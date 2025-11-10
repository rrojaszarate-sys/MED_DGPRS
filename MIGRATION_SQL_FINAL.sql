-- ============================================
-- SIGIMED - SCRIPT DE FUNCIONALIDADES AVANZADAS
-- ============================================
-- Versión: 2.0
-- Fecha: 2025-01-07
-- Descripción: Agrega trazabilidad, auditoría, búsqueda avanzada
-- ============================================

-- IMPORTANTE: Ejecutar TODO el script de una vez en Supabase SQL Editor
-- Este script es IDEMPOTENTE (se puede ejecutar múltiples veces sin problemas)

BEGIN;

-- ============================================
-- PASO 1: CREAR TABLA batch_movements
-- ============================================

-- Eliminar tabla si existe (CUIDADO: Borra datos)
-- Descomenta solo si quieres empezar de cero:
-- DROP TABLE IF EXISTS batch_movements CASCADE;

CREATE TABLE IF NOT EXISTS batch_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_id UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN (
    'entrada', 'salida', 'ajuste', 'vencimiento', 'merma',
    'transferencia_salida', 'transferencia_entrada', 'devolucion', 'destruccion'
  )),
  cantidad INTEGER NOT NULL,
  cantidad_anterior INTEGER NOT NULL,
  cantidad_posterior INTEGER NOT NULL,
  centro_origen_id UUID REFERENCES health_centers(id),
  centro_destino_id UUID REFERENCES health_centers(id),
  transfer_id UUID REFERENCES transfers(id),
  requisition_id UUID REFERENCES requisitions(id),
  adjustment_id UUID REFERENCES inventory_adjustments(id),
  numero_documento TEXT,
  motivo TEXT NOT NULL,
  observaciones TEXT,
  usuario_responsable UUID NOT NULL REFERENCES users_profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Índices para batch_movements (solo crear si no existen)
