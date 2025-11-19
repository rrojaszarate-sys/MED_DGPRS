BEGIN;

DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

TRUNCATE TABLE movimientos_lotes RESTART IDENTITY CASCADE;
TRUNCATE TABLE lotes RESTART IDENTITY CASCADE;
TRUNCATE TABLE medicamentos RESTART IDENTITY CASCADE;
TRUNCATE TABLE proveedores RESTART IDENTITY CASCADE;

CREATE VIEW health_centers AS
SELECT id, name, code, direccion as address, ciudad as city, estado as region, telefono as phone, email, responsable_nombre as responsible_name, is_active, institucion_id, created_at, updated_at
FROM centros_salud;

CREATE VIEW suppliers AS SELECT * FROM proveedores;

CREATE VIEW medications AS
SELECT id, center_id, catalog_id, nombre, formula_activa as descripcion, 'unidad' as unidad_medida, 'General' as categoria, false as requiere_refrigeracion,
CASE WHEN estado = 'Disponible' THEN true ELSE false END as is_active, created_at, updated_at
FROM medicamentos;

CREATE VIEW batches AS
SELECT id, medication_id, centro_id as center_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_fabricacion, fecha_caducidad, fecha_ingreso, ubicacion_fisica, temperatura_almacenamiento, stock_minimo, stock_maximo, estado, observaciones, is_active, created_at, updated_at
FROM lotes;

CREATE VIEW batch_movements AS SELECT * FROM movimientos_lotes;

INSERT INTO proveedores (id, nombre, rfc, razon_social, is_active, created_at, updated_at)
VALUES
  ('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional S.A.', 'FNA850101ABC', 'Farmacéutica Nacional S.A. de C.V.', true, NOW(), NOW()),
  ('20000000-0000-0000-0000-000000000002', 'Laboratorios PISA', 'LPI900215XYZ', 'Laboratorios PISA S.A. de C.V.', true, NOW(), NOW()),
  ('20000000-0000-0000-0000-000000000003', 'Genomma Lab', 'GLI950320ABC', 'Genomma Lab Internacional S.A.B. de C.V.', true, NOW(), NOW());

INSERT INTO medicamentos (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, created_at, updated_at)
SELECT
  gen_random_uuid(),
  cs.id,
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre, 'Sin nombre'),
  'L-' || cs.code || '-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  FLOOR(500 + RANDOM() * 4500)::INTEGER,
  CURRENT_DATE + INTERVAL '18 months',
  CURRENT_DATE - INTERVAL '30 days',
  'Disponible',
  (SELECT id FROM proveedores ORDER BY RANDOM() LIMIT 1),
  NOW(),
  NOW()
FROM catalogo_medicamentos cm
CROSS JOIN (SELECT id, code FROM centros_salud WHERE is_active = true LIMIT 5) cs
WHERE cm.is_active = true
LIMIT 200;

INSERT INTO lotes (id, medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, fecha_ingreso, stock_minimo, stock_maximo, estado, is_active, created_at, updated_at)
SELECT
  gen_random_uuid(),
  m.id,
  m.catalog_id,
  m.center_id,
  m.proveedor_id,
  'LOTE-' || LPAD((ROW_NUMBER() OVER())::TEXT, 6, '0'),
  FLOOR(1000 + RANDOM() * 4000)::INTEGER,
  FLOOR(500 + RANDOM() * 3500)::INTEGER,
  CURRENT_DATE + INTERVAL '2 years',
  CURRENT_DATE - INTERVAL '15 days',
  100,
  5000,
  'disponible',
  true,
  NOW(),
  NOW()
FROM medicamentos m
WHERE m.estado = 'Disponible'
LIMIT 300;

INSERT INTO movimientos_lotes (id, batch_id, medication_id, medication_catalog_id, center_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior, motivo, created_at, metadata)
SELECT
  gen_random_uuid(),
  l.id,
  l.medication_id,
  l.medication_catalog_id,
  l.centro_id,
  'entrada',
  l.cantidad_inicial,
  0,
  l.cantidad_inicial,
  'Ingreso inicial de inventario',
  NOW() - INTERVAL '15 days',
  '{}'::jsonb
FROM lotes l
LIMIT 300;

COMMIT;

SELECT 'medications' as tabla, COUNT(*) as total FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;
