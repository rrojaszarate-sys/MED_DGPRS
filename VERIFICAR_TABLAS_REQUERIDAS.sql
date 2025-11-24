-- ============================================
-- VERIFICAR TABLAS REQUERIDAS PARA LA APP
-- Ejecutar en Supabase SQL Editor
-- ============================================

SELECT
  nombre_tabla,
  CASE
    WHEN existe THEN '✅ EXISTE'
    ELSE '❌ FALTA - CREAR'
  END as estado,
  descripcion
FROM (
  VALUES
    ('catalogo_medicamentos', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'catalogo_medicamentos'), 'Catálogo de medicamentos (~1000 items)'),
    ('contratos', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'contratos'), 'Contratos con proveedores'),
    ('items_contrato', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'items_contrato'), 'Items de contratos'),
    ('alertas_medicamentos', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'alertas_medicamentos'), 'Alertas de caducidad'),
    ('batches', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'batches'), 'Lotes de medicamentos'),
    ('batch_movements', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'batch_movements'), 'Movimientos de lotes'),
    ('suppliers', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'suppliers'), 'Proveedores'),
    ('health_centers', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'health_centers'), 'Centros de salud'),
    ('medications', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'medications'), 'Medicamentos por centro'),
    ('users_profiles', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'users_profiles'), 'Perfiles de usuario')
) AS t(nombre_tabla, existe, descripcion)
ORDER BY existe ASC, nombre_tabla;

-- Ver conteo de registros en tablas existentes
SELECT
  'catalogo_medicamentos' as tabla,
  COUNT(*) as registros
FROM catalogo_medicamentos
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'health_centers', COUNT(*) FROM health_centers
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;
