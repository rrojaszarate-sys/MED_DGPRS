-- ============================================
-- APLICAR POLÍTICAS RLS - VERSIÓN GARANTIZADA
-- ============================================
-- Este script GARANTIZA que las políticas RLS
-- estén correctas para medication_catalog
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: LIMPIAR POLÍTICAS ANTERIORES
-- ============================================

-- Eliminar TODAS las políticas existentes (si existen)
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;

-- También eliminar variantes con nombres diferentes
DROP POLICY IF EXISTS "select_medication_catalog" ON medication_catalog;
DROP POLICY IF EXISTS "insert_medication_catalog" ON medication_catalog;
DROP POLICY IF EXISTS "update_medication_catalog" ON medication_catalog;
DROP POLICY IF EXISTS "delete_medication_catalog" ON medication_catalog;

DROP POLICY IF EXISTS "medication_select" ON medication_catalog;
DROP POLICY IF EXISTS "medication_insert" ON medication_catalog;
DROP POLICY IF EXISTS "medication_update" ON medication_catalog;
DROP POLICY IF EXISTS "medication_delete" ON medication_catalog;

-- ============================================
-- PASO 2: HABILITAR RLS
-- ============================================

-- Asegurar que RLS está habilitado
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 3: CREAR POLÍTICAS PERMISIVAS
-- ============================================
-- IMPORTANTE: Estas políticas permiten a CUALQUIER
-- usuario autenticado hacer operaciones.
-- En producción, deberías restringir por roles.
-- ============================================

-- POLÍTICA 1: SELECT (Ver medicamentos)
-- Permite a usuarios autenticados Y anónimos ver el catálogo
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    OR auth.role() = 'anon'
  );

-- POLÍTICA 2: INSERT (Crear medicamentos)
-- Permite a usuarios autenticados crear medicamentos
CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
  );

-- POLÍTICA 3: UPDATE (Actualizar medicamentos)
-- Permite a usuarios autenticados actualizar medicamentos
CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (
    auth.role() = 'authenticated'
  )
  WITH CHECK (
    auth.role() = 'authenticated'
  );

-- POLÍTICA 4: DELETE (Eliminar medicamentos)
-- Permite a usuarios autenticados eliminar medicamentos
CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (
    auth.role() = 'authenticated'
  );

-- ============================================
-- PASO 4: VERIFICACIÓN INMEDIATA
-- ============================================

-- Contar políticas creadas
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
  RAISE NOTICE 'VERIFICACIÓN DE POLÍTICAS RLS';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Políticas SELECT: %', v_count_select;
  RAISE NOTICE 'Políticas INSERT: %', v_count_insert;
  RAISE NOTICE 'Políticas UPDATE: %', v_count_update;
  RAISE NOTICE 'Políticas DELETE: %', v_count_delete;

  IF v_count_insert > 0 THEN
    RAISE NOTICE '✅ ÉXITO: Política INSERT creada correctamente';
  ELSE
    RAISE EXCEPTION '❌ ERROR: No se creó política INSERT';
  END IF;

  IF v_count_select > 0 THEN
    RAISE NOTICE '✅ ÉXITO: Política SELECT creada correctamente';
  ELSE
    RAISE EXCEPTION '❌ ERROR: No se creó política SELECT';
  END IF;

  RAISE NOTICE '====================================';
  RAISE NOTICE '✅ POLÍTICAS RLS APLICADAS EXITOSAMENTE';
  RAISE NOTICE '====================================';
END $$;

COMMIT;

-- ============================================
-- PASO 5: PRUEBA DE INSERCIÓN
-- ============================================

-- Hacer una prueba real de INSERT
DO $$
DECLARE
  v_test_id UUID;
  v_test_code TEXT := 'TEST-RLS-' || to_char(now(), 'YYYYMMDD-HH24MI');
BEGIN
  INSERT INTO medication_catalog (
    codigo_medicamento,
    nombre_generico,
    forma_farmaceutica,
    via_administracion,
    unidad_medida,
    is_active
  ) VALUES (
    v_test_code,
    'Prueba de Políticas RLS',
    'Tableta',
    'Oral',
    'Caja',
    true
  )
  RETURNING id INTO v_test_id;

  RAISE NOTICE '====================================';
  RAISE NOTICE '✅ PRUEBA INSERT EXITOSA';
  RAISE NOTICE 'ID creado: %', v_test_id;
  RAISE NOTICE 'Código: %', v_test_code;
  RAISE NOTICE '====================================';

  -- Verificar que se puede leer
  IF EXISTS (SELECT 1 FROM medication_catalog WHERE id = v_test_id) THEN
    RAISE NOTICE '✅ PRUEBA SELECT EXITOSA - Dato se puede leer';
  ELSE
    RAISE EXCEPTION '❌ ERROR: Dato insertado pero no se puede leer (problema con SELECT policy)';
  END IF;

  -- Limpiar dato de prueba
  DELETE FROM medication_catalog WHERE id = v_test_id;
  RAISE NOTICE '🧹 Dato de prueba eliminado';

  RAISE NOTICE '====================================';
  RAISE NOTICE '🎉 TODAS LAS PRUEBAS PASARON';
  RAISE NOTICE '====================================';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '====================================';
    RAISE NOTICE '❌ ERROR EN PRUEBA: %', SQLERRM;
    RAISE NOTICE 'Código error: %', SQLSTATE;
    RAISE NOTICE '====================================';
    RAISE;
END $$;

-- ============================================
-- MOSTRAR RESUMEN FINAL
-- ============================================

SELECT
  'medication_catalog' as tabla,
  (SELECT rowsecurity FROM pg_tables WHERE tablename = 'medication_catalog') as rls_habilitado,
  (SELECT count(*) FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass) as total_politicas,
  (SELECT count(*) FROM medication_catalog) as total_medicamentos;

SELECT
  policyname as politica,
  cmd as operacion,
  CASE
    WHEN cmd = 'SELECT' THEN '✅ Permite ver datos'
    WHEN cmd = 'INSERT' THEN '✅ Permite crear datos'
    WHEN cmd = 'UPDATE' THEN '✅ Permite actualizar datos'
    WHEN cmd = 'DELETE' THEN '✅ Permite eliminar datos'
  END as descripcion
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass
ORDER BY cmd;
