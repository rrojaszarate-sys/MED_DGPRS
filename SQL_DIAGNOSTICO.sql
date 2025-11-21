-- ============================================
-- DIAGNÓSTICO Y CORRECCIÓN COMPLETA
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- PASO 1: Diagnóstico
DO $$
DECLARE
    v_table_exists BOOLEAN;
    v_count INTEGER;
    v_rls_enabled BOOLEAN;
    v_policy_count INTEGER;
    v_columns TEXT;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DIAGNÓSTICO DE medication_catalog';
    RAISE NOTICE '========================================';

    -- Verificar si la tabla existe
    SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'medication_catalog'
    ) INTO v_table_exists;
    RAISE NOTICE '1. Tabla existe: %', v_table_exists;

    IF NOT v_table_exists THEN
        RAISE NOTICE 'ERROR: La tabla medication_catalog NO EXISTE';
        RETURN;
    END IF;

    -- Contar registros
    EXECUTE 'SELECT COUNT(*) FROM medication_catalog' INTO v_count;
    RAISE NOTICE '2. Registros en tabla: %', v_count;

    -- Verificar RLS
    SELECT relrowsecurity INTO v_rls_enabled
    FROM pg_class WHERE relname = 'medication_catalog';
    RAISE NOTICE '3. RLS habilitado: %', v_rls_enabled;

    -- Contar políticas
    SELECT COUNT(*) INTO v_policy_count
    FROM pg_policies WHERE tablename = 'medication_catalog';
    RAISE NOTICE '4. Políticas RLS: %', v_policy_count;

    -- Listar columnas
    SELECT string_agg(column_name, ', ') INTO v_columns
    FROM information_schema.columns
    WHERE table_name = 'medication_catalog' AND table_schema = 'public';
    RAISE NOTICE '5. Columnas: %', v_columns;

    RAISE NOTICE '========================================';
END $$;

-- PASO 2: Ver políticas actuales
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'medication_catalog';

-- PASO 3: Ver primeros 5 registros (si hay)
SELECT id,
       COALESCE(codigo_medicamento, 'SIN CODIGO') as codigo,
       COALESCE(nombre_generico, nombre_comercial, 'SIN NOMBRE') as nombre,
       is_active
FROM medication_catalog
LIMIT 5;
