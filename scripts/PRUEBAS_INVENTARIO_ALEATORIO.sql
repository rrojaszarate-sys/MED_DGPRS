-- =====================================================
-- SCRIPT DE PRUEBAS - INVENTARIO ALEATORIO COMPLETO
-- =====================================================
-- Este script genera datos de prueba REALISTAS para TODOS los centros
-- BORRA datos transaccionales existentes y genera nuevos datos aleatorios
-- Uso: Solo para ambientes de DESARROLLO y PRUEBAS
-- =====================================================

BEGIN;

-- 1. Eliminar vistas existentes
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- 2. Limpiar SOLO tablas transaccionales (mantiene catálogos y centros intactos)
TRUNCATE TABLE movimientos_lotes RESTART IDENTITY CASCADE;
TRUNCATE TABLE lotes RESTART IDENTITY CASCADE;
TRUNCATE TABLE medicamentos RESTART IDENTITY CASCADE;
TRUNCATE TABLE proveedores RESTART IDENTITY CASCADE;

-- 3. Recrear vistas para compatibilidad frontend
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
  CASE WHEN estado = 'Disponible' THEN true ELSE false END as is_active,
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
  is_active,
  created_at,
  updated_at
FROM lotes;

CREATE VIEW batch_movements AS SELECT * FROM movimientos_lotes;

-- 4. Insertar proveedores realistas
INSERT INTO proveedores (id, nombre, rfc, razon_social, direccion, ciudad, estado, telefono, email, contacto_nombre, terminos_pago, dias_credito, calificacion, is_active) VALUES
('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', 'FNA120101ABC', 'Farmacéutica Nacional S.A. de C.V.', 'Av. Insurgentes Sur 1234', 'Ciudad de México', 'CDMX', '55-1234-5678', 'ventas@farmanacional.mx', 'Juan Pérez López', 'Crédito 30 días', 30, 4.5, true),
('20000000-0000-0000-0000-000000000002', 'Laboratorios PISA', 'LAP850315XYZ', 'Laboratorios PISA S.A. de C.V.', 'Calle Guadalajara 567', 'Guadalajara', 'Jalisco', '33-2345-6789', 'contacto@pisa.com.mx', 'María García Sánchez', 'Crédito 45 días', 45, 4.8, true),
('20000000-0000-0000-0000-000000000003', 'Genomma Lab', 'GLI990520DEF', 'Genomma Lab Internacional S.A.B. de C.V.', 'Paseo de la Reforma 2620', 'Ciudad de México', 'CDMX', '55-3456-7890', 'ventas@genommalab.com', 'Carlos Rodríguez Martínez', 'Crédito 60 días', 60, 4.3, true),
('20000000-0000-0000-0000-000000000004', 'Grupo Grisi', 'GGR750810GHI', 'Grupo Grisi S.A. de C.V.', 'Av. Constitución 890', 'Monterrey', 'Nuevo León', '81-4567-8901', 'ventas@grisi.com', 'Ana López Fernández', 'Contado', 0, 4.0, true),
('20000000-0000-0000-0000-000000000005', 'Sanfer', 'SAN820420JKL', 'Sanfer S.A. de C.V.', 'Blvd. Manuel Ávila Camacho 138', 'Naucalpan', 'Estado de México', '55-5678-9012', 'contacto@sanfer.com.mx', 'Roberto Hernández Gómez', 'Crédito 30 días', 30, 4.6, true),
('20000000-0000-0000-0000-000000000006', 'Distribuidora Farmacéutica del Sur', 'DFS940725MNO', 'Distribuidora Farmacéutica del Sur S.A.', 'Av. Universidad 456', 'Oaxaca', 'Oaxaca', '951-6789-0123', 'ventas@dfsur.mx', 'Laura Martínez Cruz', 'Crédito 15 días', 15, 3.9, true);

-- 5. Generar medicamentos aleatorios para TODOS los centros
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
    WHEN RANDOM() < 0.85 THEN 'Disponible'
    WHEN RANDOM() < 0.92 THEN 'No Disponible'
    WHEN RANDOM() < 0.97 THEN 'Cuarentena'
    ELSE 'Vencido'
  END,
  (SELECT id FROM proveedores ORDER BY RANDOM() LIMIT 1),
  FLOOR(RANDOM() * 500 + 50)::NUMERIC,
  FLOOR(RANDOM() * 800 + 100)::NUMERIC,
  (ARRAY['Anaquel A', 'Anaquel B', 'Anaquel C', 'Refrigerador 1', 'Refrigerador 2', 'Almacén Principal', 'Farmacia'])[FLOOR(RANDOM() * 7 + 1)]
