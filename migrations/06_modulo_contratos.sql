-- ============================================
-- FASE 4: MÓDULO DE CONTRATOS AVANZADO
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Gestión completa de contratos con proveedores
-- Tiempo estimado: 60 minutos
-- Ejecutar DESPUÉS de Fase 3

BEGIN;

-- ============================================
-- PARTE 4.1: TABLAS ADICIONALES DE CONTRATOS
-- ============================================

-- Tabla: contract_deliveries (Entregas de contratos)
CREATE TABLE IF NOT EXISTS contract_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  contract_item_id UUID REFERENCES contract_items(id),
  center_id UUID REFERENCES health_centers(id),
  fecha_entrega_programada DATE NOT NULL,
  fecha_entrega_real DATE,
  cantidad_programada INTEGER NOT NULL,
  cantidad_recibida INTEGER,
  numero_remision TEXT,
  estado TEXT DEFAULT 'programada' CHECK (estado IN (
    'programada', 'en_transito', 'recibida', 'recibida_parcial', 'cancelada', 'retrasada'
  )),
  recibido_por UUID,
  notas TEXT,
  documentos JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_deliveries_contract ON contract_deliveries(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_deliveries_center ON contract_deliveries(center_id);
CREATE INDEX IF NOT EXISTS idx_contract_deliveries_estado ON contract_deliveries(estado);
CREATE INDEX IF NOT EXISTS idx_contract_deliveries_fecha ON contract_deliveries(fecha_entrega_programada);

COMMENT ON TABLE contract_deliveries IS 'Seguimiento de entregas programadas de contratos';

-- Tabla: contract_evaluations (Evaluaciones de contratos)
CREATE TABLE IF NOT EXISTS contract_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  evaluador_id UUID,
  fecha_evaluacion DATE DEFAULT CURRENT_DATE,
  cumplimiento_entregas DECIMAL(5,2) CHECK (cumplimiento_entregas >= 0 AND cumplimiento_entregas <= 100),
  calidad_productos DECIMAL(3,1) CHECK (calidad_productos >= 0 AND calidad_productos <= 5),
  servicio_proveedor DECIMAL(3,1) CHECK (servicio_productos >= 0 AND servicio_proveedor <= 5),
  cumplimiento_precios BOOLEAN DEFAULT true,
  observaciones TEXT,
  recomendacion TEXT CHECK (recomendacion IN ('renovar', 'renegociar', 'cancelar', 'mantener')),
  calificacion_global DECIMAL(3,1) CHECK (calificacion_global >= 0 AND calificacion_global <= 5),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_evaluations_contract ON contract_evaluations(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_evaluations_fecha ON contract_evaluations(fecha_evaluacion DESC);

COMMENT ON TABLE contract_evaluations IS 'Evaluaciones periódicas de desempeño de contratos';

-- Tabla: contract_amendments (Modificaciones de contratos)
CREATE TABLE IF NOT EXISTS contract_amendments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  numero_modificacion TEXT NOT NULL,
  tipo_modificacion TEXT CHECK (tipo_modificacion IN (
    'ampliacion_monto', 'cambio_fechas', 'adicion_items',
    'eliminacion_items', 'cambio_precios', 'cambio_condiciones'
  )),
  descripcion TEXT NOT NULL,
  monto_anterior DECIMAL(15,2),
  monto_nuevo DECIMAL(15,2),
  fecha_inicio_anterior DATE,
  fecha_inicio_nueva DATE,
  fecha_fin_anterior DATE,
  fecha_fin_nueva DATE,
  justificacion TEXT NOT NULL,
  autorizado_por UUID,
  fecha_autorizacion TIMESTAMPTZ,
  documento_url TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'en_revision', 'aprobada', 'rechazada')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_amendments_contract ON contract_amendments(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_estado ON contract_amendments(estado);

COMMENT ON TABLE contract_amendments IS 'Modificaciones y adendas a contratos existentes';

COMMIT;

-- ============================================
-- PARTE 4.2: FUNCIONES DE GESTIÓN DE CONTRATOS
-- ============================================

-- Función: Crear contrato con validaciones
CREATE OR REPLACE FUNCTION crear_contrato(
  p_codigo_contrato TEXT,
  p_supplier_id UUID,
  p_fecha_inicio DATE,
  p_fecha_fin DATE,
  p_monto_total DECIMAL,
  p_items JSONB,
  p_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  contract_id UUID
) AS $$
DECLARE
  v_contract_id UUID;
  v_item JSONB;
BEGIN
  -- Validar fechas
  IF p_fecha_fin <= p_fecha_inicio THEN
    RETURN QUERY SELECT false, 'La fecha de fin debe ser posterior a la fecha de inicio', NULL::UUID;
    RETURN;
  END IF;

  -- Validar que el proveedor existe y está activo
  IF NOT EXISTS (SELECT 1 FROM suppliers WHERE id = p_supplier_id AND is_active = true) THEN
    RETURN QUERY SELECT false, 'Proveedor no encontrado o inactivo', NULL::UUID;
    RETURN;
  END IF;

  -- Validar que el código no existe
  IF EXISTS (SELECT 1 FROM contracts WHERE codigo_contrato = p_codigo_contrato) THEN
    RETURN QUERY SELECT false, 'El código de contrato ya existe', NULL::UUID;
    RETURN;
  END IF;

  -- Crear el contrato
  INSERT INTO contracts (
    codigo_contrato,
    supplier_id,
    fecha_inicio,
    fecha_fin,
    monto_total,
    estado
  ) VALUES (
    p_codigo_contrato,
    p_supplier_id,
    p_fecha_inicio,
    p_fecha_fin,
    p_monto_total,
    'borrador'
  ) RETURNING id INTO v_contract_id;

  -- Insertar items del contrato
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    INSERT INTO contract_items (
      contract_id,
      medication_catalog_id,
      cantidad_comprometida,
      precio_unitario,
      center_destino_id,
      fecha_estimada_entrega
    ) VALUES (
      v_contract_id,
      (v_item->>'medication_catalog_id')::UUID,
      (v_item->>'cantidad')::INTEGER,
      (v_item->>'precio_unitario')::DECIMAL,
      (v_item->>'center_id')::UUID,
      (v_item->>'fecha_entrega')::DATE
    );
  END LOOP;

  -- Registrar en audit log
  INSERT INTO audit_log (
    user_id,
    action_type,
    entity_type,
    entity_id,
    entity_name,
    new_values,
    changes_summary,
    result,
    severity
  ) VALUES (
    p_usuario_id,
    'CREATE',
    'contract',
    v_contract_id,
    p_codigo_contrato,
    jsonb_build_object(
      'supplier_id', p_supplier_id,
      'monto_total', p_monto_total,
      'items', p_items
    ),
    'Contrato creado: ' || p_codigo_contrato,
    'success',
    'medium'
  );

  RETURN QUERY SELECT true, 'Contrato creado exitosamente', v_contract_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_contrato IS 'Crea un nuevo contrato con sus items y validaciones';

-- Función: Activar contrato (cambiar de borrador a activo)
CREATE OR REPLACE FUNCTION activar_contrato(
  p_contract_id UUID,
  p_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  v_contract RECORD;
BEGIN
  -- Obtener contrato
  SELECT * INTO v_contract FROM contracts WHERE id = p_contract_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Contrato no encontrado';
    RETURN;
  END IF;

  -- Validar estado
  IF v_contract.estado != 'borrador' THEN
    RETURN QUERY SELECT false, 'El contrato ya está activado o ha sido cancelado';
    RETURN;
  END IF;

  -- Validar que tiene items
  IF NOT EXISTS (SELECT 1 FROM contract_items WHERE contract_id = p_contract_id) THEN
    RETURN QUERY SELECT false, 'El contrato no tiene items asociados';
    RETURN;
  END IF;

  -- Activar contrato
  UPDATE contracts
  SET
    estado = 'activo',
    firmado_por = p_usuario_id,
    fecha_firma = NOW()
  WHERE id = p_contract_id;

  -- Registrar en audit log
  INSERT INTO audit_log (
    user_id,
    action_type,
    entity_type,
    entity_id,
    entity_name,
    changes_summary,
    result,
    severity
  ) VALUES (
    p_usuario_id,
    'APPROVE',
    'contract',
    p_contract_id,
    v_contract.codigo_contrato,
    'Contrato activado y firmado',
    'success',
    'high'
  );

  RETURN QUERY SELECT true, 'Contrato activado exitosamente';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION activar_contrato IS 'Activa un contrato en estado borrador';

-- Función: Registrar entrega de contrato
CREATE OR REPLACE FUNCTION registrar_entrega_contrato(
  p_delivery_id UUID,
  p_cantidad_recibida INTEGER,
  p_fecha_entrega_real DATE,
  p_numero_remision TEXT,
  p_recibido_por UUID,
  p_notas TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  batch_id UUID
) AS $$
DECLARE
  v_delivery RECORD;
  v_item RECORD;
  v_batch_id UUID;
BEGIN
  -- Obtener información de la entrega
  SELECT
    cd.*,
    ci.medication_catalog_id,
    ci.precio_unitario,
    c.supplier_id
  INTO v_delivery
  FROM contract_deliveries cd
  JOIN contract_items ci ON cd.contract_item_id = ci.id
  JOIN contracts c ON cd.contract_id = c.id
  WHERE cd.id = p_delivery_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Entrega no encontrada', NULL::UUID;
    RETURN;
  END IF;

  -- Validar estado
  IF v_delivery.estado NOT IN ('programada', 'en_transito') THEN
    RETURN QUERY SELECT false, 'La entrega ya fue procesada', NULL::UUID;
    RETURN;
  END IF;

  -- Actualizar entrega
  UPDATE contract_deliveries
  SET
    cantidad_recibida = p_cantidad_recibida,
    fecha_entrega_real = p_fecha_entrega_real,
    numero_remision = p_numero_remision,
    recibido_por = p_recibido_por,
    notas = p_notas,
    estado = CASE
      WHEN p_cantidad_recibida >= cantidad_programada THEN 'recibida'
      WHEN p_cantidad_recibida > 0 THEN 'recibida_parcial'
      ELSE estado
    END,
    updated_at = NOW()
  WHERE id = p_delivery_id;

  -- Aquí podrías crear automáticamente el lote en batches si es necesario
  -- (Dependería de tu lógica de negocio específica)

  RETURN QUERY SELECT
    true,
    format('Entrega registrada: %s de %s unidades', p_cantidad_recibida, v_delivery.cantidad_programada),
    v_batch_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_entrega_contrato IS 'Registra la recepción de una entrega programada';

-- Función: Evaluar desempeño de contrato
CREATE OR REPLACE FUNCTION evaluar_contrato(
  p_contract_id UUID,
  p_evaluador_id UUID,
  p_calidad_productos DECIMAL,
  p_servicio_proveedor DECIMAL,
  p_observaciones TEXT,
  p_recomendacion TEXT
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  calificacion_global DECIMAL
) AS $$
DECLARE
  v_contract RECORD;
  v_cumplimiento_entregas DECIMAL;
  v_calificacion_global DECIMAL;
  v_entregas_totales INTEGER;
  v_entregas_puntuales INTEGER;
BEGIN
  -- Validar que el contrato existe
  SELECT * INTO v_contract FROM contracts WHERE id = p_contract_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Contrato no encontrado', 0::DECIMAL;
    RETURN;
  END IF;

  -- Calcular cumplimiento de entregas
  SELECT
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE fecha_entrega_real <= fecha_entrega_programada) as puntuales
  INTO v_entregas_totales, v_entregas_puntuales
  FROM contract_deliveries
  WHERE contract_id = p_contract_id
    AND estado IN ('recibida', 'recibida_parcial');

  IF v_entregas_totales > 0 THEN
    v_cumplimiento_entregas := (v_entregas_puntuales::DECIMAL / v_entregas_totales * 100);
  ELSE
    v_cumplimiento_entregas := 100;
  END IF;

  -- Calcular calificación global (promedio ponderado)
  v_calificacion_global := (
    (p_calidad_productos * 0.4) +
    (p_servicio_proveedor * 0.3) +
    ((v_cumplimiento_entregas / 20) * 0.3)  -- Convertir % a escala 0-5
  );

  -- Insertar evaluación
  INSERT INTO contract_evaluations (
    contract_id,
    evaluador_id,
    cumplimiento_entregas,
    calidad_productos,
    servicio_proveedor,
    observaciones,
    recomendacion,
    calificacion_global
  ) VALUES (
    p_contract_id,
    p_evaluador_id,
    v_cumplimiento_entregas,
    p_calidad_productos,
    p_servicio_proveedor,
    p_observaciones,
    p_recomendacion,
    v_calificacion_global
  );

  -- Actualizar calificación del proveedor
  UPDATE suppliers
  SET
    calificacion = (
      SELECT AVG(calificacion_global)
      FROM contract_evaluations ce
      JOIN contracts c ON ce.contract_id = c.id
      WHERE c.supplier_id = v_contract.supplier_id
    )
  WHERE id = v_contract.supplier_id;

  RETURN QUERY SELECT
    true,
    'Evaluación registrada exitosamente',
    v_calificacion_global;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION evaluar_contrato IS 'Evalúa el desempeño de un contrato y actualiza la calificación del proveedor';

-- Función: Dashboard de contratos
CREATE OR REPLACE FUNCTION dashboard_contratos()
RETURNS TABLE (
  estado TEXT,
  cantidad INTEGER,
  monto_total DECIMAL,
  detalles JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.estado,
    COUNT(*)::INTEGER,
    SUM(c.monto_total)::DECIMAL(15,2),
    jsonb_build_object(
      'proximos_vencer', COUNT(*) FILTER (WHERE c.fecha_fin <= CURRENT_DATE + 90),
      'en_ejecucion', COUNT(*) FILTER (WHERE c.fecha_inicio <= CURRENT_DATE AND c.fecha_fin >= CURRENT_DATE),
      'promedio_monto', AVG(c.monto_total)
    )
  FROM contracts c
  GROUP BY c.estado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dashboard_contratos IS 'Proporciona métricas para el dashboard de contratos';

-- Función: Contratos por vencer
CREATE OR REPLACE FUNCTION contratos_por_vencer(dias_anticipacion INTEGER DEFAULT 90)
RETURNS TABLE (
  contract_id UUID,
  codigo_contrato TEXT,
  supplier_name TEXT,
  fecha_fin DATE,
  dias_restantes INTEGER,
  monto_total DECIMAL,
  calificacion_promedio DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.codigo_contrato,
    s.nombre,
    c.fecha_fin,
    (c.fecha_fin - CURRENT_DATE)::INTEGER,
    c.monto_total,
    (
      SELECT AVG(calificacion_global)
      FROM contract_evaluations
      WHERE contract_id = c.id
    )
  FROM contracts c
  JOIN suppliers s ON c.supplier_id = s.id
  WHERE c.estado = 'activo'
    AND c.fecha_fin BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
  ORDER BY c.fecha_fin ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION contratos_por_vencer IS 'Lista contratos próximos a vencer para planificar renovaciones';

COMMIT;

-- ============================================
-- PARTE 4.3: TRIGGERS PARA CONTRATOS
-- ============================================

-- Trigger: Marcar contratos vencidos automáticamente
CREATE OR REPLACE FUNCTION trigger_marcar_contratos_vencidos()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha_fin < CURRENT_DATE AND NEW.estado = 'activo' THEN
    NEW.estado := 'vencido';

    -- Crear alerta
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    )
    SELECT
      'contrato_vencido'::TEXT,
      'media',
      ci.center_destino_id,
      'Contrato Vencido',
      format('El contrato %s ha vencido', NEW.codigo_contrato),
      jsonb_build_object('contract_id', NEW.id, 'fecha_fin', NEW.fecha_fin)
    FROM contract_items ci
    WHERE ci.contract_id = NEW.id
    LIMIT 1;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_marcar_contratos_vencidos ON contracts;
CREATE TRIGGER trg_marcar_contratos_vencidos
  BEFORE UPDATE ON contracts
  FOR EACH ROW
  EXECUTE FUNCTION trigger_marcar_contratos_vencidos();

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 4 COMPLETADA' as resultado;

SELECT 'TABLAS DE CONTRATOS' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('contract_deliveries', 'contract_evaluations', 'contract_amendments')
ORDER BY table_name;

SELECT 'FUNCIONES DE CONTRATOS' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'crear_contrato',
    'activar_contrato',
    'registrar_entrega_contrato',
    'evaluar_contrato',
    'dashboard_contratos',
    'contratos_por_vencer'
  )
ORDER BY routine_name;
