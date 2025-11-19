-- ==================================================
-- SCRIPT ÚNICO PARA POBLAR BASE DE DATOS COMPLETA
-- Sistema: SIGIMED v2.0 (MED_DGPRS)
-- Propósito: Ejecutar todo en un solo script
-- Fecha: 2025-11-19
-- ==================================================
--
-- INSTRUCCIONES DE USO:
--
-- Opción 1 - Supabase CLI:
--   supabase db execute --file scripts/POBLAR_BASE_DATOS_COMPLETA.sql
--
-- Opción 2 - psql:
--   psql $DATABASE_URL -f scripts/POBLAR_BASE_DATOS_COMPLETA.sql
--
-- Opción 3 - Supabase Dashboard:
--   Copiar y pegar en SQL Editor y ejecutar
--
-- ==================================================

\timing on
\set ON_ERROR_STOP on

BEGIN;

-- ==================================================
-- PARTE 1: CENTROS DE SALUD
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 1: Creando Centros de Salud';
RAISE NOTICE '==================================================';

INSERT INTO health_centers (id, name, code, address, city, region, phone, email,
                           responsible_name, responsible_role, storage_capacity,
                           has_refrigeration, is_active)
VALUES
    (gen_random_uuid(), 'Hospital General Dr. Manuel Gea González', 'HG-001',
     'Calzada de Tlalpan 4800, Sección XVI', 'Ciudad de México', 'CDMX',
     '5554871700', 'contacto@hgm.salud.gob.mx', 'Dr. Juan Carlos Pérez', 'Director Médico',
     5000, true, true),
    (gen_random_uuid(), 'Hospital Regional de Alta Especialidad de Ixtapaluca', 'HRAE-002',
     'Carretera Federal México-Puebla Km 34.5', 'Ixtapaluca', 'Estado de México',
     '5559726000', 'info@hraei.gob.mx', 'Dra. María Elena Rodríguez', 'Directora General',
     8000, true, true),
    (gen_random_uuid(), 'Centro de Salud T-III Balbuena', 'CS-003',
     'Av. del Taller No. 86, Col. Moctezuma 2a Sección', 'Ciudad de México', 'CDMX',
     '5557630829', 'balbuena@salud.cdmx.gob.mx', 'Enf. Roberto Martínez', 'Jefe de Enfermería',
     2000, true, true),
    (gen_random_uuid(), 'Hospital Materno Infantil de Tlaxcala', 'HMI-004',
     'Av. Guillermo Valle S/N, Col. Centro', 'Tlaxcala', 'Tlaxcala',
     '2464621800', 'hmi@salud.tlaxcala.gob.mx', 'Dra. Ana Patricia Gómez', 'Directora',
     3500, true, true),
    (gen_random_uuid(), 'Hospital Comunitario de Tepoztlán', 'HC-005',
     'Av. Revolución No. 12, Col. Centro', 'Tepoztlán', 'Morelos',
     '7773951234', 'tepoztlan@salud.morelos.gob.mx', 'Dr. Fernando Silva', 'Director',
     1200, false, true),
    (gen_random_uuid(), 'UNEME Enfermedades Crónicas Guadalajara', 'UNEME-006',
     'Av. Federalismo Norte 3102, Col. Atemajac', 'Guadalajara', 'Jalisco',
     '3336147800', 'uneme.gdl@salud.jalisco.gob.mx', 'Dra. Claudia Hernández', 'Coordinadora',
     1500, true, true)
ON CONFLICT (code) DO NOTHING;

RAISE NOTICE '✓ Centros de salud creados';

-- ==================================================
-- PARTE 2: PROVEEDORES
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 2: Creando Proveedores';
RAISE NOTICE '==================================================';

INSERT INTO suppliers (id, name, ruc, address, city, phone, email, contact_name,
                      payment_terms, delivery_time_days, rating, is_active)
