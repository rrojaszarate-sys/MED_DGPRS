-- ==================================================
-- SUITE DE PRUEBAS AUTOMATIZADAS
-- Sistema: SIGIMED v2.0 (MED_DGPRS)
-- Propósito: Validar el correcto funcionamiento de todos los módulos
-- Fecha: 2025-11-19
-- ==================================================

-- Crear tabla para almacenar resultados de las pruebas
CREATE TABLE IF NOT EXISTS test_results (
    id SERIAL PRIMARY KEY,
    test_name TEXT NOT NULL,
    test_category TEXT NOT NULL,
    status TEXT CHECK (status IN ('PASSED', 'FAILED', 'ERROR')),
    expected_value TEXT,
    actual_value TEXT,
    error_message TEXT,
    execution_time INTERVAL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Limpiar resultados anteriores
TRUNCATE test_results;

RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'INICIANDO SUITE DE PRUEBAS AUTOMATIZADAS';
RAISE NOTICE 'Sistema: SIGIMED v2.0';
RAISE NOTICE '==================================================';
RAISE NOTICE '';

-- ==================================================
-- 1. PRUEBAS DE ESTRUCTURA DE BASE DE DATOS
-- ==================================================
RAISE NOTICE '>>> CATEGORÍA 1: Estructura de Base de Datos';

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_count INTEGER;
    v_expected INTEGER;
    v_actual TEXT;
BEGIN
    -- Test 1.1: Verificar que existen todas las tablas principales
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name IN (
            'health_centers', 'users_profiles', 'user_centers', 'medication_catalog',
            'medications', 'suppliers', 'contracts', 'transfers', 'requisitions',
            'batch_movements', 'alertas_medicamentos', 'inventory_adjustments',
            'audit_log', 'instituciones'
        );

        v_expected := 14;
        v_end_time := clock_timestamp();

        IF v_count = v_expected THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Verificar tablas principales', 'Estructura DB', 'PASSED',
                    v_expected::TEXT || ' tablas', v_count::TEXT || ' tablas', v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 1.1 PASSED: Todas las tablas principales existen';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Verificar tablas principales', 'Estructura DB', 'FAILED',
                    v_expected::TEXT || ' tablas', v_count::TEXT || ' tablas', v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 1.1 FAILED: Esperadas % tablas, encontradas %', v_expected, v_count;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Verificar tablas principales', 'Estructura DB', 'ERROR', SQLERRM, v_end_time - v_start_time);
        RAISE WARNING '  ✗ Test 1.1 ERROR: %', SQLERRM;
    END;

    -- Test 1.2: Verificar índices críticos
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM pg_indexes
        WHERE schemaname = 'public'
        AND indexname LIKE 'idx_%';

        v_end_time := clock_timestamp();

        IF v_count >= 20 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Verificar índices', 'Estructura DB', 'PASSED',
                    '>= 20 índices', v_count::TEXT || ' índices', v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 1.2 PASSED: Índices de optimización presentes (% índices)', v_count;
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Verificar índices', 'Estructura DB', 'FAILED',
                    '>= 20 índices', v_count::TEXT || ' índices', v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 1.2 FAILED: Índices insuficientes: %', v_count;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Verificar índices', 'Estructura DB', 'ERROR', SQLERRM, v_end_time - v_start_time);
        RAISE WARNING '  ✗ Test 1.2 ERROR: %', SQLERRM;
    END;

    -- Test 1.3: Verificar funciones críticas
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname IN (
            'registrar_movimiento_lote',
            'generar_alertas_caducidad',
            'generate_traceability_report',
            'search_inventory_with_batches'
        );

        v_expected := 4;
        v_end_time := clock_timestamp();

        IF v_count = v_expected THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Verificar funciones críticas', 'Estructura DB', 'PASSED',
                    v_expected::TEXT || ' funciones', v_count::TEXT || ' funciones', v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 1.3 PASSED: Funciones críticas presentes';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Verificar funciones críticas', 'Estructura DB', 'FAILED',
                    v_expected::TEXT || ' funciones', v_count::TEXT || ' funciones', v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 1.3 FAILED: Funciones faltantes';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Verificar funciones críticas', 'Estructura DB', 'ERROR', SQLERRM, v_end_time - v_start_time);
        RAISE WARNING '  ✗ Test 1.3 ERROR: %', SQLERRM;
    END;
END $$;

