BEGIN;

DELETE FROM movimientos_lotes;
DELETE FROM lotes;
DELETE FROM medicamentos;
DELETE FROM proveedores WHERE id::text LIKE '2000%';

INSERT INTO proveedores (id, nombre, rfc, razon_social, is_active, created_at, updated_at)
VALUES
  ('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional S.A.', 'FNA850101ABC', 'Farmacéutica Nacional S.A. de C.V.', true, NOW(), NOW()),
  ('20000000-0000-0000-0000-000000000002', 'Laboratorios PISA', 'LPI900215XYZ', 'Laboratorios PISA S.A. de C.V.', true, NOW(), NOW()),
  ('20000000-0000-0000-0000-000000000003', 'Genomma Lab', 'GLI950320ABC', 'Genomma Lab Internacional S.A.B. de C.V.', true, NOW(), NOW());

INSERT INTO medicamentos (id, center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, created_at, updated_at)
SELECT
  gen_random_uuid(),
  cs.id,
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre, 'Fórmula'),
  'LOTE-' || cs.code || '-' || SUBSTRING(COALESCE(cm.clave_cuadro, 'MED') FROM 1 FOR 5),
  FLOOR(RANDOM() * 5000 + 500)::INTEGER,
  CURRENT_DATE + (INTERVAL '1 year' * (RANDOM() * 2 + 1)),
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 90)),
  CASE WHEN RANDOM() > 0.1 THEN 'Disponible' ELSE 'No Disponible' END,
  (ARRAY['20000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003'])[FLOOR(RANDOM() * 3 + 1)]::uuid,
  NOW(),
  NOW()
FROM catalogo_medicamentos cm
CROSS JOIN (SELECT id, code FROM centros_salud WHERE is_active = true LIMIT 5) cs
WHERE cm.is_active = true
LIMIT 200;

INSERT INTO lotes (id, medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, fecha_ingreso, stock_minimo, stock_maximo, estado, is_active, created_at, updated_at)
SELECT
  gen_random_uuid(),
  m.id,
  m.catalog_id,
  m.center_id,
  m.proveedor_id,
  'LOTE-' || TO_CHAR(seq, 'FM0000') || '-' || TO_CHAR(RANDOM() * 1000, 'FM0000'),
  FLOOR(RANDOM() * 5000 + 1000)::INTEGER,
  FLOOR(RANDOM() * 4000 + 500)::INTEGER,
  CURRENT_DATE + (INTERVAL '1 year' * (RANDOM() * 2 + 1)),
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 60)),
  50,
  8000,
  CASE WHEN RANDOM() > 0.15 THEN 'disponible' WHEN RANDOM() > 0.5 THEN 'cuarentena' ELSE 'vencido' END,
  true,
  NOW(),
  NOW()
FROM medicamentos m
CROSS JOIN generate_series(1, 3) seq
WHERE m.estado = 'Disponible'
LIMIT 300;

INSERT INTO movimientos_lotes (id, batch_id, medication_id, medication_catalog_id, center_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior, motivo, usuario_responsable, created_at, metadata)
SELECT
  gen_random_uuid(),
  l.id,
  l.medication_id,
  l.medication_catalog_id,
  l.centro_id,
  (ARRAY['entrada', 'salida', 'ajuste'])[FLOOR(RANDOM() * 3 + 1)]::text,
  FLOOR(RANDOM() * 200 + 10)::INTEGER,
  l.cantidad_actual,
  l.cantidad_actual + FLOOR(RANDOM() * 200 - 100)::INTEGER,
  (ARRAY['Compra regular', 'Dispensación a pacientes', 'Ajuste de inventario', 'Transferencia entre centros'])[FLOOR(RANDOM() * 4 + 1)]::text,
  (SELECT id FROM users_profiles LIMIT 1),
  NOW() - (INTERVAL '1 day' * FLOOR(RANDOM() * 30)),
  '{}'::jsonb
FROM lotes l
WHERE l.is_active = true
LIMIT 150;

COMMIT;

SELECT 'medications' as tabla, COUNT(*) as total FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;
