-- ==================================================
-- SCRIPT DE GENERACIÓN DE DATOS COMPLETOS DE PRUEBA
-- Sistema: SIGIMED v2.0 (MED_DGPRS)
-- Propósito: Generar datos ficticios completos para validación del sistema
-- Incluye: Usuarios, Instituciones, Transferencias, Requisiciones, Ajustes, Movimientos
-- Fecha: 2025-11-19
-- ==================================================

-- ==================================================
-- 1. INSTITUCIONES DEL SECTOR SALUD
-- ==================================================
RAISE NOTICE 'Generando instituciones del sector salud...';

INSERT INTO instituciones (id, nombre, clave, tipo, created_at)
VALUES
    (gen_random_uuid(), 'Instituto Mexicano del Seguro Social', 'IMSS', 'IMSS', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Instituto de Seguridad y Servicios Sociales de los Trabajadores del Estado', 'ISSSTE', 'ISSSTE', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Secretaría de Salud', 'SSA', 'SSA', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Secretaría de la Defensa Nacional', 'SEDENA', 'SEDENA', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Secretaría de Marina', 'SEMAR', 'SEMAR', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Instituto de Salud para el Bienestar', 'INSABI', 'INSABI', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Petróleos Mexicanos', 'PEMEX', 'PEMEX', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'Servicios de Salud Estatales', 'SESA', 'ESTATAL', CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ==================================================
-- 2. USUARIOS DE PRUEBA (Diferentes Roles)
-- ==================================================
RAISE NOTICE 'Generando usuarios de prueba...';

DO $$
DECLARE
    v_user_id UUID;
    v_center_id UUID;
    v_email TEXT;
    v_password TEXT := 'Test123!'; -- Contraseña para todos los usuarios de prueba
BEGIN
    -- Super Admin
    v_user_id := gen_random_uuid();
    v_email := 'superadmin@sigimed.test';

    -- Nota: En producción, estos usuarios deben crearse mediante auth.users de Supabase
    -- Este script asume que ya existen en auth.users o se crearán manualmente
    INSERT INTO users_profiles (id, email, full_name, phone, role, permissions, is_active, created_at)
    VALUES (
        v_user_id,
        v_email,
        'Dr. Administrador General del Sistema',
        '5551234567',
        'super_admin',
        '{"all": true}'::JSONB,
        true,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (email) DO NOTHING;

    RAISE NOTICE 'Usuario creado: % (super_admin)', v_email;

    -- Admin Centro 1
    v_user_id := gen_random_uuid();
    v_email := 'admin.hgm@sigimed.test';
    SELECT id INTO v_center_id FROM health_centers WHERE code = 'HG-001' LIMIT 1;

    INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
    VALUES (
        v_user_id,
        v_email,
        'Dr. Juan Carlos Pérez Administrador',
        '5559871234',
        'admin_center',
        true,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (email) DO NOTHING;

    IF v_center_id IS NOT NULL THEN
        INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
        VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, center_id) DO NOTHING;
    END IF;

    RAISE NOTICE 'Usuario creado: % (admin_center - HG-001)', v_email;

    -- Admin Centro 2
    v_user_id := gen_random_uuid();
    v_email := 'admin.hraei@sigimed.test';
    SELECT id INTO v_center_id FROM health_centers WHERE code = 'HRAE-002' LIMIT 1;

    INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
    VALUES (
        v_user_id,
        v_email,
        'Dra. María Elena Rodríguez Administradora',
        '5559726001',
        'admin_center',
        true,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (email) DO NOTHING;

    IF v_center_id IS NOT NULL THEN
        INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
        VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, center_id) DO NOTHING;
    END IF;

    RAISE NOTICE 'Usuario creado: % (admin_center - HRAE-002)', v_email;

    -- Usuarios de Inventario
    FOR i IN 1..5 LOOP
        v_user_id := gen_random_uuid();
        v_email := 'inventario' || i || '@sigimed.test';

        SELECT id INTO v_center_id FROM health_centers ORDER BY random() LIMIT 1;

        INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
        VALUES (
            v_user_id,
            v_email,
            'Q.F.B. Usuario Inventario ' || i,
            '555' || lpad((1000000 + i)::TEXT, 7, '0'),
            'inventory_user',
            true,
            CURRENT_TIMESTAMP
        )
        ON CONFLICT (email) DO NOTHING;

        IF v_center_id IS NOT NULL THEN
            INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
            VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, center_id) DO NOTHING;
        END IF;

        RAISE NOTICE 'Usuario creado: % (inventory_user)', v_email;
    END LOOP;

    -- Usuarios de Solo Lectura
    FOR i IN 1..3 LOOP
        v_user_id := gen_random_uuid();
        v_email := 'readonly' || i || '@sigimed.test';

        SELECT id INTO v_center_id FROM health_centers ORDER BY random() LIMIT 1;

        INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
        VALUES (
            v_user_id,
            v_email,
            'Lic. Usuario Lectura ' || i,
            '555' || lpad((2000000 + i)::TEXT, 7, '0'),
            'read_only',
            true,
            CURRENT_TIMESTAMP
        )
        ON CONFLICT (email) DO NOTHING;

        IF v_center_id IS NOT NULL THEN
            INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
            VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, center_id) DO NOTHING;
        END IF;

        RAISE NOTICE 'Usuario creado: % (read_only)', v_email;
    END LOOP;

