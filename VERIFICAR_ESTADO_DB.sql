-- ============================================
-- SCRIPT PARA VERIFICAR ESTADO ACTUAL DE LA BASE DE DATOS
-- ============================================
-- Copia este script completo y ejecutalo en Supabase SQL Editor
-- Esto me mostrará exactamente qué tienes en tu base de datos

-- 1. Ver todas las tablas existentes
SELECT
  'TABLAS EXISTENTES' as tipo,
  table_name as nombre,
  'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Verificar si existen las tablas críticas
SELECT
  'VERIFICACION TABLA' as tipo,
  t.table_name as nombre,
  CASE
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = t.table_name)
    THEN '✅ EXISTE'
    ELSE '❌ NO EXISTE'
  END as estado
FROM (
  VALUES
    ('medications'),
    ('health_centers'),
    ('medication_catalog'),
    ('suppliers'),
    ('batches'),
    ('batch_movements')
) AS t(table_name);

-- 3. Ver columnas de la tabla medications (si existe)
SELECT
  'COLUMNAS medications' as tipo,
  column_name as nombre,
  data_type as tipo_dato
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'medications'
ORDER BY ordinal_position;

-- 4. Ver columnas de la tabla health_centers (si existe)
SELECT
  'COLUMNAS health_centers' as tipo,
  column_name as nombre,
  data_type as tipo_dato
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'health_centers'
ORDER BY ordinal_position;

-- 5. Ver columnas de la tabla batches (si existe)
SELECT
  'COLUMNAS batches' as tipo,
  column_name as nombre,
  data_type as tipo_dato
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'batches'
ORDER BY ordinal_position;

-- 6. Contar registros en tablas existentes
SELECT
  'CONTEO' as tipo,
  schemaname,
  tablename as nombre,
  n_live_tup as registros
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY tablename;
