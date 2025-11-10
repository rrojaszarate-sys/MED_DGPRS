-- ============================================
-- FASE 3: CONTROL DE CALIDAD AVANZADO
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Sistema de alertas, métricas y control de calidad
-- Tiempo estimado: 60 minutos
-- Ejecutar DESPUÉS de Fase 2

BEGIN;

-- ============================================
-- PARTE 3.1: TABLA DE ALERTAS
-- ============================================

CREATE TABLE IF NOT EXISTS alertas_medicamentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_alerta TEXT NOT NULL CHECK (tipo_alerta IN (
    'stock_bajo', 'proximo_vencer', 'vencido', 'lote_cuarentena',
    'temperatura_fuera_rango', 'discrepancia_inventario', 'medicamento_faltante'
  )),
  severidad TEXT NOT NULL CHECK (severidad IN ('baja', 'media', 'alta', 'critica')),
  medication_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  datos_adicionales JSONB DEFAULT '{}'::jsonb,
  estado TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_revision', 'resuelta', 'descartada')),
  resuelta_por UUID,
  resuelta_en TIMESTAMPTZ,
  notas_resolucion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alertas_tipo ON alertas_medicamentos(tipo_alerta);
CREATE INDEX IF NOT EXISTS idx_alertas_severidad ON alertas_medicamentos(severidad);
CREATE INDEX IF NOT EXISTS idx_alertas_estado ON alertas_medicamentos(estado);
CREATE INDEX IF NOT EXISTS idx_alertas_center ON alertas_medicamentos(center_id);
CREATE INDEX IF NOT EXISTS idx_alertas_medication ON alertas_medicamentos(medication_id);
CREATE INDEX IF NOT EXISTS idx_alertas_batch ON alertas_medicamentos(batch_id);
CREATE INDEX IF NOT EXISTS idx_alertas_created ON alertas_medicamentos(created_at DESC);

COMMENT ON TABLE alertas_medicamentos IS 'Sistema centralizado de alertas y notificaciones';
COMMENT ON COLUMN alertas_medicamentos.datos_adicionales IS 'Información adicional en JSON (cantidades, fechas, etc.)';

-- ============================================
-- PARTE 3.2: TABLA DE NOTIFICACIONES
-- ============================================

CREATE TABLE IF NOT EXISTS notificaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN (
    'alerta_stock', 'alerta_vencimiento', 'aprobacion_requerida',
    'transferencia_recibida', 'contrato_vencido', 'inspeccion_pendiente'
  )),
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  enlace TEXT,
  icono TEXT,
  leida BOOLEAN DEFAULT false,
  leida_en TIMESTAMPTZ,
  referencia_tipo TEXT,
  referencia_id UUID,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notificaciones_user ON notificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON notificaciones(leida) WHERE leida = false;
CREATE INDEX IF NOT EXISTS idx_notificaciones_tipo ON notificaciones(tipo);
CREATE INDEX IF NOT EXISTS idx_notificaciones_created ON notificaciones(created_at DESC);

COMMENT ON TABLE notificaciones IS 'Notificaciones para usuarios del sistema';

-- ============================================
-- PARTE 3.3: TABLA DE MÉTRICAS
-- ============================================

CREATE TABLE IF NOT EXISTS metricas_inventario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  fecha DATE NOT NULL DEFAULT CURRENT_DATE,
  total_medicamentos INTEGER DEFAULT 0,
  total_lotes INTEGER DEFAULT 0,
  valor_inventario DECIMAL(15,2) DEFAULT 0,
  medicamentos_bajo_stock INTEGER DEFAULT 0,
  lotes_proximos_vencer INTEGER DEFAULT 0,
  lotes_vencidos INTEGER DEFAULT 0,
  movimientos_entrada INTEGER DEFAULT 0,
  movimientos_salida INTEGER DEFAULT 0,
  tasa_rotacion DECIMAL(5,2),
  cumplimiento_stock DECIMAL(5,2),
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(center_id, fecha)
);

CREATE INDEX IF NOT EXISTS idx_metricas_center ON metricas_inventario(center_id);
CREATE INDEX IF NOT EXISTS idx_metricas_fecha ON metricas_inventario(fecha DESC);

COMMENT ON TABLE metricas_inventario IS 'Métricas diarias de inventario por centro';
COMMENT ON COLUMN metricas_inventario.tasa_rotacion IS 'Tasa de rotación de inventario (salidas / stock promedio)';
COMMENT ON COLUMN metricas_inventario.cumplimiento_stock IS 'Porcentaje de medicamentos con stock adecuado';

COMMIT;

