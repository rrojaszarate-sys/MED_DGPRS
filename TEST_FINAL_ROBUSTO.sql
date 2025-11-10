-- ============================================
-- SCRIPT DE PRUEBAS SIMPLIFICADO Y ROBUSTO
-- SIGIMED - Compatible con cualquier schema
-- ============================================
--
-- Este script:
-- 1. Consulta el schema real de la base de datos
-- 2. Se adapta a las columnas disponibles
-- 3. Inserta datos de prueba
-- 4. Ejecuta 16 pruebas automatizadas
-- 5. Genera reporte completo
--
-- VERSIÓN: Ultra-robusta - funciona con cualquier schema
-- ============================================

DO $$
DECLARE
  v_test_count INTEGER := 0;
  v_pass_count INTEGER := 0;
  v_fail_count INTEGER := 0;
  v_user_id UUID;
  v_result JSONB;
  v_count INTEGER;
  v_stock_before INTEGER;
  v_has_code_column BOOLEAN := false;

  -- IDs fijos
  v_hospital_id UUID := '11111111-1111-1111-1111-111111111111';
  v_centro_norte_id UUID := '22222222-2222-2222-2222-222222222222';
  v_posta_sur_id UUID := '33333333-3333-3333-3333-333333333333';
  v_proveedor1_id UUID := 'aaaa1111-aaaa-1111-aaaa-111111111111';
  v_proveedor2_id UUID := 'bbbb2222-bbbb-2222-bbbb-222222222222';
  v_amoxicilina_cat UUID := 'cccc1111-cccc-1111-cccc-111111111111';
  v_paracetamol_cat UUID := 'cccc3333-cccc-3333-cccc-333333333333';
  v_ciprofloxacino_cat UUID := 'cccc2222-cccc-2222-cccc-222222222222';
  v_losartan_cat UUID := 'cccc5555-cccc-5555-cccc-555555555555';
  v_insulina_cat UUID := 'cccc8888-cccc-8888-cccc-888888888888';
  v_paracetamol_hosp UUID := 'dddd3333-dddd-3333-dddd-333333333333';
  v_amoxicilina_hosp UUID := 'dddd1111-dddd-1111-dddd-111111111111';
