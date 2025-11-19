BEGIN;

DROP VIEW IF EXISTS medications CASCADE;
DROP VIEW IF EXISTS health_centers CASCADE;
DROP VIEW IF EXISTS batches CASCADE;
DROP VIEW IF EXISTS batch_movements CASCADE;
DROP VIEW IF EXISTS suppliers CASCADE;

DROP TABLE IF EXISTS movimientos_lotes CASCADE;
DROP TABLE IF EXISTS lotes CASCADE;
DROP TABLE IF EXISTS medicamentos CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;

CREATE TABLE proveedores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  rfc TEXT,
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
  calificacion NUMERIC CHECK (calificacion >= 0 AND calificacion <= 5),
  notas TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE medicamentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  center_id UUID REFERENCES centros_salud(id),
  catalog_id UUID REFERENCES catalogo_medicamentos(id),
  nombre TEXT NOT NULL,
  formula_activa TEXT NOT NULL,
  lote TEXT NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  estado TEXT NOT NULL CHECK (estado IN ('Disponible', 'No Disponible', 'Cuarentena', 'Vencido')),
  proveedor_id UUID REFERENCES proveedores(id),
  costo_unitario NUMERIC,
  precio_venta NUMERIC,
  ubicacion_fisica TEXT,
  codigo_barras TEXT,
  qr_code TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID
);

CREATE TABLE lotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_id UUID REFERENCES medicamentos(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES catalogo_medicamentos(id),
  centro_id UUID REFERENCES centros_salud(id),
  supplier_id UUID REFERENCES proveedores(id),
  numero_lote TEXT NOT NULL,
  cantidad_inicial INTEGER NOT NULL CHECK (cantidad_inicial >= 0),
  cantidad_actual INTEGER NOT NULL CHECK (cantidad_actual >= 0),
  fecha_fabricacion DATE,
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  ubicacion_fisica TEXT,
  temperatura_almacenamiento TEXT,
  proveedor TEXT,
  precio_unitario NUMERIC,
  contrato TEXT,
  stock_minimo INTEGER DEFAULT 10,
  stock_maximo INTEGER,
  estado TEXT DEFAULT 'disponible' CHECK (estado IN ('disponible', 'cuarentena', 'vencido', 'agotado')),
  observaciones TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(medication_catalog_id, numero_lote, centro_id)
);

CREATE TABLE movimientos_lotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_id UUID REFERENCES lotes(id) ON DELETE CASCADE,
  medication_id UUID REFERENCES medicamentos(id),
  medication_catalog_id UUID REFERENCES catalogo_medicamentos(id),
  center_id UUID REFERENCES centros_salud(id),
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN ('entrada', 'salida', 'ajuste', 'transferencia_salida', 'transferencia_entrada', 'devolucion', 'merma', 'vencimiento', 'destruccion')),
  cantidad INTEGER NOT NULL,
  cantidad_anterior INTEGER NOT NULL,
  cantidad_posterior INTEGER NOT NULL,
  centro_origen_id UUID REFERENCES centros_salud(id),
  centro_destino_id UUID REFERENCES centros_salud(id),
  numero_documento TEXT,
  motivo TEXT NOT NULL,
  observaciones TEXT,
  usuario_responsable UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'
);

CREATE VIEW health_centers AS
SELECT id, name, code, direccion as address, ciudad as city, estado as region, telefono as phone, email, responsable_nombre as responsible_name, is_active, institucion_id, created_at, updated_at
FROM centros_salud;

CREATE VIEW suppliers AS SELECT * FROM proveedores;

CREATE VIEW medications AS
SELECT id, center_id, catalog_id, nombre, formula_activa as descripcion, 'unidad' as unidad_medida, 'General' as categoria, false as requiere_refrigeracion,
CASE WHEN estado = 'Disponible' THEN true ELSE false END as is_active, created_at, updated_at
FROM medicamentos;

CREATE VIEW batches AS
SELECT id, medication_id, centro_id as center_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_fabricacion, fecha_caducidad, fecha_ingreso, ubicacion_fisica, temperatura_almacenamiento, stock_minimo, stock_maximo, estado, observaciones, is_active, created_at, updated_at
FROM lotes;

CREATE VIEW batch_movements AS SELECT * FROM movimientos_lotes;

INSERT INTO proveedores (id, nombre, is_active) VALUES
('20000000-0000-0000-0000-000000000001', 'Farmacéutica Nacional', true);

INSERT INTO medicamentos (center_id, catalog_id, nombre, formula_activa, lote, cantidad, fecha_caducidad, estado, proveedor_id)
SELECT
  cs.id,
  cm.id,
  cm.nombre,
  COALESCE(cm.nombre_generico, cm.nombre),
  'LOTE-001',
  1000,
  CURRENT_DATE + INTERVAL '2 years',
  'Disponible',
  '20000000-0000-0000-0000-000000000001'
FROM catalogo_medicamentos cm
CROSS JOIN (SELECT id FROM centros_salud WHERE is_active = true LIMIT 3) cs
WHERE cm.is_active = true
LIMIT 50;

INSERT INTO lotes (medication_id, medication_catalog_id, centro_id, supplier_id, numero_lote, cantidad_inicial, cantidad_actual, fecha_caducidad, estado, is_active)
SELECT
  m.id, m.catalog_id, m.center_id, m.proveedor_id,
  'L-' || LPAD((ROW_NUMBER() OVER())::TEXT, 4, '0'),
  3000, 2500, CURRENT_DATE + INTERVAL '2 years', 'disponible', true
FROM medicamentos m;

INSERT INTO movimientos_lotes (batch_id, medication_id, medication_catalog_id, center_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_posterior, motivo)
SELECT l.id, l.medication_id, l.medication_catalog_id, l.centro_id, 'entrada', l.cantidad_inicial, 0, l.cantidad_inicial, 'Ingreso inicial'
FROM lotes l;

COMMIT;

SELECT 'medications' as tabla, COUNT(*) FROM medications
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'batch_movements', COUNT(*) FROM batch_movements;
