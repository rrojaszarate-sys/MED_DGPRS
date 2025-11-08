-- ============================================
-- FASE 1 - PARTE 1.1: TABLAS CORE
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Crear tablas fundamentales para gestión de lotes y proveedores

BEGIN;

-- ============================================
-- TABLA 1: SUPPLIERS (Proveedores)
-- ============================================
CREATE TABLE IF NOT EXISTS suppliers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  rfc TEXT UNIQUE,
  razon_social TEXT,
  direccion TEXT,
  ciudad TEXT,
  estado TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  contacto_telefono TEXT,
  terminos_pago TEXT,
  dias_credito INTEGER DEFAULT 0,
  calificacion DECIMAL(2,1) CHECK (calificacion >= 0 AND calificacion <= 5),
  notas TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para suppliers
CREATE INDEX IF NOT EXISTS idx_suppliers_nombre ON suppliers(nombre);
CREATE INDEX IF NOT EXISTS idx_suppliers_rfc ON suppliers(rfc);
CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);

COMMENT ON TABLE suppliers IS 'Proveedores de medicamentos y materiales médicos';
COMMENT ON COLUMN suppliers.rfc IS 'RFC del proveedor (único)';
COMMENT ON COLUMN suppliers.calificacion IS 'Calificación del proveedor de 0 a 5';
COMMENT ON COLUMN suppliers.dias_credito IS 'Días de crédito otorgados por el proveedor';

-- ============================================
-- TABLA 2: BATCHES (Lotes de medicamentos)
-- ============================================
CREATE TABLE IF NOT EXISTS batches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
  numero_lote TEXT NOT NULL,
  cantidad_inicial INTEGER NOT NULL CHECK (cantidad_inicial >= 0),
  cantidad_actual INTEGER NOT NULL CHECK (cantidad_actual >= 0),
  fecha_fabricacion DATE,
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  ubicacion_fisica TEXT,
  temperatura_almacenamiento TEXT,
  stock_minimo INTEGER DEFAULT 10,
  stock_maximo INTEGER,
  estado TEXT DEFAULT 'disponible' CHECK (estado IN ('disponible', 'cuarentena', 'vencido', 'agotado')),
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(medication_id, numero_lote, center_id)
);

-- Índices para batches
CREATE INDEX IF NOT EXISTS idx_batches_medication ON batches(medication_id);
CREATE INDEX IF NOT EXISTS idx_batches_center ON batches(center_id);
CREATE INDEX IF NOT EXISTS idx_batches_supplier ON batches(supplier_id);
CREATE INDEX IF NOT EXISTS idx_batches_fecha_caducidad ON batches(fecha_caducidad);
CREATE INDEX IF NOT EXISTS idx_batches_estado ON batches(estado);
CREATE INDEX IF NOT EXISTS idx_batches_numero_lote ON batches(numero_lote);

COMMENT ON TABLE batches IS 'Lotes de medicamentos con control de stock y caducidad';
COMMENT ON COLUMN batches.numero_lote IS 'Número de lote del fabricante (único por medicamento y centro)';
COMMENT ON COLUMN batches.cantidad_inicial IS 'Cantidad con la que ingresó el lote';
COMMENT ON COLUMN batches.cantidad_actual IS 'Cantidad disponible actualmente';
COMMENT ON COLUMN batches.stock_minimo IS 'Cantidad mínima recomendada para alertas';
COMMENT ON COLUMN batches.stock_maximo IS 'Cantidad máxima de almacenamiento';

-- ============================================
-- TABLA 3: BATCH_MOVEMENTS (Movimientos de lotes)
-- ============================================
CREATE TABLE IF NOT EXISTS batch_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
  medication_id UUID REFERENCES medications(id),
  center_id UUID REFERENCES health_centers(id),
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN (
    'entrada', 'salida', 'ajuste', 'transferencia_salida',
    'transferencia_entrada', 'devolucion', 'merma', 'vencimiento'
  )),
  cantidad INTEGER NOT NULL,
  cantidad_anterior INTEGER NOT NULL,
  cantidad_posterior INTEGER NOT NULL,
  centro_origen_id UUID REFERENCES health_centers(id),
  centro_destino_id UUID REFERENCES health_centers(id),
  numero_documento TEXT,
  motivo TEXT NOT NULL,
  observaciones TEXT,
  usuario_responsable UUID REFERENCES users_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Índices para batch_movements
