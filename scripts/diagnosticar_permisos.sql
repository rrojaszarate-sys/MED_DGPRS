-- ================================================
-- DIAGNÓSTICO DE PERMISOS Y VISIBILIDAD
-- Sistema: SIGIMED v2.0
-- ================================================
-- Ejecutar en Supabase SQL Editor
-- ================================================

-- 1. VER TU USUARIO Y ROL ACTUAL
SELECT '=== TU USUARIO ACTUAL ===' as seccion;

SELECT
  id,
  email,
  nombre_completo,
  rol,
  is_active,
  centro_id
FROM users_profiles
WHERE email = auth.email()
LIMIT 1;

-- 2. VER TODOS LOS USUARIOS Y SUS ROLES
SELECT '=== TODOS LOS USUARIOS ===' as seccion;

SELECT
  email,
  nombre_completo,
  rol,
  is_active,
  centro_id,
  created_at
FROM users_profiles
ORDER BY created_at DESC;

-- 3. VERIFICAR DATOS DE CATÁLOGOS (sin RLS)
SELECT '=== CATÁLOGOS (bypass RLS) ===' as seccion;

-- Desactivar temporalmente RLS para verificar datos
SET LOCAL role TO postgres;

SELECT
  'catalogo_colores' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE es_activo = true) as activos
FROM catalogo_colores

UNION ALL

SELECT
  'catalogo_estados' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE es_activo = true) as activos
FROM catalogo_estados

UNION ALL

SELECT
  'catalogo_tipos_movimiento' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE es_activo = true) as activos
FROM catalogo_tipos_movimiento;

-- Resetear role
RESET role;

-- 4. VERIFICAR POLÍTICAS RLS
SELECT '=== POLÍTICAS RLS ACTIVAS ===' as seccion;

SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename LIKE 'catalogo_%'
ORDER BY tablename, policyname;

-- 5. VERIFICAR MEDICAMENTOS E INVENTARIO
SELECT '=== INVENTARIO (bypass RLS) ===' as seccion;

SET LOCAL role TO postgres;

SELECT
  'medications' as tabla,
  COUNT(*) as total
FROM medications

UNION ALL

SELECT
  'batches' as tabla,
  COUNT(*) as total
FROM batches

UNION ALL

SELECT
  'batch_movements' as tabla,
  COUNT(*) as total
FROM batch_movements;

RESET role;

-- 6. VERIFICAR CENTROS DE SALUD
SELECT '=== CENTROS DE SALUD ===' as seccion;

SELECT
  id,
  name,
  code,
  is_active
FROM health_centers
ORDER BY name;

-- 7. VERIFICAR INSTITUCIONES
SELECT '=== INSTITUCIONES ===' as seccion;

SELECT
  id,
  nombre,
  clave,
  tipo
FROM instituciones
ORDER BY nombre;

-- 8. PRUEBA DE ACCESO COMO USUARIO ACTUAL
SELECT '=== PRUEBA DE ACCESO CON TU USUARIO ===' as seccion;

-- Esto usará RLS normal
SELECT
  COUNT(*) as catálogos_visibles
FROM catalogo_colores
WHERE es_activo = true;

-- 9. VERIFICAR SI auth.uid() FUNCIONA
SELECT '=== VERIFICACIÓN AUTH ===' as seccion;

SELECT
  auth.uid() as tu_user_id,
  auth.email() as tu_email,
  auth.role() as tu_auth_role,
  current_user as current_db_user;

-- 10. DIAGNÓSTICO FINAL
SELECT '=== DIAGNÓSTICO ===' as seccion;

SELECT
  CASE
    WHEN auth.uid() IS NULL THEN '❌ NO AUTENTICADO - Debes estar logueado'
    WHEN NOT EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid()) THEN '❌ PERFIL NO EXISTE - Falta registro en users_profiles'
    WHEN (SELECT rol FROM users_profiles WHERE id = auth.uid()) NOT IN ('super_admin', 'admin_center') THEN '❌ ROL INSUFICIENTE - Necesitas ser super_admin o admin_center'
    WHEN (SELECT is_active FROM users_profiles WHERE id = auth.uid()) = false THEN '❌ USUARIO INACTIVO'
    ELSE '✅ TODO OK - Deberías poder ver los catálogos'
  END as diagnostico;
