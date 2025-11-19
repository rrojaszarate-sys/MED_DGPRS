-- =====================================================
-- SCRIPT DE PRUEBAS - INVENTARIO ALEATORIO COMPLETO
-- =====================================================
-- Basado EXACTAMENTE en INSTALAR_BD_COMPLETA.sql
-- Genera datos de prueba REALISTAS para TODOS los centros
-- =====================================================

BEGIN;

-- 1. Limpiar datos existentes (respetando foreign keys)
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

TRUNCATE TABLE movimientos_lotes CASCADE;
TRUNCATE TABLE lotes CASCADE;
TRUNCATE TABLE medicamentos CASCADE;
TRUNCATE TABLE proveedores CASCADE;

-- 2. Recrear vistas
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

CREATE VIEW batch_movements AS SELECT * FROM movimientos_lotes;

-- 3. Insertar proveedores con datos completos
INSERT INTO proveedores (id, nombre, rfc, razon_social, direccion, ciudad, estado, telefono, email, contacto_nombre, terminos_pago, dias_credito, calificacion, is_active) VALUES
('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', 'FNA120101ABC', 'Farmacéutica Nacional S.A. de C.V.', 'Av. Insurgentes Sur 1234', 'Ciudad de México', 'CDMX', '55-1234-5678', 'ventas@farmanacional.mx', 'Juan Pérez López', 'Crédito 30 días', 30, 4.5, true),
('20000000-0000-0000-0000-000000000002', 'Laboratorios PISA', 'LAP850315XYZ', 'Laboratorios PISA S.A. de C.V.', 'Calle Guadalajara 567', 'Guadalajara', 'Jalisco', '33-2345-6789', 'contacto@pisa.com.mx', 'María García Sánchez', 'Crédito 45 días', 45, 4.8, true),
('20000000-0000-0000-0000-000000000003', 'Genomma Lab', 'GLI990520DEF', 'Genomma Lab Internacional S.A.B. de C.V.', 'Paseo de la Reforma 2620', 'Ciudad de México', 'CDMX', '55-3456-7890', 'ventas@genommalab.com', 'Carlos Rodríguez Martínez', 'Crédito 60 días', 60, 4.3, true),
('20000000-0000-0000-0000-000000000004', 'Grupo Grisi', 'GGR750810GHI', 'Grupo Grisi S.A. de C.V.', 'Av. Constitución 890', 'Monterrey', 'Nuevo León', '81-4567-8901', 'ventas@grisi.com', 'Ana López Fernández', 'Contado', 0, 4.0, true),
('20000000-0000-0000-0000-000000000005', 'Sanfer', 'SAN820420JKL', 'Sanfer S.A. de C.V.', 'Blvd. Manuel Ávila Camacho 138', 'Naucalpan', 'Estado de México', '55-5678-9012', 'contacto@sanfer.com.mx', 'Roberto Hernández Gómez', 'Crédito 30 días', 30, 4.6, true),
('20000000-0000-0000-0000-000000000006', 'Distribuidora Farmacéutica del Sur', 'DFS940725MNO', 'Distribuidora Farmacéutica del Sur S.A.', 'Av. Universidad 456', 'Oaxaca', 'Oaxaca', '951-6789-0123', 'ventas@dfsur.mx', 'Laura Martínez Cruz', 'Crédito 15 días', 15, 3.9, true);

-- 4. Generar medicamentos aleatorios (centros × catálogo completo)
INSERT INTO medicamentos (center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, fecha_ingreso, estado, proveedor_id, costo_unitario, precio_venta, ubicacion_fisica)
SELECT
  cs.id,
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre),
  'LOTE-' || TO_CHAR(NOW(), 'YYYY') || '-' || cs.code || '-' || LPAD((ROW_NUMBER() OVER (PARTITION BY cs.id))::TEXT, 4, '0'),
  FLOOR(200 + RANDOM() * 8000)::INTEGER,
  CURRENT_DATE + (INTERVAL '1 month' * FLOOR(RANDOM() * 36 + 6)),
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 180)),
  CASE
    WHEN RANDOM() < 0.85 THEN 'Disponible'
    WHEN RANDOM() < 0.93 THEN 'No Disponible'
    WHEN RANDOM() < 0.97 THEN 'Cuarentena'
    ELSE 'Vencido'
  END,
  (ARRAY['20000000-0000-0000-0000-000000000001'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, '20000000-0000-0000-0000-000000000003'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, '20000000-0000-0000-0000-000000000005'::uuid, '20000000-0000-0000-0000-000000000006'::uuid])[FLOOR(RANDOM() * 6 + 1)],
  FLOOR(50 + RANDOM() * 500)::NUMERIC,
  FLOOR(100 + RANDOM() * 800)::NUMERIC,
  (ARRAY['Anaquel A', 'Anaquel B', 'Anaquel C', 'Refrigerador 1', 'Refrigerador 2', 'Almacén Principal', 'Farmacia'])[FLOOR(RANDOM() * 7 + 1)]
FROM catalogo_medicamentos cm
CROSS JOIN centros_salud cs
WHERE cm.is_active = true AND cs.is_active = true;

