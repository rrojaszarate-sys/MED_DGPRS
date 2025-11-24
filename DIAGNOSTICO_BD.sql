-- ============================================
-- DIAGNÓSTICO COMPLETO DE BASE DE DATOS
-- Ejecutar en Supabase SQL Editor
-- TODO EN UN SOLO RESULTADO
-- ============================================

WITH
-- Tablas existentes
tablas AS (
    SELECT
        'TABLA' as tipo,
        table_name as nombre,
        '' as detalle,
        0 as orden
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
),
-- Conteo de registros por tabla
conteos AS (
    SELECT
        'CONTEO' as tipo,
        table_name as nombre,
        '' as detalle,
        1 as orden
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
),
-- Columnas de tablas relacionadas con medicamentos/catálogo
columnas_importantes AS (
    SELECT
        'COLUMNA' as tipo,
        table_name as nombre,
        column_name || ' (' || data_type || ')' as detalle,
        2 as orden
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND (
        table_name ILIKE '%catalog%'
        OR table_name ILIKE '%medicamento%'
        OR table_name ILIKE '%medication%'
        OR table_name ILIKE '%config%'
        OR table_name ILIKE '%drug%'
        OR table_name = 'medications'
        OR table_name = 'batches'
        OR table_name = 'health_centers'
        OR table_name = 'suppliers'
    )
),
-- RLS status
rls_status AS (
    SELECT
        'RLS' as tipo,
        relname as nombre,
        CASE WHEN relrowsecurity THEN 'HABILITADO' ELSE 'DESHABILITADO' END as detalle,
        3 as orden
    FROM pg_class
    WHERE relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    AND relkind = 'r'
),
-- Políticas RLS
politicas AS (
    SELECT
        'POLICY' as tipo,
        tablename as nombre,
        policyname || ' (' || cmd || ')' as detalle,
        4 as orden
    FROM pg_policies
    WHERE schemaname = 'public'
)

-- RESULTADO FINAL COMBINADO
SELECT tipo, nombre, detalle FROM tablas
UNION ALL
SELECT tipo, nombre, detalle FROM columnas_importantes
UNION ALL
SELECT tipo, nombre, detalle FROM rls_status
UNION ALL
SELECT tipo, nombre, detalle FROM politicas
ORDER BY tipo, nombre, detalle;
