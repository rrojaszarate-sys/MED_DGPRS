BEGIN;

DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

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

INSERT INTO proveedores (id, nombre, is_active, created_at, updated_at)
VALUES ('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO medicamentos (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, created_at, updated_at)
SELECT gen_random_uuid(), (SELECT id FROM centros_salud WHERE is_active = true LIMIT 1), cm.id, cm.nombre, COALESCE(cm.nombre_generico, cm.nombre, 'Fórmula'), 'LOTE-INICIAL-001', 1000, CURRENT_DATE + INTERVAL '2 years', CURRENT_DATE, 'Disponible', NOW(), NOW()
FROM catalogo_medicamentos cm WHERE cm.is_active = true LIMIT 10;

INSERT INTO lotes (id, medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, fecha_ingreso, stock_minimo, stock_maximo, estado, is_active, created_at, updated_at)
SELECT gen_random_uuid(), m.id, m.catalog_id, m.center_id, '20000000-0000-0000-0000-000000000001', 'LOTE-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'), 3000, 2500, CURRENT_DATE + INTERVAL '2 years', CURRENT_DATE, 100, 5000, 'disponible', true, NOW(), NOW()
FROM medicamentos m WHERE m.estado = 'Disponible' AND m.created_at >= NOW() - INTERVAL '1 minute';

COMMIT;

SELECT 'medications' as tabla, COUNT(*) FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches;
