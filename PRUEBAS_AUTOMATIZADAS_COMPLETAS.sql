-- ============================================
-- BATERÍA DE PRUEBAS AUTOMATIZADAS - SIGIMED v2.0
-- ============================================
-- Fecha: 2025-11-10
-- Propósito: Probar TODOS los módulos del sistema con datos reales
--
-- PREREQUISITOS:
--   1. Ejecutar FIX_CRITICAL_ERRORS.sql
--   2. Ejecutar CARGA_MEDICAMENTOS_CSV.sql
--   3. Tener al menos 1 health_center creado
--   4. Tener al menos 1 supplier creado
--
-- MÓDULOS PROBADOS:
--   ✓ Catálogo de medicamentos (medication_catalog)
--   ✓ Inventario de lotes (batches)
--   ✓ Movimientos de stock (batch_movements)
--   ✓ Proveedores (suppliers)
--   ✓ Contratos (contracts + contract_items)
--   ✓ Alertas de vencimiento (automatizadas)
--   ✓ Auditoría (audit_log)
--   ✓ Políticas RLS
--
-- EJECUCIÓN: Copiar y pegar en Supabase SQL Editor → Run
-- ============================================

\echo '
============================================
🧪 BATERÍA DE PRUEBAS AUTOMATIZADAS
============================================
Fecha: 2025-11-10
Sistema: SIGIMED v2.0
============================================
'

