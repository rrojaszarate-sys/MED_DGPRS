-- ============================================
-- FASE 1 - PARTE 1.5: FUNCIONES Y TRIGGERS
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Crear funciones para gestión de lotes y triggers automáticos
-- Ejecutar DESPUÉS de 02_insertar_datos_iniciales.sql

BEGIN;

-- ============================================
-- FUNCIÓN 1: REGISTRAR MOVIMIENTO DE LOTE
-- ============================================
CREATE OR REPLACE FUNCTION registrar_movimiento_lote(
  p_batch_id UUID,
  p_tipo_movimiento TEXT,
  p_cantidad INTEGER,
  p_motivo TEXT,
  p_centro_destino_id UUID DEFAULT NULL,
  p_numero_documento TEXT DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL,
  p_usuario_responsable UUID DEFAULT NULL
) RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  new_quantity INTEGER,
  movement_id UUID
) AS $$
DECLARE
  v_batch RECORD;
  v_nueva_cantidad INTEGER;
  v_movement_id UUID;
  v_medication_id UUID;
  v_center_id UUID;
BEGIN
  -- Obtener información del lote
  SELECT * INTO v_batch FROM batches WHERE id = p_batch_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Lote no encontrado', 0::INTEGER, NULL::UUID;
    RETURN;
  END IF;

  v_medication_id := v_batch.medication_id;
  v_center_id := v_batch.center_id;

  -- Validar tipo de movimiento
  IF p_tipo_movimiento NOT IN (
    'entrada', 'salida', 'ajuste', 'transferencia_salida',
    'transferencia_entrada', 'devolucion', 'merma', 'vencimiento'
  ) THEN
    RETURN QUERY SELECT false, 'Tipo de movimiento inválido', 0::INTEGER, NULL::UUID;
    RETURN;
  END IF;

  -- Calcular nueva cantidad según tipo de movimiento
  CASE p_tipo_movimiento
    WHEN 'entrada', 'transferencia_entrada', 'devolucion' THEN
      v_nueva_cantidad := v_batch.cantidad_actual + p_cantidad;
    WHEN 'salida', 'transferencia_salida', 'merma', 'vencimiento' THEN
      v_nueva_cantidad := v_batch.cantidad_actual - p_cantidad;
      -- Validar que no quede negativo
      IF v_nueva_cantidad < 0 THEN
        RETURN QUERY SELECT
          false,
          'Stock insuficiente. Disponible: ' || v_batch.cantidad_actual::TEXT,
          v_batch.cantidad_actual::INTEGER,
          NULL::UUID;
        RETURN;
      END IF;
    WHEN 'ajuste' THEN
      v_nueva_cantidad := p_cantidad; -- p_cantidad es el nuevo total
    ELSE
      RETURN QUERY SELECT false, 'Tipo de movimiento no soportado', 0::INTEGER, NULL::UUID;
      RETURN;
  END CASE;

  -- Crear el movimiento
  INSERT INTO batch_movements (
    batch_id,
    medication_id,
    center_id,
    tipo_movimiento,
    cantidad,
    cantidad_anterior,
    cantidad_posterior,
    centro_destino_id,
    numero_documento,
    motivo,
    observaciones,
    usuario_responsable,
    metadata
  ) VALUES (
    p_batch_id,
    v_medication_id,
    v_center_id,
    p_tipo_movimiento,
    p_cantidad,
    v_batch.cantidad_actual,
    v_nueva_cantidad,
    p_centro_destino_id,
    p_numero_documento,
    p_motivo,
    p_observaciones,
    p_usuario_responsable,
    jsonb_build_object(
      'fecha_caducidad', v_batch.fecha_caducidad,
      'numero_lote', v_batch.numero_lote,
      'ubicacion_fisica', v_batch.ubicacion_fisica
    )
  ) RETURNING id INTO v_movement_id;

  -- Actualizar cantidad del lote
  UPDATE batches
  SET
    cantidad_actual = v_nueva_cantidad,
    estado = CASE
      WHEN v_nueva_cantidad = 0 THEN 'agotado'
      WHEN v_nueva_cantidad < stock_minimo THEN estado -- Mantener estado actual
      ELSE 'disponible'
    END,
    updated_at = NOW()
  WHERE id = p_batch_id;

  -- También actualizar la tabla medications si existe
  UPDATE medications
  SET
    cantidad = v_nueva_cantidad,
    updated_at = NOW()
  WHERE id = v_medication_id
    AND center_id = v_center_id;

  RETURN QUERY SELECT
    true,
    'Movimiento registrado exitosamente',
    v_nueva_cantidad,
    v_movement_id;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT
      false,
      'Error: ' || SQLERRM,
      0::INTEGER,
      NULL::UUID;
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_movimiento_lote IS 'Registra un movimiento de lote y actualiza inventario automáticamente';