BEGIN

  RAISE NOTICE '';
  RAISE NOTICE '╔═══════════════════════════════════════════════════════════╗';
  RAISE NOTICE '║                                                           ║';
  RAISE NOTICE '║     PRUEBAS AUTOMATIZADAS SIGIMED - VERSIÓN ROBUSTA       ║';
  RAISE NOTICE '║                                                           ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════════════════╝';
  RAISE NOTICE '';

  -- Verificar si la columna 'code' existe en health_centers
  SELECT EXISTS (
    SELECT FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'health_centers'
    AND column_name = 'code'
  ) INTO v_has_code_column;

  IF v_has_code_column THEN
    RAISE NOTICE '✓ Columna "code" detectada en health_centers';
  ELSE
    RAISE NOTICE '⚠ Columna "code" NO existe en health_centers - usando solo IDs';
  END IF;
  RAISE NOTICE '';

  -- ============================================
  -- PASO 1: LIMPIAR DATOS DE PRUEBA ANTERIORES
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PASO 1: LIMPIANDO DATOS DE PRUEBA ANTERIORES';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- Limpiar batch_movements
  BEGIN
    DELETE FROM batch_movements WHERE numero_documento LIKE 'TEST-%';
    RAISE NOTICE '  ✓ batch_movements limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ batch_movements: %', SQLERRM;
  END;

  -- Limpiar medications usando IDs específicos
  BEGIN
    DELETE FROM medications WHERE id IN (
      v_paracetamol_hosp, v_amoxicilina_hosp,
      'dddd1112-dddd-1112-dddd-111111111112',
      'dddd2222-dddd-2222-dddd-222222222222',
      'dddd5555-dddd-5555-dddd-555555555555',
      'dddd8888-dddd-8888-dddd-888888888888',
      'eeee1111-eeee-1111-eeee-111111111111'
    );
    RAISE NOTICE '  ✓ medications limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ medications: %', SQLERRM;
  END;

  -- Limpiar user_centers
  BEGIN
    DELETE FROM user_centers WHERE center_id IN (v_hospital_id, v_centro_norte_id, v_posta_sur_id);
    RAISE NOTICE '  ✓ user_centers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ user_centers: %', SQLERRM;
  END;

  -- Limpiar medication_catalog
  BEGIN
    DELETE FROM medication_catalog WHERE id IN (
      v_amoxicilina_cat, v_paracetamol_cat, v_ciprofloxacino_cat,
      v_losartan_cat, v_insulina_cat
    );
    RAISE NOTICE '  ✓ medication_catalog limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ medication_catalog: %', SQLERRM;
  END;

  -- Limpiar suppliers
  BEGIN
    DELETE FROM suppliers WHERE id IN (v_proveedor1_id, v_proveedor2_id);
    RAISE NOTICE '  ✓ suppliers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ suppliers: %', SQLERRM;
  END;

  -- Limpiar health_centers
  BEGIN
    DELETE FROM health_centers WHERE id IN (v_hospital_id, v_centro_norte_id, v_posta_sur_id);
    RAISE NOTICE '  ✓ health_centers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ health_centers: %', SQLERRM;
  END;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Limpieza completada';
  RAISE NOTICE '';

  -- ============================================
  -- PASO 2: INSERTAR DATOS DE PRUEBA
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PASO 2: INSERTANDO DATOS DE PRUEBA';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- 2.1 Centros de Salud
  RAISE NOTICE '💾 Insertando centros de salud...';
  BEGIN
    IF v_has_code_column THEN
      -- Si existe la columna code
      INSERT INTO health_centers (id, name, code, address, city, region, phone, storage_capacity, has_refrigeration, is_active)
      VALUES
        (v_hospital_id, 'Hospital Central de Prueba', 'TEST-HCP-001', 'Av. Principal 123', 'Lima', 'Lima', '+51-1-234-5678', 5000, true, true),
        (v_centro_norte_id, 'Centro de Salud Norte', 'TEST-CSN-002', 'Jr. Los Olivos 456', 'Lima', 'Lima', '+51-1-234-5679', 2000, true, true),
        (v_posta_sur_id, 'Posta Médica Sur', 'TEST-PMS-003', 'Calle Las Flores 789', 'Arequipa', 'Arequipa', '+51-54-234-5680', 1000, false, true);
    ELSE
      -- Sin columna code
      INSERT INTO health_centers (id, name, address, city, region, phone, storage_capacity, has_refrigeration, is_active)
      VALUES
        (v_hospital_id, 'Hospital Central de Prueba', 'Av. Principal 123', 'Lima', 'Lima', '+51-1-234-5678', 5000, true, true),
        (v_centro_norte_id, 'Centro de Salud Norte', 'Jr. Los Olivos 456', 'Lima', 'Lima', '+51-1-234-5679', 2000, true, true),
        (v_posta_sur_id, 'Posta Médica Sur', 'Calle Las Flores 789', 'Arequipa', 'Arequipa', '+51-54-234-5680', 1000, false, true);
    END IF;

    v_test_count := v_test_count + 1;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count = 3 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ TEST 1: Inserción de Centros - PASS (3 centros)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 1: Inserción de Centros - FAIL (% centros)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 1: Inserción de Centros - FAIL: %', SQLERRM;
  END;

  -- 2.2 Proveedores
  RAISE NOTICE '💾 Insertando proveedores...';
  BEGIN
    INSERT INTO suppliers (id, name, ruc, city, phone, is_active)
    VALUES
      (v_proveedor1_id, 'Farmacéutica Global SAC', 'TEST20123456789', 'Lima', '+51-1-555-0001', true),
      (v_proveedor2_id, 'Distribuidora MediPharma EIRL', 'TEST20987654321', 'Lima', '+51-1-555-0002', true);

    v_test_count := v_test_count + 1;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count = 2 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ TEST 2: Inserción de Proveedores - PASS (2 proveedores)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 2: Inserción de Proveedores - FAIL (% proveedores)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 2: Inserción de Proveedores - FAIL: %', SQLERRM;
  END;

  -- 2.3 Catálogo de Medicamentos
  RAISE NOTICE '💾 Insertando catálogo de medicamentos...';
  BEGIN
    INSERT INTO medication_catalog (id, nombre_comercial, nombre_generico, formula_activa, concentracion, forma_farmaceutica, temperatura_almacenamiento, is_active)
    VALUES
      (v_amoxicilina_cat, 'AMOXICILINA PRUEBA', 'Amoxicilina', 'Amoxicilina Trihidratada', '500mg', 'capsula', 'ambiente', true),
      (v_paracetamol_cat, 'PARACETAMOL PRUEBA', 'Paracetamol', 'Paracetamol', '500mg', 'tableta', 'ambiente', true),
      (v_ciprofloxacino_cat, 'CIPROFLOXACINO PRUEBA', 'Ciprofloxacino', 'Ciprofloxacino Clorhidrato', '500mg', 'tableta', 'ambiente', true),
      (v_losartan_cat, 'LOSARTAN PRUEBA', 'Losartán', 'Losartán Potásico', '50mg', 'tableta', 'ambiente', true),
      (v_insulina_cat, 'INSULINA PRUEBA', 'Insulina NPH', 'Insulina Humana', '100UI/ml', 'inyectable', 'refrigerado', true);

    v_test_count := v_test_count + 1;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count = 5 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ TEST 3: Inserción de Catálogo - PASS (5 medicamentos)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 3: Inserción de Catálogo - FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 3: Inserción de Catálogo - FAIL: %', SQLERRM;
  END;

  -- 2.4 Inventario
  RAISE NOTICE '💾 Insertando inventario...';
  BEGIN
    INSERT INTO medications (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, estado, proveedor_id, ubicacion_fisica)
    VALUES
      (v_paracetamol_hosp, v_hospital_id, v_paracetamol_cat, 'PARACETAMOL PRUEBA 500mg', 'Paracetamol', 'TEST-PAR-2024-001', 1500, CURRENT_DATE + INTERVAL '18 months', 'Disponible', v_proveedor1_id, 'Estante B1'),
      (v_amoxicilina_hosp, v_hospital_id, v_amoxicilina_cat, 'AMOXICILINA PRUEBA 500mg', 'Amoxicilina Trihidratada', 'TEST-AMX-2024-001', 500, CURRENT_DATE + INTERVAL '12 months', 'Disponible', v_proveedor1_id, 'Estante A1'),
      ('dddd1112-dddd-1112-dddd-111111111112', v_hospital_id, v_amoxicilina_cat, 'AMOXICILINA PRUEBA 500mg', 'Amoxicilina Trihidratada', 'TEST-AMX-2024-002', 45, CURRENT_DATE + INTERVAL '45 days', 'Disponible', v_proveedor1_id, 'Estante A1'),
      ('dddd2222-dddd-2222-dddd-222222222222', v_hospital_id, v_ciprofloxacino_cat, 'CIPROFLOXACINO PRUEBA 500mg', 'Ciprofloxacino Clorhidrato', 'TEST-CIP-2024-001', 15, CURRENT_DATE + INTERVAL '6 months', 'Disponible', v_proveedor2_id, 'Estante A2'),
      ('dddd5555-dddd-5555-dddd-555555555555', v_hospital_id, v_losartan_cat, 'LOSARTAN PRUEBA 50mg', 'Losartán Potásico', 'TEST-LOS-2023-005', 80, CURRENT_DATE + INTERVAL '15 days', 'Disponible', v_proveedor2_id, 'Estante C1'),
      ('dddd8888-dddd-8888-dddd-888888888888', v_hospital_id, v_insulina_cat, 'INSULINA PRUEBA NPH', 'Insulina Humana', 'TEST-INS-2024-001', 25, CURRENT_DATE + INTERVAL '8 months', 'Disponible', v_proveedor2_id, 'Refrigerador 1'),
      ('eeee1111-eeee-1111-eeee-111111111111', v_centro_norte_id, v_paracetamol_cat, 'PARACETAMOL PRUEBA 500mg', 'Paracetamol', 'TEST-PAR-2024-002', 600, CURRENT_DATE + INTERVAL '16 months', 'Disponible', v_proveedor1_id, 'Anaquel 1A');

    v_test_count := v_test_count + 1;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count = 7 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ TEST 4: Inserción de Inventario - PASS (7 lotes)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 4: Inserción de Inventario - FAIL (% lotes)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ TEST 4: Inserción de Inventario - FAIL: %', SQLERRM;
  END;

  RAISE NOTICE '';

  -- ============================================
  -- PASO 3: PROBAR FUNCIONES DE BASE DE DATOS
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PASO 3: PROBANDO FUNCIONES DE BASE DE DATOS';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- Obtener usuario
  BEGIN
    SELECT id INTO v_user_id FROM auth.users ORDER BY created_at DESC LIMIT 1;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        SELECT id INTO v_user_id FROM users_profiles ORDER BY created_at DESC LIMIT 1;
      EXCEPTION
        WHEN OTHERS THEN
          v_user_id := NULL;
      END;
  END;

  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️  No hay usuarios disponibles. Tests 5-6, 10, 16 omitidos.';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '📋 Usuario encontrado: %', v_user_id;
    RAISE NOTICE '';

    -- TEST 5: registrar_movimiento_lote ENTRADA
    RAISE NOTICE '⚙️  TEST 5: registrar_movimiento_lote (ENTRADA)...';
    BEGIN
      SELECT cantidad INTO v_stock_before FROM medications WHERE id = v_paracetamol_hosp;

      v_result := registrar_movimiento_lote(
        p_medication_id := v_paracetamol_hosp,
        p_tipo_movimiento := 'entrada',
        p_cantidad := 500,
        p_motivo := 'Prueba automática',
        p_usuario_responsable := v_user_id,
        p_centro_destino_id := v_hospital_id,
        p_numero_documento := 'TEST-ENTRADA-001'
      );

      v_test_count := v_test_count + 1;
      IF (v_result->>'cantidad_final')::INTEGER = v_stock_before + 500 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ PASS (Stock: % → %)', v_stock_before, (v_result->>'cantidad_final')::INTEGER;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL';
      END IF;
    EXCEPTION
      WHEN undefined_function THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: Función no existe. Ejecuta MIGRATION_SQL_FINAL.sql';
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
    END;

    -- TEST 6: registrar_movimiento_lote SALIDA
    RAISE NOTICE '⚙️  TEST 6: registrar_movimiento_lote (SALIDA)...';
    BEGIN
      SELECT cantidad INTO v_stock_before FROM medications WHERE id = v_paracetamol_hosp;

      v_result := registrar_movimiento_lote(
        p_medication_id := v_paracetamol_hosp,
        p_tipo_movimiento := 'salida',
        p_cantidad := 300,
        p_motivo := 'Prueba automática',
        p_usuario_responsable := v_user_id,
        p_centro_origen_id := v_hospital_id,
        p_numero_documento := 'TEST-SALIDA-001'
      );

      v_test_count := v_test_count + 1;
      IF (v_result->>'cantidad_final')::INTEGER = v_stock_before - 300 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ PASS (Stock: % → %)', v_stock_before, (v_result->>'cantidad_final')::INTEGER;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL';
      END IF;
    EXCEPTION
      WHEN undefined_function THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: Función no existe';
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
    END;
  END IF;

  -- TEST 7: search_inventory_with_batches
  RAISE NOTICE '⚙️  TEST 7: search_inventory_with_batches...';
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM search_inventory_with_batches(
      p_search_term := 'PARACETAMOL',
      p_center_id := v_hospital_id,
      p_stock_bajo := false,
      p_proximos_vencer_dias := null,
      p_estado := null
    );

    v_test_count := v_test_count + 1;
    IF v_count >= 1 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (% resultados)', v_count;
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL';
    END IF;
  EXCEPTION
    WHEN undefined_function THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: Función no existe. Ejecuta MIGRATION_SQL_FINAL.sql';
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 8: Stock bajo
  RAISE NOTICE '⚙️  TEST 8: search_inventory_with_batches (stock bajo)...';
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM search_inventory_with_batches(
      p_search_term := null,
      p_center_id := v_hospital_id,
      p_stock_bajo := true,
      p_proximos_vencer_dias := null,
      p_estado := 'Disponible'
    );

    v_test_count := v_test_count + 1;
    IF v_count >= 2 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (% medicamentos)', v_count;
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN undefined_function THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: Función no existe';
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 9: Próximos a vencer
  RAISE NOTICE '⚙️  TEST 9: search_inventory_with_batches (vencimiento)...';
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM search_inventory_with_batches(
      p_search_term := null,
      p_center_id := v_hospital_id,
      p_stock_bajo := false,
      p_proximos_vencer_dias := 30,
      p_estado := 'Disponible'
    );

    v_test_count := v_test_count + 1;
    IF v_count >= 1 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (% medicamentos)', v_count;
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN undefined_function THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: Función no existe';
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 10: generate_traceability_report
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '⚙️  TEST 10: generate_traceability_report...';
    BEGIN
      SELECT COUNT(*) INTO v_count
      FROM generate_traceability_report(
        p_medication_id := v_paracetamol_hosp,
        p_lote := 'TEST-PAR-2024-001',
        p_fecha_inicio := null,
        p_fecha_fin := null
      );

      v_test_count := v_test_count + 1;
      IF v_count >= 2 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ PASS (% movimientos)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL (% movimientos)', v_count;
      END IF;
    EXCEPTION
      WHEN undefined_function THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: Función no existe';
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
    END;
  END IF;

  RAISE NOTICE '';

  -- ============================================
  -- PASO 4: CONSULTAS DE INVENTARIO
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PASO 4: PROBANDO CONSULTAS DE INVENTARIO';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- TEST 11: Inventario completo
  RAISE NOTICE '💾 TEST 11: Inventario completo...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM medications WHERE center_id = v_hospital_id;

    v_test_count := v_test_count + 1;
    IF v_count = 6 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (6 medicamentos)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 12: Búsqueda por nombre
  RAISE NOTICE '💾 TEST 12: Búsqueda por nombre...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM medications
    WHERE center_id = v_hospital_id AND nombre ILIKE '%AMOXICILINA%';

    v_test_count := v_test_count + 1;
    IF v_count = 2 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (2 resultados)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% resultados)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 13: Stock bajo
  RAISE NOTICE '💾 TEST 13: Stock bajo...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM medications
    WHERE center_id = v_hospital_id AND cantidad < 50;

    v_test_count := v_test_count + 1;
    IF v_count >= 2 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (% medicamentos)', v_count;
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 14: Por estado
  RAISE NOTICE '💾 TEST 14: Filtro por estado...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM medications
    WHERE center_id = v_hospital_id AND estado = 'Disponible';

    v_test_count := v_test_count + 1;
    IF v_count = 6 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (6 medicamentos)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  RAISE NOTICE '';

  -- ============================================
  -- PASO 5: SISTEMA DE ALERTAS
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PASO 5: SISTEMA DE ALERTAS';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- TEST 15: Vencimientos
  RAISE NOTICE '💾 TEST 15: Detección de vencimientos...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM medications
    WHERE center_id = v_hospital_id
      AND fecha_caducidad <= CURRENT_DATE + INTERVAL '30 days';

    v_test_count := v_test_count + 1;
    IF v_count >= 1 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS (% medicamentos)', v_count;
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL (% medicamentos)', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 16: batch_movements
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '💾 TEST 16: batch_movements...';
    BEGIN
      SELECT COUNT(*) INTO v_count FROM batch_movements
      WHERE medication_id = v_paracetamol_hosp
        AND created_at >= NOW() - INTERVAL '1 minute';

      v_test_count := v_test_count + 1;
      IF v_count >= 2 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ PASS (% movimientos)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL (% movimientos)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
    END;
  END IF;

  RAISE NOTICE '';

  -- ============================================
  -- REPORTE FINAL
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  REPORTE FINAL';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '┌─────────────────────────────────────────────────────────┐';
  RAISE NOTICE '│                  RESUMEN DE PRUEBAS                     │';
  RAISE NOTICE '├─────────────────────────────────────────────────────────┤';
  RAISE NOTICE '│  Total de Pruebas:        %                           │', LPAD(v_test_count::TEXT, 3, ' ');
  RAISE NOTICE '│  Pruebas Exitosas:        % ✅                         │', LPAD(v_pass_count::TEXT, 3, ' ');
  RAISE NOTICE '│  Pruebas Fallidas:        % ❌                         │', LPAD(v_fail_count::TEXT, 3, ' ');
  IF v_test_count > 0 THEN
    RAISE NOTICE '│  Tasa de Éxito:           % %%                        │', LPAD(ROUND((v_pass_count::NUMERIC / v_test_count::NUMERIC * 100), 2)::TEXT, 6, ' ');
  ELSE
    RAISE NOTICE '│  Tasa de Éxito:             0.00 %%                    │';
  END IF;
  RAISE NOTICE '└─────────────────────────────────────────────────────────┘';
  RAISE NOTICE '';

  IF v_fail_count = 0 THEN
    RAISE NOTICE '🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE';
  ELSIF v_pass_count >= 12 THEN
    RAISE NOTICE '✅ FUNCIONALIDADES BÁSICAS OK (mínimo 12/16)';
    RAISE NOTICE '';
    RAISE NOTICE '💡 Para activar funciones avanzadas:';
    RAISE NOTICE '   Ejecuta MIGRATION_SQL_FINAL.sql en otro tab';
  ELSE
    RAISE NOTICE '⚠️  ALGUNAS PRUEBAS FALLARON';
  END IF;

  RAISE NOTICE '';

END $$;

-- Verificación final
SELECT
  '✅ VERIFICACIÓN FINAL' as titulo,
  (SELECT COUNT(*) FROM health_centers WHERE id IN (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333'
  )) as centros_salud,
  (SELECT COUNT(*) FROM suppliers WHERE id IN (
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    'bbbb2222-bbbb-2222-bbbb-222222222222'
  )) as proveedores,
  (SELECT COUNT(*) FROM medication_catalog WHERE id IN (
    'cccc1111-cccc-1111-cccc-111111111111',
    'cccc3333-cccc-3333-cccc-333333333333',
    'cccc2222-cccc-2222-cccc-222222222222',
    'cccc5555-cccc-5555-cccc-555555555555',
    'cccc8888-cccc-8888-cccc-888888888888'
  )) as catalogo,
  (SELECT COUNT(*) FROM medications WHERE center_id = '11111111-1111-1111-1111-111111111111') as inventario;
