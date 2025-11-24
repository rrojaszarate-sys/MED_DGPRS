-- ============================================
-- DIAGNÓSTICO COMPLETO DE BASE DE DATOS
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- 1. LISTAR TODAS LAS TABLAS
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_name = t.table_name AND c.table_schema = 'public') as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. VER ESTRUCTURA DE CADA TABLA (columnas y tipos)
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 3. CONTAR REGISTROS EN CADA TABLA
DO $$
DECLARE
    r RECORD;
    cnt INTEGER;
BEGIN
    RAISE NOTICE '========== CONTEO DE REGISTROS ==========';
    FOR r IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', r.table_name) INTO cnt;
        RAISE NOTICE 'Tabla: % - Registros: %', r.table_name, cnt;
    END LOOP;
END $$;

-- 4. VER POLÍTICAS RLS ACTIVAS
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 5. VER SI RLS ESTÁ HABILITADO EN CADA TABLA
SELECT
    relname as tabla,
    relrowsecurity as rls_habilitado,
    relforcerowsecurity as rls_forzado
FROM pg_class
WHERE relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
AND relkind = 'r'
ORDER BY relname;

-- 6. MUESTRA DE DATOS DE TABLAS QUE PODRÍAN TENER CATÁLOGO
-- (Ejecuta manualmente según lo que encuentres arriba)

-- Si existe catalogo_configuraciones:
-- SELECT * FROM catalogo_configuraciones LIMIT 10;

-- Si existe medication_catalog:
-- SELECT * FROM medication_catalog LIMIT 10;

-- Si existe medications:
-- SELECT * FROM medications LIMIT 10;

-- 7. BUSCAR TABLAS QUE CONTENGAN "catalog" O "medicamento" EN EL NOMBRE
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND (
    table_name ILIKE '%catalog%'
    OR table_name ILIKE '%medicamento%'
    OR table_name ILIKE '%medicine%'
    OR table_name ILIKE '%drug%'
    OR table_name ILIKE '%config%'
);
