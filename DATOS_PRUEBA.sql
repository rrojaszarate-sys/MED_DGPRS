-- ============================================
-- SCRIPT DE DATOS DE PRUEBA - SIGIMED
-- ============================================
-- Este script inserta datos de prueba para verificar todas las funcionalidades
-- INSTRUCCIONES:
-- 1. Ejecutar en el SQL Editor de Supabase
-- 2. Asegurarse de que MIGRATION_SQL_FINAL.sql ya fue ejecutado
-- 3. Este script es IDEMPOTENTE - puede ejecutarse múltiples veces
-- ============================================

BEGIN;

-- ============================================
-- LIMPIAR DATOS DE PRUEBA ANTERIORES
-- ============================================
-- Eliminar en orden inverso de dependencias
DELETE FROM batch_movements WHERE metadata->>'test_data' = 'true';
DELETE FROM alertas_medicamentos WHERE id IN (
  SELECT a.id FROM alertas_medicamentos a
  INNER JOIN medications m ON a.medicamento_id = m.id
  WHERE m.nombre LIKE '%PRUEBA%'
);
DELETE FROM medications WHERE nombre LIKE '%PRUEBA%' OR lote LIKE 'TEST%';
DELETE FROM user_centers WHERE center_id IN (SELECT id FROM health_centers WHERE code LIKE 'TEST%');
DELETE FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%';
DELETE FROM suppliers WHERE ruc LIKE 'TEST%';
DELETE FROM health_centers WHERE code LIKE 'TEST%';
-- No eliminamos users_profiles porque están vinculados a auth.users

-- ============================================
-- 1. CENTROS DE SALUD
-- ============================================
INSERT INTO health_centers (id, name, code, address, city, region, phone, email, responsible_name, responsible_role, storage_capacity, has_refrigeration, is_active, created_at)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'Hospital Central de Prueba',
    'TEST-HCP-001',
    'Av. Principal 123',
    'Lima',
    'Lima',
    '+51-1-234-5678',
    'hospital.central@test.com',
    'Dr. Juan Pérez',
    'Director Médico',
    5000,
    true,
    true,
    NOW()
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Centro de Salud Norte',
    'TEST-CSN-002',
    'Jr. Los Olivos 456',
    'Lima',
    'Lima',
    '+51-1-234-5679',
    'centro.norte@test.com',
    'Dra. María García',
    'Jefa de Farmacia',
    2000,
    true,
    true,
    NOW()
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Posta Médica Sur',
    'TEST-PMS-003',
    'Calle Las Flores 789',
    'Arequipa',
    'Arequipa',
    '+51-54-234-5680',
    'posta.sur@test.com',
    'Lic. Carlos Ramos',
    'Coordinador',
    1000,
    false,
    true,
    NOW()
  );

-- ============================================
-- 2. PROVEEDORES
-- ============================================
INSERT INTO suppliers (id, name, ruc, address, city, phone, email, contact_name, contact_phone, payment_terms, delivery_time_days, rating, is_active, created_at)
VALUES
  (
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    'Farmacéutica Global SAC',
    'TEST20123456789',
    'Av. Industrial 100',
    'Lima',
    '+51-1-555-0001',
    'ventas@farmglobal.test',
    'Luis Mendoza',
    '+51-999-111-222',
    '30 días',
    15,
    4.5,
    true,
    NOW()
  ),
  (
    'bbbb2222-bbbb-2222-bbbb-222222222222',
    'Distribuidora MediPharma EIRL',
    'TEST20987654321',
    'Jr. Comercio 250',
    'Lima',
    '+51-1-555-0002',
    'pedidos@medipharma.test',
    'Ana Torres',
    '+51-999-333-444',
    '45 días',
    7,
    4.8,
    true,
    NOW()
  );

