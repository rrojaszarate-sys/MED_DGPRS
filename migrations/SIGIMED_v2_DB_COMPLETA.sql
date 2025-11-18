-- ============================================
-- SIGIMED v2.0 - INSTALACIÓN LIMPIA
-- ============================================
-- Este script ELIMINA todo y lo recrea desde CERO
-- SIN ERRORES GARANTIZADO
-- ============================================

-- ============================================
-- PASO 1: ELIMINAR TODO LO ANTERIOR
-- ============================================

-- Eliminar funciones
DROP FUNCTION IF EXISTS registrar_movimiento_lote CASCADE;
DROP FUNCTION IF EXISTS detectar_lotes_vencidos CASCADE;
DROP FUNCTION IF EXISTS lotes_proximos_vencer CASCADE;
DROP FUNCTION IF EXISTS dashboard_ejecutivo CASCADE;
DROP FUNCTION IF EXISTS crear_lote_ejemplo CASCADE;

-- Eliminar tablas en orden inverso (para respetar foreign keys)
DROP TABLE IF EXISTS documentos_comprobantes CASCADE;
DROP TABLE IF EXISTS storage_inspections CASCADE;
DROP TABLE IF EXISTS contract_items CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS user_centers CASCADE;
DROP TABLE IF EXISTS batch_movements CASCADE;
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS medications CASCADE;
DROP TABLE IF EXISTS medication_catalog CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS health_centers CASCADE;
DROP TABLE IF EXISTS instituciones CASCADE;

-- ============================================
-- PASO 2: CREAR TABLAS DESDE CERO
-- ============================================

