-- ============================================
-- 🚀 FASE 1 COMPLETA - EJECUCIÓN DIRECTA
-- ============================================
-- Fecha: 2025-11-08
-- Instrucciones: Copia y pega TODO este archivo en Supabase SQL Editor
-- URL: https://cyslhzynfuetthxngpoy.supabase.co/project/_/sql
-- ============================================

-- ============================================
-- PARTE 1.1: TABLAS CORE
-- ============================================
BEGIN;

-- TABLA 1: SUPPLIERS (Proveedores)
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

-- TABLA 2: BATCHES (Lotes)
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

-- TABLA 3: BATCH_MOVEMENTS (Movimientos)
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
-- PARTE 1.2: TABLAS AUXILIARES
-- ============================================
BEGIN;

-- TABLA 4: USER_CENTERS (Multi-tenancy)
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

-- TABLA 5: AUDIT_LOG (Auditoría completa)
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

-- TABLA 6: INSTITUCIONES (Multi-institución)
CREATE TABLE IF NOT EXISTS instituciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  clave TEXT UNIQUE,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Agregar institucion_id a health_centers si no existe
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
-- PARTE 1.3: MÓDULOS AVANZADOS
-- ============================================
BEGIN;

-- TABLA 7: CONTRACTS (Contratos)
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

-- TABLA 8: CONTRACT_ITEMS (Ítems de contrato)
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

-- TABLA 9: STORAGE_INSPECTIONS (Inspecciones)
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

-- TABLA 10: DOCUMENTOS_COMPROBANTES (Gestión documental)
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
-- VERIFICACIÓN FINAL
-- ============================================
SELECT
  '✅ FASE 1 COMPLETADA' as resultado,
  'Todas las tablas creadas exitosamente' as detalle;

SELECT
  table_name as tabla_creada,
  'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'suppliers', 'batches', 'batch_movements',
    'user_centers', 'audit_log', 'instituciones',
    'contracts', 'contract_items', 'storage_inspections', 'documentos_comprobantes'
  )
ORDER BY table_name;

-- Mostrar conteo de índices creados
SELECT
  COUNT(*) as indices_creados
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
    'suppliers', 'batches', 'batch_movements',
    'user_centers', 'audit_log',
    'contracts', 'contract_items', 'storage_inspections', 'documentos_comprobantes'
  );