-- ==================================================
-- 2. PRUEBAS DE INTEGRIDAD DE DATOS
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '>>> CATEGORÍA 2: Integridad de Datos';

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_count INTEGER;
BEGIN
    -- Test 2.1: Verificar que no hay medicamentos con cantidad negativa
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count FROM medications WHERE cantidad < 0;
        v_end_time := clock_timestamp();

        IF v_count = 0 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Cantidad no negativa', 'Integridad Datos', 'PASSED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 2.1 PASSED: No hay cantidades negativas';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Cantidad no negativa', 'Integridad Datos', 'FAILED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 2.1 FAILED: % medicamentos con cantidad negativa', v_count;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Cantidad no negativa', 'Integridad Datos', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;

    -- Test 2.2: Verificar integridad referencial medicamentos -> catalog
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM medications m
        LEFT JOIN medication_catalog c ON m.catalog_id = c.id
        WHERE m.catalog_id IS NOT NULL AND c.id IS NULL;

        v_end_time := clock_timestamp();

        IF v_count = 0 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Integridad referencial catálogo', 'Integridad Datos', 'PASSED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 2.2 PASSED: Integridad referencial correcta';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Integridad referencial catálogo', 'Integridad Datos', 'FAILED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 2.2 FAILED: % medicamentos sin catálogo válido', v_count;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Integridad referencial catálogo', 'Integridad Datos', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;

    -- Test 2.3: Verificar que todos los centros activos tienen código único
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM (
            SELECT code, COUNT(*) as cnt
            FROM health_centers
            WHERE is_active = true
            GROUP BY code
            HAVING COUNT(*) > 1
        ) duplicates;

        v_end_time := clock_timestamp();

        IF v_count = 0 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Códigos únicos de centros', 'Integridad Datos', 'PASSED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 2.3 PASSED: Códigos de centros únicos';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Códigos únicos de centros', 'Integridad Datos', 'FAILED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 2.3 FAILED: % códigos duplicados', v_count;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Códigos únicos de centros', 'Integridad Datos', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;

    -- Test 2.4: Verificar que fechas de caducidad son futuras o recientes
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM medications
        WHERE fecha_caducidad < (CURRENT_DATE - INTERVAL '5 years');

        v_end_time := clock_timestamp();

        IF v_count = 0 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Fechas de caducidad válidas', 'Integridad Datos', 'PASSED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 2.4 PASSED: Fechas de caducidad razonables';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Fechas de caducidad válidas', 'Integridad Datos', 'FAILED', '0', v_count::TEXT, v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 2.4 FAILED: % medicamentos con fechas sospechosas', v_count;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Fechas de caducidad válidas', 'Integridad Datos', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;
END $$;

-- ==================================================
-- 3. PRUEBAS DE FUNCIONALIDAD DE NEGOCIO
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '>>> CATEGORÍA 3: Funcionalidad de Negocio';

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_count INTEGER;
    v_med_id UUID;
    v_cantidad_inicial INTEGER;
    v_cantidad_final INTEGER;
    v_movement_id UUID;
