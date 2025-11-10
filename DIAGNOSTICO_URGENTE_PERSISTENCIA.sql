-- ============================================
-- DIAGNÓSTICO URGENTE - PERSISTENCIA DE DATOS
-- ============================================
-- Fecha: 2025-11-10
-- Problema: Medicamentos NO se guardan en Supabase
-- Causa: Scripts SQL de corrección NO ejecutados en producción
--
-- EJECUTAR EN SUPABASE SQL EDITOR DE PRODUCCIÓN
-- ============================================

\echo '🔍 INICIANDO DIAGNÓSTICO DE PERSISTENCIA...'

-- ============================================
-- SECCIÓN 1: VERIFICAR POLÍTICAS RLS
-- ============================================

\echo '
========================================
📋 DIAGNÓSTICO 1: Políticas RLS
========================================
'

-- Verificar que medication_catalog tiene RLS habilitado
SELECT
  '1. Estado de RLS en medication_catalog:' as prueba,
  tablename,
  CASE rowsecurity
    WHEN true THEN '🔒 HABILITADO (puede causar bloqueo si no hay políticas)'
    ELSE '🔓 DESHABILITADO'
  END as estado_rls
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medication_catalog';

-- Contar políticas existentes
SELECT
  '2. Políticas RLS existentes:' as prueba,
  COALESCE(count(*), 0) as politicas_count,
  CASE
    WHEN count(*) = 0 THEN '❌ CRÍTICO: Sin políticas, INSERT bloqueado'
    WHEN count(*) < 4 THEN '⚠️ ADVERTENCIA: Faltan políticas'
    ELSE '✅ OK: Políticas completas'
  END as diagnostico
FROM pg_policies
WHERE tablename = 'medication_catalog';

-- Listar políticas específicas
SELECT
  '3. Detalle de políticas:' as prueba,
  policyname,
  cmd as operacion
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY cmd;

-- ============================================
-- SECCIÓN 2: VERIFICAR FUNCIONES HELPER
-- ============================================

\echo '
========================================
📋 DIAGNÓSTICO 2: Funciones Helper RLS
========================================
'

-- Verificar funciones críticas existen
SELECT
  '4. Funciones helper de RLS:' as prueba,
  string_agg(proname, ', ') as funciones_encontradas,
  CASE
    WHEN count(*) = 0 THEN '❌ CRÍTICO: Funciones no existen, políticas RLS fallarán'
    WHEN count(*) < 4 THEN '⚠️ ADVERTENCIA: Faltan funciones'
    ELSE '✅ OK: Funciones completas'
  END as diagnostico
FROM pg_proc
WHERE proname IN ('is_super_admin', 'has_permission', 'get_user_role', 'has_center_access');

-- ============================================
-- SECCIÓN 3: VERIFICAR ROLES DE USUARIO
-- ============================================

\echo '
========================================
📋 DIAGNÓSTICO 3: Roles de Usuario
========================================
'

-- Verificar usuario actual
SELECT
  '5. Usuario autenticado:' as prueba,
  auth.uid() as user_id,
  CASE
    WHEN auth.uid() IS NULL THEN '❌ CRÍTICO: Sin autenticación'
    ELSE '✅ OK: Autenticado'
  END as diagnostico;

-- Verificar roles asignados
SELECT
  '6. Roles del usuario:' as prueba,
  COALESCE(count(*), 0) as roles_count,
  string_agg(role_name, ', ') as roles,
  CASE
    WHEN count(*) = 0 THEN '❌ CRÍTICO: Usuario sin rol, INSERT será bloqueado'
    ELSE '✅ OK: Usuario tiene rol'
  END as diagnostico
FROM user_roles
WHERE user_id = auth.uid()
  AND is_active = true;

-- ============================================
-- SECCIÓN 4: VERIFICAR TABLA MEDICATION_CATALOG
-- ============================================

\echo '
========================================
📋 DIAGNÓSTICO 4: Tabla medication_catalog
========================================
'

-- Verificar tabla existe
SELECT
  '7. Tabla medication_catalog:' as prueba,
  table_name,
  CASE
    WHEN table_name = 'medication_catalog' THEN '✅ OK: Tabla existe'
    ELSE '❌ CRÍTICO: Tabla no existe'
  END as diagnostico
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'medication_catalog';

-- Contar registros
SELECT
  '8. Registros en medication_catalog:' as prueba,
  count(*) as total_medicamentos,
  CASE
    WHEN count(*) = 0 THEN '⚠️ ADVERTENCIA: Catálogo vacío'
    ELSE '✅ OK: Tiene medicamentos'
  END as diagnostico
FROM medication_catalog;

-- Verificar medicamento de prueba
SELECT
  '9. Buscar medicamento de prueba (MED-TEST-001):' as prueba,
  count(*) as encontrados,
  CASE
    WHEN count(*) = 0 THEN '❌ CONFIRMADO: INSERT no persistió'
    ELSE '✅ Medicamento SÍ existe en BD'
  END as diagnostico
FROM medication_catalog
WHERE codigo_medicamento = 'MED-TEST-001';

-- ============================================
-- RESUMEN DEL DIAGNÓSTICO
-- ============================================

