-- ============================================
-- SIGIMED v2.0 - SCRIPT COMPLETO CORREGIDO
-- ============================================
-- Ejecutar TODO de una vez en Supabase SQL Editor
-- Fecha: 2025-11-08
-- ============================================

-- ============================================
-- PASO 1: Crear tabla instituciones PRIMERO
-- ============================================
BEGIN;

CREATE TABLE IF NOT EXISTS instituciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  clave TEXT UNIQUE,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Agregar columna institucion_id a health_centers si no existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'health_centers' AND column_name = 'institucion_id'
  ) THEN
    ALTER TABLE health_centers ADD COLUMN institucion_id UUID REFERENCES instituciones(id);
  END IF;
END $$;

COMMIT;

-- ============================================
-- PASO 2: Crear tablas CORE (suppliers, batches, batch_movements)
-- ============================================
BEGIN;

-- TABLA: SUPPLIERS
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

CREATE INDEX IF NOT EXISTS idx_suppliers_nombre ON suppliers(nombre);
CREATE INDEX IF NOT EXISTS idx_suppliers_rfc ON suppliers(rfc);
CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);

-- TABLA: BATCHES
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

CREATE INDEX IF NOT EXISTS idx_batches_medication ON batches(medication_id);
CREATE INDEX IF NOT EXISTS idx_batches_center ON batches(center_id);
CREATE INDEX IF NOT EXISTS idx_batches_supplier ON batches(supplier_id);
CREATE INDEX IF NOT EXISTS idx_batches_fecha_caducidad ON batches(fecha_caducidad);
CREATE INDEX IF NOT EXISTS idx_batches_estado ON batches(estado);
CREATE INDEX IF NOT EXISTS idx_batches_numero_lote ON batches(numero_lote);

-- TABLA: BATCH_MOVEMENTS
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
  usuario_responsable UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_batch_movements_batch ON batch_movements(batch_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_center ON batch_movements(center_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX IF NOT EXISTS idx_batch_movements_created ON batch_movements(created_at DESC);

COMMIT;

-- ============================================
-- PASO 3: Tablas auxiliares
-- ============================================
BEGIN;

CREATE TABLE IF NOT EXISTS user_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, center_id)
);

CREATE INDEX IF NOT EXISTS idx_user_centers_user ON user_centers(user_id);
CREATE INDEX IF NOT EXISTS idx_user_centers_center ON user_centers(center_id);

CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  user_email TEXT,
  user_name TEXT,
  user_role TEXT,
  action_type TEXT NOT NULL CHECK (action_type IN (
    'CREATE', 'READ', 'UPDATE', 'DELETE',
    'LOGIN', 'LOGOUT', 'LOGIN_FAILED',
    'EXPORT', 'IMPORT', 'APPROVE', 'REJECT', 'SIGN'
  )),
  entity_type TEXT NOT NULL,
  entity_id UUID,
  entity_name TEXT,
  old_values JSONB,
  new_values JSONB,
  changes_summary TEXT,
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  result TEXT CHECK (result IN ('success', 'failed', 'partial')),
  error_message TEXT,
  metadata JSONB,
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_user ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action_type);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_severity ON audit_log(severity);

COMMIT;

-- ============================================
-- PASO 4: Tablas de contratos
-- ============================================
BEGIN;

CREATE TABLE IF NOT EXISTS contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_contrato TEXT UNIQUE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id),
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  monto_total DECIMAL(15,2),
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'activo', 'vencido', 'cancelado')),
  pdf_url TEXT,
  firmado_por UUID,
  fecha_firma TIMESTAMPTZ,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contracts_supplier ON contracts(supplier_id);
CREATE INDEX IF NOT EXISTS idx_contracts_estado ON contracts(estado);
CREATE INDEX IF NOT EXISTS idx_contracts_codigo ON contracts(codigo_contrato);