-- ============================================
-- 3. CATÁLOGO DE MEDICAMENTOS
-- ============================================
INSERT INTO medication_catalog (id, nombre_comercial, nombre_generico, formula_activa, concentracion, forma_farmaceutica, uso_terapeutico, categoria_farmacologica, requiere_receta, es_controlado, temperatura_almacenamiento, temperatura_min, temperatura_max, is_active, created_at)
VALUES
  -- Antibióticos
  (
    'cccc1111-cccc-1111-cccc-111111111111',
    'AMOXICILINA PRUEBA',
    'Amoxicilina',
    'Amoxicilina Trihidratada',
    '500mg',
    'capsula',
    'Tratamiento de infecciones bacterianas',
    'J01CA04',
    true,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  (
    'cccc2222-cccc-2222-cccc-222222222222',
    'CIPROFLOXACINO PRUEBA',
    'Ciprofloxacino',
    'Ciprofloxacino Clorhidrato',
    '500mg',
    'tableta',
    'Infecciones bacterianas resistentes',
    'J01MA02',
    true,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  -- Analgésicos
  (
    'cccc3333-cccc-3333-cccc-333333333333',
    'PARACETAMOL PRUEBA',
    'Paracetamol',
    'Paracetamol',
    '500mg',
    'tableta',
    'Analgésico y antipirético',
    'N02BE01',
    false,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  (
    'cccc4444-cccc-4444-cccc-444444444444',
    'IBUPROFENO PRUEBA',
    'Ibuprofeno',
    'Ibuprofeno',
    '400mg',
    'tableta',
    'Antiinflamatorio no esteroideo',
    'M01AE01',
    false,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  -- Antihipertensivos
  (
    'cccc5555-cccc-5555-cccc-555555555555',
    'LOSARTAN PRUEBA',
    'Losartán',
    'Losartán Potásico',
    '50mg',
    'tableta',
    'Tratamiento de hipertensión arterial',
    'C09CA01',
    true,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  (
    'cccc6666-cccc-6666-cccc-666666666666',
    'ENALAPRIL PRUEBA',
    'Enalapril',
    'Enalapril Maleato',
    '10mg',
    'tableta',
    'Inhibidor de la ECA para hipertensión',
    'C09AA02',
    true,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  -- Antidiabéticos
  (
    'cccc7777-cccc-7777-cccc-777777777777',
    'METFORMINA PRUEBA',
    'Metformina',
    'Metformina Clorhidrato',
    '850mg',
    'tableta',
    'Tratamiento de diabetes tipo 2',
    'A10BA02',
    true,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  -- Inyectables
  (
    'cccc8888-cccc-8888-cccc-888888888888',
    'INSULINA PRUEBA',
    'Insulina NPH',
    'Insulina Humana',
    '100UI/ml',
    'inyectable',
    'Tratamiento de diabetes',
    'A10AC01',
    true,
    true,
    'refrigerado',
    2.0,
    8.0,
    true,
    NOW()
  ),
  -- Jarabes
  (
    'cccc9999-cccc-9999-cccc-999999999999',
    'AMBROXOL PRUEBA',
    'Ambroxol',
    'Ambroxol Clorhidrato',
    '15mg/5ml',
    'jarabe',
    'Mucolítico y expectorante',
    'R05CB06',
    false,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  ),
  -- Vitaminas
  (
    'ccccaaaa-cccc-aaaa-cccc-aaaaaaaaaaaa',
    'COMPLEJO B PRUEBA',
    'Complejo B',
    'Vitaminas B1, B6, B12',
    'Multi',
    'tableta',
    'Suplemento vitamínico',
    'A11EA',
    false,
    false,
    'ambiente',
    15.0,
    30.0,
    true,
    NOW()
  );

-- ============================================
-- 4. INVENTARIO DE MEDICAMENTOS
-- ============================================
-- Hospital Central - Stock variado
INSERT INTO medications (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, costo_unitario, precio_venta, ubicacion_fisica, created_at)
VALUES
  -- Amoxicilina - Stock bueno, vence en 1 año
  (
    'dddd1111-dddd-1111-dddd-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'cccc1111-cccc-1111-cccc-111111111111',
    'AMOXICILINA PRUEBA 500mg',
    'Amoxicilina Trihidratada',
    'TEST-AMX-2024-001',
    500,
    CURRENT_DATE + INTERVAL '12 months',
    CURRENT_DATE - INTERVAL '2 months',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.50,
    1.20,
    'Estante A1',
    NOW()
  ),
  -- Amoxicilina - Stock bajo, vence pronto
  (
    'dddd1112-dddd-1112-dddd-111111111112',
    '11111111-1111-1111-1111-111111111111',
    'cccc1111-cccc-1111-cccc-111111111111',
    'AMOXICILINA PRUEBA 500mg',
    'Amoxicilina Trihidratada',
    'TEST-AMX-2024-002',
    45,
    CURRENT_DATE + INTERVAL '45 days',
    CURRENT_DATE - INTERVAL '8 months',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.48,
    1.20,
    'Estante A1',
    NOW()
  ),
  -- Ciprofloxacino - Stock crítico
  (
    'dddd2222-dddd-2222-dddd-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'cccc2222-cccc-2222-cccc-222222222222',
    'CIPROFLOXACINO PRUEBA 500mg',
    'Ciprofloxacino Clorhidrato',
    'TEST-CIP-2024-001',
    15,
    CURRENT_DATE + INTERVAL '6 months',
    CURRENT_DATE - INTERVAL '1 month',
    'Disponible',
    'bbbb2222-bbbb-2222-bbbb-222222222222',
    1.20,
    2.80,
    'Estante A2',
    NOW()
  ),
  -- Paracetamol - Stock excelente
  (
    'dddd3333-dddd-3333-dddd-333333333333',
    '11111111-1111-1111-1111-111111111111',
    'cccc3333-cccc-3333-cccc-333333333333',
    'PARACETAMOL PRUEBA 500mg',
    'Paracetamol',
    'TEST-PAR-2024-001',
    1500,
    CURRENT_DATE + INTERVAL '18 months',
    CURRENT_DATE - INTERVAL '1 month',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.10,
    0.30,
    'Estante B1',
    NOW()
  ),
  -- Ibuprofeno - Stock medio
  (
    'dddd4444-dddd-4444-dddd-444444444444',
    '11111111-1111-1111-1111-111111111111',
    'cccc4444-cccc-4444-cccc-444444444444',
    'IBUPROFENO PRUEBA 400mg',
    'Ibuprofeno',
    'TEST-IBU-2024-001',
    200,
    CURRENT_DATE + INTERVAL '10 months',
    CURRENT_DATE - INTERVAL '2 weeks',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.15,
    0.40,
    'Estante B2',
    NOW()
  ),
  -- Losartán - Próximo a vencer (15 días)
  (
    'dddd5555-dddd-5555-dddd-555555555555',
    '11111111-1111-1111-1111-111111111111',
    'cccc5555-cccc-5555-cccc-555555555555',
    'LOSARTAN PRUEBA 50mg',
    'Losartán Potásico',
    'TEST-LOS-2023-005',
    80,
    CURRENT_DATE + INTERVAL '15 days',
    CURRENT_DATE - INTERVAL '11 months',
    'Disponible',
    'bbbb2222-bbbb-2222-bbbb-222222222222',
    0.80,
    1.80,
    'Estante C1',
    NOW()
  ),
  -- Enalapril - Stock bueno
  (
    'dddd6666-dddd-6666-dddd-666666666666',
    '11111111-1111-1111-1111-111111111111',
    'cccc6666-cccc-6666-cccc-666666666666',
    'ENALAPRIL PRUEBA 10mg',
    'Enalapril Maleato',
    'TEST-ENA-2024-001',
    350,
    CURRENT_DATE + INTERVAL '14 months',
    CURRENT_DATE - INTERVAL '1 month',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.25,
    0.60,
    'Estante C2',
    NOW()
  ),
  -- Metformina - Stock excelente
  (
    'dddd7777-dddd-7777-dddd-777777777777',
    '11111111-1111-1111-1111-111111111111',
    'cccc7777-cccc-7777-cccc-777777777777',
    'METFORMINA PRUEBA 850mg',
    'Metformina Clorhidrato',
    'TEST-MET-2024-002',
    800,
    CURRENT_DATE + INTERVAL '20 months',
    CURRENT_DATE - INTERVAL '2 weeks',
    'Disponible',
    'bbbb2222-bbbb-2222-bbbb-222222222222',
    0.20,
    0.50,
    'Estante D1',
    NOW()
  ),
  -- Insulina - Refrigerado, stock bajo
  (
    'dddd8888-dddd-8888-dddd-888888888888',
    '11111111-1111-1111-1111-111111111111',
    'cccc8888-cccc-8888-cccc-888888888888',
    'INSULINA PRUEBA NPH 100UI/ml',
    'Insulina Humana',
    'TEST-INS-2024-001',
    25,
    CURRENT_DATE + INTERVAL '8 months',
    CURRENT_DATE - INTERVAL '1 month',
    'Disponible',
    'bbbb2222-bbbb-2222-bbbb-222222222222',
    15.00,
    35.00,
    'Refrigerador 1',
    NOW()
  ),
  -- Ambroxol jarabe - Stock medio
  (
    'dddd9999-dddd-9999-dddd-999999999999',
    '11111111-1111-1111-1111-111111111111',
    'cccc9999-cccc-9999-cccc-999999999999',
    'AMBROXOL PRUEBA Jarabe',
    'Ambroxol Clorhidrato',
    'TEST-AMB-2024-001',
    120,
    CURRENT_DATE + INTERVAL '15 months',
    CURRENT_DATE - INTERVAL '3 weeks',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    2.50,
    6.00,
    'Estante E1',
    NOW()
  ),
  -- Complejo B - Stock bajo
  (
    'ddddaaaa-dddd-aaaa-dddd-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'ccccaaaa-cccc-aaaa-cccc-aaaaaaaaaaaa',
    'COMPLEJO B PRUEBA',
    'Vitaminas B1, B6, B12',
    'TEST-VIT-2024-001',
    60,
    CURRENT_DATE + INTERVAL '24 months',
    CURRENT_DATE - INTERVAL '1 week',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.30,
    0.80,
    'Estante E2',
    NOW()
  );

-- Centro de Salud Norte - Stock variado
INSERT INTO medications (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, costo_unitario, precio_venta, ubicacion_fisica, created_at)
VALUES
  -- Paracetamol - Stock bueno
  (
    'eeee1111-eeee-1111-eeee-111111111111',
    '22222222-2222-2222-2222-222222222222',
    'cccc3333-cccc-3333-cccc-333333333333',
    'PARACETAMOL PRUEBA 500mg',
    'Paracetamol',
    'TEST-PAR-2024-002',
    600,
    CURRENT_DATE + INTERVAL '16 months',
    CURRENT_DATE - INTERVAL '1 month',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.10,
    0.30,
    'Anaquel 1A',
    NOW()
  ),
  -- Amoxicilina - Stock crítico, próximo a vencer
  (
    'eeee2222-eeee-2222-eeee-222222222222',
    '22222222-2222-2222-2222-222222222222',
    'cccc1111-cccc-1111-cccc-111111111111',
    'AMOXICILINA PRUEBA 500mg',
    'Amoxicilina Trihidratada',
    'TEST-AMX-2023-099',
    10,
    CURRENT_DATE + INTERVAL '20 days',
    CURRENT_DATE - INTERVAL '11 months',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.48,
    1.20,
    'Anaquel 1B',
    NOW()
  ),
  -- Metformina - Stock medio
  (
    'eeee3333-eeee-3333-eeee-333333333333',
    '22222222-2222-2222-2222-222222222222',
    'cccc7777-cccc-7777-cccc-777777777777',
    'METFORMINA PRUEBA 850mg',
    'Metformina Clorhidrato',
    'TEST-MET-2024-001',
    150,
    CURRENT_DATE + INTERVAL '18 months',
    CURRENT_DATE - INTERVAL '2 weeks',
    'Disponible',
    'bbbb2222-bbbb-2222-bbbb-222222222222',
    0.20,
    0.50,
    'Anaquel 2A',
    NOW()
  ),
  -- Ibuprofeno - En cuarentena
  (
    'eeee4444-eeee-4444-eeee-444444444444',
    '22222222-2222-2222-2222-222222222222',
    'cccc4444-cccc-4444-cccc-444444444444',
    'IBUPROFENO PRUEBA 400mg',
    'Ibuprofeno',
    'TEST-IBU-2024-005',
    50,
    CURRENT_DATE + INTERVAL '12 months',
    CURRENT_DATE - INTERVAL '1 week',
    'Cuarentena',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.15,
    0.40,
    'Cuarentena-A',
    NOW()
  );

-- Posta Médica Sur - Stock limitado
INSERT INTO medications (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, costo_unitario, precio_venta, ubicacion_fisica, created_at)
VALUES
  -- Paracetamol - Stock bajo
  (
    'ffff1111-ffff-1111-ffff-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'cccc3333-cccc-3333-cccc-333333333333',
    'PARACETAMOL PRUEBA 500mg',
    'Paracetamol',
    'TEST-PAR-2024-003',
    100,
    CURRENT_DATE + INTERVAL '14 months',
    CURRENT_DATE - INTERVAL '3 weeks',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    0.10,
    0.30,
    'Vitrina 1',
    NOW()
  ),
  -- Ambroxol - Stock crítico
  (
    'ffff2222-ffff-2222-ffff-222222222222',
    '33333333-3333-3333-3333-333333333333',
    'cccc9999-cccc-9999-cccc-999999999999',
    'AMBROXOL PRUEBA Jarabe',
    'Ambroxol Clorhidrato',
    'TEST-AMB-2024-002',
    8,
    CURRENT_DATE + INTERVAL '10 months',
    CURRENT_DATE - INTERVAL '2 weeks',
    'Disponible',
    'aaaa1111-aaaa-1111-aaaa-111111111111',
    2.50,
    6.00,
    'Vitrina 2',
    NOW()
  );

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT
  '✅ DATOS DE PRUEBA INSERTADOS EXITOSAMENTE' as status,
  (SELECT COUNT(*) FROM health_centers WHERE code LIKE 'TEST%') as centros,
  (SELECT COUNT(*) FROM suppliers WHERE ruc LIKE 'TEST%') as proveedores,
  (SELECT COUNT(*) FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%') as catalogo,
  (SELECT COUNT(*) FROM medications WHERE lote LIKE 'TEST%') as inventario;

-- Resumen por centro
SELECT
  hc.name as centro,
  COUNT(m.id) as total_medicamentos,
  SUM(m.cantidad) as total_unidades,
  ROUND(AVG(m.cantidad), 2) as promedio_stock,
  COUNT(CASE WHEN m.fecha_caducidad <= CURRENT_DATE + INTERVAL '30 days' THEN 1 END) as proximos_vencer
FROM health_centers hc
LEFT JOIN medications m ON hc.id = m.center_id
WHERE hc.code LIKE 'TEST%'
GROUP BY hc.id, hc.name
ORDER BY hc.name;

-- Medicamentos próximos a vencer
SELECT
  hc.name as centro,
  m.nombre,
  m.lote,
  m.cantidad,
  m.fecha_caducidad,
  (m.fecha_caducidad - CURRENT_DATE) as dias_restantes,
  m.estado
FROM medications m
INNER JOIN health_centers hc ON m.center_id = hc.id
WHERE m.lote LIKE 'TEST%'
  AND m.fecha_caducidad <= CURRENT_DATE + INTERVAL '60 days'
ORDER BY m.fecha_caducidad ASC;

-- Stock bajo (menos de 50 unidades)
SELECT
  hc.name as centro,
  m.nombre,
  m.lote,
  m.cantidad,
  m.estado,
  m.ubicacion_fisica
FROM medications m
INNER JOIN health_centers hc ON m.center_id = hc.id
WHERE m.lote LIKE 'TEST%'
  AND m.cantidad < 50
ORDER BY m.cantidad ASC;
