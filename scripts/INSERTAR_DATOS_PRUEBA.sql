-- ================================================
-- INSERTAR DATOS DE PRUEBA
-- ================================================

DO $$
DECLARE
  v_centro_id UUID;
  v_proveedor_id UUID;
  v_catalogo_ids UUID[];
  v_cat_id UUID;
  v_med_id UUID;
BEGIN

  -- 1. Obtener primer centro activo
  SELECT id INTO v_centro_id
  FROM centros_salud
  WHERE is_active = true
  LIMIT 1;

  RAISE NOTICE 'Centro seleccionado: %', v_centro_id;

  -- 2. Insertar proveedor si no existe
  INSERT INTO proveedores (id, nombre, rfc, razon_social, is_active)
  VALUES (
    '20000000-0000-0000-0000-000000000001',
    'Farmacéutica Nacional',
    'FNA123456ABC',
    'Farmacéutica Nacional S.A. de C.V.',
    true
  )
  ON CONFLICT (id) DO NOTHING;

  v_proveedor_id := '20000000-0000-0000-0000-000000000001';

  -- 3. Obtener primeros 10 items del catálogo
  SELECT ARRAY_AGG(id) INTO v_catalogo_ids
  FROM (
    SELECT id FROM catalogo_medicamentos LIMIT 10
  ) sub;

  RAISE NOTICE 'Catálogos encontrados: %', array_length(v_catalogo_ids, 1);

  -- 4. Insertar medicamentos
  FOREACH v_cat_id IN ARRAY v_catalogo_ids
  LOOP
    v_med_id := gen_random_uuid();

    INSERT INTO medicamentos (
      id,
      center_id,
      catalog_id,
      nombre,
      formula_activa,
      estado,
      created_at
    )
    SELECT
      v_med_id,
      v_centro_id,
      v_cat_id,
      cm.nombre,
      cm.principio_activo,
      'activo',
      NOW()
    FROM catalogo_medicamentos cm
    WHERE cm.id = v_cat_id
    ON CONFLICT DO NOTHING;

    -- 5. Insertar lote para este medicamento
    INSERT INTO lotes (
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
      is_active
    )
    VALUES (
      v_med_id,
      v_cat_id,
      v_centro_id,
      v_proveedor_id,
      'LOTE-' || FLOOR(RANDOM() * 9000 + 1000)::TEXT,
      FLOOR(RANDOM() * 5000 + 1000)::INTEGER,
      FLOOR(RANDOM() * 4000 + 500)::INTEGER,
      CURRENT_DATE + INTERVAL '2 years',
      CURRENT_DATE - INTERVAL '30 days',
      100,
      10000,
      'disponible',
      true
    )
    ON CONFLICT DO NOTHING;

  END LOOP;

  RAISE NOTICE '✅ Datos insertados correctamente';

END $$;

-- VERIFICAR
SELECT 'medications' as tabla, COUNT(*) as total FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;

-- MOSTRAR MUESTRA
SELECT 'MUESTRA DE MEDICATIONS:' as info;
SELECT id, nombre, catalog_id, center_id, is_active
FROM medications
LIMIT 5;

SELECT 'MUESTRA DE BATCHES:' as info;
SELECT id, numero_lote, cantidad_actual, estado
FROM batches
LIMIT 5;
