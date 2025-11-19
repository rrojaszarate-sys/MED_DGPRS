-- =====================================================
-- SCRIPT DE VERIFICACIÓN DE ESTRUCTURA DE BASE DE DATOS
-- =====================================================
-- Este script extrae TODA la estructura de la BD para documentación
-- Formatea los resultados en Markdown para fácil lectura
-- =====================================================

-- TABLAS Y COLUMNAS
SELECT '# ESTRUCTURA DE BASE DE DATOS - SIGIMED v2.0' as markdown
UNION ALL SELECT ''
UNION ALL SELECT '## 1. TABLAS Y COLUMNAS'
UNION ALL SELECT ''
UNION ALL SELECT '### Tabla: **instituciones**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'instituciones' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT ''
UNION ALL SELECT '### Tabla: **centros_salud**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'centros_salud' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT ''
UNION ALL SELECT '### Tabla: **catalogo_medicamentos**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'catalogo_medicamentos' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT ''
UNION ALL SELECT '### Tabla: **proveedores**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'proveedores' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT ''
UNION ALL SELECT '### Tabla: **medicamentos**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'medicamentos' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT ''
UNION ALL SELECT '### Tabla: **lotes**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'lotes' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT ''
UNION ALL SELECT '### Tabla: **movimientos_lotes**'
UNION ALL
SELECT '| Columna | Tipo | Nullable | Default | Descripción |'
UNION ALL
SELECT '|---------|------|----------|---------|-------------|'
UNION ALL
SELECT '| ' || column_name || ' | ' || data_type || ' | ' || is_nullable || ' | ' || COALESCE(column_default, '-') || ' | |'
FROM information_schema.columns
WHERE table_name = 'movimientos_lotes' AND table_schema = 'public'
ORDER BY ordinal_position;

-- CHECK CONSTRAINTS
SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '## 2. CHECK CONSTRAINTS'
UNION ALL SELECT ''
UNION ALL
SELECT '### Tabla: **' || tc.table_name || '**'
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'CHECK'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes', 'proveedores')
GROUP BY tc.table_name
ORDER BY tc.table_name;

SELECT '- `' || tc.constraint_name || '`: ' || pg_get_constraintdef(c.oid)
FROM information_schema.table_constraints tc
JOIN pg_constraint c ON c.conname = tc.constraint_name
WHERE tc.constraint_type = 'CHECK'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes', 'proveedores')
ORDER BY tc.table_name, tc.constraint_name;

-- UNIQUE CONSTRAINTS
SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '## 3. UNIQUE CONSTRAINTS'
UNION ALL SELECT ''
UNION ALL
SELECT '- **' || tc.table_name || '**: `' || tc.constraint_name || '`'
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'UNIQUE'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes', 'proveedores')
ORDER BY tc.table_name;

-- FOREIGN KEYS
SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '## 4. FOREIGN KEYS'
UNION ALL SELECT ''
UNION ALL
SELECT '- **' || tc.table_name || '.' || kcu.column_name || '** → ' || ccu.table_name || '.' || ccu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('medicamentos', 'lotes', 'movimientos_lotes')
ORDER BY tc.table_name, kcu.column_name;

-- VIEWS
SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '## 5. VISTAS (VIEWS)'
UNION ALL SELECT ''
UNION ALL
SELECT '### Vista: **' || table_name || '**'
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN ('health_centers', 'suppliers', 'medications', 'batches', 'batch_movements')
ORDER BY table_name;

-- CONTEO DE REGISTROS
SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '## 6. CONTEO DE REGISTROS ACTUAL'
UNION ALL SELECT ''
UNION ALL SELECT '| Tabla | Total Registros | Registros Activos |'
UNION ALL SELECT '|-------|----------------|-------------------|';

SELECT '| instituciones | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |' FROM instituciones
UNION ALL
SELECT '| centros_salud | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |' FROM centros_salud
UNION ALL
SELECT '| catalogo_medicamentos | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |' FROM catalogo_medicamentos
UNION ALL
SELECT '| proveedores | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |' FROM proveedores
UNION ALL
SELECT '| medicamentos | ' || COUNT(*)::text || ' | - |' FROM medicamentos
UNION ALL
SELECT '| lotes | ' || COUNT(*)::text || ' | ' || COUNT(*) FILTER (WHERE is_active = true)::text || ' |' FROM lotes
UNION ALL
SELECT '| movimientos_lotes | ' || COUNT(*)::text || ' | - |' FROM movimientos_lotes;

SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '## 7. DATOS MAESTROS (CATÁLOGOS)'
UNION ALL SELECT ''
UNION ALL SELECT '### Instituciones activas:'
UNION ALL SELECT '```';

SELECT '- ' || name || ' (' || tipo || ')'
FROM instituciones
WHERE is_active = true
ORDER BY name
LIMIT 10;

SELECT '```'
UNION ALL SELECT ''
UNION ALL SELECT '### Centros de Salud activos (primeros 10):'
UNION ALL SELECT '```';

SELECT '- ' || name || ' [' || code || '] - ' || ciudad || ', ' || estado
FROM centros_salud
WHERE is_active = true
ORDER BY name
LIMIT 10;

SELECT '```'
UNION ALL SELECT ''
UNION ALL SELECT '### Medicamentos en catálogo (primeros 10):'
UNION ALL SELECT '```';

SELECT '- ' || nombre || ' | ' || COALESCE(nombre_generico, 'N/A') || ' | ' || presentacion
FROM catalogo_medicamentos
WHERE is_active = true
ORDER BY nombre
LIMIT 10;

SELECT '```'
UNION ALL SELECT ''
UNION ALL SELECT '---'
UNION ALL SELECT ''
UNION ALL SELECT '**Fecha de generación:** ' || NOW()::text
UNION ALL SELECT ''
UNION ALL SELECT '**Base de datos:** Supabase PostgreSQL'
UNION ALL SELECT '**Sistema:** SIGIMED v2.0';
