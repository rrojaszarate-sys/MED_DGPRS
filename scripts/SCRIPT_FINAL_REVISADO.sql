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
SELECT
  id, name, code,
  direccion as address,
  ciudad as city,
  estado as region,
  telefono as phone,
  email,
  responsable_nombre as responsible_name,
  is_active,
  institucion_id,
  created_at,
  updated_at
FROM centros_salud;

CREATE VIEW suppliers AS
SELECT * FROM proveedores;

CREATE VIEW medications AS
SELECT
  id,
  center_id,
  catalog_id,
  nombre,
  formula_activa as descripcion,
  'unidad' as unidad_medida,
  'General' as categoria,
  false as requiere_refrigeracion,
  CASE WHEN estado = 'Disponible' THEN true ELSE false END as is_active,
  created_at,
  updated_at
FROM medicamentos;

CREATE VIEW batches AS
SELECT
  id,
  medication_id,
  centro_id as center_id,
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
  observaciones,
  is_active,
  created_at,
  updated_at
FROM lotes;

CREATE VIEW batch_movements AS
SELECT * FROM movimientos_lotes;

INSERT INTO proveedores (id, nombre, is_active)
VALUES
  ('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', true),
  ('20000000-0000-0000-0000-000000000002', 'Laboratorios PISA', true),
  ('20000000-0000-0000-0000-000000000003', 'Genomma Lab', true);

INSERT INTO medicamentos (center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id)
SELECT
  cs.id,
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre),
  'LOTE-INIT',
  1000,
  CURRENT_DATE + INTERVAL '2 years',
  CURRENT_DATE,
  'Disponible',
  '20000000-0000-0000-0000-000000000001'
FROM catalogo_medicamentos cm
CROSS JOIN (SELECT id FROM centros_salud WHERE is_active = true LIMIT 3) cs
WHERE cm.is_active = true
LIMIT 90;

INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, is_active)
SELECT
  m.id,
  m.catalog_id,
  m.center_id,
  m.proveedor_id,
  'L-' || m.center_id::text || '-' || LPAD((ROW_NUMBER() OVER (PARTITION BY m.center_id))::TEXT, 4, '0'),
  3000,
  2500,
  CURRENT_DATE + INTERVAL '2 years',
  'disponible',
  true
FROM medicamentos m
WHERE m.estado = 'Disponible';

INSERT INTO movimientos_lotes (batch_id, medication_id, medication_catalog_id, center_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior, motivo)
SELECT
  l.id,
  l.medication_id,
  l.medication_catalog_id,
  l.centro_id,
  'entrada',
  l.cantidad_inicial,
  0,
  l.cantidad_inicial,
  'Ingreso inicial de inventario'
FROM lotes l;

COMMIT;

SELECT 'medications' as tabla, COUNT(*) as total FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;
