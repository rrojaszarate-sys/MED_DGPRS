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

CREATE VIEW batch_movements AS
SELECT id, batch_id, medication_id, medication_catalog_id, center_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior, centro_origen_id, centro_destino_id, numero_documento, motivo, observaciones, usuario_responsable, created_at, metadata
FROM movimientos_lotes;

INSERT INTO proveedores (id, nombre, is_active)
VALUES ('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', true)
ON CONFLICT (id) DO NOTHING;

COMMIT;

SELECT 'Views creadas' as paso;
SELECT COUNT(*) as centros FROM health_centers;
SELECT COUNT(*) as catalogo FROM catalogo_medicamentos WHERE is_active = true;
