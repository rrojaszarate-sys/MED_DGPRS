-- ============================================
-- VERIFICAR SCHEMA DE SIGIMED
-- ============================================
-- Este script verifica si el schema base está instalado correctamente

DO $$
DECLARE
  v_health_centers_exists BOOLEAN;
  v_users_profiles_exists BOOLEAN;
  v_suppliers_exists BOOLEAN;
  v_medication_catalog_exists BOOLEAN;
  v_medications_exists BOOLEAN;
  v_alertas_medicamentos_exists BOOLEAN;
  v_batch_movements_exists BOOLEAN;
  v_transfers_exists BOOLEAN;
  v_audit_log_exists BOOLEAN;

  v_health_centers_has_code BOOLEAN;

  v_func_registrar_movimiento BOOLEAN;
  v_func_search_inventory BOOLEAN;
  v_func_generate_traceability BOOLEAN;

  v_tablas_faltantes INTEGER := 0;
  v_funciones_faltantes INTEGER := 0;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  VERIFICACIÓN DE SCHEMA - SIGIMED';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- ============================================
  -- VERIFICAR TABLAS BASE
  -- ============================================

  RAISE NOTICE '📋 VERIFICANDO TABLAS BASE...';
  RAISE NOTICE '';

  -- Health Centers
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'health_centers'
  ) INTO v_health_centers_exists;

  RAISE NOTICE '  %-30s %s', 'health_centers',
    CASE WHEN v_health_centers_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;

  IF NOT v_health_centers_exists THEN
    v_tablas_faltantes := v_tablas_faltantes + 1;
  ELSE
    -- Verificar columna 'code'
    SELECT EXISTS (
      SELECT FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'health_centers'
      AND column_name = 'code'
    ) INTO v_health_centers_has_code;

    RAISE NOTICE '    %-28s %s', 'columna "code"',
      CASE WHEN v_health_centers_has_code THEN '✅ Existe' ELSE '❌ NO EXISTE' END;

    IF NOT v_health_centers_has_code THEN
      v_tablas_faltantes := v_tablas_faltantes + 1;
    END IF;
  END IF;

  -- Users Profiles
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'users_profiles'
  ) INTO v_users_profiles_exists;

  RAISE NOTICE '  %-30s %s', 'users_profiles',
    CASE WHEN v_users_profiles_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_users_profiles_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Suppliers
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'suppliers'
  ) INTO v_suppliers_exists;

  RAISE NOTICE '  %-30s %s', 'suppliers',
    CASE WHEN v_suppliers_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_suppliers_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Medication Catalog
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'medication_catalog'
  ) INTO v_medication_catalog_exists;

  RAISE NOTICE '  %-30s %s', 'medication_catalog',
    CASE WHEN v_medication_catalog_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_medication_catalog_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Medications
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'medications'
  ) INTO v_medications_exists;

  RAISE NOTICE '  %-30s %s', 'medications',
    CASE WHEN v_medications_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_medications_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Alertas Medicamentos
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'alertas_medicamentos'
  ) INTO v_alertas_medicamentos_exists;

  RAISE NOTICE '  %-30s %s', 'alertas_medicamentos',
    CASE WHEN v_alertas_medicamentos_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_alertas_medicamentos_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Batch Movements
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'batch_movements'
  ) INTO v_batch_movements_exists;

  RAISE NOTICE '  %-30s %s', 'batch_movements',
    CASE WHEN v_batch_movements_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_batch_movements_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Transfers
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'transfers'
  ) INTO v_transfers_exists;

  RAISE NOTICE '  %-30s %s', 'transfers',
    CASE WHEN v_transfers_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_transfers_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  -- Audit Log
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'audit_log'
  ) INTO v_audit_log_exists;

  RAISE NOTICE '  %-30s %s', 'audit_log',
    CASE WHEN v_audit_log_exists THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_audit_log_exists THEN v_tablas_faltantes := v_tablas_faltantes + 1; END IF;

  RAISE NOTICE '';

  -- ============================================
  -- VERIFICAR FUNCIONES SQL
  -- ============================================

  RAISE NOTICE '⚙️  VERIFICANDO FUNCIONES SQL...';
  RAISE NOTICE '';

  -- registrar_movimiento_lote
  SELECT EXISTS (
    SELECT FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name = 'registrar_movimiento_lote'
    AND routine_type = 'FUNCTION'
  ) INTO v_func_registrar_movimiento;

  RAISE NOTICE '  %-30s %s', 'registrar_movimiento_lote',
    CASE WHEN v_func_registrar_movimiento THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_func_registrar_movimiento THEN v_funciones_faltantes := v_funciones_faltantes + 1; END IF;

  -- search_inventory_with_batches
  SELECT EXISTS (
    SELECT FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name = 'search_inventory_with_batches'
    AND routine_type = 'FUNCTION'
  ) INTO v_func_search_inventory;

  RAISE NOTICE '  %-30s %s', 'search_inventory_with_batches',
    CASE WHEN v_func_search_inventory THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_func_search_inventory THEN v_funciones_faltantes := v_funciones_faltantes + 1; END IF;

  -- generate_traceability_report
  SELECT EXISTS (
    SELECT FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name = 'generate_traceability_report'
    AND routine_type = 'FUNCTION'
  ) INTO v_func_generate_traceability;

  RAISE NOTICE '  %-30s %s', 'generate_traceability_report',
    CASE WHEN v_func_generate_traceability THEN '✅ Existe' ELSE '❌ NO EXISTE' END;
  IF NOT v_func_generate_traceability THEN v_funciones_faltantes := v_funciones_faltantes + 1; END IF;

  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '  RESULTADO FINAL';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

  -- ============================================
  -- RESULTADO Y RECOMENDACIONES
  -- ============================================

  IF v_tablas_faltantes = 0 AND v_funciones_faltantes = 0 THEN
    RAISE NOTICE '🎉 ¡SCHEMA COMPLETO INSTALADO CORRECTAMENTE!';
    RAISE NOTICE '';
    RAISE NOTICE '✅ Todas las tablas existen';
    RAISE NOTICE '✅ Todas las funciones existen';
    RAISE NOTICE '';
    RAISE NOTICE '👉 SIGUIENTE PASO: Ejecutar TEST_COMPLETO.sql para probar funcionalidades';

  ELSIF v_tablas_faltantes > 0 AND v_funciones_faltantes > 0 THEN
    RAISE NOTICE '⚠️  SCHEMA NO INSTALADO - ACCIÓN REQUERIDA';
    RAISE NOTICE '';
    RAISE NOTICE '❌ Tablas faltantes: % de 9', v_tablas_faltantes;
    RAISE NOTICE '❌ Funciones faltantes: % de 3', v_funciones_faltantes;
    RAISE NOTICE '';
    RAISE NOTICE '📋 INSTRUCCIONES:';
    RAISE NOTICE '';
    RAISE NOTICE '  1️⃣  PRIMERO ejecuta: database-schema.sql';
    RAISE NOTICE '      (Crea todas las tablas base del sistema)';
    RAISE NOTICE '';
    RAISE NOTICE '  2️⃣  LUEGO ejecuta: MIGRATION_SQL_FINAL.sql';
    RAISE NOTICE '      (Instala funciones avanzadas y triggers)';
    RAISE NOTICE '';
    RAISE NOTICE '  3️⃣  FINALMENTE ejecuta: TEST_COMPLETO.sql';
    RAISE NOTICE '      (Prueba todo el sistema)';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Sin el schema base, los tests NO funcionarán.';

  ELSIF v_tablas_faltantes > 0 THEN
    RAISE NOTICE '⚠️  TABLAS BASE FALTANTES';
    RAISE NOTICE '';
    RAISE NOTICE '❌ Tablas faltantes: % de 9', v_tablas_faltantes;
    RAISE NOTICE '✅ Funciones OK: 3 de 3';
    RAISE NOTICE '';
    RAISE NOTICE '📋 ACCIÓN REQUERIDA:';
    RAISE NOTICE '  Ejecuta: database-schema.sql';

  ELSIF v_funciones_faltantes > 0 THEN
    RAISE NOTICE '⚠️  FUNCIONES SQL FALTANTES';
    RAISE NOTICE '';
    RAISE NOTICE '✅ Tablas OK: 9 de 9';
    RAISE NOTICE '❌ Funciones faltantes: % de 3', v_funciones_faltantes;
    RAISE NOTICE '';
    RAISE NOTICE '📋 ACCIÓN REQUERIDA:';
    RAISE NOTICE '  Ejecuta: MIGRATION_SQL_FINAL.sql';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';

END $$;