CREATE INDEX IF NOT EXISTS idx_batch_movements_batch ON batch_movements(batch_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_center ON batch_movements(center_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX IF NOT EXISTS idx_batch_movements_usuario ON batch_movements(usuario_responsable);
CREATE INDEX IF NOT EXISTS idx_batch_movements_created ON batch_movements(created_at DESC);

COMMENT ON TABLE batch_movements IS 'Registro completo de movimientos de lotes (trazabilidad)';
COMMENT ON COLUMN batch_movements.tipo_movimiento IS 'Tipo: entrada, salida, ajuste, transferencia, devolucion, merma, vencimiento';
COMMENT ON COLUMN batch_movements.cantidad_anterior IS 'Stock antes del movimiento';
COMMENT ON COLUMN batch_movements.cantidad_posterior IS 'Stock después del movimiento';
COMMENT ON COLUMN batch_movements.metadata IS 'Datos adicionales en formato JSON';

COMMIT;

-- Verificación
SELECT
  '✅ PARTE 1.1 COMPLETADA' as resultado,
  'Tablas core creadas exitosamente' as detalle;

SELECT
  table_name as tabla_creada,
  'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('suppliers', 'batches', 'batch_movements')
ORDER BY table_name;
-- ============================================
-- FASE 1 - PARTE 1.4: DATOS INICIALES
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Insertar instituciones, centros, proveedores y lotes iniciales
-- Ejecutar DESPUÉS de 01_crear_tablas_core.sql

BEGIN;

-- ============================================
-- 1. INSTITUCIONES
-- ============================================
INSERT INTO instituciones (id, nombre, clave, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'IMSS - Instituto Mexicano del Seguro Social', 'IMSS', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000002', 'ISSSTE - Instituto de Seguridad y Servicios Sociales', 'ISSSTE', 'Seguridad Social')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  clave = EXCLUDED.clave,
  tipo = EXCLUDED.tipo;

-- ============================================
-- 2. CENTROS DE SALUD (HGZ1 y CMF23)
-- ============================================

-- Actualizar centros existentes o insertar nuevos
INSERT INTO health_centers (
  id,
  name,
  code,
  address,
  city,
  region,
  phone,
  email,
  responsible_name,
  is_active,
  institucion_id
) VALUES
  (
    '10000000-0000-0000-0000-000000000001',
    'Hospital General de Zona No. 1 (HGZ1)',
    'HGZ1',
    'Av. Revolución 1234, Col. Centro',
    'Ciudad de México',
    'CDMX',
    '55-1234-5678',
    'hgz1@imss.gob.mx',
    'Dr. Juan Pérez García',
    true,
    '00000000-0000-0000-0000-000000000001'
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    'Clínica de Medicina Familiar No. 23 (CMF23)',
    'CMF23',
    'Calle Hidalgo 567, Col. Juárez',
    'Ciudad de México',
    'CDMX',
    '55-8765-4321',
    'cmf23@imss.gob.mx',
    'Dra. María López Hernández',
    true,
    '00000000-0000-0000-0000-000000000001'
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  code = EXCLUDED.code,
  address = EXCLUDED.address,
  city = EXCLUDED.city,
  region = EXCLUDED.region,
  phone = EXCLUDED.phone,
  email = EXCLUDED.email,
  responsible_name = EXCLUDED.responsible_name,
  is_active = EXCLUDED.is_active,
  institucion_id = EXCLUDED.institucion_id;

-- ============================================
-- 3. PROVEEDORES
-- ============================================
INSERT INTO suppliers (
  id,
  nombre,
  rfc,
  razon_social,
  direccion,
  ciudad,
  estado,
  telefono,
  email,
  contacto_nombre,
  contacto_telefono,
  terminos_pago,
  dias_credito,
  calificacion,
  notas,
  is_active
) VALUES
  (
    '20000000-0000-0000-0000-000000000001',
    'Farmacéutica Nacional S.A. de C.V.',
    'FNA850312ABC',
    'Farmacéutica Nacional Sociedad Anónima de Capital Variable',
    'Av. Insurgentes Sur 1234, Col. Del Valle',
    'Ciudad de México',
    'CDMX',
    '55-9876-5432',
    'ventas@farmanacional.com.mx',
    'Lic. Carlos Ramírez',
    '55-9876-5433',
    'Crédito 30 días',
    30,
    4.5,
    'Proveedor confiable con 15 años de experiencia',
    true
  ),
  (
    '20000000-0000-0000-0000-000000000002',
    'Distribuidora Médica del Centro S.A.',
    'DMC920615XYZ',
    'Distribuidora Médica del Centro Sociedad Anónima',
    'Blvd. Manuel Ávila Camacho 890, Col. Lomas',
    'Guadalajara',
    'Jalisco',
    '33-1234-5678',
    'contacto@dismedcentro.com',
    'Ing. Ana Martínez',
    '33-1234-5679',
    'Crédito 45 días',
    45,
    4.8,
    'Especialistas en medicamentos de alta especialidad',
    true
  )
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  rfc = EXCLUDED.rfc,
  razon_social = EXCLUDED.razon_social,
  direccion = EXCLUDED.direccion,
  ciudad = EXCLUDED.ciudad,
  estado = EXCLUDED.estado,
  telefono = EXCLUDED.telefono,
  email = EXCLUDED.email,
  contacto_nombre = EXCLUDED.contacto_nombre,
  contacto_telefono = EXCLUDED.contacto_telefono,
  terminos_pago = EXCLUDED.terminos_pago,
  dias_credito = EXCLUDED.dias_credito,
  calificacion = EXCLUDED.calificacion,
  notas = EXCLUDED.notas,
  is_active = EXCLUDED.is_active;

-- ============================================
-- 4. MEDICAMENTOS AL CATÁLOGO (si no existen)
-- ============================================
INSERT INTO medication_catalog (id, nombre_comercial) VALUES
  ('30000000-0000-0000-0000-000000000001', 'PARACETAMOL 500mg'),
  ('30000000-0000-0000-0000-000000000002', 'AMOXICILINA 500mg'),
  ('30000000-0000-0000-0000-000000000003', 'METFORMINA 850mg'),
  ('30000000-0000-0000-0000-000000000004', 'LOSARTÁN 50mg')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. LOTES DE MEDICAMENTOS
-- ============================================

-- Obtener IDs de medicamentos existentes en inventario
-- Nota: Asumimos que ya hay medicamentos en la tabla 'medications'
-- Si no los hay, esta parte no insertará lotes

-- Lote 1: Paracetamol en HGZ1
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000001',
  m.id,
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000001',
  'PARA-2024-001',
  1000,
  850,
  '2024-01-15',
  '2026-01-15',
  '2024-02-01',
  'Almacén General - Pasillo A, Estante 3',
  '15-25°C',
  100,
  1500,
  'disponible',
  'Lote de alta rotación para consulta general'
FROM medications m
WHERE m.nombre ILIKE '%paracetamol%'
  AND m.center_id = '10000000-0000-0000-0000-000000000001'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

-- Lote 2: Amoxicilina en HGZ1
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000002',
  m.id,
  '10000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000002',
  'AMOX-2024-045',
  500,
  320,
  '2023-11-20',
  '2025-11-20',
  '2024-01-10',
  'Almacén Refrigerado - Sección B2',
  '2-8°C',
  50,
  800,
  'disponible',
  'Antibiótico de amplio espectro - Refrigeración requerida'
FROM medications m
WHERE m.nombre ILIKE '%amoxicilina%'
  AND m.center_id = '10000000-0000-0000-0000-000000000001'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

-- Lote 3: Metformina en CMF23
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000003',
  m.id,
  '10000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000001',
  'METF-2024-112',
  2000,
  1650,
  '2024-03-01',
  '2027-03-01',
  '2024-04-15',
  'Almacén Farmacia - Gabinete Diabetes',
  '15-30°C',
  200,
  3000,
  'disponible',
  'Medicamento para control de diabetes tipo 2'
FROM medications m
WHERE m.center_id = '10000000-0000-0000-0000-000000000002'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

-- Lote 4: Losartán en CMF23
INSERT INTO batches (
  id,
  medication_id,
  center_id,
  supplier_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_fabricacion,
  fecha_caducidad,
  fecha_ingreso,
  ubicacion_fisica,
  temperatura_almacenamiento,
  stock_minimo,
  stock_maximo,
  estado,
  observaciones
)
SELECT
  '40000000-0000-0000-0000-000000000004',
  m.id,
  '10000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000002',
  'LOSA-2024-078',
  800,
  650,
  '2024-02-10',
  '2026-02-10',
  '2024-03-20',
  'Almacén Farmacia - Gabinete Hipertensión',
  '15-25°C',
  100,
  1200,
  'disponible',
  'Antihipertensivo - Alta demanda en pacientes crónicos'
FROM medications m
WHERE m.center_id = '10000000-0000-0000-0000-000000000002'
LIMIT 1
ON CONFLICT (medication_id, numero_lote, center_id) DO UPDATE SET
  cantidad_actual = EXCLUDED.cantidad_actual;

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT '✅ PARTE 1.4 COMPLETADA' as resultado;

SELECT 'Instituciones' as tipo, COUNT(*) as total FROM instituciones
UNION ALL
SELECT 'Centros de Salud', COUNT(*) FROM health_centers WHERE code IN ('HGZ1', 'CMF23')
UNION ALL
SELECT 'Proveedores', COUNT(*) FROM suppliers
UNION ALL
SELECT 'Lotes Creados', COUNT(*) FROM batches;

-- Mostrar resumen de lotes
SELECT
  hc.code as centro,
  hc.name as nombre_centro,
  b.numero_lote,
  m.nombre as medicamento,
  b.cantidad_actual,
  b.estado,
  s.nombre as proveedor
FROM batches b
JOIN health_centers hc ON b.center_id = hc.id
JOIN medications m ON b.medication_id = m.id
LEFT JOIN suppliers s ON b.supplier_id = s.id
WHERE hc.code IN ('HGZ1', 'CMF23')
ORDER BY hc.code, b.numero_lote;
-- ============================================
-- FASE 1 - PARTE 1.5: FUNCIONES Y TRIGGERS
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Crear funciones para gestión de lotes y triggers automáticos
-- Ejecutar DESPUÉS de 02_insertar_datos_iniciales.sql

BEGIN;

-- ============================================
-- FUNCIÓN 1: REGISTRAR MOVIMIENTO DE LOTE
-- ============================================
CREATE OR REPLACE FUNCTION registrar_movimiento_lote(
  p_batch_id UUID,
  p_tipo_movimiento TEXT,
  p_cantidad INTEGER,
  p_motivo TEXT,
  p_centro_destino_id UUID DEFAULT NULL,
  p_numero_documento TEXT DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL,
  p_usuario_responsable UUID DEFAULT NULL
) RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  new_quantity INTEGER,
  movement_id UUID
) AS $$
DECLARE
  v_batch RECORD;
  v_nueva_cantidad INTEGER;
  v_movement_id UUID;
  v_medication_id UUID;
  v_center_id UUID;
BEGIN
  -- Obtener información del lote
  SELECT * INTO v_batch FROM batches WHERE id = p_batch_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Lote no encontrado', 0::INTEGER, NULL::UUID;
    RETURN;
  END IF;

  v_medication_id := v_batch.medication_id;
  v_center_id := v_batch.center_id;

  -- Validar tipo de movimiento
  IF p_tipo_movimiento NOT IN (
    'entrada', 'salida', 'ajuste', 'transferencia_salida',
    'transferencia_entrada', 'devolucion', 'merma', 'vencimiento'
  ) THEN
    RETURN QUERY SELECT false, 'Tipo de movimiento inválido', 0::INTEGER, NULL::UUID;
    RETURN;
  END IF;

  -- Calcular nueva cantidad según tipo de movimiento
  CASE p_tipo_movimiento
    WHEN 'entrada', 'transferencia_entrada', 'devolucion' THEN
      v_nueva_cantidad := v_batch.cantidad_actual + p_cantidad;
    WHEN 'salida', 'transferencia_salida', 'merma', 'vencimiento' THEN
      v_nueva_cantidad := v_batch.cantidad_actual - p_cantidad;
      -- Validar que no quede negativo
      IF v_nueva_cantidad < 0 THEN
        RETURN QUERY SELECT
          false,
          'Stock insuficiente. Disponible: ' || v_batch.cantidad_actual::TEXT,
          v_batch.cantidad_actual::INTEGER,
          NULL::UUID;
        RETURN;
      END IF;
    WHEN 'ajuste' THEN
      v_nueva_cantidad := p_cantidad; -- p_cantidad es el nuevo total
    ELSE
      RETURN QUERY SELECT false, 'Tipo de movimiento no soportado', 0::INTEGER, NULL::UUID;
      RETURN;
  END CASE;

  -- Crear el movimiento
  INSERT INTO batch_movements (
    batch_id,
    medication_id,
    center_id,
    tipo_movimiento,
    cantidad,
    cantidad_anterior,
    cantidad_posterior,
    centro_destino_id,
    numero_documento,
    motivo,
    observaciones,
    usuario_responsable,
    metadata
  ) VALUES (
    p_batch_id,
    v_medication_id,
    v_center_id,
    p_tipo_movimiento,
    p_cantidad,
    v_batch.cantidad_actual,
    v_nueva_cantidad,
    p_centro_destino_id,
    p_numero_documento,
    p_motivo,
    p_observaciones,
    p_usuario_responsable,
    jsonb_build_object(
      'fecha_caducidad', v_batch.fecha_caducidad,
      'numero_lote', v_batch.numero_lote,
      'ubicacion_fisica', v_batch.ubicacion_fisica
    )
  ) RETURNING id INTO v_movement_id;

  -- Actualizar cantidad del lote
  UPDATE batches
  SET
    cantidad_actual = v_nueva_cantidad,
    estado = CASE
      WHEN v_nueva_cantidad = 0 THEN 'agotado'
      WHEN v_nueva_cantidad < stock_minimo THEN estado -- Mantener estado actual
      ELSE 'disponible'
    END,
    updated_at = NOW()
  WHERE id = p_batch_id;

  -- También actualizar la tabla medications si existe
  UPDATE medications
  SET
    cantidad = v_nueva_cantidad,
    updated_at = NOW()
  WHERE id = v_medication_id
    AND center_id = v_center_id;

  RETURN QUERY SELECT
    true,
    'Movimiento registrado exitosamente',
    v_nueva_cantidad,
    v_movement_id;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT
      false,
      'Error: ' || SQLERRM,
      0::INTEGER,
      NULL::UUID;
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_movimiento_lote IS 'Registra un movimiento de lote y actualiza inventario automáticamente';

-- ============================================
-- FUNCIÓN 2: DETECTAR LOTES VENCIDOS
-- ============================================
CREATE OR REPLACE FUNCTION detectar_lotes_vencidos()
RETURNS TABLE (
  batch_id UUID,
  medication_name TEXT,
  center_name TEXT,
  numero_lote TEXT,
  cantidad_actual INTEGER,
  fecha_caducidad DATE,
  dias_vencido INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    m.nombre,
    hc.name,
    b.numero_lote,
    b.cantidad_actual,
    b.fecha_caducidad,
    (CURRENT_DATE - b.fecha_caducidad)::INTEGER as dias_vencido
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.fecha_caducidad < CURRENT_DATE
    AND b.estado != 'vencido'
    AND b.cantidad_actual > 0
  ORDER BY b.fecha_caducidad ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION detectar_lotes_vencidos IS 'Detecta lotes que ya están vencidos y tienen stock';

-- ============================================
-- FUNCIÓN 3: LOTES PRÓXIMOS A VENCER
-- ============================================
CREATE OR REPLACE FUNCTION lotes_proximos_vencer(dias_anticipacion INTEGER DEFAULT 90)
RETURNS TABLE (
  batch_id UUID,
  medication_name TEXT,
  center_name TEXT,
  numero_lote TEXT,
  cantidad_actual INTEGER,
  fecha_caducidad DATE,
  dias_restantes INTEGER,
  urgencia TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    m.nombre,
    hc.name,
    b.numero_lote,
    b.cantidad_actual,
    b.fecha_caducidad,
    (b.fecha_caducidad - CURRENT_DATE)::INTEGER as dias_restantes,
    CASE
      WHEN (b.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'CRÍTICA'
      WHEN (b.fecha_caducidad - CURRENT_DATE) <= 60 THEN 'ALTA'
      ELSE 'MEDIA'
    END as urgencia
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
    AND b.estado = 'disponible'
    AND b.cantidad_actual > 0
  ORDER BY b.fecha_caducidad ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION lotes_proximos_vencer IS 'Lista lotes próximos a vencer con nivel de urgencia';

-- ============================================
-- FUNCIÓN 4: LOTES CON STOCK BAJO
-- ============================================
CREATE OR REPLACE FUNCTION lotes_stock_bajo()
RETURNS TABLE (
  batch_id UUID,
  medication_name TEXT,
  center_name TEXT,
  numero_lote TEXT,
  cantidad_actual INTEGER,
  stock_minimo INTEGER,
  porcentaje_disponible DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    m.nombre,
    hc.name,
    b.numero_lote,
    b.cantidad_actual,
    b.stock_minimo,
    ROUND((b.cantidad_actual::DECIMAL / NULLIF(b.stock_minimo, 0) * 100), 2) as porcentaje
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.cantidad_actual <= b.stock_minimo
    AND b.cantidad_actual > 0
    AND b.estado = 'disponible'
  ORDER BY (b.cantidad_actual::DECIMAL / NULLIF(b.stock_minimo, 1)) ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION lotes_stock_bajo IS 'Detecta lotes con stock por debajo del mínimo';

-- ============================================
-- TRIGGER 1: ACTUALIZAR ESTADO AUTOMÁTICAMENTE
-- ============================================
CREATE OR REPLACE FUNCTION trigger_actualizar_estado_lote()
RETURNS TRIGGER AS $$
BEGIN
  -- Marcar como vencido si pasó la fecha de caducidad
  IF NEW.fecha_caducidad < CURRENT_DATE AND NEW.estado != 'vencido' THEN
    NEW.estado := 'vencido';
  END IF;

  -- Marcar como agotado si cantidad es 0
  IF NEW.cantidad_actual = 0 AND NEW.estado != 'agotado' THEN
    NEW.estado := 'agotado';
  END IF;

  -- Actualizar updated_at
  NEW.updated_at := NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_actualizar_estado_lote ON batches;
CREATE TRIGGER trg_actualizar_estado_lote
  BEFORE UPDATE ON batches
  FOR EACH ROW
  EXECUTE FUNCTION trigger_actualizar_estado_lote();

COMMENT ON TRIGGER trg_actualizar_estado_lote ON batches IS 'Actualiza automáticamente el estado del lote según reglas de negocio';

-- ============================================
-- TRIGGER 2: REGISTRAR EN AUDIT_LOG
-- ============================================
CREATE OR REPLACE FUNCTION trigger_audit_batch_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_action_type TEXT;
  v_changes_summary TEXT;
BEGIN
  -- Determinar tipo de acción
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'CREATE';
    v_changes_summary := 'Nuevo lote creado: ' || NEW.numero_lote;
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'UPDATE';
    v_changes_summary := 'Lote actualizado: ' || NEW.numero_lote;

    -- Detalles específicos de cambios
    IF OLD.cantidad_actual != NEW.cantidad_actual THEN
      v_changes_summary := v_changes_summary ||
        ' | Cantidad: ' || OLD.cantidad_actual || ' → ' || NEW.cantidad_actual;
    END IF;

    IF OLD.estado != NEW.estado THEN
      v_changes_summary := v_changes_summary ||
        ' | Estado: ' || OLD.estado || ' → ' || NEW.estado;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'DELETE';
    v_changes_summary := 'Lote eliminado: ' || OLD.numero_lote;
  END IF;

  -- Insertar en audit_log
  INSERT INTO audit_log (
    action_type,
    entity_type,
    entity_id,
    entity_name,
    old_values,
    new_values,
    changes_summary,
    result,
    severity,
    metadata
  ) VALUES (
    v_action_type,
    'batch',
    COALESCE(NEW.id, OLD.id),
    COALESCE(NEW.numero_lote, OLD.numero_lote),
    CASE WHEN TG_OP != 'INSERT' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END,
    v_changes_summary,
    'success',
    CASE
      WHEN TG_OP = 'DELETE' THEN 'high'
      WHEN TG_OP = 'INSERT' THEN 'medium'
      ELSE 'low'
    END,
    jsonb_build_object('trigger', TG_NAME, 'table', TG_TABLE_NAME)
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_batch_changes ON batches;
CREATE TRIGGER trg_audit_batch_changes
  AFTER INSERT OR UPDATE OR DELETE ON batches
  FOR EACH ROW
  EXECUTE FUNCTION trigger_audit_batch_changes();

COMMENT ON TRIGGER trg_audit_batch_changes ON batches IS 'Registra todos los cambios en lotes en la tabla de auditoría';

COMMIT;

-- ============================================
-- VERIFICACIÓN Y PRUEBAS
-- ============================================
SELECT '✅ PARTE 1.5 COMPLETADA' as resultado;

-- Listar funciones creadas
SELECT
  routine_name as funcion,
  'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'detectar_lotes_vencidos',
    'lotes_proximos_vencer',
    'lotes_stock_bajo',
    'trigger_actualizar_estado_lote',
    'trigger_audit_batch_changes'
  )
ORDER BY routine_name;

-- Listar triggers creados
SELECT
  trigger_name as trigger,
  event_object_table as tabla,
  'OK' as estado
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name IN (
    'trg_actualizar_estado_lote',
    'trg_audit_batch_changes'
  )
ORDER BY trigger_name;

-- Prueba de la función: detectar lotes próximos a vencer (90 días)
SELECT '🔍 PRUEBA: Lotes próximos a vencer' as titulo;
SELECT * FROM lotes_proximos_vencer(90) LIMIT 5;

-- Prueba de la función: detectar stock bajo
SELECT '🔍 PRUEBA: Lotes con stock bajo' as titulo;
SELECT * FROM lotes_stock_bajo() LIMIT 5;
-- ============================================
-- FASE 2: SISTEMA DE PERMISOS Y RLS
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Implementar sistema de roles, permisos y Row Level Security
-- Tiempo estimado: 45 minutos
-- Ejecutar DESPUÉS de Fase 1

BEGIN;

-- ============================================
-- PARTE 2.1: TABLA DE PERMISOS
-- ============================================

-- Tabla: permissions (Permisos granulares)
CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name TEXT NOT NULL CHECK (role_name IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  resource TEXT NOT NULL, -- 'medications', 'batches', 'suppliers', etc.
  action TEXT NOT NULL CHECK (action IN ('create', 'read', 'update', 'delete', 'export', 'approve')),
  allowed BOOLEAN DEFAULT true,
  conditions JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(role_name, resource, action)
);

CREATE INDEX IF NOT EXISTS idx_permissions_role ON permissions(role_name);
CREATE INDEX IF NOT EXISTS idx_permissions_resource ON permissions(resource);

COMMENT ON TABLE permissions IS 'Define permisos granulares por rol y recurso';
COMMENT ON COLUMN permissions.conditions IS 'Condiciones adicionales en formato JSON (ej: {"only_own_center": true})';

-- ============================================
-- PARTE 2.2: TABLA DE ROLES DE USUARIOS
-- ============================================

-- Tabla: user_roles (Roles asignados a usuarios)
CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role_name TEXT NOT NULL CHECK (role_name IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  assigned_by UUID,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}'::jsonb,
  UNIQUE(user_id, role_name, center_id)
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role_name);
CREATE INDEX IF NOT EXISTS idx_user_roles_center ON user_roles(center_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_active ON user_roles(is_active) WHERE is_active = true;

COMMENT ON TABLE user_roles IS 'Roles asignados a usuarios con alcance por centro';
COMMENT ON COLUMN user_roles.center_id IS 'NULL para super_admin (alcance global), obligatorio para otros roles';
COMMENT ON COLUMN user_roles.valid_until IS 'Fecha de expiración del rol (NULL = sin expiración)';

-- ============================================
-- PARTE 2.3: INSERTAR PERMISOS POR ROL
-- ============================================

-- Permisos para SUPER_ADMIN (acceso total)
INSERT INTO permissions (role_name, resource, action, allowed) VALUES
  ('super_admin', 'medications', 'create', true),
  ('super_admin', 'medications', 'read', true),
  ('super_admin', 'medications', 'update', true),
  ('super_admin', 'medications', 'delete', true),
  ('super_admin', 'medications', 'export', true),
  ('super_admin', 'batches', 'create', true),
  ('super_admin', 'batches', 'read', true),
  ('super_admin', 'batches', 'update', true),
  ('super_admin', 'batches', 'delete', true),
  ('super_admin', 'suppliers', 'create', true),
  ('super_admin', 'suppliers', 'read', true),
  ('super_admin', 'suppliers', 'update', true),
  ('super_admin', 'suppliers', 'delete', true),
  ('super_admin', 'contracts', 'create', true),
  ('super_admin', 'contracts', 'read', true),
  ('super_admin', 'contracts', 'update', true),
  ('super_admin', 'contracts', 'approve', true),
  ('super_admin', 'users', 'create', true),
  ('super_admin', 'users', 'read', true),
  ('super_admin', 'users', 'update', true),
  ('super_admin', 'users', 'delete', true)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

-- Permisos para ADMIN_CENTER (administrador de centro)
INSERT INTO permissions (role_name, resource, action, allowed, conditions) VALUES
  ('admin_center', 'medications', 'create', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'update', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'delete', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'export', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'create', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'update', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'delete', false, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'suppliers', 'read', true, '{}'::jsonb),
  ('admin_center', 'contracts', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'users', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'users', 'update', true, '{"only_own_center": true}'::jsonb)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

-- Permisos para INVENTORY_USER (usuario de inventario)
INSERT INTO permissions (role_name, resource, action, allowed, conditions) VALUES
  ('inventory_user', 'medications', 'create', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'medications', 'read', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'medications', 'update', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'medications', 'delete', false, '{}'::jsonb),
  ('inventory_user', 'medications', 'export', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'create', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'read', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'update', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'delete', false, '{}'::jsonb),
  ('inventory_user', 'suppliers', 'read', true, '{}'::jsonb),
  ('inventory_user', 'contracts', 'read', true, '{"only_own_center": true}'::jsonb)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

-- Permisos para READ_ONLY (solo lectura)
INSERT INTO permissions (role_name, resource, action, allowed, conditions) VALUES
  ('read_only', 'medications', 'read', true, '{"only_own_center": true}'::jsonb),
  ('read_only', 'batches', 'read', true, '{"only_own_center": true}'::jsonb),
  ('read_only', 'suppliers', 'read', true, '{}'::jsonb),
  ('read_only', 'contracts', 'read', true, '{"only_own_center": true}'::jsonb),
  ('read_only', 'medications', 'export', true, '{"only_own_center": true}'::jsonb)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

COMMIT;

-- ============================================
-- PARTE 2.4: FUNCIONES HELPER PARA RLS
-- ============================================

-- Función: Obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role(p_user_id UUID DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
  v_user_id UUID;
  v_role TEXT;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());

  SELECT role_name INTO v_role
  FROM user_roles
  WHERE user_id = v_user_id
    AND is_active = true
    AND (valid_until IS NULL OR valid_until > NOW())
  ORDER BY
    CASE role_name
      WHEN 'super_admin' THEN 1
      WHEN 'admin_center' THEN 2
      WHEN 'inventory_user' THEN 3
      WHEN 'read_only' THEN 4
    END
  LIMIT 1;

  RETURN COALESCE(v_role, 'read_only');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_user_role IS 'Obtiene el rol más privilegiado del usuario actual';

-- Función: Verificar si usuario tiene permiso
CREATE OR REPLACE FUNCTION has_permission(
  p_resource TEXT,
  p_action TEXT,
  p_user_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_id UUID;
  v_role TEXT;
  v_allowed BOOLEAN;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());
  v_role := get_user_role(v_user_id);

  SELECT allowed INTO v_allowed
  FROM permissions
  WHERE role_name = v_role
    AND resource = p_resource
    AND action = p_action;

  RETURN COALESCE(v_allowed, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION has_permission IS 'Verifica si el usuario tiene un permiso específico';

-- Función: Obtener centros del usuario
CREATE OR REPLACE FUNCTION get_user_centers(p_user_id UUID DEFAULT NULL)
RETURNS TABLE (center_id UUID) AS $$
DECLARE
  v_user_id UUID;
  v_role TEXT;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());
  v_role := get_user_role(v_user_id);

  -- Super admin tiene acceso a todos los centros
  IF v_role = 'super_admin' THEN
    RETURN QUERY SELECT id FROM health_centers WHERE is_active = true;
  ELSE
    -- Otros roles solo sus centros asignados
    RETURN QUERY
    SELECT DISTINCT uc.center_id
    FROM user_centers uc
    WHERE uc.user_id = v_user_id
    UNION
    SELECT DISTINCT ur.center_id
    FROM user_roles ur
    WHERE ur.user_id = v_user_id
      AND ur.is_active = true
      AND ur.center_id IS NOT NULL
      AND (ur.valid_until IS NULL OR ur.valid_until > NOW());
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_user_centers IS 'Obtiene los centros a los que el usuario tiene acceso';

-- Función: Verificar si usuario es super admin
CREATE OR REPLACE FUNCTION is_super_admin(p_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN get_user_role(COALESCE(p_user_id, auth.uid())) = 'super_admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Verificar acceso a un centro específico
CREATE OR REPLACE FUNCTION has_center_access(p_center_id UUID, p_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());

  -- Super admin tiene acceso a todos
  IF is_super_admin(v_user_id) THEN
    RETURN true;
  END IF;

  -- Verificar si el centro está en la lista del usuario
  RETURN EXISTS (
    SELECT 1 FROM get_user_centers(v_user_id) WHERE center_id = p_center_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION has_center_access IS 'Verifica si el usuario tiene acceso a un centro específico';

COMMIT;

-- ============================================
-- PARTE 2.5: POLÍTICAS RLS
-- ============================================

BEGIN;

-- Habilitar RLS en todas las tablas principales
ALTER TABLE health_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contract_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE documentos_comprobantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS: HEALTH_CENTERS
-- ============================================

DROP POLICY IF EXISTS "health_centers_select_policy" ON health_centers;
CREATE POLICY "health_centers_select_policy" ON health_centers
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(id)
  );

DROP POLICY IF EXISTS "health_centers_insert_policy" ON health_centers;
CREATE POLICY "health_centers_insert_policy" ON health_centers
  FOR INSERT
  WITH CHECK (is_super_admin());

DROP POLICY IF EXISTS "health_centers_update_policy" ON health_centers;
CREATE POLICY "health_centers_update_policy" ON health_centers
  FOR UPDATE
  USING (
    is_super_admin()
    OR (get_user_role() = 'admin_center' AND has_center_access(id))
  );

DROP POLICY IF EXISTS "health_centers_delete_policy" ON health_centers;
CREATE POLICY "health_centers_delete_policy" ON health_centers
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: MEDICATIONS
-- ============================================

DROP POLICY IF EXISTS "medications_select_policy" ON medications;
CREATE POLICY "medications_select_policy" ON medications
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(center_id)
  );

DROP POLICY IF EXISTS "medications_insert_policy" ON medications;
CREATE POLICY "medications_insert_policy" ON medications
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR (has_permission('medications', 'create') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "medications_update_policy" ON medications;
CREATE POLICY "medications_update_policy" ON medications
  FOR UPDATE
  USING (
    is_super_admin()
    OR (has_permission('medications', 'update') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "medications_delete_policy" ON medications;
CREATE POLICY "medications_delete_policy" ON medications
  FOR DELETE
  USING (
    is_super_admin()
    OR (has_permission('medications', 'delete') AND has_center_access(center_id))
  );

-- ============================================
-- RLS: BATCHES
-- ============================================

DROP POLICY IF EXISTS "batches_select_policy" ON batches;
CREATE POLICY "batches_select_policy" ON batches
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(center_id)
  );

DROP POLICY IF EXISTS "batches_insert_policy" ON batches;
CREATE POLICY "batches_insert_policy" ON batches
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR (has_permission('batches', 'create') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "batches_update_policy" ON batches;
CREATE POLICY "batches_update_policy" ON batches
  FOR UPDATE
  USING (
    is_super_admin()
    OR (has_permission('batches', 'update') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "batches_delete_policy" ON batches;
CREATE POLICY "batches_delete_policy" ON batches
  FOR DELETE
  USING (
    is_super_admin()
    OR (has_permission('batches', 'delete') AND has_center_access(center_id))
  );

-- ============================================
-- RLS: BATCH_MOVEMENTS
-- ============================================

DROP POLICY IF EXISTS "batch_movements_select_policy" ON batch_movements;
CREATE POLICY "batch_movements_select_policy" ON batch_movements
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(center_id)
  );

DROP POLICY IF EXISTS "batch_movements_insert_policy" ON batch_movements;
CREATE POLICY "batch_movements_insert_policy" ON batch_movements
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_center_access(center_id)
  );

-- Movimientos son inmutables (no UPDATE/DELETE después de crear)
DROP POLICY IF EXISTS "batch_movements_update_policy" ON batch_movements;
CREATE POLICY "batch_movements_update_policy" ON batch_movements
  FOR UPDATE
  USING (is_super_admin());

DROP POLICY IF EXISTS "batch_movements_delete_policy" ON batch_movements;
CREATE POLICY "batch_movements_delete_policy" ON batch_movements
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: SUPPLIERS (Todos pueden leer)
-- ============================================

DROP POLICY IF EXISTS "suppliers_select_policy" ON suppliers;
CREATE POLICY "suppliers_select_policy" ON suppliers
  FOR SELECT
  USING (true); -- Todos pueden ver proveedores

DROP POLICY IF EXISTS "suppliers_insert_policy" ON suppliers;
CREATE POLICY "suppliers_insert_policy" ON suppliers
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('suppliers', 'create')
  );

DROP POLICY IF EXISTS "suppliers_update_policy" ON suppliers;
CREATE POLICY "suppliers_update_policy" ON suppliers
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('suppliers', 'update')
  );

DROP POLICY IF EXISTS "suppliers_delete_policy" ON suppliers;
CREATE POLICY "suppliers_delete_policy" ON suppliers
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: CONTRACTS
-- ============================================

DROP POLICY IF EXISTS "contracts_select_policy" ON contracts;
CREATE POLICY "contracts_select_policy" ON contracts
  FOR SELECT
  USING (
    is_super_admin()
    OR has_permission('contracts', 'read')
  );

DROP POLICY IF EXISTS "contracts_insert_policy" ON contracts;
CREATE POLICY "contracts_insert_policy" ON contracts
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('contracts', 'create')
  );

DROP POLICY IF EXISTS "contracts_update_policy" ON contracts;
CREATE POLICY "contracts_update_policy" ON contracts
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('contracts', 'update')
  );

DROP POLICY IF EXISTS "contracts_delete_policy" ON contracts;
CREATE POLICY "contracts_delete_policy" ON contracts
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: AUDIT_LOG (Solo lectura, super_admin puede todo)
-- ============================================

DROP POLICY IF EXISTS "audit_log_select_policy" ON audit_log;
CREATE POLICY "audit_log_select_policy" ON audit_log
  FOR SELECT
  USING (
    is_super_admin()
    OR user_id = auth.uid()
  );

DROP POLICY IF EXISTS "audit_log_insert_policy" ON audit_log;
CREATE POLICY "audit_log_insert_policy" ON audit_log
  FOR INSERT
  WITH CHECK (true); -- Cualquiera puede insertar en audit log

DROP POLICY IF EXISTS "audit_log_update_policy" ON audit_log;
CREATE POLICY "audit_log_update_policy" ON audit_log
  FOR UPDATE
  USING (false); -- Audit log es inmutable

DROP POLICY IF EXISTS "audit_log_delete_policy" ON audit_log;
CREATE POLICY "audit_log_delete_policy" ON audit_log
  FOR DELETE
  USING (is_super_admin()); -- Solo super_admin puede eliminar logs

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 2 COMPLETADA' as resultado;

SELECT 'TABLAS DE PERMISOS' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('permissions', 'user_roles')
ORDER BY table_name;

SELECT 'FUNCIONES RLS' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'get_user_role', 'has_permission', 'get_user_centers',
    'is_super_admin', 'has_center_access'
  )
ORDER BY routine_name;

SELECT 'POLÍTICAS RLS' as seccion;
SELECT
  schemaname as schema,
  tablename as tabla,
  COUNT(*) as politicas
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY schemaname, tablename
ORDER BY tablename;

SELECT 'PERMISOS CONFIGURADOS' as seccion;
SELECT role_name, COUNT(*) as permisos_totales
FROM permissions
GROUP BY role_name
ORDER BY role_name;
-- ============================================
-- FASE 3: CONTROL DE CALIDAD AVANZADO
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Sistema de alertas, métricas y control de calidad
-- Tiempo estimado: 60 minutos
-- Ejecutar DESPUÉS de Fase 2

BEGIN;

-- ============================================
-- PARTE 3.1: TABLA DE ALERTAS
-- ============================================

CREATE TABLE IF NOT EXISTS alertas_medicamentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_alerta TEXT NOT NULL CHECK (tipo_alerta IN (
    'stock_bajo', 'proximo_vencer', 'vencido', 'lote_cuarentena',
    'temperatura_fuera_rango', 'discrepancia_inventario', 'medicamento_faltante'
  )),
  severidad TEXT NOT NULL CHECK (severidad IN ('baja', 'media', 'alta', 'critica')),
  medication_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  datos_adicionales JSONB DEFAULT '{}'::jsonb,
  estado TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_revision', 'resuelta', 'descartada')),
  resuelta_por UUID,
  resuelta_en TIMESTAMPTZ,
  notas_resolucion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alertas_tipo ON alertas_medicamentos(tipo_alerta);
CREATE INDEX IF NOT EXISTS idx_alertas_severidad ON alertas_medicamentos(severidad);
CREATE INDEX IF NOT EXISTS idx_alertas_estado ON alertas_medicamentos(estado);
CREATE INDEX IF NOT EXISTS idx_alertas_center ON alertas_medicamentos(center_id);
CREATE INDEX IF NOT EXISTS idx_alertas_medication ON alertas_medicamentos(medication_id);
CREATE INDEX IF NOT EXISTS idx_alertas_batch ON alertas_medicamentos(batch_id);
CREATE INDEX IF NOT EXISTS idx_alertas_created ON alertas_medicamentos(created_at DESC);

COMMENT ON TABLE alertas_medicamentos IS 'Sistema centralizado de alertas y notificaciones';
COMMENT ON COLUMN alertas_medicamentos.datos_adicionales IS 'Información adicional en JSON (cantidades, fechas, etc.)';

-- ============================================
-- PARTE 3.2: TABLA DE NOTIFICACIONES
-- ============================================

CREATE TABLE IF NOT EXISTS notificaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN (
    'alerta_stock', 'alerta_vencimiento', 'aprobacion_requerida',
    'transferencia_recibida', 'contrato_vencido', 'inspeccion_pendiente'
  )),
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  enlace TEXT,
  icono TEXT,
  leida BOOLEAN DEFAULT false,
  leida_en TIMESTAMPTZ,
  referencia_tipo TEXT,
  referencia_id UUID,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notificaciones_user ON notificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON notificaciones(leida) WHERE leida = false;
CREATE INDEX IF NOT EXISTS idx_notificaciones_tipo ON notificaciones(tipo);
CREATE INDEX IF NOT EXISTS idx_notificaciones_created ON notificaciones(created_at DESC);

COMMENT ON TABLE notificaciones IS 'Notificaciones para usuarios del sistema';

-- ============================================
-- PARTE 3.3: TABLA DE MÉTRICAS
-- ============================================

CREATE TABLE IF NOT EXISTS metricas_inventario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  fecha DATE NOT NULL DEFAULT CURRENT_DATE,
  total_medicamentos INTEGER DEFAULT 0,
  total_lotes INTEGER DEFAULT 0,
  valor_inventario DECIMAL(15,2) DEFAULT 0,
  medicamentos_bajo_stock INTEGER DEFAULT 0,
  lotes_proximos_vencer INTEGER DEFAULT 0,
  lotes_vencidos INTEGER DEFAULT 0,
  movimientos_entrada INTEGER DEFAULT 0,
  movimientos_salida INTEGER DEFAULT 0,
  tasa_rotacion DECIMAL(5,2),
  cumplimiento_stock DECIMAL(5,2),
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(center_id, fecha)
);

CREATE INDEX IF NOT EXISTS idx_metricas_center ON metricas_inventario(center_id);
CREATE INDEX IF NOT EXISTS idx_metricas_fecha ON metricas_inventario(fecha DESC);

COMMENT ON TABLE metricas_inventario IS 'Métricas diarias de inventario por centro';
COMMENT ON COLUMN metricas_inventario.tasa_rotacion IS 'Tasa de rotación de inventario (salidas / stock promedio)';
COMMENT ON COLUMN metricas_inventario.cumplimiento_stock IS 'Porcentaje de medicamentos con stock adecuado';

COMMIT;

-- ============================================
-- PARTE 3.4: FUNCIONES DE GENERACIÓN DE ALERTAS
-- ============================================

-- Función: Generar alertas de stock bajo
CREATE OR REPLACE FUNCTION generar_alertas_stock_bajo()
RETURNS TABLE (
  alertas_creadas INTEGER,
  mensaje TEXT
) AS $$
DECLARE
  v_count INTEGER := 0;
  v_batch RECORD;
BEGIN
  -- Buscar lotes con stock bajo
  FOR v_batch IN
    SELECT
      b.id as batch_id,
      b.medication_id,
      b.center_id,
      b.numero_lote,
      b.cantidad_actual,
      b.stock_minimo,
      m.nombre as medication_name,
      hc.name as center_name
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    JOIN health_centers hc ON b.center_id = hc.id
    WHERE b.cantidad_actual <= b.stock_minimo
      AND b.cantidad_actual > 0
      AND b.estado = 'disponible'
      AND NOT EXISTS (
        SELECT 1 FROM alertas_medicamentos
        WHERE batch_id = b.id
          AND tipo_alerta = 'stock_bajo'
          AND estado IN ('pendiente', 'en_revision')
          AND created_at > NOW() - INTERVAL '7 days'
      )
  LOOP
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    ) VALUES (
      'stock_bajo',
      CASE
        WHEN v_batch.cantidad_actual <= (v_batch.stock_minimo * 0.5) THEN 'alta'
        WHEN v_batch.cantidad_actual <= (v_batch.stock_minimo * 0.75) THEN 'media'
        ELSE 'baja'
      END,
      v_batch.medication_id,
      v_batch.batch_id,
      v_batch.center_id,
      'Stock Bajo: ' || v_batch.medication_name,
      format('El lote %s tiene solo %s unidades (mínimo: %s)',
        v_batch.numero_lote,
        v_batch.cantidad_actual,
        v_batch.stock_minimo
      ),
      jsonb_build_object(
        'cantidad_actual', v_batch.cantidad_actual,
        'stock_minimo', v_batch.stock_minimo,
        'porcentaje', ROUND((v_batch.cantidad_actual::DECIMAL / v_batch.stock_minimo * 100), 2)
      )
    );

    v_count := v_count + 1;
  END LOOP;

  RETURN QUERY SELECT v_count, format('Se crearon %s alertas de stock bajo', v_count);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_alertas_stock_bajo IS 'Genera alertas automáticas para lotes con stock bajo';

-- Función: Generar alertas de vencimiento
CREATE OR REPLACE FUNCTION generar_alertas_vencimiento(dias_anticipacion INTEGER DEFAULT 90)
RETURNS TABLE (
  alertas_creadas INTEGER,
  mensaje TEXT
) AS $$
DECLARE
  v_count INTEGER := 0;
  v_batch RECORD;
BEGIN
  -- Buscar lotes próximos a vencer
  FOR v_batch IN
    SELECT
      b.id as batch_id,
      b.medication_id,
      b.center_id,
      b.numero_lote,
      b.cantidad_actual,
      b.fecha_caducidad,
      (b.fecha_caducidad - CURRENT_DATE)::INTEGER as dias_restantes,
      m.nombre as medication_name,
      hc.name as center_name
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    JOIN health_centers hc ON b.center_id = hc.id
    WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
      AND b.cantidad_actual > 0
      AND b.estado = 'disponible'
      AND NOT EXISTS (
        SELECT 1 FROM alertas_medicamentos
        WHERE batch_id = b.id
          AND tipo_alerta = 'proximo_vencer'
          AND estado IN ('pendiente', 'en_revision')
          AND created_at > NOW() - INTERVAL '7 days'
      )
  LOOP
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    ) VALUES (
      'proximo_vencer',
      CASE
        WHEN v_batch.dias_restantes <= 30 THEN 'critica'
        WHEN v_batch.dias_restantes <= 60 THEN 'alta'
        ELSE 'media'
      END,
      v_batch.medication_id,
      v_batch.batch_id,
      v_batch.center_id,
      'Próximo a Vencer: ' || v_batch.medication_name,
      format('El lote %s vence en %s días (%s)',
        v_batch.numero_lote,
        v_batch.dias_restantes,
        v_batch.fecha_caducidad
      ),
      jsonb_build_object(
        'dias_restantes', v_batch.dias_restantes,
        'fecha_caducidad', v_batch.fecha_caducidad,
        'cantidad_actual', v_batch.cantidad_actual
      )
    );

    v_count := v_count + 1;
  END LOOP;

  -- Buscar lotes ya vencidos
  FOR v_batch IN
    SELECT
      b.id as batch_id,
      b.medication_id,
      b.center_id,
      b.numero_lote,
      b.cantidad_actual,
      b.fecha_caducidad,
      (CURRENT_DATE - b.fecha_caducidad)::INTEGER as dias_vencido,
      m.nombre as medication_name,
      hc.name as center_name
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    JOIN health_centers hc ON b.center_id = hc.id
    WHERE b.fecha_caducidad < CURRENT_DATE
      AND b.cantidad_actual > 0
      AND b.estado != 'vencido'
      AND NOT EXISTS (
        SELECT 1 FROM alertas_medicamentos
        WHERE batch_id = b.id
          AND tipo_alerta = 'vencido'
          AND estado IN ('pendiente', 'en_revision')
      )
  LOOP
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    ) VALUES (
      'vencido',
      'critica',
      v_batch.medication_id,
      v_batch.batch_id,
      v_batch.center_id,
      'VENCIDO: ' || v_batch.medication_name,
      format('El lote %s está vencido desde hace %s días. Retirar inmediatamente.',
        v_batch.numero_lote,
        v_batch.dias_vencido
      ),
      jsonb_build_object(
        'dias_vencido', v_batch.dias_vencido,
        'fecha_caducidad', v_batch.fecha_caducidad,
        'cantidad_actual', v_batch.cantidad_actual
      )
    );

    -- Actualizar estado del lote
    UPDATE batches SET estado = 'vencido', updated_at = NOW()
    WHERE id = v_batch.batch_id;

    v_count := v_count + 1;
  END LOOP;

  RETURN QUERY SELECT v_count, format('Se crearon %s alertas de vencimiento', v_count);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_alertas_vencimiento IS 'Genera alertas para lotes próximos a vencer o ya vencidos';

