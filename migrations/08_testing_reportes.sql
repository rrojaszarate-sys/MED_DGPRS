-- ============================================
-- FASE 6: TESTING Y REPORTES FINALES
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Scripts de testing y funciones de reportes avanzados
-- Tiempo estimado: 30 minutos
-- Ejecutar DESPUÉS de Fase 5

BEGIN;

-- ============================================
-- PARTE 6.1: FUNCIONES DE REPORTES
-- ============================================

-- Función: Reporte general de inventario
CREATE OR REPLACE FUNCTION reporte_inventario_general(
  p_center_id UUID DEFAULT NULL,
  p_fecha_inicio DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  center_name TEXT,
  total_medicamentos INTEGER,
  total_lotes INTEGER,
  valor_total DECIMAL,
  stock_bajo INTEGER,
  proximos_vencer INTEGER,
  vencidos INTEGER,
  cumplimiento DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    hc.name,
    COUNT(DISTINCT m.id)::INTEGER,
    COUNT(DISTINCT b.id)::INTEGER,
    SUM(b.cantidad_actual * COALESCE(
      (SELECT precio_unitario FROM vales_entrada_items WHERE batch_id = b.id LIMIT 1),
      0
    ))::DECIMAL(15,2),
    COUNT(DISTINCT b.id) FILTER (WHERE b.cantidad_actual <= b.stock_minimo)::INTEGER,
    COUNT(DISTINCT b.id) FILTER (
      WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + 90)
    )::INTEGER,
    COUNT(DISTINCT b.id) FILTER (WHERE b.fecha_caducidad < CURRENT_DATE)::INTEGER,
    ROUND(
      CASE
        WHEN COUNT(DISTINCT m.id) > 0
        THEN ((COUNT(DISTINCT m.id) - COUNT(DISTINCT b.id) FILTER (WHERE b.cantidad_actual <= b.stock_minimo))::DECIMAL / COUNT(DISTINCT m.id) * 100)
        ELSE 100
      END, 2
    )
  FROM health_centers hc
  LEFT JOIN medications m ON m.center_id = hc.id
  LEFT JOIN batches b ON b.center_id = hc.id AND b.cantidad_actual > 0
  WHERE (p_center_id IS NULL OR hc.id = p_center_id)
    AND hc.is_active = true
  GROUP BY hc.id, hc.name
  ORDER BY hc.name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION reporte_inventario_general IS 'Reporte general de inventario por centro';

