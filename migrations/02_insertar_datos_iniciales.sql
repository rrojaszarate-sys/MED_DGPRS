-- ============================================
-- FASE 1 - PARTE 1.4: DATOS INICIALES
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Insertar instituciones, centros, proveedores y lotes iniciales
-- Ejecutar DESPUÉS de 01_crear_tablas_core.sql

BEGIN;

-- ============================================
-- 1. INSTITUCIONES
-- ============================================
INSERT INTO instituciones (id, nombre, clave, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'IMSS - Instituto Mexicano del Seguro Social', 'IMSS', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000002', 'ISSSTE - Instituto de Seguridad y Servicios Sociales', 'ISSSTE', 'Seguridad Social')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  clave = EXCLUDED.clave,
  tipo = EXCLUDED.tipo;

-- ============================================
-- 2. CENTROS DE SALUD (HGZ1 y CMF23)
-- ============================================

-- Actualizar centros existentes o insertar nuevos
INSERT INTO health_centers (
  id,
  name,
  code,
  address,
  city,
  region,
  phone,
  email,
  responsible_name,
  is_active,
  institucion_id
) VALUES
  (
    '10000000-0000-0000-0000-000000000001',
    'Hospital General de Zona No. 1 (HGZ1)',
    'HGZ1',
    'Av. Revolución 1234, Col. Centro',
    'Ciudad de México',
    'CDMX',
    '55-1234-5678',
    'hgz1@imss.gob.mx',
    'Dr. Juan Pérez García',
    true,
    '00000000-0000-0000-0000-000000000001'
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    'Clínica de Medicina Familiar No. 23 (CMF23)',
    'CMF23',
    'Calle Hidalgo 567, Col. Juárez',
    'Ciudad de México',
    'CDMX',
    '55-8765-4321',
    'cmf23@imss.gob.mx',
    'Dra. María López Hernández',
    true,
    '00000000-0000-0000-0000-000000000001'
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  code = EXCLUDED.code,
  address = EXCLUDED.address,
  city = EXCLUDED.city,
  region = EXCLUDED.region,
  phone = EXCLUDED.phone,
  email = EXCLUDED.email,
  responsible_name = EXCLUDED.responsible_name,
  is_active = EXCLUDED.is_active,
  institucion_id = EXCLUDED.institucion_id;

-- ============================================
-- 3. PROVEEDORES
-- ============================================
INSERT INTO suppliers (
  id,
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
  notas,
  is_active
) VALUES
  (
    '20000000-0000-0000-0000-000000000001',
    'Farmacéutica Nacional S.A. de C.V.',
    'FNA850312ABC',
    'Farmacéutica Nacional Sociedad Anónima de Capital Variable',
    'Av. Insurgentes Sur 1234, Col. Del Valle',
    'Ciudad de México',
    'CDMX',
    '55-9876-5432',
    'ventas@farmanacional.com.mx',
    'Lic. Carlos Ramírez',
    '55-9876-5433',
    'Crédito 30 días',
    30,
    4.5,
    'Proveedor confiable con 15 años de experiencia',
    true
  ),
  (
    '20000000-0000-0000-0000-000000000002',
    'Distribuidora Médica del Centro S.A.',
    'DMC920615XYZ',
    'Distribuidora Médica del Centro Sociedad Anónima',
    'Blvd. Manuel Ávila Camacho 890, Col. Lomas',
    'Guadalajara',
    'Jalisco',
    '33-1234-5678',
    'contacto@dismedcentro.com',
    'Ing. Ana Martínez',
    '33-1234-5679',
    'Crédito 45 días',
    45,
    4.8,
    'Especialistas en medicamentos de alta especialidad',
    true
  )
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  rfc = EXCLUDED.rfc,
  razon_social = EXCLUDED.razon_social,
  direccion = EXCLUDED.direccion,
  ciudad = EXCLUDED.ciudad,
  estado = EXCLUDED.estado,
  telefono = EXCLUDED.telefono,
  email = EXCLUDED.email,
  contacto_nombre = EXCLUDED.contacto_nombre,
  contacto_telefono = EXCLUDED.contacto_telefono,
  terminos_pago = EXCLUDED.terminos_pago,
  dias_credito = EXCLUDED.dias_credito,
  calificacion = EXCLUDED.calificacion,
  notas = EXCLUDED.notas,
  is_active = EXCLUDED.is_active;

-- ============================================
-- 4. MEDICAMENTOS AL CATÁLOGO (si no existen)
-- ============================================
INSERT INTO medication_catalog (id, nombre_comercial) VALUES
  ('30000000-0000-0000-0000-000000000001', 'PARACETAMOL 500mg'),
  ('30000000-0000-0000-0000-000000000002', 'AMOXICILINA 500mg'),
  ('30000000-0000-0000-0000-000000000003', 'METFORMINA 850mg'),
  ('30000000-0000-0000-0000-000000000004', 'LOSARTÁN 50mg')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. LOTES DE MEDICAMENTOS
-- ============================================

-- Obtener IDs de medicamentos existentes en inventario
-- Nota: Asumimos que ya hay medicamentos en la tabla 'medications'
-- Si no los hay, esta parte no insertará lotes

-- Lote 1: Paracetamol en HGZ1
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000001',
  m.id,
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000001',
  'PARA-2024-001',
  1000,
  850,
  '2024-01-15',
  '2026-01-15',
  '2024-02-01',
  'Almacén General - Pasillo A, Estante 3',
  '15-25°C',
  100,
  1500,
  'disponible',
  'Lote de alta rotación para consulta general'
FROM medications m
WHERE m.nombre ILIKE '%paracetamol%'
  AND m.center_id = '10000000-0000-0000-0000-000000000001'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

-- Lote 2: Amoxicilina en HGZ1
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000002',
  m.id,
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000002',
  'AMOX-2024-045',
  500,
  320,
  '2023-11-20',
  '2025-11-20',
  '2024-01-10',
  'Almacén Refrigerado - Sección B2',
  '2-8°C',
  50,
  800,
  'disponible',
  'Antibiótico de amplio espectro - Refrigeración requerida'
FROM medications m
WHERE m.nombre ILIKE '%amoxicilina%'
  AND m.center_id = '10000000-0000-0000-0000-000000000001'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

-- Lote 3: Metformina en CMF23
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000003',
  m.id,
  '10000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000001',
  'METF-2024-112',
  2000,
  1650,
  '2024-03-01',
  '2027-03-01',
  '2024-04-15',
  'Almacén Farmacia - Gabinete Diabetes',
  '15-30°C',
  200,
  3000,
  'disponible',
  'Medicamento para control de diabetes tipo 2'
FROM medications m
WHERE m.center_id = '10000000-0000-0000-0000-000000000002'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

-- Lote 4: Losartán en CMF23
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000004',
  m.id,
  '10000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000002',
  'LOSA-2024-078',
  800,
  650,
  '2024-02-10',
  '2026-02-10',
  '2024-03-20',
  'Almacén Farmacia - Gabinete Hipertensión',
  '15-25°C',
  100,
  1200,
  'disponible',
  'Antihipertensivo - Alta demanda en pacientes crónicos'
FROM medications m
WHERE m.center_id = '10000000-0000-0000-0000-000000000002'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT '✅ PARTE 1.4 COMPLETADA' as resultado;

SELECT 'Instituciones' as tipo, COUNT(*) as total FROM instituciones
UNION ALL
SELECT 'Centros de Salud', COUNT(*) FROM health_centers WHERE code IN ('HGZ1', 'CMF23')
UNION ALL
SELECT 'Proveedores', COUNT(*) FROM suppliers
UNION ALL
SELECT 'Lotes Creados', COUNT(*) FROM batches;

-- Mostrar resumen de lotes
SELECT
  hc.code as centro,
  hc.name as nombre_centro,
  b.numero_lote,
  m.nombre as medicamento,
  b.cantidad_actual,
  b.estado,
  s.nombre as proveedor
FROM batches b
JOIN health_centers hc ON b.center_id = hc.id
JOIN medications m ON b.medication_id = m.id
LEFT JOIN suppliers s ON b.supplier_id = s.id
WHERE hc.code IN ('HGZ1', 'CMF23')
ORDER BY hc.code, b.numero_lote;
