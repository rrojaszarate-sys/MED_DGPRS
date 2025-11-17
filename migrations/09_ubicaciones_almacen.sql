-- ============================================
-- MIGRACIÓN 09: SISTEMA DE UBICACIONES FÍSICAS
-- ============================================
-- Descripción: Implementa el control de ubicaciones físicas en el almacén
-- Fecha: 2025-11-17
-- Autor: Sistema Automático

-- ============================================
-- 1. TABLA: ubicaciones_almacen
-- ============================================

CREATE TABLE IF NOT EXISTS public.ubicaciones_almacen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  centro_id UUID NOT NULL REFERENCES public.health_centers(id) ON DELETE CASCADE,
  codigo TEXT NOT NULL, -- Ej: "A-03-05" (Pasillo-Estante-Nivel)
  nombre TEXT,
  tipo TEXT CHECK (tipo IN ('ambiente', 'refrigerado', 'congelado', 'controlado')) DEFAULT 'ambiente',
  temperatura_min DECIMAL(5,2), -- Temperatura mínima permitida (°C)
  temperatura_max DECIMAL(5,2), -- Temperatura máxima permitida (°C)
  capacidad_max INTEGER DEFAULT 0, -- Capacidad máxima en unidades
  capacidad_actual INTEGER DEFAULT 0 CHECK (capacidad_actual >= 0 AND capacidad_actual <= capacidad_max),
  es_cuarentena BOOLEAN DEFAULT false,
  requiere_acceso_especial BOOLEAN DEFAULT false,
  observaciones TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(centro_id, codigo)
);

COMMENT ON TABLE public.ubicaciones_almacen IS 'Ubicaciones físicas dentro del almacén de medicamentos';
COMMENT ON COLUMN public.ubicaciones_almacen.codigo IS 'Código de ubicación física (Ej: A-03-05)';
COMMENT ON COLUMN public.ubicaciones_almacen.tipo IS 'Tipo de almacenamiento requerido';
COMMENT ON COLUMN public.ubicaciones_almacen.capacidad_max IS 'Capacidad máxima en unidades';
COMMENT ON COLUMN public.ubicaciones_almacen.es_cuarentena IS 'Indica si es zona de cuarentena';

-- ============================================
-- 2. TABLA: lotes_ubicaciones
-- ============================================

CREATE TABLE IF NOT EXISTS public.lotes_ubicaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
  ubicacion_id UUID NOT NULL REFERENCES public.ubicaciones_almacen(id) ON DELETE CASCADE,
  cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
  fecha_ubicacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(batch_id, ubicacion_id)
);

COMMENT ON TABLE public.lotes_ubicaciones IS 'Mapeo de lotes a ubicaciones físicas';
COMMENT ON COLUMN public.lotes_ubicaciones.cantidad IS 'Cantidad del lote en esta ubicación';

-- ============================================
-- 3. ÍNDICES
-- ============================================

CREATE INDEX idx_ubicaciones_centro ON public.ubicaciones_almacen(centro_id);
CREATE INDEX idx_ubicaciones_codigo ON public.ubicaciones_almacen(codigo);
CREATE INDEX idx_ubicaciones_tipo ON public.ubicaciones_almacen(tipo);
CREATE INDEX idx_ubicaciones_activas ON public.ubicaciones_almacen(is_active) WHERE is_active = true;

CREATE INDEX idx_lotes_ubicaciones_batch ON public.lotes_ubicaciones(batch_id);
CREATE INDEX idx_lotes_ubicaciones_ubicacion ON public.lotes_ubicaciones(ubicacion_id);

-- ============================================
-- 4. TRIGGERS
-- ============================================

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_ubicaciones_almacen_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ubicaciones_almacen_updated_at
  BEFORE UPDATE ON public.ubicaciones_almacen
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_lotes_ubicaciones_updated_at
  BEFORE UPDATE ON public.lotes_ubicaciones
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- Trigger para actualizar capacidad_actual de ubicación
CREATE OR REPLACE FUNCTION update_ubicacion_capacidad()
RETURNS TRIGGER AS $$
DECLARE
  v_capacidad_total INTEGER;