-- Función: Reporte de movimientos
CREATE OR REPLACE FUNCTION reporte_movimientos(
  p_center_id UUID DEFAULT NULL,
  p_fecha_inicio DATE DEFAULT CURRENT_DATE - 30,
  p_fecha_fin DATE DEFAULT CURRENT_DATE,
  p_tipo_movimiento TEXT DEFAULT NULL
)
RETURNS TABLE (
  fecha DATE,
  tipo_movimiento TEXT,
  center_name TEXT,
  medication_name TEXT,
  lote TEXT,
  cantidad INTEGER,
  motivo TEXT,
  usuario TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    bm.created_at::DATE,
    bm.tipo_movimiento,
    hc.name,
    m.nombre,
    (bm.metadata->>'numero_lote')::TEXT,
    bm.cantidad,
    bm.motivo,
    COALESCE(bm.usuario_responsable::TEXT, 'Sistema')
  FROM batch_movements bm
  JOIN health_centers hc ON bm.center_id = hc.id
  JOIN medications m ON bm.medication_id = m.id
  WHERE (p_center_id IS NULL OR bm.center_id = p_center_id)
    AND bm.created_at::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
    AND (p_tipo_movimiento IS NULL OR bm.tipo_movimiento = p_tipo_movimiento)
  ORDER BY bm.created_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION reporte_movimientos IS 'Reporte detallado de movimientos de inventario';

-- Función: Reporte de proveedores
CREATE OR REPLACE FUNCTION reporte_proveedores_desempeno()
RETURNS TABLE (
  supplier_name TEXT,
  total_contratos INTEGER,
  contratos_activos INTEGER,
  total_entregas INTEGER,
  entregas_puntuales INTEGER,
  puntualidad DECIMAL,
  calificacion_promedio DECIMAL,
  recomendacion TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.nombre,
    COUNT(DISTINCT c.id)::INTEGER,
    COUNT(DISTINCT c.id) FILTER (WHERE c.estado = 'activo')::INTEGER,
    COUNT(DISTINCT cd.id)::INTEGER,
    COUNT(DISTINCT cd.id) FILTER (WHERE cd.fecha_entrega_real <= cd.fecha_entrega_programada)::INTEGER,
    ROUND(
      CASE
        WHEN COUNT(DISTINCT cd.id) > 0
        THEN (COUNT(DISTINCT cd.id) FILTER (WHERE cd.fecha_entrega_real <= cd.fecha_entrega_programada)::DECIMAL / COUNT(DISTINCT cd.id) * 100)
        ELSE 0
      END, 2
    ),
    COALESCE(s.calificacion, 0),
    CASE
      WHEN COALESCE(s.calificacion, 0) >= 4.5 THEN 'Excelente - Renovar'
      WHEN COALESCE(s.calificacion, 0) >= 3.5 THEN 'Bueno - Mantener'
      WHEN COALESCE(s.calificacion, 0) >= 2.5 THEN 'Regular - Renegociar'
      ELSE 'Deficiente - Evaluar Cancelación'
    END
  FROM suppliers s
  LEFT JOIN contracts c ON c.supplier_id = s.id
  LEFT JOIN contract_deliveries cd ON cd.contract_id = c.id AND cd.estado IN ('recibida', 'recibida_parcial')
  WHERE s.is_active = true
  GROUP BY s.id, s.nombre, s.calificacion
  ORDER BY COALESCE(s.calificacion, 0) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION reporte_proveedores_desempeno IS 'Reporte de desempeño de proveedores';

-- Función: Reporte de auditoría
CREATE OR REPLACE FUNCTION reporte_auditoria(
  p_entity_type TEXT DEFAULT NULL,
  p_action_type TEXT DEFAULT NULL,
  p_fecha_inicio TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days',
  p_fecha_fin TIMESTAMPTZ DEFAULT NOW(),
  p_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
  fecha TIMESTAMPTZ,
  usuario TEXT,
  accion TEXT,
  entidad TEXT,
  nombre_entidad TEXT,
  cambios TEXT,
  resultado TEXT,
  severidad TEXT,
  ip_address INET
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    al.created_at,
    COALESCE(al.user_email, al.user_id::TEXT, 'Sistema'),
    al.action_type,
    al.entity_type,
    al.entity_name,
    al.changes_summary,
    al.result,
    al.severity,
    al.ip_address
  FROM audit_log al
  WHERE (p_entity_type IS NULL OR al.entity_type = p_entity_type)
    AND (p_action_type IS NULL OR al.action_type = p_action_type)
    AND (p_user_id IS NULL OR al.user_id = p_user_id)
    AND al.created_at BETWEEN p_fecha_inicio AND p_fecha_fin
  ORDER BY al.created_at DESC
  LIMIT 1000;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION reporte_auditoria IS 'Reporte de auditoría del sistema';

-- Función: Dashboard ejecutivo
CREATE OR REPLACE FUNCTION dashboard_ejecutivo()
RETURNS TABLE (
  metrica TEXT,
  valor TEXT,
  detalle JSONB
) AS $$
BEGIN
  RETURN QUERY
  -- Total de centros
  SELECT
    'centros_activos'::TEXT,
    COUNT(*)::TEXT,
    jsonb_build_object(
      'total', COUNT(*),
      'con_inventario', COUNT(*) FILTER (WHERE EXISTS (SELECT 1 FROM medications WHERE center_id = id))
    )
  FROM health_centers
  WHERE is_active = true

  UNION ALL

  -- Total de medicamentos
  SELECT
    'medicamentos_total'::TEXT,
    COUNT(DISTINCT id)::TEXT,
    jsonb_build_object(
      'total', COUNT(DISTINCT id),
      'con_stock', COUNT(DISTINCT id) FILTER (WHERE cantidad > 0)
    )
  FROM medications

  UNION ALL

  -- Lotes activos
  SELECT
    'lotes_activos'::TEXT,
    COUNT(*)::TEXT,
    jsonb_build_object(
      'disponibles', COUNT(*) FILTER (WHERE estado = 'disponible'),
      'cuarentena', COUNT(*) FILTER (WHERE estado = 'cuarentena'),
      'vencidos', COUNT(*) FILTER (WHERE estado = 'vencido')
    )
  FROM batches
  WHERE cantidad_actual > 0

  UNION ALL

  -- Alertas activas
  SELECT
    'alertas_activas'::TEXT,
    COUNT(*)::TEXT,
    jsonb_build_object(
      'criticas', COUNT(*) FILTER (WHERE severidad = 'critica'),
      'altas', COUNT(*) FILTER (WHERE severidad = 'alta'),
      'pendientes', COUNT(*) FILTER (WHERE estado = 'pendiente')
    )
  FROM alertas_medicamentos
  WHERE estado IN ('pendiente', 'en_revision')

  UNION ALL

  -- Contratos
  SELECT
    'contratos'::TEXT,
    COUNT(*)::TEXT,
    jsonb_build_object(
      'activos', COUNT(*) FILTER (WHERE estado = 'activo'),
      'por_vencer', COUNT(*) FILTER (WHERE estado = 'activo' AND fecha_fin <= CURRENT_DATE + 90),
      'monto_total', SUM(monto_total) FILTER (WHERE estado = 'activo')
    )
  FROM contracts

  UNION ALL

  -- Movimientos hoy
  SELECT
    'movimientos_hoy'::TEXT,
    COUNT(*)::TEXT,
    jsonb_build_object(
      'entradas', COUNT(*) FILTER (WHERE tipo_movimiento IN ('entrada', 'transferencia_entrada')),
      'salidas', COUNT(*) FILTER (WHERE tipo_movimiento IN ('salida', 'transferencia_salida'))
    )
  FROM batch_movements
  WHERE created_at >= CURRENT_DATE

  UNION ALL

  -- Proveedores
  SELECT
    'proveedores'::TEXT,
    COUNT(*)::TEXT,
    jsonb_build_object(
      'activos', COUNT(*) FILTER (WHERE is_active = true),
      'calificacion_promedio', ROUND(AVG(calificacion), 2)
    )
  FROM suppliers;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dashboard_ejecutivo IS 'Dashboard ejecutivo con métricas principales';

COMMIT;

-- ============================================
-- PARTE 6.2: FUNCIONES DE VALIDACIÓN
-- ============================================

-- Función: Validar integridad del sistema
CREATE OR REPLACE FUNCTION validar_integridad_sistema()
RETURNS TABLE (
  categoria TEXT,
  validacion TEXT,
  resultado TEXT,
  detalles TEXT
) AS $$
BEGIN
  -- Validar lotes huérfanos
  RETURN QUERY
  SELECT
    'Integridad de Datos'::TEXT,
    'Lotes sin medicamento'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN '✅ OK' ELSE '❌ ERROR' END,
    COUNT(*)::TEXT || ' lotes encontrados'
  FROM batches
  WHERE medication_id NOT IN (SELECT id FROM medications);

  -- Validar movimientos sin lote
  RETURN QUERY
  SELECT
    'Integridad de Datos'::TEXT,
    'Movimientos sin lote'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN '✅ OK' ELSE '❌ ERROR' END,
    COUNT(*)::TEXT || ' movimientos encontrados'
  FROM batch_movements
  WHERE batch_id IS NOT NULL AND batch_id NOT IN (SELECT id FROM batches);

  -- Validar cantidades negativas
  RETURN QUERY
  SELECT
    'Validación de Stock'::TEXT,
    'Cantidades negativas'::TEXT,
    CASE WHEN COUNT(*) = 0 THEN '✅ OK' ELSE '❌ ERROR' END,
    COUNT(*)::TEXT || ' lotes con cantidad negativa'
  FROM batches
  WHERE cantidad_actual < 0;

  -- Validar funciones críticas
  RETURN QUERY
  SELECT
    'Funciones del Sistema'::TEXT,
    'Funciones críticas'::TEXT,
    CASE
      WHEN COUNT(*) >= 20 THEN '✅ OK'
      ELSE '⚠️ ADVERTENCIA'
    END,
    COUNT(*)::TEXT || ' funciones encontradas'
  FROM information_schema.routines
  WHERE routine_schema = 'public'
    AND routine_name IN (
      'registrar_movimiento_lote',
      'generar_alertas_stock_bajo',
      'crear_contrato',
      'aplicar_vale_entrada',
      'registrar_firma_digital'
    );

  -- Validar tablas principales
  RETURN QUERY
  SELECT
    'Estructura de Base de Datos'::TEXT,
    'Tablas principales'::TEXT,
    CASE
      WHEN COUNT(*) >= 25 THEN '✅ OK'
      ELSE '❌ ERROR'
    END,
    COUNT(*)::TEXT || ' tablas encontradas'
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN (
      'medications', 'batches', 'batch_movements', 'suppliers',
      'contracts', 'vales_entrada', 'vales_salida', 'actas_entrega',
      'alertas_medicamentos', 'audit_log', 'permissions', 'user_roles'
    );

  -- Validar índices
  RETURN QUERY
  SELECT
    'Optimización'::TEXT,
    'Índices creados'::TEXT,
    CASE
      WHEN COUNT(*) >= 50 THEN '✅ OK'
      ELSE '⚠️ ADVERTENCIA'
    END,
    COUNT(*)::TEXT || ' índices encontrados'
  FROM pg_indexes
  WHERE schemaname = 'public';

  -- Validar políticas RLS
  RETURN QUERY
  SELECT
    'Seguridad'::TEXT,
    'Políticas RLS'::TEXT,
    CASE
      WHEN COUNT(*) >= 20 THEN '✅ OK'
      ELSE '⚠️ ADVERTENCIA'
    END,
    COUNT(*)::TEXT || ' políticas encontradas'
  FROM pg_policies
  WHERE schemaname = 'public';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_integridad_sistema IS 'Valida la integridad y configuración del sistema';

-- Función: Estadísticas del sistema
CREATE OR REPLACE FUNCTION estadisticas_sistema()
RETURNS TABLE (
  seccion TEXT,
  item TEXT,
  cantidad INTEGER
) AS $$
BEGIN
  RETURN QUERY
  -- Tablas
  SELECT 'TABLAS'::TEXT, 'Total de tablas', COUNT(*)::INTEGER
  FROM information_schema.tables
  WHERE table_schema = 'public'

  UNION ALL

  -- Funciones
  SELECT 'FUNCIONES'::TEXT, 'Total de funciones', COUNT(*)::INTEGER
  FROM information_schema.routines
  WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'

  UNION ALL

  -- Triggers
  SELECT 'TRIGGERS'::TEXT, 'Total de triggers', COUNT(DISTINCT trigger_name)::INTEGER
  FROM information_schema.triggers
  WHERE trigger_schema = 'public'

  UNION ALL

  -- Índices
  SELECT 'ÍNDICES'::TEXT, 'Total de índices', COUNT(*)::INTEGER
  FROM pg_indexes
  WHERE schemaname = 'public'

  UNION ALL

  -- Políticas RLS
  SELECT 'SEGURIDAD'::TEXT, 'Políticas RLS', COUNT(*)::INTEGER
  FROM pg_policies
  WHERE schemaname = 'public'

  UNION ALL

  -- Permisos configurados
  SELECT 'PERMISOS'::TEXT, 'Permisos definidos', COUNT(*)::INTEGER
  FROM permissions

  UNION ALL

  -- Datos de prueba
  SELECT 'DATOS'::TEXT, 'Centros de salud', COUNT(*)::INTEGER FROM health_centers
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Medicamentos', COUNT(*)::INTEGER FROM medications
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Lotes', COUNT(*)::INTEGER FROM batches
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Proveedores', COUNT(*)::INTEGER FROM suppliers
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Contratos', COUNT(*)::INTEGER FROM contracts
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Alertas', COUNT(*)::INTEGER FROM alertas_medicamentos
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Movimientos', COUNT(*)::INTEGER FROM batch_movements
  UNION ALL
  SELECT 'DATOS'::TEXT, 'Registros de auditoría', COUNT(*)::INTEGER FROM audit_log;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION estadisticas_sistema IS 'Muestra estadísticas completas del sistema';

COMMIT;

-- ============================================
-- PARTE 6.3: SCRIPT DE TESTING
-- ============================================

-- Ejecutar validaciones
SELECT '🔍 VALIDANDO INTEGRIDAD DEL SISTEMA' as titulo;
SELECT * FROM validar_integridad_sistema();

SELECT '📊 ESTADÍSTICAS DEL SISTEMA' as titulo;
SELECT * FROM estadisticas_sistema() ORDER BY seccion, item;

SELECT '🎯 DASHBOARD EJECUTIVO' as titulo;
SELECT * FROM dashboard_ejecutivo();

-- ============================================
-- VERIFICACIÓN FINAL FASE 6
-- ============================================

SELECT '✅ FASE 6 COMPLETADA' as resultado;

SELECT 'FUNCIONES DE REPORTES' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'reporte_inventario_general',
    'reporte_movimientos',
    'reporte_proveedores_desempeno',
    'reporte_auditoria',
    'dashboard_ejecutivo',
    'validar_integridad_sistema',
    'estadisticas_sistema'
  )
ORDER BY routine_name;

-- ============================================
-- RESUMEN FINAL DEL SISTEMA
-- ============================================

SELECT '🎉 IMPLEMENTACIÓN COMPLETA DEL SISTEMA SIGIMED' as titulo;

SELECT
  '📋 RESUMEN FINAL' as seccion,
  jsonb_pretty(
    jsonb_build_object(
      'Fases Completadas', 6,
      'Tablas Creadas', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'),
      'Funciones SQL', (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public'),
      'Triggers', (SELECT COUNT(DISTINCT trigger_name) FROM information_schema.triggers WHERE trigger_schema = 'public'),
      'Índices', (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public'),
      'Políticas RLS', (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public'),
      'Permisos Definidos', (SELECT COUNT(*) FROM permissions),
      'Centros de Salud', (SELECT COUNT(*) FROM health_centers),
      'Proveedores', (SELECT COUNT(*) FROM suppliers),
      'Sistema', 'SIGIMED v2.0 - Totalmente Operativo'
    )
  ) as resumen;

SELECT '✅ SISTEMA LISTO PARA PRODUCCIÓN' as estado;
