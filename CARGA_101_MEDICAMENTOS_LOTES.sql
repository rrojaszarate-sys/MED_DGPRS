-- ============================================
-- CARGA MASIVA: 101 MEDICAMENTOS + LOTES
-- ============================================
-- Este script carga 101 medicamentos reales con:
-- 1. Entrada en medication_catalog (catálogo maestro)
-- 2. Instancia en medications (asignada a centro)
-- 3. Lotes (batches) con stock inicial
-- 4. Centro: "Centro de Salud Urbano La Esperanza"
-- 5. Contrato: CA-0158-2025
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: CONFIGURACIÓN Y VARIABLES
-- ============================================

DO $$
DECLARE
  v_center_id UUID;
  v_center_name VARCHAR := 'Centro de Salud Urbano La Esperanza';
  v_center_code VARCHAR := 'CS-URB-ESP-001';

  v_contract_id UUID;
  v_contract_code VARCHAR := 'CA-0158-2025';

  v_supplier_id UUID;
  v_supplier_name VARCHAR := 'Distribuidora Farmacéutica Nacional';

  v_catalog_id UUID;
  v_medication_id UUID;
  v_batch_id UUID;

  v_counter INT := 0;

  -- Array de medicamentos (código, nombre, comercial, forma, vía, concentración, categoría)
  TYPE t_medicamento IS RECORD (
    codigo TEXT,
    nombre_generico TEXT,
    nombre_comercial TEXT,
    forma_farmaceutica TEXT,
    via_administracion TEXT,
    concentracion TEXT,
    categoria TEXT,
    requiere_receta BOOLEAN,
    controlado BOOLEAN,
    temperatura TEXT
  );

  v_medicamentos t_medicamento[];
  v_med t_medicamento;

