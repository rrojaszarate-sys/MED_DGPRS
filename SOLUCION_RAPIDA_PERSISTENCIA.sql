-- ============================================
-- SOLUCIÓN RÁPIDA - PERMITIR PERSISTENCIA INMEDIATA
-- ============================================
-- Fecha: 2025-11-10
-- Problema: INSERT bloqueado por RLS sin políticas
-- Solución: Políticas permisivas temporales
--
-- ⚠️ EJECUTAR ESTO PRIMERO EN SUPABASE SQL EDITOR
-- ⚠️ Luego ejecutar FIX_CRITICAL_ERRORS.sql completo
-- ============================================

\echo '🚀 APLICANDO SOLUCIÓN RÁPIDA...'

BEGIN;

-- ============================================
-- OPCIÓN A: POLÍTICAS PERMISIVAS TEMPORALES
-- ============================================

\echo '
========================================
🔧 Creando políticas permisivas temporales
========================================
'

-- Habilitar RLS si no está habilitado
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas anteriores si existen
DROP POLICY IF EXISTS "medication_catalog_select_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update_policy" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete_policy" ON medication_catalog;

-- POLÍTICA SELECT: Todos pueden ver (autenticados)
CREATE POLICY "medication_catalog_select_policy" ON medication_catalog
  FOR SELECT
  USING (auth.role() = 'authenticated' OR auth.role() = 'anon');

\echo '  ✓ Política SELECT creada (todos pueden ver)'

-- POLÍTICA INSERT: Todos los usuarios autenticados pueden insertar
CREATE POLICY "medication_catalog_insert_policy" ON medication_catalog
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

\echo '  ✓ Política INSERT creada (autenticados pueden crear)'

-- POLÍTICA UPDATE: Todos los usuarios autenticados pueden actualizar
CREATE POLICY "medication_catalog_update_policy" ON medication_catalog
  FOR UPDATE
  USING (auth.role() = 'authenticated');

\echo '  ✓ Política UPDATE creada (autenticados pueden actualizar)'

-- POLÍTICA DELETE: Todos los usuarios autenticados pueden eliminar
CREATE POLICY "medication_catalog_delete_policy" ON medication_catalog
  FOR DELETE
  USING (auth.role() = 'authenticated');

\echo '  ✓ Política DELETE creada (autenticados pueden eliminar)'

COMMIT;

\echo ''
\echo '========================================
✅ SOLUCIÓN RÁPIDA APLICADA
========================================
'

-- Verificar políticas creadas
SELECT
  '📋 Políticas creadas:' as resultado,
  count(*) as total_politicas
FROM pg_policies
WHERE tablename = 'medication_catalog';

SELECT
  policyname,
  cmd as operacion,
  '✓' as estado
FROM pg_policies
WHERE tablename = 'medication_catalog'
ORDER BY cmd;

\echo '
========================================
🧪 PRUEBA INMEDIATA
========================================
'

-- Intentar insertar medicamento de prueba
DO $$
BEGIN
  INSERT INTO medication_catalog (
    codigo_medicamento,
    nombre_generico,
    nombre_comercial,
    forma_farmaceutica,
    via_administracion,
    unidad_medida,
    categoria,
    requiere_receta,
    controlado,
    is_active
  ) VALUES (
    'PRUEBA-RAPIDA-001',
    'Medicamento de Prueba Rápida',
    'TestFarm Express',
    'Tableta',
    'Oral',
    'Caja',
    'Prueba',
    false,
    false,
    true
  );

  RAISE NOTICE '✅ INSERT exitoso: Medicamento de prueba creado';
  RAISE NOTICE '📊 Verificando persistencia...';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE '❌ INSERT falló: %', SQLERRM;
END $$;

-- Verificar que se guardó
SELECT
  '🔍 Verificación:' as prueba,
  count(*) as medicamentos_encontrados,
  CASE
    WHEN count(*) > 0 THEN '✅ ¡PERSISTENCIA FUNCIONA!'
    ELSE '❌ Aún no persiste, revisar logs'
  END as resultado
FROM medication_catalog
WHERE codigo_medicamento = 'PRUEBA-RAPIDA-001';

-- Mostrar el medicamento creado
SELECT
  codigo_medicamento,
  nombre_generico,
  created_at as fecha_creacion
FROM medication_catalog
WHERE codigo_medicamento = 'PRUEBA-RAPIDA-001';

-- Eliminar medicamento de prueba
DELETE FROM medication_catalog WHERE codigo_medicamento = 'PRUEBA-RAPIDA-001';

\echo ''
\echo '========================================
📝 PRÓXIMOS PASOS
========================================

1. ✅ Solución rápida aplicada (políticas permisivas)
2. → Probar crear medicamento en: https://[tu-dominio]/admin
3. → Debería aparecer mensaje: "Medicamento agregado al catálogo"
4. → Recargar página F5
5. → Medicamento DEBE seguir apareciendo (persistencia OK)
6. → Si persiste correctamente, continuar a paso 7
7. → Ejecutar FIX_CRITICAL_ERRORS.sql para políticas robustas
8. → Ejecutar CARGA_MEDICAMENTOS_CSV.sql para los 101 medicamentos

========================================
⚠️ IMPORTANTE
========================================

Esta solución es TEMPORAL y PERMISIVA.
Todos los usuarios autenticados pueden:
  - Ver medicamentos
  - Crear medicamentos
  - Actualizar medicamentos
  - Eliminar medicamentos

Para producción REAL, ejecuta FIX_CRITICAL_ERRORS.sql
que implementa políticas basadas en roles.

Pero para AHORA, esto desbloquea el sistema.

========================================
🆘 SI AÚN NO PERSISTE
========================================

1. Verificar autenticación:
   SELECT auth.uid(), auth.role();
   -- Debe retornar tu user_id y ''authenticated''

2. Verificar RLS habilitado:
   SELECT rowsecurity FROM pg_tables
   WHERE tablename = ''medication_catalog'';
   -- Debe retornar: true

3. Ver logs de error en Supabase:
   Dashboard → Logs → Postgres Logs
   Buscar: "permission denied" o "policy violation"

4. Si todo falla, deshabilitar RLS temporalmente:
   ALTER TABLE medication_catalog DISABLE ROW LEVEL SECURITY;
   -- Luego investigar por qué falla

========================================
'

-- FIN DE LA SOLUCIÓN RÁPIDA
