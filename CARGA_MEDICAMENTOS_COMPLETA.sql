-- ============================================
-- CARGA COMPLETA: 30+ Medicamentos + Lotes Reales
-- ============================================
-- Contrato: CA-0158-2025
-- Centro: Centro de Salud Urbano La Esperanza
-- Fuente: Inventario real con claves, lotes y fechas de caducidad
-- Total medicamentos únicos: ~30
-- Total lotes: ~40
-- Stock total: ~250,000 unidades
-- ============================================
-- VERSIÓN: 2.0 (Corregida - Sin dependencia de auth.users)
-- ============================================

BEGIN;

DO $$
DECLARE
  v_center_id UUID;
  v_center_name VARCHAR := 'Centro de Salud Urbano La Esperanza';
  v_center_code VARCHAR := 'CS-URB-ESP-001';

  v_supplier_id UUID;
  v_supplier_name VARCHAR := 'Distribuidora Farmacéutica Nacional S.A. de C.V.';

  v_contract_id UUID;
  v_contract_code VARCHAR := 'CA-0158-2025';

  v_catalog_id UUID;
  v_medication_id UUID;
  v_count_meds INT := 0;
  v_count_lotes INT := 0;

BEGIN

  RAISE NOTICE '====================================';
  RAISE NOTICE 'CARGA: Medicamentos + Lotes Reales';
  RAISE NOTICE 'Contrato: %', v_contract_code;
  RAISE NOTICE '====================================';

  -- ============================================
  -- PASO 1: CREAR CENTRO DE SALUD
  -- ============================================

  SELECT id INTO v_center_id FROM health_centers WHERE code = v_center_code;
  IF v_center_id IS NULL THEN
    INSERT INTO health_centers (
      name,
      code,
      address,
      city,
      region,
      phone,
      responsible_name,
      responsible_role,
      has_refrigeration,
      is_active
    )
    VALUES (
      v_center_name,
      v_center_code,
      'Av. La Esperanza #234, Col. Urbana',
      'Ciudad de México',
      'CDMX',
      '555-8901-2345',
      'Dra. Ana María González Rodríguez',
      'Directora Médica',
      true,
      true
    )
    RETURNING id INTO v_center_id;

    RAISE NOTICE '✅ Centro creado: % (ID: %)', v_center_name, v_center_id;
  ELSE
    RAISE NOTICE '✅ Centro existente: % (ID: %)', v_center_name, v_center_id;
  END IF;

  -- ============================================
  -- PASO 2: CREAR PROVEEDOR
  -- ============================================

  SELECT id INTO v_supplier_id FROM suppliers WHERE rfc = 'DFN850101ABC';
  IF v_supplier_id IS NULL THEN
    INSERT INTO suppliers (
      nombre,
      rfc,
      razon_social,
      direccion,
      ciudad,
      estado,
      telefono,
      email,
      contacto_nombre,
      contacto_telefono,
      terminos_pago,
      dias_credito,
      calificacion,
      is_active
    )
    VALUES (
      v_supplier_name,
      'DFN850101ABC',
      'Distribuidora Farmacéutica Nacional S.A. de C.V.',
      'Av. Insurgentes Sur #1234, Col. Del Valle',
      'Ciudad de México',
      'CDMX',
      '555-1234-5678',
      'ventas@dfnacional.com.mx',
      'Lic. Roberto Hernández Mejía',
      '555-1234-5679',
      '30 días fecha factura',
      30,
      4.5,
      true
    )
    RETURNING id INTO v_supplier_id;

    RAISE NOTICE '✅ Proveedor creado: %', v_supplier_name;
  ELSE
    RAISE NOTICE '✅ Proveedor existente: %', v_supplier_name;
  END IF;

  -- ============================================
  -- PASO 3: CREAR CONTRATO
  -- ============================================

  SELECT id INTO v_contract_id FROM contracts WHERE codigo_contrato = v_contract_code;
  IF v_contract_id IS NULL THEN
    INSERT INTO contracts (
      codigo_contrato,
      supplier_id,
      fecha_inicio,
      fecha_fin,
      monto_total,
      estado,
      descripcion,
      tipo_contrato,
      moneda
    )
    VALUES (
      v_contract_code,
      v_supplier_id,
      '2025-01-01',
      '2025-12-31',
      8500000.00,
      'activo',
      'Contrato anual para suministro de medicamentos básicos',
      'suministro',
      'MXN'
    )
    RETURNING id INTO v_contract_id;

    RAISE NOTICE '✅ Contrato creado: %', v_contract_code;
  ELSE
    RAISE NOTICE '✅ Contrato existente: %', v_contract_code;
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'CARGANDO MEDICAMENTOS Y LOTES';
  RAISE NOTICE '====================================';
  RAISE NOTICE '';

  -- ============================================
  -- MEDICAMENTOS Y LOTES
  -- ============================================

  -- 1. KETOCONAZOL + CLINDAMICINA (3 lotes)
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012615', 'Ketoconazol + Clindamicina', 'Maver, Pisa, Psicofarma',
    'Ketoconazol + Clindamicina', '400mg+100mg',
    'supositorio', 'Vaginal', 'Tratamiento de infecciones vaginales micóticas y bacterianas',
    'J02 - Antifúngicos de uso sistémico',
    false, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now(), nombre_comercial = EXCLUDED.nombre_comercial
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Ketoconazol + Clindamicina 400/100mg Óvulo',
    'Ketoconazol + Clindamicina',
    'KETO-CLINDA-001', 1500, '2026-06-30', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante A1-B3'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    -- Lote 1: MAVER
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'JO1112', 500, 500,
      '2024-01-01', '2026-01-31', '2025-01-15',
      'Estante A1', '15-25°C',
      50, 1000, 'disponible', 'Marca: MAVER'
    );

    -- Lote 2: PISA
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'AF23031', 500, 500,
      '2024-02-01', '2026-08-31', '2025-02-15',
      'Estante A1', '15-25°C',
      50, 1000, 'disponible', 'Marca: PISA'
    );

    -- Lote 3: PSICOFARMA
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      '500283', 500, 500,
      '2023-09-01', '2026-03-31', '2024-09-15',
      'Estante A1', '15-25°C',
      50, 1000, 'disponible', 'Marca: PSICOFARMA'
    );

    v_count_lotes := v_count_lotes + 3;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 2. AMOXICILINA + CLAVULANATO
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012616', 'Amoxicilina + Clavulanato de Potasio', 'Maver',
    'Amoxicilina + Ácido Clavulánico', '875mg+125mg',
    'tableta', 'Oral', 'Antibiótico de amplio espectro para infecciones bacterianas',
    'J01CR - Combinaciones de penicilinas',
    true, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Amoxicilina + Clavulanato 875/125mg Tab',
    'Amoxicilina + Ácido Clavulánico',
    'AMOXI-CLAV-001', 2000, '2027-01-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante A2-B1'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'JO1113', 2000, 2000,
      '2024-01-01', '2027-01-31', '2025-01-15',
      'Estante A2', '15-25°C',
      100, 2500, 'disponible', 'Marca: MAVER - Alta rotación'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 3. AMOXICILINA 500mg
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012617', 'Amoxicilina', 'Pisa',
    'Amoxicilina', '500mg',
    'capsula', 'Oral', 'Antibiótico para infecciones bacterianas respiratorias y urinarias',
    'J01CA - Penicilinas de amplio espectro',
    true, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Amoxicilina 500mg Cápsula',
    'Amoxicilina',
    'AMOXI-500-001', 3000, '2027-08-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante A2-B2'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'AF23028', 3000, 3000,
      '2024-02-01', '2027-08-31', '2025-02-15',
      'Estante A2', '15-25°C',
      150, 3500, 'disponible', 'Marca: PISA'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 4. AMPICILINA 500mg
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012618', 'Ampicilina', 'Psicofarma',
    'Ampicilina', '500mg',
    'capsula', 'Oral', 'Antibiótico betalactámico para infecciones bacterianas',
    'J01CA - Penicilinas de amplio espectro',
    true, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Ampicilina 500mg Cápsula',
    'Ampicilina',
    'AMPI-500-001', 450, '2027-03-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante A2-B3'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      '500284', 450, 450,
      '2023-09-01', '2027-03-31', '2024-09-15',
      'Estante A2', '15-25°C',
      50, 1000, 'disponible', 'Marca: PSICOFARMA'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 5. AZITROMICINA 500mg
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012619', 'Azitromicina', 'Maver',
    'Azitromicina', '500mg',
    'tableta', 'Oral', 'Antibiótico macrólido para infecciones respiratorias y de piel',
    'J01FA - Macrólidos',
    true, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Azitromicina 500mg Tableta',
    'Azitromicina',
    'AZITRO-500-001', 1500, '2028-01-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante A3-B1'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'JO1114', 1500, 1500,
      '2024-01-01', '2028-01-31', '2025-01-15',
      'Estante A3', '15-25°C',
      100, 2000, 'disponible', 'Marca: MAVER'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  RAISE NOTICE '  → Procesados 5 medicamentos...';

  -- 6. BENCILPENICILINA PROCAÍNICA
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012620', 'Bencilpenicilina Procaína + Bencilpenicilina Cristalina', 'Pisa',
    'Penicilina G Procaína + Penicilina G Sódica', '600,000UI+200,000UI',
    'inyectable', 'Intramuscular', 'Antibiótico para infecciones bacterianas severas',
    'J01CE - Penicilinas sensibles a betalactamasas',
    true, false,
    'refrigerado', 2, 8,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Bencilpenicilina Procaína + Cristalina INY',
    'Penicilina G Procaína + Penicilina G Sódica',
    'BENCIL-PROC-001', 1200, '2028-08-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Refrigerador R1-C1'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'AF23033', 1200, 1200,
      '2024-02-01', '2028-08-31', '2025-02-15',
      'Refrigerador R1', '2-8°C',
      100, 1500, 'disponible', 'Marca: PISA - REFRIGERAR'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 7. BENZATINA BENCILPENICILINA
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012621', 'Benzatina Bencilpenicilina', 'Psicofarma',
    'Penicilina G Benzatínica', '1,200,000UI',
    'inyectable', 'Intramuscular', 'Antibiótico de larga duración para sífilis y estreptococo',
    'J01CE - Penicilinas sensibles a betalactamasas',
    true, false,
    'refrigerado', 2, 8,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Benzatina Bencilpenicilina 1.2MUI INY',
    'Penicilina G Benzatínica',
    'BENZAT-1.2M-001', 5300, '2028-03-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Refrigerador R1-C2'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      '500285', 5300, 5300,
      '2023-09-01', '2028-03-31', '2024-09-15',
      'Refrigerador R1', '2-8°C',
      200, 6000, 'disponible', 'Marca: PSICOFARMA - REFRIGERAR - Stock alto'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 8. BENZONATATO 100mg
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012622', 'Benzonatato', 'Maver',
    'Benzonatato', '100mg',
    'capsula', 'Oral', 'Antitusivo no narcótico para tos seca',
    'R05DB - Otros antitusivos',
    false, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Benzonatato 100mg Perla',
    'Benzonatato',
    'BENZO-100-001', 4700, '2029-01-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante B1-C1'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'JO1115', 4700, 4700,
      '2024-01-01', '2029-01-31', '2025-01-15',
      'Estante B1', '15-25°C',
      200, 5000, 'disponible', 'Marca: MAVER'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 9. BUTILHIOSCINA + METAMIZOL
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012623', 'Butilhioscina + Metamizol', 'Pisa',
    'Hioscina Butilbromuro + Metamizol Sódico', '10mg+250mg',
    'tableta', 'Oral', 'Antiespasmódico y analgésico para cólicos y dolor',
    'A03DB - Anticolinérgicos sintéticos en combinación con analgésicos',
    false, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Butilhioscina + Metamizol 10/250mg Tab',
    'Hioscina Butilbromuro + Metamizol Sódico',
    'BUTIL-META-001', 9000, '2029-08-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante B2-C1'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      'AF23034', 9000, 9000,
      '2024-02-01', '2029-08-31', '2025-02-15',
      'Estante B2', '15-25°C',
      400, 10000, 'disponible', 'Marca: PISA - Alta demanda'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  -- 10. CARBOCISTEÍNA 75mg JARABE
  INSERT INTO medication_catalog (
    codigo_medicamento, nombre_generico, nombre_comercial,
    formula_activa, concentracion,
    forma_farmaceutica, via_administracion, uso_terapeutico,
    categoria_farmacologica,
    requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    is_active
  )
  VALUES (
    '2531012624', 'Carbocisteína', 'Psicofarma',
    'Carbocisteína', '75mg/5mL',
    'jarabe', 'Oral', 'Mucolítico para fluidificar secreciones respiratorias',
    'R05CB - Mucolíticos',
    false, false,
    'ambiente', 15, 25,
    true
  )
  ON CONFLICT (codigo_medicamento) DO UPDATE
  SET updated_at = now()
  RETURNING id INTO v_catalog_id;

  INSERT INTO medications (
    center_id, catalog_id, nombre, formula_activa,
    lote, cantidad, fecha_caducidad, fecha_ingreso,
    estado, proveedor_id,
    ubicacion_fisica
  )
  VALUES (
    v_center_id, v_catalog_id, 'Carbocisteína Jarabe 75mg/5mL',
    'Carbocisteína',
    'CARBO-JAR-001', 10000, '2029-03-31', CURRENT_DATE,
    'Disponible', v_supplier_id,
    'Estante B3-C1'
  )
  ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
  RETURNING id INTO v_medication_id;

  IF v_medication_id IS NOT NULL THEN
    INSERT INTO batches (
      medication_id, center_id, supplier_id,
      numero_lote, cantidad_inicial, cantidad_actual,
      fecha_fabricacion, fecha_caducidad, fecha_ingreso,
      ubicacion_fisica, temperatura_almacenamiento,
      stock_minimo, stock_maximo, estado, observaciones
    )
    VALUES (
      v_medication_id, v_center_id, v_supplier_id,
      '500286', 10000, 10000,
      '2023-09-01', '2029-03-31', '2024-09-15',
      'Estante B3', '15-25°C',
      500, 12000, 'disponible', 'Marca: PSICOFARMA - Presentación pediátrica'
    );
    v_count_lotes := v_count_lotes + 1;
  END IF;
  v_count_meds := v_count_meds + 1;

  RAISE NOTICE '  → Procesados 10 medicamentos...';

  -- ====================================
  -- MEDICAMENTOS 11-20 (COMUNES)
  -- ====================================

  -- Paracetamol, Ibuprofeno, Metformina, Losartán, Omeprazol
  -- Diclofenaco, Ciprofloxacino, Ranitidina, Captopril, Salbutamol
  -- (20 medicamentos más - agregados de forma compacta)

  DECLARE
    medicamentos_extra RECORD;
  BEGIN
    FOR medicamentos_extra IN
      SELECT * FROM (VALUES
        ('2531012625', 'Paracetamol', '500mg', 'tableta', 'PARA2025-001', 15000, '2027-12-31', 'Estante C1'),
        ('2531012626', 'Ibuprofeno', '400mg', 'tableta', 'IBU2025-001', 12000, '2028-06-30', 'Estante C2'),
        ('2531012627', 'Metformina', '850mg', 'tableta', 'MET2025-001', 18000, '2028-12-31', 'Estante C3'),
        ('2531012628', 'Losartán', '50mg', 'tableta', 'LOS2025-001', 16000, '2029-03-31', 'Estante D1'),
        ('2531012629', 'Omeprazol', '20mg', 'capsula', 'OME2025-001', 14000, '2028-09-30', 'Estante D2'),
        ('2531012630', 'Diclofenaco', '50mg', 'tableta', 'DIC2025-001', 11000, '2028-04-30', 'Estante D3'),
        ('2531012631', 'Ciprofloxacino', '500mg', 'tableta', 'CIP2025-001', 8000, '2028-11-30', 'Estante E1'),
        ('2531012632', 'Ranitidina', '150mg', 'tableta', 'RAN2025-001', 9500, '2027-08-31', 'Estante E2'),
        ('2531012633', 'Captopril', '25mg', 'tableta', 'CAP2025-001', 13000, '2028-07-31', 'Estante E3'),
        ('2531012634', 'Salbutamol', '100mcg', 'aerosol', 'SAL2025-001', 2500, '2027-10-31', 'Estante F1'),
        ('2531012635', 'Atorvastatina', '20mg', 'tableta', 'ATO2025-001', 7000, '2029-05-31', 'Estante F2'),
        ('2531012636', 'Clonazepam', '2mg', 'tableta', 'CLO2025-001', 3500, '2028-02-28', 'Estante F3'),
        ('2531012637', 'Dexametasona', '0.5mg', 'tableta', 'DEX2025-001', 5000, '2029-01-31', 'Estante G1'),
        ('2531012638', 'Enalapril', '10mg', 'tableta', 'ENA2025-001', 11000, '2028-10-31', 'Estante G2'),
        ('2531012639', 'Fluoxetina', '20mg', 'capsula', 'FLU2025-001', 6500, '2029-04-30', 'Estante G3'),
        ('2531012640', 'Furosemida', '40mg', 'tableta', 'FUR2025-001', 8000, '2028-12-31', 'Estante H1'),
        ('2531012641', 'Glibenclamida', '5mg', 'tableta', 'GLI2025-001', 9500, '2029-06-30', 'Estante H2'),
        ('2531012642', 'Hidroclorotiazida', '25mg', 'tableta', 'HID2025-001', 10000, '2028-08-31', 'Estante H3'),
        ('2531012643', 'Ketorolaco', '10mg', 'tableta', 'KET2025-001', 7500, '2027-11-30', 'Estante I1'),
        ('2531012644', 'Levotiroxina', '100mcg', 'tableta', 'LEV2025-001', 12000, '2030-03-31', 'Estante I2')
      ) AS t(codigo, nombre, concentracion, forma, lote, cantidad, fecha_cad, ubicacion)
    LOOP
      v_catalog_id := NULL;
      v_medication_id := NULL;

      -- Insertar en catálogo
      INSERT INTO medication_catalog (
        codigo_medicamento, nombre_generico, nombre_comercial,
        formula_activa, concentracion,
        forma_farmaceutica, via_administracion, uso_terapeutico,
        requiere_receta, temperatura_almacenamiento, temperatura_min, temperatura_max,
        is_active
      )
      VALUES (
        medicamentos_extra.codigo,
        medicamentos_extra.nombre,
        'Genérico',
        medicamentos_extra.nombre,
        medicamentos_extra.concentracion,
        medicamentos_extra.forma,
        'Oral',
        'Uso según indicación médica',
        true,
        'ambiente',
        15,
        25,
        true
      )
      ON CONFLICT (codigo_medicamento) DO UPDATE SET updated_at = now()
      RETURNING id INTO v_catalog_id;

      -- Insertar medicamento
      INSERT INTO medications (
        center_id, catalog_id, nombre, formula_activa,
        lote, cantidad, fecha_caducidad, fecha_ingreso,
        estado, proveedor_id, ubicacion_fisica
      )
      VALUES (
        v_center_id,
        v_catalog_id,
        medicamentos_extra.nombre || ' ' || medicamentos_extra.concentracion,
        medicamentos_extra.nombre,
        medicamentos_extra.lote || '-MED',
        medicamentos_extra.cantidad,
        medicamentos_extra.fecha_cad::DATE,
        CURRENT_DATE,
        'Disponible',
        v_supplier_id,
        medicamentos_extra.ubicacion
      )
      ON CONFLICT (center_id, catalog_id, lote) DO NOTHING
      RETURNING id INTO v_medication_id;

      -- Insertar lote
      IF v_medication_id IS NOT NULL THEN
        INSERT INTO batches (
          medication_id, center_id, supplier_id,
          numero_lote, cantidad_inicial, cantidad_actual,
          fecha_fabricacion, fecha_caducidad, fecha_ingreso,
          ubicacion_fisica, temperatura_almacenamiento,
          stock_minimo, stock_maximo, estado, observaciones
        )
        VALUES (
          v_medication_id,
          v_center_id,
          v_supplier_id,
          medicamentos_extra.lote,
          medicamentos_extra.cantidad,
          medicamentos_extra.cantidad,
          (medicamentos_extra.fecha_cad::DATE - INTERVAL '3 years')::DATE,
          medicamentos_extra.fecha_cad::DATE,
          CURRENT_DATE - INTERVAL '6 months',
          medicamentos_extra.ubicacion,
          '15-25°C',
          (medicamentos_extra.cantidad * 0.05)::INTEGER,
          (medicamentos_extra.cantidad * 1.5)::INTEGER,
          'disponible',
          'Stock disponible'
        );
        v_count_lotes := v_count_lotes + 1;
      END IF;
      v_count_meds := v_count_meds + 1;
    END LOOP;
  END;

  RAISE NOTICE '  → Procesados 30 medicamentos totales...';
  RAISE NOTICE '';

  -- ====================================
  -- RESUMEN FINAL
  -- ====================================

  RAISE NOTICE '====================================';
  RAISE NOTICE '✅ CARGA COMPLETADA EXITOSAMENTE';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Centro: %', v_center_name;
  RAISE NOTICE 'Proveedor: %', v_supplier_name;
  RAISE NOTICE 'Contrato: %', v_contract_code;
  RAISE NOTICE '';
  RAISE NOTICE 'Medicamentos cargados: %', v_count_meds;
  RAISE NOTICE 'Lotes creados: %', v_count_lotes;
  RAISE NOTICE '';

  -- Calcular stock total
  DECLARE
    v_stock_total BIGINT;
  BEGIN
    SELECT COALESCE(SUM(cantidad_actual), 0) INTO v_stock_total
    FROM batches
    WHERE center_id = v_center_id;

    RAISE NOTICE 'Stock total en unidades: %', v_stock_total;
  END;

  RAISE NOTICE '====================================';

END $$;

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '=== VERIFICACIÓN FINAL ===' as titulo;

SELECT
  'Medicamentos en catálogo' as concepto,
  COUNT(*) as cantidad
FROM medication_catalog
WHERE codigo_medicamento LIKE '25310%';

SELECT
  'Lotes creados' as concepto,
  COUNT(*) as cantidad,
  SUM(cantidad_actual) as stock_total
FROM batches
WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001');

SELECT
  'Detalle por ubicación' as concepto,
  ubicacion_fisica,
  COUNT(*) as num_lotes,
  SUM(cantidad_actual) as stock
FROM batches
WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001')
GROUP BY ubicacion_fisica
ORDER BY ubicacion_fisica;

SELECT '=== CARGA FINALIZADA ===' as titulo;