END $$;

-- ==================================================
-- 3. REQUISICIONES INTERNAS
-- ==================================================
RAISE NOTICE 'Generando requisiciones internas...';

DO $$
DECLARE
    v_req_id UUID;
    v_center_id UUID;
    v_user_id UUID;
    v_med_id UUID;
    v_req_number TEXT;
    v_estados TEXT[] := ARRAY['solicitada', 'aprobada', 'surtida', 'completada'];
    v_estado TEXT;
    v_fecha_solicitud TIMESTAMP;
    v_servicios TEXT[] := ARRAY['Urgencias', 'Hospitalización', 'Consulta Externa',
                                  'Cirugía', 'Pediatría', 'Ginecología', 'Medicina Interna'];
    v_contador INTEGER := 0;
BEGIN
    -- Generar 20 requisiciones
    FOR i IN 1..20 LOOP
        SELECT id INTO v_center_id FROM health_centers WHERE is_active = true ORDER BY random() LIMIT 1;
        SELECT id INTO v_user_id FROM users_profiles WHERE role IN ('admin_center', 'inventory_user')
                                                      ORDER BY random() LIMIT 1;

        v_req_number := 'REQ-' || to_char(CURRENT_DATE, 'YYYY') || '-' || lpad(i::TEXT, 5, '0');
        v_estado := v_estados[1 + floor(random() * array_length(v_estados, 1))::INTEGER];
        v_fecha_solicitud := CURRENT_TIMESTAMP - (floor(random() * 30)::INTEGER || ' days')::INTERVAL;

        v_req_id := gen_random_uuid();

        INSERT INTO requisitions (
            id, requisition_number, requesting_service, requesting_user_id,
            center_id, status, fecha_solicitud, fecha_necesaria,
            prioridad, observaciones, created_at
        )
        VALUES (
            v_req_id,
            v_req_number,
            v_servicios[1 + floor(random() * array_length(v_servicios, 1))::INTEGER],
            v_user_id,
            v_center_id,
            v_estado,
            v_fecha_solicitud,
            v_fecha_solicitud + (3 + floor(random() * 7)::INTEGER || ' days')::INTERVAL,
            CASE WHEN random() < 0.7 THEN 'normal'
                 WHEN random() < 0.9 THEN 'urgente'
                 ELSE 'emergencia' END,
            'Requisición de prueba generada automáticamente',
            v_fecha_solicitud
        );

        -- Agregar items a la requisición (2-6 items)
        FOR j IN 1..(2 + floor(random() * 4)::INTEGER) LOOP
            SELECT id INTO v_med_id FROM medications
            WHERE center_id = v_center_id AND estado = 'Disponible'
            ORDER BY random() LIMIT 1;

            IF v_med_id IS NOT NULL THEN
                INSERT INTO requisition_items (
                    id, requisition_id, medication_id,
                    cantidad_solicitada, cantidad_aprobada, cantidad_surtida,
                    justificacion, created_at
                )
                VALUES (
                    gen_random_uuid(),
                    v_req_id,
                    v_med_id,
                    5 + floor(random() * 45)::INTEGER,
                    CASE WHEN v_estado IN ('aprobada', 'surtida', 'completada')
                         THEN 5 + floor(random() * 40)::INTEGER
                         ELSE NULL END,
                    CASE WHEN v_estado IN ('surtida', 'completada')
                         THEN 5 + floor(random() * 40)::INTEGER
                         ELSE NULL END,
                    'Consumo estimado para ' || (7 + floor(random() * 23)::INTEGER) || ' días',
                    v_fecha_solicitud
                );
            END IF;
        END LOOP;

        v_contador := v_contador + 1;
    END LOOP;

    RAISE NOTICE 'Requisiciones generadas: %', v_contador;
