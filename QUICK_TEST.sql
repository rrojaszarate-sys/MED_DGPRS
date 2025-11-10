-- ============================================
-- PRUEBA RÁPIDA DE FUNCIONALIDADES
-- ============================================
-- Ejecuta este script DESPUÉS de MIGRATION_SQL_FINAL.sql
-- para verificar que todo funciona correctamente
-- ============================================

-- ============================================
-- TEST 1: Verificar estructura
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 1: VERIFICANDO ESTRUCTURA' as test;
SELECT '===========================================' as separador;

-- Verificar tablas
SELECT
  CASE
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'batch_movements')
    THEN '✅ batch_movements existe'
    ELSE '❌ batch_movements NO existe'
  END as resultado
UNION ALL
SELECT
  CASE
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_log')
    THEN '✅ audit_log existe'
    ELSE '❌ audit_log NO existe'
  END
UNION ALL
SELECT
  'Columnas en batch_movements: ' || COUNT(*)::TEXT
FROM information_schema.columns
WHERE table_name = 'batch_movements';

-- ============================================
-- TEST 2: Verificar funciones
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 2: VERIFICANDO FUNCIONES SQL' as test;
SELECT '===========================================' as separador;

SELECT
  routine_name as funcion,
  '✅ OK' as estado
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
AND routine_name IN (
  'registrar_movimiento_lote',
  'generate_traceability_report',
  'search_inventory_with_batches',
  'audit_trigger_func'
)
ORDER BY routine_name;

-- ============================================
-- TEST 3: Verificar triggers
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 3: VERIFICANDO TRIGGERS' as test;
SELECT '===========================================' as separador;

SELECT
  trigger_name as trigger,
  event_object_table as tabla,
  '✅ Activo' as estado
FROM information_schema.triggers
WHERE trigger_name LIKE 'audit_%'
ORDER BY event_object_table;

-- ============================================
-- TEST 4: Contar datos
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 4: ESTADÍSTICAS' as test;
SELECT '===========================================' as separador;

SELECT
  'Medicamentos en sistema: ' || COUNT(*)::TEXT as estadistica
FROM medications
UNION ALL
SELECT
  'Centros de salud: ' || COUNT(*)::TEXT
FROM health_centers
UNION ALL
SELECT
  'Usuarios: ' || COUNT(*)::TEXT
FROM users_profiles
UNION ALL
SELECT
  'Movimientos de lotes: ' || COUNT(*)::TEXT
FROM batch_movements
UNION ALL
SELECT
  'Registros de auditoría: ' || COUNT(*)::TEXT
FROM audit_log;

-- ============================================
-- TEST 5: Prueba funcional (solo si hay datos)
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 5: PRUEBA FUNCIONAL' as test;
SELECT '===========================================' as separador;

-- Verificar si hay datos para probar
SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM medications) > 0
      AND (SELECT COUNT(*) FROM users_profiles) > 0
    THEN '✅ Sistema listo para pruebas funcionales'
    ELSE '⚠️  Necesitas agregar medicamentos y usuarios para probar'
  END as estado;

-- Si hay datos, mostrar ejemplo
SELECT
  'Para probar, ejecuta:' as instruccion
WHERE (SELECT COUNT(*) FROM medications) > 0;

SELECT
  format('SELECT registrar_movimiento_lote(
  ''%s''::uuid,
  ''entrada'',
  10,
  ''Prueba de verificación'',
  ''%s''::uuid
);', m.id, u.id) as ejemplo_sql
FROM medications m
CROSS JOIN users_profiles u
LIMIT 1;

-- ============================================
-- TEST 6: Búsqueda avanzada
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 6: BÚSQUEDA AVANZADA' as test;
SELECT '===========================================' as separador;

-- Probar búsqueda avanzada
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
LIMIT 5;

-- Si no hay resultados
SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM medications) = 0
    THEN '⚠️  No hay medicamentos en el sistema'
    ELSE '✅ Búsqueda ejecutada correctamente'
  END as resultado;

-- ============================================
-- TEST 7: Reporte de trazabilidad
-- ============================================

SELECT '===========================================' as separador;
SELECT 'TEST 7: REPORTE DE TRAZABILIDAD' as test;
SELECT '===========================================' as separador;

SELECT
  medication_nombre as medicamento,
  medication_lote as lote,
  medication_cantidad as cantidad,
  center_name as centro,
  total_movimientos as movimientos,
  CASE
    WHEN ultimo_movimiento_tipo IS NOT NULL
    THEN '✅ Con historial'
    ELSE '⚠️  Sin movimientos'
  END as estado
FROM generate_traceability_report(
  p_include_history := false
)
LIMIT 5;

-- ============================================
-- RESUMEN FINAL
-- ============================================

SELECT '===========================================' as separador;
SELECT 'RESUMEN FINAL' as test;
SELECT '===========================================' as separador;

WITH verificacion AS (
  SELECT
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'batch_movements') as tabla_batch,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'registrar_movimiento_lote') as func_movimiento,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'generate_traceability_report') as func_reporte,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'search_inventory_with_batches') as func_busqueda,
    (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name LIKE 'audit_%') as triggers_count
)
SELECT
  CASE WHEN tabla_batch = 1 THEN '✅' ELSE '❌' END || ' Tabla batch_movements' as componente
FROM verificacion
UNION ALL
SELECT CASE WHEN func_movimiento = 1 THEN '✅' ELSE '❌' END || ' Función registrar_movimiento_lote' FROM verificacion
UNION ALL
SELECT CASE WHEN func_reporte = 1 THEN '✅' ELSE '❌' END || ' Función generate_traceability_report' FROM verificacion
UNION ALL
SELECT CASE WHEN func_busqueda = 1 THEN '✅' ELSE '❌' END || ' Función search_inventory_with_batches' FROM verificacion
UNION ALL
SELECT CASE WHEN triggers_count >= 5 THEN '✅' ELSE '❌' END || ' Triggers de auditoría (' || triggers_count || ')' FROM verificacion;

-- Estado final
SELECT
  CASE
    WHEN (
      (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'batch_movements') = 1 AND
      (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name = 'registrar_movimiento_lote') = 1 AND
      (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name LIKE 'audit_%') >= 5
    ) THEN '🟢 TODAS LAS FUNCIONALIDADES OPERATIVAS ✅'
    ELSE '🟡 INSTALACIÓN INCOMPLETA - REVISAR ERRORES ⚠️'
  END as estado_final;

SELECT '===========================================' as separador;
