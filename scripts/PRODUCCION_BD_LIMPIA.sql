-- =====================================================
-- SCRIPT DE PRODUCCIÓN - BASE DE DATOS LIMPIA
-- =====================================================
-- Este script prepara la base de datos para PRODUCCIÓN
-- Borra SOLO los datos transaccionales (medicamentos, lotes, movimientos)
-- Mantiene INTACTOS: catálogos, centros de salud, instituciones
-- Uso: Ejecutar cuando se vaya a entrar a producción
-- =====================================================

BEGIN;

-- 1. Eliminar vistas existentes
DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

-- 2. Limpiar SOLO tablas transaccionales (NO catálogos ni centros)
TRUNCATE TABLE movimientos_lotes RESTART IDENTITY CASCADE;
TRUNCATE TABLE lotes RESTART IDENTITY CASCADE;
TRUNCATE TABLE medicamentos RESTART IDENTITY CASCADE;
TRUNCATE TABLE proveedores RESTART IDENTITY CASCADE;

-- 3. Verificar que catálogos y centros estén intactos
DO $$
DECLARE
  v_catalogos INTEGER;
  v_centros INTEGER;
  v_instituciones INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_catalogos FROM catalogo_medicamentos WHERE is_active = true;
  SELECT COUNT(*) INTO v_centros FROM centros_salud WHERE is_active = true;
  SELECT COUNT(*) INTO v_instituciones FROM instituciones WHERE is_active = true;

  RAISE NOTICE 'Catálogo de medicamentos: % registros activos', v_catalogos;
  RAISE NOTICE 'Centros de salud: % registros activos', v_centros;
  RAISE NOTICE 'Instituciones: % registros activos', v_instituciones;

  IF v_catalogos = 0 THEN
    RAISE EXCEPTION 'ERROR: No hay medicamentos en el catálogo. Debe cargar el catálogo primero.';
  END IF;

  IF v_centros = 0 THEN
    RAISE EXCEPTION 'ERROR: No hay centros de salud activos. Debe cargar centros primero.';
  END IF;
END $$;

-- 4. Recrear vistas para compatibilidad frontend (español -> inglés)
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

CREATE VIEW suppliers AS
SELECT * FROM proveedores;

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

CREATE VIEW batch_movements AS
SELECT * FROM movimientos_lotes;

-- 5. Insertar proveedores base
INSERT INTO proveedores (id, nombre, rfc, razon_social, ciudad, estado, is_active) VALUES
('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', 'FNA120101ABC', 'Farmacéutica Nacional S.A. de C.V.', 'Ciudad de México', 'CDMX', true),
('20000000-0000-0000-0000-000000000002', 'Laboratorios PISA', 'LAP850315XYZ', 'Laboratorios PISA S.A. de C.V.', 'Guadalajara', 'Jalisco', true),
('20000000-0000-0000-0000-000000000003', 'Genomma Lab', 'GLI990520DEF', 'Genomma Lab Internacional S.A.B. de C.V.', 'Ciudad de México', 'CDMX', true),
('20000000-0000-0000-0000-000000000004', 'Grupo Grisi', 'GGR750810GHI', 'Grupo Grisi S.A. de C.V.', 'Monterrey', 'Nuevo León', true),
('20000000-0000-0000-0000-000000000005', 'Sanfer', 'SAN820420JKL', 'Sanfer S.A. de C.V.', 'Estado de México', 'EdoMex', true);

COMMIT;

-- 6. Resumen final
SELECT 'BASE DE DATOS LISTA PARA PRODUCCIÓN' as status;
SELECT '' as separador;
SELECT 'DATOS MAESTROS (Intactos):' as categoria;
SELECT 'instituciones' as tabla, COUNT(*) as total FROM instituciones WHERE is_active = true
UNION ALL
SELECT 'centros_salud', COUNT(*) FROM centros_salud WHERE is_active = true
UNION ALL
SELECT 'catalogo_medicamentos', COUNT(*) FROM catalogo_medicamentos WHERE is_active = true
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;

SELECT '' as separador;
SELECT 'DATOS TRANSACCIONALES (Limpios):' as categoria;
SELECT 'medications' as tabla, COUNT(*) as total FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements;
