-- ============================================
-- SIGIMED v2.0 - SCRIPT DEFINITIVO COMPLETO
-- ============================================
-- EJECUTAR TODO EN SUPABASE SQL EDITOR
-- Este script crea TODAS las tablas faltantes
-- ============================================

-- ============================================
-- PASO 1: TABLAS FALTANTES
-- ============================================

-- Tabla: alertas_medicamentos (FALTANTE)
CREATE TABLE IF NOT EXISTS alertas_medicamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicamento_id UUID REFERENCES medications(id) ON DELETE CASCADE,
    centro_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
    nivel_alerta TEXT NOT NULL CHECK (nivel_alerta IN ('critico', 'urgente', 'preventivo')),
    dias_restantes INTEGER NOT NULL,
    visto BOOLEAN DEFAULT false,
    resuelta BOOLEAN DEFAULT false,
    visto_por UUID,
    visto_en TIMESTAMPTZ,
    resuelta_por UUID,
    resuelta_en TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alertas_centro ON alertas_medicamentos(centro_id);
CREATE INDEX IF NOT EXISTS idx_alertas_nivel ON alertas_medicamentos(nivel_alerta);
CREATE INDEX IF NOT EXISTS idx_alertas_resuelta ON alertas_medicamentos(resuelta);
CREATE INDEX IF NOT EXISTS idx_alertas_medicamento ON alertas_medicamentos(medicamento_id);

-- Tabla: medication_catalog (FALTANTE - CRÍTICA)
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
CREATE INDEX IF NOT EXISTS idx_medication_catalog_active ON medication_catalog(is_active);

-- Tabla: contracts (FALTANTE)
CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo_contrato TEXT UNIQUE NOT NULL,
    supplier_id UUID REFERENCES suppliers(id),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    monto_total DECIMAL(15,2),
    estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'activo', 'vencido', 'cancelado')),
    pdf_url TEXT,
    firmado_por UUID,
    fecha_firma TIMESTAMPTZ,
    observaciones TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contracts_supplier ON contracts(supplier_id);
CREATE INDEX IF NOT EXISTS idx_contracts_estado ON contracts(estado);

-- Tabla: contract_items (FALTANTE)
CREATE TABLE IF NOT EXISTS contract_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
    medication_catalog_id UUID REFERENCES medication_catalog(id),
    cantidad_comprometida INTEGER NOT NULL,
    precio_unitario DECIMAL(15,2),
    center_destino_id UUID REFERENCES health_centers(id),
    fecha_estimada_entrega DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_items_contract ON contract_items(contract_id);

-- ============================================
-- PASO 2: FUNCIÓN generar_alertas_caducidad (FALTANTE)
-- ============================================

CREATE OR REPLACE FUNCTION generar_alertas_caducidad()
RETURNS void AS $$
BEGIN
    -- Eliminar alertas antiguas resueltas
    DELETE FROM alertas_medicamentos WHERE resuelta = true AND created_at < NOW() - INTERVAL '30 days';

    -- Insertar nuevas alertas basadas en lotes próximos a vencer
    INSERT INTO alertas_medicamentos (medicamento_id, centro_id, nivel_alerta, dias_restantes)
    SELECT DISTINCT
        b.medication_id,
        b.center_id,
        CASE
            WHEN (b.fecha_caducidad - CURRENT_DATE) <= 7 THEN 'critico'
            WHEN (b.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'urgente'
            ELSE 'preventivo'
        END,
        (b.fecha_caducidad - CURRENT_DATE)::INTEGER
    FROM batches b
    WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '90 days')
      AND b.cantidad_actual > 0
      AND b.estado = 'disponible'
      AND NOT EXISTS (
          SELECT 1 FROM alertas_medicamentos a
          WHERE a.medicamento_id = b.medication_id
            AND a.centro_id = b.center_id
            AND a.resuelta = false
      );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 3: HABILITAR RLS EN TODAS LAS TABLAS
-- ============================================

-- Habilitar RLS
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE alertas_medicamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contract_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_movements ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 4: CREAR POLÍTICAS RLS
-- ============================================

-- Eliminar políticas existentes (si las hay)
DROP POLICY IF EXISTS "medication_catalog_select" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_select_anon" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete" ON medication_catalog;

DROP POLICY IF EXISTS "alertas_select" ON alertas_medicamentos;
DROP POLICY IF EXISTS "contracts_select" ON contracts;
DROP POLICY IF EXISTS "contract_items_select" ON contract_items;
DROP POLICY IF EXISTS "health_centers_select" ON health_centers;
DROP POLICY IF EXISTS "suppliers_select" ON suppliers;
DROP POLICY IF EXISTS "medications_select" ON medications;
DROP POLICY IF EXISTS "batches_select" ON batches;
DROP POLICY IF EXISTS "batch_movements_select" ON batch_movements;