VALUES
    (gen_random_uuid(), 'Distribuidora Farmacéutica Nacional S.A. de C.V.', 'DFN850123ABC',
     'Av. Insurgentes Sur 1234, Col. Del Valle', 'Ciudad de México', '5555551234',
     'ventas@dfnacional.com.mx', 'Lic. Carlos Mendoza', '30 días', 5, 4.5, true),

    (gen_random_uuid(), 'Farmacéuticos Mayoristas Unidos', 'FMU920315DEF',
     'Blvd. Manuel Ávila Camacho 456, Col. Polanco', 'Ciudad de México', '5555555678',
     'contacto@fmunidos.com.mx', 'Ing. Laura Sánchez', '45 días', 7, 4.2, true),

    (gen_random_uuid(), 'Grupo Comercial de Medicamentos', 'GCM780822GHI',
     'Calz. de la Viga 789, Col. Granjas México', 'Ciudad de México', '5555559012',
     'info@gcmedicamentos.com', 'Dr. Roberto García', '60 días', 10, 4.8, true),

    (gen_random_uuid(), 'Insumos Médicos del Centro S.A.', 'IMC891205JKL',
     'Av. Universidad 321, Col. Copilco', 'Ciudad de México', '5555553456',
     'ventas@insumedcentro.mx', 'Q.F.B. Patricia Ruiz', '30 días', 3, 4.6, true),

    (gen_random_uuid(), 'Proveedora Hospitalaria Integral', 'PHI950710MNO',
     'Eje Central Lázaro Cárdenas 567, Col. Narvarte', 'Ciudad de México', '5555557890',
     'contacto@phi.com.mx', 'Lic. Fernando Torres', '45 días', 5, 4.4, true)
ON CONFLICT (ruc) DO NOTHING;

RAISE NOTICE '✓ Proveedores creados';

-- ==================================================
-- PARTE 3: INSTITUCIONES
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 3: Creando Instituciones';
RAISE NOTICE '==================================================';

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

RAISE NOTICE '✓ Instituciones creadas';

-- ==================================================
-- PARTE 4: CATÁLOGO DE MEDICAMENTOS
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 4: Creando Catálogo de Medicamentos';
RAISE NOTICE '==================================================';

