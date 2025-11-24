-- ============================================
-- CREAR TABLA ALERTAS_MEDICAMENTOS Y FUNCIÓN
-- Ejecutar en Supabase SQL Editor
-- ============================================

BEGIN;

-- ============================================
-- 1. CREAR TABLA ALERTAS_MEDICAMENTOS
-- ============================================
CREATE TABLE IF NOT EXISTS alertas_medicamentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medicamento_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  centro_id UUID REFERENCES health_centers(id),
  nivel_alerta TEXT NOT NULL CHECK (nivel_alerta IN ('critico', 'urgente', 'preventivo')),
  dias_restantes INTEGER NOT NULL,
  visto BOOLEAN DEFAULT false,
  resuelta BOOLEAN DEFAULT false,
  visto_por UUID REFERENCES users_profiles(id),
  visto_en TIMESTAMP WITH TIME ZONE,
  resuelta_por UUID REFERENCES users_profiles(id),
  resuelta_en TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para alertas
CREATE INDEX IF NOT EXISTS idx_alertas_centro ON alertas_medicamentos(centro_id);
CREATE INDEX IF NOT EXISTS idx_alertas_nivel ON alertas_medicamentos(nivel_alerta, resuelta);
CREATE INDEX IF NOT EXISTS idx_alertas_medicamento ON alertas_medicamentos(medicamento_id);

COMMENT ON TABLE alertas_medicamentos IS 'Alertas de medicamentos próximos a caducar';

-- ============================================
-- 2. HABILITAR RLS
-- ============================================
ALTER TABLE alertas_medicamentos ENABLE ROW LEVEL SECURITY;

-- Política para lectura
DROP POLICY IF EXISTS "Usuarios pueden ver alertas de su centro" ON alertas_medicamentos;
CREATE POLICY "Usuarios pueden ver alertas de su centro" ON alertas_medicamentos
  FOR SELECT USING (true);

-- Política para inserción (solo sistema)
DROP POLICY IF EXISTS "Sistema puede insertar alertas" ON alertas_medicamentos;
CREATE POLICY "Sistema puede insertar alertas" ON alertas_medicamentos
  FOR INSERT WITH CHECK (true);

-- Política para actualización
DROP POLICY IF EXISTS "Usuarios pueden actualizar alertas" ON alertas_medicamentos;
CREATE POLICY "Usuarios pueden actualizar alertas" ON alertas_medicamentos
  FOR UPDATE USING (true);

-- Política para eliminación
DROP POLICY IF EXISTS "Sistema puede eliminar alertas" ON alertas_medicamentos;
CREATE POLICY "Sistema puede eliminar alertas" ON alertas_medicamentos
  FOR DELETE USING (true);

-- ============================================
-- 3. FUNCIÓN PARA GENERAR ALERTAS AUTOMÁTICAS
-- ============================================
CREATE OR REPLACE FUNCTION generar_alertas_caducidad()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  alertas_generadas INTEGER := 0;
  alertas_eliminadas INTEGER := 0;
BEGIN
  -- Eliminar alertas de lotes ya vencidos o resueltas antiguas
  DELETE FROM alertas_medicamentos
  WHERE resuelta = true
    OR dias_restantes < 0;

  GET DIAGNOSTICS alertas_eliminadas = ROW_COUNT;

  -- Actualizar días restantes de alertas existentes
  UPDATE alertas_medicamentos am
  SET
    dias_restantes = (
      SELECT MIN(b.fecha_caducidad - CURRENT_DATE)
      FROM batches b
      WHERE b.medication_id = am.medicamento_id
        AND b.center_id = am.centro_id
        AND b.estado = 'disponible'
        AND b.cantidad_actual > 0
    ),
    nivel_alerta = CASE
      WHEN (
        SELECT MIN(b.fecha_caducidad - CURRENT_DATE)
        FROM batches b
        WHERE b.medication_id = am.medicamento_id
          AND b.center_id = am.centro_id
          AND b.estado = 'disponible'
          AND b.cantidad_actual > 0
      ) <= 7 THEN 'critico'
      WHEN (
        SELECT MIN(b.fecha_caducidad - CURRENT_DATE)
        FROM batches b
        WHERE b.medication_id = am.medicamento_id
          AND b.center_id = am.centro_id
          AND b.estado = 'disponible'
          AND b.cantidad_actual > 0
      ) <= 30 THEN 'urgente'
      ELSE 'preventivo'
    END
  WHERE resuelta = false;

  -- Insertar nuevas alertas para medicamentos próximos a caducar
  INSERT INTO alertas_medicamentos (medicamento_id, centro_id, nivel_alerta, dias_restantes)
  SELECT DISTINCT
    b.medication_id,
    b.center_id,
    CASE
      WHEN MIN(b.fecha_caducidad - CURRENT_DATE) <= 7 THEN 'critico'
      WHEN MIN(b.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'urgente'
      ELSE 'preventivo'
    END as nivel,
    MIN(b.fecha_caducidad - CURRENT_DATE) as dias
  FROM batches b
  WHERE b.estado = 'disponible'
    AND b.cantidad_actual > 0
    AND b.fecha_caducidad <= CURRENT_DATE + INTERVAL '90 days'
    AND NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos a
      WHERE a.medicamento_id = b.medication_id
        AND a.centro_id = b.center_id
        AND a.resuelta = false
    )
  GROUP BY b.medication_id, b.center_id;

  GET DIAGNOSTICS alertas_generadas = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Alertas generadas exitosamente',
    'alertas_generadas', alertas_generadas,
    'alertas_eliminadas', alertas_eliminadas
  );
END;
$$;

COMMENT ON FUNCTION generar_alertas_caducidad() IS 'Genera alertas automáticas para medicamentos próximos a caducar basándose en los lotes';

COMMIT;

-- ============================================
-- 4. GENERAR ALERTAS INICIALES
-- ============================================
SELECT generar_alertas_caducidad();

-- ============================================
-- 5. VERIFICAR RESULTADO
-- ============================================
SELECT
  '✅ TABLA ALERTAS_MEDICAMENTOS' as resultado,
  COUNT(*) as total_alertas,
  COUNT(*) FILTER (WHERE nivel_alerta = 'critico') as criticas,
  COUNT(*) FILTER (WHERE nivel_alerta = 'urgente') as urgentes,
  COUNT(*) FILTER (WHERE nivel_alerta = 'preventivo') as preventivas
FROM alertas_medicamentos
WHERE resuelta = false;

-- Ver detalle de alertas generadas
SELECT
  am.id,
  m.nombre as medicamento,
  hc.name as centro,
  am.nivel_alerta,
  am.dias_restantes,
  am.created_at
FROM alertas_medicamentos am
LEFT JOIN medications m ON am.medicamento_id = m.id
LEFT JOIN health_centers hc ON am.centro_id = hc.id
WHERE am.resuelta = false
ORDER BY am.dias_restantes ASC
LIMIT 20;