-- Políticas de LECTURA para usuarios autenticados (TODAS las tablas)
CREATE POLICY "medication_catalog_select" ON medication_catalog FOR SELECT TO authenticated USING (true);
CREATE POLICY "medication_catalog_select_anon" ON medication_catalog FOR SELECT TO anon USING (is_active = true);
CREATE POLICY "alertas_select" ON alertas_medicamentos FOR SELECT TO authenticated USING (true);
CREATE POLICY "contracts_select" ON contracts FOR SELECT TO authenticated USING (true);
CREATE POLICY "contract_items_select" ON contract_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "health_centers_select" ON health_centers FOR SELECT TO authenticated USING (true);
CREATE POLICY "suppliers_select" ON suppliers FOR SELECT TO authenticated USING (true);
CREATE POLICY "medications_select" ON medications FOR SELECT TO authenticated USING (true);
CREATE POLICY "batches_select" ON batches FOR SELECT TO authenticated USING (true);
CREATE POLICY "batch_movements_select" ON batch_movements FOR SELECT TO authenticated USING (true);

-- Políticas de ESCRITURA (INSERT/UPDATE/DELETE)
CREATE POLICY "medication_catalog_insert" ON medication_catalog FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "medication_catalog_update" ON medication_catalog FOR UPDATE TO authenticated USING (true);
CREATE POLICY "medication_catalog_delete" ON medication_catalog FOR DELETE TO authenticated USING (true);

CREATE POLICY "alertas_insert" ON alertas_medicamentos FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "alertas_update" ON alertas_medicamentos FOR UPDATE TO authenticated USING (true);

CREATE POLICY "contracts_insert" ON contracts FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "contracts_update" ON contracts FOR UPDATE TO authenticated USING (true);

CREATE POLICY "contract_items_insert" ON contract_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "contract_items_update" ON contract_items FOR UPDATE TO authenticated USING (true);

CREATE POLICY "health_centers_insert" ON health_centers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "health_centers_update" ON health_centers FOR UPDATE TO authenticated USING (true);

CREATE POLICY "suppliers_insert" ON suppliers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "suppliers_update" ON suppliers FOR UPDATE TO authenticated USING (true);

CREATE POLICY "medications_insert" ON medications FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "medications_update" ON medications FOR UPDATE TO authenticated USING (true);

CREATE POLICY "batches_insert" ON batches FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "batches_update" ON batches FOR UPDATE TO authenticated USING (true);

CREATE POLICY "batch_movements_insert" ON batch_movements FOR INSERT TO authenticated WITH CHECK (true);

-- ============================================
-- PASO 5: INSERTAR DATOS DE PRUEBA
-- ============================================