BEGIN
  -- Calcular capacidad total ocupada en la ubicación
  SELECT COALESCE(SUM(cantidad), 0)
  INTO v_capacidad_total
  FROM public.lotes_ubicaciones
  WHERE ubicacion_id = COALESCE(NEW.ubicacion_id, OLD.ubicacion_id);

  -- Actualizar capacidad_actual de la ubicación
  UPDATE public.ubicaciones_almacen
  SET capacidad_actual = v_capacidad_total
  WHERE id = COALESCE(NEW.ubicacion_id, OLD.ubicacion_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ubicacion_capacidad_insert
  AFTER INSERT ON public.lotes_ubicaciones
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicacion_capacidad();

CREATE TRIGGER trigger_update_ubicacion_capacidad_update
  AFTER UPDATE ON public.lotes_ubicaciones
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicacion_capacidad();

CREATE TRIGGER trigger_update_ubicacion_capacidad_delete
  AFTER DELETE ON public.lotes_ubicaciones
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicacion_capacidad();

-- ============================================
-- 5. FUNCIONES
-- ============================================

-- Función para obtener ubicaciones con espacio disponible
CREATE OR REPLACE FUNCTION get_ubicaciones_disponibles(
  p_center_id UUID,
  p_tipo TEXT DEFAULT NULL,
  p_cantidad_requerida INTEGER DEFAULT 1
)
RETURNS TABLE (
  ubicacion_id UUID,
  codigo TEXT,
  nombre TEXT,
  tipo TEXT,
  espacio_disponible INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id AS ubicacion_id,
    u.codigo,
    u.nombre,
    u.tipo,
    (u.capacidad_max - u.capacidad_actual) AS espacio_disponible
  FROM public.ubicaciones_almacen u
  WHERE u.centro_id = p_center_id
    AND u.is_active = true
    AND u.es_cuarentena = false
    AND (p_tipo IS NULL OR u.tipo = p_tipo)
    AND (u.capacidad_max - u.capacidad_actual) >= p_cantidad_requerida
  ORDER BY u.codigo;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_ubicaciones_disponibles IS 'Obtiene ubicaciones con espacio disponible';

-- Función para obtener lotes por ubicación
CREATE OR REPLACE FUNCTION get_lotes_por_ubicacion(
  p_ubicacion_id UUID
)
RETURNS TABLE (
  batch_id UUID,
  numero_lote TEXT,
  medicamento_nombre TEXT,
  cantidad INTEGER,
  fecha_caducidad DATE,
  estado TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id AS batch_id,
    b.numero_lote,
    m.nombre AS medicamento_nombre,
    lu.cantidad,
    b.fecha_caducidad,
    b.estado
  FROM public.lotes_ubicaciones lu
  JOIN public.batches b ON lu.batch_id = b.id
  LEFT JOIN public.medications m ON b.medication_id = m.id
  WHERE lu.ubicacion_id = p_ubicacion_id
  ORDER BY b.fecha_caducidad ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_lotes_por_ubicacion IS 'Obtiene todos los lotes en una ubicación específica';

-- ============================================
-- 6. ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.ubicaciones_almacen ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lotes_ubicaciones ENABLE ROW LEVEL SECURITY;

-- Políticas para ubicaciones_almacen
CREATE POLICY "Usuarios pueden ver ubicaciones de su centro"
  ON public.ubicaciones_almacen FOR SELECT
  USING (
    centro_id IN (
      SELECT center_id FROM public.users_profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Admin y Admin Center pueden insertar ubicaciones"
  ON public.ubicaciones_almacen FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Admin y Admin Center pueden actualizar ubicaciones"
  ON public.ubicaciones_almacen FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Solo Super Admin puede eliminar ubicaciones"
  ON public.ubicaciones_almacen FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- Políticas para lotes_ubicaciones
CREATE POLICY "Usuarios pueden ver lotes_ubicaciones de su centro"
  ON public.lotes_ubicaciones FOR SELECT
  USING (
    ubicacion_id IN (
      SELECT id FROM public.ubicaciones_almacen
      WHERE centro_id IN (
        SELECT center_id FROM public.users_profiles WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "Usuarios inventory pueden gestionar lotes_ubicaciones"
  ON public.lotes_ubicaciones FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center', 'inventory_user')
    )
  );

-- ============================================
-- 7. DATOS DE EJEMPLO (OPCIONAL)
-- ============================================

-- Insertar ubicaciones de ejemplo para el primer centro
DO $$
DECLARE
  v_centro_id UUID;
BEGIN
  -- Obtener el primer centro activo
  SELECT id INTO v_centro_id FROM public.health_centers WHERE is_active = true LIMIT 1;

  IF v_centro_id IS NOT NULL THEN
    -- Pasillo A - Ambiente
    INSERT INTO public.ubicaciones_almacen (centro_id, codigo, nombre, tipo, temperatura_min, temperatura_max, capacidad_max)
    VALUES
      (v_centro_id, 'A-01-01', 'Pasillo A - Estante 1 - Nivel 1', 'ambiente', 15, 25, 500),
      (v_centro_id, 'A-01-02', 'Pasillo A - Estante 1 - Nivel 2', 'ambiente', 15, 25, 500),
      (v_centro_id, 'A-02-01', 'Pasillo A - Estante 2 - Nivel 1', 'ambiente', 15, 25, 500),
      (v_centro_id, 'A-02-02', 'Pasillo A - Estante 2 - Nivel 2', 'ambiente', 15, 25, 500)
    ON CONFLICT (centro_id, codigo) DO NOTHING;

    -- Pasillo B - Refrigerado
    INSERT INTO public.ubicaciones_almacen (centro_id, codigo, nombre, tipo, temperatura_min, temperatura_max, capacidad_max)
    VALUES
      (v_centro_id, 'B-01-01', 'Refrigerador 1 - Estante 1', 'refrigerado', 2, 8, 200),
      (v_centro_id, 'B-01-02', 'Refrigerador 1 - Estante 2', 'refrigerado', 2, 8, 200)
    ON CONFLICT (centro_id, codigo) DO NOTHING;

    -- Pasillo C - Controlados
    INSERT INTO public.ubicaciones_almacen (centro_id, codigo, nombre, tipo, temperatura_min, temperatura_max, capacidad_max, requiere_acceso_especial)
    VALUES
      (v_centro_id, 'C-01-01', 'Medicamentos Controlados - Estante 1', 'controlado', 15, 25, 300, true)
    ON CONFLICT (centro_id, codigo) DO NOTHING;

    -- Zona de Cuarentena
    INSERT INTO public.ubicaciones_almacen (centro_id, codigo, nombre, tipo, temperatura_min, temperatura_max, capacidad_max, es_cuarentena)
    VALUES
      (v_centro_id, 'Q-01-01', 'Cuarentena - Zona 1', 'ambiente', 15, 25, 200, true)
    ON CONFLICT (centro_id, codigo) DO NOTHING;

    RAISE NOTICE 'Ubicaciones de ejemplo creadas para centro: %', v_centro_id;
  ELSE
    RAISE NOTICE 'No se encontraron centros activos';
  END IF;
END $$;

-- ============================================
-- FIN DE MIGRACIÓN 09
-- ============================================

-- Verificar creación
SELECT 'Migración 09 completada. Tablas creadas:' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('ubicaciones_almacen', 'lotes_ubicaciones');