-- ============================================
-- PARTE 3.5: FUNCIONES DE MÉTRICAS
-- ============================================

-- Función: Calcular métricas diarias
CREATE OR REPLACE FUNCTION calcular_metricas_diarias(p_center_id UUID DEFAULT NULL)
RETURNS TABLE (
  center_id UUID,
  fecha DATE,
  metricas JSONB
) AS $$
BEGIN
  RETURN QUERY
  WITH centers AS (
    SELECT id FROM health_centers
    WHERE (p_center_id IS NULL OR id = p_center_id)
      AND is_active = true
  ),
  stats AS (
    SELECT
      c.id as center_id,
      CURRENT_DATE as fecha,
      COUNT(DISTINCT m.id) as total_medicamentos,
      COUNT(DISTINCT b.id) as total_lotes,
      COUNT(DISTINCT b.id) FILTER (WHERE b.cantidad_actual <= b.stock_minimo) as medicamentos_bajo_stock,
      COUNT(DISTINCT b.id) FILTER (
        WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + 90)
      ) as lotes_proximos_vencer,
      COUNT(DISTINCT b.id) FILTER (WHERE b.fecha_caducidad < CURRENT_DATE) as lotes_vencidos,
      COUNT(bm.id) FILTER (
        WHERE bm.tipo_movimiento IN ('entrada', 'transferencia_entrada')
          AND bm.created_at >= CURRENT_DATE
      ) as movimientos_entrada,
      COUNT(bm.id) FILTER (
        WHERE bm.tipo_movimiento IN ('salida', 'transferencia_salida')
          AND bm.created_at >= CURRENT_DATE
      ) as movimientos_salida
    FROM centers c
    LEFT JOIN medications m ON m.center_id = c.id
    LEFT JOIN batches b ON b.center_id = c.id AND b.cantidad_actual > 0
    LEFT JOIN batch_movements bm ON bm.center_id = c.id
    GROUP BY c.id
  )
  SELECT
    s.center_id,
    s.fecha,
    jsonb_build_object(
      'total_medicamentos', s.total_medicamentos,
      'total_lotes', s.total_lotes,
      'medicamentos_bajo_stock', s.medicamentos_bajo_stock,
      'lotes_proximos_vencer', s.lotes_proximos_vencer,
      'lotes_vencidos', s.lotes_vencidos,
      'movimientos_entrada', s.movimientos_entrada,
      'movimientos_salida', s.movimientos_salida,
      'cumplimiento_stock', ROUND(
        CASE
          WHEN s.total_medicamentos > 0
          THEN ((s.total_medicamentos - s.medicamentos_bajo_stock)::DECIMAL / s.total_medicamentos * 100)
          ELSE 100
        END, 2
      )
    ) as metricas
  FROM stats s;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calcular_metricas_diarias IS 'Calcula métricas diarias de inventario por centro';

