-- ================================================
-- SOLUCIÓN FINAL - TODO EN UNO
-- Basado en la estructura REAL de la base de datos
-- ================================================

BEGIN;

-- ================================================
-- PASO 1: ELIMINAR VIEWS ANTERIORES
-- ================================================
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- ================================================
-- PASO 2: CREAR VIEWS CON MAPEO CORRECTO
-- ================================================

-- health_centers (ya está en inglés mayormente)
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

-- suppliers (ya está bien)
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

-- medications (la tabla medicamentos tiene center_id y catalog_id en inglés)
CREATE VIEW medications AS
SELECT
  id,
  center_id,
  catalog_id,
  nombre,
  formula_activa as descripcion,
  'unidad' as unidad_medida,
  COALESCE(
    (SELECT categoria_farmacologica FROM catalogo_medicamentos WHERE id = medicamentos.catalog_id),
    'General'
  ) as categoria,
  false as requiere_refrigeracion,
  CASE WHEN estado = 'activo' THEN true ELSE false END as is_active,
  created_at,
  updated_at
FROM medicamentos;

-- batches (centro_id -> center_id)
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

-- batch_movements (ya tiene center_id en inglés)
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
-- PASO 3: INSERTAR PROVEEDOR DE PRUEBA
-- ================================================
INSERT INTO proveedores (id, nombre, rfc, razon_social, is_active, created_at)
VALUES (
  '20000000-0000-0000-0000-000000000001',
  'Farmacéutica Nacional S.A.',
  'FNA850101ABC',
  'Farmacéutica Nacional S.A. de C.V.',
  true,
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  is_active = EXCLUDED.is_active;

-- ================================================
-- PASO 4: INSERTAR MEDICAMENTOS DE PRUEBA
-- ================================================
DO $$
DECLARE
  v_centro_id UUID;
  v_proveedor_id UUID := '20000000-0000-0000-0000-000000000001';
  v_catalogo_ids UUID[];
  v_cat_id UUID;
  v_cat_nombre TEXT;
  v_med_id UUID;
  counter INTEGER := 0;
BEGIN

  -- Obtener primer centro activo
  SELECT id INTO v_centro_id
  FROM centros_salud
  WHERE is_active = true
  LIMIT 1;

  IF v_centro_id IS NULL THEN
    RAISE EXCEPTION 'No hay centros de salud activos';
  END IF;

  -- Obtener hasta 10 medicamentos del catálogo
  SELECT ARRAY_AGG(id) INTO v_catalogo_ids
  FROM (
    SELECT id FROM catalogo_medicamentos WHERE is_active = true LIMIT 10
  ) sub;

  IF v_catalogo_ids IS NULL OR array_length(v_catalogo_ids, 1) = 0 THEN
    RAISE EXCEPTION 'No hay medicamentos en el catálogo';
  END IF;

  -- Para cada medicamento del catálogo
  FOREACH v_cat_id IN ARRAY v_catalogo_ids
  LOOP
    counter := counter + 1;
    v_med_id := gen_random_uuid();

    -- Obtener nombre del catálogo
    SELECT COALESCE(nombre, nombre_generico, 'Medicamento ' || counter)
    INTO v_cat_nombre
    FROM catalogo_medicamentos
    WHERE id = v_cat_id;

    -- Insertar en medicamentos
    INSERT INTO medicamentos (
      id,
      center_id,
      catalog_id,
      nombre,
      estado,
      created_at
    ) VALUES (
      v_med_id,
      v_centro_id,
      v_cat_id,
      v_cat_nombre,
      'activo',
      NOW()
    )
    ON CONFLICT DO NOTHING;

    -- Insertar lote para este medicamento
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
      created_at
    ) VALUES (
      gen_random_uuid(),
      v_med_id,
      v_cat_id,
      v_centro_id,
      v_proveedor_id,
      'LOTE-2025-' || LPAD(counter::TEXT, 4, '0'),
      3000 + (counter * 100),
      2500 + (counter * 80),
      CURRENT_DATE + INTERVAL '2 years',
      CURRENT_DATE - INTERVAL '15 days',
      100,
      5000,
      'disponible',
      true,
      NOW()
    )
    ON CONFLICT DO NOTHING;

  END LOOP;

  RAISE NOTICE '✅ Insertados % medicamentos y lotes', counter;

END $$;

COMMIT;

-- ================================================
-- PASO 5: VERIFICACIÓN FINAL
-- ================================================
SELECT '=== CONTEO FINAL ===' as seccion;

SELECT
  'health_centers' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_active = true) as activos
FROM health_centers

UNION ALL

SELECT
  'suppliers' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_active = true) as activos
FROM suppliers

UNION ALL

SELECT
  'medications' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_active = true) as activos
FROM medications

UNION ALL

SELECT
  'batches' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_active = true) as activos
FROM batches

UNION ALL

SELECT
  'batch_movements' as tabla,
  COUNT(*) as total,
  NULL as activos
FROM batch_movements;

-- Muestra de datos
SELECT '=== MUESTRA DE MEDICATIONS ===' as seccion;
SELECT id, nombre, center_id, catalog_id, is_active
FROM medications
LIMIT 5;

SELECT '=== MUESTRA DE BATCHES ===' as seccion;
SELECT id, numero_lote, cantidad_actual, estado, center_id
FROM batches
LIMIT 5;

SELECT '✅ ✅ ✅ PROCESO COMPLETADO EXITOSAMENTE ✅ ✅ ✅' as resultado;
