-- ============================================
-- DIAGNÓSTICO: ¿Por qué Dashboard muestra 0 medicamentos?
-- ============================================
-- El Dashboard usa useMedicamentos(centroId) que filtra por center_id
-- Necesitamos verificar:
-- 1. Políticas RLS en tabla 'medications'
-- 2. Qué center_id tienen los 4 medicamentos
-- 3. Qué centros existen
-- 4. Si hay un centro seleccionado por el usuario
-- ============================================

-- ============================================
-- 1. VERIFICAR POLÍTICAS RLS EN 'medications'
-- ============================================

SELECT
  '=== POLÍTICAS RLS EN medications ===' as titulo;

-- Ver si RLS está habilitado
SELECT
  tablename,
  rowsecurity as rls_habilitado,
  CASE
    WHEN rowsecurity = true THEN '✅ RLS habilitado'
    ELSE '❌ RLS deshabilitado'
  END as estado
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'medications';

-- Ver políticas existentes
SELECT
  policyname as nombre_politica,
  cmd as operacion,
  CASE
    WHEN cmd = 'SELECT' THEN '✅ CRÍTICO: Permite leer medications'
    WHEN cmd = 'INSERT' THEN 'Permite crear medications'
    WHEN cmd = 'UPDATE' THEN 'Permite actualizar medications'
    WHEN cmd = 'DELETE' THEN 'Permite eliminar medications'
  END as descripcion
FROM pg_policy
WHERE polrelid = 'medications'::regclass
ORDER BY cmd;

-- Contar políticas por operación
SELECT
  'medications' as tabla,
  cmd as operacion,
  count(*) as num_politicas,
  CASE
    WHEN cmd = 'SELECT' AND count(*) = 0 THEN '❌ CRÍTICO: FALTA POLÍTICA SELECT'
    WHEN count(*) = 0 THEN '❌ FALTA'
    ELSE '✅ Existe'
  END as estado
FROM pg_policy
WHERE polrelid = 'medications'::regclass
GROUP BY cmd
ORDER BY cmd;

-- ============================================
-- 2. VERIFICAR MEDICAMENTOS EXISTENTES
-- ============================================

SELECT
  '=== MEDICAMENTOS EN TABLA medications ===' as titulo;

-- Contar medicamentos totales
SELECT
  count(*) as total_medications,
  count(*) FILTER (WHERE is_active = true) as activos,
  count(DISTINCT center_id) as centros_diferentes,
  CASE
    WHEN count(*) = 0 THEN '❌ NO HAY MEDICAMENTOS en tabla medications'
    WHEN count(*) = 4 THEN '✅ Confirma 4 medicamentos'
    ELSE '⚠️ ' || count(*) || ' medicamentos encontrados'
  END as diagnostico
FROM medications;

-- Ver los 4 medicamentos con su center_id
SELECT
  id,
  center_id,
  nombre,
  categoria,
  is_active,
  created_at,
  CASE
    WHEN center_id IS NULL THEN '❌ SIN center_id (problema crítico)'
    ELSE '✅ Tiene center_id'
  END as tiene_centro
FROM medications
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- 3. VERIFICAR CENTROS DE SALUD
-- ============================================

SELECT
  '=== CENTROS DE SALUD REGISTRADOS ===' as titulo;

-- Ver centros existentes
SELECT
  id as center_id,
  name as nombre,
  code as codigo,
  is_active,
  CASE
    WHEN is_active = true THEN '✅ Activo'
    ELSE '❌ Inactivo'
  END as estado
FROM health_centers
ORDER BY name;

-- Contar centros
SELECT
  count(*) as total_centros,
  count(*) FILTER (WHERE is_active = true) as centros_activos,
  CASE
    WHEN count(*) = 0 THEN '❌ CRÍTICO: NO HAY CENTROS REGISTRADOS'
    WHEN count(*) FILTER (WHERE is_active = true) = 0 THEN '❌ CRÍTICO: NO HAY CENTROS ACTIVOS'
    ELSE '✅ Hay centros registrados'
  END as diagnostico
FROM health_centers;

-- ============================================
-- 4. VERIFICAR RELACIÓN medications <-> centers
-- ============================================

SELECT
  '=== RELACIÓN medications ↔ health_centers ===' as titulo;

-- Ver qué medications pertenecen a qué centro
SELECT
  m.id as medication_id,
  m.nombre as medicamento,
  m.center_id,
  hc.name as nombre_centro,
  hc.code as codigo_centro,
  CASE
    WHEN m.center_id IS NULL THEN '❌ Medicamento SIN centro asignado'
    WHEN hc.id IS NULL THEN '❌ center_id apunta a centro que NO EXISTE'
    WHEN hc.is_active = false THEN '⚠️ Centro existe pero está INACTIVO'
    ELSE '✅ Relación correcta'
  END as diagnostico
FROM medications m
LEFT JOIN health_centers hc ON m.center_id = hc.id
ORDER BY m.created_at DESC;

-- ============================================
-- 5. DIAGNÓSTICO DEL PROBLEMA DEL DASHBOARD
-- ============================================

SELECT
  '=== DIAGNÓSTICO: ¿Por qué Dashboard muestra 0? ===' as titulo;