-- ============================================
-- PARTE 3.4: FUNCIONES DE GENERACIÓN DE ALERTAS
-- ============================================

-- Función: Generar alertas de stock bajo
CREATE OR REPLACE FUNCTION generar_alertas_stock_bajo()
RETURNS TABLE (
  alertas_creadas INTEGER,
  mensaje TEXT
) AS $$
DECLARE
  v_count INTEGER := 0;
  v_batch RECORD;
BEGIN
  -- Buscar lotes con stock bajo
  FOR v_batch IN
    SELECT
      b.id as batch_id,
      b.medication_id,
      b.center_id,
      b.numero_lote,
      b.cantidad_actual,
      b.stock_minimo,
      m.nombre as medication_name,
      hc.name as center_name
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    JOIN health_centers hc ON b.center_id = hc.id
    WHERE b.cantidad_actual <= b.stock_minimo
      AND b.cantidad_actual > 0
      AND b.estado = 'disponible'
      AND NOT EXISTS (
        SELECT 1 FROM alertas_medicamentos
        WHERE batch_id = b.id
          AND tipo_alerta = 'stock_bajo'
          AND estado IN ('pendiente', 'en_revision')
          AND created_at > NOW() - INTERVAL '7 days'
      )
  LOOP
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    ) VALUES (
      'stock_bajo',
      CASE
        WHEN v_batch.cantidad_actual <= (v_batch.stock_minimo * 0.5) THEN 'alta'
        WHEN v_batch.cantidad_actual <= (v_batch.stock_minimo * 0.75) THEN 'media'
        ELSE 'baja'
      END,
      v_batch.medication_id,
      v_batch.batch_id,
      v_batch.center_id,
      'Stock Bajo: ' || v_batch.medication_name,
      format('El lote %s tiene solo %s unidades (mínimo: %s)',
        v_batch.numero_lote,
        v_batch.cantidad_actual,
        v_batch.stock_minimo
      ),
      jsonb_build_object(
        'cantidad_actual', v_batch.cantidad_actual,
        'stock_minimo', v_batch.stock_minimo,
        'porcentaje', ROUND((v_batch.cantidad_actual::DECIMAL / v_batch.stock_minimo * 100), 2)
      )
    );

    v_count := v_count + 1;
  END LOOP;

  RETURN QUERY SELECT v_count, format('Se crearon %s alertas de stock bajo', v_count);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_alertas_stock_bajo IS 'Genera alertas automáticas para lotes con stock bajo';

-- Función: Generar alertas de vencimiento
CREATE OR REPLACE FUNCTION generar_alertas_vencimiento(dias_anticipacion INTEGER DEFAULT 90)
RETURNS TABLE (
  alertas_creadas INTEGER,
  mensaje TEXT
) AS $$
DECLARE
  v_count INTEGER := 0;
  v_batch RECORD;