BEGIN

  RAISE NOTICE '====================================';
  RAISE NOTICE 'INICIO: Carga de 101 medicamentos';
  RAISE NOTICE '====================================';

  -- ============================================
  -- PASO 2: VERIFICAR/CREAR CENTRO DE SALUD
  -- ============================================

  SELECT id INTO v_center_id
  FROM health_centers
  WHERE code = v_center_code;

  IF v_center_id IS NULL THEN
    INSERT INTO health_centers (
      name,
      code,
      address,
      city,
      phone,
      is_active
    ) VALUES (
      v_center_name,
      v_center_code,
      'Av. La Esperanza #234, Col. Urbana',
      'Ciudad de México',
      '555-8901',
      true
    )
    RETURNING id INTO v_center_id;

    RAISE NOTICE '✅ Centro creado: % (ID: %)', v_center_name, v_center_id;
  ELSE
    RAISE NOTICE '✅ Centro encontrado: % (ID: %)', v_center_name, v_center_id;
  END IF;

  -- ============================================
  -- PASO 3: VERIFICAR/CREAR PROVEEDOR
  -- ============================================

  SELECT id INTO v_supplier_id
  FROM suppliers
  WHERE nombre = v_supplier_name
  LIMIT 1;

  IF v_supplier_id IS NULL THEN
    INSERT INTO suppliers (
      nombre,
      rfc,
      razon_social,
      telefono,
      email,
      dias_credito,
      is_active
    ) VALUES (
      v_supplier_name,
      'DFN850101ABC',
      'Distribuidora Farmacéutica Nacional S.A. de C.V.',
      '555-1234',
      'ventas@dfnacional.com.mx',
      30,
      true
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_supplier_id;

    IF v_supplier_id IS NOT NULL THEN
      RAISE NOTICE '✅ Proveedor creado: % (ID: %)', v_supplier_name, v_supplier_id;
    ELSE
      -- Si hubo conflicto, obtener el ID existente
      SELECT id INTO v_supplier_id FROM suppliers WHERE nombre = v_supplier_name LIMIT 1;
      RAISE NOTICE '✅ Proveedor encontrado: % (ID: %)', v_supplier_name, v_supplier_id;
    END IF;
  ELSE
    RAISE NOTICE '✅ Proveedor encontrado: % (ID: %)', v_supplier_name, v_supplier_id;
  END IF;

  -- ============================================
  -- PASO 4: VERIFICAR/CREAR CONTRATO
  -- ============================================

  SELECT id INTO v_contract_id
  FROM contracts
  WHERE codigo_contrato = v_contract_code;

  IF v_contract_id IS NULL THEN
    INSERT INTO contracts (
      codigo_contrato,
      supplier_id,
      fecha_inicio,
      fecha_fin,
      monto_total,
      estado,
      observaciones
    ) VALUES (
      v_contract_code,
      v_supplier_id,
      '2025-01-01',
      '2025-12-31',
      5000000.00,
      'activo',
      'Contrato anual para suministro de medicamentos al Centro de Salud Urbano La Esperanza'
    )
    ON CONFLICT (codigo_contrato) DO NOTHING
    RETURNING id INTO v_contract_id;

    IF v_contract_id IS NOT NULL THEN
      RAISE NOTICE '✅ Contrato creado: % (ID: %)', v_contract_code, v_contract_id;
    ELSE
      SELECT id INTO v_contract_id FROM contracts WHERE codigo_contrato = v_contract_code;
      RAISE NOTICE '✅ Contrato encontrado: % (ID: %)', v_contract_code, v_contract_id;
    END IF;
  ELSE
    RAISE NOTICE '✅ Contrato encontrado: % (ID: %)', v_contract_code, v_contract_id;
  END IF;

  -- ============================================
  -- PASO 5: DEFINIR ARRAY DE 101 MEDICAMENTOS
  -- ============================================

  v_medicamentos := ARRAY[
    -- ANTIINFECCIOSOS (1-25)
    ROW('MED-2531012615', 'Ketoconazol 400mg + Clindamicina 100mg', 'Maver, Pisa, Loefler, Senosiain', 'Óvulo', 'Tópica', '400mg+100mg', 'Antifúngico + Antibiótico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012616', 'Amoxicilina 500mg', 'Amoxil, Novamox, Amox', 'Cápsula', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012617', 'Ciprofloxacino 500mg', 'Cipro, Ciflox', 'Tableta', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012618', 'Azitromicina 500mg', 'Zitromax, Azro', 'Tableta', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012619', 'Cefalexina 500mg', 'Keflex, Ceporex', 'Cápsula', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012620', 'Metronidazol 500mg', 'Flagyl, Metronid', 'Tableta', 'Oral', '500mg', 'Antiparasitario', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012621', 'Clotrimazol 1% Crema', 'Canesten, Clotrim', 'Crema', 'Tópica', '1%', 'Antifúngico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012622', 'Fluconazol 150mg', 'Diflucan, Fluco', 'Cápsula', 'Oral', '150mg', 'Antifúngico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012623', 'Aciclovir 400mg', 'Zovirax, Aciclo', 'Tableta', 'Oral', '400mg', 'Antiviral', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012624', 'Penicilina G Benzatínica 1.200.000 UI', 'Benzetacil, Penilevel', 'Inyectable', 'Intramuscular', '1.2MUI', 'Antibiótico', true, false, '2-8°C')::t_medicamento,
    ROW('MED-2531012625', 'Eritromicina 500mg', 'Ilosone, Pantomicina', 'Tableta', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012626', 'Levofloxacino 500mg', 'Levaquin, Tavanic', 'Tableta', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012627', 'Nitrofurantoína 100mg', 'Macrodantina, Furadantina', 'Cápsula', 'Oral', '100mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012628', 'Trimetoprima + Sulfametoxazol 160/800mg', 'Bactrim, Septra', 'Tableta', 'Oral', '160/800mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012629', 'Doxiciclina 100mg', 'Vibramicina, Doximar', 'Cápsula', 'Oral', '100mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012630', 'Claritromicina 500mg', 'Klaricid, Clarem', 'Tableta', 'Oral', '500mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012631', 'Mebendazol 100mg', 'Vermox, Lomper', 'Tableta', 'Oral', '100mg', 'Antiparasitario', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012632', 'Albendazol 400mg', 'Zentel, Andazol', 'Tableta', 'Oral', '400mg', 'Antiparasitario', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012633', 'Nistatina 100.000 UI Suspensión', 'Mycostatin', 'Suspensión', 'Oral', '100.000UI/mL', 'Antifúngico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012634', 'Ceftriaxona 1g Inyectable', 'Rocephin, Ceftria', 'Inyectable', 'Intramuscular/IV', '1g', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012635', 'Gentamicina 80mg Inyectable', 'Garamicina, Gentalyn', 'Inyectable', 'Intramuscular/IV', '80mg', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012636', 'Vancomicina 500mg Inyectable', 'Vancocin, Vanco', 'Inyectable', 'Intravenosa', '500mg', 'Antibiótico', true, true, '2-8°C')::t_medicamento,
    ROW('MED-2531012637', 'Ampicilina 1g Inyectable', 'Pentrexyl, Ampi', 'Inyectable', 'Intramuscular/IV', '1g', 'Antibiótico', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012638', 'Oseltamivir 75mg', 'Tamiflu', 'Cápsula', 'Oral', '75mg', 'Antiviral', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012639', 'Ivermectina 6mg', 'Ivexterm, Quanox', 'Tableta', 'Oral', '6mg', 'Antiparasitario', true, false, '15-25°C')::t_medicamento,

    -- ANALGÉSICOS Y ANTIINFLAMATORIOS (26-50)
    ROW('MED-2531012640', 'Paracetamol 500mg', 'Tafirol, Tempra', 'Tableta', 'Oral', '500mg', 'Analgésico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012641', 'Ibuprofeno 400mg', 'Motrin, Actron', 'Tableta', 'Oral', '400mg', 'AINE', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012642', 'Naproxeno 500mg', 'Flanax, Naprosyn', 'Tableta', 'Oral', '500mg', 'AINE', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012643', 'Diclofenaco 100mg', 'Voltaren, Dolotren', 'Tableta', 'Oral', '100mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012644', 'Ketorolaco 10mg', 'Dolac, Toradol', 'Tableta', 'Oral', '10mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012645', 'Meloxicam 15mg', 'Mobic, Movalis', 'Tableta', 'Oral', '15mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012646', 'Metamizol 500mg', 'Novalgin, Buscapina Compositum', 'Tableta', 'Oral', '500mg', 'Analgésico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012647', 'Tramadol 50mg', 'Tramal, Adolonta', 'Cápsula', 'Oral', '50mg', 'Analgésico', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012648', 'Morfina 10mg', 'MST Continus', 'Tableta', 'Oral', '10mg', 'Analgésico Opioide', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012649', 'Celecoxib 200mg', 'Celebrex, Coxicel', 'Cápsula', 'Oral', '200mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012650', 'Aspirina 100mg', 'Aspirina Protect, ASA', 'Tableta', 'Oral', '100mg', 'Antiagregante', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012651', 'Etoricoxib 90mg', 'Arcoxia, Etori', 'Tableta', 'Oral', '90mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012652', 'Paracetamol 1g', 'Tafirol Forte, Paracetamol 1g', 'Tableta', 'Oral', '1g', 'Analgésico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012653', 'Ibuprofeno 600mg', 'Motrin 600, Actron 600', 'Tableta', 'Oral', '600mg', 'AINE', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012654', 'Diclofenaco Gel 1%', 'Voltaren Emulgel', 'Gel', 'Tópica', '1%', 'AINE Tópico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012655', 'Ketoprofeno 100mg', 'Profenid, Orudis', 'Cápsula', 'Oral', '100mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012656', 'Piroxicam 20mg', 'Feldene, Roxicam', 'Cápsula', 'Oral', '20mg', 'AINE', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012657', 'Paracetamol + Codeína 500/30mg', 'Tylex, Prodolina', 'Tableta', 'Oral', '500/30mg', 'Analgésico', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012658', 'Butilhioscina 10mg', 'Buscapina, Hyospan', 'Tableta', 'Oral', '10mg', 'Antiespasmódico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012659', 'Colchicina 0.5mg', 'Colchicine', 'Tableta', 'Oral', '0.5mg', 'Antigotoso', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012660', 'Dexametasona 4mg', 'Decadron, Alin', 'Tableta', 'Oral', '4mg', 'Corticosteroide', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012661', 'Prednisona 5mg', 'Meticorten, Deltisona', 'Tableta', 'Oral', '5mg', 'Corticosteroide', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012662', 'Prednisona 20mg', 'Meticorten 20, Deltisona B', 'Tableta', 'Oral', '20mg', 'Corticosteroide', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012663', 'Betametasona 0.5mg', 'Celestone, Betacorten', 'Tableta', 'Oral', '0.5mg', 'Corticosteroide', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012664', 'Hidrocortisona Crema 1%', 'Cortaid, Hidro Crema', 'Crema', 'Tópica', '1%', 'Corticosteroide', false, false, '15-25°C')::t_medicamento,

    -- CARDIOVASCULARES Y ANTIDIABÉTICOS (51-75)
    ROW('MED-2531012665', 'Enalapril 10mg', 'Renitec, Enaplus', 'Tableta', 'Oral', '10mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012666', 'Losartán 50mg', 'Cozaar, Losacor', 'Tableta', 'Oral', '50mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012667', 'Amlodipino 5mg', 'Norvasc, Amlopin', 'Tableta', 'Oral', '5mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012668', 'Metformina 850mg', 'Glucophage, Diabex', 'Tableta', 'Oral', '850mg', 'Antidiabético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012669', 'Glibenclamida 5mg', 'Daonil, Euglucon', 'Tableta', 'Oral', '5mg', 'Antidiabético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012670', 'Insulina NPH 100UI/mL', 'Humulin N, Insulatard', 'Inyectable', 'Subcutánea', '100UI/mL', 'Antidiabético', true, true, '2-8°C')::t_medicamento,
    ROW('MED-2531012671', 'Insulina Rápida 100UI/mL', 'Humulin R, Actrapid', 'Inyectable', 'Subcutánea', '100UI/mL', 'Antidiabético', true, true, '2-8°C')::t_medicamento,
    ROW('MED-2531012672', 'Atorvastatina 20mg', 'Lipitor, Atoris', 'Tableta', 'Oral', '20mg', 'Hipolipemiante', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012673', 'Simvastatina 40mg', 'Zocor, Simvacol', 'Tableta', 'Oral', '40mg', 'Hipolipemiante', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012674', 'Propranolol 40mg', 'Inderal, Propra', 'Tableta', 'Oral', '40mg', 'Betabloqueador', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012675', 'Carvedilol 6.25mg', 'Dilatrend, Carveda', 'Tableta', 'Oral', '6.25mg', 'Betabloqueador', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012676', 'Furosemida 40mg', 'Lasix, Furosemix', 'Tableta', 'Oral', '40mg', 'Diurético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012677', 'Hidroclorotiazida 25mg', 'Esidrex, Diurace', 'Tableta', 'Oral', '25mg', 'Diurético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012678', 'Espironolactona 25mg', 'Aldactone, Spirolac', 'Tableta', 'Oral', '25mg', 'Diurético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012679', 'Digoxina 0.25mg', 'Lanoxin, Digoxil', 'Tableta', 'Oral', '0.25mg', 'Cardiotónico', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012680', 'Clopidogrel 75mg', 'Plavix, Clopivas', 'Tableta', 'Oral', '75mg', 'Antiagregante', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012681', 'Warfarina 5mg', 'Coumadin, Warflex', 'Tableta', 'Oral', '5mg', 'Anticoagulante', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012682', 'Enalapril 20mg', 'Renitec 20, Enaplus 20', 'Tableta', 'Oral', '20mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012683', 'Losartán 100mg', 'Cozaar 100, Losacor 100', 'Tableta', 'Oral', '100mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012684', 'Amlodipino 10mg', 'Norvasc 10, Amlopin 10', 'Tableta', 'Oral', '10mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012685', 'Metformina 500mg', 'Glucophage 500, Diabex 500', 'Tableta', 'Oral', '500mg', 'Antidiabético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012686', 'Metformina 1000mg', 'Glucophage XR, Diabex 1000', 'Tableta', 'Oral', '1000mg', 'Antidiabético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012687', 'Glimepirida 2mg', 'Amaryl, Glimepi', 'Tableta', 'Oral', '2mg', 'Antidiabético', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012688', 'Captopril 25mg', 'Capoten, Captol', 'Tableta', 'Oral', '25mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012689', 'Valsartán 80mg', 'Diovan, Vals', 'Tableta', 'Oral', '80mg', 'Antihipertensivo', true, false, '15-25°C')::t_medicamento,

    -- GASTROINTESTINALES Y OTROS (76-101)
    ROW('MED-2531012690', 'Omeprazol 20mg', 'Prilosec, Losec', 'Cápsula', 'Oral', '20mg', 'Inhibidor Bomba de Protones', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012691', 'Ranitidina 150mg', 'Zantac, Ranitil', 'Tableta', 'Oral', '150mg', 'Antiulceroso', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012692', 'Pantoprazol 40mg', 'Protonix, Panto', 'Tableta', 'Oral', '40mg', 'Inhibidor Bomba de Protones', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012693', 'Metoclopramida 10mg', 'Primperan, Plasil', 'Tableta', 'Oral', '10mg', 'Antiemético', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012694', 'Loperamida 2mg', 'Imodium, Loperal', 'Cápsula', 'Oral', '2mg', 'Antidiarreico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012695', 'Lactulosa Jarabe', 'Duphalac, Lactulax', 'Jarabe', 'Oral', '667mg/mL', 'Laxante', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012696', 'Bisacodilo 5mg', 'Dulcolax, Correctol', 'Tableta', 'Oral', '5mg', 'Laxante', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012697', 'Hidróxido de Aluminio Suspensión', 'Maalox, Alugel', 'Suspensión', 'Oral', '400mg/5mL', 'Antiácido', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012698', 'Domperidona 10mg', 'Motilium, Dompe', 'Tableta', 'Oral', '10mg', 'Procinético', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012699', 'Simeticona 80mg', 'Espaven, Gaseovet', 'Tableta', 'Oral', '80mg', 'Antiflatulento', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012700', 'Levotiroxina 100mcg', 'Synthroid, Euthyrox', 'Tableta', 'Oral', '100mcg', 'Hormona Tiroidea', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012701', 'Levotiroxina 50mcg', 'Synthroid 50, Euthyrox 50', 'Tableta', 'Oral', '50mcg', 'Hormona Tiroidea', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012702', 'Loratadina 10mg', 'Clarityne, Lora', 'Tableta', 'Oral', '10mg', 'Antihistamínico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012703', 'Cetirizina 10mg', 'Zyrtec, Virlix', 'Tableta', 'Oral', '10mg', 'Antihistamínico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012704', 'Fexofenadina 120mg', 'Allegra, Fexo', 'Tableta', 'Oral', '120mg', 'Antihistamínico', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012705', 'Montelukast 10mg', 'Singulair, Lukasm', 'Tableta', 'Oral', '10mg', 'Antiasmático', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012706', 'Salbutamol Inhalador 100mcg', 'Ventolin, Salbuair', 'Inhalador', 'Inhalatoria', '100mcg/dosis', 'Broncodilatador', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012707', 'Beclometasona Inhalador 250mcg', 'Beclo-Asma, Beclovent', 'Inhalador', 'Inhalatoria', '250mcg/dosis', 'Corticosteroide', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012708', 'Fluticasona Nasal 50mcg', 'Flonase, Flixonase', 'Spray Nasal', 'Nasal', '50mcg/dosis', 'Corticosteroide', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012709', 'Alprazolam 0.5mg', 'Xanax, Tafil', 'Tableta', 'Oral', '0.5mg', 'Ansiolítico', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012710', 'Clonazepam 2mg', 'Rivotril, Clonagin', 'Tableta', 'Oral', '2mg', 'Ansiolítico', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012711', 'Diazepam 10mg', 'Valium, Ansi', 'Tableta', 'Oral', '10mg', 'Ansiolítico', true, true, '15-25°C')::t_medicamento,
    ROW('MED-2531012712', 'Sertralina 50mg', 'Zoloft, Altruline', 'Tableta', 'Oral', '50mg', 'Antidepresivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012713', 'Fluoxetina 20mg', 'Prozac, Fluox', 'Cápsula', 'Oral', '20mg', 'Antidepresivo', true, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012714', 'Ácido Fólico 5mg', 'Folvite, Folacin', 'Tableta', 'Oral', '5mg', 'Vitamina', false, false, '15-25°C')::t_medicamento,
    ROW('MED-2531012715', 'Complejo B Inyectable', 'Bedoyecta, Tribedoce', 'Inyectable', 'Intramuscular', '100mg/mL', 'Vitamina', false, false, '15-25°C')::t_medicamento
  ];

  RAISE NOTICE '====================================';
  RAISE NOTICE 'PASO 6: Insertando medicamentos';
  RAISE NOTICE '====================================';

  -- ============================================
  -- PASO 6: INSERTAR MEDICAMENTOS EN LOOP
  -- ============================================

  FOREACH v_med IN ARRAY v_medicamentos
  LOOP
    v_counter := v_counter + 1;

    -- 6.1 Insertar en medication_catalog
    INSERT INTO medication_catalog (
      codigo_medicamento,
      nombre_generico,
      nombre_comercial,
      forma_farmaceutica,
      via_administracion,
      concentracion,
      categoria,
      requiere_receta,
      controlado,
      temperatura_almacenamiento,
      is_active
    ) VALUES (
      v_med.codigo,
      v_med.nombre_generico,
      v_med.nombre_comercial,
      v_med.forma_farmaceutica,
      v_med.via_administracion,
      v_med.concentracion,
      v_med.categoria,
      v_med.requiere_receta,
      v_med.controlado,
      v_med.temperatura,
      true
    )
    ON CONFLICT (codigo_medicamento) DO UPDATE
      SET nombre_generico = EXCLUDED.nombre_generico,
          updated_at = now()
    RETURNING id INTO v_catalog_id;

    -- 6.2 Insertar instancia en medications
    INSERT INTO medications (
      center_id,
      catalog_id,
      nombre,
      unidad_medida,
      categoria,
      requiere_refrigeracion,
      is_active
    ) VALUES (
      v_center_id,
      v_catalog_id,
      v_med.nombre_generico,
      CASE
        WHEN v_med.forma_farmaceutica IN ('Tableta', 'Cápsula') THEN 'Caja'
        WHEN v_med.forma_farmaceutica IN ('Inyectable') THEN 'Ampolleta'
        WHEN v_med.forma_farmaceutica IN ('Jarabe', 'Suspensión') THEN 'Frasco'
        WHEN v_med.forma_farmaceutica IN ('Crema', 'Gel') THEN 'Tubo'
        WHEN v_med.forma_farmaceutica IN ('Inhalador') THEN 'Dispositivo'
        ELSE 'Unidad'
      END,
      v_med.categoria,
      v_med.temperatura LIKE '%2-8%',
      true
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_medication_id;

    -- 6.3 Crear lote inicial (solo si se creó la instancia)
    IF v_medication_id IS NOT NULL THEN
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
        v_medication_id,
        v_center_id,
        v_supplier_id,
        'LOTE-' || v_contract_code || '-' || LPAD(v_counter::TEXT, 3, '0'),
        (100 + (random() * 400)::INT),  -- Entre 100 y 500 unidades
        (100 + (random() * 400)::INT),
        current_date - interval '6 months',
        current_date + interval '18 months',  -- 18 meses de vigencia
        current_date - interval '1 month',
        50,
        1000,
        'disponible',
        'Lote inicial - Contrato ' || v_contract_code
      );
    END IF;

    -- Log cada 20 medicamentos
    IF v_counter % 20 = 0 THEN
      RAISE NOTICE '  → Procesados % medicamentos...', v_counter;
    END IF;

  END LOOP;

  RAISE NOTICE '====================================';
  RAISE NOTICE '✅ COMPLETADO: % medicamentos cargados', v_counter;
  RAISE NOTICE '====================================';

  -- ============================================
  -- PASO 7: RESUMEN FINAL
  -- ============================================

  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'RESUMEN FINAL';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Centro: % (ID: %)', v_center_name, v_center_id;
  RAISE NOTICE 'Contrato: % (ID: %)', v_contract_code, v_contract_id;
  RAISE NOTICE 'Proveedor: % (ID: %)', v_supplier_name, v_supplier_id;
  RAISE NOTICE '';
  RAISE NOTICE 'Medicamentos en medication_catalog: %', (SELECT count(*) FROM medication_catalog WHERE codigo_medicamento LIKE 'MED-2531%');
  RAISE NOTICE 'Instancias en medications: %', (SELECT count(*) FROM medications WHERE center_id = v_center_id);
  RAISE NOTICE 'Lotes creados: %', (SELECT count(*) FROM batches WHERE center_id = v_center_id);
  RAISE NOTICE '';
  RAISE NOTICE '✅ Stock total disponible: % unidades', (SELECT sum(cantidad_actual) FROM batches WHERE center_id = v_center_id);
  RAISE NOTICE '====================================';

END $$;

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT
  '=== VERIFICACIÓN POST-CARGA ===' as titulo;

-- Contar por tabla
SELECT
  'medication_catalog' as tabla,
  count(*) as total_registros,
  count(*) FILTER (WHERE codigo_medicamento LIKE 'MED-2531%') as medicamentos_cargados
FROM medication_catalog;

SELECT
  'medications' as tabla,
  count(*) as total_registros,
  count(*) FILTER (WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001')) as en_centro_esperanza
FROM medications;

SELECT
  'batches' as tabla,
  count(*) as total_lotes,
  sum(cantidad_actual) as stock_total,
  count(*) FILTER (WHERE estado = 'disponible') as lotes_disponibles
FROM batches
WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001');

-- Mostrar primeros 10 medicamentos cargados
SELECT
  mc.codigo_medicamento,
  mc.nombre_generico,
  mc.categoria,
  m.id as medication_id,
  b.numero_lote,
  b.cantidad_actual as stock,
  b.fecha_caducidad
FROM medication_catalog mc
JOIN medications m ON m.catalog_id = mc.id
JOIN batches b ON b.medication_id = m.id
WHERE mc.codigo_medicamento LIKE 'MED-2531%'
  AND m.center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001')
ORDER BY mc.codigo_medicamento
LIMIT 10;
