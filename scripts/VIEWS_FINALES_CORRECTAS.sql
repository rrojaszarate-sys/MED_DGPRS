-- ================================================
-- VIEWS FINALES BASADAS EN ESTRUCTURA REAL
-- ================================================

-- 1. DROP VIEWS ANTERIORES
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- ================================================
-- 2. health_centers (ya está casi en inglés)
-- ================================================
CREATE VIEW health_centers AS
SELECT
  id,
  name,
  code,
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

-- ================================================
-- 3. suppliers (ya está casi bien)
-- ================================================
CREATE VIEW suppliers AS
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
  is_active,
  created_at,
  updated_at
FROM proveedores;

-- ================================================
-- 4. medications
-- (mapear estructura real a lo que espera frontend)
-- ================================================
CREATE VIEW medications AS
SELECT
  id,
  center_id,
  catalog_id,
  nombre,
  formula_activa as descripcion,
  'unidad' as unidad_medida,
  COALESCE(
    (SELECT categoria FROM catalogo_medicamentos WHERE id = medicamentos.catalog_id LIMIT 1),
    'General'
  ) as categoria,
  false as requiere_refrigeracion,
  CASE WHEN estado = 'activo' THEN true ELSE false END as is_active,
  created_at,
  updated_at
FROM medicamentos;

-- ================================================
-- 5. batches
-- (centro_id -> center_id es el cambio principal)
-- ================================================
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
  created_at,
  updated_at
FROM lotes;

-- ================================================
-- 6. batch_movements (ya está bien)
-- ================================================
CREATE VIEW batch_movements AS
SELECT
  id,
  batch_id,
  medication_id,
  center_id,
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

-- ================================================
-- 7. VERIFICAR
-- ================================================
SELECT 'health_centers' as tabla, COUNT(*) as total FROM health_centers
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'medications', COUNT(*) FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements;
