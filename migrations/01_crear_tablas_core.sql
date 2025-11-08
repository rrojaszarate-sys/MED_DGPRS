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