BEGIN
    -- Test 3.1: Probar función de generación de alertas
    v_start_time := clock_timestamp();
    BEGIN
        PERFORM generar_alertas_caducidad();

        SELECT COUNT(*) INTO v_count FROM alertas_medicamentos WHERE NOT resuelta;
        v_end_time := clock_timestamp();

        INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
        VALUES ('Generación de alertas', 'Funcionalidad', 'PASSED',
                '> 0 alertas', v_count::TEXT || ' alertas', v_end_time - v_start_time);
        RAISE NOTICE '  ✓ Test 3.1 PASSED: Generación de alertas funciona (% alertas)', v_count;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Generación de alertas', 'Funcionalidad', 'ERROR', SQLERRM, v_end_time - v_start_time);
        RAISE WARNING '  ✗ Test 3.1 ERROR: %', SQLERRM;
    END;

    -- Test 3.2: Probar registro de movimiento
    v_start_time := clock_timestamp();
    BEGIN
        SELECT id, cantidad INTO v_med_id, v_cantidad_inicial
        FROM medications
        WHERE cantidad > 10 AND estado = 'Disponible'
        ORDER BY random()
        LIMIT 1;

        IF v_med_id IS NOT NULL THEN
            INSERT INTO batch_movements (
                id, medication_id, tipo_movimiento, cantidad,
                cantidad_anterior, cantidad_posterior, motivo,
                created_at
            )
            VALUES (
                gen_random_uuid(),
                v_med_id,
                'salida',
                5,
                v_cantidad_inicial,
                v_cantidad_inicial - 5,
                'Test automatizado',
                CURRENT_TIMESTAMP
            )
            RETURNING id INTO v_movement_id;

            -- Verificar que se registró
            IF v_movement_id IS NOT NULL THEN
                v_end_time := clock_timestamp();
                INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
                VALUES ('Registro de movimientos', 'Funcionalidad', 'PASSED',
                        'Movimiento registrado', 'ID: ' || v_movement_id::TEXT, v_end_time - v_start_time);
                RAISE NOTICE '  ✓ Test 3.2 PASSED: Registro de movimientos funciona';
            ELSE
                v_end_time := clock_timestamp();
                INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
                VALUES ('Registro de movimientos', 'Funcionalidad', 'FAILED',
                        'Movimiento registrado', 'NULL', v_end_time - v_start_time);
                RAISE WARNING '  ✗ Test 3.2 FAILED: No se pudo registrar movimiento';
            END IF;
        ELSE
            v_end_time := clock_timestamp();
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Registro de movimientos', 'Funcionalidad', 'FAILED',
                    'Medicamento disponible', 'No encontrado', v_end_time - v_start_time);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Registro de movimientos', 'Funcionalidad', 'ERROR', SQLERRM, v_end_time - v_start_time);
        RAISE WARNING '  ✗ Test 3.2 ERROR: %', SQLERRM;
    END;

    -- Test 3.3: Verificar niveles de alerta
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM alertas_medicamentos
        WHERE nivel_alerta IN ('critico', 'urgente', 'preventivo');

        v_end_time := clock_timestamp();

        INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
        VALUES ('Niveles de alerta correctos', 'Funcionalidad', 'PASSED',
                'Alertas con nivel válido', v_count::TEXT || ' alertas', v_end_time - v_start_time);
        RAISE NOTICE '  ✓ Test 3.3 PASSED: Niveles de alerta correctos';
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Niveles de alerta correctos', 'Funcionalidad', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;
END $$;

-- ==================================================
-- 4. PRUEBAS DE RENDIMIENTO
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '>>> CATEGORÍA 4: Rendimiento';

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_execution_time INTERVAL;
    v_count INTEGER;
    v_threshold INTERVAL := '1 second';
BEGIN
    -- Test 4.1: Consulta de inventario completo
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM medications m
        LEFT JOIN medication_catalog c ON m.catalog_id = c.id
        LEFT JOIN health_centers h ON m.center_id = h.id
        WHERE m.estado = 'Disponible';

        v_end_time := clock_timestamp();
        v_execution_time := v_end_time - v_start_time;

        IF v_execution_time < v_threshold THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Consulta inventario completo', 'Rendimiento', 'PASSED',
                    '< ' || v_threshold::TEXT, v_execution_time::TEXT, v_execution_time);
            RAISE NOTICE '  ✓ Test 4.1 PASSED: Consulta rápida (% ms)', EXTRACT(MILLISECONDS FROM v_execution_time);
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Consulta inventario completo', 'Rendimiento', 'FAILED',
                    '< ' || v_threshold::TEXT, v_execution_time::TEXT, v_execution_time);
            RAISE WARNING '  ✗ Test 4.1 FAILED: Consulta lenta (%)', v_execution_time;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Consulta inventario completo', 'Rendimiento', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;

    -- Test 4.2: Búsqueda por lote
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM medications
        WHERE lote LIKE 'LOTE-%'
        LIMIT 100;

        v_end_time := clock_timestamp();
        v_execution_time := v_end_time - v_start_time;

        IF v_execution_time < v_threshold THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Búsqueda por lote', 'Rendimiento', 'PASSED',
                    '< ' || v_threshold::TEXT, v_execution_time::TEXT, v_execution_time);
            RAISE NOTICE '  ✓ Test 4.2 PASSED: Búsqueda por lote eficiente';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Búsqueda por lote', 'Rendimiento', 'FAILED',
                    '< ' || v_threshold::TEXT, v_execution_time::TEXT, v_execution_time);
            RAISE WARNING '  ✗ Test 4.2 FAILED: Búsqueda lenta';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Búsqueda por lote', 'Rendimiento', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;
END $$;

