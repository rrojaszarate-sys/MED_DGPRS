-- ============================================
-- MIGRACIÓN 17: ADVANCED ANALYTICS DASHBOARD
-- ============================================
-- Descripción: Sistema de analytics avanzado con KPIs, métricas y dashboards
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Características: KPIs en tiempo real, tendencias, predicciones, reportes ejecutivos

-- ============================================
-- 1. TABLA: KPI DEFINITIONS
-- ============================================

CREATE TABLE IF NOT EXISTS public.kpi_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identificación
  kpi_code TEXT UNIQUE NOT NULL, -- Código único (ej: 'INVENTORY_TURNOVER')
  kpi_name TEXT NOT NULL,
  description TEXT,

  -- Categoría
  category TEXT CHECK (category IN (
    'inventory', 'financial', 'operational', 'quality',
    'compliance', 'efficiency', 'safety'
  )) NOT NULL,

  -- Cálculo
  calculation_method TEXT CHECK (calculation_method IN (
    'sql_query', -- Query SQL directo
    'function', -- Función PL/pgSQL
    'formula', -- Fórmula matemática
    'aggregation' -- Agregación simple
  )) NOT NULL,

  calculation_config JSONB NOT NULL, -- {
  --   "sql": "SELECT COUNT(*) FROM batches WHERE...",
  --   "function": "calculate_inventory_turnover",
  --   "formula": "(sales / avg_inventory) * 365"
  -- }

  -- Formato y visualización
  data_type TEXT CHECK (data_type IN ('number', 'percentage', 'currency', 'ratio', 'days')) DEFAULT 'number',
  decimal_places INTEGER DEFAULT 2,
  prefix TEXT, -- Ej: "$", "#"
  suffix TEXT, -- Ej: "%", "días", "unidades"

  -- Rangos de interpretación
  target_value DECIMAL(15, 4), -- Valor objetivo
  warning_threshold DECIMAL(15, 4), -- Umbral de advertencia
  critical_threshold DECIMAL(15, 4), -- Umbral crítico
  is_higher_better BOOLEAN DEFAULT true, -- ¿Mayor valor es mejor?

  -- Frecuencia de actualización
  refresh_frequency TEXT CHECK (refresh_frequency IN (
    'realtime', 'hourly', 'daily', 'weekly', 'monthly'
  )) DEFAULT 'daily',

  -- Estado
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_kpi_definitions_code ON public.kpi_definitions(kpi_code);
CREATE INDEX idx_kpi_definitions_category ON public.kpi_definitions(category);
CREATE INDEX idx_kpi_definitions_active ON public.kpi_definitions(is_active) WHERE is_active = true;

COMMENT ON TABLE public.kpi_definitions IS 'Definiciones de KPIs (Key Performance Indicators)';

-- ============================================
-- 2. TABLA: KPI SNAPSHOTS
-- ============================================

CREATE TABLE IF NOT EXISTS public.kpi_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  kpi_definition_id UUID REFERENCES public.kpi_definitions(id) ON DELETE CASCADE,
  kpi_code TEXT NOT NULL,

  -- Período
  snapshot_date DATE NOT NULL,
  snapshot_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  period_type TEXT CHECK (period_type IN ('hour', 'day', 'week', 'month', 'quarter', 'year')) DEFAULT 'day',

  -- Filtros aplicados
  centro_id UUID REFERENCES public.centros_salud(id),
  filters JSONB, -- Filtros adicionales aplicados

  -- Valores
  value DECIMAL(15, 4) NOT NULL,
  previous_value DECIMAL(15, 4), -- Valor del período anterior
  change_value DECIMAL(15, 4), -- Cambio absoluto
  change_percentage DECIMAL(10, 2), -- Cambio porcentual

  -- Status según umbrales
  status TEXT CHECK (status IN ('excellent', 'good', 'warning', 'critical')) DEFAULT 'good',

  -- Metadatos
  calculation_time_ms INTEGER, -- Tiempo que tardó el cálculo
  data_points_count INTEGER, -- Número de datos usados
  metadata JSONB,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(kpi_definition_id, snapshot_date, centro_id, period_type)
);

