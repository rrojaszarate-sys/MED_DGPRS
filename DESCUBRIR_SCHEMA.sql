-- ============================================
-- SCRIPT PARA DESCUBRIR EL SCHEMA REAL
-- ============================================
-- Este script te mostrará exactamente qué tablas
-- y columnas existen en tu base de datos
-- ============================================

-- 1. Listar TODAS las tablas en public schema
SELECT
  '📋 TABLAS DISPONIBLES' as info,
  table_name as tabla,
  (SELECT COUNT(*)
   FROM information_schema.columns
   WHERE table_schema = 'public'
   AND table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Detalles de cada tabla relevante
SELECT
  '🔍 ESTRUCTURA DE TABLAS' as info,
  table_name as tabla,
  column_name as columna,
  data_type as tipo,
  is_nullable as nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
    'health_centers',
    'users_profiles',
    'user_centers',
    'suppliers',
    'medication_catalog',
    'medications',
    'batch_movements',
    'transfers',
    'audit_log'
  )
ORDER BY table_name, ordinal_position;

-- 3. Verificar funciones SQL disponibles
SELECT
  '⚙️ FUNCIONES SQL DISPONIBLES' as info,
  routine_name as funcion,
  routine_type as tipo
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'search_inventory_with_batches',
    'generate_traceability_report',
    'audit_trigger_func'
  )
ORDER BY routine_name;

-- 4. Contar registros existentes
SELECT
  '📊 DATOS EXISTENTES' as info,
  'health_centers' as tabla,
  COUNT(*) as total_registros
FROM health_centers
UNION ALL
SELECT '📊 DATOS EXISTENTES', 'medications', COUNT(*) FROM medications
UNION ALL
SELECT '📊 DATOS EXISTENTES', 'medication_catalog', COUNT(*) FROM medication_catalog
UNION ALL
SELECT '📊 DATOS EXISTENTES', 'batch_movements', COUNT(*) FROM batch_movements
UNION ALL
SELECT '📊 DATOS EXISTENTES', 'users_profiles', COUNT(*) FROM users_profiles;