-- ============================================
-- FUNCIÓN 2: DETECTAR LOTES VENCIDOS
-- ============================================
CREATE OR REPLACE FUNCTION detectar_lotes_vencidos()
RETURNS TABLE (
  batch_id UUID,
  medication_name TEXT,
  center_name TEXT,
  numero_lote TEXT,
  cantidad_actual INTEGER,
  fecha_caducidad DATE,
  dias_vencido INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    m.nombre,
    hc.name,
    b.numero_lote,
    b.cantidad_actual,
    b.fecha_caducidad,
    (CURRENT_DATE - b.fecha_caducidad)::INTEGER as dias_vencido
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.fecha_caducidad < CURRENT_DATE
    AND b.estado != 'vencido'
    AND b.cantidad_actual > 0
  ORDER BY b.fecha_caducidad ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION detectar_lotes_vencidos IS 'Detecta lotes que ya están vencidos y tienen stock';

-- ============================================
-- FUNCIÓN 3: LOTES PRÓXIMOS A VENCER
-- ============================================
CREATE OR REPLACE FUNCTION lotes_proximos_vencer(dias_anticipacion INTEGER DEFAULT 90)
RETURNS TABLE (
  batch_id UUID,
  medication_name TEXT,
  center_name TEXT,
  numero_lote TEXT,
  cantidad_actual INTEGER,
  fecha_caducidad DATE,
  dias_restantes INTEGER,
  urgencia TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    m.nombre,
    hc.name,
    b.numero_lote,
    b.cantidad_actual,
    b.fecha_caducidad,
    (b.fecha_caducidad - CURRENT_DATE)::INTEGER as dias_restantes,
    CASE
      WHEN (b.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'CRÍTICA'
      WHEN (b.fecha_caducidad - CURRENT_DATE) <= 60 THEN 'ALTA'
      ELSE 'MEDIA'
    END as urgencia
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
    AND b.estado = 'disponible'
    AND b.cantidad_actual > 0
  ORDER BY b.fecha_caducidad ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION lotes_proximos_vencer IS 'Lista lotes próximos a vencer con nivel de urgencia';

-- ============================================
-- FUNCIÓN 4: LOTES CON STOCK BAJO
-- ============================================
CREATE OR REPLACE FUNCTION lotes_stock_bajo()
RETURNS TABLE (
  batch_id UUID,
  medication_name TEXT,
  center_name TEXT,
  numero_lote TEXT,
  cantidad_actual INTEGER,
  stock_minimo INTEGER,
  porcentaje_disponible DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    m.nombre,
    hc.name,
    b.numero_lote,
    b.cantidad_actual,
    b.stock_minimo,
    ROUND((b.cantidad_actual::DECIMAL / NULLIF(b.stock_minimo, 0) * 100), 2) as porcentaje
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.cantidad_actual <= b.stock_minimo
    AND b.cantidad_actual > 0
    AND b.estado = 'disponible'
  ORDER BY (b.cantidad_actual::DECIMAL / NULLIF(b.stock_minimo, 1)) ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION lotes_stock_bajo IS 'Detecta lotes con stock por debajo del mínimo';

-- ============================================
-- TRIGGER 1: ACTUALIZAR ESTADO AUTOMÁTICAMENTE
-- ============================================
CREATE OR REPLACE FUNCTION trigger_actualizar_estado_lote()
RETURNS TRIGGER AS $$
BEGIN
  -- Marcar como vencido si pasó la fecha de caducidad
  IF NEW.fecha_caducidad < CURRENT_DATE AND NEW.estado != 'vencido' THEN
    NEW.estado := 'vencido';
  END IF;

  -- Marcar como agotado si cantidad es 0
  IF NEW.cantidad_actual = 0 AND NEW.estado != 'agotado' THEN
    NEW.estado := 'agotado';
  END IF;

  -- Actualizar updated_at
  NEW.updated_at := NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_actualizar_estado_lote ON batches;
CREATE TRIGGER trg_actualizar_estado_lote
  BEFORE UPDATE ON batches
  FOR EACH ROW
  EXECUTE FUNCTION trigger_actualizar_estado_lote();

COMMENT ON TRIGGER trg_actualizar_estado_lote ON batches IS 'Actualiza automáticamente el estado del lote según reglas de negocio';

-- ============================================
-- TRIGGER 2: REGISTRAR EN AUDIT_LOG
-- ============================================
CREATE OR REPLACE FUNCTION trigger_audit_batch_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_action_type TEXT;
  v_changes_summary TEXT;
BEGIN
  -- Determinar tipo de acción
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'CREATE';
    v_changes_summary := 'Nuevo lote creado: ' || NEW.numero_lote;
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'UPDATE';
    v_changes_summary := 'Lote actualizado: ' || NEW.numero_lote;

    -- Detalles específicos de cambios
    IF OLD.cantidad_actual != NEW.cantidad_actual THEN
      v_changes_summary := v_changes_summary ||
        ' | Cantidad: ' || OLD.cantidad_actual || ' → ' || NEW.cantidad_actual;
    END IF;

    IF OLD.estado != NEW.estado THEN
      v_changes_summary := v_changes_summary ||
        ' | Estado: ' || OLD.estado || ' → ' || NEW.estado;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'DELETE';
    v_changes_summary := 'Lote eliminado: ' || OLD.numero_lote;
  END IF;

  -- Insertar en audit_log
  INSERT INTO audit_log (
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
    v_action_type,
    'batch',
    COALESCE(NEW.id, OLD.id),
    COALESCE(NEW.numero_lote, OLD.numero_lote),
    CASE WHEN TG_OP != 'INSERT' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END,
    v_changes_summary,
    'success',
    CASE
      WHEN TG_OP = 'DELETE' THEN 'high'
      WHEN TG_OP = 'INSERT' THEN 'medium'
      ELSE 'low'
    END,
    jsonb_build_object('trigger', TG_NAME, 'table', TG_TABLE_NAME)
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_batch_changes ON batches;
CREATE TRIGGER trg_audit_batch_changes
  AFTER INSERT OR UPDATE OR DELETE ON batches
  FOR EACH ROW
  EXECUTE FUNCTION trigger_audit_batch_changes();

COMMENT ON TRIGGER trg_audit_batch_changes ON batches IS 'Registra todos los cambios en lotes en la tabla de auditoría';

COMMIT;

-- ============================================
-- VERIFICACIÓN Y PRUEBAS
-- ============================================
SELECT '✅ PARTE 1.5 COMPLETADA' as resultado;

-- Listar funciones creadas
SELECT
  routine_name as funcion,
  'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'detectar_lotes_vencidos',
    'lotes_proximos_vencer',
    'lotes_stock_bajo',
    'trigger_actualizar_estado_lote',
    'trigger_audit_batch_changes'
  )
ORDER BY routine_name;

-- Listar triggers creados
SELECT
  trigger_name as trigger,
  event_object_table as tabla,
  'OK' as estado
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name IN (
    'trg_actualizar_estado_lote',
    'trg_audit_batch_changes'
  )
ORDER BY trigger_name;

-- Prueba de la función: detectar lotes próximos a vencer (90 días)
SELECT '🔍 PRUEBA: Lotes próximos a vencer' as titulo;
SELECT * FROM lotes_proximos_vencer(90) LIMIT 5;

-- Prueba de la función: detectar stock bajo
SELECT '🔍 PRUEBA: Lotes con stock bajo' as titulo;
SELECT * FROM lotes_stock_bajo() LIMIT 5;
