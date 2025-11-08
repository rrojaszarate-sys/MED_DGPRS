-- ============================================
-- PRUEBA MÍNIMA - SOLO LO ESENCIAL
-- ============================================
-- Este script solo prueba las tablas que SEGURO existen
-- y muestra información útil sobre tu base de datos
-- ============================================

DO $$
DECLARE
  v_test_count INTEGER := 0;
  v_pass_count INTEGER := 0;
  v_fail_count INTEGER := 0;
  v_table_exists BOOLEAN;
  v_count INTEGER;

  -- IDs de prueba
  v_hospital_id UUID := '11111111-1111-1111-1111-111111111111';
  v_paracetamol_cat UUID := 'cccc3333-cccc-3333-cccc-333333333333';
  v_paracetamol_med UUID := 'dddd3333-dddd-3333-dddd-333333333333';
BEGIN

  RAISE NOTICE '';
  RAISE NOTICE '╔═══════════════════════════════════════════════════════════╗';
  RAISE NOTICE '║     PRUEBA MÍNIMA - SIGIMED                               ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════════════════╝';
  RAISE NOTICE '';

  -- ============================================
  -- PARTE 1: DESCUBRIR QUÉ TABLAS EXISTEN
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  DESCUBRIENDO SCHEMA DE LA BASE DE DATOS';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- Verificar health_centers
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'health_centers'
  ) INTO v_table_exists;
  RAISE NOTICE '  health_centers:        %', CASE WHEN v_table_exists THEN '✅ Existe' ELSE '❌ No existe' END;

  -- Verificar medications
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'medications'
  ) INTO v_table_exists;
  RAISE NOTICE '  medications:           %', CASE WHEN v_table_exists THEN '✅ Existe' ELSE '❌ No existe' END;

  -- Verificar medication_catalog
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'medication_catalog'
  ) INTO v_table_exists;
  RAISE NOTICE '  medication_catalog:    %', CASE WHEN v_table_exists THEN '✅ Existe' ELSE '❌ No existe' END;

  -- Verificar batch_movements
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'batch_movements'
  ) INTO v_table_exists;
  RAISE NOTICE '  batch_movements:       %', CASE WHEN v_table_exists THEN '✅ Existe' ELSE '❌ No existe' END;

  -- Verificar suppliers
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'suppliers'
  ) INTO v_table_exists;
  RAISE NOTICE '  suppliers:             %', CASE WHEN v_table_exists THEN '✅ Existe' ELSE '❌ No existe' END;

  -- Verificar users_profiles
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'users_profiles'
  ) INTO v_table_exists;
  RAISE NOTICE '  users_profiles:        %', CASE WHEN v_table_exists THEN '✅ Existe' ELSE '❌ No existe' END;

  RAISE NOTICE '';

  -- ============================================
  -- PARTE 2: LIMPIAR DATOS DE PRUEBA
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  LIMPIANDO DATOS DE PRUEBA ANTERIORES';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- Limpiar medications
  BEGIN
    DELETE FROM medications WHERE id = v_paracetamol_med;
    RAISE NOTICE '  ✓ medications limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ medications: %', SQLERRM;
  END;

  -- Limpiar medication_catalog
  BEGIN
    DELETE FROM medication_catalog WHERE id = v_paracetamol_cat;
    RAISE NOTICE '  ✓ medication_catalog limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ medication_catalog: %', SQLERRM;
  END;

  -- Limpiar health_centers
  BEGIN
    DELETE FROM health_centers WHERE id = v_hospital_id;
    RAISE NOTICE '  ✓ health_centers limpiado';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '  ⚠ health_centers: %', SQLERRM;
  END;

  RAISE NOTICE '';

  -- ============================================
  -- PARTE 3: INSERTAR DATOS DE PRUEBA
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  INSERTANDO DATOS DE PRUEBA';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- TEST 1: Insertar health_center
  RAISE NOTICE '🧪 TEST 1: Insertar Centro de Salud...';
  BEGIN
    -- Verificar columnas disponibles
    SELECT EXISTS (
      SELECT FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'health_centers'
      AND column_name = 'code'
    ) INTO v_table_exists;

    IF v_table_exists THEN
      -- Con columna code
      INSERT INTO health_centers (id, name, code, city, is_active)
      VALUES (v_hospital_id, 'Hospital Central de Prueba', 'TEST-001', 'Lima', true);
    ELSE
      -- Sin columna code
      INSERT INTO health_centers (id, name, city, is_active)
      VALUES (v_hospital_id, 'Hospital Central de Prueba', 'Lima', true);
    END IF;

    v_test_count := v_test_count + 1;
    v_pass_count := v_pass_count + 1;
    RAISE NOTICE '  ✅ PASS - Centro insertado';
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 2: Insertar medication_catalog
  RAISE NOTICE '🧪 TEST 2: Insertar Catálogo...';
  BEGIN
    INSERT INTO medication_catalog (id, nombre_comercial, nombre_generico, formula_activa, forma_farmaceutica, is_active)
    VALUES (v_paracetamol_cat, 'PARACETAMOL PRUEBA', 'Paracetamol', 'Paracetamol', 'tableta', true);

    v_test_count := v_test_count + 1;
    v_pass_count := v_pass_count + 1;
    RAISE NOTICE '  ✅ PASS - Catálogo insertado';
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 3: Insertar medication
  RAISE NOTICE '🧪 TEST 3: Insertar Medicamento...';
  BEGIN
    INSERT INTO medications (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, estado)
    VALUES (v_paracetamol_med, v_hospital_id, v_paracetamol_cat, 'PARACETAMOL PRUEBA 500mg', 'Paracetamol', 'TEST-001', 100, CURRENT_DATE + INTERVAL '1 year', 'Disponible');

    v_test_count := v_test_count + 1;
    v_pass_count := v_pass_count + 1;
    RAISE NOTICE '  ✅ PASS - Medicamento insertado';
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  RAISE NOTICE '';

  -- ============================================
  -- PARTE 4: CONSULTAS BÁSICAS
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PROBANDO CONSULTAS BÁSICAS';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- TEST 4: Leer health_center
  RAISE NOTICE '🧪 TEST 4: Consultar Centro...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM health_centers WHERE id = v_hospital_id;

    v_test_count := v_test_count + 1;
    IF v_count = 1 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS - Centro encontrado';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL - Centro no encontrado';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 5: Leer medication
  RAISE NOTICE '🧪 TEST 5: Consultar Medicamento...';
  BEGIN
    SELECT COUNT(*) INTO v_count FROM medications WHERE id = v_paracetamol_med;

    v_test_count := v_test_count + 1;
    IF v_count = 1 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS - Medicamento encontrado';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL - Medicamento no encontrado';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 6: Actualizar cantidad
  RAISE NOTICE '🧪 TEST 6: Actualizar Stock...';
  BEGIN
    UPDATE medications SET cantidad = 150 WHERE id = v_paracetamol_med;

    SELECT cantidad INTO v_count FROM medications WHERE id = v_paracetamol_med;

    v_test_count := v_test_count + 1;
    IF v_count = 150 THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS - Stock actualizado (100 → 150)';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL - Stock: %', v_count;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  RAISE NOTICE '';

  -- ============================================
  -- PARTE 5: FUNCIONES SQL
  -- ============================================
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  PROBANDO FUNCIONES SQL';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- TEST 7: Verificar si existe registrar_movimiento_lote
  RAISE NOTICE '🧪 TEST 7: Función registrar_movimiento_lote...';
  BEGIN
    SELECT EXISTS (
      SELECT FROM information_schema.routines
      WHERE routine_schema = 'public'
      AND routine_name = 'registrar_movimiento_lote'
    ) INTO v_table_exists;

    v_test_count := v_test_count + 1;
    IF v_table_exists THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS - Función existe';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL - Función NO existe';
      RAISE NOTICE '     💡 Ejecuta MIGRATION_SQL_FINAL.sql para instalarla';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

  -- TEST 8: Verificar search_inventory_with_batches
  RAISE NOTICE '🧪 TEST 8: Función search_inventory_with_batches...';
  BEGIN
    SELECT EXISTS (
      SELECT FROM information_schema.routines
      WHERE routine_schema = 'public'
      AND routine_name = 'search_inventory_with_batches'
    ) INTO v_table_exists;

    v_test_count := v_test_count + 1;
    IF v_table_exists THEN
      v_pass_count := v_pass_count + 1;
      RAISE NOTICE '  ✅ PASS - Función existe';
    ELSE
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL - Función NO existe';
      RAISE NOTICE '     💡 Ejecuta MIGRATION_SQL_FINAL.sql para instalarla';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_test_count := v_test_count + 1;
      v_fail_count := v_fail_count + 1;
      RAISE NOTICE '  ❌ FAIL: %', SQLERRM;
  END;

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
  END IF;
  RAISE NOTICE '└─────────────────────────────────────────────────────────┘';
  RAISE NOTICE '';

  IF v_pass_count >= 6 THEN
    RAISE NOTICE '🎉 FUNCIONALIDADES BÁSICAS OK';
    RAISE NOTICE '';
    RAISE NOTICE '📋 SIGUIENTE PASO:';
    RAISE NOTICE '   1. Ejecuta MIGRATION_SQL_FINAL.sql para añadir funciones avanzadas';
    RAISE NOTICE '   2. Verifica la interfaz en Vercel';
  ELSIF v_pass_count >= 3 THEN
    RAISE NOTICE '✅ CONEXIÓN Y TABLAS OK';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Algunas funcionalidades faltan';
    RAISE NOTICE '   Ejecuta MIGRATION_SQL_FINAL.sql';
  ELSE
    RAISE NOTICE '⚠️  REVISAR CONFIGURACIÓN';
    RAISE NOTICE '';
    RAISE NOTICE '💡 Posibles problemas:';
    RAISE NOTICE '   • Las tablas no están creadas';
    RAISE NOTICE '   • Permisos insuficientes';
    RAISE NOTICE '   • Schema incorrecto';
  END IF;

  RAISE NOTICE '';

END $$;

-- Información adicional
SELECT
  '📊 INFORMACIÓN DE LA BASE DE DATOS' as titulo,
  (SELECT COUNT(*) FROM health_centers) as total_centros,
  (SELECT COUNT(*) FROM medication_catalog) as total_catalogo,
  (SELECT COUNT(*) FROM medications) as total_medicamentos,
  (SELECT COUNT(*) FROM users_profiles) as total_usuarios;
