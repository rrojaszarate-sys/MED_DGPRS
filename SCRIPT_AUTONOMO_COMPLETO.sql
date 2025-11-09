-- ============================================
-- SIGIMED v2.0 - SCRIPT 100% AUTÓNOMO
-- ============================================
-- Este script NO depende de tablas existentes
-- Crea TODO desde cero
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- ============================================
-- PASO 1: Tablas BASE (sin dependencias)
-- ============================================
BEGIN;

-- Instituciones
CREATE TABLE IF NOT EXISTS instituciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  clave TEXT UNIQUE,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Centros de Salud
CREATE TABLE IF NOT EXISTS health_centers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE,
  address TEXT,
  city TEXT,
  region TEXT,
  phone TEXT,
  email TEXT,
  responsible_name TEXT,
  is_active BOOLEAN DEFAULT true,
  institucion_id UUID REFERENCES instituciones(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_health_centers_code ON health_centers(code);
CREATE INDEX IF NOT EXISTS idx_health_centers_is_active ON health_centers(is_active);

-- Catálogo de Medicamentos
CREATE TABLE IF NOT EXISTS medication_catalog (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_medicamento TEXT UNIQUE NOT NULL,
  nombre_generico TEXT NOT NULL,
  nombre_comercial TEXT,
  principio_activo TEXT,
  forma_farmaceutica TEXT,
  via_administracion TEXT,
  concentracion TEXT,
  unidad_medida TEXT,
  categoria TEXT,
  requiere_receta BOOLEAN DEFAULT false,
  controlado BOOLEAN DEFAULT false,
  temperatura_almacenamiento TEXT,
  observaciones TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_medication_catalog_codigo ON medication_catalog(codigo_medicamento);
CREATE INDEX IF NOT EXISTS idx_medication_catalog_nombre ON medication_catalog(nombre_generico);

-- Medicamentos (inventario por centro)
CREATE TABLE IF NOT EXISTS medications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id UUID REFERENCES medication_catalog(id),
  center_id UUID REFERENCES health_centers(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  unidad_medida TEXT DEFAULT 'unidad',
  categoria TEXT,
  requiere_refrigeracion BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(catalog_id, center_id)
);

CREATE INDEX IF NOT EXISTS idx_medications_catalog ON medications(catalog_id);
CREATE INDEX IF NOT EXISTS idx_medications_center ON medications(center_id);
CREATE INDEX IF NOT EXISTS idx_medications_nombre ON medications(nombre);

-- Proveedores
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

COMMIT;

-- ============================================
-- PASO 2: Tablas DEPENDIENTES (lotes y movimientos)
-- ============================================
BEGIN;

-- Lotes de Medicamentos
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

-- Movimientos de Lotes
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
-- PASO 3: Tablas AUXILIARES
-- ============================================
BEGIN;

-- Centros por Usuario
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

-- Log de Auditoría
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

-- Contratos
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

-- Items de Contratos
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

-- Inspecciones de Almacenamiento
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

-- Documentos y Comprobantes
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
-- PASO 4: DATOS INICIALES
-- ============================================
BEGIN;

-- Insertar Instituciones
INSERT INTO instituciones (id, nombre, clave, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'IMSS - Instituto Mexicano del Seguro Social', 'IMSS', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000002', 'ISSSTE - Instituto de Seguridad y Servicios Sociales', 'ISSSTE', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000003', 'Secretaría de Salud', 'SSA', 'Salud Pública')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  clave = EXCLUDED.clave,
  tipo = EXCLUDED.tipo;

-- Insertar Centros de Salud
INSERT INTO health_centers (id, name, code, address, city, region, phone, email, responsible_name, is_active, institucion_id) VALUES
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
  ),
  (
    '10000000-0000-0000-0000-000000000003',
    'Centro de Salud Urbano La Esperanza',
    'CSU-ESP',
    'Calle 5 de Mayo 123, Col. Centro',
    'Guadalajara',
    'Jalisco',
    '33-4455-6677',
    'csuesperanza@salud.gob.mx',
    'Dr. Carlos Ramírez Torres',
    true,
    '00000000-0000-0000-0000-000000000003'
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  code = EXCLUDED.code,
  institucion_id = EXCLUDED.institucion_id;

-- Insertar Proveedores
INSERT INTO suppliers (id, nombre, rfc, razon_social, direccion, ciudad, estado, telefono, email, contacto_nombre, contacto_telefono, terminos_pago, dias_credito, calificacion, is_active) VALUES
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
    true
  ),
  (
    '20000000-0000-0000-0000-000000000003',
    'Medicamentos y Suministros del Norte',
    'MSN980420DEF',
    'Medicamentos y Suministros del Norte S.A. de C.V.',
    'Av. Universidad 456, Col. Industrial',
    'Monterrey',
    'Nuevo León',
    '81-5566-7788',
    'ventas@mednorte.com',
    'Dr. Roberto González',
    '81-5566-7789',
    'Crédito 60 días',
    60,
    4.2,
    true
  )
ON CONFLICT (id) DO UPDATE SET nombre = EXCLUDED.nombre;

-- Insertar Catálogo de Medicamentos
INSERT INTO medication_catalog (id, codigo_medicamento, nombre_generico, nombre_comercial, principio_activo, forma_farmaceutica, via_administracion, concentracion, unidad_medida, categoria, requiere_receta, controlado, temperatura_almacenamiento, is_active) VALUES
  (
    '30000000-0000-0000-0000-000000000001',
    'MED-PAR-500',
    'Paracetamol',
    'Tempra',
    'Acetaminofén',
    'Tableta',
    'Oral',
    '500mg',
    'tableta',
    'Analgésico',
    false,
    false,
    '15-25°C',
    true
  ),
  (
    '30000000-0000-0000-0000-000000000002',
    'MED-IBU-400',
    'Ibuprofeno',
    'Advil',
    'Ibuprofeno',
    'Tableta',
    'Oral',
    '400mg',
    'tableta',
    'Antiinflamatorio',
    false,
    false,
    '15-25°C',
    true
  ),
  (
    '30000000-0000-0000-0000-000000000003',
    'MED-AMO-500',
    'Amoxicilina',
    'Amoxil',
    'Amoxicilina',
    'Cápsula',
    'Oral',
    '500mg',
    'capsula',
    'Antibiótico',
    true,
    false,
    '15-25°C',
    true
  ),
  (
    '30000000-0000-0000-0000-000000000004',
    'MED-INS-100UI',
    'Insulina Humana',
    'Humulin R',
    'Insulina',
    'Solución inyectable',
    'Subcutánea',
    '100 UI/mL',
    'frasco',
    'Antidiabético',
    true,
    true,
    '2-8°C (Refrigeración)',
    true
  )
ON CONFLICT (id) DO UPDATE SET nombre_generico = EXCLUDED.nombre_generico;

-- Insertar Medicamentos en Inventario (HGZ1)
INSERT INTO medications (id, catalog_id, center_id, nombre, descripcion, unidad_medida, categoria, requiere_refrigeracion, is_active) VALUES
  (
    '40000000-0000-0000-0000-000000000001',
    '30000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Paracetamol 500mg',
    'Analgésico y antipirético',
    'tableta',
    'Analgésico',
    false,
    true
  ),
  (
    '40000000-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    'Ibuprofeno 400mg',
    'Antiinflamatorio no esteroideo',
    'tableta',
    'Antiinflamatorio',
    false,
    true
  ),
  (
    '40000000-0000-0000-0000-000000000003',
    '30000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000001',
    'Amoxicilina 500mg',
    'Antibiótico de amplio espectro',
    'capsula',
    'Antibiótico',
    false,
    true
  ),
  (
    '40000000-0000-0000-0000-000000000004',
    '30000000-0000-0000-0000-000000000004',
    '10000000-0000-0000-0000-000000000001',
    'Insulina Humana 100 UI/mL',
    'Control de diabetes',
    'frasco',
    'Antidiabético',
    true,
    true
  )
ON CONFLICT (catalog_id, center_id) DO UPDATE SET nombre = EXCLUDED.nombre;

COMMIT;

-- ============================================
-- PASO 5: FUNCIONES SQL
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
    AND b.cantidad_actual > 0
  ORDER BY dias_restantes ASC;
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
  SELECT 'instituciones'::TEXT, COUNT(*)::TEXT FROM instituciones
  UNION ALL
  SELECT 'centros_activos'::TEXT, COUNT(*)::TEXT FROM health_centers WHERE is_active = true
  UNION ALL
  SELECT 'catalogo_medicamentos'::TEXT, COUNT(*)::TEXT FROM medication_catalog WHERE is_active = true
  UNION ALL
  SELECT 'medicamentos_inventario'::TEXT, COUNT(*)::TEXT FROM medications WHERE is_active = true
  UNION ALL
  SELECT 'lotes_activos'::TEXT, COUNT(*)::TEXT FROM batches WHERE cantidad_actual > 0
  UNION ALL
  SELECT 'proveedores'::TEXT, COUNT(*)::TEXT FROM suppliers WHERE is_active = true
  UNION ALL
  SELECT 'contratos'::TEXT, COUNT(*)::TEXT FROM contracts
  UNION ALL
  SELECT 'movimientos_total'::TEXT, COUNT(*)::TEXT FROM batch_movements
  UNION ALL
  SELECT 'movimientos_hoy'::TEXT, COUNT(*)::TEXT FROM batch_movements WHERE created_at >= CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- Función: Crear lote de ejemplo
CREATE OR REPLACE FUNCTION crear_lote_ejemplo(
  p_medication_id UUID,
  p_center_id UUID,
  p_supplier_id UUID,
  p_cantidad INTEGER DEFAULT 100
) RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  batch_id UUID
) AS $$
DECLARE
  v_batch_id UUID;
  v_numero_lote TEXT;
