-- SIGIMED Database Schema
-- PostgreSQL + Supabase
-- Version: 2.0

-- ============================================
-- EXTENSIONES
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para búsqueda full-text

-- ============================================
-- TABLAS PRINCIPALES
-- ============================================

-- Tabla de centros de salud
CREATE TABLE health_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  address TEXT,
  city TEXT,
  region TEXT,
  phone TEXT,
  email TEXT,
  responsible_name TEXT,
  responsible_role TEXT,
  storage_capacity INTEGER,
  has_refrigeration BOOLEAN DEFAULT false,
  operating_hours JSONB,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de perfiles de usuario (extiende auth.users de Supabase)
CREATE TABLE users_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  permissions JSONB DEFAULT '[]',
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE,
  deleted_by UUID REFERENCES users_profiles(id)
);

-- Relación muchos-a-muchos: usuarios y centros
CREATE TABLE user_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users_profiles(id) ON DELETE CASCADE,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, center_id)
);

-- Tabla de proveedores
CREATE TABLE suppliers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  ruc TEXT UNIQUE,
  address TEXT,
  city TEXT,
  phone TEXT,
  email TEXT,
  contact_name TEXT,
  contact_phone TEXT,
  payment_terms TEXT,
  delivery_time_days INTEGER,
  rating DECIMAL(2, 1) CHECK (rating >= 0 AND rating <= 5),
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Catálogo maestro de medicamentos
CREATE TABLE medication_catalog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_comercial TEXT NOT NULL,
  nombre_generico TEXT NOT NULL,
  formula_activa TEXT NOT NULL,
  concentracion TEXT,
  forma_farmaceutica TEXT NOT NULL CHECK (forma_farmaceutica IN (
    'tableta', 'capsula', 'jarabe', 'suspension', 'inyectable',
    'crema', 'ungüento', 'supositorio', 'gotas', 'aerosol'
  )),
  uso_terapeutico TEXT,
  categoria_farmacologica TEXT, -- Código ATC
  contraindicaciones TEXT,
  efectos_secundarios TEXT,
  interacciones TEXT,
  dosis_usual TEXT,
  fabricantes_autorizados TEXT[],
  imagen_producto TEXT,
  ficha_tecnica_url TEXT,
  requiere_receta BOOLEAN DEFAULT false,
  es_controlado BOOLEAN DEFAULT false,
  temperatura_almacenamiento TEXT CHECK (temperatura_almacenamiento IN (
    'ambiente', 'refrigerado', 'congelado', 'especial'
  )),
  temperatura_min DECIMAL(5, 2),
  temperatura_max DECIMAL(5, 2),
  condiciones_especiales TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id)
);

-- Inventario de medicamentos por centro
CREATE TABLE medications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  catalog_id UUID REFERENCES medication_catalog(id),
  nombre TEXT NOT NULL,
  formula_activa TEXT NOT NULL,
  lote TEXT NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  estado TEXT NOT NULL CHECK (estado IN ('Disponible', 'No Disponible', 'Cuarentena')),
  proveedor_id UUID REFERENCES suppliers(id),
  costo_unitario DECIMAL(10, 2),
  precio_venta DECIMAL(10, 2),
  ubicacion_fisica TEXT,
  codigo_barras TEXT,
  qr_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id)
);

-- Alertas de medicamentos próximos a caducar
CREATE TABLE alertas_medicamentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medicamento_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  centro_id UUID REFERENCES health_centers(id),
  nivel_alerta TEXT NOT NULL CHECK (nivel_alerta IN ('critico', 'urgente', 'preventivo')),
  dias_restantes INTEGER NOT NULL,
  visto BOOLEAN DEFAULT false,
  resuelta BOOLEAN DEFAULT false,
  visto_por UUID REFERENCES users_profiles(id),
  visto_en TIMESTAMP WITH TIME ZONE,
  resuelta_por UUID REFERENCES users_profiles(id),
  resuelta_en TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Transferencias entre centros
