BEGIN;

INSERT INTO medicamentos (center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, costo_unitario, precio_venta, ubicacion_fisica)
SELECT
  cs.id,
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre),
  'LOTE-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD((ROW_NUMBER() OVER (PARTITION BY cs.id))::TEXT, 5, '0'),
  FLOOR(RANDOM() * 8000 + 200)::INTEGER,
  CURRENT_DATE + (INTERVAL '1 month' * FLOOR(RANDOM() * 36 + 6)),
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 180)),
  CASE
    WHEN RANDOM() > 0.85 THEN 'No Disponible'
    WHEN RANDOM() > 0.90 THEN 'Cuarentena'
    WHEN RANDOM() > 0.95 THEN 'Vencido'
    ELSE 'Disponible'
  END,
  (SELECT id FROM proveedores ORDER BY RANDOM() LIMIT 1),
  FLOOR(RANDOM() * 500 + 50)::NUMERIC,
  FLOOR(RANDOM() * 800 + 100)::NUMERIC,
  (ARRAY['Anaquel A', 'Anaquel B', 'Anaquel C', 'Refrigerador 1', 'Refrigerador 2', 'Almacén Principal', 'Farmacia'])[FLOOR(RANDOM() * 7 + 1)]
FROM catalogo_medicamentos cm
CROSS JOIN centros_salud cs
WHERE cm.is_active = true AND cs.is_active = true
ON CONFLICT DO NOTHING;

INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_fabricacion, fecha_caducidad, fecha_ingreso, ubicacion_fisica, temperatura_almacenamiento, precio_unitario, stock_minimo, stock_maximo, estado, observaciones, is_active)
SELECT
  m.id,
  m.catalog_id,
  m.center_id,
  m.proveedor_id,
  'L-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || SUBSTRING(m.center_id::TEXT FROM 1 FOR 8) || '-' || LPAD((ROW_NUMBER() OVER (PARTITION BY m.center_id))::TEXT, 5, '0'),
  FLOOR(RANDOM() * 10000 + 500)::INTEGER,
  FLOOR(RANDOM() * 8000 + 100)::INTEGER,
  CURRENT_DATE - (INTERVAL '1 month' * FLOOR(RANDOM() * 18 + 3)),
  CURRENT_DATE + (INTERVAL '1 month' * FLOOR(RANDOM() * 30 + 12)),
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 120)),
  (ARRAY['A-001', 'A-002', 'B-001', 'B-002', 'C-001', 'REFR-01', 'REFR-02', 'ALM-PRIN'])[FLOOR(RANDOM() * 8 + 1)],
  CASE WHEN RANDOM() > 0.7 THEN '15-25°C' ELSE '2-8°C (Refrigerado)' END,
  FLOOR(RANDOM() * 300 + 20)::NUMERIC,
  FLOOR(RANDOM() * 200 + 50)::INTEGER,
  FLOOR(RANDOM() * 8000 + 2000)::INTEGER,
  CASE
    WHEN RANDOM() > 0.80 THEN 'cuarentena'
    WHEN RANDOM() > 0.92 THEN 'vencido'
    WHEN RANDOM() > 0.95 THEN 'agotado'
    ELSE 'disponible'
  END,
  CASE
    WHEN RANDOM() > 0.7 THEN 'Lote en buen estado'
    WHEN RANDOM() > 0.8 THEN 'Requiere supervisión'
    WHEN RANDOM() > 0.9 THEN 'Próximo a vencer'
    ELSE NULL
  END,
  CASE WHEN RANDOM() > 0.1 THEN true ELSE false END
FROM medicamentos m
WHERE m.estado = 'Disponible'
ON CONFLICT (medication_catalog_id, numero_lote, centro_id) DO NOTHING;

DO $$
DECLARE
  v_lote RECORD;
  v_cantidad INTEGER;
  v_tipo TEXT;
  i INTEGER;