FROM catalogo_medicamentos cm
CROSS JOIN centros_salud cs
WHERE cm.is_active = true AND cs.is_active = true;

-- 6. Generar lotes realistas con variedad de estados
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
    WHEN RANDOM() < 0.80 THEN 'disponible'
    WHEN RANDOM() < 0.92 THEN 'cuarentena'
    WHEN RANDOM() < 0.97 THEN 'vencido'
    ELSE 'agotado'
  END,
  CASE
    WHEN RANDOM() > 0.7 THEN 'Lote en buen estado'
    WHEN RANDOM() > 0.8 THEN 'Requiere supervisión'
    WHEN RANDOM() > 0.9 THEN 'Próximo a vencer'
    ELSE NULL
  END,
  CASE WHEN RANDOM() > 0.1 THEN true ELSE false END
FROM medicamentos m
WHERE m.estado = 'Disponible';

-- 7. Generar movimientos históricos realistas (1000+ movimientos)
DO $$
DECLARE
  v_lote RECORD;
  v_cantidad INTEGER;
  v_tipo TEXT;
  v_tipos TEXT[] := ARRAY['entrada', 'salida', 'ajuste', 'salida', 'entrada'];
  i INTEGER;
BEGIN
  FOR v_lote IN (SELECT * FROM lotes WHERE is_active = true ORDER BY RANDOM() LIMIT 1000) LOOP
    FOR i IN 1..(FLOOR(RANDOM() * 5 + 1))::INTEGER LOOP
      v_tipo := v_tipos[FLOOR(RANDOM() * 5 + 1)];
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

-- 8. Crear 50 lotes VENCIDOS específicamente (para probar alertas)
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

-- 9. Crear 100 lotes con BAJO STOCK (para probar alertas)
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

-- 10. Crear lotes próximos a vencer (dentro de 3 meses)
INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, observaciones, stock_minimo, is_active)
SELECT
  m.id, m.catalog_id, m.center_id, m.proveedor_id,
  'PROX-VENC-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  800,
  FLOOR(RANDOM() * 600 + 100)::INTEGER,
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

-- 11. Resumen de datos generados
SELECT 'INVENTARIO ALEATORIO GENERADO EXITOSAMENTE' as resultado;
SELECT '' as separador;

SELECT 'DATOS MAESTROS:' as categoria;
SELECT 'instituciones' as tabla, COUNT(*) as total FROM instituciones WHERE is_active = true
UNION ALL
SELECT 'centros_salud', COUNT(*) FROM centros_salud WHERE is_active = true
UNION ALL
SELECT 'catalogo_medicamentos', COUNT(*) FROM catalogo_medicamentos WHERE is_active = true
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;

SELECT '' as separador;

SELECT 'DATOS TRANSACCIONALES GENERADOS:' as categoria;
SELECT 'medications' as tabla, COUNT(*) as total, COUNT(*) FILTER (WHERE estado = 'Disponible') as disponibles FROM medicamentos
UNION ALL
SELECT 'batches', COUNT(*), COUNT(*) FILTER (WHERE estado = 'disponible') FROM lotes
UNION ALL
SELECT 'batch_movements', COUNT(*), COUNT(*) FILTER (WHERE tipo_movimiento = 'entrada') as entradas FROM movimientos_lotes;

SELECT '' as separador;

SELECT 'CASOS DE PRUEBA ESPECIALES:' as categoria;
SELECT 'lotes vencidos' as tipo, COUNT(*) as total FROM lotes WHERE estado = 'vencido'
UNION ALL
SELECT 'lotes bajo stock', COUNT(*) FROM lotes WHERE cantidad_actual < stock_minimo
UNION ALL
SELECT 'lotes próximos a vencer (3 meses)', COUNT(*) FROM lotes WHERE fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 months' AND estado = 'disponible'
UNION ALL
SELECT 'medicamentos en cuarentena', COUNT(*) FROM medicamentos WHERE estado = 'Cuarentena'
UNION ALL
SELECT 'movimientos de transferencia', COUNT(*) FROM movimientos_lotes WHERE tipo_movimiento LIKE 'transferencia%';