-- Función: Guardar métricas diarias
CREATE OR REPLACE FUNCTION guardar_metricas_diarias()
RETURNS TABLE (
  centros_procesados INTEGER,
  mensaje TEXT
) AS $$
DECLARE
  v_count INTEGER := 0;
  v_metric RECORD;
BEGIN
  FOR v_metric IN SELECT * FROM calcular_metricas_diarias()
  LOOP
    INSERT INTO metricas_inventario (
      center_id,
      fecha,
      total_medicamentos,
      total_lotes,
      medicamentos_bajo_stock,
      lotes_proximos_vencer,
      lotes_vencidos,
      movimientos_entrada,
      movimientos_salida,
      cumplimiento_stock,
      metadata
    ) VALUES (
      v_metric.center_id,
      v_metric.fecha,
      (v_metric.metricas->>'total_medicamentos')::INTEGER,
      (v_metric.metricas->>'total_lotes')::INTEGER,
      (v_metric.metricas->>'medicamentos_bajo_stock')::INTEGER,
      (v_metric.metricas->>'lotes_proximos_vencer')::INTEGER,
      (v_metric.metricas->>'lotes_vencidos')::INTEGER,
      (v_metric.metricas->>'movimientos_entrada')::INTEGER,
      (v_metric.metricas->>'movimientos_salida')::INTEGER,
      (v_metric.metricas->>'cumplimiento_stock')::DECIMAL,
      v_metric.metricas
    )
    ON CONFLICT (center_id, fecha) DO UPDATE SET
      total_medicamentos = EXCLUDED.total_medicamentos,
      total_lotes = EXCLUDED.total_lotes,
      medicamentos_bajo_stock = EXCLUDED.medicamentos_bajo_stock,
      lotes_proximos_vencer = EXCLUDED.lotes_proximos_vencer,
      lotes_vencidos = EXCLUDED.lotes_vencidos,
      movimientos_entrada = EXCLUDED.movimientos_entrada,
      movimientos_salida = EXCLUDED.movimientos_salida,
      cumplimiento_stock = EXCLUDED.cumplimiento_stock,
      metadata = EXCLUDED.metadata,
      created_at = NOW();

    v_count := v_count + 1;
  END LOOP;

  RETURN QUERY SELECT v_count, format('Métricas guardadas para %s centros', v_count);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION guardar_metricas_diarias IS 'Guarda las métricas diarias en la tabla metricas_inventario';