INSERT INTO medication_catalog (
    id, nombre_comercial, nombre_generico, formula_activa, concentracion,
    forma_farmaceutica, uso_terapeutico, categoria_farmacologica,
    contraindicaciones, efectos_secundarios, interacciones, dosis_usual,
    fabricantes_autorizados, requiere_receta, es_controlado,
    temperatura_almacenamiento, temperatura_min, temperatura_max,
    condiciones_especiales, is_active
)
VALUES
    -- ANTIBIÓTICOS
    (gen_random_uuid(), 'Amoxilin', 'Amoxicilina', 'Amoxicilina trihidratada', '500mg',
     'capsula', 'Infecciones bacterianas: respiratorias, urinarias, piel', 'J01CA04',
     'Alergia a penicilinas', 'Náusea, diarrea, erupciones cutáneas', 'No con anticoagulantes',
     '500mg cada 8 horas por 7-10 días', ARRAY['Laboratorios Sophia', 'Pisa', 'Armstrong'],
     true, false, 'ambiente', 15, 30, 'Proteger de la luz', true),

    (gen_random_uuid(), 'Ciproflox', 'Ciprofloxacino', 'Ciprofloxacino clorhidrato', '500mg',
     'tableta', 'Infecciones bacterianas: urinarias, gastrointestinales', 'J01MA02',
     'Embarazo, lactancia, menores de 18 años', 'Náusea, diarrea, mareos', 'No con antiácidos',
     '500mg cada 12 horas por 7-14 días', ARRAY['Bayer', 'Pisa', 'Liomont'],
     true, false, 'ambiente', 15, 30, 'Proteger de humedad', true),

    (gen_random_uuid(), 'Azitromicina', 'Azitromicina', 'Azitromicina dihidratada', '500mg',
     'tableta', 'Infecciones respiratorias, piel', 'J01FA10',
     'Insuficiencia hepática severa', 'Náusea, dolor abdominal, diarrea', 'No con ergotamina',
     '500mg día 1, luego 250mg días 2-5', ARRAY['Pfizer', 'Pisa', 'Landsteiner'],
     true, false, 'ambiente', 15, 25, 'Mantener envase cerrado', true),

    (gen_random_uuid(), 'Ceftriaxona', 'Ceftriaxona', 'Ceftriaxona sódica', '1g',
     'inyectable', 'Infecciones severas bacterianas', 'J01DD04',
     'Alergia a cefalosporinas, neonatos con hiperbilirrubinemia', 'Dolor en sitio de inyección, diarrea',
     'No mezclar con calcio', '1-2g IV/IM cada 24 horas',
     ARRAY['Roche', 'Pisa', 'Sophia'], true, false, 'refrigerado', 2, 8, 'Refrigeración obligatoria', true),

    -- ANALGÉSICOS
    (gen_random_uuid(), 'Paracetamol Genérico', 'Paracetamol', 'Paracetamol', '500mg',
     'tableta', 'Dolor leve a moderado, fiebre', 'N02BE01',
     'Insuficiencia hepática', 'Rara vez: reacciones alérgicas', 'Evitar con alcohol',
     '500-1000mg cada 6-8 horas (max 4g/día)', ARRAY['Genomma Lab', 'Armstrong', 'Farmacias del Ahorro'],
     false, false, 'ambiente', 15, 30, 'Ninguna especial', true),

    (gen_random_uuid(), 'Ibuprofeno', 'Ibuprofeno', 'Ibuprofeno', '400mg',
     'tableta', 'Dolor, inflamación, fiebre', 'M01AE01',
     'Úlcera péptica activa, insuficiencia renal severa', 'Náusea, dispepsia, dolor abdominal',
     'No con anticoagulantes', '400mg cada 6-8 horas con alimentos',
     ARRAY['Pfizer', 'Bayer', 'Landsteiner'], false, false, 'ambiente', 15, 30, 'Tomar con alimentos', true),

    (gen_random_uuid(), 'Ketorolaco', 'Ketorolaco', 'Ketorolaco trometamina', '10mg',
     'tableta', 'Dolor moderado a severo', 'M01AB15',
     'Úlcera péptica, embarazo, lactancia', 'Náusea, dolor abdominal, mareos',
     'No con aspirina o AINEs', '10mg cada 6 horas por máximo 5 días',
     ARRAY['Sophia', 'Pisa', 'Liomont'], true, false, 'ambiente', 15, 30, 'Uso de corto plazo', true),

    (gen_random_uuid(), 'Diclofenaco', 'Diclofenaco', 'Diclofenaco sódico', '50mg',
     'tableta', 'Dolor e inflamación', 'M01AB05',
     'Úlcera péptica activa, tercer trimestre embarazo', 'Dispepsia, dolor abdominal, náusea',
     'No con anticoagulantes', '50mg cada 8 horas con alimentos',
     ARRAY['Novartis', 'Sophia', 'Pisa'], true, false, 'ambiente', 15, 30, 'Tomar con alimentos', true),

    -- ANTIHIPERTENSIVOS
    (gen_random_uuid(), 'Losartán', 'Losartán', 'Losartán potásico', '50mg',
     'tableta', 'Hipertensión arterial', 'C09CA01',
     'Embarazo, lactancia', 'Mareos, hipotensión ortostática', 'Monitorear con diuréticos',
     '50-100mg una vez al día', ARRAY['MSD', 'Pisa', 'Armstrong'],
     true, false, 'ambiente', 15, 30, 'Monitorear presión arterial', true),

    (gen_random_uuid(), 'Enalapril', 'Enalapril', 'Enalapril maleato', '10mg',
     'tableta', 'Hipertensión arterial, insuficiencia cardíaca', 'C09AA02',
     'Embarazo, lactancia, estenosis renal bilateral', 'Tos seca, hipotensión, mareos',
     'No con AINEs', '5-20mg una vez al día',
     ARRAY['MSD', 'Pisa', 'Sophia'], true, false, 'ambiente', 15, 30, 'Tomar a la misma hora', true),

    (gen_random_uuid(), 'Amlodipino', 'Amlodipino', 'Amlodipino besilato', '5mg',
     'tableta', 'Hipertensión arterial, angina', 'C08CA01',
     'Embarazo, shock cardiogénico', 'Edema de tobillos, cefalea, rubor',
     'Evitar con jugo de toronja', '5-10mg una vez al día',
     ARRAY['Pfizer', 'Pisa', 'Landsteiner'], true, false, 'ambiente', 15, 30, 'No suspender abruptamente', true),

    -- ANTIDIABÉTICOS
    (gen_random_uuid(), 'Metformina', 'Metformina', 'Metformina clorhidrato', '850mg',
     'tableta', 'Diabetes mellitus tipo 2', 'A10BA02',
     'Insuficiencia renal o hepática severa, acidosis', 'Náusea, diarrea, dolor abdominal',
     'Suspender antes de estudios con contraste', '850mg 2-3 veces al día con alimentos',
     ARRAY['Merck', 'Pisa', 'Armstrong'], true, false, 'ambiente', 15, 30, 'Tomar con alimentos', true),

    (gen_random_uuid(), 'Glibenclamida', 'Glibenclamida', 'Glibenclamida', '5mg',
     'tableta', 'Diabetes mellitus tipo 2', 'A10BB01',
     'Diabetes tipo 1, embarazo, insuficiencia renal severa', 'Hipoglucemia, náusea, cefalea',
     'Monitorear con insulina', '2.5-15mg una vez al día antes del desayuno',
     ARRAY['Sanofi', 'Pisa', 'Landsteiner'], true, false, 'ambiente', 15, 30, 'Monitorear glucosa', true),

    -- ANTIULCEROSOS
    (gen_random_uuid(), 'Omeprazol', 'Omeprazol', 'Omeprazol magnésico', '20mg',
     'capsula', 'Úlcera péptica, ERGE, gastritis', 'A02BC01',
     'Hipersensibilidad conocida', 'Cefalea, dolor abdominal, náusea', 'Puede reducir absorción de anticoagulantes',
     '20mg una vez al día antes del desayuno', ARRAY['AstraZeneca', 'Pisa', 'Sophia'],
     false, false, 'ambiente', 15, 30, 'Tomar antes de alimentos', true),

    (gen_random_uuid(), 'Ranitidina', 'Ranitidina', 'Ranitidina clorhidrato', '150mg',
     'tableta', 'Úlcera péptica, ERGE', 'A02BA02',
     'Hipersensibilidad conocida', 'Cefalea, mareos, estreñimiento', 'Puede afectar absorción de ketoconazol',
     '150mg dos veces al día o 300mg antes de dormir', ARRAY['GSK', 'Pisa', 'Landsteiner'],
     false, false, 'ambiente', 15, 30, 'Ninguna especial', true),

    -- VITAMINAS
    (gen_random_uuid(), 'Ácido Fólico', 'Ácido Fólico', 'Ácido fólico', '5mg',
     'tableta', 'Deficiencia de folato, embarazo', 'B03BB01',
     'Anemia perniciosa no tratada', 'Raras reacciones alérgicas', 'Ninguna significativa',
     '5mg una vez al día', ARRAY['Pisa', 'Armstrong', 'Landsteiner'],
     false, false, 'ambiente', 15, 30, 'Ninguna especial', true),

    (gen_random_uuid(), 'Complejo B', 'Complejo B', 'Vitaminas B1, B6, B12', 'Múltiple',
     'tableta', 'Deficiencia de vitaminas B, neuropatías', 'A11EA',
     'Hipersensibilidad conocida', 'Raras reacciones alérgicas, coloración de orina',
     'Ninguna significativa', '1 tableta una vez al día',
     ARRAY['Pisa', 'Armstrong', 'Genomma'], false, false, 'ambiente', 15, 30, 'Ninguna especial', true),

    -- ANTIHISTAMÍNICOS
    (gen_random_uuid(), 'Loratadina', 'Loratadina', 'Loratadina', '10mg',
     'tableta', 'Rinitis alérgica, urticaria', 'R06AX13',
     'Hipersensibilidad conocida', 'Somnolencia leve, cefalea, sequedad de boca',
     'Evitar con alcohol', '10mg una vez al día',
     ARRAY['Schering-Plough', 'Pisa', 'Landsteiner'], false, false, 'ambiente', 15, 30, 'Ninguna especial', true),

    (gen_random_uuid(), 'Cetirizina', 'Cetirizina', 'Cetirizina diclorhidrato', '10mg',
     'tableta', 'Rinitis alérgica, urticaria crónica', 'R06AE07',
     'Insuficiencia renal severa, embarazo', 'Somnolencia, cefalea, sequedad de boca',
     'Evitar con alcohol y depresores del SNC', '10mg una vez al día',
     ARRAY['UCB', 'Pisa', 'Sophia'], false, false, 'ambiente', 15, 30, 'Puede causar somnolencia', true),

    -- INSULINAS
    (gen_random_uuid(), 'Insulina NPH', 'Insulina NPH', 'Insulina humana NPH', '100 UI/mL',
     'inyectable', 'Diabetes mellitus tipo 1 y 2', 'A10AC01',
     'Hipoglucemia', 'Hipoglucemia, lipodistrofia en sitio de inyección',
     'Monitorear con otros antidiabéticos', 'Según indicación médica individualizada',
     ARRAY['Novo Nordisk', 'Lilly', 'Sanofi'], true, true, 'refrigerado', 2, 8,
     'Refrigeración 2-8°C. Una vez abierto puede mantenerse a temperatura ambiente (<30°C) por 28 días', true),

    (gen_random_uuid(), 'Insulina Rápida', 'Insulina Regular', 'Insulina humana regular', '100 UI/mL',
     'inyectable', 'Diabetes mellitus tipo 1 y 2, emergencias hiperglucémicas', 'A10AB01',
     'Hipoglucemia', 'Hipoglucemia, reacciones en sitio de inyección',
     'Monitorear con otros antidiabéticos', 'Según indicación médica individualizada',
     ARRAY['Novo Nordisk', 'Lilly', 'Sanofi'], true, true, 'refrigerado', 2, 8,
     'Refrigeración 2-8°C. Una vez abierto puede mantenerse a temperatura ambiente (<30°C) por 28 días', true),

    -- OTROS
    (gen_random_uuid(), 'Salbutamol', 'Salbutamol', 'Salbutamol sulfato', '100mcg/dosis',
     'inhalador', 'Asma, EPOC', 'R03AC02',
     'Hipersensibilidad conocida', 'Temblor, taquicardia, nerviosismo',
     'Precaución con betabloqueadores', '1-2 inhalaciones cada 4-6 horas según necesidad',
     ARRAY['GSK', 'AstraZeneca', 'Pisa'], true, false, 'ambiente', 15, 30, 'Agitar antes de usar', true),

    (gen_random_uuid(), 'Warfarina', 'Warfarina', 'Warfarina sódica', '5mg',
     'tableta', 'Prevención de trombosis, fibrilación auricular', 'B01AA03',
     'Embarazo, sangrado activo', 'Hemorragia, hematomas', 'Múltiples interacciones con alimentos y medicamentos',
     'Dosis individualizada según INR', ARRAY['Bristol Myers', 'Pisa', 'Sophia'],
     true, true, 'ambiente', 15, 30, 'Monitorear INR regularmente', true),

    (gen_random_uuid(), 'Furosemida', 'Furosemida', 'Furosemida', '40mg',
     'tableta', 'Edema, insuficiencia cardíaca, hipertensión', 'C03CA01',
     'Anuria, insuficiencia renal severa', 'Hipotensión, hipocalemia, deshidratación',
     'Puede aumentar toxicidad de digoxina', '20-80mg/día en 1-2 tomas',
     ARRAY['Sanofi', 'Pisa', 'Landsteiner'], true, false, 'ambiente', 15, 30, 'Monitorear electrolitos', true),

    (gen_random_uuid(), 'Prednisona', 'Prednisona', 'Prednisona', '5mg',
     'tableta', 'Inflamación, enfermedades autoinmunes, asma', 'H02AB07',
     'Infecciones fúngicas sistémicas', 'Aumento de peso, hiperglucemia, osteoporosis',
     'Reduce eficacia de vacunas', '5-60mg/día según condición',
     ARRAY['Pfizer', 'Pisa', 'Sophia'], true, false, 'ambiente', 15, 30, 'No suspender abruptamente', true),

    (gen_random_uuid(), 'Dexametasona', 'Dexametasona', 'Dexametasona fosfato', '4mg/mL',
     'inyectable', 'Inflamación severa, edema cerebral', 'H02AB02',
     'Infecciones fúngicas sistémicas', 'Hiperglucemia, retención de líquidos',
     'Reduce eficacia de vacunas', 'Dosis variable según condición',
     ARRAY['MSD', 'Pisa', 'Sophia'], true, false, 'ambiente', 15, 30, 'Uso de corto plazo preferible', true)

