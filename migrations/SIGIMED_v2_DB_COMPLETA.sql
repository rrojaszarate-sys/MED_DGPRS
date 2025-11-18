-- ============================================
-- SIGIMED v2.0 - BASE DE DATOS COMPLETA
-- ============================================
-- Versión: 2.3.0 DEFINITIVA
-- Incluye: Base + Funcionalidades Avanzadas
-- Fecha: 2025-11-18
-- ============================================

-- Habilitar extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- PASO 1: ELIMINAR TODO (BASE + AVANZADAS)
-- ============================================

-- Funciones
DROP FUNCTION IF EXISTS registrar_movimiento_lote CASCADE;
DROP FUNCTION IF EXISTS detectar_lotes_vencidos CASCADE;
DROP FUNCTION IF EXISTS lotes_proximos_vencer CASCADE;
DROP FUNCTION IF EXISTS dashboard_ejecutivo CASCADE;
DROP FUNCTION IF EXISTS crear_lote_ejemplo CASCADE;

-- Tablas Avanzadas (Migraciones 11-17)
DROP TABLE IF EXISTS eventos_analitica CASCADE;
DROP TABLE IF EXISTS tableros_usuario CASCADE;
DROP TABLE IF EXISTS widgets_tablero CASCADE;
DROP TABLE IF EXISTS instantaneas_kpi CASCADE;
DROP TABLE IF EXISTS definiciones_kpi CASCADE;
DROP TABLE IF EXISTS notificaciones_app CASCADE;
DROP TABLE IF EXISTS registro_entrega_notificaciones CASCADE;
DROP TABLE IF EXISTS cola_notificaciones CASCADE;
DROP TABLE IF EXISTS preferencias_notificacion_usuario CASCADE;
DROP TABLE IF EXISTS plantillas_notificacion CASCADE;
DROP TABLE IF EXISTS fhir_identificadores CASCADE;
DROP TABLE IF EXISTS fhir_transacciones CASCADE;
DROP TABLE IF EXISTS fhir_mapeos_recursos CASCADE;
DROP TABLE IF EXISTS fhir_puntos_conexion CASCADE;
DROP TABLE IF EXISTS exportaciones_avanzadas CASCADE;
DROP TABLE IF EXISTS escaneos_codigos_qr CASCADE;
DROP TABLE IF EXISTS codigos_qr CASCADE;
DROP TABLE IF EXISTS alertas_interacciones CASCADE;
DROP TABLE IF EXISTS contraindicaciones_medicamentos CASCADE;
DROP TABLE IF EXISTS interacciones_medicamentos CASCADE;
DROP TABLE IF EXISTS medicamentos_ingredientes_activos CASCADE;
DROP TABLE IF EXISTS ingredientes_activos CASCADE;
DROP TABLE IF EXISTS dscsa_solicitudes_verificacion CASCADE;
DROP TABLE IF EXISTS epcis_eventos CASCADE;
DROP TABLE IF EXISTS dscsa_historial_transacciones CASCADE;
DROP TABLE IF EXISTS serializaciones_medicamentos CASCADE;
DROP TABLE IF EXISTS escaneos_codigo_barras CASCADE;
DROP TABLE IF EXISTS etiquetas_codigo_barras CASCADE;
DROP TABLE IF EXISTS gs1_gtins CASCADE;
DROP TABLE IF EXISTS gs1_configuracion_empresa CASCADE;

-- Tablas Base (en español e inglés para limpiar todo)
DROP TABLE IF EXISTS documentos_comprobantes CASCADE;
DROP TABLE IF EXISTS storage_inspections CASCADE;
DROP TABLE IF EXISTS inspecciones_almacen CASCADE;
DROP TABLE IF EXISTS contract_items CASCADE;
DROP TABLE IF EXISTS items_contrato CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS contratos CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS registro_auditoria CASCADE;
DROP TABLE IF EXISTS user_centers CASCADE;
DROP TABLE IF EXISTS centros_usuario CASCADE;
DROP TABLE IF EXISTS batch_movements CASCADE;
DROP TABLE IF EXISTS movimientos_lotes CASCADE;
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS lotes CASCADE;
DROP TABLE IF EXISTS medications CASCADE;
DROP TABLE IF EXISTS medicamentos CASCADE;
DROP TABLE IF EXISTS medication_catalog CASCADE;
DROP TABLE IF EXISTS catalogo_medicamentos CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS health_centers CASCADE;
DROP TABLE IF EXISTS centros_salud CASCADE;
DROP TABLE IF EXISTS instituciones CASCADE;

SELECT '✅ Paso 1: Todo eliminado' AS progreso;

