-- ================================================
-- SCRIPT DE VERIFICACIÓN DE DATOS DE PRUEBA
-- Sistema: SIGIMED v2.0 - Catálogos Administrables
-- ================================================
-- Ejecutar en: Supabase SQL Editor o cliente PostgreSQL
-- Copiar y pegar TODOS los resultados aquí
-- ================================================

-- 1. VERIFICAR EXISTENCIA Y CONTEO DE TABLAS
-- ================================================
SELECT '=== VERIFICACIÓN DE TABLAS Y CONTEO ===' as seccion;

SELECT
  'catalogo_colores' as tabla,
  COUNT(*) as total_registros,
  COUNT(*) FILTER (WHERE es_activo = true) as activos,
  COUNT(*) FILTER (WHERE es_activo = false) as inactivos
FROM catalogo_colores
UNION ALL
SELECT
  'catalogo_estados' as tabla,
  COUNT(*) as total_registros,
  COUNT(*) FILTER (WHERE es_activo = true) as activos,
  COUNT(*) FILTER (WHERE es_activo = false) as inactivos
FROM catalogo_estados
UNION ALL
SELECT
  'catalogo_tipos_movimiento' as tabla,
  COUNT(*) as total_registros,
  COUNT(*) FILTER (WHERE es_activo = true) as activos,
  COUNT(*) FILTER (WHERE es_activo = false) as inactivos
FROM catalogo_tipos_movimiento
UNION ALL
SELECT
  'catalogo_formas_farmaceuticas' as tabla,
  COUNT(*) as total_registros,
  COUNT(*) FILTER (WHERE es_activo = true) as activos,
  COUNT(*) FILTER (WHERE es_activo = false) as inactivos
FROM catalogo_formas_farmaceuticas
UNION ALL
SELECT
  'catalogo_prioridades' as tabla,
  COUNT(*) as total_registros,
  COUNT(*) FILTER (WHERE es_activo = true) as activos,
  COUNT(*) FILTER (WHERE es_activo = false) as inactivos
FROM catalogo_prioridades
UNION ALL
SELECT
  'catalogo_configuraciones' as tabla,
  COUNT(*) as total_registros,
  COUNT(*) FILTER (WHERE es_activo = true) as activos,
  COUNT(*) FILTER (WHERE es_activo = false) as inactivos
FROM catalogo_configuraciones;

-- 2. VERIFICAR COLORES (Muestra de 5)
-- ================================================
SELECT '=== MUESTRA DE COLORES (5 registros) ===' as seccion;

SELECT
  nombre,
  codigo_hex,
  categoria,
  uso,
  orden,
  es_activo
FROM catalogo_colores
ORDER BY orden
LIMIT 5;

-- 3. VERIFICAR ESTADOS POR MÓDULO
-- ================================================
SELECT '=== ESTADOS POR MÓDULO ===' as seccion;

SELECT
  modulo,
  COUNT(*) as total_estados,
  STRING_AGG(codigo, ', ' ORDER BY orden) as codigos
FROM catalogo_estados
WHERE es_activo = true
GROUP BY modulo
ORDER BY modulo;

-- 4. VERIFICAR TIPOS DE MOVIMIENTO POR TIPO
-- ================================================
SELECT '=== TIPOS DE MOVIMIENTO POR TIPO ===' as seccion;

SELECT
  tipo,
  COUNT(*) as total,
  STRING_AGG(codigo, ', ' ORDER BY orden) as codigos
FROM catalogo_tipos_movimiento
WHERE es_activo = true
GROUP BY tipo
ORDER BY tipo;

-- 5. VERIFICAR FORMAS FARMACÉUTICAS POR CATEGORÍA
-- ================================================
SELECT '=== FORMAS FARMACÉUTICAS POR CATEGORÍA ===' as seccion;

SELECT
  categoria,
  COUNT(*) as total,
  STRING_AGG(codigo, ', ' ORDER BY orden) as codigos
FROM catalogo_formas_farmaceuticas
WHERE es_activo = true
GROUP BY categoria
ORDER BY categoria;

-- 6. VERIFICAR PRIORIDADES POR MÓDULO Y NIVEL
-- ================================================
SELECT '=== PRIORIDADES POR MÓDULO ===' as seccion;

