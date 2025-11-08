import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';

const SUPABASE_URL = 'https://cyslhzynfuetthxngpoy.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQ1MTMzMSwiZXhwIjoyMDc4MDI3MzMxfQ.SAeM-AoJLCN5vTryASDVqGpEDiKEmkckYeZTvpybdAk';

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

console.log('🚀 Ejecutando Fase 1 - Script SQL completo\n');

// Leer el archivo SQL
const sqlScript = readFileSync('./EJECUTAR_FASE_1_COMPLETA.sql', 'utf8');

console.log('📝 Intentando ejecutar SQL via Supabase...\n');

// Intentar ejecutar statement por statement
const statements = [
  // PARTE 1.1
  `CREATE TABLE IF NOT EXISTS suppliers (
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
  );`,

  `CREATE INDEX IF NOT EXISTS idx_suppliers_nombre ON suppliers(nombre);`,
  `CREATE INDEX IF NOT EXISTS idx_suppliers_rfc ON suppliers(rfc);`,
  `CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);`,

  `CREATE TABLE IF NOT EXISTS batches (
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
  );`,

  `CREATE INDEX IF NOT EXISTS idx_batches_medication ON batches(medication_id);`,
  `CREATE INDEX IF NOT EXISTS idx_batches_center ON batches(center_id);`,
  `CREATE INDEX IF NOT EXISTS idx_batches_supplier ON batches(supplier_id);`,
  `CREATE INDEX IF NOT EXISTS idx_batches_fecha_caducidad ON batches(fecha_caducidad);`,
  `CREATE INDEX IF NOT EXISTS idx_batches_estado ON batches(estado);`,
  `CREATE INDEX IF NOT EXISTS idx_batches_numero_lote ON batches(numero_lote);`,

  `CREATE TABLE IF NOT EXISTS batch_movements (
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
  );`,

  `CREATE INDEX IF NOT EXISTS idx_batch_movements_batch ON batch_movements(batch_id);`,
  `CREATE INDEX IF NOT EXISTS idx_batch_movements_medication ON batch_movements(medication_id);`,
  `CREATE INDEX IF NOT EXISTS idx_batch_movements_center ON batch_movements(center_id);`,
  `CREATE INDEX IF NOT EXISTS idx_batch_movements_tipo ON batch_movements(tipo_movimiento);`,
  `CREATE INDEX IF NOT EXISTS idx_batch_movements_created ON batch_movements(created_at DESC);`
];

console.log(`Ejecutando ${statements.length} statements...\n`);

for (let i = 0; i < statements.length; i++) {
  const stmt = statements[i].trim();
  const preview = stmt.substring(0, 60).replace(/\n/g, ' ') + '...';

  try {
    const { data, error } = await supabase.rpc('exec', { sql: stmt });

    if (error) {
      console.log(`${i+1}. ❌ ${preview}`);
      console.log(`   Error: ${error.message}`);
    } else {
      console.log(`${i+1}. ✅ ${preview}`);
    }
  } catch (e) {
    console.log(`${i+1}. ⚠️  ${preview}`);
    console.log(`   ${e.message}`);
  }
}

console.log('\n🔍 Verificando tablas creadas vía SQL directo...\n');

// Verificar con query SQL simple
const { data, error } = await supabase
  .from('suppliers')
  .select('count')
  .limit(0);

if (error) {
  console.log('❌ Tabla suppliers:', error.message);
} else {
  console.log('✅ Tabla suppliers existe');
}
