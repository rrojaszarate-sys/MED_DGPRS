-- ============================================
-- SOLUCIÓN: Dashboard muestra 0 medicamentos
-- ============================================
-- Este script corrige los problemas más comunes que causan
-- que el Dashboard muestre 0 medicamentos
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: APLICAR POLÍTICAS RLS EN 'medications'
-- ============================================

-- Eliminar políticas antiguas (si existen)
DROP POLICY IF EXISTS "medications_select_policy" ON medications;
DROP POLICY IF EXISTS "medications_insert_policy" ON medications;
DROP POLICY IF EXISTS "medications_update_policy" ON medications;
DROP POLICY IF EXISTS "medications_delete_policy" ON medications;

-- Habilitar RLS
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;

-- Crear políticas permisivas
CREATE POLICY "medications_select_policy" ON medications
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    OR auth.role() = 'anon'
  );

CREATE POLICY "medications_insert_policy" ON medications
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "medications_update_policy" ON medications
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "medications_delete_policy" ON medications
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- ============================================
-- PASO 2: VERIFICAR/CREAR CENTRO DE SALUD
-- ============================================

-- Verificar si existe al menos un centro activo
DO $$
DECLARE
  v_centros_activos INT;
  v_centro_id UUID;
BEGIN
  SELECT count(*) INTO v_centros_activos
  FROM health_centers
  WHERE is_active = true;

  IF v_centros_activos = 0 THEN
    RAISE NOTICE '⚠️ NO hay centros activos. Creando centro de ejemplo...';

    -- Crear centro de ejemplo
    INSERT INTO health_centers (
      name,
      code,
      address,
      city,
      phone,
      is_active
    ) VALUES (
      'Centro de Salud Principal',
      'CS-001',
      'Av. Principal #123',
      'Ciudad',
      '555-1234',
      true
    )
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_centro_id;

    IF v_centro_id IS NOT NULL THEN
      RAISE NOTICE '✅ Centro creado con ID: %', v_centro_id;
    ELSE
      RAISE NOTICE '⚠️ Centro ya existía';
    END IF;
  ELSE
    RAISE NOTICE '✅ % centros activos encontrados', v_centros_activos;
  END IF;
END $$;

-- ============================================
-- PASO 3: ASIGNAR center_id A MEDICAMENTOS HUÉRFANOS
-- ============================================

-- Si hay medicamentos sin center_id, asignarlos al primer centro activo
DO $$
DECLARE
  v_meds_sin_centro INT;
  v_primer_centro_id UUID;
  v_updated INT;
BEGIN
  -- Contar medicamentos sin center_id
  SELECT count(*) INTO v_meds_sin_centro
  FROM medications
  WHERE center_id IS NULL;

  IF v_meds_sin_centro > 0 THEN
    RAISE NOTICE '⚠️ % medicamentos sin center_id', v_meds_sin_centro;

    -- Obtener primer centro activo
    SELECT id INTO v_primer_centro_id
    FROM health_centers
    WHERE is_active = true
    ORDER BY created_at ASC
    LIMIT 1;

    IF v_primer_centro_id IS NOT NULL THEN
      -- Asignar center_id a medicamentos huérfanos
      UPDATE medications
      SET center_id = v_primer_centro_id
      WHERE center_id IS NULL;

      GET DIAGNOSTICS v_updated = ROW_COUNT;

      RAISE NOTICE '✅ Asignados % medicamentos al centro: %', v_updated, v_primer_centro_id;
    ELSE
      RAISE NOTICE '❌ ERROR: No hay centros activos para asignar';
    END IF;
  ELSE
    RAISE NOTICE '✅ Todos los medicamentos tienen center_id';
  END IF;
END $$;

-- ============================================
-- PASO 4: VERIFICACIÓN POST-CORRECCIÓN
-- ============================================

DO $$
DECLARE
  v_total_meds INT;
  v_meds_activos INT;
  v_total_centers INT;
  v_centers_activos INT;
  v_meds_sin_centro INT;
  v_politica_select INT;
BEGIN
  -- Recopilar métricas
  SELECT count(*) INTO v_total_meds FROM medications;
  SELECT count(*) INTO v_meds_activos FROM medications WHERE is_active = true;
  SELECT count(*) INTO v_total_centers FROM health_centers;
  SELECT count(*) INTO v_centers_activos FROM health_centers WHERE is_active = true;
  SELECT count(*) INTO v_meds_sin_centro FROM medications WHERE center_id IS NULL;
  SELECT count(*) INTO v_politica_select FROM pg_policy WHERE polrelid = 'medications'::regclass AND cmd = 'SELECT';

  RAISE NOTICE '====================================';
  RAISE NOTICE 'VERIFICACIÓN POST-CORRECCIÓN';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Medicamentos totales: %', v_total_meds;
  RAISE NOTICE 'Medicamentos activos: %', v_meds_activos;
  RAISE NOTICE 'Centros totales: %', v_total_centers;
  RAISE NOTICE 'Centros activos: %', v_centers_activos;
  RAISE NOTICE 'Medicamentos sin centro: %', v_meds_sin_centro;
  RAISE NOTICE 'Política SELECT: %', CASE WHEN v_politica_select > 0 THEN '✅' ELSE '❌' END;
  RAISE NOTICE '====================================';

  -- Validar que todo está OK
  IF v_politica_select = 0 THEN
    RAISE EXCEPTION '❌ ERROR: No se creó política SELECT';
  END IF;

  IF v_centers_activos = 0 THEN
    RAISE EXCEPTION '❌ ERROR: No hay centros activos';
  END IF;

  IF v_total_meds > 0 AND v_meds_sin_centro > 0 THEN
    RAISE EXCEPTION '❌ ERROR: Hay medicamentos sin center_id';
  END IF;

  RAISE NOTICE '✅ TODAS LAS CORRECCIONES APLICADAS EXITOSAMENTE';
  RAISE NOTICE '====================================';
END $$;

COMMIT;

-- ============================================
-- PASO 5: PRUEBA FINAL
-- ============================================

-- Probar query como lo haría el frontend
SELECT
  '=== PRUEBA FINAL: Simular query del Dashboard ===' as titulo;

-- Mostrar medicamentos por centro
SELECT
  hc.name as centro,
  count(m.id) as num_medicamentos,
  string_agg(m.nombre, ', ') as medicamentos
FROM health_centers hc
LEFT JOIN medications m ON m.center_id = hc.id AND m.is_active = true
WHERE hc.is_active = true
GROUP BY hc.id, hc.name
ORDER BY hc.name;

-- ============================================
-- INSTRUCCIONES FINALES
-- ============================================

SELECT
  '=== PRÓXIMOS PASOS ===' as titulo;

DO $$
BEGIN
  RAISE NOTICE '====================================';
  RAISE NOTICE 'INSTRUCCIONES PARA EL FRONTEND';
  RAISE NOTICE '====================================';
  RAISE NOTICE '1. Ir a Dashboard en Vercel';
  RAISE NOTICE '2. IMPORTANTE: Seleccionar un centro en el dropdown';
  RAISE NOTICE '3. El Dashboard debe mostrar los medicamentos';
  RAISE NOTICE '4. Si no hay dropdown de centros:';
  RAISE NOTICE '   - Verificar componente CentroContext';
  RAISE NOTICE '   - Verificar que usuario esté autenticado';
  RAISE NOTICE '5. Si sigue mostrando 0:';
  RAISE NOTICE '   - Abrir consola (F12)';
  RAISE NOTICE '   - Buscar errores de Supabase';
  RAISE NOTICE '   - Reportar error específico';
  RAISE NOTICE '====================================';
END $$;
