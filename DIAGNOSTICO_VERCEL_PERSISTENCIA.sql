-- ============================================
-- DIAGNÓSTICO COMPLETO - VERIFICAR PERSISTENCIA
-- ============================================
-- Este script verifica por qué los datos no persisten
-- desde el frontend de Vercel
-- ============================================

-- ============================================
-- 1. VERIFICAR TABLA Y ESTRUCTURA
-- ============================================

-- Verificar que tabla medication_catalog existe
SELECT
  table_name,
  CASE
    WHEN table_name = 'medication_catalog' THEN '✅ Tabla medication_catalog existe'
    ELSE '❌ Tabla NO encontrada'
  END as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'medication_catalog';

-- ============================================
-- 2. VERIFICAR DATOS EXISTENTES
-- ============================================

-- Contar medicamentos en la tabla
SELECT
  count(*) as total_medicamentos,
  CASE
    WHEN count(*) = 0 THEN '⚠️ NO HAY DATOS - Tabla vacía'
    WHEN count(*) > 100 THEN '✅ Datos cargados correctamente (101 medicamentos esperados)'
    ELSE concat('⚠️ Solo hay ', count(*), ' medicamentos')
  END as diagnostico
FROM medication_catalog;

-- Verificar si existe el medicamento de prueba MED-TEST-001
SELECT
  CASE
    WHEN EXISTS (SELECT 1 FROM medication_catalog WHERE codigo_medicamento = 'MED-TEST-001')
    THEN '✅ MED-TEST-001 existe en BD'
    ELSE '❌ MED-TEST-001 NO existe (no se guardó desde frontend)'
  END as prueba_frontend;

-- Mostrar últimos 5 medicamentos creados
SELECT
  codigo_medicamento,
  nombre_generico,
  created_at,
  is_active
FROM medication_catalog
ORDER BY created_at DESC
LIMIT 5;

-- ============================================
-- 3. VERIFICAR ROW LEVEL SECURITY (RLS)
-- ============================================

-- Verificar si RLS está habilitado
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_habilitado,
  CASE
    WHEN rowsecurity = true THEN '✅ RLS habilitado (correcto)'
    ELSE '⚠️ RLS deshabilitado'
  END as estado_rls
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medication_catalog';

-- Verificar políticas RLS existentes
SELECT
  policyname as nombre_politica,
  cmd as operacion,
  CASE
    WHEN qual IS NOT NULL THEN 'USING: ' || pg_get_expr(qual, polrelid)
    ELSE 'Sin restricción USING'
  END as condicion_using,
  CASE
    WHEN with_check IS NOT NULL THEN 'WITH CHECK: ' || pg_get_expr(with_check, polrelid)
    ELSE 'Sin restricción WITH CHECK'
  END as condicion_check
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass
ORDER BY cmd;

-- Contar políticas por tipo de operación
SELECT
  'SELECT' as operacion,
  count(*) as num_politicas,
  CASE WHEN count(*) > 0 THEN '✅' ELSE '❌ FALTA' END as estado
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'SELECT'

UNION ALL

SELECT
  'INSERT' as operacion,
  count(*) as num_politicas,
  CASE WHEN count(*) > 0 THEN '✅' ELSE '❌ FALTA - CRÍTICO!' END as estado
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'INSERT'

UNION ALL

SELECT
  'UPDATE' as operacion,
  count(*) as num_politicas,
  CASE WHEN count(*) > 0 THEN '✅' ELSE '❌ FALTA' END as estado
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'UPDATE'

UNION ALL

SELECT
  'DELETE' as operacion,
  count(*) as num_politicas,
  CASE WHEN count(*) > 0 THEN '✅' ELSE '❌ FALTA' END as estado
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'DELETE';

-- ============================================
-- 4. PROBAR INSERT DIRECTO (Simular Frontend)
-- ============================================

-- Intentar insertar medicamento de prueba
DO $$
DECLARE
  v_test_code TEXT := 'DIAG-TEST-' || to_char(now(), 'YYYYMMDD-HH24MISS');
  v_inserted_id UUID;
