-- ================================================
-- CREAR VIEWS CON NOMBRES EN INGLÉS
-- Para que el frontend funcione sin cambios
-- ================================================

-- View: medications -> medicamentos
CREATE OR REPLACE VIEW medications AS
SELECT
  id,
  catalogo_medicamento_id as catalog_id,
  centro_salud_id as center_id,
  nombre as nombre,
  descripcion,
  unidad_medida,
  categoria,
  subcategoria,
  requiere_refrigeracion,
  es_activo as is_active,
  created_at,
  updated_at
FROM medicamentos;

-- View: health_centers -> centros_salud
CREATE OR REPLACE VIEW health_centers AS
SELECT
  id,
  nombre as name,
  codigo as code,
  direccion as address,
  ciudad as city,
  region,
  telefono as phone,
  email,
  responsable as responsible_name,
  es_activo as is_active,
  institucion_id,
  created_at,
  updated_at
FROM centros_salud;

-- View: batches -> lotes
CREATE OR REPLACE VIEW batches AS
SELECT
  id,
  medicamento_id as medication_id,
  centro_salud_id as center_id,
  proveedor_id as supplier_id,
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
  estado_id,
  observaciones,
  created_at,
  updated_at
FROM lotes;

-- View: batch_movements -> movimientos_lotes
CREATE OR REPLACE VIEW batch_movements AS
SELECT
  id,
  lote_id as batch_id,
  medicamento_id as medication_id,
  centro_salud_id as center_id,
  tipo_movimiento,
  cantidad,
  cantidad_anterior,
  cantidad_posterior,
  centro_origen_id,
  centro_destino_id,
  numero_documento,
  motivo,
  observaciones,
  usuario_responsable,
  created_at,
  metadata
FROM movimientos_lotes;

-- View: suppliers -> proveedores
CREATE OR REPLACE VIEW suppliers AS
SELECT
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
  es_activo as is_active,
  created_at,
  updated_at
FROM proveedores;

-- View: instituciones (sin cambio de nombre pero con columnas inglés)
CREATE OR REPLACE VIEW institutions AS
SELECT
  id,
  nombre as name,
  clave as code,
  tipo as type,
  created_at
FROM instituciones;

-- VERIFICAR
SELECT 'medications' as view_name, COUNT(*) as total FROM medications
UNION ALL
SELECT 'health_centers', COUNT(*) FROM health_centers
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;
