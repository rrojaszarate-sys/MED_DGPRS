-- ============================================
-- CORRECCIÓN CRÍTICA: POLÍTICAS RLS PARA MEDICATION_CATALOG
-- ============================================
-- Fecha: 2025-11-10
-- Propósito: Agregar políticas RLS faltantes que bloquean creación de medicamentos
-- ERROR: La tabla medication_catalog tiene RLS habilitado pero sin políticas
-- RESULTADO: Nadie puede INSERT/UPDATE/DELETE en la tabla

BEGIN;

-- Verificar que RLS está habilitado (debe estar habilitado)
SELECT
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medication_catalog';

-- ============================================
-- RLS: MEDICATION_CATALOG
-- ============================================

-- Política SELECT: Todos pueden ver el catálogo
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (true); -- Todos pueden ver el catálogo de medicamentos

-- Política INSERT: Solo super_admin y quienes tienen permiso
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('medications', 'create')
  );

-- Política UPDATE: Solo super_admin
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('medications', 'update')
  );

-- Política DELETE: Solo super_admin
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (is_super_admin());

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Mostrar políticas creadas
SELECT
  schemaname,
  tablename,
  policyname,
  cmd as operacion,
  qual as using_expression,
  with_check as with_check_expression
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY cmd;

-- Mensaje de éxito
SELECT
  '✅ CORRECCIÓN APLICADA' as resultado,
  'Políticas RLS creadas para medication_catalog' as detalle,
  count(*) as politicas_creadas
FROM pg_policies
WHERE tablename = 'medication_catalog';

-- ============================================
-- PRUEBA RÁPIDA (ejecutar como usuario super_admin)
-- ============================================

-- Intentar insertar medicamento de prueba
-- NOTA: Descomentar solo si quieres probar inmediatamente

/*
INSERT INTO medication_catalog (
  codigo_medicamento,
  nombre_generico,
  nombre_comercial,
  principio_activo,
  concentracion,
  forma_farmaceutica,
  via_administracion,
  unidad_medida,
  categoria,
  requiere_receta,
  controlado,
  temperatura_almacenamiento,
  observaciones,
  is_active
) VALUES (
  'TEST-001',
  'Medicamento de Prueba',
  'PruebaFarm',
  'Principio Activo Test',
  '500mg',
  'Tableta',
  'Oral',
  'Tableta',
  'Test',
  false,
  false,
  '15-25°C',
  'Medicamento de prueba para verificar políticas RLS',
  true
) RETURNING id, codigo_medicamento, nombre_generico, created_at;

-- Si el INSERT funciona, eliminar el medicamento de prueba
DELETE FROM medication_catalog WHERE codigo_medicamento = 'TEST-001';
*/

-- ============================================
-- NOTAS IMPORTANTES
-- ============================================

-- 1. Este script debe ejecutarse en Supabase SQL Editor
-- 2. Las funciones is_super_admin() y has_permission() deben existir previamente
-- 3. Si las funciones no existen, ejecutar primero: 04_sistema_permisos_rls.sql
-- 4. Después de aplicar, probar en la UI: /admin → "Agregar Medicamento al Catálogo"

SELECT
  '⚠️ PRÓXIMOS PASOS' as titulo,
  '1. Ejecutar este script en Supabase SQL Editor' as paso_1,
  '2. Verificar que aparecen 4 políticas (SELECT, INSERT, UPDATE, DELETE)' as paso_2,
  '3. Probar crear medicamento en /admin' as paso_3,
  '4. Si falla, verificar que usuario tiene rol super_admin en tabla user_roles' as paso_4;