BEGIN
  -- Generar número de lote único
  v_numero_lote := 'LOTE-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || SUBSTRING(gen_random_uuid()::TEXT, 1, 8);

  INSERT INTO batches (
    medication_id,
    center_id,
    supplier_id,
    numero_lote,
    cantidad_inicial,
    cantidad_actual,
    fecha_fabricacion,
    fecha_caducidad,
    fecha_ingreso,
    estado
  ) VALUES (
    p_medication_id,
    p_center_id,
    p_supplier_id,
    v_numero_lote,
    p_cantidad,
    p_cantidad,
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE + INTERVAL '2 years',
    CURRENT_DATE,
    'disponible'
  ) RETURNING id INTO v_batch_id;

  RETURN QUERY SELECT true, 'Lote creado: ' || v_numero_lote, v_batch_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '
╔══════════════════════════════════════════════════╗
║  ✅ SISTEMA SIGIMED v2.0 INSTALADO EXITOSAMENTE  ║
╚══════════════════════════════════════════════════╝
' as "RESULTADO";

-- Mostrar tablas creadas
SELECT
  '📋 TABLAS' as tipo,
  table_name as nombre,
  '✅ OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'instituciones', 'health_centers', 'medication_catalog', 'medications',
    'suppliers', 'batches', 'batch_movements', 'user_centers', 'audit_log',
    'contracts', 'contract_items', 'storage_inspections', 'documentos_comprobantes'
  )
