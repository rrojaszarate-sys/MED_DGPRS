-- ============================================
-- CORRECCIÓN CRÍTICA: POLÍTICAS RLS PARA MEDICATION_CATALOG
-- ============================================
-- Problema: Tabla con RLS habilitado pero SIN políticas
-- Resultado: Nadie puede INSERT/UPDATE/DELETE
-- Ejecutar en: Supabase SQL Editor
-- ============================================

-- ============================================
-- SECCIÓN 1: DIAGNÓSTICO PREVIO
-- ============================================

-- Verificar tablas existen
SELECT
  table_name,
  'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('medication_catalog', 'medications', 'batches', 'health_centers', 'suppliers', 'user_roles', 'permissions')
ORDER BY table_name;

-- Verificar RLS habilitado
SELECT
  tablename,
  CASE rowsecurity
    WHEN true THEN 'HABILITADO'
    ELSE 'DESHABILITADO'
  END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('medication_catalog', 'medications', 'batches')
ORDER BY tablename;

-- Contar políticas RLS existentes
SELECT
  tablename,
  count(*) as politicas_count
FROM pg_policies
WHERE tablename IN ('medication_catalog', 'medications', 'batches')
GROUP BY tablename
ORDER BY tablename;

-- Verificar funciones helper de RLS
SELECT
  proname as funcion,
  'EXISTE' as estado
FROM pg_proc
WHERE proname IN ('is_super_admin', 'has_permission', 'get_user_role', 'has_center_access')
ORDER BY proname;

-- Verificar columnas de medication_catalog
SELECT
  column_name,
  data_type,
  CASE is_nullable WHEN 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'medication_catalog'
ORDER BY ordinal_position;

-- ============================================
-- SECCIÓN 2: APLICAR CORRECCIONES
-- ============================================

BEGIN;

-- Eliminar políticas anteriores si existen
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;

-- Política SELECT: Todos pueden ver el catálogo
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (true);

-- Política INSERT: Solo super_admin y quienes tienen permiso
CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('medications', 'create')
  );

-- Política UPDATE: Solo super_admin y quienes tienen permiso
CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('medications', 'update')
  );

-- Política DELETE: Solo super_admin
CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (is_super_admin());

COMMIT;

-- ============================================
-- SECCIÓN 3: VERIFICACIÓN POST-CORRECCIÓN
-- ============================================

-- Mostrar políticas creadas
SELECT
  policyname,
  cmd as operacion,
  CASE
    WHEN qual IS NOT NULL THEN 'CON USING'
    ELSE 'SIN USING'
  END as tiene_using,
  CASE
    WHEN with_check IS NOT NULL THEN 'CON WITH CHECK'
    ELSE 'SIN WITH CHECK'
  END as tiene_check
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY cmd;

-- Contar políticas por tabla
SELECT
  tablename,
  count(*) as total_politicas
FROM pg_policies
WHERE tablename IN ('medication_catalog', 'medications', 'batches')
GROUP BY tablename
ORDER BY tablename;

-- Verificar estado final de RLS
SELECT
  tablename,
  CASE rowsecurity
    WHEN true THEN 'HABILITADO'
    ELSE 'DESHABILITADO'
  END as rls_status,
  (SELECT count(*) FROM pg_policies p WHERE p.tablename = t.tablename) as politicas_count
FROM pg_tables t
WHERE schemaname = 'public'
  AND tablename IN ('medication_catalog', 'medications', 'batches')
ORDER BY tablename;

-- ============================================
-- RESUMEN FINAL
-- ============================================

SELECT
  'CORRECCIÓN COMPLETADA' as resultado,
  'Políticas RLS creadas para medication_catalog' as detalle,
  (SELECT count(*) FROM pg_policies WHERE tablename = 'medication_catalog') as politicas_creadas,
  '4' as politicas_esperadas,
  CASE
    WHEN (SELECT count(*) FROM pg_policies WHERE tablename = 'medication_catalog') = 4
    THEN 'OK'
    ELSE 'VERIFICAR'
  END as estado;

-- ============================================
-- PRÓXIMOS PASOS:
-- 1. Verificar que aparecen 4 políticas
-- 2. Probar crear medicamento en /admin
-- 3. Verificar en consola (F12): logs 📤 → ✅
-- 4. Si falla, verificar rol: SELECT role_name FROM user_roles WHERE user_id = auth.uid();
-- ============================================

-- ============================================
-- SI PERSISTE EL ERROR - VERIFICAR:
-- ============================================
-- A) Usuario tiene rol super_admin:
--    SELECT * FROM user_roles WHERE user_id = auth.uid();
--
-- B) Si no tiene rol, asignar:
--    INSERT INTO user_roles (user_id, role_name, is_active)
--    VALUES (auth.uid(), 'super_admin', true);
--
-- C) Verificar auth.uid() retorna valor:
--    SELECT auth.uid() as mi_user_id;
-- ============================================
