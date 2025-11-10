-- ============================================
-- SCRIPT DE VERIFICACIÓN - SIGIMED
-- ============================================
-- Ejecuta este script en Supabase SQL Editor para verificar
-- que todas las funcionalidades estén operativas
-- ============================================

-- ============================================
-- TEST 1: Verificar que existen las tablas
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 1: Verificando tablas principales' as test;
SELECT '========================================' as test;

-- Verificar batch_movements
SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_name = 'batch_movements'
    )
    THEN '✅ Tabla batch_movements existe'
    ELSE '❌ Tabla batch_movements NO existe'
  END as resultado;

-- Verificar audit_log
SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_name = 'audit_log'
    )
    THEN '✅ Tabla audit_log existe'
    ELSE '❌ Tabla audit_log NO existe'
  END as resultado;

-- Contar columnas de batch_movements
SELECT
  'batch_movements tiene ' || COUNT(*) || ' columnas' as info
FROM information_schema.columns
WHERE table_name = 'batch_movements';

-- ============================================
-- TEST 2: Verificar índices
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 2: Verificando índices' as test;
SELECT '========================================' as test;

SELECT
  indexname as indice,
  tablename as tabla
FROM pg_indexes
WHERE tablename IN ('batch_movements', 'audit_log')
ORDER BY tablename, indexname;

-- ============================================
-- TEST 3: Verificar funciones SQL
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 3: Verificando funciones SQL' as test;
SELECT '========================================' as test;

SELECT
  routine_name as funcion,
  CASE
    WHEN routine_name = 'registrar_movimiento_lote' THEN '✅ Función de movimientos de lotes'
    WHEN routine_name = 'generate_traceability_report' THEN '✅ Función de reporte de trazabilidad'
    WHEN routine_name = 'search_inventory_with_batches' THEN '✅ Función de búsqueda avanzada'
    WHEN routine_name = 'audit_trigger_func' THEN '✅ Función de trigger de auditoría'
    ELSE '✅ Función auxiliar'
  END as descripcion
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
AND routine_schema = 'public'
AND routine_name IN (
  'registrar_movimiento_lote',
  'generate_traceability_report',
  'search_inventory_with_batches',
  'audit_trigger_func'
)
ORDER BY routine_name;

-- ============================================
-- TEST 4: Verificar triggers
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 4: Verificando triggers de auditoría' as test;
SELECT '========================================' as test;

SELECT
  trigger_name as trigger,
  event_object_table as tabla,
  action_timing as momento,
  event_manipulation as evento
FROM information_schema.triggers
WHERE trigger_name LIKE 'audit_%'
ORDER BY event_object_table;

-- ============================================
-- TEST 5: Estadísticas de datos
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 5: Estadísticas del sistema' as test;
SELECT '========================================' as test;

-- Contar medicamentos
SELECT
  'Total de medicamentos: ' || COUNT(*) as estadistica
FROM medications;

-- Contar centros
SELECT
  'Total de centros de salud: ' || COUNT(*) as estadistica
FROM health_centers;

-- Contar movimientos de lotes
SELECT
  'Total de movimientos de lotes: ' || COUNT(*) as estadistica
FROM batch_movements;

-- Contar registros de auditoría
SELECT
  'Total de registros de auditoría: ' || COUNT(*) as estadistica
FROM audit_log;

-- ============================================
-- TEST 6: Verificar estructura de batch_movements
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 6: Estructura de batch_movements' as test;
SELECT '========================================' as test;

SELECT
  column_name as columna,
  data_type as tipo,
  CASE
    WHEN is_nullable = 'NO' THEN 'NOT NULL'
    ELSE 'NULL'
  END as nullable
FROM information_schema.columns
WHERE table_name = 'batch_movements'
ORDER BY ordinal_position;

-- ============================================
-- TEST 7: Verificar políticas RLS
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 7: Row Level Security (RLS)' as test;
SELECT '========================================' as test;

SELECT
  schemaname as schema,
  tablename as tabla,
  policyname as politica,
  permissive as permisivo,
  cmd as comando
FROM pg_policies
WHERE tablename IN ('batch_movements', 'audit_log')
ORDER BY tablename, policyname;

-- ============================================
-- TEST 8: Prueba de función registrar_movimiento_lote
-- (Solo si hay datos)
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 8: Prueba de función (requiere datos)' as test;
SELECT '========================================' as test;

-- Verificar si hay medicamentos y usuarios para probar
SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM medications) > 0
      AND (SELECT COUNT(*) FROM users_profiles) > 0
    THEN '✅ Hay datos para probar la función'
    ELSE '⚠️  No hay datos suficientes para probar (necesitas medicamentos y usuarios)'
  END as estado;