ORDER BY table_name;

-- Mostrar funciones creadas
SELECT
  '⚙️ FUNCIONES' as tipo,
  routine_name as nombre,
  '✅ OK' as estado
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

-- Dashboard ejecutivo
SELECT '📊 MÉTRICAS DEL SISTEMA' as "Tipo";
SELECT * FROM dashboard_ejecutivo();

-- Datos de ejemplo
SELECT '
╔══════════════════════════════════════════════════╗
║              DATOS DE EJEMPLO CREADOS             ║
╠══════════════════════════════════════════════════╣
║  ✓ 3 Instituciones (IMSS, ISSSTE, SSA)          ║
║  ✓ 3 Centros de Salud                            ║
║  ✓ 3 Proveedores                                  ║
║  ✓ 4 Medicamentos en Catálogo                    ║
║  ✓ 4 Medicamentos en Inventario HGZ1             ║
╠══════════════════════════════════════════════════╣
║  SIGUIENTE PASO:                                  ║
║  Crear lotes con la función:                      ║
║  SELECT * FROM crear_lote_ejemplo(               ║
║    ''40000000-0000-0000-0000-000000000001'',    ║
║    ''10000000-0000-0000-0000-000000000001'',    ║
║    ''20000000-0000-0000-0000-000000000001'',    ║
║    500                                            ║
║  );                                               ║
╚══════════════════════════════════════════════════╝
' as "INSTRUCCIONES";
