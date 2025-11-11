-- ============================================
-- VERIFICACIÓN Y CORRECCIÓN - AMBAS TABLAS
-- ============================================
-- Este script verifica y corrige políticas RLS
-- en AMBAS tablas: medication_catalog Y medications
-- ============================================

-- ============================================
-- PARTE 1: VERIFICAR TABLAS EXISTENTES
-- ============================================

SELECT
  '=== VERIFICACIÓN DE TABLAS ===' as titulo;

-- Verificar qué tablas existen
SELECT
  table_name,
  CASE
    WHEN table_name = 'medication_catalog' THEN '✅ Catálogo maestro (usado en /admin)'
    WHEN table_name = 'medications' THEN '✅ Instancias en centros (usado en /inventario)'
    WHEN table_name = 'medicamentos' THEN '⚠️ Tabla antigua - no debería existir'
    ELSE 'Otra tabla'
  END as descripcion
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('medication_catalog', 'medications', 'medicamentos')
ORDER BY table_name;

-- ============================================
-- PARTE 2: VERIFICAR RLS EN medication_catalog
-- ============================================

SELECT
  '=== VERIFICACIÓN RLS: medication_catalog ===' as titulo;

-- Verificar si RLS está habilitado
SELECT
  tablename,
  rowsecurity as rls_habilitado,
  CASE
    WHEN rowsecurity = true THEN '✅ RLS habilitado'
    ELSE '❌ RLS deshabilitado'
  END as estado
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medication_catalog';

-- Contar políticas por operación
SELECT
  'medication_catalog' as tabla,
  cmd as operacion,
  count(*) as num_politicas,
  CASE
    WHEN count(*) = 0 THEN '❌ FALTA'
    ELSE '✅ Existe'
  END as estado
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass
GROUP BY cmd
ORDER BY cmd;

-- Mostrar políticas existentes
SELECT
  'medication_catalog' as tabla,
  policyname as nombre_politica,
  cmd as operacion
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass
ORDER BY cmd;

-- ============================================
-- PARTE 3: VERIFICAR RLS EN medications
-- ============================================

SELECT
  '=== VERIFICACIÓN RLS: medications ===' as titulo;

-- Verificar si RLS está habilitado
SELECT
  tablename,
  rowsecurity as rls_habilitado,
  CASE
    WHEN rowsecurity = true THEN '✅ RLS habilitado'
    ELSE '❌ RLS deshabilitado'
  END as estado
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medications';

-- Contar políticas por operación
SELECT
  'medications' as tabla,
  cmd as operacion,
  count(*) as num_politicas,
  CASE
    WHEN count(*) = 0 THEN '❌ FALTA'
    ELSE '✅ Existe'
  END as estado
FROM pg_policy
WHERE polrelid = 'medications'::regclass
GROUP BY cmd
ORDER BY cmd;

-- Mostrar políticas existentes
SELECT
  'medications' as tabla,
  policyname as nombre_politica,
  cmd as operacion
FROM pg_policy
WHERE polrelid = 'medications'::regclass
ORDER BY cmd;

-- ============================================
-- PARTE 4: VERIFICAR DATOS EXISTENTES
-- ============================================

SELECT
  '=== VERIFICACIÓN DE DATOS ===' as titulo;

-- Contar registros en medication_catalog
SELECT
  'medication_catalog' as tabla,
  count(*) as total_registros,
  count(*) FILTER (WHERE is_active = true) as activos,
  CASE
    WHEN count(*) = 0 THEN '⚠️ Tabla vacía - ejecutar CARGA_MEDICAMENTOS_CSV.sql'
    WHEN count(*) < 10 THEN '⚠️ Pocos registros (' || count(*) || ')'
    ELSE '✅ Datos cargados (' || count(*) || ' medicamentos)'
  END as diagnostico
FROM medication_catalog;

-- Contar registros en medications
SELECT
  'medications' as tabla,
  count(*) as total_registros,
  count(*) FILTER (WHERE is_active = true) as activos,
  CASE
    WHEN count(*) = 0 THEN '⚠️ Sin instancias en centros'
    ELSE '✅ ' || count(*) || ' instancias en centros'
  END as diagnostico
FROM medications;

-- ============================================
-- PARTE 5: CORRECCIÓN AUTOMÁTICA
-- ============================================

BEGIN;

-- ============================================
-- 5A. CORREGIR medication_catalog
-- ============================================

-- Eliminar políticas antiguas
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;

-- Habilitar RLS
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- Crear políticas permisivas
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (auth.role() = 'authenticated' OR auth.role() = 'anon');

CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- ============================================
-- 5B. CORREGIR medications
-- ============================================

-- Eliminar políticas antiguas
DROP POLICY IF EXISTS "medications_select_policy" ON medications;
DROP POLICY IF EXISTS "medications_insert_policy" ON medications;
DROP POLICY IF EXISTS "medications_update_policy" ON medications;
DROP POLICY IF EXISTS "medications_delete_policy" ON medications;

