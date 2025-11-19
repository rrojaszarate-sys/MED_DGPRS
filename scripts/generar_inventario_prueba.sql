-- ================================================
-- SCRIPT DE GENERACIÓN DE INVENTARIO DE PRUEBA
-- Sistema: SIGIMED v2.0
-- ================================================
-- Ejecutar en: Supabase SQL Editor
-- ================================================

BEGIN;

-- ================================================
-- 1. LIMPIAR DATOS ANTERIORES (OPCIONAL)
-- ================================================
-- Descomentar solo si quieres empezar limpio
-- DELETE FROM batch_movements;
-- DELETE FROM batches;

-- ================================================
-- 2. OBTENER IDs NECESARIOS
-- ================================================
-- Nota: Usar IDs existentes de la migración 02_insertar_datos_iniciales.sql

DO $$
DECLARE
  v_center_id_hgz1 UUID := '10000000-0000-0000-0000-000000000001'; -- HGZ1
  v_center_id_cmf23 UUID := '10000000-0000-0000-0000-000000000002'; -- CMF23
  v_supplier_id UUID := '20000000-0000-0000-0000-000000000001'; -- Farmacéutica Nacional
  v_medication_paracetamol UUID;
  v_medication_ibuprofeno UUID;
  v_medication_amoxicilina UUID;
  v_medication_losartan UUID;
  v_medication_metformina UUID;
  v_batch_id UUID;
  v_user_id UUID;