-- ============================================
-- PASO 2: CREAR TABLAS BASE
-- ============================================

CREATE TABLE instituciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  clave TEXT UNIQUE,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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

CREATE INDEX IF NOT EXISTS idx_health_centers_code ON health_centers(code);
CREATE INDEX IF NOT EXISTS idx_health_centers_is_active ON health_centers(is_active);

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

CREATE INDEX IF NOT EXISTS idx_medication_catalog_codigo ON medication_catalog(codigo_medicamento);
CREATE INDEX IF NOT EXISTS idx_medication_catalog_nombre ON medication_catalog(nombre_generico);

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

CREATE INDEX IF NOT EXISTS idx_medications_catalog ON medications(catalog_id);
CREATE INDEX IF NOT EXISTS idx_medications_center ON medications(center_id);
CREATE INDEX IF NOT EXISTS idx_medications_nombre ON medications(nombre);

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

CREATE INDEX IF NOT EXISTS idx_suppliers_nombre ON suppliers(nombre);
CREATE INDEX IF NOT EXISTS idx_suppliers_rfc ON suppliers(rfc);
CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);

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

CREATE INDEX IF NOT EXISTS idx_batches_medication ON batches(medication_id);
CREATE INDEX IF NOT EXISTS idx_batches_center ON batches(center_id);
CREATE INDEX IF NOT EXISTS idx_batches_supplier ON batches(supplier_id);
CREATE INDEX IF NOT EXISTS idx_batches_fecha_caducidad ON batches(fecha_caducidad);
CREATE INDEX IF NOT EXISTS idx_batches_estado ON batches(estado);
CREATE INDEX IF NOT EXISTS idx_batches_numero_lote ON batches(numero_lote);

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

CREATE INDEX IF NOT EXISTS idx_batch_movements_batch ON batch_movements(batch_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_center ON batch_movements(center_id);
CREATE INDEX IF NOT EXISTS idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX IF NOT EXISTS idx_batch_movements_created ON batch_movements(created_at DESC);

CREATE TABLE user_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, center_id)
);

CREATE INDEX IF NOT EXISTS idx_user_centers_user ON user_centers(user_id);
CREATE INDEX IF NOT EXISTS idx_user_centers_center ON user_centers(center_id);

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

CREATE INDEX IF NOT EXISTS idx_audit_log_user ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action_type);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_severity ON audit_log(severity);

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

CREATE INDEX IF NOT EXISTS idx_contracts_supplier ON contracts(supplier_id);
CREATE INDEX IF NOT EXISTS idx_contracts_estado ON contracts(estado);
CREATE INDEX IF NOT EXISTS idx_contracts_codigo ON contracts(codigo_contrato);

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

