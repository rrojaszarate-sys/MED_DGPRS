-- ============================================
-- SCRIPT DE RESET (BORRAR FUNCIONALIDADES)
-- ============================================
-- ⚠️  ADVERTENCIA: Este script ELIMINA DATOS
-- Solo ejecutar si quieres borrar las funcionalidades avanzadas
-- ============================================

BEGIN;

-- Mostrar advertencia
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  ⚠️  ⚠️  ADVERTENCIA  ⚠️  ⚠️  ⚠️';
  RAISE NOTICE 'Este script va a ELIMINAR:';
  RAISE NOTICE '- Todos los movimientos de lotes (batch_movements)';
  RAISE NOTICE '- Triggers de auditoría automática';
  RAISE NOTICE '- Funciones SQL avanzadas';
  RAISE NOTICE '';
  RAISE NOTICE 'Presiona Ctrl+C AHORA para cancelar';
  RAISE NOTICE 'O espera 5 segundos para continuar...';
  RAISE NOTICE '';

  PERFORM pg_sleep(5);
END $$;

-- Eliminar políticas RLS
DROP POLICY IF EXISTS "Users can view movements from their centers" ON batch_movements;
DROP POLICY IF EXISTS "System can insert movements" ON batch_movements;
DROP POLICY IF EXISTS "Admins can view audit logs" ON audit_log;
DROP POLICY IF EXISTS "System can insert audit logs" ON audit_log;

-- Eliminar triggers
DROP TRIGGER IF EXISTS audit_medications ON medications;
DROP TRIGGER IF EXISTS audit_users_profiles ON users_profiles;
DROP TRIGGER IF EXISTS audit_health_centers ON health_centers;
DROP TRIGGER IF EXISTS audit_medication_catalog ON medication_catalog;
DROP TRIGGER IF EXISTS audit_transfers ON transfers;

-- Eliminar funciones
DROP FUNCTION IF EXISTS registrar_movimiento_lote;
DROP FUNCTION IF EXISTS generate_traceability_report;
DROP FUNCTION IF EXISTS search_inventory_with_batches;
DROP FUNCTION IF EXISTS audit_trigger_func CASCADE;

-- Eliminar tabla batch_movements (y todos sus datos)
DROP TABLE IF EXISTS batch_movements CASCADE;

-- Deshabilitar RLS en audit_log (la tabla ya existía, solo la deshabilitamos)
ALTER TABLE audit_log DISABLE ROW LEVEL SECURITY;

COMMIT;

-- Verificación
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'RESET COMPLETADO';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Se han eliminado:';
  RAISE NOTICE '✅ Tabla batch_movements';
  RAISE NOTICE '✅ 5 Triggers de auditoría';
  RAISE NOTICE '✅ 4 Funciones SQL';
  RAISE NOTICE '✅ Políticas RLS';
  RAISE NOTICE '';
  RAISE NOTICE 'Ahora puedes ejecutar MIGRATION_SQL_FINAL.sql';
  RAISE NOTICE 'para instalar de nuevo desde cero.';
  RAISE NOTICE '============================================';
  RAISE NOTICE '';
END $$;
