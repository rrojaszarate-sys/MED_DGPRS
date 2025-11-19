-- =====================================================
-- SCRIPT DE VERIFICACIÓN DE ESTRUCTURA DE BASE DE DATOS
-- =====================================================
-- Este script extrae TODA la estructura de la BD para documentación
-- Formatea los resultados en Markdown para fácil lectura
-- Usa tabla temporal para concatenar todos los resultados
-- =====================================================

BEGIN;

-- Crear tabla temporal para acumular resultados
CREATE TEMP TABLE IF NOT EXISTS temp_output (
  orden INTEGER,
  linea TEXT
);

-- Encabezado principal
INSERT INTO temp_output VALUES (1, '# ESTRUCTURA DE BASE DE DATOS - SIGIMED v2.0');
INSERT INTO temp_output VALUES (2, '');
INSERT INTO temp_output VALUES (3, '## 1. TABLAS Y COLUMNAS');
INSERT INTO temp_output VALUES (4, '');

-- Tabla: instituciones
INSERT INTO temp_output VALUES (10, '### Tabla: **instituciones**');
INSERT INTO temp_output VALUES (11, '');
INSERT INTO temp_output VALUES (12, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (13, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 14 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'instituciones' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Tabla: centros_salud
INSERT INTO temp_output VALUES (100, '');
INSERT INTO temp_output VALUES (101, '### Tabla: **centros_salud**');
INSERT INTO temp_output VALUES (102, '');
INSERT INTO temp_output VALUES (103, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (104, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 105 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'centros_salud' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Tabla: catalogo_medicamentos
INSERT INTO temp_output VALUES (200, '');
INSERT INTO temp_output VALUES (201, '### Tabla: **catalogo_medicamentos**');
INSERT INTO temp_output VALUES (202, '');
INSERT INTO temp_output VALUES (203, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (204, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 205 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'catalogo_medicamentos' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Tabla: proveedores
INSERT INTO temp_output VALUES (300, '');
INSERT INTO temp_output VALUES (301, '### Tabla: **proveedores**');
INSERT INTO temp_output VALUES (302, '');
INSERT INTO temp_output VALUES (303, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (304, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 305 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'proveedores' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Tabla: medicamentos
INSERT INTO temp_output VALUES (400, '');
INSERT INTO temp_output VALUES (401, '### Tabla: **medicamentos**');
INSERT INTO temp_output VALUES (402, '');
INSERT INTO temp_output VALUES (403, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (404, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 405 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'medicamentos' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Tabla: lotes
INSERT INTO temp_output VALUES (500, '');
INSERT INTO temp_output VALUES (501, '### Tabla: **lotes**');
INSERT INTO temp_output VALUES (502, '');
INSERT INTO temp_output VALUES (503, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (504, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 505 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'lotes' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Tabla: movimientos_lotes
INSERT INTO temp_output VALUES (600, '');
INSERT INTO temp_output VALUES (601, '### Tabla: **movimientos_lotes**');
INSERT INTO temp_output VALUES (602, '');
INSERT INTO temp_output VALUES (603, '| Columna | Tipo | Nullable | Default |');
INSERT INTO temp_output VALUES (604, '|---------|------|----------|---------|');
INSERT INTO temp_output
SELECT 605 + ROW_NUMBER() OVER () as orden,
  '| ' || column_name || ' | ' || data_type ||
  CASE WHEN character_maximum_length IS NOT NULL THEN '(' || character_maximum_length || ')' ELSE '' END ||
  ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' |'
FROM information_schema.columns
WHERE table_name = 'movimientos_lotes' AND table_schema = 'public'
ORDER BY ordinal_position;

-- CHECK CONSTRAINTS
INSERT INTO temp_output VALUES (700, '');
INSERT INTO temp_output VALUES (701, '---');
INSERT INTO temp_output VALUES (702, '');
INSERT INTO temp_output VALUES (703, '## 2. CHECK CONSTRAINTS');
INSERT INTO temp_output VALUES (704, '');
INSERT INTO temp_output
SELECT 705 + ROW_NUMBER() OVER () as orden,
  '- **' || tc.table_name || '.' || tc.constraint_name || '**: `' || pg_get_constraintdef(c.oid) || '`'
FROM information_schema.table_constraints tc
JOIN pg_constraint c ON c.conname = tc.constraint_name
WHERE tc.constraint_type = 'CHECK'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes', 'proveedores')
ORDER BY tc.table_name, tc.constraint_name;

-- UNIQUE CONSTRAINTS
INSERT INTO temp_output VALUES (800, '');
INSERT INTO temp_output VALUES (801, '---');
INSERT INTO temp_output VALUES (802, '');
INSERT INTO temp_output VALUES (803, '## 3. UNIQUE CONSTRAINTS');
INSERT INTO temp_output VALUES (804, '');
INSERT INTO temp_output
SELECT 805 + ROW_NUMBER() OVER () as orden,
  '- **' || tc.table_name || '**: `' || tc.constraint_name || '`'
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'UNIQUE'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes', 'proveedores', 'instituciones', 'centros_salud')
ORDER BY tc.table_name;

-- FOREIGN KEYS
INSERT INTO temp_output VALUES (900, '');
INSERT INTO temp_output VALUES (901, '---');
INSERT INTO temp_output VALUES (902, '');
INSERT INTO temp_output VALUES (903, '## 4. FOREIGN KEYS');
INSERT INTO temp_output VALUES (904, '');
INSERT INTO temp_output
SELECT 905 + ROW_NUMBER() OVER () as orden,
  '- **' || tc.table_name || '.' || kcu.column_name || '** → ' || ccu.table_name || '.' || ccu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes', 'centros_salud')
ORDER BY tc.table_name, kcu.column_name;

-- VIEWS
INSERT INTO temp_output VALUES (1000, '');
INSERT INTO temp_output VALUES (1001, '---');
INSERT INTO temp_output VALUES (1002, '');
INSERT INTO temp_output VALUES (1003, '## 5. VISTAS (VIEWS)');
INSERT INTO temp_output VALUES (1004, '');
INSERT INTO temp_output
SELECT 1005 + ROW_NUMBER() OVER () as orden,
  '- `' || table_name || '`'
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- CONTEO DE REGISTROS
INSERT INTO temp_output VALUES (1100, '');
INSERT INTO temp_output VALUES (1101, '---');
INSERT INTO temp_output VALUES (1102, '');
INSERT INTO temp_output VALUES (1103, '## 6. CONTEO DE REGISTROS ACTUAL');
INSERT INTO temp_output VALUES (1104, '');
INSERT INTO temp_output VALUES (1105, '| Tabla | Total Registros | Registros Activos |');
INSERT INTO temp_output VALUES (1106, '|-------|----------------|-------------------|');

INSERT INTO temp_output
SELECT 1107, '| instituciones | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |'
FROM instituciones;

INSERT INTO temp_output
SELECT 1108, '| centros_salud | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |'
FROM centros_salud;

INSERT INTO temp_output
SELECT 1109, '| catalogo_medicamentos | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |'
FROM catalogo_medicamentos;

INSERT INTO temp_output
SELECT 1110, '| proveedores | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |'
FROM proveedores;

INSERT INTO temp_output
SELECT 1111, '| medicamentos | ' || COUNT(*)::text || ' | - |'
FROM medicamentos;

INSERT INTO temp_output
SELECT 1112, '| lotes | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |'
FROM lotes;

INSERT INTO temp_output
SELECT 1113, '| movimientos_lotes | ' || COUNT(*)::text || ' | - |'
FROM movimientos_lotes;

-- DATOS MAESTROS
INSERT INTO temp_output VALUES (1200, '');
INSERT INTO temp_output VALUES (1201, '---');
INSERT INTO temp_output VALUES (1202, '');
INSERT INTO temp_output VALUES (1203, '## 7. DATOS MAESTROS (CATÁLOGOS)');
INSERT INTO temp_output VALUES (1204, '');
INSERT INTO temp_output VALUES (1205, '### Instituciones activas:');
INSERT INTO temp_output VALUES (1206, '');

INSERT INTO temp_output
SELECT 1207 + ROW_NUMBER() OVER () as orden,
  '- ' || name || ' (' || tipo || ')'
FROM instituciones
WHERE is_active = true
ORDER BY name
LIMIT 5;

INSERT INTO temp_output VALUES (1220, '');
INSERT INTO temp_output VALUES (1221, '### Centros de Salud activos (primeros 5):');
INSERT INTO temp_output VALUES (1222, '');

INSERT INTO temp_output
SELECT 1223 + ROW_NUMBER() OVER () as orden,
  '- ' || name || ' [' || code || '] - ' || ciudad || ', ' || estado
FROM centros_salud
WHERE is_active = true
ORDER BY name
LIMIT 5;

INSERT INTO temp_output VALUES (1240, '');
INSERT INTO temp_output VALUES (1241, '### Medicamentos en catálogo (primeros 5):');
INSERT INTO temp_output VALUES (1242, '');

INSERT INTO temp_output
SELECT 1243 + ROW_NUMBER() OVER () as orden,
  '- ' || nombre || ' | ' || COALESCE(nombre_generico, 'N/A') || ' | ' || presentacion
FROM catalogo_medicamentos
WHERE is_active = true
ORDER BY nombre
LIMIT 5;

-- Footer
INSERT INTO temp_output VALUES (9000, '');
INSERT INTO temp_output VALUES (9001, '---');
INSERT INTO temp_output VALUES (9002, '');
INSERT INTO temp_output VALUES (9003, '**Fecha de generación:** ' || NOW()::text);
INSERT INTO temp_output VALUES (9004, '');
INSERT INTO temp_output VALUES (9005, '**Base de datos:** Supabase PostgreSQL');
INSERT INTO temp_output VALUES (9006, '**Sistema:** SIGIMED v2.0');

COMMIT;

-- Mostrar TODO el resultado ordenado
SELECT linea as "ESTRUCTURA_BD_MARKDOWN"
FROM temp_output
ORDER BY orden;

-- Limpiar
DROP TABLE temp_output;