CREATE INDEX IF NOT EXISTS idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX IF NOT EXISTS idx_batch_movements_usuario ON batch_movements(usuario_responsable);
CREATE INDEX IF NOT EXISTS idx_batch_movements_created ON batch_movements(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_batch_movements_centro_origen ON batch_movements(centro_origen_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_centro_destino ON batch_movements(centro_destino_id);

-- ============================================
-- PASO 2: FUNCIÓN DE AUDITORÍA AUTOMÁTICA
-- ============================================

CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT;
  v_user_name TEXT;
  v_action_type TEXT;
  v_old_values JSONB;
  v_new_values JSONB;
BEGIN
  -- Obtener usuario actual (de Supabase Auth)
  BEGIN
    v_user_id := auth.uid();
  EXCEPTION WHEN OTHERS THEN
    v_user_id := NULL;
  END;

  IF v_user_id IS NOT NULL THEN
    SELECT email, full_name INTO v_user_email, v_user_name
    FROM users_profiles WHERE id = v_user_id;
  END IF;

  -- Determinar tipo de acción
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'CREATE';
    v_new_values := to_jsonb(NEW);
    v_old_values := NULL;
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'UPDATE';
    v_old_values := to_jsonb(OLD);
    v_new_values := to_jsonb(NEW);
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'DELETE';
    v_old_values := to_jsonb(OLD);
    v_new_values := NULL;
  END IF;

  -- Insertar en audit_log
  BEGIN
    INSERT INTO audit_log (
      user_id,
      user_email,
      user_name,
      action_type,
      entity_type,
      entity_id,
      entity_name,
      old_values,
      new_values,
      result,
      severity
    ) VALUES (
      v_user_id,
      v_user_email,
      v_user_name,
      v_action_type,
      TG_TABLE_NAME,
      COALESCE(NEW.id, OLD.id),
      CASE TG_TABLE_NAME
        WHEN 'medications' THEN COALESCE(NEW.nombre, OLD.nombre)
        WHEN 'users_profiles' THEN COALESCE(NEW.full_name, OLD.full_name)
        WHEN 'health_centers' THEN COALESCE(NEW.name, OLD.name)
        WHEN 'medication_catalog' THEN COALESCE(NEW.nombre_comercial, OLD.nombre_comercial)
        ELSE 'N/A'
      END,
      v_old_values,
      v_new_values,
      'success',
      CASE
        WHEN TG_OP = 'DELETE' THEN 'high'
        WHEN TG_OP = 'UPDATE' THEN 'medium'
        ELSE 'low'
      END
    );
  EXCEPTION WHEN OTHERS THEN
    -- Si falla el audit log, no fallar la operación principal
    RAISE WARNING 'Error al insertar en audit_log: %', SQLERRM;
  END;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 3: APLICAR TRIGGERS DE AUDITORÍA
-- ============================================

-- Eliminar triggers existentes primero (para evitar duplicados)
DROP TRIGGER IF EXISTS audit_medications ON medications;
DROP TRIGGER IF EXISTS audit_users_profiles ON users_profiles;
DROP TRIGGER IF EXISTS audit_health_centers ON health_centers;
DROP TRIGGER IF EXISTS audit_medication_catalog ON medication_catalog;
DROP TRIGGER IF EXISTS audit_transfers ON transfers;

-- Crear triggers
CREATE TRIGGER audit_medications
  AFTER INSERT OR UPDATE OR DELETE ON medications
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_users_profiles
  AFTER INSERT OR UPDATE OR DELETE ON users_profiles
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_health_centers
  AFTER INSERT OR UPDATE OR DELETE ON health_centers
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_medication_catalog
  AFTER INSERT OR UPDATE OR DELETE ON medication_catalog
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_transfers
  AFTER INSERT OR UPDATE OR DELETE ON transfers
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ============================================
-- PASO 4: FUNCIÓN PARA REGISTRAR MOVIMIENTOS
-- ============================================

CREATE OR REPLACE FUNCTION registrar_movimiento_lote(
  p_medication_id UUID,
  p_tipo_movimiento TEXT,
  p_cantidad INTEGER,
  p_motivo TEXT,
  p_usuario_responsable UUID,
  p_centro_origen_id UUID DEFAULT NULL,
  p_centro_destino_id UUID DEFAULT NULL,
  p_transfer_id UUID DEFAULT NULL,
  p_requisition_id UUID DEFAULT NULL,
  p_adjustment_id UUID DEFAULT NULL,
  p_numero_documento TEXT DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
) RETURNS JSONB AS $$
DECLARE
  v_cantidad_anterior INTEGER;
  v_cantidad_posterior INTEGER;
  v_medication RECORD;
  v_movement_id UUID;
  v_user_email TEXT;
  v_user_name TEXT;
  v_resultado JSONB;
BEGIN
  -- Obtener información del medicamento con LOCK
  SELECT * INTO v_medication
  FROM medications
  WHERE id = p_medication_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Medicamento no encontrado',
      'message', 'El medicamento especificado no existe'
    );
  END IF;

  -- Obtener información del usuario
  SELECT email, full_name INTO v_user_email, v_user_name
  FROM users_profiles WHERE id = p_usuario_responsable;

  -- Guardar cantidad anterior
  v_cantidad_anterior := v_medication.cantidad;

  -- Calcular cantidad posterior según tipo de movimiento
  IF p_tipo_movimiento IN ('salida', 'merma', 'transferencia_salida', 'destruccion') THEN
    -- Validar stock suficiente
    IF v_cantidad_anterior < p_cantidad THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'Stock insuficiente',
        'message', format('Stock disponible: %s, Solicitado: %s', v_cantidad_anterior, p_cantidad)
      );
    END IF;
    v_cantidad_posterior := v_cantidad_anterior - p_cantidad;

  ELSIF p_tipo_movimiento IN ('entrada', 'transferencia_entrada', 'devolucion') THEN
    v_cantidad_posterior := v_cantidad_anterior + p_cantidad;

  ELSIF p_tipo_movimiento = 'ajuste' THEN
    v_cantidad_posterior := v_cantidad_anterior + p_cantidad; -- p_cantidad puede ser negativo

  ELSIF p_tipo_movimiento = 'vencimiento' THEN
    v_cantidad_posterior := 0;

  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Tipo de movimiento inválido',
      'message', format('Tipo no válido: %s', p_tipo_movimiento)
    );
  END IF;

  -- Validar que la cantidad posterior no sea negativa
  IF v_cantidad_posterior < 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Cantidad negativa',
      'message', 'La cantidad resultante no puede ser negativa'
    );
  END IF;

  -- Actualizar cantidad en medications
  UPDATE medications
  SET cantidad = v_cantidad_posterior,
      updated_at = NOW()
  WHERE id = p_medication_id;

  -- Si la cantidad llegó a 0 por vencimiento, cambiar estado
  IF p_tipo_movimiento = 'vencimiento' AND v_cantidad_posterior = 0 THEN
    UPDATE medications
    SET estado = 'No Disponible'
    WHERE id = p_medication_id;
  END IF;

  -- Insertar movimiento en batch_movements
  INSERT INTO batch_movements (
    medication_id,
    tipo_movimiento,
    cantidad,
    cantidad_anterior,
    cantidad_posterior,
    centro_origen_id,
    centro_destino_id,
    transfer_id,
    requisition_id,
    adjustment_id,
    numero_documento,
    motivo,
    observaciones,
    usuario_responsable,
    metadata
  ) VALUES (
    p_medication_id,
    p_tipo_movimiento,
    p_cantidad,
    v_cantidad_anterior,
    v_cantidad_posterior,
    p_centro_origen_id,
    p_centro_destino_id,
    p_transfer_id,
    p_requisition_id,
    p_adjustment_id,
    p_numero_documento,
    p_motivo,
    p_observaciones,
    p_usuario_responsable,
    p_metadata
  ) RETURNING id INTO v_movement_id;

  -- Registrar en audit_log
  BEGIN
    INSERT INTO audit_log (
      user_id,
      user_email,
      user_name,
      action_type,
      entity_type,
      entity_id,
      entity_name,
      old_values,
      new_values,
      changes_summary,
      result,
      severity,
      metadata
    ) VALUES (
      p_usuario_responsable,
      v_user_email,
      v_user_name,
      CASE
        WHEN p_tipo_movimiento IN ('entrada', 'transferencia_entrada', 'devolucion') THEN 'CREATE'
        WHEN p_tipo_movimiento IN ('salida', 'transferencia_salida') THEN 'TRANSFER'
        WHEN p_tipo_movimiento IN ('ajuste', 'merma', 'destruccion', 'vencimiento') THEN 'ADJUST'
        ELSE 'UPDATE'
      END,
      'batch',
      v_movement_id,
      v_medication.nombre || ' - Lote: ' || v_medication.lote,
      jsonb_build_object(
        'cantidad', v_cantidad_anterior,
        'estado', v_medication.estado
      ),
      jsonb_build_object(
        'cantidad', v_cantidad_posterior,
        'tipo_movimiento', p_tipo_movimiento
      ),
      format('Movimiento de %s: %s unidades. Motivo: %s', p_tipo_movimiento, p_cantidad, p_motivo),
      'success',
      CASE
        WHEN p_tipo_movimiento IN ('vencimiento', 'destruccion') THEN 'high'
        WHEN p_tipo_movimiento IN ('merma') THEN 'medium'
        ELSE 'low'
      END,
      jsonb_build_object(
        'movement_id', v_movement_id,
        'medication_id', p_medication_id,
        'tipo_movimiento', p_tipo_movimiento
      )
    );
  EXCEPTION WHEN OTHERS THEN
    -- Si falla el audit log, no fallar todo
    RAISE WARNING 'Error al registrar en audit_log: %', SQLERRM;
  END;

  -- Retornar resultado exitoso
  RETURN jsonb_build_object(
    'success', true,
    'movement_id', v_movement_id,
    'cantidad_anterior', v_cantidad_anterior,
    'cantidad_posterior', v_cantidad_posterior,
    'message', format('Movimiento registrado exitosamente: %s', p_tipo_movimiento)
  );