\echo '
========================================
📊 RESUMEN DEL DIAGNÓSTICO
========================================
'

DO $$
DECLARE
  v_rls_enabled BOOLEAN;
  v_policies_count INTEGER;
  v_functions_count INTEGER;
  v_user_id UUID;
  v_roles_count INTEGER;
  v_problem TEXT := '';
BEGIN
  -- Verificar RLS
  SELECT rowsecurity INTO v_rls_enabled
  FROM pg_tables
  WHERE tablename = 'medication_catalog';

  -- Contar políticas
  SELECT count(*) INTO v_policies_count
  FROM pg_policies
  WHERE tablename = 'medication_catalog';

  -- Contar funciones
  SELECT count(*) INTO v_functions_count
  FROM pg_proc
  WHERE proname IN ('is_super_admin', 'has_permission', 'get_user_role', 'has_center_access');

  -- Usuario actual
  SELECT auth.uid() INTO v_user_id;

  -- Contar roles
  SELECT count(*) INTO v_roles_count
  FROM user_roles
  WHERE user_id = v_user_id AND is_active = true;

  -- Determinar problema
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔍 DIAGNÓSTICO COMPLETO';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';

  IF v_rls_enabled AND v_policies_count = 0 THEN
    RAISE NOTICE '❌ PROBLEMA IDENTIFICADO: RLS habilitado pero SIN políticas';
    RAISE NOTICE '   Causa: Scripts SQL de corrección NO ejecutados';
    RAISE NOTICE '   Efecto: Todos los INSERT son bloqueados silenciosamente';
    RAISE NOTICE '   Solución: Ejecutar SOLUCIÓN INMEDIATA abajo';
    v_problem := 'RLS sin políticas';
  ELSIF v_policies_count > 0 AND v_functions_count = 0 THEN
    RAISE NOTICE '❌ PROBLEMA IDENTIFICADO: Políticas existen pero funciones helper NO';
    RAISE NOTICE '   Causa: Migración 04_sistema_permisos_rls.sql NO ejecutada';
    RAISE NOTICE '   Efecto: Políticas RLS fallan al evaluar is_super_admin()';
    RAISE NOTICE '   Solución: Ejecutar SOLUCIÓN INMEDIATA abajo';
    v_problem := 'Faltan funciones helper';
  ELSIF v_roles_count = 0 THEN
    RAISE NOTICE '⚠️ PROBLEMA IDENTIFICADO: Usuario sin rol asignado';
    RAISE NOTICE '   Causa: No se asignó rol super_admin al usuario';
    RAISE NOTICE '   Efecto: Políticas RLS niegan acceso';
    RAISE NOTICE '   Solución: Ejecutar SOLUCIÓN INMEDIATA abajo';
    v_problem := 'Usuario sin rol';
  ELSE
    RAISE NOTICE '✅ CONFIGURACIÓN CORRECTA';
    RAISE NOTICE '   Si aún no persiste, revisar logs de Supabase';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'ESTADÍSTICAS:';
  RAISE NOTICE '  - RLS habilitado: %', v_rls_enabled;
  RAISE NOTICE '  - Políticas RLS: %', v_policies_count;
  RAISE NOTICE '  - Funciones helper: %', v_functions_count;
  RAISE NOTICE '  - Usuario ID: %', v_user_id;
  RAISE NOTICE '  - Roles asignados: %', v_roles_count;
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;

-- ============================================
-- SOLUCIÓN INMEDIATA
-- ============================================

\echo '
========================================
🚨 SOLUCIÓN INMEDIATA
========================================

⚠️ SI EL DIAGNÓSTICO MOSTRÓ ERRORES, EJECUTA UNO DE ESTOS:

----------------------------------------
SOLUCIÓN 1: Si NO hay políticas RLS
----------------------------------------

-- Deshabilitar RLS temporalmente (solo para pruebas)
ALTER TABLE medication_catalog DISABLE ROW LEVEL SECURITY;

-- Luego ejecutar FIX_CRITICAL_ERRORS.sql completo

----------------------------------------
SOLUCIÓN 2: Si faltan funciones helper
----------------------------------------

-- Crear funciones mínimas temporales
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN true; -- Temporal: permite todo
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION has_permission(p_resource TEXT, p_action TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN true; -- Temporal: permite todo
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Luego ejecutar FIX_CRITICAL_ERRORS.sql completo

----------------------------------------
SOLUCIÓN 3: Si usuario sin rol
----------------------------------------

-- Asignar rol super_admin al usuario actual
INSERT INTO user_roles (user_id, role_name, is_active)
VALUES (auth.uid(), ''super_admin'', true)
ON CONFLICT DO NOTHING;

-- Verificar
SELECT * FROM user_roles WHERE user_id = auth.uid();

----------------------------------------
SOLUCIÓN 4: Ejecutar corrección completa
----------------------------------------

-- Ejecutar en orden:
-- 1. migrations/04_sistema_permisos_rls.sql
-- 2. FIX_CRITICAL_ERRORS.sql
-- 3. CARGA_MEDICAMENTOS_CSV.sql

========================================
'

-- FIN DEL DIAGNÓSTICO
