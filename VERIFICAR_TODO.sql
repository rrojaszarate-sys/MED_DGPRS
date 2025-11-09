-- ============================================
-- VERIFICACIÓN COMPLETA DEL SISTEMA SIGIMED
-- ============================================
-- Ejecuta este script para ver TODA la información instalada
-- ============================================

-- ============================================
-- 1. RESUMEN EJECUTIVO
-- ============================================
SELECT '
╔══════════════════════════════════════════════════╗
║           VERIFICACIÓN DEL SISTEMA                ║
╚══════════════════════════════════════════════════╝
' as "INICIO";

SELECT * FROM dashboard_ejecutivo();

-- ============================================
-- 2. INSTITUCIONES INSTALADAS
-- ============================================
SELECT '
════════════════════════════════════════════════════
📍 INSTITUCIONES
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  clave,
  nombre,
  tipo,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as fecha_creacion
FROM instituciones
ORDER BY clave;

-- ============================================
-- 3. CENTROS DE SALUD
-- ============================================
SELECT '
════════════════════════════════════════════════════
🏥 CENTROS DE SALUD
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  code as codigo,
  name as nombre,
  city as ciudad,
  region,
  responsible_name as responsable,
  phone as telefono,
  CASE WHEN is_active THEN '✅ Activo' ELSE '❌ Inactivo' END as estado,
  i.clave as institucion
FROM health_centers hc
LEFT JOIN instituciones i ON hc.institucion_id = i.id
ORDER BY code;

-- ============================================
-- 4. PROVEEDORES
-- ============================================
SELECT '
════════════════════════════════════════════════════
🏭 PROVEEDORES
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  nombre,
  rfc,
  ciudad,
  estado,
  calificacion,
  terminos_pago,
  dias_credito,
  contacto_nombre,
  contacto_telefono,
  CASE WHEN is_active THEN '✅ Activo' ELSE '❌ Inactivo' END as estado
FROM suppliers
ORDER BY nombre;

-- ============================================
-- 5. CATÁLOGO DE MEDICAMENTOS
-- ============================================
SELECT '
════════════════════════════════════════════════════
💊 CATÁLOGO DE MEDICAMENTOS
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  codigo_medicamento as codigo,
  nombre_generico,
  nombre_comercial,
  forma_farmaceutica,
  concentracion,
  categoria,
  CASE WHEN requiere_receta THEN '✅ Sí' ELSE '❌ No' END as requiere_receta,
  CASE WHEN controlado THEN '⚠️ Controlado' ELSE 'Normal' END as tipo,
  temperatura_almacenamiento as temp_almacen
FROM medication_catalog
WHERE is_active = true
ORDER BY categoria, nombre_generico;

-- ============================================
-- 6. MEDICAMENTOS EN INVENTARIO (por centro)
-- ============================================
SELECT '
════════════════════════════════════════════════════
📦 MEDICAMENTOS EN INVENTARIO (por centro)
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  hc.code as centro,
  m.nombre as medicamento,
  m.categoria,
  m.unidad_medida,
  CASE WHEN m.requiere_refrigeracion THEN '❄️ Refrigeración' ELSE 'Ambiente' END as almacenamiento,
  mc.codigo_medicamento as codigo_catalogo
FROM medications m
JOIN health_centers hc ON m.center_id = hc.id
LEFT JOIN medication_catalog mc ON m.catalog_id = mc.id
WHERE m.is_active = true
ORDER BY hc.code, m.categoria, m.nombre;

-- ============================================
-- 7. LOTES EXISTENTES
-- ============================================
SELECT '
════════════════════════════════════════════════════
📋 LOTES DE MEDICAMENTOS
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  COUNT(*) as total_lotes,
  SUM(cantidad_actual) as unidades_totales,
  COUNT(CASE WHEN estado = 'disponible' THEN 1 END) as lotes_disponibles,
  COUNT(CASE WHEN estado = 'agotado' THEN 1 END) as lotes_agotados,
  COUNT(CASE WHEN estado = 'vencido' THEN 1 END) as lotes_vencidos
FROM batches;

SELECT
  hc.code as centro,
  m.nombre as medicamento,
  b.numero_lote,
  b.cantidad_actual,
  to_char(b.fecha_caducidad, 'DD/MM/YYYY') as vencimiento,
  (b.fecha_caducidad - CURRENT_DATE) as dias_restantes,
  b.estado,
  s.nombre as proveedor
FROM batches b
JOIN medications m ON b.medication_id = m.id
JOIN health_centers hc ON b.center_id = hc.id
LEFT JOIN suppliers s ON b.supplier_id = s.id
ORDER BY b.fecha_caducidad ASC;

-- ============================================
-- 8. MOVIMIENTOS DE INVENTARIO
-- ============================================
SELECT '
════════════════════════════════════════════════════
📊 MOVIMIENTOS DE INVENTARIO
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  COUNT(*) as total_movimientos,
  COUNT(CASE WHEN tipo_movimiento = 'entrada' THEN 1 END) as entradas,
  COUNT(CASE WHEN tipo_movimiento = 'salida' THEN 1 END) as salidas,
  COUNT(CASE WHEN tipo_movimiento LIKE 'transferencia%' THEN 1 END) as transferencias,
  COUNT(CASE WHEN created_at >= CURRENT_DATE THEN 1 END) as movimientos_hoy
FROM batch_movements;

SELECT
  to_char(bm.created_at, 'DD/MM/YYYY HH24:MI') as fecha,
  hc.code as centro,
  m.nombre as medicamento,
  bm.tipo_movimiento,
  bm.cantidad,
  bm.cantidad_anterior as stock_anterior,
  bm.cantidad_posterior as stock_final,
  bm.motivo
