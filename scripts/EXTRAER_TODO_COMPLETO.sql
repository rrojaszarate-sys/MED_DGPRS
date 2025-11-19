-- ================================================
-- EXTRACCIÓN COMPLETA DE TODA LA BASE DE DATOS
-- ================================================
-- Incluye: tablas, columnas, tipos, constraints, checks, defaults, vistas, datos
-- ================================================

-- PARTE 1: ESTRUCTURA DE TABLAS PRINCIPALES
SELECT
  '=== TABLA: ' || c.table_name || ' ===' as info,
  json_agg(
    json_build_object(
      'columna', c.column_name,
      'tipo', c.data_type,
      'nullable', c.is_nullable,
      'default', c.column_default,
      'posicion', c.ordinal_position
    ) ORDER BY c.ordinal_position
  )::text as estructura
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name IN (
    'centros_salud',
    'medicamentos',
    'lotes',
    'movimientos_lotes',
    'proveedores',
    'catalogo_medicamentos',
    'instituciones',
    'users_profiles'
  )
GROUP BY c.table_name

UNION ALL

-- PARTE 2: CHECK CONSTRAINTS
SELECT
  '=== CHECK CONSTRAINTS ===' as info,
  json_agg(
    json_build_object(
      'tabla', tc.table_name,
      'constraint', tc.constraint_name,
      'check', cc.check_clause
    )
  )::text as estructura
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name IN (
    'centros_salud',
    'medicamentos',
    'lotes',
    'movimientos_lotes',
    'proveedores'
  )

UNION ALL

-- PARTE 3: FOREIGN KEYS
SELECT
  '=== FOREIGN KEYS ===' as info,
  json_agg(
    json_build_object(
      'tabla', tc.table_name,
      'columna', kcu.column_name,
      'referencia_tabla', ccu.table_name,
      'referencia_columna', ccu.column_name
    )
  )::text as estructura
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN (
    'centros_salud',
    'medicamentos',
    'lotes',
    'movimientos_lotes'
  )

UNION ALL

-- PARTE 4: VISTAS EXISTENTES
SELECT
  '=== VISTAS EXISTENTES ===' as info,
  json_agg(table_name)::text as estructura
FROM information_schema.views
WHERE table_schema = 'public'

UNION ALL

-- PARTE 5: MUESTRA DE DATOS - medicamentos
SELECT
  '=== DATOS MUESTRA: medicamentos ===' as info,
  json_agg(
    json_build_object(
      'id', id,
      'center_id', center_id,
      'catalog_id', catalog_id,
      'nombre', nombre,
      'formula_activa', formula_activa,
      'lote', lote,
      'cantidad', cantidad,
      'estado', estado
    )
  )::text as estructura
FROM medicamentos
LIMIT 3

UNION ALL

-- PARTE 6: VALORES DISTINTOS DE ESTADO
SELECT
  '=== VALORES DE ESTADO EN medicamentos ===' as info,
  json_agg(DISTINCT estado)::text as estructura
FROM medicamentos

UNION ALL

-- PARTE 7: VALORES DISTINTOS DE ESTADO EN lotes
SELECT
  '=== VALORES DE ESTADO EN lotes ===' as info,
  json_agg(DISTINCT estado)::text as estructura
FROM lotes

UNION ALL

-- PARTE 8: CONTEO DE DATOS
SELECT
  '=== CONTEO DE REGISTROS ===' as info,
  json_build_object(
    'centros_salud', (SELECT COUNT(*) FROM centros_salud),
    'medicamentos', (SELECT COUNT(*) FROM medicamentos),
    'lotes', (SELECT COUNT(*) FROM lotes),
    'movimientos_lotes', (SELECT COUNT(*) FROM movimientos_lotes),
    'proveedores', (SELECT COUNT(*) FROM proveedores),
    'catalogo_medicamentos', (SELECT COUNT(*) FROM catalogo_medicamentos),
    'instituciones', (SELECT COUNT(*) FROM instituciones),
    'users_profiles', (SELECT COUNT(*) FROM users_profiles)
  )::text as estructura;