BEGIN

  -- ================================================
  -- 3. OBTENER PRIMER USUARIO (para movimientos)
  -- ================================================
  SELECT id INTO v_user_id FROM users_profiles LIMIT 1;

  -- Si no hay usuario, crear uno genérico
  IF v_user_id IS NULL THEN
    INSERT INTO users_profiles (id, email, nombre_completo)
    VALUES (
      '30000000-0000-0000-0000-000000000001',
      'admin@sigimed.com',
      'Administrador Sistema'
    )
    ON CONFLICT (id) DO NOTHING;
    v_user_id := '30000000-0000-0000-0000-000000000001';
  END IF;

  -- ================================================
  -- 4. CREAR MEDICAMENTOS DE PRUEBA
  -- ================================================

  -- PARACETAMOL 500mg
  INSERT INTO medications (
    id, nombre, clave_cuadro_basico, categoria, subcategoria,
    principio_activo, forma_farmaceutica, concentracion, unidad_medida,
    via_administracion, es_controlado, nivel_atencion, requiere_refrigeracion,
    stock_minimo, stock_maximo, is_active
  ) VALUES (
    '40000000-0000-0000-0000-000000000001',
    'PARACETAMOL 500mg TABLETA',
    'PAR-500-TAB',
    'Analgésicos',
    'No opioides',
    'Paracetamol',
    'Tableta',
    '500mg',
    'Tableta',
    'Oral',
    false,
    1,
    false,
    1000,
    10000,
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    is_active = true;
  v_medication_paracetamol := '40000000-0000-0000-0000-000000000001';

  -- IBUPROFENO 400mg
  INSERT INTO medications (
    id, nombre, clave_cuadro_basico, categoria, subcategoria,
    principio_activo, forma_farmaceutica, concentracion, unidad_medida,
    via_administracion, es_controlado, nivel_atencion, requiere_refrigeracion,
    stock_minimo, stock_maximo, is_active
  ) VALUES (
    '40000000-0000-0000-0000-000000000002',
    'IBUPROFENO 400mg TABLETA',
    'IBU-400-TAB',
    'Antiinflamatorios',
    'AINES',
    'Ibuprofeno',
    'Tableta',
    '400mg',
    'Tableta',
    'Oral',
    false,
    1,
    false,
    800,
    8000,
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    is_active = true;
  v_medication_ibuprofeno := '40000000-0000-0000-0000-000000000002';

  -- AMOXICILINA 500mg
  INSERT INTO medications (
    id, nombre, clave_cuadro_basico, categoria, subcategoria,
    principio_activo, forma_farmaceutica, concentracion, unidad_medida,
    via_administracion, es_controlado, nivel_atencion, requiere_refrigeracion,
    stock_minimo, stock_maximo, is_active
  ) VALUES (
    '40000000-0000-0000-0000-000000000003',
    'AMOXICILINA 500mg CÁPSULA',
    'AMO-500-CAP',
    'Antibióticos',
    'Penicilinas',
    'Amoxicilina',
    'Cápsula',
    '500mg',
    'Cápsula',
    'Oral',
    false,
    1,
    false,
    500,
    5000,
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    is_active = true;
  v_medication_amoxicilina := '40000000-0000-0000-0000-000000000003';

  -- LOSARTAN 50mg
  INSERT INTO medications (
    id, nombre, clave_cuadro_basico, categoria, subcategoria,
    principio_activo, forma_farmaceutica, concentracion, unidad_medida,
    via_administracion, es_controlado, nivel_atencion, requiere_refrigeracion,
    stock_minimo, stock_maximo, is_active
  ) VALUES (
    '40000000-0000-0000-0000-000000000004',
    'LOSARTAN 50mg TABLETA',
    'LOS-50-TAB',
    'Antihipertensivos',
    'ARA II',
    'Losartan',
    'Tableta',
    '50mg',
    'Tableta',
    'Oral',
    false,
    1,
    false,
    600,
    6000,
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    is_active = true;
  v_medication_losartan := '40000000-0000-0000-0000-000000000004';

  -- METFORMINA 850mg
  INSERT INTO medications (
    id, nombre, clave_cuadro_basico, categoria, subcategoria,
    principio_activo, forma_farmaceutica, concentracion, unidad_medida,
    via_administracion, es_controlado, nivel_atencion, requiere_refrigeracion,
    stock_minimo, stock_maximo, is_active
  ) VALUES (
    '40000000-0000-0000-0000-000000000005',
    'METFORMINA 850mg TABLETA',
    'MET-850-TAB',
    'Antidiabéticos',
    'Biguanidas',
    'Metformina',
    'Tableta',
    '850mg',
    'Tableta',
    'Oral',
    false,
    1,
    false,
    700,
    7000,
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    is_active = true;
  v_medication_metformina := '40000000-0000-0000-0000-000000000005';

  RAISE NOTICE '✅ 5 medicamentos creados';

  -- ================================================
  -- 5. CREAR LOTES DE INVENTARIO EN HGZ1
  -- ================================================

  -- Lote 1: PARACETAMOL en HGZ1
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000001',
    v_medication_paracetamol,
    v_center_id_hgz1,
    v_supplier_id,
    'PARA-2025-001',
    5000,
    4500,
    '2024-11-01',
    '2026-11-01',
    '2025-01-15',
    'Anaquel A1',
    '15-25°C',
    1000,
    10000,
    'disponible',
    'Lote de prueba - Stock alto'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 2: IBUPROFENO en HGZ1
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000002',
    v_medication_ibuprofeno,
    v_center_id_hgz1,
    v_supplier_id,
    'IBU-2025-001',
    3000,
    2800,
    '2024-10-15',
    '2026-10-15',
    '2025-01-10',
    'Anaquel A2',
    '15-25°C',
    800,
    8000,
    'disponible',
    'Lote de prueba'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 3: AMOXICILINA en HGZ1
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000003',
    v_medication_amoxicilina,
    v_center_id_hgz1,
    v_supplier_id,
    'AMO-2025-001',
    2000,
    1850,
    '2024-12-01',
    '2026-12-01',
    '2025-02-01',
    'Anaquel B1',
    '15-25°C',
    500,
    5000,
    'disponible',
    'Lote de prueba'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 4: LOSARTAN en HGZ1
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000004',
    v_medication_losartan,
    v_center_id_hgz1,
    v_supplier_id,
    'LOS-2025-001',
    2500,
    2300,
    '2024-11-20',
    '2026-11-20',
    '2025-01-20',
    'Anaquel B2',
    '15-25°C',
    600,
    6000,
    'disponible',
    'Lote de prueba'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 5: METFORMINA en HGZ1
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000005',
    v_medication_metformina,
    v_center_id_hgz1,
    v_supplier_id,
    'MET-2025-001',
    3500,
    3200,
    '2024-11-10',
    '2026-11-10',
    '2025-01-25',
    'Anaquel C1',
    '15-25°C',
    700,
    7000,
    'disponible',
    'Lote de prueba'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  RAISE NOTICE '✅ 5 lotes creados en HGZ1';

  -- ================================================
  -- 6. CREAR LOTES EN CMF23
  -- ================================================

  -- Lote 6: PARACETAMOL en CMF23
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000006',
    v_medication_paracetamol,
    v_center_id_cmf23,
    v_supplier_id,
    'PARA-2025-002',
    2000,
    1800,
    '2024-11-05',
    '2026-11-05',
    '2025-02-10',
    'Farmacia Principal',
    '15-25°C',
    500,
    5000,
    'disponible',
    'Lote CMF23'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 7: IBUPROFENO en CMF23
  INSERT INTO batches (
    id, medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, temperatura_almacenamiento,
    stock_minimo, stock_maximo, estado, observaciones
  ) VALUES (
    '50000000-0000-0000-0000-000000000007',
    v_medication_ibuprofeno,
    v_center_id_cmf23,
    v_supplier_id,
    'IBU-2025-002',
    1500,
    1350,
    '2024-10-20',
    '2026-10-20',
    '2025-02-05',
    'Farmacia Principal',
    '15-25°C',
    400,
    4000,
    'disponible',
    'Lote CMF23'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  RAISE NOTICE '✅ 2 lotes adicionales creados en CMF23';

  -- ================================================
  -- 7. CREAR MOVIMIENTOS DE INVENTARIO
  -- ================================================

  -- Movimiento 1: Entrada inicial PARACETAMOL HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000001',
    v_medication_paracetamol,
    v_center_id_hgz1,
    'entrada',
    5000,
    0,
    5000,
    'Entrada inicial de inventario',
    'Compra directa proveedor',
    v_user_id,
    'PO-2025-001'
  );

  -- Movimiento 2: Salida PARACETAMOL HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000001',
    v_medication_paracetamol,
    v_center_id_hgz1,
    'salida',
    500,
    5000,
    4500,
    'Dispensación a pacientes',
    'Consulta externa - Semana 1',
    v_user_id,
    'DISP-2025-001'
  );

  -- Movimiento 3: Entrada IBUPROFENO HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000002',
    v_medication_ibuprofeno,
    v_center_id_hgz1,
    'entrada',
    3000,
    0,
    3000,
    'Entrada inicial de inventario',
    'Compra directa proveedor',
    v_user_id,
    'PO-2025-002'
  );

  -- Movimiento 4: Salida IBUPROFENO HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000002',
    v_medication_ibuprofeno,
    v_center_id_hgz1,
    'salida',
    200,
    3000,
    2800,
    'Dispensación a pacientes',
    'Urgencias',
    v_user_id,
    'DISP-2025-002'
  );

  -- Movimiento 5: Entrada AMOXICILINA HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000003',
    v_medication_amoxicilina,
    v_center_id_hgz1,
    'entrada',
    2000,
    0,
    2000,
    'Entrada inicial de inventario',
    'Compra directa proveedor',
    v_user_id,
    'PO-2025-003'
  );

  -- Movimiento 6: Salida AMOXICILINA HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000003',
    v_medication_amoxicilina,
    v_center_id_hgz1,
    'salida',
    150,
    2000,
    1850,
    'Dispensación a pacientes',
    'Infecciones respiratorias',
    v_user_id,
    'DISP-2025-003'
  );

  -- Movimiento 7: Entrada LOSARTAN HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000004',
    v_medication_losartan,
    v_center_id_hgz1,
    'entrada',
    2500,
    0,
    2500,
    'Entrada inicial de inventario',
    'Compra directa proveedor',
    v_user_id,
    'PO-2025-004'
  );

  -- Movimiento 8: Salida LOSARTAN HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000004',
    v_medication_losartan,
    v_center_id_hgz1,
    'salida',
    200,
    2500,
    2300,
    'Dispensación a pacientes',
    'Control hipertensión',
    v_user_id,
    'DISP-2025-004'
  );

  -- Movimiento 9: Entrada METFORMINA HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000005',
    v_medication_metformina,
    v_center_id_hgz1,
    'entrada',
    3500,
    0,
    3500,
    'Entrada inicial de inventario',
    'Compra directa proveedor',
    v_user_id,
    'PO-2025-005'
  );

  -- Movimiento 10: Salida METFORMINA HGZ1
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000005',
    v_medication_metformina,
    v_center_id_hgz1,
    'salida',
    300,
    3500,
    3200,
    'Dispensación a pacientes',
    'Control diabetes',
    v_user_id,
    'DISP-2025-005'
  );

  -- Movimientos CMF23
  -- Movimiento 11: Entrada PARACETAMOL CMF23
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000006',
    v_medication_paracetamol,
    v_center_id_cmf23,
    'entrada',
    2000,
    0,
    2000,
    'Entrada inicial de inventario',
    'Transferencia desde almacén central',
    v_user_id,
    'TRANS-2025-001'
  );

  -- Movimiento 12: Salida PARACETAMOL CMF23
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000006',
    v_medication_paracetamol,
    v_center_id_cmf23,
    'salida',
    200,
    2000,
    1800,
    'Dispensación a pacientes',
    'Consulta externa',
    v_user_id,
    'DISP-CMF-001'
  );

  -- Movimiento 13: Entrada IBUPROFENO CMF23
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000007',
    v_medication_ibuprofeno,
    v_center_id_cmf23,
    'entrada',
    1500,
    0,
    1500,
    'Entrada inicial de inventario',
    'Transferencia desde almacén central',
    v_user_id,
    'TRANS-2025-002'
  );

  -- Movimiento 14: Salida IBUPROFENO CMF23
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000007',
    v_medication_ibuprofeno,
    v_center_id_cmf23,
    'salida',
    150,
    1500,
    1350,
    'Dispensación a pacientes',
    'Consulta externa',
    v_user_id,
    'DISP-CMF-002'
  );

  -- Movimiento 15: Ajuste de inventario (ejemplo)
  INSERT INTO batch_movements (
    batch_id, medication_id, center_id,
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
    motivo, observaciones, usuario_responsable, numero_documento
  ) VALUES (
    '50000000-0000-0000-0000-000000000001',
    v_medication_paracetamol,
    v_center_id_hgz1,
    'ajuste',
    0,
    4500,
    4500,
    'Inventario físico mensual',
    'Ajuste por conteo físico - sin discrepancias',
    v_user_id,
    'INV-2025-001'
  );

  RAISE NOTICE '✅ 15 movimientos creados';

