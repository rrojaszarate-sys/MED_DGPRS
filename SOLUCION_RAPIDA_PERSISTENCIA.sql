-- ============================================
-- SOLUCIÓN RÁPIDA - PERMITIR PERSISTENCIA
-- ============================================
-- Problema: INSERT bloqueado por RLS sin políticas
-- Solución: Políticas permisivas temporales
-- Ejecutar en: Supabase SQL Editor
-- ============================================

BEGIN;

-- Habilitar RLS si no está habilitado
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas anteriores si existen
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;

-- POLÍTICA SELECT: Todos pueden ver (autenticados)
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (auth.role() = 'authenticated' OR auth.role() = 'anon');

-- POLÍTICA INSERT: Usuarios autenticados pueden insertar
CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- POLÍTICA UPDATE: Usuarios autenticados pueden actualizar
CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- POLÍTICA DELETE: Usuarios autenticados pueden eliminar
CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (auth.role() = 'authenticated');

COMMIT;

-- Verificar políticas creadas
SELECT
  count(*) as total_politicas,
  '✅ Políticas creadas' as resultado
FROM pg_policies
WHERE tablename = 'medication_catalog';

SELECT
  policyname,
  cmd as operacion,
  '✓' as estado
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY cmd;

-- Prueba de inserción
DO $$
BEGIN
  INSERT INTO medication_catalog (
    codigo_medicamento,
    nombre_generico,
    nombre_comercial,
    forma_farmaceutica,
    via_administracion,
    unidad_medida,
    categoria,
    requiere_receta,
    controlado,
    is_active
  ) VALUES (
    'PRUEBA-RAPIDA-001',
    'Medicamento de Prueba Rápida',
    'TestFarm Express',
    'Tableta',
    'Oral',
    'Caja',
    'Prueba',
    false,
    false,
    true
  );

  RAISE NOTICE '✅ INSERT exitoso: Medicamento de prueba creado';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE '❌ INSERT falló: %', SQLERRM;
END $$;

-- Verificar que se guardó
SELECT
  count(*) as medicamentos_encontrados,
  CASE
    WHEN count(*) > 0 THEN '✅ ¡PERSISTENCIA FUNCIONA!'
    ELSE '❌ Aún no persiste'
  END as resultado
FROM medication_catalog
WHERE codigo_medicamento = 'PRUEBA-RAPIDA-001';

-- Mostrar el medicamento creado
SELECT
  codigo_medicamento,
  nombre_generico,
  created_at
FROM medication_catalog
WHERE codigo_medicamento = 'PRUEBA-RAPIDA-001';

-- Eliminar medicamento de prueba
DELETE FROM medication_catalog WHERE codigo_medicamento = 'PRUEBA-RAPIDA-001';

-- ============================================
-- PRÓXIMOS PASOS:
-- 1. Probar crear medicamento en /admin
-- 2. Recargar página (F5)
-- 3. Medicamento DEBE seguir apareciendo
-- 4. Ejecutar FIX_CRITICAL_ERRORS.sql completo
-- 5. Ejecutar CARGA_MEDICAMENTOS_CSV.sql
-- ============================================