BEGIN
  -- Intentar INSERT
  INSERT INTO medication_catalog (
    codigo_medicamento,
    nombre_generico,
    forma_farmaceutica,
    via_administracion,
    unidad_medida,
    is_active
  ) VALUES (
    v_test_code,
    'Medicamento Diagnóstico Test',
    'Tableta',
    'Oral',
    'Caja',
    true
  )
  RETURNING id INTO v_inserted_id;

  RAISE NOTICE '✅ INSERT exitoso! ID: %, Código: %', v_inserted_id, v_test_code;

  -- Verificar que se guardó
  IF EXISTS (SELECT 1 FROM medication_catalog WHERE id = v_inserted_id) THEN
    RAISE NOTICE '✅ Verificación: Medicamento persiste en BD';

    -- Limpiar prueba
    DELETE FROM medication_catalog WHERE id = v_inserted_id;
    RAISE NOTICE '🧹 Medicamento de prueba eliminado';
  ELSE
    RAISE NOTICE '❌ CRÍTICO: INSERT ejecutó pero dato NO persiste!';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR al insertar: % - %', SQLSTATE, SQLERRM;
    RAISE NOTICE 'Detalle: %', SQLERRM;
END $$;

-- ============================================
-- 5. VERIFICAR AUTENTICACIÓN
-- ============================================

-- Verificar usuario actual
SELECT
  current_user as usuario_postgres,
  auth.role() as rol_supabase,
  CASE
    WHEN auth.role() = 'authenticated' THEN '✅ Usuario autenticado'
    WHEN auth.role() = 'anon' THEN '⚠️ Usuario anónimo (puede causar problemas con RLS)'
    ELSE '❌ Rol desconocido: ' || auth.role()
  END as diagnostico;

-- ============================================
-- 6. RESUMEN Y DIAGNÓSTICO FINAL
-- ============================================

SELECT
  '=== RESUMEN DIAGNÓSTICO ===' as titulo;

-- Verificar configuración completa
WITH diagnostico AS (
  SELECT
    (SELECT count(*) FROM medication_catalog) as total_medicamentos,
    (SELECT rowsecurity FROM pg_tables WHERE tablename = 'medication_catalog') as rls_habilitado,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'INSERT') as politicas_insert,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medication_catalog'::regclass AND cmd = 'SELECT') as politicas_select
)
SELECT
  CASE
    WHEN total_medicamentos = 0 THEN
      '❌ PROBLEMA: Tabla vacía - ejecutar CARGA_MEDICAMENTOS_CSV.sql'
    WHEN total_medicamentos < 10 THEN
      '⚠️ ADVERTENCIA: Pocos medicamentos (' || total_medicamentos || ') - verificar carga'
    ELSE
      '✅ Datos: ' || total_medicamentos || ' medicamentos en BD'
  END as estado_datos,

  CASE
    WHEN NOT rls_habilitado THEN
      '⚠️ RLS deshabilitado - habilitar para seguridad'
    WHEN politicas_insert = 0 THEN
      '❌ CRÍTICO: RLS habilitado pero SIN política INSERT - ejecutar SOLUCION_RAPIDA_PERSISTENCIA.sql'
    WHEN politicas_select = 0 THEN
      '❌ PROBLEMA: Sin política SELECT - usuarios no pueden ver datos'
    ELSE
      '✅ RLS configurado correctamente (' || politicas_insert || ' INSERT, ' || politicas_select || ' SELECT)'
  END as estado_rls,

  CASE
    WHEN politicas_insert = 0 THEN
      '🔧 SOLUCIÓN: Ejecutar el script SOLUCION_RAPIDA_PERSISTENCIA.sql'
    WHEN total_medicamentos = 0 THEN
      '🔧 SOLUCIÓN: Ejecutar el script CARGA_MEDICAMENTOS_CSV.sql'
    ELSE
      '✅ Sistema configurado correctamente'
  END as recomendacion
FROM diagnostico;

-- ============================================
-- INSTRUCCIONES FINALES
-- ============================================

SELECT
  'Si ves ❌ CRÍTICO: RLS habilitado pero SIN política INSERT' as problema,
  'Ejecuta inmediatamente: SOLUCION_RAPIDA_PERSISTENCIA.sql' as solucion,
  'Esto desbloqueará la persistencia de datos' as resultado;