BEGIN
  FOR v_lote IN (SELECT * FROM lotes WHERE is_active = true ORDER BY RANDOM() LIMIT 1000) LOOP
    FOR i IN 1..(FLOOR(RANDOM() * 5 + 1))::INTEGER LOOP
      v_tipo := (ARRAY['entrada', 'salida', 'ajuste', 'salida', 'entrada'])[FLOOR(RANDOM() * 5 + 1)];
      v_cantidad := FLOOR(RANDOM() * 500 + 10)::INTEGER;

      INSERT INTO movimientos_lotes (
        batch_id, medication_id, medication_catalog_id, center_id,
        tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
        motivo, observaciones, created_at
      ) VALUES (
        v_lote.id,
        v_lote.medication_id,
        v_lote.medication_catalog_id,
        v_lote.centro_id,
        v_tipo,
        v_cantidad,
        v_lote.cantidad_actual,
        CASE
          WHEN v_tipo = 'entrada' THEN v_lote.cantidad_actual + v_cantidad
          WHEN v_tipo = 'salida' THEN GREATEST(v_lote.cantidad_actual - v_cantidad, 0)
          ELSE v_lote.cantidad_actual
        END,
        CASE v_tipo
          WHEN 'entrada' THEN (ARRAY['Compra programada', 'Donación', 'Transferencia recibida', 'Devolución de área'])[FLOOR(RANDOM() * 4 + 1)]
          WHEN 'salida' THEN (ARRAY['Dispensación a pacientes', 'Transferencia a otra unidad', 'Uso interno', 'Baja por caducidad'])[FLOOR(RANDOM() * 4 + 1)]
          ELSE (ARRAY['Ajuste por inventario físico', 'Corrección administrativa', 'Ajuste por merma'])[FLOOR(RANDOM() * 3 + 1)]
        END,
        CASE
          WHEN RANDOM() > 0.6 THEN (ARRAY['Operación normal', 'Verificado', 'Aprobado por supervisor', 'Urgente', 'Programado'])[FLOOR(RANDOM() * 5 + 1)]
          ELSE NULL
        END,
        NOW() - (INTERVAL '1 day' * FLOOR(RANDOM() * 90))
      );
    END LOOP;
  END LOOP;
END $$;

INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, observaciones, is_active)
SELECT
  m.id, m.catalog_id, m.center_id, m.proveedor_id,
  'VENCIDO-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  1000, 0,
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 180 + 30)),
  'vencido',
  'Lote vencido - pendiente de baja',
  false
FROM medicamentos m
WHERE m.estado = 'Disponible'
ORDER BY RANDOM()
LIMIT 50;

INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, observaciones, stock_minimo, is_active)
SELECT
  m.id, m.catalog_id, m.center_id, m.proveedor_id,
  'BAJO-STOCK-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  500,
  FLOOR(RANDOM() * 30 + 5)::INTEGER,
  CURRENT_DATE + INTERVAL '1 year',
  'disponible',
  'ALERTA: Stock por debajo del mínimo',
  200,
  true
FROM medicamentos m
WHERE m.estado = 'Disponible'
ORDER BY RANDOM()
LIMIT 100;

COMMIT;

SELECT 'INVENTARIO GENERADO' as resultado;
SELECT 'medications' as tabla, COUNT(*) as total, COUNT(*) FILTER (WHERE estado = 'Disponible') as disponibles FROM medicamentos
UNION ALL
SELECT 'batches', COUNT(*), COUNT(*) FILTER (WHERE estado = 'disponible') FROM lotes
UNION ALL
SELECT 'batch_movements', COUNT(*), NULL FROM movimientos_lotes
UNION ALL
SELECT 'lotes vencidos', COUNT(*), NULL FROM lotes WHERE estado = 'vencido'
UNION ALL
SELECT 'lotes bajo stock', COUNT(*), NULL FROM lotes WHERE cantidad_actual < stock_minimo;
