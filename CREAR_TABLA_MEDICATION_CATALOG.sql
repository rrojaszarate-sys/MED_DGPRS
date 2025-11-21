-- ============================================
-- CREAR TABLA medication_catalog
-- EJECUTAR EN SUPABASE SQL EDITOR
-- ============================================
-- LA TABLA NO EXISTE - Este script la crea
-- ============================================

-- PASO 1: Crear la tabla
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

-- PASO 2: Crear índices
CREATE INDEX IF NOT EXISTS idx_medication_catalog_codigo ON medication_catalog(codigo_medicamento);
CREATE INDEX IF NOT EXISTS idx_medication_catalog_nombre ON medication_catalog(nombre_generico);
CREATE INDEX IF NOT EXISTS idx_medication_catalog_active ON medication_catalog(is_active);

-- PASO 3: Habilitar RLS
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- PASO 4: Crear políticas RLS
CREATE POLICY "medication_catalog_select_authenticated"
ON medication_catalog FOR SELECT TO authenticated USING (true);

CREATE POLICY "medication_catalog_select_anon"
ON medication_catalog FOR SELECT TO anon USING (is_active = true);

CREATE POLICY "medication_catalog_insert_admin"
ON medication_catalog FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center'))
);

CREATE POLICY "medication_catalog_update_admin"
ON medication_catalog FOR UPDATE TO authenticated
USING (
    EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center'))
);

CREATE POLICY "medication_catalog_delete_superadmin"
ON medication_catalog FOR DELETE TO authenticated
USING (
    EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid() AND role = 'super_admin')
);