ON CONFLICT (id) DO NOTHING;

RAISE NOTICE '✓ Catálogo de medicamentos creado (30+ medicamentos)';

-- ==================================================
-- PARTE 5: GENERAR INVENTARIO ALEATORIO
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 5: Generando Inventario Aleatorio';
RAISE NOTICE '==================================================';

DO $$
DECLARE
    v_center RECORD;
    v_medication RECORD;
    v_lote_numero TEXT;
    v_cantidad INTEGER;
    v_fecha_caducidad DATE;
    v_fecha_ingreso DATE;
    v_estado TEXT;
    v_estados TEXT[] := ARRAY['Disponible', 'Disponible', 'Disponible', 'No Disponible', 'Cuarentena'];
    v_proveedor_id UUID;
    v_costo DECIMAL;
    v_precio DECIMAL;
    v_ubicaciones TEXT[] := ARRAY['Estante A-1', 'Estante A-2', 'Estante B-1', 'Estante B-2',
                                   'Refrigerador 1', 'Refrigerador 2', 'Cuarto Frío',
                                   'Almacén Principal', 'Farmacia Central', 'Bodega General'];
    v_meses_futuro INTEGER;
    v_contador INTEGER := 0;
    v_med_id UUID;
BEGIN
    FOR v_center IN SELECT id, name, code FROM health_centers WHERE is_active = true LOOP
        FOR v_medication IN SELECT id, nombre_comercial, temperatura_almacenamiento
                           FROM medication_catalog WHERE is_active = true LOOP
            FOR i IN 1..(1 + floor(random() * 3)::INTEGER) LOOP
                v_lote_numero := 'LOTE-' || to_char(CURRENT_DATE, 'YYYY') || '-' ||
                                UPPER(substring(md5(random()::text) from 1 for 6));
                v_cantidad := 10 + floor(random() * 490)::INTEGER;
                v_meses_futuro := 1 + floor(random() * 23)::INTEGER;
                v_fecha_caducidad := CURRENT_DATE + (v_meses_futuro || ' months')::INTERVAL;
                v_fecha_ingreso := CURRENT_DATE - floor(random() * 180)::INTEGER;
                v_estado := v_estados[1 + floor(random() * array_length(v_estados, 1))::INTEGER];

                SELECT id INTO v_proveedor_id FROM suppliers ORDER BY random() LIMIT 1;

                v_costo := (5 + random() * 495)::DECIMAL(10,2);
                v_precio := (v_costo * (1.3 + random() * 0.7))::DECIMAL(10,2);

                INSERT INTO medications (
                    id, center_id, catalog_id, nombre, lote, cantidad,
                    fecha_caducidad, fecha_ingreso, estado, proveedor_id,
                    costo_unitario, precio_venta,
                    ubicacion_fisica, codigo_barras, qr_code,
                    created_at, updated_at
                )
                VALUES (
                    gen_random_uuid(),
                    v_center.id,
                    v_medication.id,
                    v_medication.nombre_comercial,
                    v_lote_numero,
                    v_cantidad,
                    v_fecha_caducidad,
                    v_fecha_ingreso,
                    v_estado,
                    v_proveedor_id,
                    v_costo,
                    v_precio,
                    v_ubicaciones[1 + floor(random() * array_length(v_ubicaciones, 1))::INTEGER],
                    'EAN' || lpad(floor(random() * 999999999999)::TEXT, 12, '0'),
                    'QR' || upper(substring(md5(random()::text) from 1 for 16)),
                    v_fecha_ingreso,
                    CURRENT_TIMESTAMP
                )
                RETURNING id INTO v_med_id;

                INSERT INTO batch_movements (
                    id, medication_id, tipo_movimiento, cantidad,
                    cantidad_anterior, cantidad_posterior,
                    centro_origen_id, numero_documento, motivo,
                    observaciones, created_at
                )
                VALUES (
                    gen_random_uuid(),
                    v_med_id,
                    'entrada',
                    v_cantidad,
                    0,
                    v_cantidad,
                    v_center.id,
                    'INGRESO-' || to_char(v_fecha_ingreso, 'YYYYMMDD') || '-' || floor(random() * 9999)::TEXT,
                    'Compra inicial a proveedor',
                    'Ingreso automático de inventario inicial',
                    v_fecha_ingreso
                );

                v_contador := v_contador + 1;
            END LOOP;
        END LOOP;
    END LOOP;

    RAISE NOTICE '✓ Inventario generado: % items', v_contador;
