-- ================================================
-- DIAGNÓSTICO COMPLETO DE ESTRUCTURA
-- ================================================
-- Ver qué columnas REALMENTE existen en cada tabla
-- ================================================

-- CENTROS_SALUD
SELECT '=== COLUMNAS DE centros_salud ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'centros_salud'
ORDER BY ordinal_position;

-- MEDICAMENTOS
SELECT '=== COLUMNAS DE medicamentos ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'medicamentos'
ORDER BY ordinal_position;

-- LOTES
SELECT '=== COLUMNAS DE lotes ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'lotes'
ORDER BY ordinal_position;

-- MOVIMIENTOS_LOTES
SELECT '=== COLUMNAS DE movimientos_lotes ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'movimientos_lotes'
ORDER BY ordinal_position;

-- PROVEEDORES
SELECT '=== COLUMNAS DE proveedores ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'proveedores'
ORDER BY ordinal_position;

-- CATALOGO_MEDICAMENTOS
SELECT '=== COLUMNAS DE catalogo_medicamentos ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'catalogo_medicamentos'
ORDER BY ordinal_position;

-- INSTITUCIONES
SELECT '=== COLUMNAS DE instituciones ===' as seccion;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'instituciones'
ORDER BY ordinal_position;

-- CONTEO DE DATOS
SELECT '=== CONTEO DE DATOS ACTUALES ===' as seccion;

SELECT 'centros_salud' as tabla, COUNT(*) as total FROM centros_salud
UNION ALL
SELECT 'medicamentos', COUNT(*) FROM medicamentos
UNION ALL
SELECT 'lotes', COUNT(*) FROM lotes
UNION ALL
SELECT 'movimientos_lotes', COUNT(*) FROM movimientos_lotes
UNION ALL
SELECT 'proveedores', COUNT(*) FROM proveedores
UNION ALL
SELECT 'catalogo_medicamentos', COUNT(*) FROM catalogo_medicamentos
UNION ALL
SELECT 'instituciones', COUNT(*) FROM instituciones;
