-- ================================================
-- EXTRACCIÓN COMPLETA DE ESTRUCTURA Y DATOS
-- ================================================
-- Un solo resultado con toda la información
-- ================================================

SELECT
  '>>> TABLA: ' || table_name as info,
  'Columnas: ' || string_agg(column_name || ' (' || data_type || ')', ', ' ORDER BY ordinal_position) as detalles
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('centros_salud', 'medicamentos', 'lotes', 'movimientos_lotes', 'proveedores', 'catalogo_medicamentos', 'instituciones', 'users_profiles', 'catalogo_colores', 'catalogo_estados', 'catalogo_tipos_movimiento', 'catalogo_formas_farmaceuticas', 'catalogo_prioridades', 'catalogo_configuraciones')
GROUP BY table_name
ORDER BY table_name;