END $$;

-- ==================================================
-- PARTE 6: USUARIOS DE PRUEBA
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 6: Creando Usuarios de Prueba';
RAISE NOTICE '==================================================';

DO $$
DECLARE
    v_user_id UUID;
    v_center_id UUID;
    v_email TEXT;
BEGIN
    -- Super Admin
    v_user_id := gen_random_uuid();
    v_email := 'superadmin@sigimed.test';
    INSERT INTO users_profiles (id, email, full_name, phone, role, permissions, is_active, created_at)
    VALUES (v_user_id, v_email, 'Dr. Administrador General del Sistema', '5551234567',
            'super_admin', '{"all": true}'::JSONB, true, CURRENT_TIMESTAMP)
    ON CONFLICT (email) DO NOTHING;

    -- Admin Centro 1
    v_user_id := gen_random_uuid();
    v_email := 'admin.hgm@sigimed.test';
    SELECT id INTO v_center_id FROM health_centers WHERE code = 'HG-001' LIMIT 1;
    INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
    VALUES (v_user_id, v_email, 'Dr. Juan Carlos Pérez Administrador', '5559871234',
            'admin_center', true, CURRENT_TIMESTAMP)
    ON CONFLICT (email) DO NOTHING;
    IF v_center_id IS NOT NULL THEN
        INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
        VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, center_id) DO NOTHING;
    END IF;

    -- Admin Centro 2
    v_user_id := gen_random_uuid();
    v_email := 'admin.hraei@sigimed.test';
    SELECT id INTO v_center_id FROM health_centers WHERE code = 'HRAE-002' LIMIT 1;
    INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
    VALUES (v_user_id, v_email, 'Dra. María Elena Rodríguez Administradora', '5559726001',
            'admin_center', true, CURRENT_TIMESTAMP)
    ON CONFLICT (email) DO NOTHING;
    IF v_center_id IS NOT NULL THEN
        INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
        VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, center_id) DO NOTHING;
    END IF;

    -- Usuarios de Inventario
    FOR i IN 1..5 LOOP
        v_user_id := gen_random_uuid();
        v_email := 'inventario' || i || '@sigimed.test';
        SELECT id INTO v_center_id FROM health_centers ORDER BY random() LIMIT 1;
        INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
        VALUES (v_user_id, v_email, 'Q.F.B. Usuario Inventario ' || i,
                '555' || lpad((1000000 + i)::TEXT, 7, '0'), 'inventory_user', true, CURRENT_TIMESTAMP)
        ON CONFLICT (email) DO NOTHING;
        IF v_center_id IS NOT NULL THEN
            INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
            VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, center_id) DO NOTHING;
        END IF;
    END LOOP;

    -- Usuarios de Solo Lectura
    FOR i IN 1..3 LOOP
        v_user_id := gen_random_uuid();
        v_email := 'readonly' || i || '@sigimed.test';
        SELECT id INTO v_center_id FROM health_centers ORDER BY random() LIMIT 1;
        INSERT INTO users_profiles (id, email, full_name, phone, role, is_active, created_at)
        VALUES (v_user_id, v_email, 'Lic. Usuario Lectura ' || i,
                '555' || lpad((2000000 + i)::TEXT, 7, '0'), 'read_only', true, CURRENT_TIMESTAMP)
        ON CONFLICT (email) DO NOTHING;
        IF v_center_id IS NOT NULL THEN
            INSERT INTO user_centers (id, user_id, center_id, is_primary, created_at)
            VALUES (gen_random_uuid(), v_user_id, v_center_id, true, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, center_id) DO NOTHING;
        END IF;
    END LOOP;

    RAISE NOTICE '✓ Usuarios creados (10+)';