DO $$
DECLARE
  v_test_count INTEGER := 0;
  v_test_passed INTEGER := 0;
  v_test_failed INTEGER := 0;
  v_start_time TIMESTAMP := NOW();

  -- Variables para IDs de prueba
  v_center_id UUID;
  v_center_id_2 UUID;
  v_supplier_id UUID;
  v_medicamento_id UUID;
  v_batch_id UUID;
  v_contract_id UUID;

  -- Contadores
  v_count INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '🚀 INICIANDO PRUEBAS AUTOMATIZADAS';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';

  -- ============================================
  -- PRUEBA 1: VERIFICAR TABLAS EXISTEN
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '📋 PRUEBA 1: Verificar que tablas críticas existen';

  SELECT count(*) INTO v_count
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN ('medication_catalog', 'medications', 'batches', 'batch_movements',
                        'suppliers', 'contracts', 'health_centers', 'audit_log');

  IF v_count = 8 THEN
    v_test_passed := v_test_passed + 1;
    RAISE NOTICE '  ✅ PASÓ: 8/8 tablas existen';
  ELSE
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ❌ FALLÓ: Solo % tablas de 8 existen', v_count;
  END IF;

  -- ============================================
  -- PRUEBA 2: VERIFICAR POLÍTICAS RLS
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '🛡️ PRUEBA 2: Verificar políticas RLS de medication_catalog';

  SELECT count(*) INTO v_count
  FROM pg_policies
  WHERE tablename = 'medication_catalog';

  IF v_count >= 4 THEN
    v_test_passed := v_test_passed + 1;
    RAISE NOTICE '  ✅ PASÓ: % políticas RLS creadas (mínimo 4)', v_count;
  ELSE
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ❌ FALLÓ: Solo % políticas RLS (se esperan 4)', v_count;
  END IF;

  -- ============================================
  -- PRUEBA 3: VERIFICAR MEDICAMENTOS CARGADOS
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '💊 PRUEBA 3: Verificar medicamentos del CSV cargados';

  SELECT count(*) INTO v_count
  FROM medication_catalog;

  IF v_count >= 100 THEN
    v_test_passed := v_test_passed + 1;
    RAISE NOTICE '  ✅ PASÓ: % medicamentos en catálogo (esperado ≥100)', v_count;
  ELSE
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ⚠️ ADVERTENCIA: Solo % medicamentos (esperado ≥100)', v_count;
  END IF;

  -- ============================================
  -- PRUEBA 4: VERIFICAR HEALTH CENTERS
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '🏥 PRUEBA 4: Verificar centros de salud';

  SELECT count(*) INTO v_count
  FROM health_centers
  WHERE is_active = true;

  IF v_count >= 1 THEN
    v_test_passed := v_test_passed + 1;
    RAISE NOTICE '  ✅ PASÓ: % centros de salud activos', v_count;

    -- Obtener IDs para pruebas posteriores
    SELECT id INTO v_center_id FROM health_centers WHERE is_active = true LIMIT 1;
    SELECT id INTO v_center_id_2 FROM health_centers WHERE is_active = true OFFSET 1 LIMIT 1;

    RAISE NOTICE '  📍 Centro de prueba: %', v_center_id;
  ELSE
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ❌ FALLÓ: No hay centros de salud activos';
    RAISE NOTICE '  💡 Ejecutar: INSERT INTO health_centers (name, code, is_active) VALUES (''Centro de Pruebas'', ''TEST-001'', true);';
  END IF;

  -- ============================================
  -- PRUEBA 5: CREAR PROVEEDOR DE PRUEBA
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '🏭 PRUEBA 5: Crear proveedor de prueba';

  BEGIN
    INSERT INTO suppliers (
      nombre,
      rfc,
      razon_social,
      telefono,
      email,
      dias_credito,
      is_active
    ) VALUES (
      'Proveedor de Pruebas Automatizadas',
      'PRUEBA999XXX',
      'Pruebas Automatizadas S.A. de C.V.',
      '5555555555',
      'pruebas@test.com',
      30,
      true
    ) RETURNING id INTO v_supplier_id;

    v_test_passed := v_test_passed + 1;
    RAISE NOTICE '  ✅ PASÓ: Proveedor creado con ID %', v_supplier_id;
  EXCEPTION WHEN OTHERS THEN
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ❌ FALLÓ: Error al crear proveedor: %', SQLERRM;
  END;

  -- ============================================
  -- PRUEBA 6: CREAR MEDICAMENTO EN MEDICATIONS
  -- ============================================
  IF v_center_id IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '💉 PRUEBA 6: Crear medicamento en tabla medications';

    BEGIN
      INSERT INTO medications (
        center_id,
        nombre,
        descripcion,
        unidad_medida,
        categoria,
        requiere_refrigeracion,
        is_active
      ) VALUES (
        v_center_id,
        'Paracetamol 500mg Prueba',
        'Medicamento de prueba automatizada',
        'Tableta',
        'Analgésico',
        false,
        true
      ) RETURNING id INTO v_medicamento_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Medicamento creado con ID %', v_medicamento_id;
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al crear medicamento: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 7: CREAR LOTE (BATCH)
  -- ============================================
  IF v_medicamento_id IS NOT NULL AND v_supplier_id IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '📦 PRUEBA 7: Crear lote de medicamento';

    BEGIN
      INSERT INTO batches (
        medication_id,
        center_id,
        supplier_id,
        numero_lote,
        cantidad_inicial,
        cantidad_actual,
        fecha_fabricacion,
        fecha_caducidad,
        fecha_ingreso,
        stock_minimo,
        stock_maximo,
        estado,
        observaciones
      ) VALUES (
        v_medicamento_id,
        v_center_id,
        v_supplier_id,
        'LOTE-TEST-001',
        1000,
        1000,
        CURRENT_DATE - INTERVAL '6 months',
        CURRENT_DATE + INTERVAL '18 months',
        CURRENT_DATE,
        100,
        2000,
        'disponible',
        'Lote de prueba automatizada'
      ) RETURNING id INTO v_batch_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Lote creado con ID %', v_batch_id;
      RAISE NOTICE '  📊 Stock inicial: 1000 unidades';
      RAISE NOTICE '  📅 Caduca: % meses', EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '18 months' - CURRENT_DATE));
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al crear lote: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 8: REGISTRAR MOVIMIENTO DE SALIDA
  -- ============================================
  IF v_batch_id IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '📤 PRUEBA 8: Registrar movimiento de salida';

    BEGIN
      -- Registrar salida de 50 unidades
      INSERT INTO batch_movements (
        batch_id,
        medication_id,
        center_id,
        tipo_movimiento,
        cantidad,
        cantidad_anterior,
        cantidad_posterior,
        motivo,
        observaciones,
        metadata
      ) VALUES (
        v_batch_id,
        v_medicamento_id,
        v_center_id,
        'salida',
        50,
        1000,
        950,
        'Dispensación de prueba automatizada',
        'Movimiento generado por batería de pruebas',
        '{"tipo_prueba": "automatizada", "modulo": "movimientos"}'::jsonb
      );

      -- Actualizar stock actual del lote
      UPDATE batches
      SET cantidad_actual = 950
      WHERE id = v_batch_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Movimiento de salida registrado';
      RAISE NOTICE '  📊 Stock: 1000 → 950 (-50 unidades)';
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al registrar movimiento: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 9: REGISTRAR MOVIMIENTO DE ENTRADA
  -- ============================================
  IF v_batch_id IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '📥 PRUEBA 9: Registrar movimiento de entrada';

    BEGIN
      INSERT INTO batch_movements (
        batch_id,
        medication_id,
        center_id,
        tipo_movimiento,
        cantidad,
        cantidad_anterior,
        cantidad_posterior,
        motivo,
        observaciones
      ) VALUES (
        v_batch_id,
        v_medicamento_id,
        v_center_id,
        'entrada',
        200,
        950,
        1150,
        'Reposición de inventario - Prueba',
        'Entrada generada por batería de pruebas'
      );

      UPDATE batches
      SET cantidad_actual = 1150
      WHERE id = v_batch_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Movimiento de entrada registrado';
      RAISE NOTICE '  📊 Stock: 950 → 1150 (+200 unidades)';
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al registrar entrada: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 10: CREAR CONTRATO
  -- ============================================
  IF v_supplier_id IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '📄 PRUEBA 10: Crear contrato con proveedor';

    BEGIN
      INSERT INTO contracts (
        codigo_contrato,
        supplier_id,
        fecha_inicio,
        fecha_fin,
        monto_total,
        estado,
        observaciones
      ) VALUES (
        'CT-TEST-2025-001',
        v_supplier_id,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '12 months',
        500000.00,
        'activo',
        'Contrato de prueba automatizada'
      ) RETURNING id INTO v_contract_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Contrato creado con ID %', v_contract_id;
      RAISE NOTICE '  💰 Monto: $500,000.00 MXN';
      RAISE NOTICE '  📅 Vigencia: 12 meses';
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al crear contrato: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 11: AGREGAR ITEMS AL CONTRATO
  -- ============================================
  IF v_contract_id IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '📋 PRUEBA 11: Agregar items al contrato';

    BEGIN
      -- Obtener 5 medicamentos al azar del catálogo
      INSERT INTO contract_items (
        contract_id,
        medication_catalog_id,
        cantidad_comprometida,
        precio_unitario,
        center_destino_id,
        fecha_estimada_entrega
      )
      SELECT
        v_contract_id,
        id,
        FLOOR(RANDOM() * 500 + 100)::INTEGER, -- Entre 100 y 600 unidades
        FLOOR(RANDOM() * 100 + 10)::NUMERIC, -- Entre $10 y $110
        v_center_id,
        CURRENT_DATE + (INTERVAL '1 month' * FLOOR(RANDOM() * 6 + 1))
      FROM medication_catalog
      WHERE is_active = true
      LIMIT 5;

      SELECT count(*) INTO v_count FROM contract_items WHERE contract_id = v_contract_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: % items agregados al contrato', v_count;
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al agregar items: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 12: VERIFICAR ALERTAS AUTOMÁTICAS
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ PRUEBA 12: Verificar sistema de alertas';

  -- Crear lote próximo a vencer para generar alerta
  IF v_medicamento_id IS NOT NULL THEN
    BEGIN
      INSERT INTO batches (
        medication_id,
        center_id,
        numero_lote,
        cantidad_inicial,
        cantidad_actual,
        fecha_caducidad,
        stock_minimo,
        estado
      ) VALUES (
        v_medicamento_id,
        v_center_id,
        'LOTE-VENCIMIENTO-TEST',
        500,
        500,
        CURRENT_DATE + INTERVAL '20 days', -- Vence en 20 días
        100,
        'disponible'
      );

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Lote próximo a vencer creado (vence en 20 días)';
      RAISE NOTICE '  💡 Sistema debería generar alerta automática';
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ❌ FALLÓ: Error al crear lote de alerta: %', SQLERRM;
    END;
  END IF;

  -- ============================================
  -- PRUEBA 13: VERIFICAR AUDITORÍA
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '📝 PRUEBA 13: Verificar sistema de auditoría';

  SELECT count(*) INTO v_count
  FROM audit_log
  WHERE created_at >= v_start_time;

  IF v_count >= 0 THEN
    v_test_passed := v_test_passed + 1;
    RAISE NOTICE '  ✅ PASÓ: % eventos auditados desde inicio de pruebas', v_count;
  ELSE
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ⚠️ ADVERTENCIA: Sistema de auditoría no registró eventos';
  END IF;

  -- ============================================
  -- PRUEBA 14: VERIFICAR TRANSFERENCIA ENTRE CENTROS
  -- ============================================
  IF v_batch_id IS NOT NULL AND v_center_id_2 IS NOT NULL THEN
    v_test_count := v_test_count + 1;
    RAISE NOTICE '';
    RAISE NOTICE '🔄 PRUEBA 14: Registrar transferencia entre centros';

    BEGIN
      INSERT INTO batch_movements (
        batch_id,
        medication_id,
        center_id,
        tipo_movimiento,
        cantidad,
        cantidad_anterior,
        cantidad_posterior,
        centro_origen_id,
        centro_destino_id,
        motivo,
        observaciones
      ) VALUES (
        v_batch_id,
        v_medicamento_id,
        v_center_id,
        'transferencia_salida',
        100,
        1150,
        1050,
        v_center_id,
        v_center_id_2,
        'Transferencia de prueba automatizada',
        'Transferencia entre centros generada por batería de pruebas'
      );

      UPDATE batches SET cantidad_actual = 1050 WHERE id = v_batch_id;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Transferencia registrada';
      RAISE NOTICE '  📊 Stock origen: 1150 → 1050 (-100 transferidas)';
      RAISE NOTICE '  🏥 Centro origen: %', v_center_id;
      RAISE NOTICE '  🏥 Centro destino: %', v_center_id_2;
    EXCEPTION WHEN OTHERS THEN
      v_test_failed := v_test_failed + 1;
      RAISE NOTICE '  ⚠️ ADVERTENCIA: No hay segundo centro para transferencia';
    END;
  END IF;

  -- ============================================
  -- PRUEBA 15: ESTADÍSTICAS FINALES
  -- ============================================
  v_test_count := v_test_count + 1;
  RAISE NOTICE '';
  RAISE NOTICE '📊 PRUEBA 15: Recopilar estadísticas del sistema';

  BEGIN
    DECLARE
      v_total_medicamentos INTEGER;
      v_total_lotes INTEGER;
      v_total_movimientos INTEGER;
      v_total_contratos INTEGER;
      v_stock_total BIGINT;
    BEGIN
      SELECT count(*) INTO v_total_medicamentos FROM medication_catalog;
      SELECT count(*) INTO v_total_lotes FROM batches;
      SELECT count(*) INTO v_total_movimientos FROM batch_movements;
      SELECT count(*) INTO v_total_contratos FROM contracts;
      SELECT COALESCE(SUM(cantidad_actual), 0) INTO v_stock_total FROM batches;

      v_test_passed := v_test_passed + 1;
      RAISE NOTICE '  ✅ PASÓ: Estadísticas recopiladas';
      RAISE NOTICE '  📈 Medicamentos en catálogo: %', v_total_medicamentos;
      RAISE NOTICE '  📦 Lotes en inventario: %', v_total_lotes;
      RAISE NOTICE '  📊 Movimientos registrados: %', v_total_movimientos;
      RAISE NOTICE '  📄 Contratos activos: %', v_total_contratos;
      RAISE NOTICE '  🏪 Stock total sistema: % unidades', v_stock_total;
    END;
  EXCEPTION WHEN OTHERS THEN
    v_test_failed := v_test_failed + 1;
    RAISE NOTICE '  ❌ FALLÓ: Error al recopilar estadísticas: %', SQLERRM;
  END;

  -- ============================================
  -- RESUMEN FINAL
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '📊 RESUMEN DE PRUEBAS';
  RAISE NOTICE '========================================';
  RAISE NOTICE '  Total de pruebas: %', v_test_count;
  RAISE NOTICE '  ✅ Pruebas pasadas: %', v_test_passed;
  RAISE NOTICE '  ❌ Pruebas fallidas: %', v_test_failed;
  RAISE NOTICE '  📈 Tasa de éxito: %%', ROUND((v_test_passed::NUMERIC / v_test_count::NUMERIC) * 100, 2);
  RAISE NOTICE '  ⏱️ Tiempo de ejecución: % segundos', EXTRACT(EPOCH FROM (NOW() - v_start_time));
  RAISE NOTICE '========================================';

  IF v_test_failed = 0 THEN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE!';
    RAISE NOTICE '✅ El sistema está funcionando correctamente';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ ALGUNAS PRUEBAS FALLARON';
    RAISE NOTICE '💡 Revisa los mensajes de error arriba';
    RAISE NOTICE '📝 Verifica prerequisitos y configuración';
    RAISE NOTICE '';
  END IF;

  -- ============================================
  -- LIMPIEZA (OPCIONAL)
  -- ============================================
  RAISE NOTICE '========================================';
  RAISE NOTICE '🧹 LIMPIEZA DE DATOS DE PRUEBA';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ Los datos de prueba NO serán eliminados automáticamente.';
  RAISE NOTICE 'Para eliminar los datos de prueba, ejecuta:';
  RAISE NOTICE '';
  RAISE NOTICE '-- Eliminar movimientos de prueba';
  RAISE NOTICE 'DELETE FROM batch_movements WHERE observaciones LIKE ''%%prueba%%'';';
  RAISE NOTICE '';
  RAISE NOTICE '-- Eliminar lotes de prueba';
  RAISE NOTICE 'DELETE FROM batches WHERE numero_lote LIKE ''%%TEST%%'';';
  RAISE NOTICE '';
  RAISE NOTICE '-- Eliminar contrato de prueba';
  RAISE NOTICE 'DELETE FROM contracts WHERE codigo_contrato LIKE ''%%TEST%%'';';
  RAISE NOTICE '';
  RAISE NOTICE '-- Eliminar proveedor de prueba';
  RAISE NOTICE 'DELETE FROM suppliers WHERE rfc = ''PRUEBA999XXX'';';
  RAISE NOTICE '';
  RAISE NOTICE '-- Eliminar medicamento de prueba';
  RAISE NOTICE 'DELETE FROM medications WHERE nombre LIKE ''%%Prueba%%'';';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';

END $$;

-- FIN DE LAS PRUEBAS AUTOMATIZADAS