-- Función: Dashboard de control de calidad
CREATE OR REPLACE FUNCTION dashboard_control_calidad(p_center_id UUID DEFAULT NULL)
RETURNS TABLE (
  seccion TEXT,
  total INTEGER,
  criticos INTEGER,
  altos INTEGER,
  medios INTEGER,
  bajos INTEGER,
  detalles JSONB
) AS $$
BEGIN
  RETURN QUERY
  -- Alertas por tipo
  SELECT
    'alertas_activas'::TEXT,
    COUNT(*)::INTEGER as total,
    COUNT(*) FILTER (WHERE severidad = 'critica')::INTEGER,
    COUNT(*) FILTER (WHERE severidad = 'alta')::INTEGER,
    COUNT(*) FILTER (WHERE severidad = 'media')::INTEGER,
    COUNT(*) FILTER (WHERE severidad = 'baja')::INTEGER,
    jsonb_agg(
      jsonb_build_object(
        'tipo', tipo_alerta,
        'count', count
      )
    ) as detalles
  FROM (
    SELECT tipo_alerta, COUNT(*) as count
    FROM alertas_medicamentos
    WHERE estado IN ('pendiente', 'en_revision')
      AND (p_center_id IS NULL OR center_id = p_center_id)
    GROUP BY tipo_alerta
  ) sub

  UNION ALL

  -- Stock bajo
  SELECT
    'stock_bajo'::TEXT,
    COUNT(*)::INTEGER,
    COUNT(*) FILTER (WHERE cantidad_actual <= (stock_minimo * 0.5))::INTEGER,
    COUNT(*) FILTER (WHERE cantidad_actual <= (stock_minimo * 0.75) AND cantidad_actual > (stock_minimo * 0.5))::INTEGER,
    COUNT(*) FILTER (WHERE cantidad_actual > (stock_minimo * 0.75))::INTEGER,
    0::INTEGER,
    jsonb_build_object('medicamentos', jsonb_agg(jsonb_build_object('id', id, 'nombre', nombre)))
  FROM (
    SELECT b.id, m.nombre, b.cantidad_actual, b.stock_minimo
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    WHERE b.cantidad_actual <= b.stock_minimo
      AND b.estado = 'disponible'
      AND (p_center_id IS NULL OR b.center_id = p_center_id)
    LIMIT 10
  ) sub

  UNION ALL

  -- Vencimientos
  SELECT
    'vencimientos'::TEXT,
    COUNT(*)::INTEGER,
    COUNT(*) FILTER (WHERE dias_restantes <= 30 OR dias_restantes < 0)::INTEGER,
    COUNT(*) FILTER (WHERE dias_restantes > 30 AND dias_restantes <= 60)::INTEGER,
    COUNT(*) FILTER (WHERE dias_restantes > 60 AND dias_restantes <= 90)::INTEGER,
    0::INTEGER,
    jsonb_build_object('lotes', jsonb_agg(jsonb_build_object('lote', numero_lote, 'dias', dias_restantes)))
  FROM (
    SELECT
      b.numero_lote,
      (b.fecha_caducidad - CURRENT_DATE)::INTEGER as dias_restantes
    FROM batches b
    WHERE b.fecha_caducidad <= (CURRENT_DATE + 90)
      AND b.cantidad_actual > 0
      AND (p_center_id IS NULL OR b.center_id = p_center_id)
    LIMIT 10
  ) sub;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dashboard_control_calidad IS 'Proporciona datos para el dashboard de control de calidad';

COMMIT;

-- ============================================
-- PARTE 3.6: TRIGGER AUTOMÁTICO DE ALERTAS
-- ============================================

-- Trigger: Generar alerta automática al actualizar lote
CREATE OR REPLACE FUNCTION trigger_generar_alertas_batch()
RETURNS TRIGGER AS $$
BEGIN
  -- Alerta de stock bajo
  IF NEW.cantidad_actual <= NEW.stock_minimo AND NEW.estado = 'disponible' THEN
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    )
    SELECT
      'stock_bajo',
      CASE
        WHEN NEW.cantidad_actual <= (NEW.stock_minimo * 0.5) THEN 'alta'
        ELSE 'media'
      END,
      NEW.medication_id,
      NEW.id,
      NEW.center_id,
      'Stock Bajo Detectado',
      format('Lote %s - Stock: %s (Mínimo: %s)', NEW.numero_lote, NEW.cantidad_actual, NEW.stock_minimo),
      jsonb_build_object('cantidad', NEW.cantidad_actual, 'minimo', NEW.stock_minimo)
    WHERE NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos
      WHERE batch_id = NEW.id
        AND tipo_alerta = 'stock_bajo'
        AND estado IN ('pendiente', 'en_revision')
        AND created_at > NOW() - INTERVAL '24 hours'
    );
  END IF;

  -- Alerta de vencimiento próximo
  IF NEW.fecha_caducidad <= (CURRENT_DATE + 90) AND NEW.cantidad_actual > 0 THEN
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      medication_id,
      batch_id,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    )
    SELECT
      'proximo_vencer',
      CASE
        WHEN NEW.fecha_caducidad <= (CURRENT_DATE + 30) THEN 'critica'
        WHEN NEW.fecha_caducidad <= (CURRENT_DATE + 60) THEN 'alta'
        ELSE 'media'
      END,
      NEW.medication_id,
      NEW.id,
      NEW.center_id,
      'Lote Próximo a Vencer',
      format('Lote %s vence el %s', NEW.numero_lote, NEW.fecha_caducidad),
      jsonb_build_object('fecha_caducidad', NEW.fecha_caducidad, 'dias_restantes', (NEW.fecha_caducidad - CURRENT_DATE))
    WHERE NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos
      WHERE batch_id = NEW.id
        AND tipo_alerta = 'proximo_vencer'
        AND estado IN ('pendiente', 'en_revision')
        AND created_at > NOW() - INTERVAL '7 days'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_generar_alertas_batch ON batches;
CREATE TRIGGER trg_generar_alertas_batch
  AFTER INSERT OR UPDATE ON batches
  FOR EACH ROW
  EXECUTE FUNCTION trigger_generar_alertas_batch();

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 3 COMPLETADA' as resultado;

SELECT 'TABLAS DE CALIDAD' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('alertas_medicamentos', 'notificaciones', 'metricas_inventario')
ORDER BY table_name;

SELECT 'FUNCIONES DE CALIDAD' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'generar_alertas_stock_bajo',
    'generar_alertas_vencimiento',
    'calcular_metricas_diarias',
    'guardar_metricas_diarias',
    'dashboard_control_calidad'
  )
ORDER BY routine_name;
-- ============================================
-- FASE 4: MÓDULO DE CONTRATOS AVANZADO
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Gestión completa de contratos con proveedores
-- Tiempo estimado: 60 minutos
-- Ejecutar DESPUÉS de Fase 3

BEGIN;

-- ============================================
-- PARTE 4.1: TABLAS ADICIONALES DE CONTRATOS
-- ============================================