END $$;

-- ==================================================
-- 4. TRANSFERENCIAS ENTRE CENTROS
-- ==================================================
RAISE NOTICE 'Generando transferencias entre centros...';

DO $$
DECLARE
    v_transfer_id UUID;
    v_origin_center_id UUID;
    v_dest_center_id UUID;
    v_user_id UUID;
    v_med_id UUID;
    v_transfer_number TEXT;
    v_estados TEXT[] := ARRAY['pending', 'approved', 'in_transit', 'received', 'completed'];
    v_estado TEXT;
    v_fecha_solicitud TIMESTAMP;
    v_contador INTEGER := 0;
BEGIN
    -- Generar 15 transferencias
    FOR i IN 1..15 LOOP
        SELECT id INTO v_origin_center_id FROM health_centers WHERE is_active = true ORDER BY random() LIMIT 1;
        SELECT id INTO v_dest_center_id FROM health_centers
        WHERE is_active = true AND id != v_origin_center_id ORDER BY random() LIMIT 1;

        SELECT id INTO v_user_id FROM users_profiles WHERE role IN ('admin_center', 'super_admin')
                                                      ORDER BY random() LIMIT 1;

        v_transfer_number := 'TRF-' || to_char(CURRENT_DATE, 'YYYY') || '-' || lpad(i::TEXT, 5, '0');
        v_estado := v_estados[1 + floor(random() * array_length(v_estados, 1))::INTEGER];
        v_fecha_solicitud := CURRENT_TIMESTAMP - (floor(random() * 60)::INTEGER || ' days')::INTERVAL;

        v_transfer_id := gen_random_uuid();

        INSERT INTO transfers (
            id, transfer_number, origin_center_id, destination_center_id,
            status, requested_by, requested_at,
            tracking_number, notes, created_at
        )
        VALUES (
            v_transfer_id,
            v_transfer_number,
            v_origin_center_id,
            v_dest_center_id,
            v_estado,
            v_user_id,
            v_fecha_solicitud,
            'TRK' || lpad(floor(random() * 9999999999)::TEXT, 10, '0'),
            'Transferencia de prueba generada automáticamente',
            v_fecha_solicitud
        );

        -- Agregar items a la transferencia (1-5 items)
        FOR j IN 1..(1 + floor(random() * 4)::INTEGER) LOOP
            SELECT id INTO v_med_id FROM medications
            WHERE center_id = v_origin_center_id AND estado = 'Disponible' AND cantidad > 20
            ORDER BY random() LIMIT 1;

            IF v_med_id IS NOT NULL THEN
                INSERT INTO transfer_items (
                    id, transfer_id, medication_id,
                    cantidad_solicitada, cantidad_aprobada, cantidad_enviada, cantidad_recibida,
                    created_at
                )
                SELECT
                    gen_random_uuid(),
                    v_transfer_id,
                    v_med_id,
                    5 + floor(random() * 15)::INTEGER,
                    CASE WHEN v_estado IN ('approved', 'in_transit', 'received', 'completed')
                         THEN 5 + floor(random() * 15)::INTEGER
                         ELSE NULL END,
                    CASE WHEN v_estado IN ('in_transit', 'received', 'completed')
                         THEN 5 + floor(random() * 15)::INTEGER
                         ELSE NULL END,
                    CASE WHEN v_estado IN ('received', 'completed')
                         THEN 5 + floor(random() * 15)::INTEGER
                         ELSE NULL END,
                    v_fecha_solicitud;
            END IF;
        END LOOP;

        v_contador := v_contador + 1;
    END LOOP;

    RAISE NOTICE 'Transferencias generadas: %', v_contador;