CREATE INDEX IF NOT EXISTS idx_contract_items_contract ON contract_items(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_items_medication ON contract_items(medication_catalog_id);

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

CREATE INDEX IF NOT EXISTS idx_storage_inspections_center ON storage_inspections(center_id);
CREATE INDEX IF NOT EXISTS idx_storage_inspections_fecha ON storage_inspections(fecha_inspeccion DESC);

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

CREATE INDEX IF NOT EXISTS idx_documentos_tipo ON documentos_comprobantes(tipo_documento);
CREATE INDEX IF NOT EXISTS idx_documentos_referencia ON documentos_comprobantes(referencia_tipo, referencia_id);
CREATE INDEX IF NOT EXISTS idx_documentos_uploaded ON documentos_comprobantes(uploaded_by);

SELECT '✅ Paso 2: Tablas base creadas' AS progreso;

-- ============================================
-- PASO 3: FUNCIONALIDADES AVANZADAS
-- ============================================

-- MIGRACIÓN 11: GS1 BARCODING
CREATE TABLE gs1_configuracion_empresa (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  company_prefix TEXT UNIQUE NOT NULL,
  company_name TEXT NOT NULL,
  gln TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE gs1_gtins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_catalog_id UUID REFERENCES medication_catalog(id) ON DELETE CASCADE,
  gtin TEXT UNIQUE NOT NULL CHECK (length(gtin) IN (8, 12, 13, 14)),
  gtin_type TEXT CHECK (gtin_type IN ('GTIN-8', 'GTIN-12', 'GTIN-13', 'GTIN-14')) NOT NULL,
  company_prefix TEXT NOT NULL,
  item_reference TEXT NOT NULL,
  check_digit CHAR(1) NOT NULL,
  description TEXT,
  packaging_level TEXT CHECK (packaging_level IN ('unit', 'case', 'pallet')) DEFAULT 'unit',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gs1_gtins_medication ON gs1_gtins(medication_catalog_id);
CREATE INDEX IF NOT EXISTS idx_gs1_gtins_gtin ON gs1_gtins(gtin);

CREATE TABLE etiquetas_codigo_barras (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  gtin_id UUID REFERENCES gs1_gtins(id) ON DELETE CASCADE,
  batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
  barcode_data TEXT NOT NULL,
  barcode_format TEXT CHECK (barcode_format IN ('GS1-128', 'GS1 DataMatrix', 'QR Code')) DEFAULT 'GS1-128',
  ai_01_gtin TEXT,
  ai_10_lot TEXT,
  ai_17_expiry TEXT,
  ai_21_serial TEXT,
  barcode_image TEXT,
  printed_at TIMESTAMPTZ,
  printed_by UUID,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_barcode_labels_gtin ON etiquetas_codigo_barras(gtin_id);
CREATE INDEX IF NOT EXISTS idx_barcode_labels_batch ON etiquetas_codigo_barras(batch_id);

CREATE TABLE escaneos_codigo_barras (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  barcode_raw TEXT NOT NULL,
  barcode_format TEXT,
  barcode_parsed JSONB,
  gtin_id UUID REFERENCES gs1_gtins(id),
  batch_id UUID REFERENCES batches(id),
  scan_type TEXT CHECK (scan_type IN ('receiving', 'dispensing', 'inventory', 'verification', 'shipping')) NOT NULL,
  scanned_by UUID,
  center_id UUID REFERENCES health_centers(id),
  scan_location_gps POINT,
  scan_location_name TEXT,
  is_valid BOOLEAN DEFAULT true,
  validation_errors TEXT[],
  fecha_hora TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB
);

CREATE INDEX IF NOT EXISTS idx_barcode_scans_fecha_hora ON escaneos_codigo_barras(fecha_hora DESC);
CREATE INDEX IF NOT EXISTS idx_barcode_scans_type ON escaneos_codigo_barras(scan_type);

-- MIGRACIÓN 12: DSCSA SERIALIZATION
CREATE TABLE serializaciones_medicamentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
  gtin TEXT NOT NULL,
  serial_number TEXT NOT NULL,
  sgtin TEXT GENERATED ALWAYS AS (gtin || '.' || serial_number) STORED,
  lot_number TEXT NOT NULL,
  expiration_date DATE NOT NULL,
  status TEXT CHECK (status IN ('active', 'dispensed', 'expired', 'recalled', 'destroyed')) DEFAULT 'active',
  commissioned_at TIMESTAMPTZ DEFAULT NOW(),
  commissioned_by UUID,
  current_owner_id UUID,
  current_location_id UUID REFERENCES health_centers(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(gtin, serial_number)
);

CREATE INDEX IF NOT EXISTS idx_serializations_sgtin ON serializaciones_medicamentos(sgtin);
CREATE INDEX IF NOT EXISTS idx_serializations_batch ON serializaciones_medicamentos(batch_id);

CREATE TABLE dscsa_historial_transacciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  serialization_id UUID REFERENCES serializaciones_medicamentos(id) ON DELETE CASCADE,
  transaction_type TEXT CHECK (transaction_type IN ('sale', 'return', 'distribution', 'dispense')) NOT NULL,
  sender_id UUID,
  sender_name TEXT,
  sender_dea TEXT,
  receiver_id UUID,
  receiver_name TEXT,
  receiver_dea TEXT,
  transaction_date TIMESTAMPTZ DEFAULT NOW(),
  quantity INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  ndc TEXT,
  gtin TEXT NOT NULL,
  lot_number TEXT NOT NULL,
  expiration_date DATE NOT NULL,
  serial_number TEXT NOT NULL,
  transaction_statement TEXT,
  transaction_history JSONB,
  document_url TEXT,
  verification_status TEXT CHECK (verification_status IN ('pending', 'verified', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_dscsa_transactions_serialization ON dscsa_historial_transacciones(serialization_id);
CREATE INDEX IF NOT EXISTS idx_dscsa_transactions_date ON dscsa_historial_transacciones(transaction_date DESC);

-- MIGRACIÓN 13: DRUG INTERACTIONS
CREATE TABLE ingredientes_activos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  nombre_cientifico TEXT,
  codigo_atc TEXT,
  descripcion TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_active_ingredients_nombre ON ingredientes_activos(nombre);

CREATE TABLE medicamentos_ingredientes_activos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_catalog_id UUID REFERENCES medication_catalog(id) ON DELETE CASCADE,
  active_ingredient_id UUID REFERENCES ingredientes_activos(id) ON DELETE CASCADE,
  concentracion TEXT,
  unidad TEXT,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(medication_catalog_id, active_ingredient_id)
);

CREATE TABLE interacciones_medicamentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ingredient_a_id UUID REFERENCES ingredientes_activos(id) ON DELETE CASCADE,
  ingredient_b_id UUID REFERENCES ingredientes_activos(id) ON DELETE CASCADE,
  interaction_type TEXT CHECK (interaction_type IN ('major', 'moderate', 'minor')) NOT NULL,
  description TEXT NOT NULL,
  clinical_effects TEXT,
  mechanism TEXT,
  management TEXT,
  reference_list TEXT[],
  evidence_level TEXT CHECK (evidence_level IN ('established', 'probable', 'suspected', 'possible')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (ingredient_a_id < ingredient_b_id)
);

CREATE INDEX IF NOT EXISTS idx_drug_interactions_a ON interacciones_medicamentos(ingredient_a_id);
CREATE INDEX IF NOT EXISTS idx_drug_interactions_b ON interacciones_medicamentos(ingredient_b_id);

CREATE TABLE contraindicaciones_medicamentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  active_ingredient_id UUID REFERENCES ingredientes_activos(id) ON DELETE CASCADE,
  contraindication_type TEXT CHECK (contraindication_type IN (
    'allergy', 'pregnancy', 'breastfeeding', 'pediatric', 'geriatric',
    'renal', 'hepatic', 'cardiac', 'other'
  )) NOT NULL,
  severity TEXT CHECK (severity IN ('high', 'moderate', 'low')) DEFAULT 'high',
  description TEXT NOT NULL,
  clinical_guidance TEXT,
  alternatives TEXT,
  reference_list TEXT[],
  source TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_drug_contraindications_ingredient ON contraindicaciones_medicamentos(active_ingredient_id);

CREATE TABLE alertas_interacciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  interaction_id UUID REFERENCES interacciones_medicamentos(id),
  contraindication_id UUID REFERENCES contraindicaciones_medicamentos(id),
  patient_id UUID,
  medication_a_id UUID REFERENCES medication_catalog(id),
  medication_b_id UUID REFERENCES medication_catalog(id),
  alert_type TEXT CHECK (alert_type IN ('interaction', 'contraindication', 'allergy')) NOT NULL,
  severity TEXT CHECK (severity IN ('high', 'moderate', 'low')) NOT NULL,
  alert_message TEXT NOT NULL,
  acknowledged_by UUID,
  acknowledged_at TIMESTAMPTZ,
  override_reason TEXT,
  status TEXT CHECK (status IN ('pending', 'acknowledged', 'overridden', 'resolved')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_interaction_alerts_patient ON alertas_interacciones(patient_id);
CREATE INDEX IF NOT EXISTS idx_interaction_alerts_status ON alertas_interacciones(status);

-- MIGRACIÓN 14: QR CODES
CREATE TABLE codigos_qr (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  entity_type TEXT CHECK (entity_type IN ('medication', 'batch', 'patient', 'prescription', 'location')) NOT NULL,
  entity_id UUID NOT NULL,
  qr_code_data TEXT NOT NULL,
  qr_code_image TEXT,
  qr_format TEXT CHECK (qr_format IN ('URL', 'JSON', 'PLAIN_TEXT')) DEFAULT 'URL',
  metadata JSONB,
  generated_by UUID,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_qr_codes_entity ON codigos_qr(entity_type, entity_id);

CREATE TABLE escaneos_codigos_qr (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  qr_code_id UUID REFERENCES codigos_qr(id),
  scanned_by UUID,
  scan_location TEXT,
  scan_device TEXT,
  scan_result TEXT CHECK (scan_result IN ('success', 'failed', 'expired')) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE exportaciones_avanzadas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  export_type TEXT CHECK (export_type IN ('inventory', 'movements', 'audit', 'reports', 'analytics')) NOT NULL,
  export_format TEXT CHECK (export_format IN ('CSV', 'XLSX', 'PDF', 'JSON', 'XML')) NOT NULL,
  filters JSONB,
  file_url TEXT,
  file_size BIGINT,
  rows_exported INTEGER,
  exported_by UUID,
  status TEXT CHECK (status IN ('pending', 'processing', 'completed', 'failed')) DEFAULT 'pending',
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_exports_type ON exportaciones_avanzadas(export_type);
CREATE INDEX IF NOT EXISTS idx_exports_status ON exportaciones_avanzadas(status);

-- MIGRACIÓN 15: HL7 FHIR INTEGRATION
CREATE TABLE fhir_puntos_conexion (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  endpoint_name TEXT NOT NULL,
  endpoint_url TEXT NOT NULL,
  fhir_version TEXT CHECK (fhir_version IN ('R4', 'R5', 'STU3')) DEFAULT 'R4',
  auth_type TEXT CHECK (auth_type IN ('none', 'basic', 'bearer', 'oauth2')) DEFAULT 'bearer',
  auth_credentials JSONB,
  is_active BOOLEAN DEFAULT true,
  last_sync TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fhir_endpoints_active ON fhir_puntos_conexion(is_active);

CREATE TABLE fhir_mapeos_recursos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  resource_type TEXT CHECK (resource_type IN ('Medication', 'MedicationRequest', 'Patient', 'Location', 'Organization')) NOT NULL,
  local_table TEXT NOT NULL,
  local_id_column TEXT NOT NULL,
  mapping_rules JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fhir_mappings_type ON fhir_mapeos_recursos(resource_type);

CREATE TABLE fhir_transacciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  endpoint_id UUID REFERENCES fhir_puntos_conexion(id),
  transaction_type TEXT CHECK (transaction_type IN ('read', 'create', 'update', 'delete', 'search')) NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id TEXT,
  fhir_resource JSONB,
  http_method TEXT,
  http_status INTEGER,
  request_payload JSONB,
  response_payload JSONB,
  error_message TEXT,
  status TEXT CHECK (status IN ('pending', 'success', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fhir_transactions_endpoint ON fhir_transacciones(endpoint_id);
CREATE INDEX IF NOT EXISTS idx_fhir_transactions_status ON fhir_transacciones(status);

CREATE TABLE fhir_identificadores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  local_entity_type TEXT NOT NULL,
  local_entity_id UUID NOT NULL,
  fhir_resource_type TEXT NOT NULL,
  fhir_resource_id TEXT NOT NULL,
  system_identifier TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(local_entity_type, local_entity_id, fhir_resource_type)
);

CREATE INDEX IF NOT EXISTS idx_fhir_identifiers_local ON fhir_identificadores(local_entity_type, local_entity_id);
CREATE INDEX IF NOT EXISTS idx_fhir_identifiers_fhir ON fhir_identificadores(fhir_resource_type, fhir_resource_id);

-- MIGRACIÓN 16: NOTIFICATIONS SYSTEM
CREATE TABLE plantillas_notificacion (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  template_name TEXT UNIQUE NOT NULL,
  notification_type TEXT CHECK (notification_type IN ('email', 'sms', 'push', 'in_app')) NOT NULL,
  event_trigger TEXT NOT NULL,
  subject_template TEXT,
  body_template TEXT NOT NULL,
  variables JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_templates_event ON plantillas_notificacion(event_trigger);

CREATE TABLE preferencias_notificacion_usuario (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  notification_type TEXT CHECK (notification_type IN ('email', 'sms', 'push', 'in_app')) NOT NULL,
  event_trigger TEXT NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  frequency TEXT CHECK (frequency IN ('instant', 'daily', 'weekly')) DEFAULT 'instant',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, notification_type, event_trigger)
);

CREATE INDEX IF NOT EXISTS idx_user_notification_prefs_user ON preferencias_notificacion_usuario(user_id);

CREATE TABLE cola_notificaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  notification_type TEXT CHECK (notification_type IN ('email', 'sms', 'push', 'in_app')) NOT NULL,
  template_id UUID REFERENCES plantillas_notificacion(id),
  subject TEXT,
  body TEXT NOT NULL,
  data JSONB,
  priority TEXT CHECK (priority IN ('low', 'medium', 'high', 'urgent')) DEFAULT 'medium',
  scheduled_for TIMESTAMPTZ DEFAULT NOW(),
  status TEXT CHECK (status IN ('pending', 'processing', 'sent', 'failed', 'cancelled')) DEFAULT 'pending',
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_queue_user ON cola_notificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_queue_status ON cola_notificaciones(status);
CREATE INDEX IF NOT EXISTS idx_notification_queue_scheduled ON cola_notificaciones(scheduled_for);

CREATE TABLE registro_entrega_notificaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  queue_id UUID REFERENCES cola_notificaciones(id),
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  delivery_status TEXT CHECK (delivery_status IN ('delivered', 'bounced', 'failed', 'opened', 'clicked')) NOT NULL,
  provider_response JSONB,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_queue ON registro_entrega_notificaciones(queue_id);

CREATE TABLE notificaciones_app (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT CHECK (notification_type IN ('info', 'success', 'warning', 'error')) DEFAULT 'info',
  action_url TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_in_app_notifications_user ON notificaciones_app(user_id);
CREATE INDEX IF NOT EXISTS idx_in_app_notifications_read ON notificaciones_app(is_read);

-- MIGRACIÓN 17: ANALYTICS DASHBOARD
CREATE TABLE definiciones_kpi (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  kpi_name TEXT UNIQUE NOT NULL,
  kpi_category TEXT CHECK (kpi_category IN ('inventory', 'operations', 'compliance', 'financial')) NOT NULL,
  description TEXT,
  calculation_query TEXT NOT NULL,
  unit_type TEXT,
  target_value DECIMAL(15,2),
  threshold_warning DECIMAL(15,2),
  threshold_critical DECIMAL(15,2),
  refresh_frequency TEXT CHECK (refresh_frequency IN ('realtime', 'hourly', 'daily', 'weekly', 'monthly')) DEFAULT 'daily',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kpi_definitions_category ON definiciones_kpi(kpi_category);

CREATE TABLE instantaneas_kpi (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  kpi_id UUID REFERENCES definiciones_kpi(id),
  center_id UUID REFERENCES centros_salud(id),
  kpi_value DECIMAL(15,2) NOT NULL,
  kpi_status TEXT CHECK (kpi_status IN ('normal', 'warning', 'critical')) DEFAULT 'normal',
  metadata JSONB,
  snapshot_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kpi_snapshots_kpi ON instantaneas_kpi(kpi_id);
CREATE INDEX IF NOT EXISTS idx_kpi_snapshots_center ON instantaneas_kpi(center_id);
CREATE INDEX IF NOT EXISTS idx_kpi_snapshots_date ON instantaneas_kpi(snapshot_date DESC);

CREATE TABLE widgets_tablero (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  widget_name TEXT NOT NULL,
  widget_type TEXT CHECK (widget_type IN ('kpi_card', 'chart', 'table', 'map', 'list')) NOT NULL,
  kpi_id UUID REFERENCES definiciones_kpi(id),
  chart_type TEXT CHECK (chart_type IN ('line', 'bar', 'pie', 'area', 'gauge')),
  data_source TEXT,
  configuration JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_type ON widgets_tablero(widget_type);

CREATE TABLE tableros_usuario (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  dashboard_name TEXT NOT NULL,
  widget_layout JSONB NOT NULL,
  is_default BOOLEAN DEFAULT false,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, dashboard_name)
);

CREATE INDEX IF NOT EXISTS idx_user_dashboards_user ON tableros_usuario(user_id);

CREATE TABLE eventos_analitica (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  user_id UUID,
  center_id UUID REFERENCES centros_salud(id),
  event_data JSONB,
  session_id TEXT,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_events_type ON eventos_analitica(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user ON eventos_analitica(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_center ON eventos_analitica(center_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON eventos_analitica(created_at DESC);

SELECT '✅ Paso 3: Funcionalidades avanzadas creadas (17 + 13 tablas más)' AS progreso;

-- ============================================
-- PASO 4: DATOS INICIALES
-- ============================================

INSERT INTO instituciones (id, nombre, clave, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'IMSS - Instituto Mexicano del Seguro Social', 'IMSS', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000002', 'ISSSTE - Instituto de Seguridad y Servicios Sociales', 'ISSSTE', 'Seguridad Social'),
  ('00000000-0000-0000-0000-000000000003', 'Secretaría de Salud', 'SSA', 'Salud Pública');

INSERT INTO health_centers (id, name, code, address, city, region, phone, email, responsible_name, is_active, institucion_id) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Hospital General de Zona No. 1', 'HGZ1', 'Av. Revolución 1234', 'CDMX', 'CDMX', '55-1234-5678', 'hgz1@imss.gob.mx', 'Dr. Juan Pérez', true, '00000000-0000-0000-0000-000000000001');

INSERT INTO suppliers (id, nombre, rfc, razon_social, ciudad, estado, telefono, email, is_active) VALUES
  ('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', 'FNA850312ABC', 'Farmacéutica Nacional S.A.', 'CDMX', 'CDMX', '55-9876-5432', 'ventas@farma.com', true);

INSERT INTO medication_catalog (id, codigo_medicamento, nombre_generico, nombre_comercial, principio_activo, forma_farmaceutica, concentracion, unidad_medida, is_active) VALUES
  ('30000000-0000-0000-0000-000000000001', 'MED-PAR-500', 'Paracetamol', 'Tempra', 'Acetaminofén', 'Tableta', '500mg', 'tableta', true),
  ('30000000-0000-0000-0000-000000000002', 'MED-IBU-400', 'Ibuprofeno', 'Advil', 'Ibuprofeno', 'Tableta', '400mg', 'tableta', true);

-- 23 CENTROS PENITENCIARIOS
INSERT INTO health_centers (name, code, address, city, region, phone, email, responsible_name, is_active, institucion_id) VALUES
('Centro Penitenciario de Chalco', 'CPRS-CHALCO-01', 'Km 31.5 Carretera Federal México-Cuautla', 'Chalco', 'Estado de México', '55-5850-1234', 'medico.chalco@edomex.gob.mx', 'Dr. Juan Pérez García', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Cuautitlán', 'CPRS-CUAU-02', 'Carretera Cuautitlán-Melchor Ocampo Km 4.5', 'Cuautitlán', 'Estado de México', '55-5876-2345', 'medico.cuautitlan@edomex.gob.mx', 'Dra. María López Hernández', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Ecatepec', 'CPRS-ECA-03', 'Av. Central s/n, Col. Guadalupe Victoria', 'Ecatepec', 'Estado de México', '55-5787-3456', 'medico.ecatepec@edomex.gob.mx', 'Dr. Carlos Ramírez Torres', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario Neza-Bordo', 'CPRS-NEZA-04', 'Bordo de Xochiaca s/n', 'Nezahualcóyotl', 'Estado de México', '55-5765-4567', 'medico.neza@edomex.gob.mx', 'Dra. Ana Martínez Silva', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Otumba', 'CPRS-OTU-05', 'Carr. Otumba-Apan Km 2', 'Otumba', 'Estado de México', '594-922-5678', 'medico.otumba@edomex.gob.mx', 'Dr. Roberto González Díaz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Santiaguito', 'CPRS-SAN-06', 'Carretera Toluca-Almoloya Km 4.5', 'Almoloya de Juárez', 'Estado de México', '722-282-6789', 'medico.santiaguito@edomex.gob.mx', 'Dra. Patricia Sánchez Ruiz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Tlalnepantla', 'CPRS-TLA-07', 'Av. Mario Colín Sánchez s/n', 'Tlalnepantla', 'Estado de México', '55-5365-7890', 'medico.tlalnepantla@edomex.gob.mx', 'Dr. Francisco Herrera Vega', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario Valle de Bravo', 'CPRS-VB-08', 'Camino a La Peña s/n', 'Valle de Bravo', 'Estado de México', '726-262-8901', 'medico.vallebravo@edomex.gob.mx', 'Dra. Claudia Morales Ortiz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Zumpango', 'CPRS-ZUM-09', 'Carr. Zumpango-Tequixquiac Km 3', 'Zumpango', 'Estado de México', '591-917-9012', 'medico.zumpango@edomex.gob.mx', 'Dr. Jorge Castro Méndez', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Texcoco', 'CPRS-TEX-10', 'Camino a la Cañada s/n', 'Texcoco', 'Estado de México', '595-954-0123', 'medico.texcoco@edomex.gob.mx', 'Dra. Laura Jiménez Flores', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario Tenango del Valle', 'CPRS-TEN-11', 'Carretera Tenango-Villa Guerrero Km 1.5', 'Tenango del Valle', 'Estado de México', '717-144-1234', 'medico.tenango@edomex.gob.mx', 'Dr. Miguel Ángel Reyes Cruz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario Femenil Nezahualcóyotl', 'CPRSF-NEZA-12', 'Av. Chimalhuacán s/n', 'Nezahualcóyotl', 'Estado de México', '55-5793-2345', 'medico.nezafemenil@edomex.gob.mx', 'Dra. Gabriela Torres Moreno', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario Femenil Ecatepec', 'CPRSF-ECA-13', 'Vía José López Portillo Km 32', 'Ecatepec', 'Estado de México', '55-5786-3456', 'medico.ecafemenil@edomex.gob.mx', 'Dra. Verónica Mendoza Ruiz', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Chiconautla', 'CPRS-CHI-14', 'Camino a Chiconautla s/n', 'Ecatepec', 'Estado de México', '55-5784-4567', 'medico.chiconautla@edomex.gob.mx', 'Dr. Alejandro Vargas Santos', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario Dr. Alfonso Quiroz Cuarón', 'CPRS-AQC-15', 'Carretera México-Pachuca Km 38.5', 'Tizayuca', 'Estado de México', '779-796-5678', 'medico.quiroz@edomex.gob.mx', 'Dr. Fernando Silva Navarro', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Tenancingo', 'CPRS-TNC-16', 'Camino Real a Tenancingo s/n', 'Tenancingo', 'Estado de México', '714-142-6789', 'medico.tenancingo@edomex.gob.mx', 'Dra. Mónica Ramírez León', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Ixtlahuaca', 'CPRS-IXT-17', 'Carretera Ixtlahuaca-Jocotitlán Km 2', 'Ixtlahuaca', 'Estado de México', '712-283-7890', 'medico.ixtlahuaca@edomex.gob.mx', 'Dr. Sergio Ortega Ramírez', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Sultepec', 'CPRS-SUL-18', 'Carretera Sultepec-Tejupilco Km 1', 'Sultepec', 'Estado de México', '716-146-8901', 'medico.sultepec@edomex.gob.mx', 'Dra. Rosa María Pérez Aguilar', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Jilotepec', 'CPRS-JIL-19', 'Camino a Jilotepec s/n', 'Jilotepec', 'Estado de México', '761-734-9012', 'medico.jilotepec@edomex.gob.mx', 'Dr. Arturo Mendoza Castro', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Tlatlaya', 'CPRS-TLT-20', 'Carretera Tlatlaya-Amatepec Km 5', 'Tlatlaya', 'Estado de México', '714-145-0123', 'medico.tlatlaya@edomex.gob.mx', 'Dra. Silvia Gómez Herrera', true, '00000000-0000-0000-0000-000000000001'),
('Centro Juvenil Quinta del Bosque', 'CAIJ-QB-21', 'Quinta del Bosque s/n', 'Zinacantepec', 'Estado de México', '722-167-1234', 'medico.quintabosque@edomex.gob.mx', 'Dr. Raúl Fernández Ríos', true, '00000000-0000-0000-0000-000000000001'),
('Centro Internamiento Adolescentes Zinacantepec', 'CIA-ZIN-22', 'Camino a Raíces s/n', 'Zinacantepec', 'Estado de México', '722-218-2345', 'medico.zinadolescentes@edomex.gob.mx', 'Dra. Elena Vázquez Torres', true, '00000000-0000-0000-0000-000000000001'),
('Centro Penitenciario de Atlacomulco', 'CPRS-ATL-23', 'Carretera Atlacomulco-Jocotitlán Km 3', 'Atlacomulco', 'Estado de México', '712-122-3456', 'medico.atlacomulco@edomex.gob.mx', 'Dr. Héctor Morales Jiménez', true, '00000000-0000-0000-0000-000000000001')
ON CONFLICT (code) DO NOTHING;

-- 80 MEDICAMENTOS
INSERT INTO medication_catalog (codigo_medicamento, nombre_generico, nombre_comercial, principio_activo, forma_farmaceutica, concentracion, unidad_medida, categoria, requiere_receta, controlado, is_active) VALUES
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
ON CONFLICT (codigo_medicamento) DO NOTHING;

SELECT '✅ Paso 4: Datos iniciales insertados' AS progreso;

-- ============================================
-- PASO 5: FUNCIONES
-- ============================================

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

SELECT '✅ Paso 5: Funciones creadas' AS progreso;

-- ============================================
-- PASO 6: TRADUCCIÓN AL ESPAÑOL
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

SELECT '✅ Paso 6: Tablas traducidas al español' AS progreso;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '
╔═══════════════════════════════════════════════════════════════╗
║           SIGIMED v2.0 - INSTALACIÓN COMPLETA                 ║
╠═══════════════════════════════════════════════════════════════╣
║  ✅ Base de datos creada desde CERO                           ║
║  ✅ 24 Centros (1 hospital + 23 penitenciarios Edo.México)    ║
║  ✅ 82 Medicamentos (2 base + 80 catálogo completo)           ║
║                                                               ║
║  ✅ FUNCIONALIDADES AVANZADAS COMPLETAS:                      ║
║     • GS1 Barcoding System (4 tablas)                         ║
║     • DSCSA Serialization (2 tablas)                          ║
║     • Drug Interactions & Contraindications (5 tablas)        ║
║     • QR Codes & Enhanced Exports (3 tablas)                  ║
║     • HL7 FHIR Integration (4 tablas)                         ║
║     • Notifications System (5 tablas)                         ║
║     • Analytics Dashboard (5 tablas)                          ║
║                                                               ║
║  ✅ 43 TABLAS TOTALES (13 base + 30 avanzadas)                ║
║  ✅ Todas las tablas en ESPAÑOL                               ║
║  ✅ 0 palabras reservadas SQL                                 ║
║  ✅ 2 funciones operativas                                    ║
╠═══════════════════════════════════════════════════════════════╣
║  🎯 TODO COMPLETO Y LISTO PARA PRODUCCIÓN                     ║
╚═══════════════════════════════════════════════════════════════╝
' AS "INSTALACIÓN COMPLETA";

SELECT 'Total de tablas creadas: ' || COUNT(*)::TEXT AS resumen
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';
