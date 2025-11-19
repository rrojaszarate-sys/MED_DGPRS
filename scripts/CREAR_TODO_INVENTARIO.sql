-- ================================================
-- CREAR TABLAS DE INVENTARIO + DATOS DE PRUEBA
-- Sistema: SIGIMED v2.0
-- ================================================
-- EJECUTAR EN SUPABASE SQL EDITOR
-- ================================================

BEGIN;

-- ================================================
-- 1. CREAR TABLAS SI NO EXISTEN
-- ================================================

-- Catálogo de Medicamentos
CREATE TABLE IF NOT EXISTS medication_catalog (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_medicamento TEXT UNIQUE NOT NULL,
  nombre_generico TEXT NOT NULL,
  nombre_comercial TEXT,
  principio_activo TEXT,
  forma_farmaceutica TEXT,
  via_administracion TEXT,
  concentracion TEXT,
  unidad_medida TEXT,
  categoria TEXT,
  requiere_receta BOOLEAN DEFAULT false,
  controlado BOOLEAN DEFAULT false,
  temperatura_almacenamiento TEXT,
  observaciones TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_medication_catalog_codigo ON medication_catalog(codigo_medicamento);
CREATE INDEX IF NOT EXISTS idx_medication_catalog_nombre ON medication_catalog(nombre_generico);

-- Medicamentos (inventario por centro)
CREATE TABLE IF NOT EXISTS medications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id UUID REFERENCES medication_catalog(id),
  center_id UUID REFERENCES health_centers(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  unidad_medida TEXT DEFAULT 'unidad',
  categoria TEXT,
  requiere_refrigeracion BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(catalog_id, center_id)
);

CREATE INDEX IF NOT EXISTS idx_medications_catalog ON medications(catalog_id);
CREATE INDEX IF NOT EXISTS idx_medications_center ON medications(center_id);
CREATE INDEX IF NOT EXISTS idx_medications_nombre ON medications(nombre);

-- ================================================
-- 2. INSERTAR CATÁLOGO DE MEDICAMENTOS
-- ================================================

INSERT INTO medication_catalog (
  id, codigo_medicamento, nombre_generico, nombre_comercial,
  principio_activo, forma_farmaceutica, via_administracion,
  concentracion, unidad_medida, categoria,
  requiere_receta, controlado, temperatura_almacenamiento,
  observaciones, is_active
) VALUES
  (
    '40000000-0000-0000-0000-000000000001',
    'PAR-500-TAB',
    'PARACETAMOL',
    'Tempra',
    'Paracetamol',
    'Tableta',
    'Oral',
    '500mg',
    'Tableta',
    'Analgésicos',
    false,
    false,
    '15-25°C',
    'Analgésico y antipirético',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000002',
    'IBU-400-TAB',
    'IBUPROFENO',
    'Advil',
    'Ibuprofeno',
    'Tableta',
    'Oral',
    '400mg',
    'Tableta',
    'Antiinflamatorios',
    false,
    false,
    '15-25°C',
    'AINE - Antiinflamatorio no esteroideo',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000003',
    'AMO-500-CAP',
    'AMOXICILINA',
    'Amoxil',
    'Amoxicilina',
    'Cápsula',
    'Oral',
    '500mg',
    'Cápsula',
    'Antibióticos',
    true,
    false,
    '15-25°C',
    'Antibiótico penicilina',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000004',
    'LOS-50-TAB',
    'LOSARTAN',
    'Cozaar',
    'Losartan',
    'Tableta',
    'Oral',
    '50mg',
    'Tableta',
    'Antihipertensivos',
    true,
    false,
    '15-25°C',
    'ARA II - Antagonista de receptores de angiotensina',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000005',
    'MET-850-TAB',
    'METFORMINA',
    'Glucophage',
    'Metformina',
    'Tableta',
    'Oral',
    '850mg',
    'Tableta',
    'Antidiabéticos',
    true,
    false,
    '15-25°C',
    'Antidiabético oral - Biguanida',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000006',
    'CLA-500-TAB',
    'CLARITROMICINA',
    'Klaricid',
    'Claritromicina',
    'Tableta',
    'Oral',
    '500mg',
    'Tableta',
    'Antibióticos',
    true,
    false,
    '15-25°C',
    'Antibiótico macrólido',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000007',
    'ATO-20-TAB',
    'ATORVASTATINA',
    'Lipitor',
    'Atorvastatina',
    'Tableta',
    'Oral',
    '20mg',
    'Tableta',
    'Hipolipemiantes',
    true,
    false,
    '15-25°C',
    'Estatina - Reductor de colesterol',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000008',
    'OME-20-CAP',
    'OMEPRAZOL',
    'Prilosec',
    'Omeprazol',
    'Cápsula',
    'Oral',
    '20mg',
    'Cápsula',
    'Antiulcerosos',
    false,
    false,
    '15-25°C',
    'Inhibidor de bomba de protones',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000009',
    'ASA-100-TAB',
    'ÁCIDO ACETILSALICÍLICO',
    'Aspirina',
    'Ácido Acetilsalicílico',
    'Tableta',
    'Oral',
    '100mg',
    'Tableta',
    'Antiagregantes',
    false,
    false,
    '15-25°C',
    'Antiagregante plaquetario',
    true
  ),
  (
    '40000000-0000-0000-0000-000000000010',
    'CAP-25-TAB',
    'CAPTOPRIL',
    'Capoten',
    'Captopril',
    'Tableta',
    'Oral',
    '25mg',
    'Tableta',
    'Antihipertensivos',
    true,
    false,
    '15-25°C',
    'IECA - Inhibidor de enzima convertidora',
    true
  )
ON CONFLICT (id) DO UPDATE SET
  nombre_generico = EXCLUDED.nombre_generico,
  is_active = true;

-- ================================================
-- 3. OBTENER IDs DE CENTROS
-- ================================================

DO $$
DECLARE
  v_center_hgz1 UUID := '10000000-0000-0000-0000-000000000001';
  v_center_cmf23 UUID := '10000000-0000-0000-0000-000000000002';
  v_supplier_id UUID := '20000000-0000-0000-0000-000000000001';
  v_med_id UUID;
BEGIN

  -- ================================================
  -- 4. CREAR MEDICATIONS PARA HGZ1
  -- ================================================

  -- Paracetamol en HGZ1
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    v_center_hgz1,
    'PARACETAMOL 500mg TABLETA',
    'Analgésicos',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- Ibuprofeno en HGZ1
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000002',
    '40000000-0000-0000-0000-000000000002',
    v_center_hgz1,
    'IBUPROFENO 400mg TABLETA',
    'Antiinflamatorios',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- Amoxicilina en HGZ1
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000003',
    '40000000-0000-0000-0000-000000000003',
    v_center_hgz1,
    'AMOXICILINA 500mg CÁPSULA',
    'Antibióticos',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- Losartan en HGZ1
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000004',
    '40000000-0000-0000-0000-000000000004',
    v_center_hgz1,
    'LOSARTAN 50mg TABLETA',
    'Antihipertensivos',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- Metformina en HGZ1
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000005',
    '40000000-0000-0000-0000-000000000005',
    v_center_hgz1,
    'METFORMINA 850mg TABLETA',
    'Antidiabéticos',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- ================================================
  -- 5. CREAR MEDICATIONS PARA CMF23
  -- ================================================

  -- Paracetamol en CMF23
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000006',
    '40000000-0000-0000-0000-000000000001',
    v_center_cmf23,
    'PARACETAMOL 500mg TABLETA',
    'Analgésicos',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- Ibuprofeno en CMF23
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000007',
    '40000000-0000-0000-0000-000000000002',
    v_center_cmf23,
    'IBUPROFENO 400mg TABLETA',
    'Antiinflamatorios',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  -- Omeprazol en CMF23
  INSERT INTO medications (id, catalog_id, center_id, nombre, categoria, is_active)
  VALUES (
    '41000000-0000-0000-0000-000000000008',
    '40000000-0000-0000-0000-000000000008',
    v_center_cmf23,
    'OMEPRAZOL 20mg CÁPSULA',
    'Antiulcerosos',
    true
  )
  ON CONFLICT (catalog_id, center_id) DO UPDATE SET is_active = true;

  RAISE NOTICE '✅ Medicamentos creados';

  -- ================================================
  -- 6. CREAR LOTES DE INVENTARIO
  -- ================================================

  -- Lote 1: Paracetamol HGZ1
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000001',
    v_center_hgz1,
    v_supplier_id,
    'PARA-2025-001',
    5000, 4500,
    '2024-11-01', '2026-11-01', '2025-01-15',
    'Anaquel A1', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 2: Ibuprofeno HGZ1
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000002',
    v_center_hgz1,
    v_supplier_id,
    'IBU-2025-001',
    3000, 2800,
    '2024-10-15', '2026-10-15', '2025-01-10',
    'Anaquel A2', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 3: Amoxicilina HGZ1
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000003',
    v_center_hgz1,
    v_supplier_id,
    'AMO-2025-001',
    2000, 1850,
    '2024-12-01', '2026-12-01', '2025-02-01',
    'Anaquel B1', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 4: Losartan HGZ1
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000004',
    v_center_hgz1,
    v_supplier_id,
    'LOS-2025-001',
    2500, 2300,
    '2024-11-20', '2026-11-20', '2025-01-20',
    'Anaquel B2', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 5: Metformina HGZ1
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000005',
    v_center_hgz1,
    v_supplier_id,
    'MET-2025-001',
    3500, 3200,
    '2024-11-10', '2026-11-10', '2025-01-25',
    'Anaquel C1', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 6: Paracetamol CMF23
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000006',
    v_center_cmf23,
    v_supplier_id,
    'PARA-2025-002',
    2000, 1800,
    '2024-11-05', '2026-11-05', '2025-02-10',
    'Farmacia Principal', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  -- Lote 7: Ibuprofeno CMF23
  INSERT INTO batches (
    medication_id, center_id, supplier_id,
    numero_lote, cantidad_inicial, cantidad_actual,
    fecha_fabricacion, fecha_caducidad, fecha_ingreso,
    ubicacion_fisica, estado
  ) VALUES (
    '41000000-0000-0000-0000-000000000007',
    v_center_cmf23,
    v_supplier_id,
    'IBU-2025-002',
    1500, 1350,
    '2024-10-20', '2026-10-20', '2025-02-05',
    'Farmacia Principal', 'disponible'
  )
  ON CONFLICT (medication_id, numero_lote, center_id)
  DO UPDATE SET cantidad_actual = EXCLUDED.cantidad_actual;

  RAISE NOTICE '✅ Lotes creados';

END $$;

COMMIT;

-- ================================================
-- 7. VERIFICACIÓN
-- ================================================
SELECT '=== RESUMEN FINAL ===' as seccion;

SELECT
  'medication_catalog' as tabla,
  COUNT(*) as total
FROM medication_catalog

UNION ALL

SELECT
  'medications (HGZ1)' as tabla,
  COUNT(*) as total
FROM medications
WHERE center_id = '10000000-0000-0000-0000-000000000001'

UNION ALL

SELECT
  'medications (CMF23)' as tabla,
  COUNT(*) as total
FROM medications
WHERE center_id = '10000000-0000-0000-0000-000000000002'

UNION ALL

SELECT
  'batches' as tabla,
  COUNT(*) as total
FROM batches;

SELECT '✅ INSTALACIÓN COMPLETA' as resultado;