END $$;

-- ==================================================
-- 5. AJUSTES DE INVENTARIO
-- ==================================================
RAISE NOTICE 'Generando ajustes de inventario...';

DO $$
DECLARE
    v_adj_id UUID;
    v_med_id UUID;
    v_center_id UUID;
    v_user_id UUID;
    v_adj_number TEXT;
    v_tipos TEXT[] := ARRAY['merma', 'correccion', 'devolucion', 'reclasificacion'];
    v_tipo TEXT;
    v_cantidad_sistema INTEGER;
    v_cantidad_fisica INTEGER;
    v_contador INTEGER := 0;
BEGIN
    -- Generar 25 ajustes
    FOR i IN 1..25 LOOP
        SELECT m.id, m.center_id, m.cantidad INTO v_med_id, v_center_id, v_cantidad_sistema
        FROM medications m
        WHERE m.cantidad > 0 AND m.estado = 'Disponible'
        ORDER BY random() LIMIT 1;

        IF v_med_id IS NOT NULL THEN
            SELECT id INTO v_user_id FROM users_profiles
            WHERE role IN ('admin_center', 'inventory_user')
            ORDER BY random() LIMIT 1;

            v_adj_number := 'ADJ-' || to_char(CURRENT_DATE, 'YYYY') || '-' || lpad(i::TEXT, 5, '0');
            v_tipo := v_tipos[1 + floor(random() * array_length(v_tipos, 1))::INTEGER];

            -- Generar diferencia: 80% menor, 20% mayor
            IF random() < 0.8 THEN
                v_cantidad_fisica := v_cantidad_sistema - (1 + floor(random() * 10)::INTEGER);
            ELSE
                v_cantidad_fisica := v_cantidad_sistema + (1 + floor(random() * 5)::INTEGER);
            END IF;

            v_cantidad_fisica := GREATEST(0, v_cantidad_fisica);

            v_adj_id := gen_random_uuid();

            INSERT INTO inventory_adjustments (
                id, adjustment_number, medication_id, center_id,
                adjustment_type, cantidad_sistema, cantidad_fisica,
                motivo, justificacion, created_by, created_at
            )
            VALUES (
                v_adj_id,
                v_adj_number,
                v_med_id,
                v_center_id,
                v_tipo,
                v_cantidad_sistema,
                v_cantidad_fisica,
                CASE v_tipo
                    WHEN 'merma' THEN 'Producto dañado durante almacenamiento'
                    WHEN 'correccion' THEN 'Error en conteo físico anterior'
                    WHEN 'devolucion' THEN 'Devolución de servicio no utilizado'
                    ELSE 'Reclasificación de lote' END,
                'Ajuste generado automáticamente para pruebas. Diferencia: ' ||
                    (v_cantidad_fisica - v_cantidad_sistema)::TEXT || ' unidades',
                v_user_id,
                CURRENT_TIMESTAMP - (floor(random() * 30)::INTEGER || ' days')::INTERVAL
            );

            v_contador := v_contador + 1;
        END IF;
    END LOOP;

    RAISE NOTICE 'Ajustes de inventario generados: %', v_contador;