-- Medicamentos en catálogo
INSERT INTO medication_catalog (codigo_medicamento, nombre_generico, nombre_comercial, principio_activo, forma_farmaceutica, via_administracion, concentracion, unidad_medida, categoria, requiere_receta, controlado, temperatura_almacenamiento, observaciones, is_active)
VALUES
    ('MED-PAR-500', 'Paracetamol', 'Tempra', 'Paracetamol', 'Tableta', 'Oral', '500mg', 'tableta', 'Analgésico', false, false, '15-25°C', 'Analgésico y antipirético', true),
    ('MED-AMO-500', 'Amoxicilina', 'Amoxil', 'Amoxicilina trihidratada', 'Cápsula', 'Oral', '500mg', 'cápsula', 'Antibiótico', true, false, '15-25°C', 'Antibiótico de amplio espectro', true),
    ('MED-IBU-400', 'Ibuprofeno', 'Advil', 'Ibuprofeno', 'Tableta', 'Oral', '400mg', 'tableta', 'Antiinflamatorio', false, false, '15-25°C', 'AINE', true),
    ('MED-OME-20', 'Omeprazol', 'Losec', 'Omeprazol', 'Cápsula', 'Oral', '20mg', 'cápsula', 'Gastroenterología', false, false, '15-25°C', 'Inhibidor bomba de protones', true),
    ('MED-MET-850', 'Metformina', 'Glucophage', 'Metformina clorhidrato', 'Tableta', 'Oral', '850mg', 'tableta', 'Antidiabético', true, false, '15-25°C', 'Antidiabético oral', true),
    ('MED-LOS-50', 'Losartán', 'Cozaar', 'Losartán potásico', 'Tableta', 'Oral', '50mg', 'tableta', 'Antihipertensivo', true, false, '15-25°C', 'ARA II', true),
    ('MED-ATO-20', 'Atorvastatina', 'Lipitor', 'Atorvastatina cálcica', 'Tableta', 'Oral', '20mg', 'tableta', 'Hipolipemiante', true, false, '15-25°C', 'Estatina', true),
    ('MED-ASP-100', 'Aspirina', 'Aspirina Protect', 'Ácido acetilsalicílico', 'Tableta', 'Oral', '100mg', 'tableta', 'Antiagregante', false, false, '15-25°C', 'Antiagregante plaquetario', true),
    ('MED-DIC-50', 'Diclofenaco', 'Voltaren', 'Diclofenaco sódico', 'Tableta', 'Oral', '50mg', 'tableta', 'Antiinflamatorio', false, false, '15-25°C', 'AINE potente', true),
    ('MED-CIP-500', 'Ciprofloxacino', 'Cipro', 'Ciprofloxacino', 'Tableta', 'Oral', '500mg', 'tableta', 'Antibiótico', true, false, '15-25°C', 'Fluoroquinolona', true),
    ('MED-AZI-500', 'Azitromicina', 'Zithromax', 'Azitromicina', 'Tableta', 'Oral', '500mg', 'tableta', 'Antibiótico', true, false, '15-25°C', 'Macrólido', true),
    ('MED-CLO-05', 'Clonazepam', 'Rivotril', 'Clonazepam', 'Tableta', 'Oral', '0.5mg', 'tableta', 'Ansiolítico', true, true, '15-25°C', 'Controlado', true),
    ('MED-TRA-50', 'Tramadol', 'Tramal', 'Tramadol clorhidrato', 'Cápsula', 'Oral', '50mg', 'cápsula', 'Analgésico', true, true, '15-25°C', 'Opioide - Controlado', true),
    ('MED-INS-100', 'Insulina NPH', 'Humulin N', 'Insulina isofánica', 'Solución inyectable', 'Subcutánea', '100 UI/mL', 'frasco 10mL', 'Antidiabético', true, false, '2-8°C', 'Refrigerar', true),
    ('MED-SAL-100', 'Salbutamol', 'Ventolin', 'Salbutamol sulfato', 'Aerosol', 'Inhalatoria', '100mcg/dosis', 'inhalador', 'Broncodilatador', false, false, '15-25°C', 'Beta-2 agonista', true),
    ('MED-PRE-5', 'Prednisona', 'Meticorten', 'Prednisona', 'Tableta', 'Oral', '5mg', 'tableta', 'Corticosteroide', true, false, '15-25°C', 'Glucocorticoide', true),
    ('MED-RAN-150', 'Ranitidina', 'Zantac', 'Ranitidina clorhidrato', 'Tableta', 'Oral', '150mg', 'tableta', 'Antiulceroso', false, false, '15-25°C', 'Antagonista H2', true),
    ('MED-CLO-75', 'Clopidogrel', 'Plavix', 'Clopidogrel bisulfato', 'Tableta', 'Oral', '75mg', 'tableta', 'Antiagregante', true, false, '15-25°C', 'Antiagregante', true),
    ('MED-FUR-40', 'Furosemida', 'Lasix', 'Furosemida', 'Tableta', 'Oral', '40mg', 'tableta', 'Diurético', true, false, '15-25°C', 'Diurético de asa', true),
    ('MED-AML-5', 'Amlodipino', 'Norvasc', 'Amlodipino besilato', 'Tableta', 'Oral', '5mg', 'tableta', 'Antihipertensivo', true, false, '15-25°C', 'Bloqueador Ca', true)
ON CONFLICT (codigo_medicamento) DO UPDATE SET
    nombre_generico = EXCLUDED.nombre_generico,
    nombre_comercial = EXCLUDED.nombre_comercial,
    is_active = true;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

DO $$
DECLARE
    v_catalog_count INTEGER;
    v_tables_count INTEGER;
    v_policies_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_catalog_count FROM medication_catalog;
    SELECT COUNT(*) INTO v_tables_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name IN (
        'medication_catalog', 'alertas_medicamentos', 'contracts', 'contract_items',
        'health_centers', 'suppliers', 'medications', 'batches', 'batch_movements'
    );
    SELECT COUNT(*) INTO v_policies_count FROM pg_policies WHERE schemaname = 'public';

    RAISE NOTICE '';
    RAISE NOTICE '╔══════════════════════════════════════════════════╗';
    RAISE NOTICE '║     ✅ INSTALACIÓN COMPLETADA EXITOSAMENTE       ║';
    RAISE NOTICE '╠══════════════════════════════════════════════════╣';
    RAISE NOTICE '║  Tablas creadas:        %                        ║', v_tables_count;
    RAISE NOTICE '║  Medicamentos catálogo: %                       ║', v_catalog_count;
    RAISE NOTICE '║  Políticas RLS:         %                       ║', v_policies_count;
    RAISE NOTICE '╠══════════════════════════════════════════════════╣';
    RAISE NOTICE '║  RECARGA LA PÁGINA DE TU APLICACIÓN              ║';
    RAISE NOTICE '╚══════════════════════════════════════════════════╝';
END $$;

-- Mostrar medicamentos creados
SELECT codigo_medicamento, nombre_generico, categoria, is_active
FROM medication_catalog
ORDER BY nombre_generico
LIMIT 10;
