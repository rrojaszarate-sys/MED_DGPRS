-- ============================================
-- DIAGNÓSTICO COMPLETO DE COLUMNAS
-- Ejecutar en Supabase SQL Editor - Resultado concatenado
-- ============================================

SELECT
  string_agg(
    tabla || '.' || columna || ' (' || tipo || ')',
    E'\n'
    ORDER BY tabla, ordinal_position
  ) as estructura_completa
FROM (
  SELECT
    UPPER(table_name) as tabla,
    column_name as columna,
    data_type as tipo,
    ordinal_position
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('lotes', 'medicamentos', 'centros_salud', 'proveedores', 'movimientos_lotes', 'alertas_medicamentos')
  ORDER BY table_name, ordinal_position
) sub;
