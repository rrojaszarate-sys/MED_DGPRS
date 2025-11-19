-- ================================================
-- DIAGNÓSTICO EN UN SOLO RESULTADO
-- ================================================

SELECT
  'medicamentos' as tabla,
  column_name,
  data_type,
  ordinal_position as pos
FROM information_schema.columns
WHERE table_name = 'medicamentos'

UNION ALL

SELECT
  'lotes' as tabla,
  column_name,
  data_type,
  ordinal_position as pos
FROM information_schema.columns
WHERE table_name = 'lotes'

UNION ALL

SELECT
  'proveedores' as tabla,
  column_name,
  data_type,
  ordinal_position as pos
FROM information_schema.columns
WHERE table_name = 'proveedores'

UNION ALL

SELECT
  'centros_salud' as tabla,
  column_name,
  data_type,
  ordinal_position as pos
FROM information_schema.columns
WHERE table_name = 'centros_salud'

UNION ALL

SELECT
  'movimientos_lotes' as tabla,
  column_name,
  data_type,
  ordinal_position as pos
FROM information_schema.columns
WHERE table_name = 'movimientos_lotes'

ORDER BY tabla, pos;