END $$;

-- ==================================================
-- 6. MOVIMIENTOS ADICIONALES DE STOCK
-- ==================================================
RAISE NOTICE 'Generando movimientos adicionales de stock...';

DO $$
DECLARE
    v_med RECORD;
    v_user_id UUID;
    v_tipos_salida TEXT[] := ARRAY['salida', 'vencimiento', 'merma', 'devolucion', 'destruccion'];
    v_tipo TEXT;
    v_cantidad INTEGER;
    v_motivos TEXT[] := ARRAY[
        'Dispensación a servicio de urgencias',
        'Surtido de requisición',
        'Consumo de consulta externa',
        'Medicamento vencido retirado',
        'Merma por almacenamiento inadecuado',
        'Devolución a proveedor por defecto',
        'Destrucción por caducidad'
    ];
    v_contador INTEGER := 0;
BEGIN
    SELECT id INTO v_user_id FROM users_profiles WHERE role IN ('inventory_user', 'admin_center')
                                                  ORDER BY random() LIMIT 1;

    -- Generar 50 movimientos aleatorios
    FOR i IN 1..50 LOOP
        SELECT m.id, m.cantidad, m.center_id INTO v_med
        FROM medications m
        WHERE m.cantidad > 5 AND m.estado = 'Disponible'
        ORDER BY random() LIMIT 1;

        IF v_med.id IS NOT NULL THEN
            v_tipo := v_tipos_salida[1 + floor(random() * array_length(v_tipos_salida, 1))::INTEGER];
            v_cantidad := 1 + floor(random() * LEAST(v_med.cantidad - 1, 20))::INTEGER;

            INSERT INTO batch_movements (
                id, medication_id, tipo_movimiento, cantidad,
                cantidad_anterior, cantidad_posterior,
                centro_origen_id, numero_documento, motivo,
                observaciones, usuario_responsable, created_at
            )
            VALUES (
                gen_random_uuid(),
                v_med.id,
                v_tipo,
                v_cantidad,
                v_med.cantidad,
                v_med.cantidad - v_cantidad,
                v_med.center_id,
                'MOV-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || lpad(i::TEXT, 6, '0'),
                v_motivos[1 + floor(random() * array_length(v_motivos, 1))::INTEGER],
                'Movimiento de prueba generado automáticamente',
                v_user_id,
                CURRENT_TIMESTAMP - (floor(random() * 60)::INTEGER || ' days')::INTERVAL
            );

            -- Actualizar cantidad del medicamento
            UPDATE medications
            SET cantidad = cantidad - v_cantidad,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_med.id;

            v_contador := v_contador + 1;
        END IF;
    END LOOP;

    RAISE NOTICE 'Movimientos adicionales generados: %', v_contador;
END $$;

-- ==================================================
-- 7. GENERAR CONTRATOS CON PROVEEDORES
-- ==================================================
RAISE NOTICE 'Generando contratos con proveedores...';

DO $$
DECLARE
    v_contract_id UUID;
    v_supplier_id UUID;
    v_user_id UUID;
    v_med_id UUID;
    v_contract_code TEXT;
    v_estados TEXT[] := ARRAY['borrador', 'activo', 'activo', 'activo', 'vencido'];
    v_estado TEXT;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_contador INTEGER := 0;
