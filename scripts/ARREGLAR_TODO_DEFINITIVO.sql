-- ================================================
-- SCRIPT DEFINITIVO: ARREGLAR MAPEO INGLÉS-ESPAÑOL
-- ================================================
-- Ejecutar en Supabase SQL Editor
-- ================================================

-- ================================================
-- 1. DROP VIEWS ANTERIORES
-- ================================================
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- ================================================
-- 2. CREAR VIEW: health_centers
-- ================================================
CREATE VIEW health_centers AS
SELECT
  id,
  COALESCE(name, nombre) as name,
  COALESCE(code, codigo) as code,
  COALESCE(address, direccion) as address,
  COALESCE(city, ciudad) as city,
  region,
  COALESCE(phone, telefono) as phone,
  email,
  COALESCE(responsible_name, responsable) as responsible_name,
  COALESCE(is_active, es_activo) as is_active,
  institucion_id,
  created_at,
  COALESCE(updated_at, created_at) as updated_at
FROM centros_salud;

-- ================================================
-- 3. CREAR VIEW: suppliers
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
  COALESCE(dias_credito, 0) as dias_credito,
  calificacion,
  notas,
  COALESCE(is_active, es_activo) as is_active,
  created_at,
  COALESCE(updated_at, created_at) as updated_at
FROM proveedores;

-- ================================================
-- 4. CREAR VIEW: medications
-- ================================================
CREATE VIEW medications AS
SELECT
  id,
  COALESCE(center_id, centro_salud_id) as center_id,
  COALESCE(catalog_id, catalogo_medicamento_id) as catalog_id,
  nombre,
  descripcion,
  COALESCE(unidad_medida, 'unidad') as unidad_medida,
  categoria,
  COALESCE(requiere_refrigeracion, false) as requiere_refrigeracion,
  COALESCE(is_active, es_activo, true) as is_active,
  created_at,
  COALESCE(updated_at, created_at) as updated_at
FROM medicamentos;

-- ================================================
-- 5. CREAR VIEW: batches
-- ================================================
CREATE VIEW batches AS
SELECT
  id,
  COALESCE(medication_id, medicamento_id) as medication_id,
  COALESCE(center_id, centro_salud_id) as center_id,
  COALESCE(supplier_id, proveedor_id) as supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  COALESCE(stock_minimo, 10) as stock_minimo,
  stock_maximo,
  -- Mapear estado_id a estado string
  CASE
    WHEN estado_id IS NOT NULL THEN
      COALESCE(
        (SELECT codigo FROM catalogo_estados WHERE id = lotes.estado_id LIMIT 1),
        'disponible'
      )
    ELSE COALESCE(estado, 'disponible')
  END as estado,
  observaciones,
  created_at,
  COALESCE(updated_at, created_at) as updated_at
FROM lotes;

-- ================================================
-- 6. CREAR VIEW: batch_movements
-- ================================================
CREATE VIEW batch_movements AS
SELECT
  id,
  COALESCE(batch_id, lote_id) as batch_id,
  COALESCE(medication_id, medicamento_id) as medication_id,
  COALESCE(center_id, centro_salud_id) as center_id,
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
  COALESCE(metadata, '{}'::jsonb) as metadata
FROM movimientos_lotes;

-- ================================================
-- 7. VERIFICAR DATOS
-- ================================================
SELECT '=== VERIFICACIÓN DE VIEWS ===' as seccion;

SELECT
  'health_centers' as vista,
  COUNT(*) as total_registros,
  COUNT(DISTINCT id) as ids_unicos
FROM health_centers

UNION ALL

SELECT
  'suppliers' as vista,
  COUNT(*) as total_registros,
  COUNT(DISTINCT id) as ids_unicos
FROM suppliers

UNION ALL

SELECT
  'medications' as vista,
  COUNT(*) as total_registros,
  COUNT(DISTINCT id) as ids_unicos
FROM medications

UNION ALL

SELECT
  'batches' as vista,
  COUNT(*) as total_registros,
  COUNT(DISTINCT id) as ids_unicos
FROM batches

UNION ALL

SELECT
  'batch_movements' as vista,
  COUNT(*) as total_registros,
  COUNT(DISTINCT id) as ids_unicos
FROM batch_movements;

-- ================================================
-- 8. MUESTRA DE DATOS
-- ================================================
SELECT '=== MUESTRA DE MEDICATIONS ===' as seccion;
SELECT id, center_id, nombre, categoria, is_active
FROM medications
LIMIT 5;

SELECT '=== MUESTRA DE BATCHES ===' as seccion;
SELECT id, medication_id, numero_lote, cantidad_actual, estado
FROM batches
LIMIT 5;

SELECT '=== MUESTRA DE HEALTH CENTERS ===' as seccion;
SELECT id, name, code, is_active
FROM health_centers
LIMIT 5;

SELECT '✅ VIEWS CREADAS Y VERIFICADAS' as resultado;
