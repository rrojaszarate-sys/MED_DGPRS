-- ============================================
-- VERIFICACIÓN POST-EJECUCIÓN - SIGIMED v4.0.0
-- ============================================
-- Descripción: Queries de verificación para confirmar que todo se creó correctamente
-- Fecha: 2025-11-18
-- Uso: Ejecutar DESPUÉS de SIGIMED_v2_DB_COMPLETA.sql
--
-- INSTRUCCIONES:
-- 1. Ejecutar el script principal primero
-- 2. Ejecutar estas queries una por una
-- 3. Verificar que los resultados coincidan con los valores esperados
-- ============================================

-- ============================================
-- 1. VERIFICAR EXTENSIONES
-- ============================================

SELECT
    extname AS extension_name,
    extversion AS version
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pgcrypto', 'pg_trgm')
ORDER BY extname;

-- Esperado: 3 extensiones (uuid-ossp, pgcrypto, pg_trgm)

SELECT '✅ Verificación 1: Extensiones' AS check_name;

-- ============================================
-- 2. VERIFICAR TABLAS CREADAS
-- ============================================

SELECT
    COUNT(*) AS total_tablas_creadas,
    CASE
        WHEN COUNT(*) >= 46 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN TABLAS'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

-- Esperado: 46 tablas

SELECT '✅ Verificación 2: Tablas creadas' AS check_name;

-- ============================================
-- 3. LISTAR TODAS LAS TABLAS
-- ============================================

SELECT
    table_name AS nombre_tabla,
    (SELECT COUNT(*)
     FROM information_schema.columns c
     WHERE c.table_name = t.table_name
       AND c.table_schema = 'public') AS num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT '✅ Verificación 3: Listado de tablas' AS check_name;

-- ============================================
-- 4. VERIFICAR DATOS INSERTADOS
-- ============================================

-- 4.1 Instituciones
SELECT
    COUNT(*) AS total_instituciones,
    CASE
        WHEN COUNT(*) >= 2 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN INSTITUCIONES'
    END AS estado
FROM instituciones
WHERE is_active = true;

-- Esperado: 2 instituciones

-- 4.2 Centros Penitenciarios
SELECT
    COUNT(*) AS total_centros,
    CASE
        WHEN COUNT(*) >= 23 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN CENTROS'
    END AS estado
FROM centros_salud
WHERE is_active = true;

-- Esperado: 23 centros

-- 4.3 Medicamentos
SELECT
    COUNT(*) AS total_medicamentos,
    CASE
        WHEN COUNT(*) >= 80 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN MEDICAMENTOS'
    END AS estado
FROM catalogo_medicamentos
WHERE is_active = true;

-- Esperado: 99 medicamentos

-- 4.4 Proveedores
SELECT
    COUNT(*) AS total_proveedores,
    CASE
        WHEN COUNT(*) >= 1 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN PROVEEDORES'
    END AS estado
FROM proveedores
WHERE is_active = true;

-- Esperado: 1+ proveedores

SELECT '✅ Verificación 4: Datos insertados' AS check_name;

-- ============================================
-- 5. VERIFICAR FUNCIONES CREADAS
-- ============================================

SELECT
    routine_name AS nombre_funcion,
    routine_type AS tipo,
    data_type AS tipo_retorno
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- Esperado: 6+ funciones principales

SELECT '✅ Verificación 5: Funciones creadas' AS check_name;

-- ============================================
-- 6. VERIFICAR ÍNDICES CREADOS
-- ============================================

SELECT
    COUNT(DISTINCT indexname) AS total_indices,
    CASE
        WHEN COUNT(DISTINCT indexname) >= 133 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN ÍNDICES'
    END AS estado
FROM pg_indexes
WHERE schemaname = 'public';

-- Esperado: 133+ índices

SELECT '✅ Verificación 6: Índices creados' AS check_name;

-- ============================================
-- 7. VERIFICAR TRIGGERS CREADOS
-- ============================================

SELECT
    trigger_name AS nombre_trigger,
    event_object_table AS tabla,
    action_timing AS momento,
    event_manipulation AS evento
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Esperado: 12+ triggers

SELECT '✅ Verificación 7: Triggers creados' AS check_name;

-- ============================================
-- 8. VERIFICAR FOREIGN KEYS
-- ============================================

SELECT
    COUNT(*) AS total_foreign_keys,
    CASE
        WHEN COUNT(*) >= 50 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN FOREIGN KEYS'
    END AS estado
FROM information_schema.table_constraints
WHERE constraint_schema = 'public'
  AND constraint_type = 'FOREIGN KEY';

-- Esperado: 50+ foreign keys

SELECT '✅ Verificación 8: Foreign Keys' AS check_name;

-- ============================================
-- 9. VERIFICAR TABLAS AVANZADAS
-- ============================================

-- 9.1 Tablas GS1
SELECT
    COUNT(*) AS tablas_gs1,
    CASE
        WHEN COUNT(*) >= 4 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN TABLAS GS1'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE '%gs1%'
     OR table_name LIKE '%codigo_barras%'
     OR table_name LIKE '%barcode%';

-- 9.2 Tablas DSCSA
SELECT
    COUNT(*) AS tablas_dscsa,
    CASE
        WHEN COUNT(*) >= 3 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN TABLAS DSCSA'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name LIKE '%dscsa%'
     OR table_name LIKE '%serializ%'
     OR table_name LIKE '%epcis%');

-- 9.3 Tablas FHIR
SELECT
    COUNT(*) AS tablas_fhir,
    CASE
        WHEN COUNT(*) >= 4 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN TABLAS FHIR'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE '%fhir%';