BEGIN
    SELECT id INTO v_user_id FROM users_profiles WHERE role = 'super_admin' ORDER BY random() LIMIT 1;

    -- Generar 10 contratos
    FOR i IN 1..10 LOOP
        SELECT id INTO v_supplier_id FROM suppliers WHERE is_active = true ORDER BY random() LIMIT 1;

        v_contract_code := 'CONT-' || to_char(CURRENT_DATE, 'YYYY') || '-' || lpad(i::TEXT, 4, '0');
        v_estado := v_estados[1 + floor(random() * array_length(v_estados, 1))::INTEGER];
        v_fecha_inicio := CURRENT_DATE - (floor(random() * 365)::INTEGER || ' days')::INTERVAL;
        v_fecha_fin := v_fecha_inicio + (180 + floor(random() * 365)::INTEGER || ' days')::INTERVAL;

        v_contract_id := gen_random_uuid();

        INSERT INTO contracts (
            id, codigo_contrato, supplier_id, estado,
            fecha_inicio, fecha_fin, monto_total,
            condiciones_pago, garantia, penalizaciones,
            observaciones, created_by, created_at
        )
        VALUES (
            v_contract_id,
            v_contract_code,
            v_supplier_id,
            v_estado,
            v_fecha_inicio,
            v_fecha_fin,
            (50000 + random() * 950000)::DECIMAL(12,2),
            'Pago a 30 días después de entrega conforme',
            '10% del monto total',
            '2% del monto por día de retraso en entrega',
            'Contrato de prueba generado automáticamente',
            v_user_id,
            v_fecha_inicio
        );

        -- Agregar items al contrato (3-8 medicamentos)
        FOR j IN 1..(3 + floor(random() * 5)::INTEGER) LOOP
            SELECT id INTO v_med_id FROM medication_catalog WHERE is_active = true ORDER BY random() LIMIT 1;

            IF v_med_id IS NOT NULL THEN
                INSERT INTO contract_items (
                    id, contract_id, catalog_id, cantidad_comprometida,
                    precio_unitario, descuento, total,
                    frecuencia_entrega, created_at
                )
                VALUES (
                    gen_random_uuid(),
                    v_contract_id,
                    v_med_id,
                    100 + floor(random() * 900)::INTEGER,
                    (10 + random() * 490)::DECIMAL(10,2),
                    floor(random() * 15)::INTEGER,
                    0, -- Se calculará con trigger
                    CASE floor(random() * 3)::INTEGER
                        WHEN 0 THEN 'mensual'
                        WHEN 1 THEN 'bimestral'
                        ELSE 'trimestral' END,
                    v_fecha_inicio
                );
            END IF;
        END LOOP;

        v_contador := v_contador + 1;
    END LOOP;

    RAISE NOTICE 'Contratos generados: %', v_contador;
END $$;

-- ==================================================
-- 8. REFRESCAR VISTAS MATERIALIZADAS
-- ==================================================
RAISE NOTICE 'Refrescando vistas materializadas...';

REFRESH MATERIALIZED VIEW IF EXISTS estadisticas_centro;

-- ==================================================
-- ESTADÍSTICAS FINALES
-- ==================================================
DO $$
DECLARE
    v_total_users INTEGER;
    v_total_requisitions INTEGER;
    v_total_transfers INTEGER;
    v_total_adjustments INTEGER;
    v_total_movements INTEGER;
    v_total_contracts INTEGER;
    v_total_institutions INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_users FROM users_profiles;
    SELECT COUNT(*) INTO v_total_requisitions FROM requisitions;
    SELECT COUNT(*) INTO v_total_transfers FROM transfers;
    SELECT COUNT(*) INTO v_total_adjustments FROM inventory_adjustments;
    SELECT COUNT(*) INTO v_total_movements FROM batch_movements;
    SELECT COUNT(*) INTO v_total_contracts FROM contracts;
    SELECT COUNT(*) INTO v_total_institutions FROM instituciones;

    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RESUMEN DE DATOS COMPLETOS GENERADOS';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Instituciones: %', v_total_institutions;
    RAISE NOTICE 'Usuarios: %', v_total_users;
    RAISE NOTICE 'Requisiciones: %', v_total_requisitions;
    RAISE NOTICE 'Transferencias: %', v_total_transfers;
    RAISE NOTICE 'Ajustes de inventario: %', v_total_adjustments;
    RAISE NOTICE 'Movimientos de stock: %', v_total_movements;
    RAISE NOTICE 'Contratos: %', v_total_contracts;
    RAISE NOTICE '========================================';
END $$;

-- ==================================================
-- FIN DEL SCRIPT
-- ==================================================
