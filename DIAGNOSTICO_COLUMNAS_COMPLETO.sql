-- ============================================
-- DIAGNÓSTICO COMPLETO DE COLUMNAS
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- 1. Columnas de la tabla LOTES
SELECT
  'LOTES' as tabla,
  column_name as columna,
  data_type as tipo
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'lotes'
ORDER BY ordinal_position;

-- 2. Columnas de la tabla MEDICAMENTOS
SELECT
  'MEDICAMENTOS' as tabla,
  column_name as columna,
  data_type as tipo
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'medicamentos'
ORDER BY ordinal_position;

-- 3. Columnas de la tabla CENTROS_SALUD
SELECT
  'CENTROS_SALUD' as tabla,
  column_name as columna,
  data_type as tipo
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'centros_salud'
ORDER BY ordinal_position;

-- 4. Columnas de la tabla PROVEEDORES
SELECT
  'PROVEEDORES' as tabla,
  column_name as columna,
  data_type as tipo
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'proveedores'
ORDER BY ordinal_position;

-- 5. Columnas de la tabla MOVIMIENTOS_LOTES
SELECT
  'MOVIMIENTOS_LOTES' as tabla,
  column_name as columna,
  data_type as tipo
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'movimientos_lotes'
ORDER BY ordinal_position;

-- 6. Ver todas las tablas públicas
SELECT
  table_name as tabla
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
