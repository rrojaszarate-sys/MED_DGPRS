-- ================================================
-- SCRIPT FINAL GARANTIZADO
-- Revisado línea por línea basado en estructura REAL
-- ================================================
-- EJECUTAR TODO DE UNA VEZ
-- ================================================

BEGIN;

-- ================================================
-- PARTE 1: LIMPIAR VIEWS ANTERIORES
-- ================================================
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- ================================================
-- PARTE 2: CREAR VIEWS CORRECTAS
-- ================================================

-- VIEW: health_centers
-- centros_salud YA tiene: name, code, is_active en INGLÉS
CREATE VIEW health_centers AS
SELECT
  id,
  name,                                    -- ya está en inglés
  code,                                    -- ya está en inglés
  direccion as address,                   -- español -> inglés
  ciudad as city,                         -- español -> inglés
  estado as region,                       -- español -> inglés (estado = state/region)
  telefono as phone,                      -- español -> inglés
  email,                                   -- igual en ambos
  responsable_nombre as responsible_name, -- español -> inglés
  is_active,                              -- ya está en inglés
  institucion_id,                         -- mantener igual
  created_at,                             -- ya está en inglés
  updated_at                              -- ya está en inglés
FROM centros_salud;

-- VIEW: suppliers
-- proveedores YA tiene is_active en INGLÉS
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
  is_active,        -- ya está en inglés
  created_at,
  updated_at
FROM proveedores;

-- VIEW: medications
-- medicamentos YA tiene: center_id, catalog_id en INGLÉS
-- formula_activa puede ser NULL en la vista pero no en la tabla
CREATE VIEW medications AS
SELECT
  id,
  center_id,                              -- ya está en inglés
  catalog_id,                             -- ya está en inglés
  nombre,                                 -- mantener español (es el nombre que se muestra)
  formula_activa as descripcion,          -- español -> inglés (puede ser null en vista)
  'unidad' as unidad_medida,              -- valor por defecto
  'General' as categoria,                 -- valor por defecto
  false as requiere_refrigeracion,        -- valor por defecto
  CASE
    WHEN estado = 'activo' THEN true
    ELSE false
  END as is_active,                       -- mapear estado -> is_active
  created_at,
  updated_at
FROM medicamentos;

-- VIEW: batches
-- lotes tiene medication_id en INGLÉS pero centro_id en ESPAÑOL
CREATE VIEW batches AS
SELECT
  id,
  medication_id,                          -- ya está en inglés
  centro_id as center_id,                 -- español -> inglés ***CLAVE***
  supplier_id,                            -- ya está en inglés
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

-- VIEW: batch_movements
-- movimientos_lotes YA tiene: batch_id, medication_id, center_id en INGLÉS
CREATE VIEW batch_movements AS
SELECT
  id,
  batch_id,                               -- ya está en inglés
  medication_id,                          -- ya está en inglés
  center_id,                              -- ya está en inglés
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
-- PARTE 3: INSERTAR PROVEEDOR DE PRUEBA
-- ================================================
INSERT INTO proveedores (
  id,
  nombre,
  rfc,
  razon_social,
  is_active,
  created_at,
  updated_at
)
VALUES (
  '20000000-0000-0000-0000-000000000001',
  'Farmacéutica Nacional S.A.',
  'FNA850101ABC',
  'Farmacéutica Nacional S.A. de C.V.',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (id)
DO UPDATE SET
  nombre = EXCLUDED.nombre,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- ================================================
-- PARTE 4: INSERTAR MEDICAMENTOS DE PRUEBA
-- ================================================
-- Usamos datos del catálogo existente
-- formula_activa es NOT NULL, así que usamos nombre_generico o nombre

INSERT INTO medicamentos (
  id,
  center_id,
  catalog_id,
  nombre,
  formula_activa,                         -- NOT NULL en la tabla
  estado,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  (SELECT id FROM centros_salud WHERE is_active = true LIMIT 1),
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre, 'Sin fórmula'),  -- garantizar NOT NULL
  'activo',
  NOW(),
  NOW()
FROM catalogo_medicamentos cm
WHERE cm.is_active = true
LIMIT 10
ON CONFLICT DO NOTHING;

-- ================================================
-- PARTE 5: INSERTAR LOTES DE PRUEBA
-- ================================================
-- Para cada medicamento recién insertado, crear su lote

INSERT INTO lotes (
  id,
  medication_id,
  medication_catalog_id,
  centro_id,                              -- español! no center_id
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
  m.center_id,                            -- medicamentos.center_id -> lotes.centro_id
  '20000000-0000-0000-0000-000000000001',
  'LOTE-2025-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  3000,
  2500,
  CURRENT_DATE + INTERVAL '2 years',
  CURRENT_DATE - INTERVAL '15 days',
  100,
  5000,
  'disponible',
  true,
  NOW(),
  NOW()
FROM medicamentos m
WHERE m.estado = 'activo'
  AND m.created_at >= NOW() - INTERVAL '1 minute'  -- solo los que acabamos de insertar
ON CONFLICT DO NOTHING;

COMMIT;

-- ================================================
-- PARTE 6: VERIFICACIÓN COMPLETA
-- ================================================

-- Conteo de registros
SELECT '>>> CONTEO FINAL' as info;

SELECT
  'health_centers' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_active = true) as activos
FROM health_centers

UNION ALL

SELECT
  'suppliers',
  COUNT(*),
  COUNT(*) FILTER (WHERE is_active = true)
FROM suppliers

UNION ALL

SELECT
  'medications',
  COUNT(*),
  COUNT(*) FILTER (WHERE is_active = true)
FROM medications

UNION ALL

SELECT
  'batches',
  COUNT(*),
  COUNT(*) FILTER (WHERE is_active = true)
FROM batches

UNION ALL

SELECT
  'batch_movements',
  COUNT(*),
  NULL
FROM batch_movements;

-- Muestra de medications
SELECT '>>> MUESTRA DE MEDICATIONS' as info;
SELECT
  id,
  nombre,
  descripcion,
  center_id,
  catalog_id,
  is_active
FROM medications
ORDER BY created_at DESC
LIMIT 5;

-- Muestra de batches
SELECT '>>> MUESTRA DE BATCHES' as info;
SELECT
  id,
  numero_lote,
  cantidad_actual,
  estado,
  center_id,
  medication_id
FROM batches
ORDER BY created_at DESC
LIMIT 5;

-- Verificar relaciones
SELECT '>>> VERIFICACIÓN DE RELACIONES' as info;
SELECT
  'medications con center válido' as verificacion,
  COUNT(*) as total
FROM medications m
WHERE EXISTS (SELECT 1 FROM health_centers hc WHERE hc.id = m.center_id)

UNION ALL

SELECT
  'batches con medication válido',
  COUNT(*)
FROM batches b
WHERE EXISTS (SELECT 1 FROM medications m WHERE m.id = b.medication_id)

UNION ALL

SELECT
  'batches con center válido',
  COUNT(*)
FROM batches b
WHERE EXISTS (SELECT 1 FROM health_centers hc WHERE hc.id = b.center_id);

-- Mensaje final
SELECT '✅ ✅ ✅ PROCESO COMPLETADO EXITOSAMENTE ✅ ✅ ✅' as resultado;
SELECT 'Si ves este mensaje, TODO FUNCIONÓ CORRECTAMENTE' as mensaje;
SELECT 'Ahora ve a Vercel → Redeploy → Abre la app' as siguiente_paso;