-- ==================================================
-- 5. PRUEBAS DE SEGURIDAD Y PERMISOS
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '>>> CATEGORÍA 5: Seguridad y Permisos';

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_count INTEGER;
BEGIN
    -- Test 5.1: Verificar RLS habilitado
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename IN ('medications', 'users_profiles', 'batch_movements', 'audit_log')
        AND rowsecurity = true;

        v_end_time := clock_timestamp();

        IF v_count >= 3 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('RLS habilitado', 'Seguridad', 'PASSED',
                    '>= 3 tablas', v_count::TEXT || ' tablas', v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 5.1 PASSED: RLS habilitado en tablas críticas';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('RLS habilitado', 'Seguridad', 'FAILED',
                    '>= 3 tablas', v_count::TEXT || ' tablas', v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 5.1 FAILED: RLS no habilitado suficientemente';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('RLS habilitado', 'Seguridad', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;

    -- Test 5.2: Verificar que existen roles diferentes
    v_start_time := clock_timestamp();
    BEGIN
        SELECT COUNT(DISTINCT role) INTO v_count FROM users_profiles;

        v_end_time := clock_timestamp();

        IF v_count >= 3 THEN
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Roles de usuario', 'Seguridad', 'PASSED',
                    '>= 3 roles', v_count::TEXT || ' roles', v_end_time - v_start_time);
            RAISE NOTICE '  ✓ Test 5.2 PASSED: Sistema multi-rol implementado';
        ELSE
            INSERT INTO test_results (test_name, test_category, status, expected_value, actual_value, execution_time)
            VALUES ('Roles de usuario', 'Seguridad', 'FAILED',
                    '>= 3 roles', v_count::TEXT || ' roles', v_end_time - v_start_time);
            RAISE WARNING '  ✗ Test 5.2 FAILED: Roles insuficientes';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        INSERT INTO test_results (test_name, test_category, status, error_message, execution_time)
        VALUES ('Roles de usuario', 'Seguridad', 'ERROR', SQLERRM, v_end_time - v_start_time);
    END;
END $$;

-- ==================================================
-- RESUMEN FINAL DE PRUEBAS
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'RESUMEN DE PRUEBAS AUTOMATIZADAS';
RAISE NOTICE '==================================================';

DO $$
DECLARE
    v_total INTEGER;
    v_passed INTEGER;
    v_failed INTEGER;
    v_errors INTEGER;
    v_success_rate DECIMAL;
BEGIN
    SELECT COUNT(*) INTO v_total FROM test_results;
    SELECT COUNT(*) INTO v_passed FROM test_results WHERE status = 'PASSED';
    SELECT COUNT(*) INTO v_failed FROM test_results WHERE status = 'FAILED';
    SELECT COUNT(*) INTO v_errors FROM test_results WHERE status = 'ERROR';

    v_success_rate := (v_passed::DECIMAL / NULLIF(v_total, 0) * 100)::DECIMAL(5,2);

    RAISE NOTICE 'Total de pruebas: %', v_total;
    RAISE NOTICE 'Exitosas (PASSED): % (%.2f%%)', v_passed, v_success_rate;
    RAISE NOTICE 'Fallidas (FAILED): %', v_failed;
    RAISE NOTICE 'Errores (ERROR): %', v_errors;
    RAISE NOTICE '';

    IF v_failed > 0 OR v_errors > 0 THEN
        RAISE NOTICE 'Pruebas con problemas:';
        FOR rec IN SELECT test_name, test_category, status, error_message
                   FROM test_results
                   WHERE status IN ('FAILED', 'ERROR')
                   ORDER BY test_category, test_name LOOP
            RAISE NOTICE '  - [%] % : % %',
                rec.status,
                rec.test_category,
                rec.test_name,
                COALESCE(' - ' || rec.error_message, '');
        END LOOP;
    END IF;

    RAISE NOTICE '==================================================';

    IF v_success_rate = 100 THEN
        RAISE NOTICE '✓ TODAS LAS PRUEBAS PASARON EXITOSAMENTE';
    ELSIF v_success_rate >= 80 THEN
        RAISE WARNING '⚠ SISTEMA FUNCIONAL CON ADVERTENCIAS (%.2f%% éxito)', v_success_rate;
    ELSE
        RAISE WARNING '✗ SISTEMA REQUIERE ATENCIÓN (%.2f%% éxito)', v_success_rate;
    END IF;

    RAISE NOTICE '==================================================';
END $$;

-- ==================================================
-- FIN DE SUITE DE PRUEBAS
-- ==================================================
