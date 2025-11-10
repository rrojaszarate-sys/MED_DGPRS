-- ============================================
-- SCRIPT DE CORRECCIÓN CRÍTICA - SIGIMED v2.0
-- ============================================
-- Fecha: 2025-11-10
-- Autor: Claude Code
-- Propósito: Corregir errores bloqueantes en creación de medicamentos y lotes
--
-- ERRORES CORREGIDOS:
--   ERROR #1: medication_catalog tiene RLS habilitado pero SIN políticas → Nadie puede INSERT/UPDATE/DELETE
--   ERROR #2: Falta verificar que tabla batches y medications tienen schema correcto
--
-- EJECUCIÓN: Copiar y pegar en Supabase SQL Editor → Run
--
-- ============================================

\echo '🔍 INICIANDO DIAGNÓSTICO...'

-- ============================================
-- SECCIÓN 1: DIAGNÓSTICO PREVIO
-- ============================================

\echo '
======================================
📊 SECCIÓN 1: DIAGNÓSTICO DEL SISTEMA
======================================
'

-- 1.1 Verificar que las tablas existen
SELECT
  '✅ Tablas existentes' as estado,
  table_name,
  CASE
    WHEN table_name IN ('medication_catalog', 'medications', 'batches', 'health_centers', 'suppliers')
    THEN '✓ OK'
    ELSE '✗ FALTA'
  END as verificacion
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('medication_catalog', 'medications', 'batches', 'health_centers', 'suppliers', 'user_roles', 'permissions')
ORDER BY table_name;

-- 1.2 Verificar RLS habilitado
\echo '
📋 Estado de RLS por tabla:
'
SELECT
  schemaname,
  tablename,
  CASE rowsecurity
    WHEN true THEN '🔒 HABILITADO'
    ELSE '🔓 DESHABILITADO'
  END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('medication_catalog', 'medications', 'batches')
ORDER BY tablename;

-- 1.3 Contar políticas RLS existentes
\echo '
🛡️ Políticas RLS existentes:
'
SELECT
  tablename,
  count(*) as politicas_count,
  string_agg(policyname, ', ') as nombres_politicas
FROM pg_policies
WHERE tablename IN ('medication_catalog', 'medications', 'batches')
GROUP BY tablename
ORDER BY tablename;

-- 1.4 Verificar funciones helper de RLS
\echo '
⚙️ Funciones RLS helper:
'
SELECT
  proname as funcion,
  CASE
    WHEN proname IN ('is_super_admin', 'has_permission', 'get_user_role', 'has_center_access')
    THEN '✓ EXISTE'
    ELSE '✗ NO ENCONTRADA'
  END as estado
FROM pg_proc
WHERE proname IN ('is_super_admin', 'has_permission', 'get_user_role', 'has_center_access', 'get_user_centers')
ORDER BY proname;

-- 1.5 Verificar columnas de medication_catalog
\echo '
📋 Columnas de medication_catalog:
'
SELECT
  column_name,
  data_type,
  CASE is_nullable WHEN 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'medication_catalog'
ORDER BY ordinal_position;

-- 1.6 Verificar columnas de batches
\echo '
📦 Columnas de batches:
'
SELECT
  column_name,
  data_type,
  CASE is_nullable WHEN 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'batches'
ORDER BY ordinal_position;

-- ============================================
-- SECCIÓN 2: APLICAR CORRECCIONES
-- ============================================

\echo '
=======================================
🔧 SECCIÓN 2: APLICANDO CORRECCIONES
=======================================
'

BEGIN;

-- 2.1 CREAR POLÍTICAS RLS PARA MEDICATION_CATALOG
\echo '
🛡️ Creando políticas RLS para medication_catalog...
'

-- Política SELECT: Todos pueden ver el catálogo
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (true); -- Todos pueden ver el catálogo

\echo '  ✓ Política SELECT creada'

-- Política INSERT: Solo super_admin y quienes tienen permiso
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('medications', 'create')
  );

\echo '  ✓ Política INSERT creada'

-- Política UPDATE: Solo super_admin y quienes tienen permiso
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('medications', 'update')
  );

\echo '  ✓ Política UPDATE creada'

-- Política DELETE: Solo super_admin
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;
CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (is_super_admin());

\echo '  ✓ Política DELETE creada'

COMMIT;

-- ============================================
-- SECCIÓN 3: VERIFICACIÓN POST-CORRECCIÓN
-- ============================================

\echo '
========================================
✅ SECCIÓN 3: VERIFICACIÓN FINAL
========================================
'

-- 3.1 Mostrar políticas creadas
\echo '
🛡️ Políticas RLS de medication_catalog:
'
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