CREATE TABLE IF NOT EXISTS contract_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  cantidad_comprometida INTEGER NOT NULL,
  precio_unitario DECIMAL(15,2),
  center_destino_id UUID REFERENCES health_centers(id),
  fecha_estimada_entrega DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contract_items_contract ON contract_items(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_items_medication ON contract_items(medication_catalog_id);

CREATE TABLE IF NOT EXISTS storage_inspections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  center_id UUID REFERENCES health_centers(id),
  inspector_id UUID,
  fecha_inspeccion TIMESTAMPTZ DEFAULT NOW(),
  temperatura_min DECIMAL(5,2),
  temperatura_max DECIMAL(5,2),
  humedad_relativa DECIMAL(5,2),
  condiciones_generales TEXT,
  observaciones TEXT,
  cumple_normas BOOLEAN DEFAULT true,
  firma_digital TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_storage_inspections_center ON storage_inspections(center_id);
CREATE INDEX IF NOT EXISTS idx_storage_inspections_fecha ON storage_inspections(fecha_inspeccion DESC);

CREATE TABLE IF NOT EXISTS documentos_comprobantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_documento TEXT CHECK (tipo_documento IN (
    'vale_entrada', 'acta_entrega', 'vale_salida',
    'documento_transferencia', 'contrato_pdf', 'anexo', 'inspeccion'
  )),
  referencia_tipo TEXT,
  referencia_id UUID,
  nombre_archivo TEXT NOT NULL,
  url_archivo TEXT NOT NULL,
  size_bytes BIGINT,
  mime_type TEXT,
  firmado_por UUID,
  fecha_firma TIMESTAMPTZ,
  requiere_firma BOOLEAN DEFAULT false,
  observaciones TEXT,
  uploaded_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_documentos_tipo ON documentos_comprobantes(tipo_documento);
CREATE INDEX IF NOT EXISTS idx_documentos_referencia ON documentos_comprobantes(referencia_tipo, referencia_id);
CREATE INDEX IF NOT EXISTS idx_documentos_uploaded ON documentos_comprobantes(uploaded_by);

COMMIT;

-- ============================================
-- PASO 5: Insertar datos iniciales
-- ============================================
BEGIN;

-- Instituciones
INSERT INTO instituciones (id, nombre, clave, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'IMSS - Instituto Mexicano del Seguro Social', 'IMSS', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000002', 'ISSSTE - Instituto de Seguridad y Servicios Sociales', 'ISSSTE', 'Seguridad Social')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  clave = EXCLUDED.clave,
  tipo = EXCLUDED.tipo;

-- Centros de Salud
INSERT INTO health_centers (
  id, name, code, address, city, region, phone, email, responsible_name, is_active, institucion_id
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

-- Proveedores
INSERT INTO suppliers (
  id, nombre, rfc, razon_social, direccion, ciudad, estado, telefono, email,
  contacto_nombre, contacto_telefono, terminos_pago, dias_credito, calificacion, notas, is_active
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
    'Proveedor confiable',
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
    'Especialistas en medicamentos',
    true
  )
ON CONFLICT (id) DO UPDATE SET nombre = EXCLUDED.nombre;

COMMIT;

-- ============================================
-- PASO 6: Funciones SQL básicas
-- ============================================

-- Función: Registrar movimiento de lote
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
BEGIN
  SELECT * INTO v_batch FROM batches WHERE id = p_batch_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Lote no encontrado', 0::INTEGER, NULL::UUID;
    RETURN;
  END IF;

  CASE p_tipo_movimiento
    WHEN 'entrada', 'transferencia_entrada', 'devolucion' THEN
      v_nueva_cantidad := v_batch.cantidad_actual + p_cantidad;
    WHEN 'salida', 'transferencia_salida', 'merma', 'vencimiento' THEN
      v_nueva_cantidad := v_batch.cantidad_actual - p_cantidad;
      IF v_nueva_cantidad < 0 THEN
        RETURN QUERY SELECT false, 'Stock insuficiente', v_batch.cantidad_actual::INTEGER, NULL::UUID;
        RETURN;
      END IF;
    WHEN 'ajuste' THEN
      v_nueva_cantidad := p_cantidad;
    ELSE
      RETURN QUERY SELECT false, 'Tipo inválido', 0::INTEGER, NULL::UUID;
      RETURN;
  END CASE;

  INSERT INTO batch_movements (
    batch_id, medication_id, center_id, tipo_movimiento, cantidad,
    cantidad_anterior, cantidad_posterior, centro_destino_id,
    numero_documento, motivo, observaciones, usuario_responsable
  ) VALUES (
    p_batch_id, v_batch.medication_id, v_batch.center_id, p_tipo_movimiento, p_cantidad,
    v_batch.cantidad_actual, v_nueva_cantidad, p_centro_destino_id,
    p_numero_documento, p_motivo, p_observaciones, p_usuario_responsable
  ) RETURNING id INTO v_movement_id;

  UPDATE batches SET
    cantidad_actual = v_nueva_cantidad,
    estado = CASE WHEN v_nueva_cantidad = 0 THEN 'agotado' ELSE estado END,
    updated_at = NOW()
  WHERE id = p_batch_id;

  RETURN QUERY SELECT true, 'Movimiento registrado', v_nueva_cantidad, v_movement_id;
END;
$$ LANGUAGE plpgsql;

-- Función: Detectar lotes vencidos
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
    (CURRENT_DATE - b.fecha_caducidad)::INTEGER
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.fecha_caducidad < CURRENT_DATE
    AND b.estado != 'vencido'
    AND b.cantidad_actual > 0;
END;
$$ LANGUAGE plpgsql;

-- Función: Lotes próximos a vencer
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
    (b.fecha_caducidad - CURRENT_DATE)::INTEGER,
    CASE
      WHEN (b.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'CRÍTICA'
      WHEN (b.fecha_caducidad - CURRENT_DATE) <= 60 THEN 'ALTA'
      ELSE 'MEDIA'
    END
  FROM batches b
  JOIN medications m ON b.medication_id = m.id
  JOIN health_centers hc ON b.center_id = hc.id
  WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND (CURRENT_DATE + dias_anticipacion)
    AND b.estado = 'disponible'
    AND b.cantidad_actual > 0;
END;
$$ LANGUAGE plpgsql;

-- Función: Dashboard ejecutivo
CREATE OR REPLACE FUNCTION dashboard_ejecutivo()
RETURNS TABLE (
  metrica TEXT,
  valor TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 'centros_activos'::TEXT, COUNT(*)::TEXT FROM health_centers WHERE is_active = true
  UNION ALL
  SELECT 'medicamentos_total'::TEXT, COUNT(*)::TEXT FROM medications
  UNION ALL
  SELECT 'lotes_activos'::TEXT, COUNT(*)::TEXT FROM batches WHERE cantidad_actual > 0
  UNION ALL
  SELECT 'proveedores'::TEXT, COUNT(*)::TEXT FROM suppliers WHERE is_active = true
  UNION ALL
  SELECT 'contratos'::TEXT, COUNT(*)::TEXT FROM contracts
  UNION ALL
  SELECT 'movimientos_hoy'::TEXT, COUNT(*)::TEXT FROM batch_movements WHERE created_at >= CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ SISTEMA INSTALADO CORRECTAMENTE' as resultado;

-- Mostrar tablas creadas
SELECT
  table_name,
  'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'suppliers', 'batches', 'batch_movements', 'user_centers', 'audit_log',
    'instituciones', 'contracts', 'contract_items', 'storage_inspections', 'documentos_comprobantes'
  )
ORDER BY table_name;

-- Mostrar funciones creadas
SELECT
  routine_name as funcion,
  'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'detectar_lotes_vencidos',
    'lotes_proximos_vencer',
    'dashboard_ejecutivo'
  )
ORDER BY routine_name;

-- Dashboard
SELECT * FROM dashboard_ejecutivo();