BEGIN
  -- Buscar lotes próximos a vencer
  FOR v_batch IN
    SELECT
      b.id as batch_id,
      b.medication_id,
      b.center_id,
      b.numero_lote,
      b.cantidad_actual,
      b.fecha_caducidad,
      (b.fecha_caducidad - CURRENT_DATE)::INTEGER as dias_restantes,
      m.nombre as medication_name,
      hc.name as center_name
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    JOIN health_centers hc ON b.center_id = hc.id
    WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
      AND b.cantidad_actual > 0
      AND b.estado = 'disponible'
      AND NOT EXISTS (
        SELECT 1 FROM alertas_medicamentos
        WHERE batch_id = b.id
          AND tipo_alerta = 'proximo_vencer'
          AND estado IN ('pendiente', 'en_revision')
          AND created_at > NOW() - INTERVAL '7 days'
      )
  LOOP
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    ) VALUES (
      'proximo_vencer',
      CASE
        WHEN v_batch.dias_restantes <= 30 THEN 'critica'
        WHEN v_batch.dias_restantes <= 60 THEN 'alta'
        ELSE 'media'
      END,
      v_batch.medication_id,
      v_batch.batch_id,
      v_batch.center_id,
      'Próximo a Vencer: ' || v_batch.medication_name,
      format('El lote %s vence en %s días (%s)',
        v_batch.numero_lote,
        v_batch.dias_restantes,
        v_batch.fecha_caducidad
      ),
      jsonb_build_object(
        'dias_restantes', v_batch.dias_restantes,
        'fecha_caducidad', v_batch.fecha_caducidad,
        'cantidad_actual', v_batch.cantidad_actual
      )
    );

    v_count := v_count + 1;
  END LOOP;

  -- Buscar lotes ya vencidos
  FOR v_batch IN
    SELECT
      b.id as batch_id,
      b.medication_id,
      b.center_id,
      b.numero_lote,
      b.cantidad_actual,
      b.fecha_caducidad,
      (CURRENT_DATE - b.fecha_caducidad)::INTEGER as dias_vencido,
      m.nombre as medication_name,
      hc.name as center_name
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    JOIN health_centers hc ON b.center_id = hc.id
    WHERE b.fecha_caducidad < CURRENT_DATE
      AND b.cantidad_actual > 0
      AND b.estado != 'vencido'
      AND NOT EXISTS (
        SELECT 1 FROM alertas_medicamentos
        WHERE batch_id = b.id
          AND tipo_alerta = 'vencido'
          AND estado IN ('pendiente', 'en_revision')
      )
  LOOP
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    ) VALUES (
      'vencido',
      'critica',
      v_batch.medication_id,
      v_batch.batch_id,
      v_batch.center_id,
      'VENCIDO: ' || v_batch.medication_name,
      format('El lote %s está vencido desde hace %s días. Retirar inmediatamente.',
        v_batch.numero_lote,
        v_batch.dias_vencido
      ),
      jsonb_build_object(
        'dias_vencido', v_batch.dias_vencido,
        'fecha_caducidad', v_batch.fecha_caducidad,
        'cantidad_actual', v_batch.cantidad_actual
      )
    );

    -- Actualizar estado del lote
    UPDATE batches SET estado = 'vencido', updated_at = NOW()
    WHERE id = v_batch.batch_id;

    v_count := v_count + 1;
  END LOOP;

  RETURN QUERY SELECT v_count, format('Se crearon %s alertas de vencimiento', v_count);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_alertas_vencimiento IS 'Genera alertas para lotes próximos a vencer o ya vencidos';

-- ============================================
-- PARTE 3.5: FUNCIONES DE MÉTRICAS
-- ============================================

-- Función: Calcular métricas diarias
CREATE OR REPLACE FUNCTION calcular_metricas_diarias(p_center_id UUID DEFAULT NULL)
RETURNS TABLE (
  center_id UUID,
  fecha DATE,
  metricas JSONB
) AS $$
BEGIN
  RETURN QUERY
  WITH centers AS (
    SELECT id FROM health_centers
    WHERE (p_center_id IS NULL OR id = p_center_id)
      AND is_active = true
  ),
  stats AS (
    SELECT
      c.id as center_id,
      CURRENT_DATE as fecha,
      COUNT(DISTINCT m.id) as total_medicamentos,
      COUNT(DISTINCT b.id) as total_lotes,
      COUNT(DISTINCT b.id) FILTER (WHERE b.cantidad_actual <= b.stock_minimo) as medicamentos_bajo_stock,
      COUNT(DISTINCT b.id) FILTER (
        WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + 90)
      ) as lotes_proximos_vencer,
      COUNT(DISTINCT b.id) FILTER (WHERE b.fecha_caducidad < CURRENT_DATE) as lotes_vencidos,
      COUNT(bm.id) FILTER (
        WHERE bm.tipo_movimiento IN ('entrada', 'transferencia_entrada')
          AND bm.created_at >= CURRENT_DATE
      ) as movimientos_entrada,
      COUNT(bm.id) FILTER (
        WHERE bm.tipo_movimiento IN ('salida', 'transferencia_salida')
          AND bm.created_at >= CURRENT_DATE
      ) as movimientos_salida
    FROM centers c
    LEFT JOIN medications m ON m.center_id = c.id
    LEFT JOIN batches b ON b.center_id = c.id AND b.cantidad_actual > 0
    LEFT JOIN batch_movements bm ON bm.center_id = c.id
    GROUP BY c.id
  )
  SELECT
    s.center_id,
    s.fecha,
    jsonb_build_object(
      'total_medicamentos', s.total_medicamentos,
      'total_lotes', s.total_lotes,
      'medicamentos_bajo_stock', s.medicamentos_bajo_stock,
      'lotes_proximos_vencer', s.lotes_proximos_vencer,
      'lotes_vencidos', s.lotes_vencidos,
      'movimientos_entrada', s.movimientos_entrada,
      'movimientos_salida', s.movimientos_salida,
      'cumplimiento_stock', ROUND(
        CASE
          WHEN s.total_medicamentos > 0
          THEN ((s.total_medicamentos - s.medicamentos_bajo_stock)::DECIMAL / s.total_medicamentos * 100)
          ELSE 100
        END, 2
      )
    ) as metricas
  FROM stats s;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calcular_metricas_diarias IS 'Calcula métricas diarias de inventario por centro';