CREATE INDEX idx_kpi_snapshots_kpi ON public.kpi_snapshots(kpi_definition_id);
CREATE INDEX idx_kpi_snapshots_date ON public.kpi_snapshots(snapshot_date DESC);
CREATE INDEX idx_kpi_snapshots_centro ON public.kpi_snapshots(centro_id);
CREATE INDEX idx_kpi_snapshots_code_date ON public.kpi_snapshots(kpi_code, snapshot_date DESC);

COMMENT ON TABLE public.kpi_snapshots IS 'Snapshots históricos de KPIs para tendencias y análisis temporal';

-- ============================================
-- 3. TABLA: DASHBOARD WIDGETS
-- ============================================

CREATE TABLE IF NOT EXISTS public.dashboard_widgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identificación
  widget_code TEXT UNIQUE NOT NULL,
  widget_name TEXT NOT NULL,
  description TEXT,

  -- Tipo de widget
  widget_type TEXT CHECK (widget_type IN (
    'kpi_card', -- Tarjeta con número grande
    'chart_line', -- Gráfico de línea
    'chart_bar', -- Gráfico de barras
    'chart_pie', -- Gráfico circular
    'table', -- Tabla de datos
    'map', -- Mapa
    'gauge', -- Indicador tipo gauge
    'sparkline', -- Mini gráfico
    'list' -- Lista
  )) NOT NULL,

  -- Configuración
  kpi_definition_id UUID REFERENCES public.kpi_definitions(id),
  data_source_config JSONB NOT NULL, -- {
  --   "query": "SELECT...",
  --   "kpi_codes": ["INVENTORY_TURNOVER", "STOCK_VALUE"],
  --   "time_range": "last_30_days"
  -- }

  -- Visualización
  chart_config JSONB, -- Configuración específica del gráfico (colores, ejes, etc.)
  display_options JSONB, -- {size, position, refresh_rate, etc.}

  -- Permisos
  required_role TEXT[], -- Roles que pueden ver este widget
  centro_specific BOOLEAN DEFAULT false, -- ¿Es específico por centro?

  -- Estado
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_dashboard_widgets_code ON public.dashboard_widgets(widget_code);
CREATE INDEX idx_dashboard_widgets_type ON public.dashboard_widgets(widget_type);
CREATE INDEX idx_dashboard_widgets_active ON public.dashboard_widgets(is_active) WHERE is_active = true;

COMMENT ON TABLE public.dashboard_widgets IS 'Configuración de widgets para dashboards personalizables';

-- ============================================
-- 4. TABLA: USER DASHBOARDS
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_dashboards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID REFERENCES public.users_profiles(id) ON DELETE CASCADE,

  -- Dashboard
  dashboard_name TEXT NOT NULL,
  is_default BOOLEAN DEFAULT false,

  -- Layout
  layout_config JSONB NOT NULL, -- {
  --   "widgets": [
  --     {"widget_id": "uuid", "position": {"x": 0, "y": 0, "w": 6, "h": 4}},
  --     ...
  --   ]
  -- }

  -- Widgets incluidos
  widget_ids UUID[], -- Array de IDs de widgets

  -- Estado
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_dashboards_user ON public.user_dashboards(user_id);
CREATE INDEX idx_user_dashboards_default ON public.user_dashboards(user_id, is_default) WHERE is_default = true;

COMMENT ON TABLE public.user_dashboards IS 'Dashboards personalizados por usuario';

-- ============================================
-- 5. TABLA: ANALYTICS EVENTS
-- ============================================

CREATE TABLE IF NOT EXISTS public.analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Evento
  event_type TEXT NOT NULL, -- 'page_view', 'action', 'error', 'export', etc.
  event_category TEXT,
  event_name TEXT NOT NULL,
  event_label TEXT,

  -- Usuario
  user_id UUID REFERENCES public.users_profiles(id),
  user_role TEXT,
  centro_id UUID REFERENCES public.centros_salud(id),

  -- Contexto
  page_url TEXT,
  page_title TEXT,
  referrer TEXT,

  -- Datos del evento
  event_data JSONB,
  event_value DECIMAL(15, 4), -- Valor numérico si aplica

  -- Sesión
  session_id UUID,
  session_duration_seconds INTEGER,

  -- Dispositivo
  device_type TEXT, -- 'desktop', 'mobile', 'tablet'
  browser TEXT,
  os TEXT,
  ip_address INET,

  -- Timestamp
  event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analytics_events_type ON public.analytics_events(event_type);