-- PASO 5: Insertar datos de prueba (medicamentos básicos)
INSERT INTO medication_catalog (codigo_medicamento, nombre_generico, nombre_comercial, principio_activo, forma_farmaceutica, via_administracion, concentracion, unidad_medida, categoria, requiere_receta, controlado, temperatura_almacenamiento, observaciones, is_active)
VALUES
    ('MED-PAR-500', 'Paracetamol', 'Tempra', 'Paracetamol', 'Tableta', 'Oral', '500mg', 'tableta', 'Analgésico', false, false, '15-25°C', 'Analgésico y antipirético de uso común', true),
    ('MED-AMO-500', 'Amoxicilina', 'Amoxil', 'Amoxicilina trihidratada', 'Cápsula', 'Oral', '500mg', 'cápsula', 'Antibiótico', true, false, '15-25°C', 'Antibiótico de amplio espectro', true),
    ('MED-IBU-400', 'Ibuprofeno', 'Advil', 'Ibuprofeno', 'Tableta', 'Oral', '400mg', 'tableta', 'Antiinflamatorio', false, false, '15-25°C', 'AINE - Antiinflamatorio no esteroideo', true),
    ('MED-OME-20', 'Omeprazol', 'Losec', 'Omeprazol', 'Cápsula', 'Oral', '20mg', 'cápsula', 'Gastroenterología', false, false, '15-25°C', 'Inhibidor de la bomba de protones', true),
    ('MED-MET-850', 'Metformina', 'Glucophage', 'Metformina clorhidrato', 'Tableta', 'Oral', '850mg', 'tableta', 'Antidiabético', true, false, '15-25°C', 'Antidiabético oral de primera línea', true),
    ('MED-LOS-50', 'Losartán', 'Cozaar', 'Losartán potásico', 'Tableta', 'Oral', '50mg', 'tableta', 'Antihipertensivo', true, false, '15-25°C', 'Antagonista de receptores de angiotensina II', true),
    ('MED-ATO-20', 'Atorvastatina', 'Lipitor', 'Atorvastatina cálcica', 'Tableta', 'Oral', '20mg', 'tableta', 'Hipolipemiante', true, false, '15-25°C', 'Inhibidor de HMG-CoA reductasa', true),
    ('MED-ASP-100', 'Aspirina', 'Aspirina Protect', 'Ácido acetilsalicílico', 'Tableta', 'Oral', '100mg', 'tableta', 'Antiagregante', false, false, '15-25°C', 'Antiagregante plaquetario', true),
    ('MED-DIC-50', 'Diclofenaco', 'Voltaren', 'Diclofenaco sódico', 'Tableta', 'Oral', '50mg', 'tableta', 'Antiinflamatorio', false, false, '15-25°C', 'AINE potente', true),
    ('MED-CIP-500', 'Ciprofloxacino', 'Cipro', 'Ciprofloxacino', 'Tableta', 'Oral', '500mg', 'tableta', 'Antibiótico', true, false, '15-25°C', 'Fluoroquinolona de amplio espectro', true),
    ('MED-AZI-500', 'Azitromicina', 'Zithromax', 'Azitromicina dihidratada', 'Tableta', 'Oral', '500mg', 'tableta', 'Antibiótico', true, false, '15-25°C', 'Macrólido de acción prolongada', true),
    ('MED-CLO-500', 'Clonazepam', 'Rivotril', 'Clonazepam', 'Tableta', 'Oral', '0.5mg', 'tableta', 'Ansiolítico', true, true, '15-25°C', 'Benzodiazepina - Medicamento controlado', true),
    ('MED-TRA-50', 'Tramadol', 'Tramal', 'Tramadol clorhidrato', 'Cápsula', 'Oral', '50mg', 'cápsula', 'Analgésico', true, true, '15-25°C', 'Opioide sintético - Medicamento controlado', true),
    ('MED-INS-100', 'Insulina NPH', 'Humulin N', 'Insulina isofánica humana', 'Solución inyectable', 'Subcutánea', '100 UI/mL', 'frasco 10mL', 'Antidiabético', true, false, '2-8°C', 'Requiere refrigeración', true),
    ('MED-SAL-100', 'Salbutamol', 'Ventolin', 'Salbutamol sulfato', 'Aerosol', 'Inhalatoria', '100mcg/dosis', 'inhalador', 'Broncodilatador', false, false, '15-25°C', 'Beta-2 agonista de acción corta', true),
    ('MED-PRE-5', 'Prednisona', 'Meticorten', 'Prednisona', 'Tableta', 'Oral', '5mg', 'tableta', 'Corticosteroide', true, false, '15-25°C', 'Glucocorticoide antiinflamatorio', true),
    ('MED-RAI-20', 'Ranitidina', 'Zantac', 'Ranitidina clorhidrato', 'Tableta', 'Oral', '150mg', 'tableta', 'Antiulceroso', false, false, '15-25°C', 'Antagonista H2', true),
    ('MED-CLO-250', 'Clopidogrel', 'Plavix', 'Clopidogrel bisulfato', 'Tableta', 'Oral', '75mg', 'tableta', 'Antiagregante', true, false, '15-25°C', 'Antiagregante plaquetario', true),
    ('MED-FUR-40', 'Furosemida', 'Lasix', 'Furosemida', 'Tableta', 'Oral', '40mg', 'tableta', 'Diurético', true, false, '15-25°C', 'Diurético de asa', true),
    ('MED-AML-5', 'Amlodipino', 'Norvasc', 'Amlodipino besilato', 'Tableta', 'Oral', '5mg', 'tableta', 'Antihipertensivo', true, false, '15-25°C', 'Bloqueador de canales de calcio', true)
ON CONFLICT (codigo_medicamento) DO NOTHING;

-- PASO 6: Verificar resultado
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM medication_catalog;
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TABLA CREADA EXITOSAMENTE';
    RAISE NOTICE 'Registros insertados: %', v_count;
    RAISE NOTICE '========================================';
END $$;

-- Mostrar los medicamentos creados
SELECT codigo_medicamento, nombre_generico, categoria, is_active
FROM medication_catalog
ORDER BY nombre_generico;