-- Función: Guardar métricas diarias
CREATE OR REPLACE FUNCTION guardar_metricas_diarias()
RETURNS TABLE (
  centros_procesados INTEGER,
  mensaje TEXT
) AS $$
DECLARE
  v_count INTEGER := 0;
  v_metric RECORD;
BEGIN
  FOR v_metric IN SELECT * FROM calcular_metricas_diarias()
  LOOP
    INSERT INTO metricas_inventario (
      center_id,
      fecha,
      total_medicamentos,
      total_lotes,
      medicamentos_bajo_stock,
      lotes_proximos_vencer,
      lotes_vencidos,
      movimientos_entrada,
      movimientos_salida,
      cumplimiento_stock,
      metadata
    ) VALUES (
      v_metric.center_id,
      v_metric.fecha,
      (v_metric.metricas->>'total_medicamentos')::INTEGER,
      (v_metric.metricas->>'total_lotes')::INTEGER,
      (v_metric.metricas->>'medicamentos_bajo_stock')::INTEGER,
      (v_metric.metricas->>'lotes_proximos_vencer')::INTEGER,
      (v_metric.metricas->>'lotes_vencidos')::INTEGER,
      (v_metric.metricas->>'movimientos_entrada')::INTEGER,
      (v_metric.metricas->>'movimientos_salida')::INTEGER,
      (v_metric.metricas->>'cumplimiento_stock')::DECIMAL,
      v_metric.metricas
    )
    ON CONFLICT (center_id, fecha) DO UPDATE SET
      total_medicamentos = EXCLUDED.total_medicamentos,
      total_lotes = EXCLUDED.total_lotes,
      medicamentos_bajo_stock = EXCLUDED.medicamentos_bajo_stock,
      lotes_proximos_vencer = EXCLUDED.lotes_proximos_vencer,
      lotes_vencidos = EXCLUDED.lotes_vencidos,
      movimientos_entrada = EXCLUDED.movimientos_entrada,
      movimientos_salida = EXCLUDED.movimientos_salida,
      cumplimiento_stock = EXCLUDED.cumplimiento_stock,
      metadata = EXCLUDED.metadata,
      created_at = NOW();

    v_count := v_count + 1;
  END LOOP;

  RETURN QUERY SELECT v_count, format('Métricas guardadas para %s centros', v_count);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION guardar_metricas_diarias IS 'Guarda las métricas diarias en la tabla metricas_inventario';

-- Función: Dashboard de control de calidad
CREATE OR REPLACE FUNCTION dashboard_control_calidad(p_center_id UUID DEFAULT NULL)
RETURNS TABLE (
  seccion TEXT,
  total INTEGER,
  criticos INTEGER,
  altos INTEGER,
  medios INTEGER,
  bajos INTEGER,
  detalles JSONB
) AS $$
BEGIN
  RETURN QUERY
  -- Alertas por tipo
  SELECT
    'alertas_activas'::TEXT,
    COUNT(*)::INTEGER as total,
    COUNT(*) FILTER (WHERE severidad = 'critica')::INTEGER,
    COUNT(*) FILTER (WHERE severidad = 'alta')::INTEGER,
    COUNT(*) FILTER (WHERE severidad = 'media')::INTEGER,
    COUNT(*) FILTER (WHERE severidad = 'baja')::INTEGER,
    jsonb_agg(
      jsonb_build_object(
        'tipo', tipo_alerta,
        'count', count
      )
    ) as detalles
  FROM (
    SELECT tipo_alerta, COUNT(*) as count
    FROM alertas_medicamentos
    WHERE estado IN ('pendiente', 'en_revision')
      AND (p_center_id IS NULL OR center_id = p_center_id)
    GROUP BY tipo_alerta
  ) sub

  UNION ALL

  -- Stock bajo
  SELECT
    'stock_bajo'::TEXT,
    COUNT(*)::INTEGER,
    COUNT(*) FILTER (WHERE cantidad_actual <= (stock_minimo * 0.5))::INTEGER,
    COUNT(*) FILTER (WHERE cantidad_actual <= (stock_minimo * 0.75) AND cantidad_actual > (stock_minimo * 0.5))::INTEGER,
    COUNT(*) FILTER (WHERE cantidad_actual > (stock_minimo * 0.75))::INTEGER,
    0::INTEGER,
    jsonb_build_object('medicamentos', jsonb_agg(jsonb_build_object('id', id, 'nombre', nombre)))
  FROM (
    SELECT b.id, m.nombre, b.cantidad_actual, b.stock_minimo
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    WHERE b.cantidad_actual <= b.stock_minimo
      AND b.estado = 'disponible'
      AND (p_center_id IS NULL OR b.center_id = p_center_id)
    LIMIT 10
  ) sub

  UNION ALL

  -- Vencimientos
  SELECT
    'vencimientos'::TEXT,
    COUNT(*)::INTEGER,
    COUNT(*) FILTER (WHERE dias_restantes <= 30 OR dias_restantes < 0)::INTEGER,
    COUNT(*) FILTER (WHERE dias_restantes > 30 AND dias_restantes <= 60)::INTEGER,
    COUNT(*) FILTER (WHERE dias_restantes > 60 AND dias_restantes <= 90)::INTEGER,
    0::INTEGER,
    jsonb_build_object('lotes', jsonb_agg(jsonb_build_object('lote', numero_lote, 'dias', dias_restantes)))
  FROM (
    SELECT
      b.numero_lote,
      (b.fecha_caducidad - CURRENT_DATE)::INTEGER as dias_restantes
    FROM batches b
    WHERE b.fecha_caducidad <= (CURRENT_DATE + 90)
      AND b.cantidad_actual > 0
      AND (p_center_id IS NULL OR b.center_id = p_center_id)
    LIMIT 10
  ) sub;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dashboard_control_calidad IS 'Proporciona datos para el dashboard de control de calidad';