EXCEPTION
  WHEN OTHERS THEN
    -- Capturar cualquier error no manejado
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM,
      'message', 'Error al registrar movimiento'
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 5: FUNCIÓN DE REPORTE DE TRAZABILIDAD
-- ============================================

CREATE OR REPLACE FUNCTION generate_traceability_report(
  p_medication_id UUID DEFAULT NULL,
  p_lote TEXT DEFAULT NULL,
  p_center_id UUID DEFAULT NULL,
  p_fecha_inicio DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT NULL,
  p_estado TEXT DEFAULT NULL,
  p_include_history BOOLEAN DEFAULT true
) RETURNS TABLE (
  medication_id UUID,
  medication_nombre TEXT,
  medication_lote TEXT,
  medication_cantidad INTEGER,
  medication_fecha_caducidad DATE,
  medication_estado TEXT,
  medication_ubicacion TEXT,
  center_id UUID,
  center_name TEXT,
  ultimo_movimiento_tipo TEXT,
  ultimo_movimiento_fecha TIMESTAMP WITH TIME ZONE,
  ultimo_movimiento_usuario TEXT,
  total_movimientos BIGINT,
  historial_movimientos JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id AS medication_id,
    m.nombre AS medication_nombre,
    m.lote AS medication_lote,
    m.cantidad AS medication_cantidad,
    m.fecha_caducidad AS medication_fecha_caducidad,
    m.estado AS medication_estado,
    m.ubicacion_fisica AS medication_ubicacion,
    m.center_id,
    hc.name AS center_name,
    bm_last.tipo_movimiento AS ultimo_movimiento_tipo,
    bm_last.created_at AS ultimo_movimiento_fecha,
    up_last.full_name AS ultimo_movimiento_usuario,
    (SELECT COUNT(*)::BIGINT FROM batch_movements WHERE medication_id = m.id) AS total_movimientos,
    CASE
      WHEN p_include_history THEN
        (
          SELECT jsonb_agg(
            jsonb_build_object(
              'id', bm.id,
              'tipo', bm.tipo_movimiento,
              'cantidad', bm.cantidad,
              'cantidad_anterior', bm.cantidad_anterior,
              'cantidad_posterior', bm.cantidad_posterior,
              'motivo', bm.motivo,
              'usuario', up.full_name,
              'fecha', bm.created_at
            ) ORDER BY bm.created_at DESC
          )
          FROM batch_movements bm
          LEFT JOIN users_profiles up ON bm.usuario_responsable = up.id
          WHERE bm.medication_id = m.id
        )
      ELSE NULL
    END AS historial_movimientos
  FROM medications m
  LEFT JOIN health_centers hc ON m.center_id = hc.id
  LEFT JOIN LATERAL (
    SELECT * FROM batch_movements
    WHERE medication_id = m.id
    ORDER BY created_at DESC
    LIMIT 1
  ) bm_last ON true
  LEFT JOIN users_profiles up_last ON bm_last.usuario_responsable = up_last.id
  WHERE
    (p_medication_id IS NULL OR m.id = p_medication_id)
    AND (p_lote IS NULL OR m.lote ILIKE '%' || p_lote || '%')
    AND (p_center_id IS NULL OR m.center_id = p_center_id)
    AND (p_fecha_inicio IS NULL OR m.fecha_caducidad >= p_fecha_inicio)
    AND (p_fecha_fin IS NULL OR m.fecha_caducidad <= p_fecha_fin)
    AND (p_estado IS NULL OR m.estado = p_estado)
  ORDER BY m.fecha_caducidad ASC, m.nombre ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 6: FUNCIÓN DE BÚSQUEDA AVANZADA
-- ============================================

CREATE OR REPLACE FUNCTION search_inventory_with_batches(
  p_search_term TEXT DEFAULT NULL,
  p_center_id UUID DEFAULT NULL,
  p_stock_bajo INTEGER DEFAULT NULL,
  p_vencidos BOOLEAN DEFAULT false,
  p_proximos_vencer_dias INTEGER DEFAULT NULL,
  p_estado TEXT DEFAULT NULL
) RETURNS TABLE (
  id UUID,
  center_id UUID,
  center_name TEXT,
  catalog_id UUID,
  nombre TEXT,
  formula_activa TEXT,
  lote TEXT,
  cantidad INTEGER,
  fecha_caducidad DATE,
  fecha_ingreso DATE,
  estado TEXT,
  ubicacion_fisica TEXT,
  dias_para_vencer INTEGER,
  stock_alert BOOLEAN,
  expired_alert BOOLEAN,
  expiring_soon_alert BOOLEAN,
  total_movements BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id,
    m.center_id,
    hc.name AS center_name,
    m.catalog_id,
    m.nombre,
    m.formula_activa,
    m.lote,
    m.cantidad,
    m.fecha_caducidad,
    m.fecha_ingreso,
    m.estado,
    m.ubicacion_fisica,
    (m.fecha_caducidad - CURRENT_DATE)::INTEGER AS dias_para_vencer,
    (p_stock_bajo IS NOT NULL AND m.cantidad <= p_stock_bajo) AS stock_alert,
    (m.fecha_caducidad < CURRENT_DATE) AS expired_alert,
    (p_proximos_vencer_dias IS NOT NULL AND
     m.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + (p_proximos_vencer_dias || ' days')::INTERVAL
    ) AS expiring_soon_alert,
    (SELECT COUNT(*)::BIGINT FROM batch_movements WHERE medication_id = m.id) AS total_movements
  FROM medications m
  LEFT JOIN health_centers hc ON m.center_id = hc.id
  WHERE
    (p_search_term IS NULL OR
     m.nombre ILIKE '%' || p_search_term || '%' OR
     m.formula_activa ILIKE '%' || p_search_term || '%' OR
     m.lote ILIKE '%' || p_search_term || '%')
    AND (p_center_id IS NULL OR m.center_id = p_center_id)
    AND (p_stock_bajo IS NULL OR m.cantidad <= p_stock_bajo)
    AND (p_vencidos = false OR m.fecha_caducidad < CURRENT_DATE)
    AND (p_proximos_vencer_dias IS NULL OR
         m.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + (p_proximos_vencer_dias || ' days')::INTERVAL)
    AND (p_estado IS NULL OR m.estado = p_estado)
  ORDER BY
    CASE WHEN m.fecha_caducidad < CURRENT_DATE THEN 0 ELSE 1 END,
    m.fecha_caducidad ASC,
    m.nombre ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 7: CONFIGURAR RLS (Row Level Security)
-- ============================================

-- Habilitar RLS en batch_movements
ALTER TABLE batch_movements ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si hay
DROP POLICY IF EXISTS "Users can view movements from their centers" ON batch_movements;
DROP POLICY IF EXISTS "System can insert movements" ON batch_movements;

-- Policy para ver movimientos (usuarios autenticados del mismo centro)
CREATE POLICY "Users can view movements from their centers"
  ON batch_movements FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM medications m
      JOIN user_centers uc ON m.center_id = uc.center_id
      WHERE m.id = batch_movements.medication_id
      AND uc.user_id = auth.uid()
    )
  );

