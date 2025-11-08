-- ============================================
-- AUDITORÍA COMPLETA DEL SISTEMA ACTUAL
-- ============================================

-- 1. TABLAS EXISTENTES
SELECT 
  '📋 TABLAS EXISTENTES' as seccion,
  '' as detalle;

SELECT 
  tablename as tabla,
  'Existe' as estado
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. COLUMNAS POR TABLA
SELECT 
  '',
  '📊 ESTRUCTURA DE TABLAS' as seccion;

SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 3. FUNCIONES SQL
SELECT 
  '',
  '⚙️ FUNCIONES SQL' as seccion;

SELECT 
  routine_name as funcion,
  'Existe' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- 4. RLS ESTADO
SELECT 
  '',
  '🔒 ESTADO DE RLS' as seccion;

SELECT 
  tablename,
  CASE WHEN rowsecurity THEN 'Habilitado' ELSE 'Deshabilitado' END as rls
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- 5. CONTEO DE REGISTROS
SELECT 
  '',
  '📈 DATOS ACTUALES' as seccion;

SELECT 'health_centers' as tabla, COUNT(*) as registros FROM health_centers
UNION ALL
SELECT 'medication_catalog', COUNT(*) FROM medication_catalog
UNION ALL
SELECT 'medications', COUNT(*) FROM medications;
