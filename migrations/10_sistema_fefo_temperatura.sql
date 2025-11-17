-- ============================================
-- MIGRACIÓN 10: SISTEMA FEFO Y MONITOREO DE TEMPERATURA
-- ============================================
-- Descripción: Implementa algoritmo FEFO y monitoreo de temperatura
-- Fecha: 2025-11-17
-- Autor: Sistema Automático

-- ============================================
-- 1. TABLA: monitoreo_temperatura
-- ============================================

CREATE TABLE IF NOT EXISTS public.monitoreo_temperatura (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  centro_id UUID NOT NULL REFERENCES public.health_centers(id) ON DELETE CASCADE,
  ubicacion_id UUID REFERENCES public.ubicaciones_almacen(id) ON DELETE SET NULL,
  temperatura DECIMAL(5,2) NOT NULL,
  humedad DECIMAL(5,2),
  sensor_id TEXT,
  fuera_rango BOOLEAN DEFAULT false,
  alerta_generada BOOLEAN DEFAULT false,
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.monitoreo_temperatura IS 'Registro continuo de temperatura y humedad en almacén';
COMMENT ON COLUMN public.monitoreo_temperatura.temperatura IS 'Temperatura registrada en °C';
COMMENT ON COLUMN public.monitoreo_temperatura.humedad IS 'Humedad relativa en %';
COMMENT ON COLUMN public.monitoreo_temperatura.sensor_id IS 'ID del sensor IoT que registró la medición';
COMMENT ON COLUMN public.monitoreo_temperatura.fuera_rango IS 'Indica si la temperatura está fuera del rango permitido';

-- ============================================
-- 2. TABLA: excursiones_termicas
-- ============================================

CREATE TABLE IF NOT EXISTS public.excursiones_termicas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ubicacion_id UUID NOT NULL REFERENCES public.ubicaciones_almacen(id) ON DELETE CASCADE,
  temperatura_registrada DECIMAL(5,2) NOT NULL,
  temperatura_min_permitida DECIMAL(5,2),
  temperatura_max_permitida DECIMAL(5,2),
  duracion_minutos INTEGER, -- Duración de la excursión en minutos
  inicio TIMESTAMP WITH TIME ZONE NOT NULL,
  fin TIMESTAMP WITH TIME ZONE,
  severidad TEXT CHECK (severidad IN ('leve', 'moderada', 'severa', 'crítica')) DEFAULT 'leve',
  accion_correctiva TEXT,
  responsable_id UUID REFERENCES public.users_profiles(id),
  resuelta BOOLEAN DEFAULT false,
  afecta_medicamentos BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.excursiones_termicas IS 'Registro de excursiones térmicas (temperatura fuera de rango)';
COMMENT ON COLUMN public.excursiones_termicas.duracion_minutos IS 'Duración total de la excursión';
COMMENT ON COLUMN public.excursiones_termicas.severidad IS 'Nivel de severidad de la excursión';
COMMENT ON COLUMN public.excursiones_termicas.afecta_medicamentos IS 'Indica si la excursión afecta la calidad de medicamentos';

-- ============================================
-- 3. ÍNDICES
-- ============================================

CREATE INDEX idx_monitoreo_temp_centro ON public.monitoreo_temperatura(centro_id);
CREATE INDEX idx_monitoreo_temp_ubicacion ON public.monitoreo_temperatura(ubicacion_id);
CREATE INDEX idx_monitoreo_temp_created ON public.monitoreo_temperatura(created_at DESC);
CREATE INDEX idx_monitoreo_temp_fuera_rango ON public.monitoreo_temperatura(fuera_rango) WHERE fuera_rango = true;

CREATE INDEX idx_excursiones_ubicacion ON public.excursiones_termicas(ubicacion_id);
CREATE INDEX idx_excursiones_no_resueltas ON public.excursiones_termicas(resuelta) WHERE resuelta = false;
CREATE INDEX idx_excursiones_severidad ON public.excursiones_termicas(severidad);

CREATE INDEX idx_batches_fecha_caducidad ON public.batches(fecha_caducidad ASC) WHERE estado = 'disponible';

-- ============================================
-- 4. FUNCIÓN: ALGORITMO FEFO (First Expired, First Out)
-- ============================================

CREATE OR REPLACE FUNCTION suggest_fefo_batches(
  p_medication_id UUID,
  p_cantidad_requerida INTEGER,
  p_center_id UUID
)
RETURNS TABLE (
  batch_id UUID,
  numero_lote TEXT,
  cantidad_disponible INTEGER,
  cantidad_sugerida INTEGER,
  fecha_caducidad DATE,
  dias_hasta_vencimiento INTEGER,
  ubicacion_codigo TEXT,
  prioridad INTEGER
) AS $$
DECLARE
  v_cantidad_restante INTEGER := p_cantidad_requerida;
  v_cantidad_a_tomar INTEGER;
BEGIN
  -- Retornar lotes ordenados por fecha de caducidad (FEFO)
  -- Prioridad: 1 = más próximo a vencer, debe usarse primero
  RETURN QUERY
  WITH lotes_ordenados AS (
    SELECT
      b.id AS batch_id,
      b.numero_lote,
      b.cantidad_actual AS cantidad_disponible,
      b.fecha_caducidad,
      EXTRACT(DAY FROM (b.fecha_caducidad - CURRENT_DATE))::INTEGER AS dias_hasta_vencimiento,
      COALESCE(lu.ubicacion_id, NULL) AS ubicacion_id,
      ROW_NUMBER() OVER (ORDER BY b.fecha_caducidad ASC, b.created_at ASC) AS prioridad
    FROM public.batches b
    LEFT JOIN public.lotes_ubicaciones lu ON b.id = lu.batch_id
    WHERE b.medication_id = p_medication_id
      AND b.center_id = p_center_id
      AND b.estado = 'disponible'
      AND b.cantidad_actual > 0
      AND b.fecha_caducidad > CURRENT_DATE
    ORDER BY b.fecha_caducidad ASC, b.created_at ASC
  )
  SELECT
    lo.batch_id,
    lo.numero_lote,
    lo.cantidad_disponible,
    CASE
      WHEN v_cantidad_restante > lo.cantidad_disponible THEN lo.cantidad_disponible
      ELSE v_cantidad_restante
    END AS cantidad_sugerida,
    lo.fecha_caducidad,
    lo.dias_hasta_vencimiento,
    COALESCE(ua.codigo, 'Sin ubicación') AS ubicacion_codigo,
    lo.prioridad::INTEGER
  FROM lotes_ordenados lo
  LEFT JOIN public.ubicaciones_almacen ua ON lo.ubicacion_id = ua.id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION suggest_fefo_batches IS 'Sugiere lotes a despachar siguiendo el algoritmo FEFO (First Expired, First Out)';

-- ============================================
-- 5. FUNCIÓN: VALIDAR EXCURSIÓN TÉRMICA
-- ============================================

CREATE OR REPLACE FUNCTION validate_temperature_excursion(
  p_ubicacion_id UUID,
  p_temperatura DECIMAL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_temp_min DECIMAL;
  v_temp_max DECIMAL;
  v_fuera_rango BOOLEAN := false;
BEGIN
  -- Obtener rangos de temperatura permitidos para la ubicación
  SELECT temperatura_min, temperatura_max
  INTO v_temp_min, v_temp_max
  FROM public.ubicaciones_almacen
  WHERE id = p_ubicacion_id;

  -- Verificar si está fuera de rango
  IF v_temp_min IS NOT NULL AND p_temperatura < v_temp_min THEN
    v_fuera_rango := true;
  END IF;

  IF v_temp_max IS NOT NULL AND p_temperatura > v_temp_max THEN
    v_fuera_rango := true;
  END IF;

  -- Si está fuera de rango, registrar excursión térmica
  IF v_fuera_rango THEN
    INSERT INTO public.excursiones_termicas (
      ubicacion_id,
      temperatura_registrada,
      temperatura_min_permitida,
      temperatura_max_permitida,
      inicio,
      severidad
    ) VALUES (
      p_ubicacion_id,
      p_temperatura,
      v_temp_min,
      v_temp_max,
      NOW(),
      CASE
        WHEN ABS(p_temperatura - COALESCE(v_temp_max, v_temp_min)) > 10 THEN 'crítica'
        WHEN ABS(p_temperatura - COALESCE(v_temp_max, v_temp_min)) > 5 THEN 'severa'
        WHEN ABS(p_temperatura - COALESCE(v_temp_max, v_temp_min)) > 2 THEN 'moderada'
        ELSE 'leve'
      END
    );
  END IF;

  RETURN v_fuera_rango;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validate_temperature_excursion IS 'Valida si una temperatura está fuera del rango permitido y registra excursión';

-- ============================================
-- 6. FUNCIÓN: REGISTRAR TEMPERATURA
-- ============================================

CREATE OR REPLACE FUNCTION registrar_temperatura(
  p_centro_id UUID,
  p_ubicacion_id UUID,
  p_temperatura DECIMAL,
  p_humedad DECIMAL DEFAULT NULL,
  p_sensor_id TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_registro_id UUID;
  v_fuera_rango BOOLEAN;
BEGIN
  -- Validar si está fuera de rango
  v_fuera_rango := validate_temperature_excursion(p_ubicacion_id, p_temperatura);

  -- Insertar registro
  INSERT INTO public.monitoreo_temperatura (
    centro_id,
    ubicacion_id,
    temperatura,
    humedad,
    sensor_id,
    fuera_rango,
    alerta_generada
  ) VALUES (
    p_centro_id,
    p_ubicacion_id,
    p_temperatura,
    p_humedad,
    p_sensor_id,
    v_fuera_rango,
    v_fuera_rango -- Si está fuera de rango, generar alerta
  )
  RETURNING id INTO v_registro_id;

  RETURN v_registro_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_temperatura IS 'Registra una medición de temperatura y valida excursiones';

-- ============================================
-- 7. FUNCIÓN: OBTENER HISTORIAL DE TEMPERATURA
-- ============================================

CREATE OR REPLACE FUNCTION get_temperature_history(
  p_ubicacion_id UUID,
  p_horas INTEGER DEFAULT 24
)
RETURNS TABLE (
  timestamp TIMESTAMP WITH TIME ZONE,
  temperatura DECIMAL,
  humedad DECIMAL,
  fuera_rango BOOLEAN,
  sensor_id TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    mt.created_at AS timestamp,
    mt.temperatura,
    mt.humedad,
    mt.fuera_rango,
    mt.sensor_id
  FROM public.monitoreo_temperatura mt
  WHERE mt.ubicacion_id = p_ubicacion_id
    AND mt.created_at >= NOW() - INTERVAL '1 hour' * p_horas
  ORDER BY mt.created_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_temperature_history IS 'Obtiene el historial de temperatura de una ubicación';

-- ============================================
-- 8. FUNCIÓN: MEDICAMENTOS AFECTADOS POR EXCURSIÓN
-- ============================================

CREATE OR REPLACE FUNCTION get_medicamentos_afectados_excursion(
  p_excursion_id UUID
)
RETURNS TABLE (
  batch_id UUID,
  medicamento_nombre TEXT,
  numero_lote TEXT,
  cantidad INTEGER,
  requiere_evaluacion BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id AS batch_id,
    m.nombre AS medicamento_nombre,
    b.numero_lote,
    lu.cantidad,
    true AS requiere_evaluacion
  FROM public.excursiones_termicas et
  JOIN public.lotes_ubicaciones lu ON lu.ubicacion_id = et.ubicacion_id
  JOIN public.batches b ON lu.batch_id = b.id
  LEFT JOIN public.medications m ON b.medication_id = m.id
  WHERE et.id = p_excursion_id
    AND et.afecta_medicamentos = true;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_medicamentos_afectados_excursion IS 'Obtiene los medicamentos afectados por una excursión térmica';

-- ============================================
-- 9. TRIGGER: ALERTA AUTOMÁTICA POR TEMPERATURA
-- ============================================

CREATE OR REPLACE FUNCTION trigger_alerta_temperatura()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fuera_rango = true AND NEW.alerta_generada = false THEN
    -- Aquí se podría insertar en tabla de alertas o enviar notificación
    -- Por ahora solo marcamos como alerta generada
    NEW.alerta_generada = true;

    -- Log para debugging
    RAISE NOTICE 'ALERTA: Temperatura fuera de rango en ubicación % - Temperatura: %°C',
      NEW.ubicacion_id, NEW.temperatura;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_alerta_temperatura_fuera_rango
  BEFORE INSERT ON public.monitoreo_temperatura
  FOR EACH ROW
  WHEN (NEW.fuera_rango = true)
  EXECUTE FUNCTION trigger_alerta_temperatura();

-- ============================================
-- 10. ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.monitoreo_temperatura ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.excursiones_termicas ENABLE ROW LEVEL SECURITY;

-- Políticas para monitoreo_temperatura
CREATE POLICY "Usuarios pueden ver temperatura de su centro"
  ON public.monitoreo_temperatura FOR SELECT
  USING (
    centro_id IN (
      SELECT center_id FROM public.users_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Sistema puede insertar registros de temperatura"
  ON public.monitoreo_temperatura FOR INSERT
  WITH CHECK (true); -- API key validation should be done at application level

-- Políticas para excursiones_termicas
CREATE POLICY "Usuarios pueden ver excursiones de su centro"
  ON public.excursiones_termicas FOR SELECT
  USING (
    ubicacion_id IN (
      SELECT id FROM public.ubicaciones_almacen
      WHERE centro_id IN (
        SELECT center_id FROM public.users_profiles WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "Admin puede gestionar excursiones"
  ON public.excursiones_termicas FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

-- ============================================
-- 11. VISTA: RESUMEN DE TEMPERATURA POR UBICACIÓN
-- ============================================

CREATE OR REPLACE VIEW public.v_temperatura_ubicaciones AS
SELECT
  ua.id AS ubicacion_id,
  ua.codigo,
  ua.nombre AS ubicacion_nombre,
  ua.tipo,
  ua.temperatura_min,
  ua.temperatura_max,
  hc.name AS centro_nombre,
  (
    SELECT mt.temperatura
    FROM public.monitoreo_temperatura mt
    WHERE mt.ubicacion_id = ua.id
    ORDER BY mt.created_at DESC
    LIMIT 1
  ) AS temperatura_actual,
  (
    SELECT mt.created_at
    FROM public.monitoreo_temperatura mt
    WHERE mt.ubicacion_id = ua.id
    ORDER BY mt.created_at DESC
    LIMIT 1
  ) AS ultima_lectura,
  (
    SELECT COUNT(*)
    FROM public.excursiones_termicas et
    WHERE et.ubicacion_id = ua.id
      AND et.resuelta = false
  ) AS excursiones_pendientes
FROM public.ubicaciones_almacen ua
JOIN public.health_centers hc ON ua.centro_id = hc.id
WHERE ua.is_active = true;

COMMENT ON VIEW public.v_temperatura_ubicaciones IS 'Vista resumen de temperatura por ubicación';

-- ============================================
-- 12. DATOS DE EJEMPLO (OPCIONAL)
-- ============================================

-- Insertar registros de temperatura de ejemplo
DO $$
DECLARE
  v_ubicacion_id UUID;
BEGIN
  -- Obtener una ubicación refrigerada
  SELECT id INTO v_ubicacion_id
  FROM public.ubicaciones_almacen
  WHERE tipo = 'refrigerado'
  LIMIT 1;

  IF v_ubicacion_id IS NOT NULL THEN
    -- Insertar registros de temperatura simulados (últimas 24 horas)
    INSERT INTO public.monitoreo_temperatura (centro_id, ubicacion_id, temperatura, humedad, sensor_id, created_at)
    SELECT
      (SELECT centro_id FROM public.ubicaciones_almacen WHERE id = v_ubicacion_id),
      v_ubicacion_id,
      4.5 + (random() * 2), -- Temperatura entre 4.5°C y 6.5°C
      65 + (random() * 10), -- Humedad entre 65% y 75%
      'SENSOR-001',
      NOW() - INTERVAL '1 hour' * generate_series
    FROM generate_series(0, 23)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Registros de temperatura de ejemplo creados para ubicación: %', v_ubicacion_id;
  END IF;
END $$;

-- ============================================
-- FIN DE MIGRACIÓN 10
-- ============================================

-- Verificar creación
SELECT 'Migración 10 completada. Funciones FEFO y monitoreo de temperatura implementadas.' AS mensaje;
SELECT routine_name, routine_type FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_name IN ('suggest_fefo_batches', 'registrar_temperatura');
