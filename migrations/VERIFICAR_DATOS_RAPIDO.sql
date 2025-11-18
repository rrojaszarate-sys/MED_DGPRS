-- ============================================
-- VERIFICACIÓN RÁPIDA DE DATOS
-- ============================================

SELECT 'INSTITUCIONES' as tabla, COUNT(*) as total FROM instituciones
UNION ALL
SELECT 'CENTROS DE SALUD', COUNT(*) FROM centros_salud
UNION ALL
SELECT 'CATÁLOGO MEDICAMENTOS', COUNT(*) FROM catalogo_medicamentos
UNION ALL
SELECT 'PROVEEDORES', COUNT(*) FROM proveedores
UNION ALL
SELECT 'CONFIGURACIÓN GS1', COUNT(*) FROM gs1_configuracion_empresa
UNION ALL
SELECT 'PERFILES USUARIO', COUNT(*) FROM perfiles_usuario
UNION ALL
SELECT 'LOTES', COUNT(*) FROM lotes
UNION ALL
SELECT 'MOVIMIENTOS', COUNT(*) FROM movimientos_lotes;

-- Ver los primeros 5 centros
SELECT 'PRIMEROS 5 CENTROS:' as info;
SELECT code, name, tipo, is_active
FROM centros_salud
ORDER BY name
LIMIT 5;

-- Ver los primeros 5 medicamentos
SELECT 'PRIMEROS 5 MEDICAMENTOS:' as info;
SELECT clave_cuadro, nombre, forma_farmaceutica, precio_unitario
FROM catalogo_medicamentos
ORDER BY nombre
LIMIT 5;
