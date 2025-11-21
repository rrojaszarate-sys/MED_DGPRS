-- ============================================
-- SOLUCIÓN INMEDIATA - EJECUTAR EN SUPABASE
-- ============================================
-- Copia TODO este contenido y pégalo en:
-- Supabase Dashboard → SQL Editor → Run
-- ============================================

-- PASO 1: Eliminar TODAS las políticas existentes de medication_catalog
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'medication_catalog'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON medication_catalog';
        RAISE NOTICE 'Eliminada política: %', pol.policyname;
    END LOOP;
END $$;

-- PASO 2: Crear políticas nuevas
-- SELECT para usuarios autenticados (TODOS pueden leer)
CREATE POLICY "medication_catalog_select_authenticated"
ON medication_catalog FOR SELECT
TO authenticated
USING (true);

-- SELECT para usuarios anónimos (solo activos)
CREATE POLICY "medication_catalog_select_anon"
ON medication_catalog FOR SELECT
TO anon
USING (is_active = true);

-- INSERT para administradores
CREATE POLICY "medication_catalog_insert_admin"
ON medication_catalog FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM users_profiles
        WHERE id = auth.uid()
        AND role IN ('super_admin', 'admin_center')
    )
);

-- UPDATE para administradores
CREATE POLICY "medication_catalog_update_admin"
ON medication_catalog FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users_profiles
        WHERE id = auth.uid()
        AND role IN ('super_admin', 'admin_center')
    )
);

-- DELETE para super_admin
CREATE POLICY "medication_catalog_delete_superadmin"
ON medication_catalog FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users_profiles
        WHERE id = auth.uid()
        AND role = 'super_admin'
    )
);

-- PASO 3: Asegurar que RLS está habilitado
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- PASO 4: IMPORTANTE - Forzar políticas para service role también
ALTER TABLE medication_catalog FORCE ROW LEVEL SECURITY;

-- PASO 5: Verificar resultado
DO $$
DECLARE
    v_count INTEGER;
    v_policy_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM medication_catalog;
    SELECT COUNT(*) INTO v_policy_count FROM pg_policies WHERE tablename = 'medication_catalog';

    RAISE NOTICE '========================================';
    RAISE NOTICE 'RESULTADO:';
    RAISE NOTICE 'Registros en medication_catalog: %', v_count;
    RAISE NOTICE 'Políticas creadas: %', v_policy_count;
    RAISE NOTICE '========================================';

    IF v_policy_count >= 5 THEN
        RAISE NOTICE 'ÉXITO: Las políticas se crearon correctamente';
    ELSE
        RAISE NOTICE 'ADVERTENCIA: Faltan políticas';
    END IF;
END $$;

-- PASO 6: Mostrar políticas creadas
SELECT policyname, cmd, roles
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY policyname;