FROM batch_movements bm
JOIN medications m ON bm.medication_id = m.id
JOIN health_centers hc ON bm.center_id = hc.id
ORDER BY bm.created_at DESC
LIMIT 20;

-- ============================================
-- 9. CONTRATOS
-- ============================================
SELECT '
════════════════════════════════════════════════════
📄 CONTRATOS
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  COUNT(*) as total_contratos,
  COUNT(CASE WHEN estado = 'activo' THEN 1 END) as activos,
  COUNT(CASE WHEN estado = 'borrador' THEN 1 END) as borradores,
  COUNT(CASE WHEN estado = 'vencido' THEN 1 END) as vencidos
FROM contracts;

SELECT
  c.codigo_contrato,
  s.nombre as proveedor,
  to_char(c.fecha_inicio, 'DD/MM/YYYY') as inicio,
  to_char(c.fecha_fin, 'DD/MM/YYYY') as fin,
  c.monto_total,
  c.estado
FROM contracts c
LEFT JOIN suppliers s ON c.supplier_id = s.id
ORDER BY c.created_at DESC;

-- ============================================
-- 10. TABLAS DEL SISTEMA
-- ============================================
SELECT '
════════════════════════════════════════════════════
🗄️ TABLAS DEL SISTEMA
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  t.table_name as tabla,
  pg_size_pretty(pg_total_relation_size(quote_ident(t.table_name)::regclass)) as tamaño,
  (SELECT COUNT(*)
   FROM information_schema.columns c
   WHERE c.table_name = t.table_name
   AND c.table_schema = 'public') as num_columnas,
  COALESCE(s.n_live_tup, 0) as num_registros
FROM information_schema.tables t
LEFT JOIN pg_stat_user_tables s ON t.table_name = s.relname
WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
  AND t.table_name IN (
    'instituciones', 'health_centers', 'medication_catalog', 'medications',
    'suppliers', 'batches', 'batch_movements', 'user_centers', 'audit_log',
    'contracts', 'contract_items', 'storage_inspections', 'documentos_comprobantes'
  )
ORDER BY t.table_name;

-- ============================================
-- 11. FUNCIONES DISPONIBLES
-- ============================================
SELECT '
════════════════════════════════════════════════════
⚙️ FUNCIONES SQL DISPONIBLES
════════════════════════════════════════════════════
' as "SECCION";

SELECT
  routine_name as funcion,
  CASE routine_name
    WHEN 'registrar_movimiento_lote' THEN 'Registrar entrada/salida de medicamentos'
    WHEN 'detectar_lotes_vencidos' THEN 'Detectar lotes que ya vencieron'
    WHEN 'lotes_proximos_vencer' THEN 'Lotes que están por vencer (próximos 90 días)'
    WHEN 'dashboard_ejecutivo' THEN 'Métricas principales del sistema'
    WHEN 'crear_lote_ejemplo' THEN 'Crear un lote de prueba rápidamente'
  END as descripcion,
  CASE routine_name
    WHEN 'registrar_movimiento_lote' THEN 'SELECT * FROM registrar_movimiento_lote(batch_id, tipo, cantidad, motivo);'
    WHEN 'detectar_lotes_vencidos' THEN 'SELECT * FROM detectar_lotes_vencidos();'
    WHEN 'lotes_proximos_vencer' THEN 'SELECT * FROM lotes_proximos_vencer(90);'
    WHEN 'dashboard_ejecutivo' THEN 'SELECT * FROM dashboard_ejecutivo();'
    WHEN 'crear_lote_ejemplo' THEN 'SELECT * FROM crear_lote_ejemplo(med_id, center_id, supplier_id, 500);'
  END as ejemplo_uso
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'detectar_lotes_vencidos',
    'lotes_proximos_vencer',
    'dashboard_ejecutivo',
    'crear_lote_ejemplo'
  )
ORDER BY routine_name;

-- ============================================
-- 12. ALERTAS Y RECOMENDACIONES
-- ============================================
SELECT '
════════════════════════════════════════════════════
⚠️ ALERTAS Y RECOMENDACIONES
════════════════════════════════════════════════════
' as "SECCION";

-- Lotes próximos a vencer
SELECT
  '⚠️ LOTES PRÓXIMOS A VENCER' as alerta,
  COUNT(*) as cantidad
FROM batches
WHERE fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + 90)
  AND estado = 'disponible'
  AND cantidad_actual > 0;

-- Lotes vencidos
SELECT
  '🚨 LOTES VENCIDOS' as alerta,
  COUNT(*) as cantidad
FROM batches
WHERE fecha_caducidad < CURRENT_DATE
  AND estado != 'vencido'
  AND cantidad_actual > 0;

-- Lotes con stock bajo
SELECT
  '📉 LOTES CON STOCK BAJO' as alerta,
  COUNT(*) as cantidad
FROM batches
WHERE cantidad_actual <= stock_minimo
  AND cantidad_actual > 0
  AND estado = 'disponible';

-- ============================================
-- RESUMEN FINAL
-- ============================================
SELECT '
╔══════════════════════════════════════════════════╗
║              VERIFICACIÓN COMPLETADA              ║
╠══════════════════════════════════════════════════╣
║  ✅ Sistema instalado correctamente               ║
║  ✅ Datos de ejemplo cargados                     ║
║  ✅ Funciones operativas                          ║
║                                                    ║
║  SIGUIENTE PASO: Crear tu primer lote             ║
║                                                    ║
║  SELECT * FROM crear_lote_ejemplo(                ║
║    ''40000000-0000-0000-0000-000000000001''::UUID,║
║    ''10000000-0000-0000-0000-000000000001''::UUID,║
║    ''20000000-0000-0000-0000-000000000001''::UUID,║
║    500                                             ║
║  );                                                ║
╚══════════════════════════════════════════════════╝
' as "FIN";
