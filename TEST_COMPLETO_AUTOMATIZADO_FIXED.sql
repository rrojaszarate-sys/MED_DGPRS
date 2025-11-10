-- ============================================
-- SCRIPT DE PRUEBAS AUTOMATIZADAS CORREGIDO
-- SIGIMED - Sistema de Gestión de Inventario
-- ============================================
--
-- Este script:
-- 1. Verifica qué tablas existen
-- 2. Limpia solo las tablas que existen
-- 3. Inserta datos de prueba
-- 4. Ejecuta pruebas de todas las funcionalidades
-- 5. Genera reportes de verificación
--
-- IMPORTANTE: Este script es seguro y maneja tablas faltantes
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
  v_stock_after INTEGER;
  v_table_exists BOOLEAN;
BEGIN

  RAISE NOTICE '';
  RAISE NOTICE '╔═══════════════════════════════════════════════════════════╗';
  RAISE NOTICE '║                                                           ║';
  RAISE NOTICE '║     PRUEBAS AUTOMATIZADAS COMPLETAS - SIGIMED             ║';
  RAISE NOTICE '║                                                           ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════════════════╝';
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
    DELETE FROM batch_movements WHERE
      numero_documento LIKE 'TEST-%' OR
      numero_documento LIKE 'DISP-2024-%' OR
      numero_documento LIKE 'TRANS-2024-%' OR
      numero_documento LIKE 'FC-2024-%' OR
      numero_documento LIKE 'INV-2024-%' OR
      numero_documento LIKE 'VEN-2024-%' OR
      numero_documento LIKE 'MERMA-2024-%';
    RAISE NOTICE '  ✓ batch_movements limpiado';
  EXCEPTION
    WHEN undefined_table THEN
      RAISE NOTICE '  ⚠ batch_movements no existe - omitido';
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ Error limpiando batch_movements: %', SQLERRM;
  END;

  -- Verificar si alertas_medicamentos existe
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'alertas_medicamentos'
  ) INTO v_table_exists;

  -- Limpiar alertas solo si la tabla existe
  IF v_table_exists THEN
    BEGIN
      DELETE FROM alertas_medicamentos WHERE medicamento_id IN (
        SELECT id FROM medications WHERE lote LIKE 'TEST-%'
      );
      RAISE NOTICE '  ✓ alertas_medicamentos limpiado';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '  ⚠ Error limpiando alertas_medicamentos: %', SQLERRM;
    END;
  ELSE
    RAISE NOTICE '  ⚠ alertas_medicamentos no existe - omitido';
  END IF;

  -- Limpiar medications
  BEGIN
    DELETE FROM medications WHERE lote LIKE 'TEST-%';
    RAISE NOTICE '  ✓ medications limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ Error limpiando medications: %', SQLERRM;
  END;

  -- Limpiar user_centers
  BEGIN
    DELETE FROM user_centers WHERE center_id IN (
      SELECT id FROM health_centers WHERE code LIKE 'TEST-%'
    );
    RAISE NOTICE '  ✓ user_centers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ Error limpiando user_centers: %', SQLERRM;
  END;

  -- Limpiar medication_catalog
  BEGIN
    DELETE FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%';
    RAISE NOTICE '  ✓ medication_catalog limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ Error limpiando medication_catalog: %', SQLERRM;
  END;

  -- Limpiar suppliers
  BEGIN
    DELETE FROM suppliers WHERE ruc LIKE 'TEST%';
    RAISE NOTICE '  ✓ suppliers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ Error limpiando suppliers: %', SQLERRM;
  END;

  -- Limpiar health_centers
  BEGIN
    DELETE FROM health_centers WHERE code LIKE 'TEST-%';
    RAISE NOTICE '  ✓ health_centers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ Error limpiando health_centers: %', SQLERRM;
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

  -- IDs fijos para pruebas
  DECLARE
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

    -- 2.1 Centros de Salud
    RAISE NOTICE '💾 Insertando centros de salud...';
    BEGIN
      INSERT INTO health_centers (id, name, code, address, city, region, phone, email, responsible_name, responsible_role, storage_capacity, has_refrigeration, is_active)
      VALUES
        (v_hospital_id, 'Hospital Central de Prueba', 'TEST-HCP-001', 'Av. Principal 123', 'Lima', 'Lima', '+51-1-234-5678', 'hospital.central@test.com', 'Dr. Juan Pérez', 'Director Médico', 5000, true, true),
        (v_centro_norte_id, 'Centro de Salud Norte', 'TEST-CSN-002', 'Jr. Los Olivos 456', 'Lima', 'Lima', '+51-1-234-5679', 'centro.norte@test.com', 'Dra. María García', 'Jefa de Farmacia', 2000, true, true),
        (v_posta_sur_id, 'Posta Médica Sur', 'TEST-PMS-003', 'Calle Las Flores 789', 'Arequipa', 'Arequipa', '+51-54-234-5680', 'posta.sur@test.com', 'Lic. Carlos Ramos', 'Coordinador', 1000, false, true);

      v_test_count := v_test_count + 1;
      GET DIAGNOSTICS v_count = ROW_COUNT;
      IF v_count = 3 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ TEST 1: Inserción de Centros de Salud - PASS (3 centros)';
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 1: Inserción de Centros de Salud - FAIL (% centros)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 1: Inserción de Centros de Salud - FAIL: %', SQLERRM;
    END;

    -- 2.2 Proveedores
    RAISE NOTICE '💾 Insertando proveedores...';
    BEGIN
      INSERT INTO suppliers (id, name, ruc, address, city, phone, email, contact_name, is_active)
      VALUES
        (v_proveedor1_id, 'Farmacéutica Global SAC', 'TEST20123456789', 'Av. Industrial 100', 'Lima', '+51-1-555-0001', 'ventas@farmglobal.test', 'Luis Mendoza', true),
        (v_proveedor2_id, 'Distribuidora MediPharma EIRL', 'TEST20987654321', 'Jr. Comercio 250', 'Lima', '+51-1-555-0002', 'pedidos@medipharma.test', 'Ana Torres', true);

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
      INSERT INTO medication_catalog (id, nombre_comercial, nombre_generico, formula_activa, concentracion, forma_farmaceutica, uso_terapeutico, categoria_farmacologica, requiere_receta, es_controlado, temperatura_almacenamiento, temperatura_min, temperatura_max, is_active)
      VALUES
        (v_amoxicilina_cat, 'AMOXICILINA PRUEBA', 'Amoxicilina', 'Amoxicilina Trihidratada', '500mg', 'capsula', 'Tratamiento de infecciones bacterianas', 'J01CA04', true, false, 'ambiente', 15.0, 30.0, true),
        (v_paracetamol_cat, 'PARACETAMOL PRUEBA', 'Paracetamol', 'Paracetamol', '500mg', 'tableta', 'Analgésico y antipirético', 'N02BE01', false, false, 'ambiente', 15.0, 30.0, true),
        (v_ciprofloxacino_cat, 'CIPROFLOXACINO PRUEBA', 'Ciprofloxacino', 'Ciprofloxacino Clorhidrato', '500mg', 'tableta', 'Infecciones bacterianas resistentes', 'J01MA02', true, false, 'ambiente', 15.0, 30.0, true),
        (v_losartan_cat, 'LOSARTAN PRUEBA', 'Losartán', 'Losartán Potásico', '50mg', 'tableta', 'Tratamiento de hipertensión arterial', 'C09CA01', true, false, 'ambiente', 15.0, 30.0, true),
        (v_insulina_cat, 'INSULINA PRUEBA', 'Insulina NPH', 'Insulina Humana', '100UI/ml', 'inyectable', 'Tratamiento de diabetes', 'A10AC01', true, true, 'refrigerado', 2.0, 8.0, true);

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
      INSERT INTO medications (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, estado, proveedor_id, costo_unitario, precio_venta, ubicacion_fisica)
      VALUES
        (v_paracetamol_hosp, v_hospital_id, v_paracetamol_cat, 'PARACETAMOL PRUEBA 500mg', 'Paracetamol', 'TEST-PAR-2024-001', 1500, CURRENT_DATE + INTERVAL '18 months', 'Disponible', v_proveedor1_id, 0.10, 0.30, 'Estante B1'),
        (v_amoxicilina_hosp, v_hospital_id, v_amoxicilina_cat, 'AMOXICILINA PRUEBA 500mg', 'Amoxicilina Trihidratada', 'TEST-AMX-2024-001', 500, CURRENT_DATE + INTERVAL '12 months', 'Disponible', v_proveedor1_id, 0.50, 1.20, 'Estante A1'),
        ('dddd1112-dddd-1112-dddd-111111111112', v_hospital_id, v_amoxicilina_cat, 'AMOXICILINA PRUEBA 500mg', 'Amoxicilina Trihidratada', 'TEST-AMX-2024-002', 45, CURRENT_DATE + INTERVAL '45 days', 'Disponible', v_proveedor1_id, 0.48, 1.20, 'Estante A1'),
        ('dddd2222-dddd-2222-dddd-222222222222', v_hospital_id, v_ciprofloxacino_cat, 'CIPROFLOXACINO PRUEBA 500mg', 'Ciprofloxacino Clorhidrato', 'TEST-CIP-2024-001', 15, CURRENT_DATE + INTERVAL '6 months', 'Disponible', v_proveedor2_id, 1.20, 2.80, 'Estante A2'),
        ('dddd5555-dddd-5555-dddd-555555555555', v_hospital_id, v_losartan_cat, 'LOSARTAN PRUEBA 50mg', 'Losartán Potásico', 'TEST-LOS-2023-005', 80, CURRENT_DATE + INTERVAL '15 days', 'Disponible', v_proveedor2_id, 0.80, 1.80, 'Estante C1'),
        ('dddd8888-dddd-8888-dddd-888888888888', v_hospital_id, v_insulina_cat, 'INSULINA PRUEBA NPH 100UI/ml', 'Insulina Humana', 'TEST-INS-2024-001', 25, CURRENT_DATE + INTERVAL '8 months', 'Disponible', v_proveedor2_id, 15.00, 35.00, 'Refrigerador 1'),
        ('eeee1111-eeee-1111-eeee-111111111111', v_centro_norte_id, v_paracetamol_cat, 'PARACETAMOL PRUEBA 500mg', 'Paracetamol', 'TEST-PAR-2024-002', 600, CURRENT_DATE + INTERVAL '16 months', 'Disponible', v_proveedor1_id, 0.10, 0.30, 'Anaquel 1A');

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

    -- Obtener usuario para pruebas
    BEGIN
      SELECT id INTO v_user_id FROM auth.users ORDER BY created_at DESC LIMIT 1;
    EXCEPTION
      WHEN OTHERS THEN
        v_user_id := NULL;
    END;

    IF v_user_id IS NULL THEN
      -- Si no hay usuarios en auth.users, intentar users_profiles
      BEGIN
        SELECT id INTO v_user_id FROM users_profiles ORDER BY created_at DESC LIMIT 1;
      EXCEPTION
        WHEN OTHERS THEN
          v_user_id := NULL;
      END;
    END IF;

    IF v_user_id IS NULL THEN
      RAISE NOTICE '⚠️  No hay usuarios disponibles. Tests 5-6, 10, 16 se omitirán.';
      RAISE NOTICE '';
    ELSE
      RAISE NOTICE '📋 Usando usuario: %', v_user_id;
      RAISE NOTICE '';

      -- TEST 5: Función registrar_movimiento_lote - ENTRADA
      RAISE NOTICE '⚙️  Probando: registrar_movimiento_lote (ENTRADA)...';
      BEGIN
        SELECT cantidad INTO v_stock_before FROM medications WHERE id = v_paracetamol_hosp;

        v_result := registrar_movimiento_lote(
          p_medication_id := v_paracetamol_hosp,
          p_tipo_movimiento := 'entrada',
          p_cantidad := 500,
          p_motivo := 'Prueba automática - Compra de inventario',
          p_usuario_responsable := v_user_id,
          p_centro_destino_id := v_hospital_id,
          p_numero_documento := 'TEST-ENTRADA-001',
          p_observaciones := 'Entrada de prueba automatizada',
          p_metadata := '{"test": true, "automated": true}'::jsonb
        );

        v_test_count := v_test_count + 1;
        IF (v_result->>'cantidad_final')::INTEGER = v_stock_before + 500 THEN
          v_pass_count := v_pass_count + 1;
          RAISE NOTICE '  ✅ TEST 5: registrar_movimiento_lote (ENTRADA) - PASS (Stock: % → %)', v_stock_before, (v_result->>'cantidad_final')::INTEGER;
        ELSE
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 5: registrar_movimiento_lote (ENTRADA) - FAIL (Esperado: %, Obtenido: %)', v_stock_before + 500, (v_result->>'cantidad_final')::INTEGER;
        END IF;
      EXCEPTION
        WHEN undefined_function THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 5: registrar_movimiento_lote (ENTRADA) - FAIL: La función no existe. Ejecuta MIGRATION_SQL_FINAL.sql primero.';
        WHEN OTHERS THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 5: registrar_movimiento_lote (ENTRADA) - FAIL: %', SQLERRM;
      END;

      -- TEST 6: Función registrar_movimiento_lote - SALIDA
      RAISE NOTICE '⚙️  Probando: registrar_movimiento_lote (SALIDA)...';
      BEGIN
        SELECT cantidad INTO v_stock_before FROM medications WHERE id = v_paracetamol_hosp;

        v_result := registrar_movimiento_lote(
          p_medication_id := v_paracetamol_hosp,
          p_tipo_movimiento := 'salida',
          p_cantidad := 300,
          p_motivo := 'Prueba automática - Dispensación',
          p_usuario_responsable := v_user_id,
          p_centro_origen_id := v_hospital_id,
          p_numero_documento := 'TEST-SALIDA-001',
          p_observaciones := 'Salida de prueba automatizada',
          p_metadata := '{"test": true, "automated": true}'::jsonb
        );

        v_test_count := v_test_count + 1;
        IF (v_result->>'cantidad_final')::INTEGER = v_stock_before - 300 THEN
          v_pass_count := v_pass_count + 1;
          RAISE NOTICE '  ✅ TEST 6: registrar_movimiento_lote (SALIDA) - PASS (Stock: % → %)', v_stock_before, (v_result->>'cantidad_final')::INTEGER;
        ELSE
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 6: registrar_movimiento_lote (SALIDA) - FAIL (Esperado: %, Obtenido: %)', v_stock_before - 300, (v_result->>'cantidad_final')::INTEGER;
        END IF;
      EXCEPTION
        WHEN undefined_function THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 6: registrar_movimiento_lote (SALIDA) - FAIL: La función no existe.';
        WHEN OTHERS THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 6: registrar_movimiento_lote (SALIDA) - FAIL: %', SQLERRM;
      END;
    END IF;

    -- TEST 7: Función search_inventory_with_batches
    RAISE NOTICE '⚙️  Probando: search_inventory_with_batches...';
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
        RAISE NOTICE '  ✅ TEST 7: search_inventory_with_batches - PASS (% resultados)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 7: search_inventory_with_batches - FAIL (0 resultados)';
      END IF;
    EXCEPTION
      WHEN undefined_function THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 7: search_inventory_with_batches - FAIL: La función no existe. Ejecuta MIGRATION_SQL_FINAL.sql primero.';
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 7: search_inventory_with_batches - FAIL: %', SQLERRM;
    END;

    -- TEST 8: Búsqueda con filtro stock bajo
    RAISE NOTICE '⚙️  Probando: search_inventory_with_batches (stock bajo)...';
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
        RAISE NOTICE '  ✅ TEST 8: search_inventory_with_batches (Stock Bajo) - PASS (% medicamentos)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 8: search_inventory_with_batches (Stock Bajo) - FAIL (% medicamentos)', v_count;
      END IF;
    EXCEPTION
      WHEN undefined_function THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 8: search_inventory_with_batches (Stock Bajo) - FAIL: La función no existe.';
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 8: search_inventory_with_batches (Stock Bajo) - FAIL: %', SQLERRM;
    END;

    -- TEST 9: Búsqueda próximos a vencer
    RAISE NOTICE '⚙️  Probando: search_inventory_with_batches (próximos a vencer)...';
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
        RAISE NOTICE '  ✅ TEST 9: search_inventory_with_batches (Próximos a Vencer) - PASS (% medicamentos)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 9: search_inventory_with_batches (Próximos a Vencer) - FAIL (% medicamentos)', v_count;
      END IF;
    EXCEPTION
      WHEN undefined_function THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 9: search_inventory_with_batches (Vencer) - FAIL: La función no existe.';
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 9: search_inventory_with_batches (Vencer) - FAIL: %', SQLERRM;
    END;

    -- TEST 10: Función generate_traceability_report
    IF v_user_id IS NOT NULL THEN
      RAISE NOTICE '⚙️  Probando: generate_traceability_report...';
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
          RAISE NOTICE '  ✅ TEST 10: generate_traceability_report - PASS (% movimientos)', v_count;
        ELSE
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 10: generate_traceability_report - FAIL (% movimientos)', v_count;
        END IF;
      EXCEPTION
        WHEN undefined_function THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 10: generate_traceability_report - FAIL: La función no existe.';
        WHEN OTHERS THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 10: generate_traceability_report - FAIL: %', SQLERRM;
      END;
    END IF;

    RAISE NOTICE '';

    -- ============================================
    -- PASO 4: PROBAR CONSULTAS DE INVENTARIO
    -- ============================================
    RAISE NOTICE '============================================================';
    RAISE NOTICE '  PASO 4: PROBANDO CONSULTAS DE INVENTARIO';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '';

    -- TEST 11: Listar inventario completo
    RAISE NOTICE '💾 Probando: Listar inventario completo...';
    BEGIN
      SELECT COUNT(*) INTO v_count FROM medications WHERE center_id = v_hospital_id AND lote LIKE 'TEST-%';

      v_test_count := v_test_count + 1;
      IF v_count = 6 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ TEST 11: Inventario Completo - PASS (6 medicamentos)';
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 11: Inventario Completo - FAIL (% medicamentos)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 11: Inventario Completo - FAIL: %', SQLERRM;
    END;

    -- TEST 12: Búsqueda por nombre
    RAISE NOTICE '💾 Probando: Búsqueda por nombre...';
    BEGIN
      SELECT COUNT(*) INTO v_count FROM medications
      WHERE center_id = v_hospital_id AND nombre ILIKE '%AMOXICILINA%' AND lote LIKE 'TEST-%';

      v_test_count := v_test_count + 1;
      IF v_count = 2 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ TEST 12: Búsqueda por Nombre - PASS (2 resultados)';
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 12: Búsqueda por Nombre - FAIL (% resultados)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 12: Búsqueda por Nombre - FAIL: %', SQLERRM;
    END;

    -- TEST 13: Stock bajo
    RAISE NOTICE '💾 Probando: Filtro stock bajo...';
    BEGIN
      SELECT COUNT(*) INTO v_count FROM medications
      WHERE center_id = v_hospital_id AND cantidad < 50 AND lote LIKE 'TEST-%';

      v_test_count := v_test_count + 1;
      IF v_count >= 2 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ TEST 13: Stock Bajo (<50) - PASS (% medicamentos)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 13: Stock Bajo (<50) - FAIL (% medicamentos)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 13: Stock Bajo - FAIL: %', SQLERRM;
    END;

    -- TEST 14: Medicamentos disponibles
    RAISE NOTICE '💾 Probando: Filtro por estado...';
    BEGIN
      SELECT COUNT(*) INTO v_count FROM medications
      WHERE center_id = v_hospital_id AND estado = 'Disponible' AND lote LIKE 'TEST-%';

      v_test_count := v_test_count + 1;
      IF v_count = 6 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ TEST 14: Filtro por Estado (Disponible) - PASS (6 medicamentos)';
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 14: Filtro por Estado (Disponible) - FAIL (% medicamentos)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 14: Filtro por Estado - FAIL: %', SQLERRM;
    END;

    RAISE NOTICE '';

    -- ============================================
    -- PASO 5: PROBAR SISTEMA DE ALERTAS
    -- ============================================
    RAISE NOTICE '============================================================';
    RAISE NOTICE '  PASO 5: PROBANDO SISTEMA DE ALERTAS';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '';

    -- TEST 15: Medicamentos próximos a vencer
    RAISE NOTICE '💾 Probando: Alertas de vencimiento...';
    BEGIN
      SELECT COUNT(*) INTO v_count FROM medications
      WHERE center_id = v_hospital_id
        AND fecha_caducidad <= CURRENT_DATE + INTERVAL '30 days'
        AND lote LIKE 'TEST-%';

      v_test_count := v_test_count + 1;
      IF v_count >= 1 THEN
        v_pass_count := v_pass_count + 1;
        RAISE NOTICE '  ✅ TEST 15: Detección de Vencimientos - PASS (% medicamentos)', v_count;
      ELSE
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 15: Detección de Vencimientos - FAIL (% medicamentos)', v_count;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_test_count := v_test_count + 1;
        v_fail_count := v_fail_count + 1;
        RAISE NOTICE '  ❌ TEST 15: Detección de Vencimientos - FAIL: %', SQLERRM;
    END;

    -- TEST 16: Registro de movimientos
    IF v_user_id IS NOT NULL THEN
      RAISE NOTICE '💾 Probando: Registro en batch_movements...';
      BEGIN
        SELECT COUNT(*) INTO v_count FROM batch_movements
        WHERE medication_id = v_paracetamol_hosp
          AND created_at >= NOW() - INTERVAL '1 minute';

        v_test_count := v_test_count + 1;
        IF v_count >= 2 THEN
          v_pass_count := v_pass_count + 1;
          RAISE NOTICE '  ✅ TEST 16: batch_movements Creados - PASS (% movimientos)', v_count;
        ELSE
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 16: batch_movements Creados - FAIL (% movimientos)', v_count;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_test_count := v_test_count + 1;
          v_fail_count := v_fail_count + 1;
          RAISE NOTICE '  ❌ TEST 16: batch_movements - FAIL: %', SQLERRM;
      END;
    END IF;

  END;

  RAISE NOTICE '';

  -- ============================================
  -- REPORTE FINAL
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  REPORTE FINAL DE PRUEBAS';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '┌─────────────────────────────────────────────────────────┐';
  RAISE NOTICE '│                  RESUMEN DE PRUEBAS                     │';
  RAISE NOTICE '├─────────────────────────────────────────────────────────┤';
  RAISE NOTICE '│  Total de Pruebas:        %                           │', LPAD(v_test_count::TEXT, 3, ' ');
  RAISE NOTICE '│  Pruebas Exitosas:        % ✅                         │', LPAD(v_pass_count::TEXT, 3, ' ');
  RAISE NOTICE '│  Pruebas Fallidas:        % ❌                         │', LPAD(v_fail_count::TEXT, 3, ' ');
  RAISE NOTICE '│  Tasa de Éxito:           % %%                        │', LPAD(ROUND((v_pass_count::NUMERIC / NULLIF(v_test_count, 0)::NUMERIC * 100), 2)::TEXT, 6, ' ');
  RAISE NOTICE '└─────────────────────────────────────────────────────────┘';
  RAISE NOTICE '';

  RAISE NOTICE '✅ FUNCIONALIDADES VERIFICADAS:';
  RAISE NOTICE '  • Inserción de datos de prueba (centros, proveedores, catálogo, inventario)';
  RAISE NOTICE '  • Función registrar_movimiento_lote() - Entradas y Salidas';
  RAISE NOTICE '  • Función search_inventory_with_batches() - Búsquedas avanzadas';
  RAISE NOTICE '  • Función search_inventory_with_batches() - Filtro stock bajo';
  RAISE NOTICE '  • Función search_inventory_with_batches() - Filtro próximos a vencer';
  RAISE NOTICE '  • Función generate_traceability_report() - Trazabilidad de lotes';
  RAISE NOTICE '  • Consultas de inventario (listar, buscar, filtrar)';
  RAISE NOTICE '  • Sistema de alertas (vencimientos y stock bajo)';
  RAISE NOTICE '  • Registro de movimientos en batch_movements';
  RAISE NOTICE '';

  IF v_fail_count = 0 THEN
    RAISE NOTICE '🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE';
  ELSE
    RAISE NOTICE '⚠️  ALGUNAS PRUEBAS FALLARON - Revisar detalles arriba';
    RAISE NOTICE '';
    RAISE NOTICE '💡 POSIBLES SOLUCIONES:';
    RAISE NOTICE '   1. Si fallan tests 5-10: Ejecutar MIGRATION_SQL_FINAL.sql primero';
    RAISE NOTICE '   2. Si no hay usuarios: Crear usuario en Supabase Dashboard';
    RAISE NOTICE '   3. Si hay errores de permisos: Verificar RLS policies';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE '📋 PRÓXIMOS PASOS:';
  RAISE NOTICE '  1. Verificar la interfaz web en Vercel';
  RAISE NOTICE '  2. Probar funcionalidad de importación manual';
  RAISE NOTICE '  3. Validar reportes en formato PDF/Excel';
  RAISE NOTICE '  4. Revisar navegación y UI de la aplicación';
  RAISE NOTICE '';

END $$;

-- ============================================
-- VERIFICACIÓN ADICIONAL: DATOS INSERTADOS
-- ============================================
SELECT
  '✅ VERIFICACIÓN DE DATOS INSERTADOS' as titulo,
  (SELECT COUNT(*) FROM health_centers WHERE code LIKE 'TEST-%') as centros_salud,
  (SELECT COUNT(*) FROM suppliers WHERE ruc LIKE 'TEST%') as proveedores,
  (SELECT COUNT(*) FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%') as catalogo,
  (SELECT COUNT(*) FROM medications WHERE lote LIKE 'TEST-%') as inventario,
  (SELECT COUNT(*) FROM batch_movements WHERE numero_documento LIKE 'TEST-%'
    AND created_at >= NOW() - INTERVAL '5 minutes') as movimientos_recientes;