END $$;

-- ==================================================
-- PARTE 7: REQUISICIONES
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 7: Generando Requisiciones';
RAISE NOTICE '==================================================';

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
            v_req_id, v_req_number,
            v_servicios[1 + floor(random() * array_length(v_servicios, 1))::INTEGER],
            v_user_id, v_center_id, v_estado, v_fecha_solicitud,
            v_fecha_solicitud + (3 + floor(random() * 7)::INTEGER || ' days')::INTERVAL,
            CASE WHEN random() < 0.7 THEN 'normal'
                 WHEN random() < 0.9 THEN 'urgente'
                 ELSE 'emergencia' END,
            'Requisición de prueba generada automáticamente', v_fecha_solicitud
        );

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
                    gen_random_uuid(), v_req_id, v_med_id,
                    5 + floor(random() * 45)::INTEGER,
                    CASE WHEN v_estado IN ('aprobada', 'surtida', 'completada')
                         THEN 5 + floor(random() * 40)::INTEGER ELSE NULL END,
                    CASE WHEN v_estado IN ('surtida', 'completada')
                         THEN 5 + floor(random() * 40)::INTEGER ELSE NULL END,
                    'Consumo estimado para ' || (7 + floor(random() * 23)::INTEGER) || ' días',
                    v_fecha_solicitud
                );
            END IF;
        END LOOP;
        v_contador := v_contador + 1;
    END LOOP;
    RAISE NOTICE '✓ Requisiciones generadas: %', v_contador;