SELECT
  modulo,
  COUNT(*) as total,
  STRING_AGG(codigo || '(' || nivel || ')', ', ' ORDER BY nivel) as prioridades_con_nivel
FROM catalogo_prioridades
WHERE es_activo = true
GROUP BY modulo
ORDER BY modulo;

-- 7. VERIFICAR CONFIGURACIONES POR CATEGORÍA
-- ================================================
SELECT '=== CONFIGURACIONES POR CATEGORÍA ===' as seccion;

SELECT
  categoria,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE es_sensible = true) as sensibles,
  COUNT(*) FILTER (WHERE es_requerido = true) as requeridas
FROM catalogo_configuraciones
WHERE es_activo = true
GROUP BY categoria
ORDER BY categoria;

-- 8. VERIFICAR RELACIONES (Estados con Colores)
-- ================================================
SELECT '=== ESTADOS CON COLORES ASIGNADOS ===' as seccion;

SELECT
  e.modulo,
  e.codigo as estado_codigo,
  e.nombre as estado_nombre,
  c.nombre as color_nombre,
  c.codigo_hex
FROM catalogo_estados e
LEFT JOIN catalogo_colores c ON e.color_id = c.id
WHERE e.es_activo = true
ORDER BY e.modulo, e.orden
LIMIT 10;

-- 9. VERIFICAR DATOS ESPECÍFICOS CRÍTICOS
-- ================================================
SELECT '=== VERIFICACIÓN DE DATOS CRÍTICOS ===' as seccion;

-- Verificar que existen colores principales
SELECT
  'Colores principales' as verificacion,
  COUNT(*) as encontrados,
  CASE
    WHEN COUNT(*) >= 3 THEN '✓ OK'
    ELSE '✗ FALTAN DATOS'
  END as estado
FROM catalogo_colores
WHERE categoria = 'principal' AND es_activo = true

UNION ALL

-- Verificar que cada módulo tiene estados
SELECT
  'Estados por módulo' as verificacion,
  COUNT(DISTINCT modulo) as encontrados,
  CASE
    WHEN COUNT(DISTINCT modulo) >= 4 THEN '✓ OK'
    ELSE '✗ FALTAN MÓDULOS'
  END as estado
FROM catalogo_estados
WHERE es_activo = true

UNION ALL

-- Verificar tipos de movimiento de entrada y salida
SELECT
  'Tipos entrada/salida' as verificacion,
  COUNT(DISTINCT tipo) as encontrados,
  CASE
    WHEN COUNT(DISTINCT tipo) >= 2 THEN '✓ OK'
    ELSE '✗ FALTAN TIPOS'
  END as estado
FROM catalogo_tipos_movimiento
WHERE es_activo = true

UNION ALL

-- Verificar formas farmacéuticas básicas
SELECT
  'Formas farmacéuticas' as verificacion,
  COUNT(*) as encontrados,
  CASE
    WHEN COUNT(*) >= 10 THEN '✓ OK'
    ELSE '✗ POCAS FORMAS'
  END as estado
FROM catalogo_formas_farmaceuticas
WHERE es_activo = true

UNION ALL

-- Verificar prioridades con diferentes niveles
SELECT
  'Niveles de prioridad' as verificacion,
  COUNT(DISTINCT nivel) as encontrados,
  CASE
    WHEN COUNT(DISTINCT nivel) >= 5 THEN '✓ OK'
    ELSE '✗ POCOS NIVELES'
  END as estado
FROM catalogo_prioridades
WHERE es_activo = true

UNION ALL

-- Verificar configuraciones del sistema
SELECT
  'Configuraciones sistema' as verificacion,
  COUNT(*) as encontrados,
  CASE
    WHEN COUNT(*) >= 8 THEN '✓ OK'
    ELSE '✗ POCAS CONFIGS'
  END as estado
FROM catalogo_configuraciones
WHERE es_activo = true;

-- 10. MUESTRA DETALLADA DE CADA CATÁLOGO
-- ================================================
SELECT '=== MUESTRA DETALLADA: COLORES ===' as seccion;
SELECT nombre, codigo_hex, categoria, orden FROM catalogo_colores WHERE es_activo = true ORDER BY orden LIMIT 10;