-- 3.2 Contar políticas por tabla
\echo '
📊 Resumen de políticas por tabla:
'
SELECT
  tablename,
  count(*) as total_politicas
FROM pg_policies
WHERE tablename IN ('medication_catalog', 'medications', 'batches')
GROUP BY tablename
ORDER BY tablename;

-- 3.3 Verificar estado final de RLS
\echo '
🔒 Estado final de RLS:
'
SELECT
  tablename,
  CASE rowsecurity
    WHEN true THEN '🔒 HABILITADO'
    ELSE '🔓 DESHABILITADO'
  END as rls_status,
  (SELECT count(*) FROM pg_policies p WHERE p.tablename = t.tablename) as politicas_count
FROM pg_tables t
WHERE schemaname = 'public'
  AND tablename IN ('medication_catalog', 'medications', 'batches')
ORDER BY tablename;

-- ============================================
-- SECCIÓN 4: PRUEBAS (OPCIONAL)
-- ============================================

\echo '
========================================
🧪 SECCIÓN 4: PRUEBAS OPCIONALES
========================================
'

\echo '
⚠️ Las siguientes pruebas están COMENTADAS.
   Descoméntalas solo si quieres probar inmediatamente.

-- PRUEBA 1: Insertar medicamento de prueba
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
  ''TEST-PRUEBA-001'',
  ''Medicamento de Prueba'',
  ''TestFarm'',
  ''Principio Activo Test'',
  ''500mg'',
  ''Tableta'',
  ''Oral'',
  ''Tableta'',
  ''Prueba'',
  false,
  false,
  ''15-25°C'',
  ''Medicamento de prueba para verificar políticas RLS - ELIMINAR DESPUÉS'',
  true
) RETURNING id, codigo_medicamento, nombre_generico, created_at;

\echo ''  ✓ Medicamento de prueba creado''

-- PRUEBA 2: Verificar que se puede leer
SELECT
  codigo_medicamento,
  nombre_generico,
  created_at
FROM medication_catalog
WHERE codigo_medicamento = ''TEST-PRUEBA-001'';

\echo ''  ✓ Medicamento de prueba leído''

-- PRUEBA 3: Eliminar medicamento de prueba
DELETE FROM medication_catalog WHERE codigo_medicamento = ''TEST-PRUEBA-001'';

\echo ''  ✓ Medicamento de prueba eliminado''
*/
'

-- ============================================
-- SECCIÓN 5: RESUMEN FINAL
-- ============================================

\echo '
========================================
📝 RESUMEN FINAL
========================================
'

SELECT
  '✅ CORRECCIÓN COMPLETADA' as resultado,
  'Políticas RLS creadas para medication_catalog' as detalle,
  (SELECT count(*) FROM pg_policies WHERE tablename = 'medication_catalog') as politicas_creadas,
  '4' as politicas_esperadas,
  CASE
    WHEN (SELECT count(*) FROM pg_policies WHERE tablename = 'medication_catalog') = 4
    THEN '✓ OK'
    ELSE '✗ VERIFICAR'
  END as estado;

\echo '
========================================
📋 PRÓXIMOS PASOS
========================================

1. ✓ Script ejecutado exitosamente
2. → Verificar que aparecen 4 políticas para medication_catalog
3. → Probar crear medicamento en /admin:
     - Ir a https://[tu-dominio]/admin
     - Click en "Agregar Medicamento al Catálogo"
     - Llenar formulario con datos de prueba
     - Click en "Agregar Medicamento"
     - Debería aparecer: "Medicamento agregado al catálogo"
4. → Si aún falla, verificar en consola del navegador (F12):
     - Ver logs: 📤 Intentando crear medicamento...
     - Ver error específico: ❌ Error de Supabase...
5. → Verificar rol del usuario:
     SELECT role_name FROM user_roles WHERE user_id = auth.uid();
     - Debe ser ''super_admin'' o tener permiso ''medications create''

========================================
🆘 SI PERSISTE EL ERROR
========================================

Si después de ejecutar este script aún no puedes crear medicamentos:

A) Verificar que usuario tiene rol super_admin:
   SELECT * FROM user_roles WHERE user_id = auth.uid();

B) Si no tiene rol, asignar temporalmente:
   INSERT INTO user_roles (user_id, role_name, is_active)
   VALUES (auth.uid(), ''super_admin'', true)
   ON CONFLICT DO NOTHING;

C) Verificar que auth.uid() retorna un valor:
   SELECT auth.uid() as mi_user_id;

D) Si auth.uid() es NULL, problema de autenticación:
   - Cerrar sesión y volver a iniciar
   - Verificar JWT token en localStorage
   - Revisar configuración de Supabase Auth

========================================
'

-- FIN DEL SCRIPT