CREATE TABLE transfers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  transfer_number TEXT UNIQUE NOT NULL,
  origin_center_id UUID NOT NULL REFERENCES health_centers(id),
  destination_center_id UUID NOT NULL REFERENCES health_centers(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'approved', 'rejected', 'in_transit', 'received', 'completed'
  )),
  requested_by UUID NOT NULL REFERENCES users_profiles(id),
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_by UUID REFERENCES users_profiles(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  shipped_by UUID REFERENCES users_profiles(id),
  shipped_at TIMESTAMP WITH TIME ZONE,
  received_by UUID REFERENCES users_profiles(id),
  received_at TIMESTAMP WITH TIME ZONE,
  rejection_reason TEXT,
  notes TEXT,
  tracking_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE transfer_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  transfer_id UUID NOT NULL REFERENCES transfers(id) ON DELETE CASCADE,
  medication_id UUID NOT NULL REFERENCES medications(id),
  cantidad_solicitada INTEGER NOT NULL CHECK (cantidad_solicitada > 0),
  cantidad_aprobada INTEGER CHECK (cantidad_aprobada >= 0),
  cantidad_enviada INTEGER CHECK (cantidad_enviada >= 0),
  cantidad_recibida INTEGER CHECK (cantidad_recibida >= 0),
  lote TEXT,
  fecha_caducidad DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Requisiciones internas
CREATE TABLE requisitions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  requisition_number TEXT UNIQUE NOT NULL,
  requesting_service TEXT NOT NULL,
  requesting_user_id UUID NOT NULL REFERENCES users_profiles(id),
  center_id UUID NOT NULL REFERENCES health_centers(id),
  status TEXT NOT NULL DEFAULT 'borrador' CHECK (status IN (
    'borrador', 'solicitada', 'aprobada', 'rechazada', 'surtida', 'completada'
  )),
  fecha_solicitud TIMESTAMP WITH TIME ZONE,
  fecha_necesaria DATE,
  aprobada_por UUID REFERENCES users_profiles(id),
  aprobada_en TIMESTAMP WITH TIME ZONE,
  motivo_rechazo TEXT,
  surtida_por UUID REFERENCES users_profiles(id),
  surtida_en TIMESTAMP WITH TIME ZONE,
  observaciones TEXT,
  prioridad TEXT CHECK (prioridad IN ('normal', 'urgente', 'emergencia')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE requisition_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  requisition_id UUID NOT NULL REFERENCES requisitions(id) ON DELETE CASCADE,
  medication_id UUID NOT NULL REFERENCES medications(id),
  cantidad_solicitada INTEGER NOT NULL CHECK (cantidad_solicitada > 0),
  cantidad_aprobada INTEGER CHECK (cantidad_aprobada >= 0),
  cantidad_surtida INTEGER CHECK (cantidad_surtida >= 0),
  justificacion TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ajustes de inventario
CREATE TABLE inventory_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  adjustment_number TEXT UNIQUE NOT NULL,
  medication_id UUID REFERENCES medications(id),
  center_id UUID NOT NULL REFERENCES health_centers(id),
  adjustment_type TEXT NOT NULL CHECK (adjustment_type IN (
    'merma', 'correccion', 'devolucion', 'reclasificacion'
  )),
  cantidad_sistema INTEGER NOT NULL,
  cantidad_fisica INTEGER NOT NULL,
  diferencia INTEGER GENERATED ALWAYS AS (cantidad_fisica - cantidad_sistema) STORED,
  motivo TEXT NOT NULL,
  justificacion TEXT NOT NULL,
  evidencia_fotografica TEXT[],
  autorizado_por UUID REFERENCES users_profiles(id),
  autorizado_en TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users_profiles(id)
);

-- Log de auditoría detallado
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users_profiles(id),
  user_email TEXT,
  user_name TEXT,
  user_role TEXT,
  action_type TEXT NOT NULL CHECK (action_type IN (
    'CREATE', 'READ', 'UPDATE', 'DELETE',
    'LOGIN', 'LOGOUT', 'LOGIN_FAILED',
    'EXPORT', 'IMPORT',
    'APPROVE', 'REJECT', 'SIGN',
    'ADJUST', 'TRANSFER', 'REQUISITION'
  )),
  entity_type TEXT NOT NULL CHECK (entity_type IN (
    'medication', 'user', 'center', 'document',
    'transfer', 'supplier', 'catalog',
    'requisition', 'adjustment', 'batch'
  )),
  entity_id UUID,
  entity_name TEXT,
  old_values JSONB,
  new_values JSONB,
  changes_summary TEXT,
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  device_type TEXT,
  browser TEXT,
  result TEXT CHECK (result IN ('success', 'failed', 'partial')),
  error_message TEXT,
  error_code TEXT,
  metadata JSONB,
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  location_lat DECIMAL(10, 8),
  location_lon DECIMAL(11, 8),
  location_city TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

-- Medications
CREATE INDEX idx_medications_center ON medications(center_id);
CREATE INDEX idx_medications_fecha_caducidad ON medications(fecha_caducidad);
CREATE INDEX idx_medications_cantidad ON medications(cantidad);
CREATE INDEX idx_medications_estado ON medications(estado);
CREATE INDEX idx_medications_lote ON medications(lote);

-- Alertas
CREATE INDEX idx_alertas_centro ON alertas_medicamentos(centro_id);
CREATE INDEX idx_alertas_nivel ON alertas_medicamentos(nivel_alerta, resuelta);
CREATE INDEX idx_alertas_medicamento ON alertas_medicamentos(medicamento_id);

-- Transfers
CREATE INDEX idx_transfers_origin ON transfers(origin_center_id);
CREATE INDEX idx_transfers_destination ON transfers(destination_center_id);
CREATE INDEX idx_transfers_status ON transfers(status);
CREATE INDEX idx_transfers_number ON transfers(transfer_number);

-- Requisitions
CREATE INDEX idx_requisitions_center ON requisitions(center_id);
CREATE INDEX idx_requisitions_status ON requisitions(status);
CREATE INDEX idx_requisitions_number ON requisitions(requisition_number);

-- Audit Log
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_action ON audit_log(action_type);
CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_date ON audit_log(created_at DESC);
CREATE INDEX idx_audit_severity ON audit_log(severity);
CREATE INDEX idx_audit_result ON audit_log(result);

-- Catalog (full-text search)
CREATE INDEX idx_catalog_nombre ON medication_catalog USING gin(to_tsvector('spanish', nombre_comercial || ' ' || nombre_generico));
CREATE INDEX idx_catalog_formula ON medication_catalog(formula_activa);

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_health_centers_updated_at BEFORE UPDATE ON health_centers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_profiles_updated_at BEFORE UPDATE ON users_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_medication_catalog_updated_at BEFORE UPDATE ON medication_catalog FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_medications_updated_at BEFORE UPDATE ON medications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transfers_updated_at BEFORE UPDATE ON transfers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_requisitions_updated_at BEFORE UPDATE ON requisitions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para crear perfil automáticamente al registrar usuario
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO users_profiles (id, email, role, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    'inventory_user', -- rol por defecto
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- FUNCIONES DE NEGOCIO
-- ============================================

-- Función para generar alertas automáticas
CREATE OR REPLACE FUNCTION generar_alertas_caducidad()
RETURNS void AS $$
BEGIN
  -- Eliminar alertas antiguas de medicamentos ya caducados o no disponibles
  DELETE FROM alertas_medicamentos
  WHERE medicamento_id IN (
    SELECT id FROM medications
    WHERE fecha_caducidad < CURRENT_DATE OR estado = 'No Disponible'
  );

  -- Insertar nuevas alertas para medicamentos próximos a caducar
  INSERT INTO alertas_medicamentos (medicamento_id, centro_id, nivel_alerta, dias_restantes)
  SELECT
    m.id,
    m.center_id,
    CASE
      WHEN (m.fecha_caducidad - CURRENT_DATE) <= 7 THEN 'critico'
      WHEN (m.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'urgente'
      WHEN (m.fecha_caducidad - CURRENT_DATE) <= 90 THEN 'preventivo'
    END as nivel_alerta,
    (m.fecha_caducidad - CURRENT_DATE) as dias_restantes
  FROM medications m
  WHERE m.fecha_caducidad > CURRENT_DATE
    AND m.fecha_caducidad <= (CURRENT_DATE + INTERVAL '90 days')
    AND m.estado = 'Disponible'
    AND NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos a
      WHERE a.medicamento_id = m.id AND a.resuelta = false
    );
END;
$$ LANGUAGE plpgsql;

-- Función para calcular racha de días sin vencimientos
CREATE OR REPLACE FUNCTION calcular_racha_centro(centro_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
  racha INTEGER := 0;
  fecha_actual DATE := CURRENT_DATE;
BEGIN
  WHILE NOT EXISTS (
    SELECT 1 FROM medications
    WHERE center_id = centro_uuid
    AND fecha_caducidad = fecha_actual
    AND estado = 'No Disponible'
  ) AND racha < 365 LOOP
    racha := racha + 1;
    fecha_actual := fecha_actual - INTERVAL '1 day';
  END LOOP;

  RETURN racha;
END;
$$ LANGUAGE plpgsql;

-- Función para otorgar badges automáticamente
CREATE OR REPLACE FUNCTION otorgar_badges(centro_uuid UUID)
RETURNS TABLE(badge_nombre TEXT, badge_descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT
    'Guardian del Inventario' as badge_nombre,
    'Sin medicamentos vencidos en 30 días' as badge_descripcion
  WHERE calcular_racha_centro(centro_uuid) >= 30
  UNION ALL
  SELECT
    'Maestro de la Prevención',
    'Resolvió 50 alertas preventivas'
  WHERE (SELECT COUNT(*) FROM alertas_medicamentos
         WHERE centro_id = centro_uuid
         AND nivel_alerta = 'preventivo'
         AND resuelta = true) >= 50
  UNION ALL
  SELECT
    'Héroe de Crisis',
    'Resolvió 20 alertas críticas'
  WHERE (SELECT COUNT(*) FROM alertas_medicamentos
         WHERE centro_id = centro_uuid
         AND nivel_alerta = 'critico'
         AND resuelta = true) >= 20;
END;
$$ LANGUAGE plpgsql;

-- Función para revocar sesiones de un usuario
CREATE OR REPLACE FUNCTION revoke_user_sessions(target_user_id UUID)
RETURNS void AS $$
BEGIN
  -- Eliminar tokens de sesión del usuario
  DELETE FROM auth.sessions WHERE user_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VISTAS MATERIALIZADAS
-- ============================================

-- Vista para estadísticas por centro
CREATE MATERIALIZED VIEW estadisticas_centro AS
SELECT
  c.id as centro_id,
  c.name as centro_nombre,
  COUNT(DISTINCT m.id) as total_medicamentos,
  SUM(m.cantidad) as stock_total,
  COUNT(DISTINCT a.id) FILTER (WHERE a.nivel_alerta = 'critico' AND NOT a.resuelta) as alertas_criticas,
  COUNT(DISTINCT a.id) FILTER (WHERE a.nivel_alerta = 'urgente' AND NOT a.resuelta) as alertas_urgentes,
  COUNT(DISTINCT a.id) FILTER (WHERE a.nivel_alerta = 'preventivo' AND NOT a.resuelta) as alertas_preventivas,
  COUNT(DISTINCT a.id) FILTER (WHERE a.resuelta) as alertas_resueltas,
  SUM(CASE
    WHEN a.nivel_alerta = 'critico' THEN 100
    WHEN a.nivel_alerta = 'urgente' THEN 50
    WHEN a.nivel_alerta = 'preventivo' THEN 20
    ELSE 0
  END) as puntos_urgencia_total
FROM health_centers c
LEFT JOIN medications m ON c.id = m.center_id
LEFT JOIN alertas_medicamentos a ON c.id = a.centro_id
GROUP BY c.id, c.name;

-- Índice en la vista materializada
CREATE UNIQUE INDEX idx_estadisticas_centro_id ON estadisticas_centro(centro_id);

-- Refrescar vista (ejecutar periódicamente con cron job)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY estadisticas_centro;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE health_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE alertas_medicamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfer_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE requisitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE requisition_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Policies para users_profiles
CREATE POLICY "Users can view own profile" ON users_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users_profiles FOR UPDATE USING (auth.uid() = id);

-- Policies para medications
CREATE POLICY "Users see medications from their centers" ON medications FOR SELECT TO authenticated USING (
  center_id IN (
    SELECT center_id FROM user_centers WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert medications to their centers" ON medications FOR INSERT TO authenticated WITH CHECK (
  center_id IN (
    SELECT center_id FROM user_centers WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can update medications in their centers" ON medications FOR UPDATE TO authenticated USING (
  center_id IN (
    SELECT center_id FROM user_centers WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Only admins can delete medications" ON medications FOR DELETE TO authenticated USING (
  EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid()
    AND role IN ('super_admin', 'admin_center')
  )
);

-- Policies para alertas
CREATE POLICY "Users see alerts from their centers" ON alertas_medicamentos FOR SELECT TO authenticated USING (
  centro_id IN (
    SELECT center_id FROM user_centers WHERE user_id = auth.uid()
  )
);

-- Policies para transfers
CREATE POLICY "Users see transfers related to their centers" ON transfers FOR SELECT TO authenticated USING (
  origin_center_id IN (SELECT center_id FROM user_centers WHERE user_id = auth.uid())
  OR destination_center_id IN (SELECT center_id FROM user_centers WHERE user_id = auth.uid())
);

-- Policies para audit_log (solo lectura para admins)
CREATE POLICY "Only admins can view audit logs" ON audit_log FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid()
    AND role IN ('super_admin', 'admin_center')
  )
);

-- ============================================
-- DATOS DE PRUEBA (SEED DATA)
-- ============================================

-- Insertar centros de salud de prueba
INSERT INTO health_centers (name, code, address, city, responsible_name) VALUES
('Centro de Salud Norte', 'CSN-001', 'Av. Principal 123', 'La Paz', 'Dr. Juan Pérez'),
('Centro de Salud Sur', 'CSS-002', 'Calle 45 #67', 'La Paz', 'Dra. María González'),
('Hospital Central', 'HC-003', 'Zona Hospitalaria s/n', 'La Paz', 'Dr. Carlos Ruiz');

-- Insertar medicamentos del catálogo
INSERT INTO medication_catalog (nombre_comercial, nombre_generico, formula_activa, forma_farmaceutica, uso_terapeutico) VALUES
('Paracetamol 500mg', 'Paracetamol', 'Paracetamol', 'tableta', 'Analgésico y antipirético'),
('Amoxicilina 500mg', 'Amoxicilina', 'Amoxicilina', 'capsula', 'Antibiótico'),
('Ibuprofeno 400mg', 'Ibuprofeno', 'Ibuprofeno', 'tableta', 'Antiinflamatorio no esteroideo'),
('Omeprazol 20mg', 'Omeprazol', 'Omeprazol', 'capsula', 'Inhibidor de la bomba de protones'),
('Losartán 50mg', 'Losartán', 'Losartán', 'tableta', 'Antihipertensivo'),
('Metformina 850mg', 'Metformina', 'Metformina', 'tableta', 'Antidiabético oral'),
('Diclofenaco 50mg', 'Diclofenaco', 'Diclofenaco', 'tableta', 'Antiinflamatorio'),
('Atorvastatina 20mg', 'Atorvastatina', 'Atorvastatina', 'tableta', 'Hipolipemiante');

-- Los usuarios se crearán desde la interfaz de Supabase Auth
-- Los perfiles se crearán automáticamente con el trigger

COMMENT ON DATABASE postgres IS 'SIGIMED - Sistema de Gestión de Inventario de Medicamentos v2.0';