CREATE INDEX idx_analytics_events_user ON public.analytics_events(user_id);
CREATE INDEX idx_analytics_events_timestamp ON public.analytics_events(event_timestamp DESC);
CREATE INDEX idx_analytics_events_centro ON public.analytics_events(centro_id);
CREATE INDEX idx_analytics_events_session ON public.analytics_events(session_id);

COMMENT ON TABLE public.analytics_events IS 'Eventos de analytics para entender uso del sistema';

-- ============================================
-- 6. FUNCIÓN: CALCULAR INVENTORY TURNOVER
-- ============================================

CREATE OR REPLACE FUNCTION calculate_inventory_turnover(
  p_centro_id UUID DEFAULT NULL,
  p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '365 days',
  p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS DECIMAL AS $$
DECLARE
  v_total_dispensed DECIMAL;
  v_avg_inventory DECIMAL;
  v_turnover DECIMAL;
BEGIN
  -- Total dispensado en el período
  SELECT COALESCE(SUM(cantidad), 0)
  INTO v_total_dispensed
  FROM public.dispensaciones d
  WHERE d.fecha_dispensacion BETWEEN p_start_date AND p_end_date
  AND (p_centro_id IS NULL OR d.centro_id = p_centro_id);

  -- Inventario promedio
  SELECT COALESCE(AVG(total_stock), 1)
  INTO v_avg_inventory
  FROM (
    SELECT DATE(created_at) AS stock_date, SUM(cantidad_actual) AS total_stock
    FROM public.batches
    WHERE created_at BETWEEN p_start_date AND p_end_date
    AND (p_centro_id IS NULL OR centro_id = p_centro_id)
    GROUP BY DATE(created_at)
  ) daily_stock;

  -- Calcular turnover anualizado
  v_turnover := CASE
    WHEN v_avg_inventory > 0 THEN
      (v_total_dispensed / v_avg_inventory) * (365.0 / EXTRACT(DAYS FROM p_end_date - p_start_date))
    ELSE 0
  END;

  RETURN ROUND(v_turnover, 2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_inventory_turnover IS 'Calcula inventory turnover (rotación de inventario) anualizado';

-- ============================================
-- 7. FUNCIÓN: CALCULAR STOCK VALUE
-- ============================================

CREATE OR REPLACE FUNCTION calculate_stock_value(
  p_centro_id UUID DEFAULT NULL,
  p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS DECIMAL AS $$
DECLARE
  v_total_value DECIMAL;
BEGIN
  SELECT COALESCE(SUM(b.cantidad_actual * b.precio_unitario), 0)
  INTO v_total_value
  FROM public.batches b
  WHERE b.cantidad_actual > 0
  AND b.is_active = true
  AND (p_centro_id IS NULL OR b.centro_id = p_centro_id);

  RETURN ROUND(v_total_value, 2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_stock_value IS 'Calcula el valor total del inventario';

-- ============================================
-- 8. FUNCIÓN: CALCULAR EXPIRING SOON
-- ============================================

CREATE OR REPLACE FUNCTION calculate_expiring_soon(
  p_centro_id UUID DEFAULT NULL,
  p_days_threshold INTEGER DEFAULT 30
)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(DISTINCT b.id)
  INTO v_count
  FROM public.batches b
  WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + (p_days_threshold || ' days')::INTERVAL
  AND b.cantidad_actual > 0
  AND b.is_active = true
  AND (p_centro_id IS NULL OR b.centro_id = p_centro_id);

  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_expiring_soon IS 'Cuenta lotes que vencen pronto';

-- ============================================
-- 9. FUNCIÓN: CALCULAR STOCKOUT RATE
-- ============================================

CREATE OR REPLACE FUNCTION calculate_stockout_rate(
  p_centro_id UUID DEFAULT NULL,
  p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
  p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS DECIMAL AS $$
DECLARE
  v_total_medications INTEGER;
  v_medications_out_of_stock INTEGER;
  v_stockout_rate DECIMAL;
BEGIN
  -- Total de medicamentos activos
  SELECT COUNT(DISTINCT id)
  INTO v_total_medications
  FROM public.medication_catalog
  WHERE is_active = true;

  -- Medicamentos sin stock en el período
  SELECT COUNT(DISTINCT m.id)
  INTO v_medications_out_of_stock
  FROM public.medication_catalog m
  WHERE m.is_active = true
  AND NOT EXISTS (
    SELECT 1 FROM public.batches b
    WHERE b.medication_catalog_id = m.id
    AND b.cantidad_actual > 0
    AND b.is_active = true
    AND (p_centro_id IS NULL OR b.centro_id = p_centro_id)
  );

  v_stockout_rate := CASE
    WHEN v_total_medications > 0 THEN
      (v_medications_out_of_stock::DECIMAL / v_total_medications) * 100
    ELSE 0
  END;

  RETURN ROUND(v_stockout_rate, 2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_stockout_rate IS 'Calcula el porcentaje de medicamentos sin stock (stockout rate)';

-- ============================================
-- 10. FUNCIÓN: SNAPSHOT KPIs DIARIOS
-- ============================================

CREATE OR REPLACE FUNCTION snapshot_daily_kpis()
RETURNS void AS $$
DECLARE
  v_centro record;
  v_kpi record;
  v_value DECIMAL;
BEGIN
  -- Iterar por cada centro
  FOR v_centro IN SELECT id FROM public.centros_salud WHERE is_active = true
  LOOP
    -- Iterar por cada KPI activo
    FOR v_kpi IN
      SELECT * FROM public.kpi_definitions
      WHERE is_active = true
      AND refresh_frequency IN ('daily', 'realtime')
    LOOP
      -- Calcular valor según método
      CASE v_kpi.calculation_method
        WHEN 'function' THEN
          CASE v_kpi.kpi_code
            WHEN 'INVENTORY_TURNOVER' THEN
              v_value := calculate_inventory_turnover(v_centro.id);
            WHEN 'STOCK_VALUE' THEN
              v_value := calculate_stock_value(v_centro.id);
            WHEN 'EXPIRING_SOON_30' THEN
              v_value := calculate_expiring_soon(v_centro.id, 30);
            WHEN 'STOCKOUT_RATE' THEN
              v_value := calculate_stockout_rate(v_centro.id);
            ELSE
              CONTINUE;
          END CASE;
        ELSE
          CONTINUE;
      END CASE;

      -- Insertar snapshot
      INSERT INTO public.kpi_snapshots (
        kpi_definition_id,
        kpi_code,
        snapshot_date,
        period_type,
        centro_id,
        value
      ) VALUES (
        v_kpi.id,
        v_kpi.kpi_code,
        CURRENT_DATE,
        'day',
        v_centro.id,
        v_value
      )
      ON CONFLICT (kpi_definition_id, snapshot_date, centro_id, period_type)
      DO UPDATE SET value = v_value;
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION snapshot_daily_kpis IS 'Ejecutar diariamente para capturar snapshots de todos los KPIs';

-- ============================================
-- 11. TRIGGER: ACTUALIZAR UPDATED_AT
-- ============================================

CREATE TRIGGER trigger_update_kpi_definitions_updated_at
  BEFORE UPDATE ON public.kpi_definitions
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_dashboard_widgets_updated_at
  BEFORE UPDATE ON public.dashboard_widgets
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_user_dashboards_updated_at
  BEFORE UPDATE ON public.user_dashboards
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- ============================================
-- 12. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.kpi_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kpi_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_widgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_dashboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

-- KPI definitions - todos pueden ver
CREATE POLICY "Usuarios pueden ver KPI definitions"
  ON public.kpi_definitions FOR SELECT
  USING (is_active = true);

-- KPI snapshots - usuarios ven de su centro
CREATE POLICY "Usuarios ven KPI snapshots de su centro"
  ON public.kpi_snapshots FOR SELECT
  USING (
    centro_id IN (
      SELECT centro_id FROM public.users_profiles WHERE id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- Dashboards - usuarios ven los suyos
CREATE POLICY "Usuarios ven sus dashboards"
  ON public.user_dashboards FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Usuarios modifican sus dashboards"
  ON public.user_dashboards FOR ALL
  USING (user_id = auth.uid());

-- Analytics events - solo admin puede ver
CREATE POLICY "Admin puede ver analytics events"
  ON public.analytics_events FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Sistema puede crear analytics events"
  ON public.analytics_events FOR INSERT
  WITH CHECK (true);

-- ============================================
-- 13. VISTAS: DASHBOARDS
-- ============================================

-- Vista: KPIs actuales por centro
CREATE OR REPLACE VIEW v_current_kpis AS
SELECT DISTINCT ON (ks.kpi_code, ks.centro_id)
  ks.kpi_code,
  kd.kpi_name,
  kd.category,
  ks.centro_id,
  c.name AS centro_name,
  ks.value,
  ks.status,
  ks.snapshot_date,
  kd.data_type,
  kd.prefix,
  kd.suffix,
  kd.target_value
FROM public.kpi_snapshots ks
JOIN public.kpi_definitions kd ON ks.kpi_definition_id = kd.id
LEFT JOIN public.centros_salud c ON ks.centro_id = c.id
WHERE kd.is_active = true
ORDER BY ks.kpi_code, ks.centro_id, ks.snapshot_date DESC;

COMMENT ON VIEW v_current_kpis IS 'Vista de KPIs más recientes por centro';

-- Vista: Top medicamentos por valor
CREATE OR REPLACE VIEW v_top_medications_by_value AS
SELECT
  m.id,
  m.nombre AS medication_name,
  m.codigo_atc,
  SUM(b.cantidad_actual) AS total_quantity,
  SUM(b.cantidad_actual * b.precio_unitario) AS total_value,
  COUNT(DISTINCT b.id) AS batch_count
FROM public.medication_catalog m
JOIN public.batches b ON m.id = b.medication_catalog_id
WHERE b.cantidad_actual > 0
AND b.is_active = true
GROUP BY m.id, m.nombre, m.codigo_atc
ORDER BY total_value DESC
LIMIT 20;

COMMENT ON VIEW v_top_medications_by_value IS 'Top 20 medicamentos por valor de inventario';

-- Vista: Métricas de movimientos
CREATE OR REPLACE VIEW v_movement_metrics AS
SELECT
  DATE(d.fecha_dispensacion) AS movement_date,
  d.centro_id,
  c.name AS centro_name,
  COUNT(*) AS total_transactions,
  SUM(d.cantidad) AS total_quantity,
  COUNT(DISTINCT d.medication_catalog_id) AS unique_medications,
  COUNT(DISTINCT d.usuario_id) AS unique_users
FROM public.dispensaciones d
LEFT JOIN public.centros_salud c ON d.centro_id = c.id
WHERE d.fecha_dispensacion >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(d.fecha_dispensacion), d.centro_id, c.name
ORDER BY movement_date DESC;

COMMENT ON VIEW v_movement_metrics IS 'Métricas de movimientos de los últimos 30 días';

-- ============================================
-- 14. DATOS DE EJEMPLO - KPIs
-- ============================================

INSERT INTO public.kpi_definitions (
  kpi_code,
  kpi_name,
  description,
  category,
  calculation_method,
  calculation_config,
  data_type,
  suffix,
  target_value,
  is_higher_better
) VALUES
(
  'INVENTORY_TURNOVER',
  'Rotación de Inventario',
  'Número de veces que se renueva el inventario por año',
  'inventory',
  'function',
  '{"function": "calculate_inventory_turnover"}'::JSONB,
  'ratio',
  'veces/año',
  12.0,
  true
),
(
  'STOCK_VALUE',
  'Valor del Inventario',
  'Valor total del inventario actual',
  'financial',
  'function',
  '{"function": "calculate_stock_value"}'::JSONB,
  'currency',
  'MXN',
  NULL,
  false
),
(
  'EXPIRING_SOON_30',
  'Medicamentos por Vencer (30 días)',
  'Número de lotes que vencen en los próximos 30 días',
  'operational',
  'function',
  '{"function": "calculate_expiring_soon", "params": {"days": 30}}'::JSONB,
  'number',
  'lotes',
  0,
  false
),
(
  'STOCKOUT_RATE',
  'Tasa de Falta de Stock',
  'Porcentaje de medicamentos sin stock disponible',
  'operational',
  'function',
  '{"function": "calculate_stockout_rate"}'::JSONB,
  'percentage',
  '%',
  0,
  false
)
ON CONFLICT (kpi_code) DO NOTHING;

-- ============================================
-- FIN DE MIGRACIÓN 17
-- ============================================

SELECT 'Migración 17 completada. Sistema de Advanced Analytics Dashboard implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('kpi_definitions', 'kpi_snapshots', 'dashboard_widgets', 'user_dashboards', 'analytics_events');