END $$;

-- ==================================================
-- PARTE 8: TRANSFERENCIAS
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 8: Generando Transferencias';
RAISE NOTICE '==================================================';

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
            v_transfer_id, v_transfer_number, v_origin_center_id, v_dest_center_id,
            v_estado, v_user_id, v_fecha_solicitud,
            'TRK' || lpad(floor(random() * 9999999999)::TEXT, 10, '0'),
            'Transferencia de prueba generada automáticamente', v_fecha_solicitud
        );

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
                    gen_random_uuid(), v_transfer_id, v_med_id,
                    5 + floor(random() * 15)::INTEGER,
                    CASE WHEN v_estado IN ('approved', 'in_transit', 'received', 'completed')
                         THEN 5 + floor(random() * 15)::INTEGER ELSE NULL END,
                    CASE WHEN v_estado IN ('in_transit', 'received', 'completed')
                         THEN 5 + floor(random() * 15)::INTEGER ELSE NULL END,
                    CASE WHEN v_estado IN ('received', 'completed')
                         THEN 5 + floor(random() * 15)::INTEGER ELSE NULL END,
                    v_fecha_solicitud;
            END IF;
        END LOOP;
        v_contador := v_contador + 1;
    END LOOP;
    RAISE NOTICE '✓ Transferencias generadas: %', v_contador;
