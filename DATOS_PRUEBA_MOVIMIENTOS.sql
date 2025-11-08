-- ============================================
-- SCRIPT DE MOVIMIENTOS DE PRUEBA - SIGIMED
-- ============================================
-- Este script genera movimientos de lote para probar la trazabilidad
-- REQUISITO: Ejecutar DATOS_PRUEBA.sql primero
-- REQUISITO: Tener un usuario autenticado en Supabase
-- ============================================

-- IMPORTANTE: Reemplazar este UUID con el ID de tu usuario actual
-- Obtén tu user ID ejecutando: SELECT auth.uid();
-- O usa: SELECT id FROM auth.users LIMIT 1;

DO $$
DECLARE
  v_user_id UUID;
  v_hospital_id UUID := '11111111-1111-1111-1111-111111111111';
  v_centro_norte_id UUID := '22222222-2222-2222-2222-222222222222';
  v_posta_sur_id UUID := '33333333-3333-3333-3333-333333333333';
  v_result JSONB;
BEGIN
  -- Obtener el primer usuario disponible
  SELECT id INTO v_user_id FROM auth.users ORDER BY created_at DESC LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️  No hay usuarios en auth.users. Por favor crea un usuario primero.';
    RAISE NOTICE '   Puedes crearlo desde Supabase Dashboard -> Authentication -> Users';
    RETURN;
  END IF;

  RAISE NOTICE '✅ Usuario encontrado: %', v_user_id;
  RAISE NOTICE '📦 Generando movimientos de prueba...';

  -- ============================================
  -- MOVIMIENTOS DE ENTRADA (Compras/Recepciones)
  -- ============================================

  -- Entrada de Paracetamol al Hospital Central
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd3333-dddd-3333-dddd-333333333333',
    p_tipo_movimiento := 'entrada',
    p_cantidad := 500,
    p_motivo := 'Compra a proveedor Farmacéutica Global',
    p_usuario_responsable := v_user_id,
    p_centro_destino_id := v_hospital_id,
    p_numero_documento := 'FC-2024-001',
    p_observaciones := 'Primera compra del año - Lote de alta rotación',
    p_metadata := '{"proveedor": "Farmacéutica Global", "orden_compra": "OC-2024-0123"}'::jsonb
  );
  RAISE NOTICE '  ✓ Entrada Paracetamol: % unidades', (v_result->>'cantidad_final')::integer;

  -- Entrada de Metformina al Hospital Central
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd7777-dddd-7777-dddd-777777777777',
    p_tipo_movimiento := 'entrada',
    p_cantidad := 300,
    p_motivo := 'Compra trimestral programada',
    p_usuario_responsable := v_user_id,
    p_centro_destino_id := v_hospital_id,
    p_numero_documento := 'FC-2024-002',
    p_observaciones := 'Stock para programa de pacientes diabéticos',
    p_metadata := '{"programa": "diabetes", "urgencia": "normal"}'::jsonb
  );
  RAISE NOTICE '  ✓ Entrada Metformina: % unidades', (v_result->>'cantidad_final')::integer;

  -- ============================================
  -- MOVIMIENTOS DE SALIDA (Dispensaciones)
  -- ============================================

  -- Salida de Amoxicilina por dispensación
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd1111-dddd-1111-dddd-111111111111',
    p_tipo_movimiento := 'salida',
    p_cantidad := 100,
    p_motivo := 'Dispensación a pacientes ambulatorios',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_numero_documento := 'DISP-2024-045',
    p_observaciones := 'Tratamientos de infecciones respiratorias',
    p_metadata := '{"tipo_atencion": "ambulatorio", "total_pacientes": 20}'::jsonb
  );
  RAISE NOTICE '  ✓ Salida Amoxicilina: % unidades', (v_result->>'cantidad_final')::integer;

  -- Salida de Paracetamol
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd3333-dddd-3333-dddd-333333333333',
    p_tipo_movimiento := 'salida',
    p_cantidad := 800,
    p_motivo := 'Dispensación masiva emergencia',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_numero_documento := 'DISP-2024-046',
    p_observaciones := 'Campaña de salud comunitaria',
    p_metadata := '{"evento": "campaña_salud", "comunidad": "San Juan"}'::jsonb
  );
  RAISE NOTICE '  ✓ Salida Paracetamol: % unidades', (v_result->>'cantidad_final')::integer;

  -- Salida de Insulina (medicamento refrigerado)
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd8888-dddd-8888-dddd-888888888888',
    p_tipo_movimiento := 'salida',
    p_cantidad := 5,
    p_motivo := 'Dispensación programa diabetes',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_numero_documento := 'DISP-2024-047',
    p_observaciones := 'Pacientes con receta médica',
    p_metadata := '{"programa": "diabetes_tipo1", "refrigerado": true}'::jsonb
  );
  RAISE NOTICE '  ✓ Salida Insulina: % unidades', (v_result->>'cantidad_final')::integer;

  -- ============================================
  -- AJUSTES DE INVENTARIO
  -- ============================================

  -- Ajuste por diferencia en inventario físico
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd4444-dddd-4444-dddd-444444444444',
    p_tipo_movimiento := 'ajuste',
    p_cantidad := -10,
    p_motivo := 'Diferencia encontrada en inventario físico mensual',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_numero_documento := 'INV-2024-11',
    p_observaciones := 'Auditoría mensual - Se encontraron 10 unidades menos',
    p_metadata := '{"tipo_ajuste": "faltante", "auditoria": "mensual", "mes": "noviembre"}'::jsonb
  );
  RAISE NOTICE '  ✓ Ajuste Ibuprofeno: % unidades', (v_result->>'cantidad_final')::integer;

  -- Ajuste positivo por recuperación
  v_result := registrar_movimiento_lote(
    p_medication_id := 'ddddaaaa-dddd-aaaa-dddd-aaaaaaaaaaaa',
    p_tipo_movimiento := 'ajuste',
    p_cantidad := 20,
    p_motivo := 'Recuperación de unidades mal registradas',
    p_usuario_responsable := v_user_id,
    p_centro_destino_id := v_hospital_id,
    p_numero_documento := 'INV-2024-12',
    p_observaciones := 'Se encontraron unidades que no estaban en sistema',
    p_metadata := '{"tipo_ajuste": "sobrante", "origen": "error_registro"}'::jsonb
  );
  RAISE NOTICE '  ✓ Ajuste Complejo B: % unidades', (v_result->>'cantidad_final')::integer;

  -- ============================================
  -- TRANSFERENCIAS ENTRE CENTROS
  -- ============================================

  -- Transferencia de Hospital Central a Centro Norte
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd3333-dddd-3333-dddd-333333333333',
    p_tipo_movimiento := 'transferencia_salida',
    p_cantidad := 200,
    p_motivo := 'Transferencia por stock bajo en Centro Norte',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_centro_destino_id := v_centro_norte_id,
    p_numero_documento := 'TRANS-2024-001',
    p_observaciones := 'Transferencia urgente por desabastecimiento',
    p_metadata := '{"urgencia": "alta", "tipo": "desabastecimiento"}'::jsonb
  );
  RAISE NOTICE '  ✓ Transferencia Salida Paracetamol: % unidades restantes', (v_result->>'cantidad_final')::integer;

  -- Nota: La transferencia_entrada se debe registrar en el centro destino
  -- Por ahora solo registramos la salida

  -- ============================================
  -- VENCIMIENTOS Y MERMAS
  -- ============================================

  -- Retiro por vencimiento
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd5555-dddd-5555-dddd-555555555555',
    p_tipo_movimiento := 'vencimiento',
    p_cantidad := 30,
    p_motivo := 'Medicamento próximo a vencer - Retiro preventivo',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_numero_documento := 'VEN-2024-001',
    p_observaciones := 'Losartán lote TEST-LOS-2023-005 vence en 15 días',
    p_metadata := '{"fecha_vencimiento": "2024-11-23", "accion": "retiro_preventivo"}'::jsonb
  );
  RAISE NOTICE '  ✓ Vencimiento Losartán: % unidades restantes', (v_result->>'cantidad_final')::integer;

  -- Merma por daño
  v_result := registrar_movimiento_lote(
    p_medication_id := 'dddd9999-dddd-9999-dddd-999999999999',
    p_tipo_movimiento := 'merma',
    p_cantidad := 5,
    p_motivo := 'Envases dañados durante almacenamiento',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_hospital_id,
    p_numero_documento := 'MERMA-2024-003',
    p_observaciones := 'Frascos de jarabe con tapa rota - No aptos para dispensación',
    p_metadata := '{"causa": "daño_envase", "tipo_daño": "tapa_rota"}'::jsonb
  );
  RAISE NOTICE '  ✓ Merma Ambroxol: % unidades restantes', (v_result->>'cantidad_final')::integer;

  -- ============================================
  -- MOVIMIENTOS EN OTROS CENTROS
  -- ============================================

  -- Salida de Paracetamol en Centro Norte
  v_result := registrar_movimiento_lote(
    p_medication_id := 'eeee1111-eeee-1111-eeee-111111111111',
    p_tipo_movimiento := 'salida',
    p_cantidad := 150,
    p_motivo := 'Dispensación semanal normal',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_centro_norte_id,
    p_numero_documento := 'DISP-CN-2024-020',
    p_observaciones := 'Dispensación rutinaria',
    p_metadata := '{"centro": "norte", "periodo": "semanal"}'::jsonb
  );
  RAISE NOTICE '  ✓ Salida Paracetamol Centro Norte: % unidades', (v_result->>'cantidad_final')::integer;

  -- Salida de Paracetamol en Posta Sur
  v_result := registrar_movimiento_lote(
    p_medication_id := 'ffff1111-ffff-1111-ffff-111111111111',
    p_tipo_movimiento := 'salida',
    p_cantidad := 40,
    p_motivo := 'Dispensación a pacientes',
    p_usuario_responsable := v_user_id,
    p_centro_origen_id := v_posta_sur_id,
    p_numero_documento := 'DISP-PS-2024-010',
    p_observaciones := 'Atención ambulatoria',
    p_metadata := '{"centro": "sur", "tipo": "ambulatorio"}'::jsonb
  );
  RAISE NOTICE '  ✓ Salida Paracetamol Posta Sur: % unidades', (v_result->>'cantidad_final')::integer;

  RAISE NOTICE '';
  RAISE NOTICE '🎉 ¡Movimientos de prueba generados exitosamente!';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Resumen:';
  RAISE NOTICE '   • Entradas: 2 movimientos';
  RAISE NOTICE '   • Salidas: 6 movimientos';
  RAISE NOTICE '   • Ajustes: 2 movimientos';
  RAISE NOTICE '   • Transferencias: 1 movimiento';
  RAISE NOTICE '   • Vencimientos: 1 movimiento';
  RAISE NOTICE '   • Mermas: 1 movimiento';
  RAISE NOTICE '   • TOTAL: 13 movimientos registrados';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Ahora puedes probar:';
  RAISE NOTICE '   1. Reportes de trazabilidad en la interfaz web';
  RAISE NOTICE '   2. Búsqueda avanzada de inventario';
  RAISE NOTICE '   3. Consultar movimientos por lote';
  RAISE NOTICE '   4. Ver historial de auditoría';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Error: %', SQLERRM;
    RAISE NOTICE '💡 Posibles causas:';
    RAISE NOTICE '   • La función registrar_movimiento_lote() no existe (ejecuta MIGRATION_SQL_FINAL.sql)';
    RAISE NOTICE '   • Los medicamentos de prueba no existen (ejecuta DATOS_PRUEBA.sql primero)';
    RAISE NOTICE '   • Permisos insuficientes';
    RAISE;