-- 9.4 Tablas Notificaciones
SELECT
    COUNT(*) AS tablas_notificaciones,
    CASE
        WHEN COUNT(*) >= 5 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN TABLAS NOTIFICACIONES'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE '%notifica%';

-- 9.5 Tablas Analytics
SELECT
    COUNT(*) AS tablas_analytics,
    CASE
        WHEN COUNT(*) >= 5 THEN '✅ CORRECTO'
        ELSE '❌ FALTAN TABLAS ANALYTICS'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name LIKE '%kpi%'
     OR table_name LIKE '%tablero%'
     OR table_name LIKE '%analitica%');

SELECT '✅ Verificación 9: Tablas avanzadas' AS check_name;

-- ============================================
-- 10. VERIFICAR INTEGRIDAD DE DATOS
-- ============================================

-- 10.1 Medicamentos con todos los campos
SELECT
    COUNT(*) AS medicamentos_completos,
    CASE
        WHEN COUNT(*) >= 80 THEN '✅ CORRECTO'
        ELSE '❌ DATOS INCOMPLETOS'
    END AS estado
FROM catalogo_medicamentos
WHERE codigo_medicamento IS NOT NULL
  AND nombre_generico IS NOT NULL
  AND forma_farmaceutica IS NOT NULL
  AND concentracion IS NOT NULL;

-- 10.2 Centros con todos los campos
SELECT
    COUNT(*) AS centros_completos,
    CASE
        WHEN COUNT(*) >= 23 THEN '✅ CORRECTO'
        ELSE '❌ DATOS INCOMPLETOS'
    END AS estado
FROM centros_salud
WHERE name IS NOT NULL
  AND code IS NOT NULL
  AND tipo IS NOT NULL;

SELECT '✅ Verificación 10: Integridad de datos' AS check_name;

-- ============================================
-- 11. RESUMEN FINAL
-- ============================================

SELECT
    '=====================================' AS separador
UNION ALL
SELECT '📊 RESUMEN DE VERIFICACIÓN COMPLETA'
UNION ALL
SELECT '====================================='
UNION ALL
SELECT CONCAT('✅ Tablas: ',
    (SELECT COUNT(*)::text
     FROM information_schema.tables
     WHERE table_schema = 'public'
       AND table_type = 'BASE TABLE'))
UNION ALL
SELECT CONCAT('✅ Funciones: ',
    (SELECT COUNT(*)::text
     FROM information_schema.routines
     WHERE routine_schema = 'public'))
UNION ALL
SELECT CONCAT('✅ Índices: ',
    (SELECT COUNT(DISTINCT indexname)::text
     FROM pg_indexes
     WHERE schemaname = 'public'))
UNION ALL
SELECT CONCAT('✅ Triggers: ',
    (SELECT COUNT(*)::text
     FROM information_schema.triggers
     WHERE trigger_schema = 'public'))
UNION ALL
SELECT CONCAT('✅ Foreign Keys: ',
    (SELECT COUNT(*)::text
     FROM information_schema.table_constraints
     WHERE constraint_schema = 'public'
       AND constraint_type = 'FOREIGN KEY'))
UNION ALL
SELECT '-------------------------------------'
UNION ALL
SELECT CONCAT('📦 Instituciones: ',
    (SELECT COUNT(*)::text FROM instituciones WHERE is_active = true))
UNION ALL
SELECT CONCAT('🏥 Centros: ',
    (SELECT COUNT(*)::text FROM centros_salud WHERE is_active = true))
UNION ALL
SELECT CONCAT('💊 Medicamentos: ',
    (SELECT COUNT(*)::text FROM catalogo_medicamentos WHERE is_active = true))
UNION ALL
SELECT CONCAT('🏭 Proveedores: ',
    (SELECT COUNT(*)::text FROM proveedores WHERE is_active = true))
UNION ALL
SELECT '====================================='
UNION ALL
SELECT '✅ VERIFICACIÓN COMPLETADA'
UNION ALL
SELECT '=====================================';

-- ============================================
-- 12. QUERIES ÚTILES ADICIONALES
-- ============================================

-- Ver primeros 5 medicamentos
SELECT
    codigo_medicamento,
    nombre_generico,
    forma_farmaceutica,
    concentracion,
    precio_unitario
FROM catalogo_medicamentos
WHERE is_active = true
ORDER BY codigo_medicamento
LIMIT 5;

-- Ver todos los centros penitenciarios
SELECT
    code,
    name,
    tipo,
    municipio,
    is_active
FROM centros_salud
ORDER BY code;

-- Ver estructura de una tabla específica
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'catalogo_medicamentos'
ORDER BY ordinal_position;

-- ============================================
-- INSTRUCCIONES FINALES
-- ============================================

/*
Si TODAS las verificaciones muestran ✅ CORRECTO:
1. La base de datos está lista para usar
2. Puedes proceder a configurar RLS y autenticación
3. Puedes comenzar a cargar datos adicionales

Si alguna verificación muestra ❌:
1. Revisa los mensajes de error del script principal
2. Verifica que ejecutaste TODO el script
3. Intenta ejecutar el script nuevamente (es idempotente)
4. Si persiste el error, comparte el mensaje completo

PRÓXIMOS PASOS:
1. Configurar Row Level Security (RLS)
2. Crear usuarios administradores
3. Configurar autenticación
4. Cargar datos adicionales de prueba
5. Probar las funcionalidades
*/

SELECT '✅ SCRIPT DE VERIFICACIÓN COMPLETADO' AS resultado_final;
