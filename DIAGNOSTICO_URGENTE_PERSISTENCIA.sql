-- ============================================
-- DIAGNOSTICO URGENTE - PERSISTENCIA DE DATOS
-- ============================================
-- Problema: Medicamentos NO se guardan en Supabase
-- Ejecutar en: Supabase SQL Editor
-- ============================================

-- ============================================
-- SECCIÓN 1: Verificar políticas RLS
-- ============================================

-- 1. Estado de RLS en medication_catalog
SELECT
  tablename,
  CASE rowsecurity
    WHEN true THEN '🔒 RLS HABILITADO'
    ELSE '🔓 RLS DESHABILITADO'
  END as estado_rls
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medication_catalog';

-- 2. Contar políticas RLS existentes
SELECT
  COALESCE(count(*), 0) as politicas_count,
  CASE
    WHEN count(*) = 0 THEN '❌ CRÍTICO: Sin políticas, INSERT bloqueado'
    WHEN count(*) < 4 THEN '⚠️ ADVERTENCIA: Faltan políticas'
    ELSE '✅ OK: Políticas completas'
  END as diagnostico
FROM pg_policies
WHERE tablename = 'medication_catalog';

-- 3. Listar políticas específicas
SELECT
  policyname,
  cmd as operacion
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY cmd;

-- ============================================
-- SECCIÓN 2: Verificar funciones helper
-- ============================================

-- 4. Verificar funciones críticas existen
SELECT
  count(*) as funciones_encontradas,
  CASE
    WHEN count(*) = 0 THEN '❌ CRÍTICO: Funciones no existen'
    WHEN count(*) < 4 THEN '⚠️ Faltan funciones'
    ELSE '✅ OK: Funciones completas'
  END as diagnostico
FROM pg_proc
WHERE proname IN ('is_super_admin', 'has_permission', 'get_user_role', 'has_center_access');

-- ============================================
-- SECCIÓN 3: Verificar roles de usuario
-- ============================================

-- 5. Usuario autenticado
SELECT
  auth.uid() as user_id,
  CASE
    WHEN auth.uid() IS NULL THEN '❌ CRÍTICO: Sin autenticación'
    ELSE '✅ OK: Autenticado'
  END as diagnostico;

-- 6. Verificar tabla user_roles existe
SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'user_roles'
    ) THEN '✅ Tabla user_roles existe'
    ELSE '⚠️ Tabla user_roles NO existe (usar políticas simples)'
  END as diagnostico;

-- ============================================
-- SECCIÓN 4: Verificar tabla medication_catalog
-- ============================================

-- 7. Verificar tabla existe
SELECT
  table_name,
  '✅ OK: Tabla existe' as diagnostico
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'medication_catalog';

-- 8. Contar registros
SELECT
  count(*) as total_medicamentos,
  CASE
    WHEN count(*) = 0 THEN '⚠️ Catálogo vacío'
    ELSE '✅ OK: Tiene medicamentos'
  END as diagnostico
FROM medication_catalog;

-- 9. Buscar medicamento de prueba
SELECT
  count(*) as encontrados,
  CASE
    WHEN count(*) = 0 THEN '❌ INSERT no persistió'
    ELSE '✅ Medicamento existe en BD'
  END as diagnostico
FROM medication_catalog
WHERE codigo_medicamento = 'MED-TEST-001';

-- ============================================
-- RESUMEN DEL DIAGNÓSTICO
-- ============================================

DO $$
DECLARE
  v_rls_enabled BOOLEAN;
  v_policies_count INTEGER;
  v_functions_count INTEGER;
  v_user_id UUID;
  v_roles_count INTEGER;
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

  -- Contar roles (si tabla existe)
  BEGIN
    SELECT count(*) INTO v_roles_count
    FROM user_roles
    WHERE user_id = v_user_id AND is_active = true;
  EXCEPTION
    WHEN undefined_table THEN
      v_roles_count := -1; -- Tabla no existe
  END;

  -- Mostrar diagnóstico
  RAISE NOTICE '========================================';
  RAISE NOTICE 'DIAGNOSTICO COMPLETO';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';

  IF v_rls_enabled AND v_policies_count = 0 THEN
    RAISE NOTICE 'PROBLEMA: RLS habilitado pero SIN politicas';
    RAISE NOTICE 'Causa: Scripts SQL NO ejecutados';
    RAISE NOTICE 'Efecto: INSERT bloqueado silenciosamente';
    RAISE NOTICE 'Solucion: Ejecutar SOLUCION_RAPIDA_PERSISTENCIA.sql';
  ELSIF v_policies_count > 0 AND v_functions_count = 0 THEN
    RAISE NOTICE 'PROBLEMA: Politicas existen pero funciones NO';
    RAISE NOTICE 'Causa: Migracion 04_sistema_permisos_rls.sql NO ejecutada';
    RAISE NOTICE 'Solucion: Ejecutar SOLUCION_RAPIDA_PERSISTENCIA.sql';
  ELSIF v_roles_count = -1 THEN
    RAISE NOTICE 'ADVERTENCIA: Tabla user_roles no existe';
    RAISE NOTICE 'Solucion: Usar SOLUCION_RAPIDA_PERSISTENCIA.sql (no requiere user_roles)';
  ELSIF v_roles_count = 0 THEN
    RAISE NOTICE 'PROBLEMA: Usuario sin rol asignado';
    RAISE NOTICE 'Solucion: INSERT INTO user_roles (user_id, role_name, is_active) VALUES (auth.uid(), ''super_admin'', true);';
  ELSE
    RAISE NOTICE 'CONFIGURACION CORRECTA';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE 'ESTADISTICAS:';
  RAISE NOTICE '  - RLS habilitado: %', v_rls_enabled;
  RAISE NOTICE '  - Politicas RLS: %', v_policies_count;
  RAISE NOTICE '  - Funciones helper: %', v_functions_count;
  RAISE NOTICE '  - Usuario ID: %', v_user_id;
  RAISE NOTICE '  - Roles asignados: %', v_roles_count;
  RAISE NOTICE '========================================';
END $$;

-- FIN DEL DIAGNÓSTICO