-- Policy para insertar movimientos (a través de la función)
CREATE POLICY "System can insert movements"
  ON batch_movements FOR INSERT
  WITH CHECK (true);

-- Habilitar RLS en audit_log
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si hay
DROP POLICY IF EXISTS "Admins can view audit logs" ON audit_log;
DROP POLICY IF EXISTS "System can insert audit logs" ON audit_log;

-- Policy para ver audit_log (solo super_admin y admin_center)
CREATE POLICY "Admins can view audit logs"
  ON audit_log FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

-- Policy para insertar en audit_log (sistema)
CREATE POLICY "System can insert audit logs"
  ON audit_log FOR INSERT
  WITH CHECK (true);

COMMIT;

-- ============================================
-- VERIFICACIÓN POST-INSTALACIÓN
-- ============================================

-- Verificar que todo se creó correctamente
DO $$
DECLARE
  v_batch_movements_exists BOOLEAN;
  v_audit_log_exists BOOLEAN;
  v_func_count INTEGER;
  v_trigger_count INTEGER;
BEGIN
  -- Verificar tablas
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'batch_movements'
  ) INTO v_batch_movements_exists;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'audit_log'
  ) INTO v_audit_log_exists;

  -- Verificar funciones
  SELECT COUNT(*) INTO v_func_count
  FROM information_schema.routines
  WHERE routine_type = 'FUNCTION'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'generate_traceability_report',
    'search_inventory_with_batches',
    'audit_trigger_func'
  );

  -- Verificar triggers
  SELECT COUNT(*) INTO v_trigger_count
  FROM information_schema.triggers
  WHERE trigger_name LIKE 'audit_%';

  -- Mostrar resultados
  RAISE NOTICE '';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'VERIFICACIÓN DE INSTALACIÓN';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Tabla batch_movements: %', CASE WHEN v_batch_movements_exists THEN '✅ OK' ELSE '❌ FALTA' END;
  RAISE NOTICE 'Tabla audit_log: %', CASE WHEN v_audit_log_exists THEN '✅ OK' ELSE '❌ FALTA' END;
  RAISE NOTICE 'Funciones SQL: % de 4', v_func_count;
  RAISE NOTICE 'Triggers: % de 5', v_trigger_count;
  RAISE NOTICE '============================================';

  IF v_batch_movements_exists AND v_audit_log_exists AND v_func_count = 4 AND v_trigger_count >= 5 THEN
    RAISE NOTICE '🎉 INSTALACIÓN EXITOSA - TODO FUNCIONANDO';
  ELSE
    RAISE NOTICE '⚠️  INSTALACIÓN INCOMPLETA - REVISAR ERRORES';
  END IF;
  RAISE NOTICE '============================================';
  RAISE NOTICE '';
END $$;