END $$;

COMMIT;

-- ================================================
-- 8. VERIFICACIÓN DE RESULTADOS
-- ================================================
SELECT '=== RESUMEN DE DATOS GENERADOS ===' as seccion;

SELECT
  '📦 Medicamentos' as tipo,
  COUNT(*) as total
FROM medications
WHERE id LIKE '40000000%'

UNION ALL

SELECT
  '📊 Lotes de Inventario' as tipo,
  COUNT(*) as total
FROM batches
WHERE id LIKE '50000000%'

UNION ALL

SELECT
  '🔄 Movimientos' as tipo,
  COUNT(*) as total
FROM batch_movements
WHERE batch_id LIKE '50000000%';

-- Detalle de lotes por centro
SELECT '=== INVENTARIO POR CENTRO ===' as seccion;

SELECT
  hc.name as centro,
  m.nombre as medicamento,
  b.numero_lote,
  b.cantidad_actual,
  b.estado,
  b.fecha_caducidad
FROM batches b
JOIN health_centers hc ON b.center_id = hc.id
JOIN medications m ON b.medication_id = m.id
WHERE b.id LIKE '50000000%'
ORDER BY hc.name, m.nombre;

-- Resumen de movimientos
SELECT '=== RESUMEN DE MOVIMIENTOS ===' as seccion;

SELECT
  tipo_movimiento,
  COUNT(*) as total_movimientos,
  SUM(cantidad) as total_unidades
FROM batch_movements
WHERE batch_id LIKE '50000000%'
GROUP BY tipo_movimiento
ORDER BY tipo_movimiento;

SELECT '✅ GENERACIÓN DE INVENTARIO COMPLETADA' as resultado;