END $$;

-- ============================================
-- VERIFICACIÓN DE MOVIMIENTOS CREADOS
-- ============================================

SELECT
  '✅ MOVIMIENTOS REGISTRADOS' as status,
  COUNT(*) as total_movimientos
FROM batch_movements
WHERE created_at >= NOW() - INTERVAL '5 minutes';

-- Detalle de movimientos por tipo
SELECT
  tipo_movimiento,
  COUNT(*) as cantidad,
  SUM(cantidad) as unidades_totales
FROM batch_movements
WHERE created_at >= NOW() - INTERVAL '5 minutes'
GROUP BY tipo_movimiento
ORDER BY cantidad DESC;

-- Últimos 10 movimientos
SELECT
  bm.created_at::timestamp(0) as fecha,
  hc.name as centro,
  m.nombre as medicamento,
  bm.tipo_movimiento,
  bm.cantidad,
  bm.cantidad_anterior || ' → ' || bm.cantidad_posterior as cambio_stock,
  bm.motivo
FROM batch_movements bm
INNER JOIN medications m ON bm.medication_id = m.id
INNER JOIN health_centers hc ON m.center_id = hc.id
WHERE bm.created_at >= NOW() - INTERVAL '5 minutes'
ORDER BY bm.created_at DESC
LIMIT 10;