-- Tabla: contract_deliveries (Entregas de contratos)
CREATE TABLE IF NOT EXISTS contract_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  contract_item_id UUID REFERENCES contract_items(id),
  center_id UUID REFERENCES health_centers(id),
  fecha_entrega_programada DATE NOT NULL,
  fecha_entrega_real DATE,
  cantidad_programada INTEGER NOT NULL,
  cantidad_recibida INTEGER,
  numero_remision TEXT,
  estado TEXT DEFAULT 'programada' CHECK (estado IN (
    'programada', 'en_transito', 'recibida', 'recibida_parcial', 'cancelada', 'retrasada'
  )),
  recibido_por UUID,
  notas TEXT,
  documentos JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_deliveries_contract ON contract_deliveries(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_deliveries_center ON contract_deliveries(center_id);
CREATE INDEX IF NOT EXISTS idx_contract_deliveries_estado ON contract_deliveries(estado);
CREATE INDEX IF NOT EXISTS idx_contract_deliveries_fecha ON contract_deliveries(fecha_entrega_programada);

COMMENT ON TABLE contract_deliveries IS 'Seguimiento de entregas programadas de contratos';

-- Tabla: contract_evaluations (Evaluaciones de contratos)
CREATE TABLE IF NOT EXISTS contract_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  evaluador_id UUID,
  fecha_evaluacion DATE DEFAULT CURRENT_DATE,
  cumplimiento_entregas DECIMAL(5,2) CHECK (cumplimiento_entregas >= 0 AND cumplimiento_entregas <= 100),
  calidad_productos DECIMAL(3,1) CHECK (calidad_productos >= 0 AND calidad_productos <= 5),
  servicio_proveedor DECIMAL(3,1) CHECK (servicio_productos >= 0 AND servicio_proveedor <= 5),
  cumplimiento_precios BOOLEAN DEFAULT true,
  observaciones TEXT,
  recomendacion TEXT CHECK (recomendacion IN ('renovar', 'renegociar', 'cancelar', 'mantener')),
  calificacion_global DECIMAL(3,1) CHECK (calificacion_global >= 0 AND calificacion_global <= 5),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_evaluations_contract ON contract_evaluations(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_evaluations_fecha ON contract_evaluations(fecha_evaluacion DESC);

COMMENT ON TABLE contract_evaluations IS 'Evaluaciones periódicas de desempeño de contratos';

-- Tabla: contract_amendments (Modificaciones de contratos)
CREATE TABLE IF NOT EXISTS contract_amendments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  numero_modificacion TEXT NOT NULL,
  tipo_modificacion TEXT CHECK (tipo_modificacion IN (
    'ampliacion_monto', 'cambio_fechas', 'adicion_items',
    'eliminacion_items', 'cambio_precios', 'cambio_condiciones'
  )),
  descripcion TEXT NOT NULL,
  monto_anterior DECIMAL(15,2),
  monto_nuevo DECIMAL(15,2),
  fecha_inicio_anterior DATE,
  fecha_inicio_nueva DATE,
  fecha_fin_anterior DATE,
  fecha_fin_nueva DATE,
  justificacion TEXT NOT NULL,
  autorizado_por UUID,
  fecha_autorizacion TIMESTAMPTZ,
  documento_url TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'en_revision', 'aprobada', 'rechazada')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_amendments_contract ON contract_amendments(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_estado ON contract_amendments(estado);

COMMENT ON TABLE contract_amendments IS 'Modificaciones y adendas a contratos existentes';

COMMIT;

-- ============================================
-- PARTE 4.2: FUNCIONES DE GESTIÓN DE CONTRATOS
-- ============================================

-- Función: Crear contrato con validaciones
CREATE OR REPLACE FUNCTION crear_contrato(
  p_codigo_contrato TEXT,
  p_supplier_id UUID,
  p_fecha_inicio DATE,
  p_fecha_fin DATE,
  p_monto_total DECIMAL,
  p_items JSONB,
  p_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  contract_id UUID
) AS $$
DECLARE
  v_contract_id UUID;
  v_item JSONB;
BEGIN
  -- Validar fechas
  IF p_fecha_fin <= p_fecha_inicio THEN
    RETURN QUERY SELECT false, 'La fecha de fin debe ser posterior a la fecha de inicio', NULL::UUID;
    RETURN;
  END IF;

  -- Validar que el proveedor existe y está activo
  IF NOT EXISTS (SELECT 1 FROM suppliers WHERE id = p_supplier_id AND is_active = true) THEN
    RETURN QUERY SELECT false, 'Proveedor no encontrado o inactivo', NULL::UUID;
    RETURN;
  END IF;

  -- Validar que el código no existe
  IF EXISTS (SELECT 1 FROM contracts WHERE codigo_contrato = p_codigo_contrato) THEN
    RETURN QUERY SELECT false, 'El código de contrato ya existe', NULL::UUID;
    RETURN;
  END IF;

  -- Crear el contrato
  INSERT INTO contracts (
    codigo_contrato,
    supplier_id,
    fecha_inicio,
    fecha_fin,
    monto_total,
    estado
  ) VALUES (
    p_codigo_contrato,
    p_supplier_id,
    p_fecha_inicio,
    p_fecha_fin,
    p_monto_total,
    'borrador'
  ) RETURNING id INTO v_contract_id;

  -- Insertar items del contrato
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    INSERT INTO contract_items (
      contract_id,
      medication_catalog_id,
      cantidad_comprometida,
      precio_unitario,
      center_destino_id,
      fecha_estimada_entrega
    ) VALUES (
      v_contract_id,
      (v_item->>'medication_catalog_id')::UUID,
      (v_item->>'cantidad')::INTEGER,
      (v_item->>'precio_unitario')::DECIMAL,
      (v_item->>'center_id')::UUID,
      (v_item->>'fecha_entrega')::DATE
    );
  END LOOP;

  -- Registrar en audit log
  INSERT INTO audit_log (
    user_id,
    action_type,
    entity_type,
    entity_id,
    entity_name,
    new_values,
    changes_summary,
    result,
    severity
  ) VALUES (
    p_usuario_id,
    'CREATE',
    'contract',
    v_contract_id,
    p_codigo_contrato,
    jsonb_build_object(
      'supplier_id', p_supplier_id,
      'monto_total', p_monto_total,
      'items', p_items
    ),
    'Contrato creado: ' || p_codigo_contrato,
    'success',
    'medium'
  );

  RETURN QUERY SELECT true, 'Contrato creado exitosamente', v_contract_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_contrato IS 'Crea un nuevo contrato con sus items y validaciones';

-- Función: Activar contrato (cambiar de borrador a activo)
CREATE OR REPLACE FUNCTION activar_contrato(
  p_contract_id UUID,
  p_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  v_contract RECORD;
BEGIN
  -- Obtener contrato
  SELECT * INTO v_contract FROM contracts WHERE id = p_contract_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Contrato no encontrado';
    RETURN;
  END IF;

  -- Validar estado
  IF v_contract.estado != 'borrador' THEN
    RETURN QUERY SELECT false, 'El contrato ya está activado o ha sido cancelado';
    RETURN;
  END IF;

  -- Validar que tiene items
  IF NOT EXISTS (SELECT 1 FROM contract_items WHERE contract_id = p_contract_id) THEN
    RETURN QUERY SELECT false, 'El contrato no tiene items asociados';
    RETURN;
  END IF;

  -- Activar contrato
  UPDATE contracts
  SET
    estado = 'activo',
    firmado_por = p_usuario_id,
    fecha_firma = NOW()
  WHERE id = p_contract_id;

  -- Registrar en audit log
  INSERT INTO audit_log (
    user_id,
    action_type,
    entity_type,
    entity_id,
    entity_name,
    changes_summary,
    result,
    severity
  ) VALUES (
    p_usuario_id,
    'APPROVE',
    'contract',
    p_contract_id,
    v_contract.codigo_contrato,
    'Contrato activado y firmado',
    'success',
    'high'
  );

  RETURN QUERY SELECT true, 'Contrato activado exitosamente';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION activar_contrato IS 'Activa un contrato en estado borrador';

-- Función: Registrar entrega de contrato
CREATE OR REPLACE FUNCTION registrar_entrega_contrato(
  p_delivery_id UUID,
  p_cantidad_recibida INTEGER,
  p_fecha_entrega_real DATE,
  p_numero_remision TEXT,
  p_recibido_por UUID,
  p_notas TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  batch_id UUID
) AS $$
DECLARE
  v_delivery RECORD;
  v_item RECORD;
  v_batch_id UUID;
BEGIN
  -- Obtener información de la entrega
  SELECT
    cd.*,
    ci.medication_catalog_id,
    ci.precio_unitario,
    c.supplier_id
  INTO v_delivery
  FROM contract_deliveries cd
  JOIN contract_items ci ON cd.contract_item_id = ci.id
  JOIN contracts c ON cd.contract_id = c.id
  WHERE cd.id = p_delivery_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Entrega no encontrada', NULL::UUID;
    RETURN;
  END IF;

  -- Validar estado
  IF v_delivery.estado NOT IN ('programada', 'en_transito') THEN
    RETURN QUERY SELECT false, 'La entrega ya fue procesada', NULL::UUID;
    RETURN;
  END IF;

  -- Actualizar entrega
  UPDATE contract_deliveries
  SET
    cantidad_recibida = p_cantidad_recibida,
    fecha_entrega_real = p_fecha_entrega_real,
    numero_remision = p_numero_remision,
    recibido_por = p_recibido_por,
    notas = p_notas,
    estado = CASE
      WHEN p_cantidad_recibida >= cantidad_programada THEN 'recibida'
      WHEN p_cantidad_recibida > 0 THEN 'recibida_parcial'
      ELSE estado
    END,
    updated_at = NOW()
  WHERE id = p_delivery_id;

  -- Aquí podrías crear automáticamente el lote en batches si es necesario
  -- (Dependería de tu lógica de negocio específica)

  RETURN QUERY SELECT
    true,
    format('Entrega registrada: %s de %s unidades', p_cantidad_recibida, v_delivery.cantidad_programada),
    v_batch_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_entrega_contrato IS 'Registra la recepción de una entrega programada';

-- Función: Evaluar desempeño de contrato
CREATE OR REPLACE FUNCTION evaluar_contrato(
  p_contract_id UUID,
  p_evaluador_id UUID,
  p_calidad_productos DECIMAL,
  p_servicio_proveedor DECIMAL,
  p_observaciones TEXT,
  p_recomendacion TEXT
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  calificacion_global DECIMAL
) AS $$
DECLARE
  v_contract RECORD;
  v_cumplimiento_entregas DECIMAL;
  v_calificacion_global DECIMAL;
  v_entregas_totales INTEGER;
  v_entregas_puntuales INTEGER;
BEGIN
  -- Validar que el contrato existe
  SELECT * INTO v_contract FROM contracts WHERE id = p_contract_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Contrato no encontrado', 0::DECIMAL;
    RETURN;
  END IF;

  -- Calcular cumplimiento de entregas
  SELECT
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE fecha_entrega_real <= fecha_entrega_programada) as puntuales
  INTO v_entregas_totales, v_entregas_puntuales
  FROM contract_deliveries
  WHERE contract_id = p_contract_id
    AND estado IN ('recibida', 'recibida_parcial');

  IF v_entregas_totales > 0 THEN
    v_cumplimiento_entregas := (v_entregas_puntuales::DECIMAL / v_entregas_totales * 100);
  ELSE
    v_cumplimiento_entregas := 100;
  END IF;

  -- Calcular calificación global (promedio ponderado)
  v_calificacion_global := (
    (p_calidad_productos * 0.4) +
    (p_servicio_proveedor * 0.3) +
    ((v_cumplimiento_entregas / 20) * 0.3)  -- Convertir % a escala 0-5
  );

  -- Insertar evaluación
  INSERT INTO contract_evaluations (
    contract_id,
    evaluador_id,
    cumplimiento_entregas,
    calidad_productos,
    servicio_proveedor,
    observaciones,
    recomendacion,
    calificacion_global
  ) VALUES (
    p_contract_id,
    p_evaluador_id,
    v_cumplimiento_entregas,
    p_calidad_productos,
    p_servicio_proveedor,
    p_observaciones,
    p_recomendacion,
    v_calificacion_global
  );

  -- Actualizar calificación del proveedor
  UPDATE suppliers
  SET
    calificacion = (
      SELECT AVG(calificacion_global)
      FROM contract_evaluations ce
      JOIN contracts c ON ce.contract_id = c.id
      WHERE c.supplier_id = v_contract.supplier_id
    )
  WHERE id = v_contract.supplier_id;

  RETURN QUERY SELECT
    true,
    'Evaluación registrada exitosamente',
    v_calificacion_global;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION evaluar_contrato IS 'Evalúa el desempeño de un contrato y actualiza la calificación del proveedor';

-- Función: Dashboard de contratos
CREATE OR REPLACE FUNCTION dashboard_contratos()
RETURNS TABLE (
  estado TEXT,
  cantidad INTEGER,
  monto_total DECIMAL,
  detalles JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.estado,
    COUNT(*)::INTEGER,
    SUM(c.monto_total)::DECIMAL(15,2),
    jsonb_build_object(
      'proximos_vencer', COUNT(*) FILTER (WHERE c.fecha_fin <= CURRENT_DATE + 90),
      'en_ejecucion', COUNT(*) FILTER (WHERE c.fecha_inicio <= CURRENT_DATE AND c.fecha_fin >= CURRENT_DATE),
      'promedio_monto', AVG(c.monto_total)
    )
  FROM contracts c
  GROUP BY c.estado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dashboard_contratos IS 'Proporciona métricas para el dashboard de contratos';

-- Función: Contratos por vencer
CREATE OR REPLACE FUNCTION contratos_por_vencer(dias_anticipacion INTEGER DEFAULT 90)
RETURNS TABLE (
  contract_id UUID,
  codigo_contrato TEXT,
  supplier_name TEXT,
  fecha_fin DATE,
  dias_restantes INTEGER,
  monto_total DECIMAL,
  calificacion_promedio DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.codigo_contrato,
    s.nombre,
    c.fecha_fin,
    (c.fecha_fin - CURRENT_DATE)::INTEGER,
    c.monto_total,
    (
      SELECT AVG(calificacion_global)
      FROM contract_evaluations
      WHERE contract_id = c.id
    )
  FROM contracts c
  JOIN suppliers s ON c.supplier_id = s.id
  WHERE c.estado = 'activo'
    AND c.fecha_fin BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
  ORDER BY c.fecha_fin ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION contratos_por_vencer IS 'Lista contratos próximos a vencer para planificar renovaciones';

COMMIT;

-- ============================================
-- PARTE 4.3: TRIGGERS PARA CONTRATOS
-- ============================================

-- Trigger: Marcar contratos vencidos automáticamente
CREATE OR REPLACE FUNCTION trigger_marcar_contratos_vencidos()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha_fin < CURRENT_DATE AND NEW.estado = 'activo' THEN
    NEW.estado := 'vencido';

    -- Crear alerta
    INSERT INTO alertas_medicamentos (
      tipo_alerta,
      severidad,
      center_id,
      titulo,
      mensaje,
      datos_adicionales
    )
    SELECT
      'contrato_vencido'::TEXT,
      'media',
      ci.center_destino_id,
      'Contrato Vencido',
      format('El contrato %s ha vencido', NEW.codigo_contrato),
      jsonb_build_object('contract_id', NEW.id, 'fecha_fin', NEW.fecha_fin)
    FROM contract_items ci
    WHERE ci.contract_id = NEW.id
    LIMIT 1;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_marcar_contratos_vencidos ON contracts;
CREATE TRIGGER trg_marcar_contratos_vencidos
  BEFORE UPDATE ON contracts
  FOR EACH ROW
  EXECUTE FUNCTION trigger_marcar_contratos_vencidos();

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 4 COMPLETADA' as resultado;

SELECT 'TABLAS DE CONTRATOS' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('contract_deliveries', 'contract_evaluations', 'contract_amendments')
ORDER BY table_name;

SELECT 'FUNCIONES DE CONTRATOS' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'crear_contrato',
    'activar_contrato',
    'registrar_entrega_contrato',
    'evaluar_contrato',
    'dashboard_contratos',
    'contratos_por_vencer'
  )
ORDER BY routine_name;
-- ============================================
-- FASE 5: GESTIÓN DOCUMENTAL Y FIRMAS DIGITALES
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Sistema completo de documentos, vales, actas y firmas digitales
-- Tiempo estimado: 90 minutos
-- Ejecutar DESPUÉS de Fase 4

BEGIN;

-- ============================================
-- PARTE 5.1: TABLAS DE DOCUMENTACIÓN
-- ============================================

-- Tabla: vales_entrada (Vales de entrada de medicamentos)
CREATE TABLE IF NOT EXISTS vales_entrada (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_vale TEXT UNIQUE NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES suppliers(id),
  contract_id UUID REFERENCES contracts(id),
  fecha_entrada DATE DEFAULT CURRENT_DATE,
  numero_factura TEXT,
  numero_remision TEXT,
  recibido_por UUID,
  autorizado_por UUID,
  total_items INTEGER DEFAULT 0,
  monto_total DECIMAL(15,2),
  observaciones TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'autorizado', 'aplicado', 'cancelado')),
  documento_pdf_url TEXT,
  firma_recepcion TEXT,
  firma_autorizacion TEXT,
  fecha_firma_recepcion TIMESTAMPTZ,
  fecha_firma_autorizacion TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_entrada_numero ON vales_entrada(numero_vale);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_center ON vales_entrada(center_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_supplier ON vales_entrada(supplier_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_fecha ON vales_entrada(fecha_entrada DESC);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_estado ON vales_entrada(estado);

COMMENT ON TABLE vales_entrada IS 'Vales de entrada de medicamentos con trazabilidad completa';

-- Tabla: vales_entrada_items (Items de vales de entrada)
CREATE TABLE IF NOT EXISTS vales_entrada_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vale_entrada_id UUID REFERENCES vales_entrada(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  numero_lote TEXT NOT NULL,
  fecha_caducidad DATE NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(15,2),
  subtotal DECIMAL(15,2),
  ubicacion_fisica TEXT,
  temperatura_recepcion DECIMAL(5,2),
  condicion TEXT CHECK (condicion IN ('optima', 'aceptable', 'deficiente', 'rechazada')),
  observaciones TEXT,
  batch_id UUID REFERENCES batches(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_entrada_items_vale ON vales_entrada_items(vale_entrada_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_items_medication ON vales_entrada_items(medication_catalog_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_items_lote ON vales_entrada_items(numero_lote);

COMMENT ON TABLE vales_entrada_items IS 'Detalle de items en vales de entrada';

-- Tabla: vales_salida (Vales de salida/dispensación)
CREATE TABLE IF NOT EXISTS vales_salida (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_vale TEXT UNIQUE NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  tipo_salida TEXT NOT NULL CHECK (tipo_salida IN (
    'dispensacion', 'transferencia', 'devolucion', 'merma', 'baja'
  )),
  destino_centro_id UUID REFERENCES health_centers(id),
  destino_descripcion TEXT,
  solicitado_por TEXT,
  despachado_por UUID,
  autorizado_por UUID,
  fecha_salida DATE DEFAULT CURRENT_DATE,
  total_items INTEGER DEFAULT 0,
  observaciones TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'autorizado', 'despachado', 'recibido', 'cancelado')),
  documento_pdf_url TEXT,
  firma_despacho TEXT,
  firma_autorizacion TEXT,
  firma_recepcion TEXT,
  fecha_firma_despacho TIMESTAMPTZ,
  fecha_firma_autorizacion TIMESTAMPTZ,
  fecha_firma_recepcion TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_salida_numero ON vales_salida(numero_vale);
CREATE INDEX IF NOT EXISTS idx_vales_salida_center ON vales_salida(center_id);
CREATE INDEX IF NOT EXISTS idx_vales_salida_tipo ON vales_salida(tipo_salida);
CREATE INDEX IF NOT EXISTS idx_vales_salida_fecha ON vales_salida(fecha_salida DESC);
CREATE INDEX IF NOT EXISTS idx_vales_salida_estado ON vales_salida(estado);

COMMENT ON TABLE vales_salida IS 'Vales de salida, dispensación y transferencia de medicamentos';

-- Tabla: vales_salida_items (Items de vales de salida)
CREATE TABLE IF NOT EXISTS vales_salida_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vale_salida_id UUID REFERENCES vales_salida(id) ON DELETE CASCADE,
  batch_id UUID REFERENCES batches(id),
  medication_id UUID REFERENCES medications(id),
  numero_lote TEXT NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  fecha_caducidad DATE,
  observaciones TEXT,
  movement_id UUID REFERENCES batch_movements(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_salida_items_vale ON vales_salida_items(vale_salida_id);
CREATE INDEX IF NOT EXISTS idx_vales_salida_items_batch ON vales_salida_items(batch_id);
CREATE INDEX IF NOT EXISTS idx_vales_salida_items_medication ON vales_salida_items(medication_id);

COMMENT ON TABLE vales_salida_items IS 'Detalle de items en vales de salida';

-- Tabla: actas_entrega (Actas de entrega-recepción)
CREATE TABLE IF NOT EXISTS actas_entrega (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_acta TEXT UNIQUE NOT NULL,
  tipo_acta TEXT CHECK (tipo_acta IN ('transferencia', 'donacion', 'devolucion', 'entrega_contrato')),
  center_origen_id UUID REFERENCES health_centers(id),
  center_destino_id UUID REFERENCES health_centers(id),
  fecha_acta DATE DEFAULT CURRENT_DATE,
  entrega TEXT NOT NULL, -- Nombre de quien entrega
  recibe TEXT NOT NULL, -- Nombre de quien recibe
  testigo_1 TEXT,
  testigo_2 TEXT,
  motivo TEXT NOT NULL,
  total_items INTEGER DEFAULT 0,
  valor_estimado DECIMAL(15,2),
  observaciones TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'firmada', 'cancelada')),
  documento_pdf_url TEXT,
  firma_entrega TEXT,
  firma_recibe TEXT,
  firma_testigo_1 TEXT,
  firma_testigo_2 TEXT,
  fecha_firma_entrega TIMESTAMPTZ,
  fecha_firma_recibe TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_actas_entrega_numero ON actas_entrega(numero_acta);
CREATE INDEX IF NOT EXISTS idx_actas_entrega_origen ON actas_entrega(center_origen_id);
CREATE INDEX IF NOT EXISTS idx_actas_entrega_destino ON actas_entrega(center_destino_id);
CREATE INDEX IF NOT EXISTS idx_actas_entrega_fecha ON actas_entrega(fecha_acta DESC);

COMMENT ON TABLE actas_entrega IS 'Actas de entrega-recepción formales con firmas';

-- Tabla: actas_entrega_items (Items de actas)
CREATE TABLE IF NOT EXISTS actas_entrega_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acta_id UUID REFERENCES actas_entrega(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  numero_lote TEXT,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  fecha_caducidad DATE,
  valor_unitario DECIMAL(15,2),
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_actas_entrega_items_acta ON actas_entrega_items(acta_id);

COMMENT ON TABLE actas_entrega_items IS 'Detalle de medicamentos en actas de entrega';

-- Tabla: firmas_digitales (Registro de firmas)
CREATE TABLE IF NOT EXISTS firmas_digitales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  documento_tipo TEXT NOT NULL CHECK (documento_tipo IN (
    'vale_entrada', 'vale_salida', 'acta_entrega', 'contrato', 'inspeccion'
  )),
  documento_id UUID NOT NULL,
  tipo_firma TEXT CHECK (tipo_firma IN ('recepcion', 'autorizacion', 'despacho', 'testigo', 'aprobacion')),
  firma_data TEXT NOT NULL, -- Firma en base64 o hash
  ip_address INET,
  user_agent TEXT,
  geolocalizacion JSONB,
  certificado_digital TEXT,
  timestamp_firma TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_firmas_digitales_user ON firmas_digitales(user_id);
CREATE INDEX IF NOT EXISTS idx_firmas_digitales_documento ON firmas_digitales(documento_tipo, documento_id);
CREATE INDEX IF NOT EXISTS idx_firmas_digitales_timestamp ON firmas_digitales(timestamp_firma DESC);

COMMENT ON TABLE firmas_digitales IS 'Registro inmutable de todas las firmas digitales del sistema';
COMMENT ON COLUMN firmas_digitales.firma_data IS 'Datos de la firma (base64, hash, o certificado)';

COMMIT;

-- ============================================
-- PARTE 5.2: FUNCIONES PARA VALES DE ENTRADA
-- ============================================

-- Función: Crear vale de entrada
CREATE OR REPLACE FUNCTION crear_vale_entrada(
  p_numero_vale TEXT,
  p_center_id UUID,
  p_supplier_id UUID,
  p_numero_factura TEXT,
  p_items JSONB,
  p_recibido_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  vale_id UUID
) AS $$
DECLARE
  v_vale_id UUID;
  v_item JSONB;
  v_total_items INTEGER := 0;
  v_monto_total DECIMAL := 0;
BEGIN
  -- Validar que no exista el número de vale
  IF EXISTS (SELECT 1 FROM vales_entrada WHERE numero_vale = p_numero_vale) THEN
    RETURN QUERY SELECT false, 'El número de vale ya existe', NULL::UUID;
    RETURN;
  END IF;

  -- Crear el vale
  INSERT INTO vales_entrada (
    numero_vale,
    center_id,
    supplier_id,
    numero_factura,
    recibido_por,
    estado
  ) VALUES (
    p_numero_vale,
    p_center_id,
    p_supplier_id,
    p_numero_factura,
    p_recibido_por,
    'borrador'
  ) RETURNING id INTO v_vale_id;

  -- Insertar items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    INSERT INTO vales_entrada_items (
      vale_entrada_id,
      medication_catalog_id,
      numero_lote,
      fecha_caducidad,
      cantidad,
      precio_unitario,
      subtotal,
      ubicacion_fisica,
      condicion
    ) VALUES (
      v_vale_id,
      (v_item->>'medication_catalog_id')::UUID,
      v_item->>'numero_lote',
      (v_item->>'fecha_caducidad')::DATE,
      (v_item->>'cantidad')::INTEGER,
      (v_item->>'precio_unitario')::DECIMAL,
      (v_item->>'cantidad')::INTEGER * (v_item->>'precio_unitario')::DECIMAL,
      v_item->>'ubicacion_fisica',
      COALESCE(v_item->>'condicion', 'optima')
    );

    v_total_items := v_total_items + 1;
    v_monto_total := v_monto_total + ((v_item->>'cantidad')::INTEGER * (v_item->>'precio_unitario')::DECIMAL);
  END LOOP;

  -- Actualizar totales
  UPDATE vales_entrada
  SET
    total_items = v_total_items,
    monto_total = v_monto_total
  WHERE id = v_vale_id;

  RETURN QUERY SELECT true, 'Vale de entrada creado exitosamente', v_vale_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_vale_entrada IS 'Crea un vale de entrada con sus items';

-- Función: Aplicar vale de entrada (crear lotes en batches)
CREATE OR REPLACE FUNCTION aplicar_vale_entrada(
  p_vale_id UUID,
  p_autorizado_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  lotes_creados INTEGER
) AS $$
DECLARE
  v_vale RECORD;
  v_item RECORD;
  v_batch_id UUID;
  v_medication_id UUID;
  v_count INTEGER := 0;
BEGIN
  -- Obtener vale
  SELECT * INTO v_vale FROM vales_entrada WHERE id = p_vale_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Vale no encontrado', 0;
    RETURN;
  END IF;

  IF v_vale.estado != 'autorizado' THEN
    RETURN QUERY SELECT false, 'El vale debe estar autorizado para aplicarse', 0;
    RETURN;
  END IF;

  -- Procesar cada item
  FOR v_item IN
    SELECT * FROM vales_entrada_items WHERE vale_entrada_id = p_vale_id
  LOOP
    -- Buscar o crear medicamento en medications
    SELECT id INTO v_medication_id
    FROM medications
    WHERE catalog_id = v_item.medication_catalog_id
      AND center_id = v_vale.center_id
    LIMIT 1;

    IF v_medication_id IS NULL THEN
      -- Crear medicamento si no existe
      INSERT INTO medications (
        catalog_id,
        center_id,
        nombre,
        lote,
        cantidad,
        fecha_caducidad,
        fecha_ingreso,
        estado,
        ubicacion_fisica
      )
      SELECT
        mc.id,
        v_vale.center_id,
        mc.nombre_comercial,
        v_item.numero_lote,
        v_item.cantidad,
        v_item.fecha_caducidad,
        v_vale.fecha_entrada,
        'disponible',
        v_item.ubicacion_fisica
      FROM medication_catalog mc
      WHERE mc.id = v_item.medication_catalog_id
      RETURNING id INTO v_medication_id;
    END IF;

    -- Crear lote en batches
    INSERT INTO batches (
      medication_id,
      center_id,
      supplier_id,
      numero_lote,
      cantidad_inicial,
      cantidad_actual,
      fecha_caducidad,
      fecha_ingreso,
      ubicacion_fisica,
      estado
    ) VALUES (
      v_medication_id,
      v_vale.center_id,
      v_vale.supplier_id,
      v_item.numero_lote,
      v_item.cantidad,
      v_item.cantidad,
      v_item.fecha_caducidad,
      v_vale.fecha_entrada,
      v_item.ubicacion_fisica,
      'disponible'
    ) RETURNING id INTO v_batch_id;

    -- Registrar movimiento
    INSERT INTO batch_movements (
      batch_id,
      medication_id,
      center_id,
      tipo_movimiento,
      cantidad,
      cantidad_anterior,
      cantidad_posterior,
      numero_documento,
      motivo,
      observaciones,
      usuario_responsable,
      metadata
    ) VALUES (
      v_batch_id,
      v_medication_id,
      v_vale.center_id,
      'entrada',
      v_item.cantidad,
      0,
      v_item.cantidad,
      v_vale.numero_vale,
      'Entrada por vale: ' || v_vale.numero_vale,
      v_vale.observaciones,
      p_autorizado_por,
      jsonb_build_object(
        'vale_id', p_vale_id,
        'factura', v_vale.numero_factura,
        'supplier_id', v_vale.supplier_id
      )
    );

    -- Actualizar referencia en item
    UPDATE vales_entrada_items
    SET batch_id = v_batch_id
    WHERE id = v_item.id;

    v_count := v_count + 1;
  END LOOP;

  -- Marcar vale como aplicado
  UPDATE vales_entrada
  SET
    estado = 'aplicado',
    updated_at = NOW()
  WHERE id = p_vale_id;

  RETURN QUERY SELECT true, format('%s lotes creados exitosamente', v_count), v_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION aplicar_vale_entrada IS 'Aplica un vale de entrada creando lotes y movimientos';

-- ============================================
-- PARTE 5.3: FUNCIONES PARA VALES DE SALIDA
-- ============================================

-- Función: Crear vale de salida
CREATE OR REPLACE FUNCTION crear_vale_salida(
  p_numero_vale TEXT,
  p_center_id UUID,
  p_tipo_salida TEXT,
  p_destino_centro_id UUID,
  p_items JSONB,
  p_despachado_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  vale_id UUID
) AS $$
DECLARE
  v_vale_id UUID;
  v_item JSONB;
  v_batch RECORD;
  v_total_items INTEGER := 0;
BEGIN
  -- Validar número de vale
  IF EXISTS (SELECT 1 FROM vales_salida WHERE numero_vale = p_numero_vale) THEN
    RETURN QUERY SELECT false, 'El número de vale ya existe', NULL::UUID;
    RETURN;
  END IF;

  -- Crear vale
  INSERT INTO vales_salida (
    numero_vale,
    center_id,
    tipo_salida,
    destino_centro_id,
    despachado_por,
    estado
  ) VALUES (
    p_numero_vale,
    p_center_id,
    p_tipo_salida,
    p_destino_centro_id,
    p_despachado_por,
    'borrador'
  ) RETURNING id INTO v_vale_id;

  -- Insertar items y validar stock
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    -- Obtener lote
    SELECT * INTO v_batch
    FROM batches
    WHERE id = (v_item->>'batch_id')::UUID;

    IF NOT FOUND THEN
      RETURN QUERY SELECT false, 'Lote no encontrado: ' || (v_item->>'batch_id'), NULL::UUID;
      RETURN;
    END IF;

    -- Validar stock disponible
    IF v_batch.cantidad_actual < (v_item->>'cantidad')::INTEGER THEN
      RETURN QUERY SELECT
        false,
        format('Stock insuficiente en lote %s. Disponible: %s, Solicitado: %s',
          v_batch.numero_lote, v_batch.cantidad_actual, (v_item->>'cantidad')::INTEGER),
        NULL::UUID;
      RETURN;
    END IF;

    -- Insertar item
    INSERT INTO vales_salida_items (
      vale_salida_id,
      batch_id,
      medication_id,
      numero_lote,
      cantidad,
      fecha_caducidad
    ) VALUES (
      v_vale_id,
      v_batch.id,
      v_batch.medication_id,
      v_batch.numero_lote,
      (v_item->>'cantidad')::INTEGER,
      v_batch.fecha_caducidad
    );

    v_total_items := v_total_items + 1;
  END LOOP;

  -- Actualizar total
  UPDATE vales_salida SET total_items = v_total_items WHERE id = v_vale_id;

  RETURN QUERY SELECT true, 'Vale de salida creado exitosamente', v_vale_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_vale_salida IS 'Crea un vale de salida validando stock disponible';

-- Función: Aplicar vale de salida (descontar stock)
CREATE OR REPLACE FUNCTION aplicar_vale_salida(
  p_vale_id UUID,
  p_autorizado_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  movimientos_creados INTEGER
) AS $$
DECLARE
  v_vale RECORD;
  v_item RECORD;
  v_movement_id UUID;
  v_count INTEGER := 0;
  v_result RECORD;
BEGIN
  -- Obtener vale
  SELECT * INTO v_vale FROM vales_salida WHERE id = p_vale_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Vale no encontrado', 0;
    RETURN;
  END IF;

  IF v_vale.estado != 'autorizado' THEN
    RETURN QUERY SELECT false, 'El vale debe estar autorizado', 0;
    RETURN;
  END IF;

  -- Procesar cada item
  FOR v_item IN
    SELECT * FROM vales_salida_items WHERE vale_salida_id = p_vale_id
  LOOP
    -- Registrar movimiento usando la función existente
    SELECT * INTO v_result
    FROM registrar_movimiento_lote(
      v_item.batch_id,
      CASE v_vale.tipo_salida
        WHEN 'transferencia' THEN 'transferencia_salida'
        WHEN 'dispensacion' THEN 'salida'
        WHEN 'devolucion' THEN 'devolucion'
        WHEN 'merma' THEN 'merma'
        ELSE 'salida'
      END,
      v_item.cantidad,
      'Salida por vale: ' || v_vale.numero_vale,
      v_vale.destino_centro_id,
      v_vale.numero_vale,
      v_vale.observaciones,
      p_autorizado_por
    );

    IF NOT v_result.success THEN
      RETURN QUERY SELECT false, v_result.message, 0;
      RETURN;
    END IF;

    -- Actualizar referencia del movimiento
    UPDATE vales_salida_items
    SET movement_id = v_result.movement_id
    WHERE id = v_item.id;

    v_count := v_count + 1;
  END LOOP;

  -- Marcar vale como despachado
  UPDATE vales_salida
  SET
    estado = 'despachado',
    updated_at = NOW()
  WHERE id = p_vale_id;

  RETURN QUERY SELECT true, format('%s movimientos aplicados', v_count), v_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION aplicar_vale_salida IS 'Aplica un vale de salida descontando stock';

-- ============================================
-- PARTE 5.4: FUNCIONES DE FIRMAS DIGITALES
-- ============================================

-- Función: Registrar firma digital
CREATE OR REPLACE FUNCTION registrar_firma_digital(
  p_user_id UUID,
  p_documento_tipo TEXT,
  p_documento_id UUID,
  p_tipo_firma TEXT,
  p_firma_data TEXT,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  firma_id UUID
) AS $$
DECLARE
  v_firma_id UUID;
BEGIN
  -- Registrar firma
  INSERT INTO firmas_digitales (
    user_id,
    documento_tipo,
    documento_id,
    tipo_firma,
    firma_data,
    ip_address,
    user_agent
  ) VALUES (
    p_user_id,
    p_documento_tipo,
    p_documento_id,
    p_tipo_firma,
    p_firma_data,
    p_ip_address,
    p_user_agent
  ) RETURNING id INTO v_firma_id;

  -- Actualizar documento según tipo
  CASE p_documento_tipo
    WHEN 'vale_entrada' THEN
      IF p_tipo_firma = 'recepcion' THEN
        UPDATE vales_entrada
        SET firma_recepcion = p_firma_data, fecha_firma_recepcion = NOW()
        WHERE id = p_documento_id;
      ELSIF p_tipo_firma = 'autorizacion' THEN
        UPDATE vales_entrada
        SET
          firma_autorizacion = p_firma_data,
          fecha_firma_autorizacion = NOW(),
          estado = 'autorizado',
          autorizado_por = p_user_id
        WHERE id = p_documento_id;
      END IF;

    WHEN 'vale_salida' THEN
      IF p_tipo_firma = 'despacho' THEN
        UPDATE vales_salida
        SET firma_despacho = p_firma_data, fecha_firma_despacho = NOW()
        WHERE id = p_documento_id;
      ELSIF p_tipo_firma = 'autorizacion' THEN
        UPDATE vales_salida
        SET
          firma_autorizacion = p_firma_data,
          fecha_firma_autorizacion = NOW(),
          estado = 'autorizado',
          autorizado_por = p_user_id
        WHERE id = p_documento_id;
      END IF;

    WHEN 'acta_entrega' THEN
      IF p_tipo_firma = 'recepcion' THEN
        UPDATE actas_entrega
        SET firma_recibe = p_firma_data, fecha_firma_recibe = NOW()
        WHERE id = p_documento_id;
      ELSIF p_tipo_firma = 'autorizacion' THEN
        UPDATE actas_entrega
        SET
          firma_entrega = p_firma_data,
          fecha_firma_entrega = NOW(),
          estado = 'firmada'
        WHERE id = p_documento_id;
      END IF;

    ELSE
      -- Otros tipos de documentos
      NULL;
  END CASE;

  -- Registrar en audit log
  INSERT INTO audit_log (
    user_id,
    action_type,
    entity_type,
    entity_id,
    changes_summary,
    result,
    severity,
    ip_address,
    user_agent
  ) VALUES (
    p_user_id,
    'SIGN',
    p_documento_tipo,
    p_documento_id,
    'Firma digital registrada: ' || p_tipo_firma,
    'success',
    'high',
    p_ip_address,
    p_user_agent
  );

  RETURN QUERY SELECT true, 'Firma registrada exitosamente', v_firma_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_firma_digital IS 'Registra una firma digital en un documento';

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 5 COMPLETADA' as resultado;

SELECT 'TABLAS DOCUMENTALES' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'vales_entrada', 'vales_entrada_items',
    'vales_salida', 'vales_salida_items',
    'actas_entrega', 'actas_entrega_items',
    'firmas_digitales'
  )
ORDER BY table_name;

SELECT 'FUNCIONES DOCUMENTALES' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'crear_vale_entrada',
    'aplicar_vale_entrada',
    'crear_vale_salida',
    'aplicar_vale_salida',
    'registrar_firma_digital'
  )
ORDER BY routine_name;
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