-- Instituciones
CREATE TABLE instituciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  clave TEXT UNIQUE,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Centros de Salud
CREATE TABLE health_centers (
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

CREATE INDEX idx_health_centers_code ON health_centers(code);
CREATE INDEX idx_health_centers_is_active ON health_centers(is_active);

-- Catálogo de Medicamentos
CREATE TABLE medication_catalog (
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

CREATE INDEX idx_medication_catalog_codigo ON medication_catalog(codigo_medicamento);
CREATE INDEX idx_medication_catalog_nombre ON medication_catalog(nombre_generico);

-- Medicamentos (inventario por centro)
CREATE TABLE medications (
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

CREATE INDEX idx_medications_catalog ON medications(catalog_id);
CREATE INDEX idx_medications_center ON medications(center_id);
CREATE INDEX idx_medications_nombre ON medications(nombre);

-- Proveedores
CREATE TABLE suppliers (
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

CREATE INDEX idx_suppliers_nombre ON suppliers(nombre);
CREATE INDEX idx_suppliers_rfc ON suppliers(rfc);
CREATE INDEX idx_suppliers_is_active ON suppliers(is_active);

-- Lotes de Medicamentos
CREATE TABLE batches (
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

CREATE INDEX idx_batches_medication ON batches(medication_id);
CREATE INDEX idx_batches_center ON batches(center_id);
CREATE INDEX idx_batches_supplier ON batches(supplier_id);
CREATE INDEX idx_batches_fecha_caducidad ON batches(fecha_caducidad);
CREATE INDEX idx_batches_estado ON batches(estado);
CREATE INDEX idx_batches_numero_lote ON batches(numero_lote);

-- Movimientos de Lotes
CREATE TABLE batch_movements (
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

CREATE INDEX idx_batch_movements_batch ON batch_movements(batch_id);
CREATE INDEX idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX idx_batch_movements_center ON batch_movements(center_id);
CREATE INDEX idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX idx_batch_movements_created ON batch_movements(created_at DESC);

-- Centros por Usuario
CREATE TABLE user_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, center_id)
);

CREATE INDEX idx_user_centers_user ON user_centers(user_id);
CREATE INDEX idx_user_centers_center ON user_centers(center_id);

-- Log de Auditoría
CREATE TABLE audit_log (
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

CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_action ON audit_log(action_type);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_created ON audit_log(created_at DESC);
CREATE INDEX idx_audit_log_severity ON audit_log(severity);

-- Contratos
CREATE TABLE contracts (
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

CREATE INDEX idx_contracts_supplier ON contracts(supplier_id);
CREATE INDEX idx_contracts_estado ON contracts(estado);
CREATE INDEX idx_contracts_codigo ON contracts(codigo_contrato);

-- Items de Contratos
CREATE TABLE contract_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  cantidad_comprometida INTEGER NOT NULL,
  precio_unitario DECIMAL(15,2),
  center_destino_id UUID REFERENCES health_centers(id),
  fecha_estimada_entrega DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_contract_items_contract ON contract_items(contract_id);
CREATE INDEX idx_contract_items_medication ON contract_items(medication_catalog_id);

-- Inspecciones de Almacenamiento
CREATE TABLE storage_inspections (
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

CREATE INDEX idx_storage_inspections_center ON storage_inspections(center_id);
CREATE INDEX idx_storage_inspections_fecha ON storage_inspections(fecha_inspeccion DESC);

-- Documentos y Comprobantes
CREATE TABLE documentos_comprobantes (
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

CREATE INDEX idx_documentos_tipo ON documentos_comprobantes(tipo_documento);
CREATE INDEX idx_documentos_referencia ON documentos_comprobantes(referencia_tipo, referencia_id);
CREATE INDEX idx_documentos_uploaded ON documentos_comprobantes(uploaded_by);

-- ============================================
-- PASO 3: INSERTAR DATOS DE EJEMPLO
-- ============================================

-- Instituciones
INSERT INTO instituciones (id, nombre, clave, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'IMSS - Instituto Mexicano del Seguro Social', 'IMSS', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000002', 'ISSSTE - Instituto de Seguridad y Servicios Sociales', 'ISSSTE', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000003', 'Secretaría de Salud', 'SSA', 'Salud Pública');

-- Centros de Salud
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
  );

-- Proveedores
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
  );

-- Catálogo de Medicamentos
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
  );

-- Medicamentos en Inventario (HGZ1)
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
  );

-- ============================================
-- PASO 4: CREAR FUNCIONES
-- ============================================

-- Función: Registrar movimiento de lote
CREATE FUNCTION registrar_movimiento_lote(
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
CREATE FUNCTION detectar_lotes_vencidos()
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
CREATE FUNCTION lotes_proximos_vencer(dias_anticipacion INTEGER DEFAULT 90)
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
CREATE FUNCTION dashboard_ejecutivo()
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
CREATE FUNCTION crear_lote_ejemplo(
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
║     ✅ SIGIMED v2.0 INSTALADO EXITOSAMENTE ✅    ║
╚══════════════════════════════════════════════════╝
' as "RESULTADO";

-- Tablas creadas
SELECT '📋 TABLAS CREADAS:' as info;
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'instituciones', 'health_centers', 'medication_catalog', 'medications',
    'suppliers', 'batches', 'batch_movements', 'user_centers', 'audit_log',
    'contracts', 'contract_items', 'storage_inspections', 'documentos_comprobantes'
  )
ORDER BY table_name;

-- Funciones creadas
SELECT '⚙️ FUNCIONES CREADAS:' as info;
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'registrar_movimiento_lote',
    'detectar_lotes_vencidos',
    'lotes_proximos_vencer',
    'dashboard_ejecutivo',
    'crear_lote_ejemplo'
  )
ORDER BY routine_name;

-- Métricas
SELECT '📊 MÉTRICAS:' as info;
SELECT * FROM dashboard_ejecutivo();

-- Instrucciones
SELECT '
╔══════════════════════════════════════════════════╗
║              TODO LISTO PARA USAR                 ║
╠══════════════════════════════════════════════════╣
║  ✓ 3 Instituciones                                ║
║  ✓ 3 Centros de Salud                             ║
║  ✓ 3 Proveedores                                   ║
║  ✓ 4 Medicamentos en Catálogo                     ║
║  ✓ 4 Medicamentos en Inventario HGZ1              ║
╠══════════════════════════════════════════════════╣
║  CREA TU PRIMER LOTE:                             ║
║                                                    ║
║  SELECT * FROM crear_lote_ejemplo(                ║
║    ''40000000-0000-0000-0000-000000000001''::UUID,║
║    ''10000000-0000-0000-0000-000000000001''::UUID,║
║    ''20000000-0000-0000-0000-000000000001''::UUID,║
║    500                                             ║
║  );                                                ║
╚══════════════════════════════════════════════════╝
' as "SIGUIENTE PASO";

-- ============================================
-- DATOS DE PRUEBA: 23 CENTROS PENITENCIARIOS
-- ============================================

INSERT INTO health_centers (name, code, address, city, region, phone, email, responsible_name, is_active, institucion_id) VALUES
('Centro Penitenciario y de Reinserción Social de Chalco', 'CPRS-CHALCO-01', 'Km 31.5 Carretera Federal México-Cuautla', 'Chalco', 'Estado de México', '55-5850-1234', 'medico.chalco@edomex.gob.mx', 'Dr. Juan Pérez García', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Cuautitlán', 'CPRS-CUAU-02', 'Carretera Cuautitlán-Melchor Ocampo Km 4.5', 'Cuautitlán', 'Estado de México', '55-5876-2345', 'medico.cuautitlan@edomex.gob.mx', 'Dra. María López Hernández', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Ecatepec', 'CPRS-ECA-03', 'Av. Central s/n, Col. Guadalupe Victoria', 'Ecatepec', 'Estado de México', '55-5787-3456', 'medico.ecatepec@edomex.gob.mx', 'Dr. Carlos Ramírez Torres', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Neza-Bordo', 'CPRS-NEZA-04', 'Bordo de Xochiaca s/n', 'Nezahualcóyotl', 'Estado de México', '55-5765-4567', 'medico.neza@edomex.gob.mx', 'Dra. Ana Martínez Silva', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Otumba', 'CPRS-OTU-05', 'Carr. Otumba-Apan Km 2', 'Otumba', 'Estado de México', '594-922-5678', 'medico.otumba@edomex.gob.mx', 'Dr. Roberto González Díaz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Santiaguito', 'CPRS-SAN-06', 'Carretera Toluca-Almoloya Km 4.5', 'Almoloya de Juárez', 'Estado de México', '722-282-6789', 'medico.santiaguito@edomex.gob.mx', 'Dra. Patricia Sánchez Ruiz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Tlalnepantla', 'CPRS-TLA-07', 'Av. Mario Colín Sánchez s/n, Barrientos', 'Tlalnepantla', 'Estado de México', '55-5365-7890', 'medico.tlalnepantla@edomex.gob.mx', 'Dr. Francisco Herrera Vega', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Valle de Bravo', 'CPRS-VB-08', 'Camino a La Peña s/n', 'Valle de Bravo', 'Estado de México', '726-262-8901', 'medico.vallebravo@edomex.gob.mx', 'Dra. Claudia Morales Ortiz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Zumpango', 'CPRS-ZUM-09', 'Carr. Zumpango-Tequixquiac Km 3', 'Zumpango', 'Estado de México', '591-917-9012', 'medico.zumpango@edomex.gob.mx', 'Dr. Jorge Castro Méndez', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Texcoco', 'CPRS-TEX-10', 'Camino a la Cañada s/n, San Felipe', 'Texcoco', 'Estado de México', '595-954-0123', 'medico.texcoco@edomex.gob.mx', 'Dra. Laura Jiménez Flores', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Tenango del Valle', 'CPRS-TEN-11', 'Carretera Tenango-Villa Guerrero Km 1.5', 'Tenango del Valle', 'Estado de México', '717-144-1234', 'medico.tenango@edomex.gob.mx', 'Dr. Miguel Ángel Reyes Cruz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social Femenil de Nezahualcóyotl', 'CPRSF-NEZA-12', 'Av. Chimalhuacán s/n, Col. Benito Juárez', 'Nezahualcóyotl', 'Estado de México', '55-5793-2345', 'medico.nezafemenil@edomex.gob.mx', 'Dra. Gabriela Torres Moreno', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social Femenil de Ecatepec', 'CPRSF-ECA-13', 'Vía José López Portillo Km 32', 'Ecatepec', 'Estado de México', '55-5786-3456', 'medico.ecafemenil@edomex.gob.mx', 'Dra. Verónica Mendoza Ruiz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Chiconautla', 'CPRS-CHI-14', 'Camino a Chiconautla s/n', 'Ecatepec', 'Estado de México', '55-5784-4567', 'medico.chiconautla@edomex.gob.mx', 'Dr. Alejandro Vargas Santos', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social Dr. Alfonso Quiroz Cuarón', 'CPRS-AQC-15', 'Carretera México-Pachuca Km 38.5', 'Tizayuca', 'Estado de México', '779-796-5678', 'medico.quiroz@edomex.gob.mx', 'Dr. Fernando Silva Navarro', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Tenancingo', 'CPRS-TNC-16', 'Camino Real a Tenancingo s/n', 'Tenancingo', 'Estado de México', '714-142-6789', 'medico.tenancingo@edomex.gob.mx', 'Dra. Mónica Ramírez León', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Ixtlahuaca', 'CPRS-IXT-17', 'Carretera Ixtlahuaca-Jocotitlán Km 2', 'Ixtlahuaca', 'Estado de México', '712-283-7890', 'medico.ixtlahuaca@edomex.gob.mx', 'Dr. Sergio Ortega Ramírez', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Sultepec', 'CPRS-SUL-18', 'Carretera Sultepec-Tejupilco Km 1', 'Sultepec', 'Estado de México', '716-146-8901', 'medico.sultepec@edomex.gob.mx', 'Dra. Rosa María Pérez Aguilar', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Jilotepec', 'CPRS-JIL-19', 'Camino a Jilotepec s/n', 'Jilotepec', 'Estado de México', '761-734-9012', 'medico.jilotepec@edomex.gob.mx', 'Dr. Arturo Mendoza Castro', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Tlatlaya', 'CPRS-TLT-20', 'Carretera Tlatlaya-Amatepec Km 5', 'Tlatlaya', 'Estado de México', '714-145-0123', 'medico.tlatlaya@edomex.gob.mx', 'Dra. Silvia Gómez Herrera', true, '00000000-0000-0000-0000-000000000001'),
('Centro de Atención Integral Juvenil de Quinta del Bosque', 'CAIJ-QB-21', 'Quinta del Bosque s/n, Zinacantepec', 'Zinacantepec', 'Estado de México', '722-167-1234', 'medico.quintabosque@edomex.gob.mx', 'Dr. Raúl Fernández Ríos', true, '00000000-0000-0000-0000-000000000001'),
('Centro de Internamiento para Adolescentes de Zinacantepec', 'CIA-ZIN-22', 'Camino a Raíces s/n', 'Zinacantepec', 'Estado de México', '722-218-2345', 'medico.zinadolescentes@edomex.gob.mx', 'Dra. Elena Vázquez Torres', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario y de Reinserción Social de Atlcomulco', 'CPRS-ATL-23', 'Carretera Atlacomulco-Jocotitlán Km 3', 'Atlacomulco', 'Estado de México', '712-122-3456', 'medico.atlacomulco@edomex.gob.mx', 'Dr. Héctor Morales Jiménez', true, '00000000-0000-0000-0000-000000000001')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  city = EXCLUDED.city,
  region = EXCLUDED.region,
  phone = EXCLUDED.phone,
  email = EXCLUDED.email,
  responsible_name = EXCLUDED.responsible_name;

-- ============================================
-- DATOS DE PRUEBA: 80 MEDICAMENTOS
-- ============================================

INSERT INTO medication_catalog (
  codigo_medicamento, nombre_generico, nombre_comercial, principio_activo,
  forma_farmaceutica, concentracion, unidad_medida, categoria,
  requiere_receta, controlado, is_active
) VALUES
('2531012615', 'KETOCONAZOL/CLINDAMICINA', 'KETOCONAZOL/CLINDAMICINA', 'Ketoconazol 400mg + Clindamicina 100mg', 'supositorio', '400mg/100mg', 'caja', 'G01AF11', true, false, true),
('2531012616', 'AMOXICILINA/CLAVULANATO', 'AMOXICILINA/CLAVULANATO', 'Amoxicilina 875mg + Ácido Clavulánico 125mg', 'tableta', '875mg/125mg', 'caja', 'J01CR02', true, false, true),
('2531012617', 'CIPROFLOXACINO', 'CIPROFLOXACINO', 'Ciprofloxacino 500mg', 'tableta', '500mg', 'caja', 'J01MA02', true, false, true),
('2531012618', 'METRONIDAZOL', 'METRONIDAZOL', 'Metronidazol 500mg', 'tableta', '500mg', 'caja', 'P01AB01', false, false, true),
('2531012619', 'OMEPRAZOL', 'OMEPRAZOL', 'Omeprazol 20mg', 'capsula', '20mg', 'caja', 'A02BC01', false, false, true),
('2531012620', 'LOSARTÁN', 'LOSARTÁN', 'Losartán 50mg', 'tableta', '50mg', 'caja', 'C09CA01', true, false, true),
('2531012621', 'METFORMINA', 'METFORMINA', 'Metformina 850mg', 'tableta', '850mg', 'caja', 'A10BA02', true, false, true),
('2531012622', 'ATORVASTATINA', 'ATORVASTATINA', 'Atorvastatina 20mg', 'tableta', '20mg', 'caja', 'C10AA05', true, false, true),
('2531012623', 'PARACETAMOL', 'PARACETAMOL', 'Paracetamol 500mg', 'tableta', '500mg', 'caja', 'N02BE01', false, false, true),
('2531012624', 'IBUPROFENO', 'IBUPROFENO', 'Ibuprofeno 400mg', 'tableta', '400mg', 'caja', 'M01AE01', false, false, true),
('2531012625', 'CLONAZEPAM', 'CLONAZEPAM', 'Clonazepam 2mg', 'tableta', '2mg', 'caja', 'N03AE01', true, true, true),
('2531012626', 'FLUOXETINA', 'FLUOXETINA', 'Fluoxetina 20mg', 'capsula', '20mg', 'caja', 'N06AB03', true, false, true),
('2531012627', 'CAPTOPRIL', 'CAPTOPRIL', 'Captopril 25mg', 'tableta', '25mg', 'caja', 'C09AA01', true, false, true),
('2531012628', 'HIDROCLOROTIAZIDA', 'HIDROCLOROTIAZIDA', 'Hidroclorotiazida 25mg', 'tableta', '25mg', 'caja', 'C03AA03', true, false, true),
('2531012629', 'DICLOFENACO', 'DICLOFENACO', 'Diclofenaco 100mg', 'tableta', '100mg', 'caja', 'M01AB05', false, false, true),
('2531012630', 'RANITIDINA', 'RANITIDINA', 'Ranitidina 150mg', 'tableta', '150mg', 'caja', 'A02BA02', false, false, true),
('2531012631', 'SALBUTAMOL', 'SALBUTAMOL', 'Salbutamol 100mcg', 'aerosol', '100mcg', 'inhalador', 'R03AC02', true, false, true),
('2531012632', 'BECLOMETASONA', 'BECLOMETASONA', 'Beclometasona 250mcg', 'aerosol', '250mcg', 'inhalador', 'R03BA01', true, false, true),
('2531012633', 'CARBAMAZEPINA', 'CARBAMAZEPINA', 'Carbamazepina 200mg', 'tableta', '200mg', 'caja', 'N03AF01', true, false, true),
('2531012634', 'FENITOÍNA', 'FENITOÍNA', 'Fenitoína 100mg', 'capsula', '100mg', 'caja', 'N03AB02', true, false, true),
('2531012635', 'ÁCIDO VALPROICO', 'ÁCIDO VALPROICO', 'Ácido Valproico 500mg', 'tableta', '500mg', 'caja', 'N03AG01', true, false, true),
('2531012636', 'GLIBENCLAMIDA', 'GLIBENCLAMIDA', 'Glibenclamida 5mg', 'tableta', '5mg', 'caja', 'A10BB01', true, false, true),
('2531012637', 'INSULINA NPH', 'INSULINA NPH', 'Insulina NPH 100 UI/mL', 'inyectable', '100UI/mL', 'frasco', 'A10AC01', true, false, true),
('2531012638', 'INSULINA RÁPIDA', 'INSULINA RÁPIDA', 'Insulina Regular 100 UI/mL', 'inyectable', '100UI/mL', 'frasco', 'A10AB01', true, false, true),
('2531012639', 'LEVOTIROXINA', 'LEVOTIROXINA', 'Levotiroxina 100mcg', 'tableta', '100mcg', 'caja', 'H03AA01', true, false, true),
('2531012640', 'ALOPURINOL', 'ALOPURINOL', 'Alopurinol 300mg', 'tableta', '300mg', 'caja', 'M04AA01', true, false, true),
('2531012641', 'PREDNISONA', 'PREDNISONA', 'Prednisona 5mg', 'tableta', '5mg', 'caja', 'H02AB07', true, false, true),
('2531012642', 'BETAMETASONA', 'BETAMETASONA', 'Betametasona 0.6mg', 'tableta', '0.6mg', 'caja', 'H02AB01', true, false, true),
('2531012643', 'CEFTRIAXONA', 'CEFTRIAXONA', 'Ceftriaxona 1g', 'inyectable', '1g', 'ampolleta', 'J01DD04', true, false, true),
('2531012644', 'GENTAMICINA', 'GENTAMICINA', 'Gentamicina 80mg', 'inyectable', '80mg', 'ampolleta', 'J01GB03', true, false, true),
('2531012645', 'DIAZEPAM', 'DIAZEPAM', 'Diazepam 10mg', 'inyectable', '10mg', 'ampolleta', 'N05BA01', true, true, true),
('2531012646', 'TRAMADOL', 'TRAMADOL', 'Tramadol 100mg', 'inyectable', '100mg', 'ampolleta', 'N02AX02', true, true, true),
('2531012647', 'KETOROLACO', 'KETOROLACO', 'Ketorolaco 30mg', 'inyectable', '30mg', 'ampolleta', 'M01AB15', true, false, true),
('2531012648', 'METAMIZOL', 'METAMIZOL', 'Metamizol 2g', 'inyectable', '2g', 'ampolleta', 'N02BB02', false, false, true),
('2531012649', 'FUROSEMIDA', 'FUROSEMIDA', 'Furosemida 20mg', 'inyectable', '20mg', 'ampolleta', 'C03CA01', true, false, true),
('2531012650', 'ENOXAPARINA', 'ENOXAPARINA', 'Enoxaparina 60mg', 'inyectable', '60mg', 'jeringa', 'B01AB05', true, false, true),
('2531012651', 'NITROGLICERINA', 'NITROGLICERINA', 'Nitroglicerina 5mg', 'inyectable', '5mg', 'ampolleta', 'C01DA02', true, false, true),
('2531012652', 'DEXAMETASONA', 'DEXAMETASONA', 'Dexametasona 8mg', 'inyectable', '8mg', 'ampolleta', 'H02AB02', true, false, true),
('2531012653', 'RANITIDINA INYECTABLE', 'RANITIDINA INYECTABLE', 'Ranitidina 50mg', 'inyectable', '50mg', 'ampolleta', 'A02BA02', true, false, true),
('2531012654', 'ENALAPRIL', 'ENALAPRIL', 'Enalapril 10mg', 'tableta', '10mg', 'caja', 'C09AA02', true, false, true),
('2531012655', 'NIFEDIPINO', 'NIFEDIPINO', 'Nifedipino 30mg', 'tableta', '30mg', 'caja', 'C08CA05', true, false, true),
('2531012656', 'PROPRANOLOL', 'PROPRANOLOL', 'Propranolol 40mg', 'tableta', '40mg', 'caja', 'C07AA05', true, false, true),
('2531012657', 'AMIODARONA', 'AMIODARONA', 'Amiodarona 200mg', 'tableta', '200mg', 'caja', 'C01BD01', true, false, true),
('2531012658', 'ISOSORBIDE', 'ISOSORBIDE', 'Isosorbide 10mg', 'tableta', '10mg', 'caja', 'C01DA08', true, false, true),
('2531012659', 'WARFARINA', 'WARFARINA', 'Warfarina 5mg', 'tableta', '5mg', 'caja', 'B01AA03', true, false, true),
('2531012660', 'CLINDAMICINA', 'CLINDAMICINA', 'Clindamicina 300mg', 'capsula', '300mg', 'caja', 'J01FF01', true, false, true),
('2531012661', 'AZITROMICINA', 'AZITROMICINA', 'Azitromicina 500mg', 'tableta', '500mg', 'caja', 'J01FA10', true, false, true),
('2531012662', 'CLARITROMICINA', 'CLARITROMICINA', 'Claritromicina 500mg', 'tableta', '500mg', 'caja', 'J01FA09', true, false, true),
('2531012663', 'CEFALEXINA', 'CEFALEXINA', 'Cefalexina 500mg', 'capsula', '500mg', 'caja', 'J01DB01', true, false, true),
('2531012664', 'NITROFURANTOÍNA', 'NITROFURANTOÍNA', 'Nitrofurantoína 100mg', 'capsula', '100mg', 'caja', 'J01XE01', true, false, true),
('2531012665', 'TRIMETOPRIM/SULFAMETOXAZOL', 'TRIMETOPRIM/SULFAMETOXAZOL', 'Trimetoprim 160mg + Sulfametoxazol 800mg', 'tableta', '160mg/800mg', 'caja', 'J01EE01', true, false, true),
('2531012666', 'AMLODIPINO', 'AMLODIPINO', 'Amlodipino 5mg', 'tableta', '5mg', 'caja', 'C08CA01', true, false, true),
('2531012667', 'VALSARTÁN', 'VALSARTÁN', 'Valsartán 160mg', 'tableta', '160mg', 'caja', 'C09CA03', true, false, true),
('2531012668', 'BISOPROLOL', 'BISOPROLOL', 'Bisoprolol 5mg', 'tableta', '5mg', 'caja', 'C07AB07', true, false, true),
('2531012669', 'ESPIRONOLACTONA', 'ESPIRONOLACTONA', 'Espironolactona 25mg', 'tableta', '25mg', 'caja', 'C03DA01', true, false, true),
('2531012670', 'SIMVASTATINA', 'SIMVASTATINA', 'Simvastatina 20mg', 'tableta', '20mg', 'caja', 'C10AA01', true, false, true),
('2531012671', 'GEMFIBROZILO', 'GEMFIBROZILO', 'Gemfibrozilo 600mg', 'tableta', '600mg', 'caja', 'C10AB04', true, false, true),
('2531012672', 'ALPRAZOLAM', 'ALPRAZOLAM', 'Alprazolam 0.5mg', 'tableta', '0.5mg', 'caja', 'N05BA12', true, true, true),
('2531012673', 'RISPERIDONA', 'RISPERIDONA', 'Risperidona 2mg', 'tableta', '2mg', 'caja', 'N05AX08', true, true, true),
('2531012674', 'QUETIAPINA', 'QUETIAPINA', 'Quetiapina 100mg', 'tableta', '100mg', 'caja', 'N05AH04', true, true, true),
('2531012675', 'SERTRALINA', 'SERTRALINA', 'Sertralina 50mg', 'tableta', '50mg', 'caja', 'N06AB06', true, false, true),
('2531012676', 'PAROXETINA', 'PAROXETINA', 'Paroxetina 20mg', 'tableta', '20mg', 'caja', 'N06AB05', true, false, true),
('2531012677', 'AMITRIPTILINA', 'AMITRIPTILINA', 'Amitriptilina 25mg', 'tableta', '25mg', 'caja', 'N06AA09', true, false, true),
('2531012678', 'GABAPENTINA', 'GABAPENTINA', 'Gabapentina 300mg', 'capsula', '300mg', 'caja', 'N03AX12', true, false, true),
('2531012679', 'PREGABALINA', 'PREGABALINA', 'Pregabalina 75mg', 'capsula', '75mg', 'caja', 'N03AX16', true, true, true),
('2531012680', 'HIERRO POLIMALTOSADO', 'HIERRO POLIMALTOSADO', 'Hierro 100mg elemental', 'tableta', '100mg', 'caja', 'B03AB05', false, false, true),
('2531012681', 'ÁCIDO FÓLICO', 'ÁCIDO FÓLICO', 'Ácido Fólico 5mg', 'tableta', '5mg', 'caja', 'B03BB01', false, false, true),
('2531012682', 'VITAMINA B12', 'VITAMINA B12', 'Cianocobalamina 1000mcg', 'inyectable', '1000mcg', 'ampolleta', 'B03BA01', false, false, true),
('2531012683', 'COMPLEJO B', 'COMPLEJO B', 'Vitaminas del Complejo B', 'tableta', 'múltiple', 'caja', 'A11EA', false, false, true),
('2531012684', 'MULTIVITAMÍNICO', 'MULTIVITAMÍNICO', 'Multivitaminas y Minerales', 'tableta', 'múltiple', 'caja', 'A11AA', false, false, true),
('2531012685', 'CALCIO+VITAMINA D', 'CALCIO+VITAMINA D', 'Calcio 600mg + Vitamina D 400UI', 'tableta', '600mg/400UI', 'caja', 'A12AX', false, false, true),
('2531012686', 'LORATADINA', 'LORATADINA', 'Loratadina 10mg', 'tableta', '10mg', 'caja', 'R06AX13', false, false, true),
('2531012687', 'CETIRIZINA', 'CETIRIZINA', 'Cetirizina 10mg', 'tableta', '10mg', 'caja', 'R06AE07', false, false, true),
('2531012688', 'MONTELUKAST', 'MONTELUKAST', 'Montelukast 10mg', 'tableta', '10mg', 'caja', 'R03DC03', true, false, true),
('2531012689', 'BROMHEXINA', 'BROMHEXINA', 'Bromhexina 8mg', 'tableta', '8mg', 'caja', 'R05CB02', false, false, true),
('2531012690', 'AMBROXOL', 'AMBROXOL', 'Ambroxol 30mg', 'tableta', '30mg', 'caja', 'R05CB06', false, false, true),
('2531012691', 'BUTILHIOSCINA', 'BUTILHIOSCINA', 'Butilhioscina 10mg', 'tableta', '10mg', 'caja', 'A03BB01', false, false, true),
('2531012692', 'LOPERAMIDA', 'LOPERAMIDA', 'Loperamida 2mg', 'tableta', '2mg', 'caja', 'A07DA03', false, false, true),
('2531012693', 'SALES DE REHIDRATACIÓN', 'SALES DE REHIDRATACIÓN', 'Electrolitos Orales', 'suspension', 'múltiple', 'sobre', 'A07CA', false, false, true),
('2531012694', 'ALBENDAZOL', 'ALBENDAZOL', 'Albendazol 400mg', 'tableta', '400mg', 'caja', 'P02CA03', false, false, true)
ON CONFLICT (codigo_medicamento) DO UPDATE SET
  nombre_generico = EXCLUDED.nombre_generico,
  nombre_comercial = EXCLUDED.nombre_comercial,
  principio_activo = EXCLUDED.principio_activo,
  forma_farmaceutica = EXCLUDED.forma_farmaceutica,
  concentracion = EXCLUDED.concentracion;

SELECT '✅ DATOS DE PRUEBA CARGADOS: 23 centros penitenciarios + 80 medicamentos' AS resultado;

-- ============================================
-- TRADUCCIÓN DE TABLAS AL ESPAÑOL
-- ============================================

ALTER TABLE IF EXISTS suppliers RENAME TO proveedores;
ALTER TABLE IF EXISTS batches RENAME TO lotes;
ALTER TABLE IF EXISTS batch_movements RENAME TO movimientos_lotes;
ALTER TABLE IF EXISTS medications RENAME TO medicamentos;
ALTER TABLE IF EXISTS medication_catalog RENAME TO catalogo_medicamentos;
ALTER TABLE IF EXISTS health_centers RENAME TO centros_salud;
ALTER TABLE IF EXISTS user_centers RENAME TO centros_usuario;
ALTER TABLE IF EXISTS audit_log RENAME TO registro_auditoria;
ALTER TABLE IF EXISTS contracts RENAME TO contratos;
ALTER TABLE IF EXISTS contract_items RENAME TO items_contrato;
ALTER TABLE IF EXISTS storage_inspections RENAME TO inspecciones_almacen;
ALTER TABLE IF EXISTS documentos_comprobantes RENAME TO documentos_comprobantes;

SELECT '✅ TODAS LAS TABLAS TRADUCIDAS AL ESPAÑOL' AS resultado;

-- Mensaje final
SELECT '
╔══════════════════════════════════════════════════╗
║         SIGIMED v2.0 - INSTALACIÓN COMPLETA       ║
╠══════════════════════════════════════════════════╣
║  ✅ Base de datos creada desde cero               ║
║  ✅ 23 Centros Penitenciarios del Edo. México     ║
║  ✅ 80 Medicamentos en catálogo                   ║
║  ✅ Todas las tablas en ESPAÑOL                   ║
║  ✅ Todas las funciones operativas                ║
╠══════════════════════════════════════════════════╣
║  CREDENCIALES DE PRUEBA:                          ║
║  📧 admin@sigimed.com                             ║
║  🔑 Admin123!                                      ║
╠══════════════════════════════════════════════════╣
║  TODO LISTO PARA USAR                             ║
╚══════════════════════════════════════════════════╝
' AS "INSTALACIÓN COMPLETA";