END $$;

-- ==================================================
-- PARTE 9: ALERTAS DE CADUCIDAD
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'PASO 9: Generando Alertas de Caducidad';
RAISE NOTICE '==================================================';

SELECT generar_alertas_caducidad();

RAISE NOTICE '✓ Alertas generadas';

-- ==================================================
-- RESUMEN FINAL
-- ==================================================
RAISE NOTICE '';
RAISE NOTICE '==================================================';
RAISE NOTICE 'RESUMEN FINAL';
RAISE NOTICE '==================================================';

DO $$
DECLARE
    v_total_centros INTEGER;
    v_total_medicamentos INTEGER;
    v_total_items INTEGER;
    v_stock_total BIGINT;
    v_total_alertas INTEGER;
    v_total_usuarios INTEGER;
    v_total_requisiciones INTEGER;
    v_total_transferencias INTEGER;
    v_total_proveedores INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_centros FROM health_centers WHERE is_active = true;
    SELECT COUNT(DISTINCT catalog_id) INTO v_total_medicamentos FROM medications;
    SELECT COUNT(*) INTO v_total_items FROM medications;
    SELECT SUM(cantidad) INTO v_stock_total FROM medications WHERE estado = 'Disponible';
    SELECT COUNT(*) INTO v_total_alertas FROM alertas_medicamentos WHERE NOT resuelta;
    SELECT COUNT(*) INTO v_total_usuarios FROM users_profiles;
    SELECT COUNT(*) INTO v_total_requisiciones FROM requisitions;
    SELECT COUNT(*) INTO v_total_transferencias FROM transfers;
    SELECT COUNT(*) INTO v_total_proveedores FROM suppliers;

    RAISE NOTICE '';
    RAISE NOTICE 'Centros de salud: %', v_total_centros;
    RAISE NOTICE 'Proveedores: %', v_total_proveedores;
    RAISE NOTICE 'Medicamentos en catálogo: %', v_total_medicamentos;
    RAISE NOTICE 'Items en inventario: %', v_total_items;
    RAISE NOTICE 'Stock total disponible: % unidades', v_stock_total;
    RAISE NOTICE 'Usuarios: %', v_total_usuarios;
    RAISE NOTICE 'Requisiciones: %', v_total_requisiciones;
    RAISE NOTICE 'Transferencias: %', v_total_transferencias;
    RAISE NOTICE 'Alertas activas: %', v_total_alertas;
    RAISE NOTICE '';
    RAISE NOTICE '==================================================';
    RAISE NOTICE '✓ BASE DE DATOS POBLADA EXITOSAMENTE';
    RAISE NOTICE '==================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'CREDENCIALES DE PRUEBA:';
    RAISE NOTICE 'Email: superadmin@sigimed.test';
    RAISE NOTICE 'Email: admin.hgm@sigimed.test';
    RAISE NOTICE 'Email: admin.hraei@sigimed.test';
    RAISE NOTICE 'Email: inventario1@sigimed.test';
    RAISE NOTICE 'Email: readonly1@sigimed.test';
    RAISE NOTICE 'Contraseña para todos: Test123!';
    RAISE NOTICE '';
    RAISE NOTICE 'NOTA: Debes crear estos usuarios en Supabase Auth';
    RAISE NOTICE '==================================================';
END $$;

COMMIT;