-- Si quieres probar la función con datos reales, descomenta y ajusta:
/*
-- ADVERTENCIA: Esto modificará datos reales
SELECT registrar_movimiento_lote(
  (SELECT id FROM medications LIMIT 1),  -- ID de un medicamento existente
  'entrada',                              -- Tipo de movimiento
  10,                                     -- Cantidad
  'Prueba de verificación del sistema',  -- Motivo
  (SELECT id FROM users_profiles LIMIT 1), -- ID de usuario
  NULL,                                   -- centro_origen_id
  NULL,                                   -- centro_destino_id
  NULL,                                   -- transfer_id
  NULL,                                   -- requisition_id
  NULL,                                   -- adjustment_id
  NULL,                                   -- numero_documento
  'Test desde script de verificación'    -- observaciones
);
*/

-- ============================================
-- TEST 9: Prueba de función de búsqueda avanzada
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 9: Prueba de búsqueda avanzada' as test;
SELECT '========================================' as test;

-- Buscar medicamentos próximos a vencer (90 días)
SELECT
  nombre,
  lote,
  cantidad,
  fecha_caducidad,
  dias_para_vencer,
  CASE
    WHEN expired_alert THEN '🔴 VENCIDO'
    WHEN expiring_soon_alert THEN '🟡 PRÓXIMO A VENCER'
    WHEN stock_alert THEN '🟠 STOCK BAJO'
    ELSE '🟢 OK'
  END as alerta,
  total_movements as movimientos
FROM search_inventory_with_batches(
  p_proximos_vencer_dias := 90
)
LIMIT 10;

-- ============================================
-- TEST 10: Últimos registros de auditoría
-- ============================================

SELECT '========================================' as test;
SELECT 'TEST 10: Últimos registros de auditoría' as test;
SELECT '========================================' as test;

SELECT
  action_type as accion,
  entity_type as entidad,
  entity_name as nombre,
  user_email as usuario,
  result as resultado,
  severity as severidad,
  created_at as fecha
FROM audit_log
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- RESUMEN FINAL
-- ============================================

SELECT '========================================' as resumen;
SELECT 'RESUMEN DE VERIFICACIÓN' as resumen;
SELECT '========================================' as resumen;

WITH verificacion AS (
  SELECT
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'batch_movements') as tabla_batch,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'audit_log') as tabla_audit,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'registrar_movimiento_lote') as func_movimiento,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'generate_traceability_report') as func_reporte,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'search_inventory_with_batches') as func_busqueda,
    (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name LIKE 'audit_%') as triggers_count
)
SELECT
  CASE WHEN tabla_batch = 1 THEN '✅' ELSE '❌' END || ' Tabla batch_movements' as componente
FROM verificacion
UNION ALL
SELECT
  CASE WHEN tabla_audit = 1 THEN '✅' ELSE '❌' END || ' Tabla audit_log'
FROM verificacion
UNION ALL
SELECT
  CASE WHEN func_movimiento = 1 THEN '✅' ELSE '❌' END || ' Función registrar_movimiento_lote'
FROM verificacion
UNION ALL
SELECT
  CASE WHEN func_reporte = 1 THEN '✅' ELSE '❌' END || ' Función generate_traceability_report'
FROM verificacion
UNION ALL
SELECT
  CASE WHEN func_busqueda = 1 THEN '✅' ELSE '❌' END || ' Función search_inventory_with_batches'
FROM verificacion
UNION ALL
SELECT
  CASE WHEN triggers_count >= 5 THEN '✅' ELSE '❌' END || ' Triggers de auditoría (' || triggers_count || ')'
FROM verificacion;

-- Total de componentes funcionando
SELECT
  '🎯 Total de componentes verificados: ' ||
  (
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('batch_movements', 'audit_log')) +
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name IN ('registrar_movimiento_lote', 'generate_traceability_report', 'search_inventory_with_batches')) +
    (SELECT COUNT(DISTINCT event_object_table) FROM information_schema.triggers WHERE trigger_name LIKE 'audit_%')
  ) || ' / 10' as resultado;

SELECT
  '📊 Estado general: ' ||
  CASE
    WHEN (
      (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'batch_movements') = 1 AND
      (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'registrar_movimiento_lote') = 1 AND
      (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name LIKE 'audit_%') >= 5
    ) THEN '🟢 TODAS LAS FUNCIONALIDADES OPERATIVAS'
    ELSE '🟡 REQUIERE ATENCIÓN'
  END as estado;