COMMIT;

-- ============================================
-- PARTE 3.6: TRIGGER AUTOMÁTICO DE ALERTAS
-- ============================================

-- Trigger: Generar alerta automática al actualizar lote
CREATE OR REPLACE FUNCTION trigger_generar_alertas_batch()
RETURNS TRIGGER AS $$
BEGIN
  -- Alerta de stock bajo
  IF NEW.cantidad_actual <= NEW.stock_minimo AND NEW.estado = 'disponible' THEN
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    )
    SELECT
      'stock_bajo',
      CASE
        WHEN NEW.cantidad_actual <= (NEW.stock_minimo * 0.5) THEN 'alta'
        ELSE 'media'
      END,
      NEW.medication_id,
      NEW.id,
      NEW.center_id,
      'Stock Bajo Detectado',
      format('Lote %s - Stock: %s (Mínimo: %s)', NEW.numero_lote, NEW.cantidad_actual, NEW.stock_minimo),
      jsonb_build_object('cantidad', NEW.cantidad_actual, 'minimo', NEW.stock_minimo)
    WHERE NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos
      WHERE batch_id = NEW.id
        AND tipo_alerta = 'stock_bajo'
        AND estado IN ('pendiente', 'en_revision')
        AND created_at > NOW() - INTERVAL '24 hours'
    );
  END IF;

  -- Alerta de vencimiento próximo
  IF NEW.fecha_caducidad <= (CURRENT_DATE + 90) AND NEW.cantidad_actual > 0 THEN
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    )
    SELECT
      'proximo_vencer',
      CASE
        WHEN NEW.fecha_caducidad <= (CURRENT_DATE + 30) THEN 'critica'
        WHEN NEW.fecha_caducidad <= (CURRENT_DATE + 60) THEN 'alta'
        ELSE 'media'
      END,
      NEW.medication_id,
      NEW.id,
      NEW.center_id,
      'Lote Próximo a Vencer',
      format('Lote %s vence el %s', NEW.numero_lote, NEW.fecha_caducidad),
      jsonb_build_object('fecha_caducidad', NEW.fecha_caducidad, 'dias_restantes', (NEW.fecha_caducidad - CURRENT_DATE))
    WHERE NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos
      WHERE batch_id = NEW.id
        AND tipo_alerta = 'proximo_vencer'
        AND estado IN ('pendiente', 'en_revision')
        AND created_at > NOW() - INTERVAL '7 days'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_generar_alertas_batch ON batches;
CREATE TRIGGER trg_generar_alertas_batch
  AFTER INSERT OR UPDATE ON batches
  FOR EACH ROW
  EXECUTE FUNCTION trigger_generar_alertas_batch();

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 3 COMPLETADA' as resultado;

SELECT 'TABLAS DE CALIDAD' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('alertas_medicamentos', 'notificaciones', 'metricas_inventario')
ORDER BY table_name;

SELECT 'FUNCIONES DE CALIDAD' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'generar_alertas_stock_bajo',
    'generar_alertas_vencimiento',
    'calcular_metricas_diarias',
    'guardar_metricas_diarias',
    'dashboard_control_calidad'
  )
ORDER BY routine_name;
