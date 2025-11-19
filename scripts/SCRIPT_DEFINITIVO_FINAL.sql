-- ================================================
-- SCRIPT DEFINITIVO - BASADO EN ESTRUCTURA REAL
-- ================================================
-- Todas las columnas NOT NULL incluidas
-- CHECK constraints respetados
-- ================================================

BEGIN;

-- ================================================
-- 1. LIMPIAR VIEWS ANTERIORES
-- ================================================
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- ================================================
-- 2. CREAR VIEWS CORRECTAS
-- ================================================

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

CREATE VIEW suppliers AS SELECT * FROM proveedores;

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
  CASE
    WHEN estado = 'Disponible' THEN true
    ELSE false
  END as is_active,
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
  created_at,
  updated_at
FROM lotes;

CREATE VIEW batch_movements AS SELECT * FROM movimientos_lotes;

-- ================================================
-- 3. INSERTAR PROVEEDOR
-- ================================================
INSERT INTO proveedores (id, nombre, is_active, created_at, updated_at)
VALUES (
  '20000000-0000-0000-0000-000000000001',
  'Farmacéutica Nacional',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO NOTHING;

-- ================================================
-- 4. INSERTAR MEDICAMENTOS
-- Todas las columnas NOT NULL incluidas:
-- - nombre (NOT NULL)
-- - formula_activa (NOT NULL)
-- - lote (NOT NULL)
-- - cantidad (NOT NULL)
-- - fecha_caducidad (NOT NULL)
-- - estado (NOT NULL) - debe ser 'Disponible' con mayúscula
-- ================================================
INSERT INTO medicamentos (
  id,
  center_id,
  catalog_id,
  nombre,
  formula_activa,
  lote,
  cantidad,
  fecha_caducidad,
  fecha_ingreso,
  estado,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  (SELECT id FROM centros_salud WHERE is_active = true LIMIT 1),
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre, 'Fórmula'),
  'LOTE-INICIAL-001',
  1000,
  CURRENT_DATE + INTERVAL '2 years',
  CURRENT_DATE,
  'Disponible',  -- Con mayúscula según CHECK constraint
  NOW(),
  NOW()
FROM catalogo_medicamentos cm
WHERE cm.is_active = true
LIMIT 10
ON CONFLICT DO NOTHING;

-- ================================================
-- 5. INSERTAR LOTES
-- Todas las columnas NOT NULL incluidas:
-- - numero_lote (NOT NULL)
-- - cantidad_inicial (NOT NULL)
-- - cantidad_actual (NOT NULL)
-- - fecha_caducidad (NOT NULL)
-- estado debe ser 'disponible' con minúscula
-- ================================================
INSERT INTO lotes (
  id,
  medication_id,
  medication_catalog_id,
  centro_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_caducidad,
  fecha_ingreso,
  stock_minimo,
  stock_maximo,
  estado,
  is_active,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  m.id,
  m.catalog_id,
  m.center_id,
  '20000000-0000-0000-0000-000000000001',
  'LOTE-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  3000,
  2500,
  CURRENT_DATE + INTERVAL '2 years',
  CURRENT_DATE,
  100,
  5000,
  'disponible',  -- Con minúscula según CHECK constraint
  true,
  NOW(),
  NOW()
FROM medicamentos m
WHERE m.estado = 'Disponible'
  AND m.created_at >= NOW() - INTERVAL '1 minute'
ON CONFLICT DO NOTHING;

COMMIT;

-- ================================================
-- 6. VERIFICACIÓN
-- ================================================
SELECT '✅ VIEWS CREADAS' as paso;

SELECT
  'health_centers' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_active = true) as activos
FROM health_centers
UNION ALL
SELECT 'suppliers', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM suppliers
UNION ALL
SELECT 'medications', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM medications
UNION ALL
SELECT 'batches', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM batches;

SELECT '✅ MUESTRA DE MEDICATIONS' as paso;
SELECT id, nombre, descripcion, center_id, is_active
FROM medications
LIMIT 5;

SELECT '✅ MUESTRA DE BATCHES' as paso;
SELECT id, numero_lote, cantidad_actual, estado, center_id
FROM batches
LIMIT 5;

SELECT '✅ ✅ ✅ PROCESO COMPLETADO EXITOSAMENTE ✅ ✅ ✅' as resultado;
SELECT 'VE A VERCEL → REDEPLOY → ABRE LA APP' as siguiente_paso;