SELECT '=== MUESTRA DETALLADA: ESTADOS MEDICAMENTOS ===' as seccion;
SELECT codigo, nombre, es_estado_inicial, es_estado_final FROM catalogo_estados WHERE modulo = 'medicamentos' AND es_activo = true ORDER BY orden;

SELECT '=== MUESTRA DETALLADA: ESTADOS REQUISICIONES ===' as seccion;
SELECT codigo, nombre, es_estado_inicial, es_estado_final FROM catalogo_estados WHERE modulo = 'requisiciones' AND es_activo = true ORDER BY orden;

SELECT '=== MUESTRA DETALLADA: TIPOS MOVIMIENTO ENTRADA ===' as seccion;
SELECT codigo, nombre, afecta_stock, requiere_documento, requiere_aprobacion FROM catalogo_tipos_movimiento WHERE tipo = 'entrada' AND es_activo = true ORDER BY orden;

SELECT '=== MUESTRA DETALLADA: TIPOS MOVIMIENTO SALIDA ===' as seccion;
SELECT codigo, nombre, afecta_stock, requiere_documento, requiere_aprobacion FROM catalogo_tipos_movimiento WHERE tipo = 'salida' AND es_activo = true ORDER BY orden;

SELECT '=== MUESTRA DETALLADA: FORMAS FARMACÉUTICAS ===' as seccion;
SELECT codigo, nombre, categoria, via_administracion, requiere_refrigeracion FROM catalogo_formas_farmaceuticas WHERE es_activo = true ORDER BY categoria, orden LIMIT 10;

SELECT '=== MUESTRA DETALLADA: PRIORIDADES ===' as seccion;
SELECT codigo, nombre, nivel, modulo, dias_respuesta_esperado, requiere_notificacion FROM catalogo_prioridades WHERE es_activo = true ORDER BY nivel;

SELECT '=== MUESTRA DETALLADA: CONFIGURACIONES ===' as seccion;
SELECT clave, nombre, tipo_dato, categoria, es_sensible, es_requerido FROM catalogo_configuraciones WHERE es_activo = true ORDER BY categoria, clave LIMIT 10;

-- 11. RESUMEN FINAL
-- ================================================
SELECT '=== RESUMEN FINAL ===' as seccion;

SELECT
  SUM(CASE WHEN tabla = 'catalogo_colores' THEN total ELSE 0 END) as total_colores,
  SUM(CASE WHEN tabla = 'catalogo_estados' THEN total ELSE 0 END) as total_estados,
  SUM(CASE WHEN tabla = 'catalogo_tipos_movimiento' THEN total ELSE 0 END) as total_tipos_movimiento,
  SUM(CASE WHEN tabla = 'catalogo_formas_farmaceuticas' THEN total ELSE 0 END) as total_formas,
  SUM(CASE WHEN tabla = 'catalogo_prioridades' THEN total ELSE 0 END) as total_prioridades,
  SUM(CASE WHEN tabla = 'catalogo_configuraciones' THEN total ELSE 0 END) as total_configs,
  SUM(total) as total_general
FROM (
  SELECT 'catalogo_colores' as tabla, COUNT(*) as total FROM catalogo_colores WHERE es_activo = true
  UNION ALL
  SELECT 'catalogo_estados', COUNT(*) FROM catalogo_estados WHERE es_activo = true
  UNION ALL
  SELECT 'catalogo_tipos_movimiento', COUNT(*) FROM catalogo_tipos_movimiento WHERE es_activo = true
  UNION ALL
  SELECT 'catalogo_formas_farmaceuticas', COUNT(*) FROM catalogo_formas_farmaceuticas WHERE es_activo = true
  UNION ALL
  SELECT 'catalogo_prioridades', COUNT(*) FROM catalogo_prioridades WHERE es_activo = true
  UNION ALL
  SELECT 'catalogo_configuraciones', COUNT(*) FROM catalogo_configuraciones WHERE es_activo = true
) counts;

-- ================================================
-- FIN DEL SCRIPT
-- ================================================
-- COPIAR TODOS LOS RESULTADOS Y PEGARLOS EN LA CONVERSACIÓN
-- ================================================