-- Análisis completo
DO $$
DECLARE
  v_total_meds INT;
  v_total_centers INT;
  v_meds_sin_centro INT;
  v_centros_activos INT;
  v_politica_select INT;
BEGIN
  SELECT count(*) INTO v_total_meds FROM medications;
  SELECT count(*) INTO v_total_centers FROM health_centers;
  SELECT count(*) INTO v_meds_sin_centro FROM medications WHERE center_id IS NULL;
  SELECT count(*) INTO v_centros_activos FROM health_centers WHERE is_active = true;
  SELECT count(*) INTO v_politica_select FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'SELECT';

  RAISE NOTICE '====================================';
  RAISE NOTICE 'DIAGNÓSTICO COMPLETO';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Total medicamentos: %', v_total_meds;
  RAISE NOTICE 'Total centros: %', v_total_centers;
  RAISE NOTICE 'Medicamentos sin centro: %', v_meds_sin_centro;
  RAISE NOTICE 'Centros activos: %', v_centros_activos;
  RAISE NOTICE 'Política SELECT: %', CASE WHEN v_politica_select > 0 THEN '✅ Existe' ELSE '❌ NO existe' END;
  RAISE NOTICE '====================================';

  -- Determinar problema
  IF v_total_meds = 0 THEN
    RAISE NOTICE '❌ PROBLEMA: NO hay medicamentos en tabla medications';
    RAISE NOTICE '🔧 SOLUCIÓN: Crear medicamentos desde /admin o importar datos';
  ELSIF v_politica_select = 0 THEN
    RAISE NOTICE '❌ PROBLEMA: NO hay política SELECT en medications';
    RAISE NOTICE '🔧 SOLUCIÓN: Ejecutar script VERIFICAR_Y_CORREGIR_AMBAS_TABLAS.sql';
  ELSIF v_total_centers = 0 THEN
    RAISE NOTICE '❌ PROBLEMA: NO hay centros de salud registrados';
    RAISE NOTICE '🔧 SOLUCIÓN: Crear al menos un centro en tabla health_centers';
  ELSIF v_centros_activos = 0 THEN
    RAISE NOTICE '❌ PROBLEMA: NO hay centros ACTIVOS';
    RAISE NOTICE '🔧 SOLUCIÓN: Activar al menos un centro (is_active = true)';
  ELSIF v_meds_sin_centro > 0 THEN
    RAISE NOTICE '⚠️ PROBLEMA: % medicamentos SIN center_id', v_meds_sin_centro;
    RAISE NOTICE '🔧 SOLUCIÓN: Asignar center_id a los medicamentos';
  ELSE
    RAISE NOTICE '✅ Configuración correcta';
    RAISE NOTICE '⚠️ PROBLEMA POSIBLE: Usuario no tiene centro seleccionado en frontend';
    RAISE NOTICE '🔧 SOLUCIÓN: Verificar que usuario seleccione centro en dropdown del Dashboard';
  END IF;

  RAISE NOTICE '====================================';
END $$;

-- ============================================
-- 6. PROBAR SELECT COMO LO HARÍA EL FRONTEND
-- ============================================

-- Simular query del frontend: SELECT * FROM medications WHERE center_id = ?
-- Probar con todos los center_id que existen

DO $$
DECLARE
  v_center RECORD;
  v_count INT;
BEGIN
  RAISE NOTICE '====================================';
  RAISE NOTICE 'SIMULACIÓN: Queries del frontend';
  RAISE NOTICE '====================================';

  FOR v_center IN SELECT id, name FROM health_centers WHERE is_active = true
  LOOP
    SELECT count(*) INTO v_count FROM medications WHERE center_id = v_center.id;
    RAISE NOTICE 'Centro: % (ID: %)', v_center.name, v_center.id;
    RAISE NOTICE '  → Medicamentos: %', v_count;
  END LOOP;

  RAISE NOTICE '====================================';
END $$;

-- ============================================
-- 7. RESUMEN Y RECOMENDACIONES
-- ============================================

SELECT
  '=== RESUMEN Y PRÓXIMOS PASOS ===' as titulo;

-- Resumen final
WITH diagnostico AS (
  SELECT
    (SELECT count(*) FROM medications) as total_meds,
    (SELECT count(*) FROM health_centers WHERE is_active = true) as centros_activos,
    (SELECT count(*) FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'SELECT') as tiene_select,
    (SELECT count(*) FROM medications WHERE center_id IS NULL) as meds_sin_centro
)
SELECT
  total_meds || ' medicamentos en BD' as estado_medications,
  centros_activos || ' centros activos' as estado_centers,
  CASE WHEN tiene_select > 0 THEN '✅ SELECT OK' ELSE '❌ FALTA SELECT' END as politica_select,
  CASE
    WHEN total_meds = 0 THEN
      '❌ Crear medicamentos'
    WHEN tiene_select = 0 THEN
      '❌ Aplicar política SELECT (ejecutar VERIFICAR_Y_CORREGIR_AMBAS_TABLAS.sql)'
    WHEN centros_activos = 0 THEN
      '❌ Crear/activar centro de salud'
    WHEN meds_sin_centro > 0 THEN
      '⚠️ Asignar center_id a ' || meds_sin_centro || ' medicamentos'
    ELSE
      '✅ Verificar que usuario seleccione centro en frontend'
  END as accion_requerida
FROM diagnostico;