-- Habilitar RLS
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;

-- Crear políticas permisivas
CREATE POLICY "medications_select_policy" ON medications
  FOR SELECT
  USING (auth.role() = 'authenticated' OR auth.role() = 'anon');

CREATE POLICY "medications_insert_policy" ON medications
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "medications_update_policy" ON medications
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "medications_delete_policy" ON medications
  FOR DELETE
  USING (auth.role() = 'authenticated');

COMMIT;

-- ============================================
-- PARTE 6: VERIFICACIÓN POST-CORRECCIÓN
-- ============================================

SELECT
  '=== VERIFICACIÓN POST-CORRECCIÓN ===' as titulo;

-- Verificar medication_catalog
DO $$
DECLARE
  v_count_select INT;
  v_count_insert INT;
  v_count_update INT;
  v_count_delete INT;
BEGIN
  SELECT count(*) INTO v_count_select FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'SELECT';
  SELECT count(*) INTO v_count_insert FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'INSERT';
  SELECT count(*) INTO v_count_update FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'UPDATE';
  SELECT count(*) INTO v_count_delete FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'DELETE';

  RAISE NOTICE '====================================';
  RAISE NOTICE 'medication_catalog:';
  RAISE NOTICE '  SELECT: %', CASE WHEN v_count_select > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '  INSERT: %', CASE WHEN v_count_insert > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '  UPDATE: %', CASE WHEN v_count_update > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '  DELETE: %', CASE WHEN v_count_delete > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '====================================';

  IF v_count_insert = 0 THEN
    RAISE EXCEPTION '❌ CRÍTICO: No se creó política INSERT en medication_catalog';
  END IF;
END $$;

-- Verificar medications
DO $$
DECLARE
  v_count_select INT;
  v_count_insert INT;
  v_count_update INT;
  v_count_delete INT;
BEGIN
  SELECT count(*) INTO v_count_select FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'SELECT';
  SELECT count(*) INTO v_count_insert FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'INSERT';
  SELECT count(*) INTO v_count_update FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'UPDATE';
  SELECT count(*) INTO v_count_delete FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'DELETE';

  RAISE NOTICE '====================================';
  RAISE NOTICE 'medications:';
  RAISE NOTICE '  SELECT: %', CASE WHEN v_count_select > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '  INSERT: %', CASE WHEN v_count_insert > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '  UPDATE: %', CASE WHEN v_count_update > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '  DELETE: %', CASE WHEN v_count_delete > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '====================================';

  IF v_count_insert = 0 THEN
    RAISE EXCEPTION '❌ CRÍTICO: No se creó política INSERT en medications';
  END IF;
END $$;

-- ============================================
-- PARTE 7: PRUEBAS DE INSERCIÓN
-- ============================================

-- Prueba en medication_catalog
DO $$
DECLARE
  v_test_id UUID;
  v_test_code TEXT := 'TEST-CAT-' || to_char(now(), 'YYYYMMDD-HH24MISS');
BEGIN
  INSERT INTO medication_catalog (
    codigo_medicamento,
    nombre_generico,
    forma_farmaceutica,
    via_administracion,
    unidad_medida,
    requiere_receta,
    controlado,
    is_active
  ) VALUES (
    v_test_code,
    'Prueba Catálogo',
    'Tableta',
    'Oral',
    'Caja',
    false,
    false,
    true
  )
  RETURNING id INTO v_test_id;

  RAISE NOTICE '✅ INSERT en medication_catalog EXITOSO (ID: %)', v_test_id;

  -- Limpiar
  DELETE FROM medication_catalog WHERE id = v_test_id;
  RAISE NOTICE '🧹 Dato de prueba eliminado';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR en medication_catalog: %', SQLERRM;
END $$;

-- ============================================
-- PARTE 8: RESUMEN FINAL
-- ============================================

SELECT
  '=== RESUMEN FINAL ===' as titulo;

-- Resumen de políticas
WITH politicas AS (
  SELECT
    'medication_catalog' as tabla,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass) as total_politicas,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'INSERT') as tiene_insert,
    (SELECT count(*) FROM medication_catalog) as total_registros
  UNION ALL
  SELECT
    'medications' as tabla,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medications'::regclass) as total_politicas,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'INSERT') as tiene_insert,
    (SELECT count(*) FROM medications) as total_registros
)
SELECT
  tabla,
  total_politicas,
  CASE WHEN tiene_insert > 0 THEN '✅ INSERT OK' ELSE '❌ FALTA INSERT' END as estado_insert,
  total_registros,
  CASE
    WHEN tabla = 'medication_catalog' AND total_registros = 0 THEN
      '⚠️ Ejecutar CARGA_MEDICAMENTOS_CSV.sql'
    WHEN tiene_insert = 0 THEN
      '❌ CRÍTICO: Sin política INSERT'
    ELSE
      '✅ Configuración correcta'
  END as recomendacion
FROM politicas;