-- 5. Generar lotes con variedad de estados y cantidades
INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_fabricacion, fecha_caducidad, fecha_ingreso, ubicacion_fisica, temperatura_almacenamiento, precio_unitario, stock_minimo, stock_maximo, estado, observaciones, is_active)
SELECT
  m.id,
  m.catalog_id,
  m.center_id,
  m.proveedor_id,
  'L-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || SUBSTRING(m.center_id::text FROM 1 FOR 8) || '-' || LPAD((ROW_NUMBER() OVER (PARTITION BY m.center_id))::TEXT, 5, '0'),
  FLOOR(500 + RANDOM() * 10000)::INTEGER,
  FLOOR(100 + RANDOM() * 8000)::INTEGER,
  CURRENT_DATE - (INTERVAL '1 month' * FLOOR(RANDOM() * 18 + 3)),
  CURRENT_DATE + (INTERVAL '1 month' * FLOOR(RANDOM() * 30 + 12)),
  CURRENT_DATE - (INTERVAL '1 day' * FLOOR(RANDOM() * 120)),
  (ARRAY['A-001', 'A-002', 'B-001', 'B-002', 'C-001', 'REFR-01', 'REFR-02', 'ALM-PRIN'])[FLOOR(RANDOM() * 8 + 1)],
  CASE WHEN RANDOM() > 0.7 THEN '15-25°C' ELSE '2-8°C (Refrigerado)' END,
  FLOOR(20 + RANDOM() * 300)::NUMERIC,
  FLOOR(50 + RANDOM() * 200)::INTEGER,
  FLOOR(2000 + RANDOM() * 8000)::INTEGER,
  CASE
    WHEN RANDOM() < 0.80 THEN 'disponible'
    WHEN RANDOM() < 0.92 THEN 'cuarentena'
    WHEN RANDOM() < 0.97 THEN 'vencido'
    ELSE 'agotado'
  END,
  CASE
    WHEN RANDOM() > 0.7 THEN 'Lote en buen estado'
    WHEN RANDOM() > 0.85 THEN 'Requiere supervisión'
    WHEN RANDOM() > 0.95 THEN 'Próximo a vencer'
    ELSE NULL
  END,
  CASE WHEN RANDOM() > 0.1 THEN true ELSE false END
FROM medicamentos m
WHERE m.estado = 'Disponible';

-- 6. Generar movimientos históricos (máximo 1000 movimientos)
DO $$
DECLARE
  v_lote RECORD;
  v_cantidad INTEGER;
  v_tipo TEXT;
  v_tipos TEXT[] := ARRAY['entrada', 'salida', 'ajuste', 'salida', 'entrada'];
  i INTEGER;
  v_count INTEGER := 0;
BEGIN
  FOR v_lote IN (SELECT * FROM lotes WHERE is_active = true ORDER BY RANDOM() LIMIT 500) LOOP
    EXIT WHEN v_count >= 1000;

    FOR i IN 1..(FLOOR(RANDOM() * 3 + 1))::INTEGER LOOP
      EXIT WHEN v_count >= 1000;

      v_tipo := v_tipos[FLOOR(RANDOM() * 5 + 1)];
      v_cantidad := FLOOR(10 + RANDOM() * 500)::INTEGER;

      INSERT INTO movimientos_lotes (
        batch_id, medication_id, medication_catalog_id, center_id,
        tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior,
        motivo, observaciones
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
          WHEN RANDOM() > 0.6 THEN (ARRAY['Operación normal', 'Verificado', 'Aprobado por supervisor', 'Urgente'])[FLOOR(RANDOM() * 4 + 1)]
          ELSE NULL
        END
      );

      v_count := v_count + 1;
    END LOOP;
  END LOOP;
END $$;

-- 7. Crear 50 lotes VENCIDOS (casos especiales)
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

-- 8. Crear 100 lotes con BAJO STOCK (casos especiales)
INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, observaciones, stock_minimo, is_active)
SELECT
  m.id, m.catalog_id, m.center_id, m.proveedor_id,
  'BAJO-STOCK-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  500,
  FLOOR(5 + RANDOM() * 30)::INTEGER,
  CURRENT_DATE + INTERVAL '1 year',
  'disponible',
  'ALERTA: Stock por debajo del mínimo',
  200,
  true
FROM medicamentos m
WHERE m.estado = 'Disponible'
ORDER BY RANDOM()
LIMIT 100;

-- 9. Crear 75 lotes PRÓXIMOS A VENCER (dentro de 3 meses)
INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, observaciones, stock_minimo, is_active)
SELECT
  m.id, m.catalog_id, m.center_id, m.proveedor_id,
  'PROX-VENC-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  800,
  FLOOR(100 + RANDOM() * 600)::INTEGER,
  CURRENT_DATE + (INTERVAL '1 day' * FLOOR(RANDOM() * 90 + 1)),
  'disponible',
  'ADVERTENCIA: Lote próximo a vencer',
  100,
  true
FROM medicamentos m
WHERE m.estado = 'Disponible'
ORDER BY RANDOM()
LIMIT 75;

COMMIT;

-- 10. Mostrar resumen (formato igual al script que funciono)
SELECT 'INVENTARIO GENERADO EXITOSAMENTE' as resultado;

SELECT 'medications' as tabla, COUNT(*) as total, COUNT(*) FILTER (WHERE estado = 'Disponible') as disponibles FROM medications
UNION ALL
SELECT 'batches', COUNT(*), COUNT(*) FILTER (WHERE estado = 'disponible') FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*), NULL FROM batch_movements
UNION ALL
SELECT 'suppliers', COUNT(*), NULL FROM suppliers
UNION ALL
SELECT 'health_centers', COUNT(*), NULL FROM health_centers;

SELECT 'CASOS_ESPECIALES' as tipo;

SELECT 'lotes_vencidos' as caso, COUNT(*) as cantidad FROM lotes WHERE estado = 'vencido'
UNION ALL
SELECT 'lotes_bajo_stock', COUNT(*) FROM lotes WHERE cantidad_actual < stock_minimo
UNION ALL
SELECT 'lotes_proximos_vencer', COUNT(*) FROM lotes WHERE fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 months' AND estado = 'disponible'
UNION ALL
SELECT 'medicamentos_cuarentena', COUNT(*) FROM medicamentos WHERE estado = 'Cuarentena';
