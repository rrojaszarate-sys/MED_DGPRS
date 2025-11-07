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

-- Movimientos de lotes (trazabilidad completa)
CREATE TABLE batch_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_id UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN (
    'entrada', 'salida', 'ajuste', 'vencimiento', 'merma',
    'transferencia_salida', 'transferencia_entrada', 'devolucion', 'destruccion'
  )),
  cantidad INTEGER NOT NULL,
  cantidad_anterior INTEGER NOT NULL,
  cantidad_posterior INTEGER NOT NULL,
  centro_origen_id UUID REFERENCES health_centers(id),
  centro_destino_id UUID REFERENCES health_centers(id),
  transfer_id UUID REFERENCES transfers(id),
  requisition_id UUID REFERENCES requisitions(id),
  adjustment_id UUID REFERENCES inventory_adjustments(id),
  numero_documento TEXT,
  motivo TEXT NOT NULL,
  observaciones TEXT,
  usuario_responsable UUID NOT NULL REFERENCES users_profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
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

-- Batch Movements
CREATE INDEX idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX idx_batch_movements_usuario ON batch_movements(usuario_responsable);
CREATE INDEX idx_batch_movements_created ON batch_movements(created_at DESC);
CREATE INDEX idx_batch_movements_centro_origen ON batch_movements(centro_origen_id);
CREATE INDEX idx_batch_movements_centro_destino ON batch_movements(centro_destino_id);

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

-- Función genérica para auditar operaciones CRUD
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT;
  v_user_name TEXT;
  v_action_type TEXT;
  v_old_values JSONB;
  v_new_values JSONB;
BEGIN
  -- Obtener usuario actual (de Supabase Auth)
  v_user_id := auth.uid();

  IF v_user_id IS NOT NULL THEN
    SELECT email, full_name INTO v_user_email, v_user_name
    FROM users_profiles WHERE id = v_user_id;
  END IF;

  -- Determinar tipo de acción
  IF TG_OP = 'INSERT' THEN
    v_action_type := 'CREATE';
    v_new_values := to_jsonb(NEW);
    v_old_values := NULL;
  ELSIF TG_OP = 'UPDATE' THEN
    v_action_type := 'UPDATE';
    v_old_values := to_jsonb(OLD);
    v_new_values := to_jsonb(NEW);
  ELSIF TG_OP = 'DELETE' THEN
    v_action_type := 'DELETE';
    v_old_values := to_jsonb(OLD);
    v_new_values := NULL;
  END IF;

  -- Insertar en audit_log
  INSERT INTO audit_log (
    user_id,
    user_email,
    user_name,
    action_type,
    entity_type,
    entity_id,
    entity_name,
    old_values,
    new_values,
    result,
    severity
  ) VALUES (
    v_user_id,
    v_user_email,
    v_user_name,
    v_action_type,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    CASE TG_TABLE_NAME
      WHEN 'medications' THEN COALESCE(NEW.nombre, OLD.nombre)
      WHEN 'users_profiles' THEN COALESCE(NEW.full_name, OLD.full_name)
      WHEN 'health_centers' THEN COALESCE(NEW.name, OLD.name)
      WHEN 'medication_catalog' THEN COALESCE(NEW.nombre_comercial, OLD.nombre_comercial)
      ELSE 'N/A'
    END,
    v_old_values,
    v_new_values,
    'success',
    CASE
      WHEN TG_OP = 'DELETE' THEN 'high'
      WHEN TG_OP = 'UPDATE' THEN 'medium'
      ELSE 'low'
    END
  );

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar triggers de auditoría a tablas principales
CREATE TRIGGER audit_medications
  AFTER INSERT OR UPDATE OR DELETE ON medications
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_users_profiles
  AFTER INSERT OR UPDATE OR DELETE ON users_profiles
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_health_centers
  AFTER INSERT OR UPDATE OR DELETE ON health_centers
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_medication_catalog
  AFTER INSERT OR UPDATE OR DELETE ON medication_catalog
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_transfers
  AFTER INSERT OR UPDATE OR DELETE ON transfers
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

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

-- Función para registrar movimientos de lotes con trazabilidad completa
CREATE OR REPLACE FUNCTION registrar_movimiento_lote(
  p_medication_id UUID,
  p_tipo_movimiento TEXT,
  p_cantidad INTEGER,
  p_motivo TEXT,
  p_usuario_responsable UUID,
  p_centro_origen_id UUID DEFAULT NULL,
  p_centro_destino_id UUID DEFAULT NULL,
  p_transfer_id UUID DEFAULT NULL,
  p_requisition_id UUID DEFAULT NULL,
  p_adjustment_id UUID DEFAULT NULL,
  p_numero_documento TEXT DEFAULT NULL,
  p_observaciones TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
) RETURNS JSONB AS $$
DECLARE
  v_cantidad_anterior INTEGER;
  v_cantidad_posterior INTEGER;
  v_medication RECORD;
  v_movement_id UUID;
  v_user_email TEXT;
  v_user_name TEXT;
  v_resultado JSONB;
BEGIN
  -- Obtener información del medicamento
  SELECT * INTO v_medication FROM medications WHERE id = p_medication_id FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Medicamento no encontrado: %', p_medication_id;
  END IF;

  -- Obtener información del usuario
  SELECT email, full_name INTO v_user_email, v_user_name
  FROM users_profiles WHERE id = p_usuario_responsable;

  -- Guardar cantidad anterior
  v_cantidad_anterior := v_medication.cantidad;

  -- Validar stock suficiente para salidas, mermas, etc.
  IF p_tipo_movimiento IN ('salida', 'merma', 'transferencia_salida', 'destruccion') THEN
    IF v_cantidad_anterior < p_cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente. Disponible: %, Solicitado: %', v_cantidad_anterior, p_cantidad;
    END IF;
    v_cantidad_posterior := v_cantidad_anterior - p_cantidad;
  ELSIF p_tipo_movimiento IN ('entrada', 'transferencia_entrada', 'devolucion') THEN
    v_cantidad_posterior := v_cantidad_anterior + p_cantidad;
  ELSIF p_tipo_movimiento = 'ajuste' THEN
    v_cantidad_posterior := v_cantidad_anterior + p_cantidad; -- p_cantidad puede ser negativo
  ELSIF p_tipo_movimiento = 'vencimiento' THEN
    v_cantidad_posterior := 0;
  ELSE
    RAISE EXCEPTION 'Tipo de movimiento no válido: %', p_tipo_movimiento;
  END IF;

  -- Validar que la cantidad posterior no sea negativa
  IF v_cantidad_posterior < 0 THEN
    RAISE EXCEPTION 'La cantidad resultante no puede ser negativa';
  END IF;

  -- Actualizar cantidad en medications
  UPDATE medications
  SET cantidad = v_cantidad_posterior,
      updated_at = NOW()
  WHERE id = p_medication_id;

  -- Si la cantidad llegó a 0 por vencimiento, cambiar estado
  IF p_tipo_movimiento = 'vencimiento' AND v_cantidad_posterior = 0 THEN
    UPDATE medications
    SET estado = 'No Disponible'
    WHERE id = p_medication_id;
  END IF;

  -- Insertar movimiento en batch_movements
  INSERT INTO batch_movements (
    medication_id,
    tipo_movimiento,
    cantidad,
    cantidad_anterior,
    cantidad_posterior,
    centro_origen_id,
    centro_destino_id,
    transfer_id,
    requisition_id,
    adjustment_id,
    numero_documento,
    motivo,
    observaciones,
    usuario_responsable,
    metadata
  ) VALUES (
    p_medication_id,
    p_tipo_movimiento,
    p_cantidad,
    v_cantidad_anterior,
    v_cantidad_posterior,
    p_centro_origen_id,
    p_centro_destino_id,
    p_transfer_id,
    p_requisition_id,
    p_adjustment_id,
    p_numero_documento,
    p_motivo,
    p_observaciones,
    p_usuario_responsable,
    p_metadata
  ) RETURNING id INTO v_movement_id;

  -- Registrar en audit_log
  INSERT INTO audit_log (
    user_id,
    user_email,
    user_name,
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
    p_usuario_responsable,
    v_user_email,
    v_user_name,
    CASE
      WHEN p_tipo_movimiento IN ('entrada', 'transferencia_entrada', 'devolucion') THEN 'CREATE'
      WHEN p_tipo_movimiento IN ('salida', 'transferencia_salida') THEN 'TRANSFER'
      WHEN p_tipo_movimiento IN ('ajuste', 'merma', 'destruccion', 'vencimiento') THEN 'ADJUST'
      ELSE 'UPDATE'
    END,
    'batch',
    v_movement_id,
    v_medication.nombre || ' - Lote: ' || v_medication.lote,
    jsonb_build_object(
      'cantidad', v_cantidad_anterior,
      'estado', v_medication.estado
    ),
    jsonb_build_object(
      'cantidad', v_cantidad_posterior,
      'tipo_movimiento', p_tipo_movimiento
    ),
    format('Movimiento de %s: %s unidades. Motivo: %s', p_tipo_movimiento, p_cantidad, p_motivo),
    'success',
    CASE
      WHEN p_tipo_movimiento IN ('vencimiento', 'destruccion') THEN 'high'
      WHEN p_tipo_movimiento IN ('merma') THEN 'medium'
      ELSE 'low'
    END,
    jsonb_build_object(
      'movement_id', v_movement_id,
      'medication_id', p_medication_id,
      'tipo_movimiento', p_tipo_movimiento
    )
  );

  -- Retornar resultado
  v_resultado := jsonb_build_object(
    'success', true,
    'movement_id', v_movement_id,
    'cantidad_anterior', v_cantidad_anterior,
    'cantidad_posterior', v_cantidad_posterior,
    'message', format('Movimiento registrado exitosamente: %s', p_tipo_movimiento)
  );

  RETURN v_resultado;

EXCEPTION
  WHEN OTHERS THEN
    -- Registrar error en audit_log
    INSERT INTO audit_log (
      user_id,
      user_email,
      user_name,
      action_type,
      entity_type,
      entity_id,
      entity_name,
      result,
      error_message,
      severity,
      metadata
    ) VALUES (
      p_usuario_responsable,
      v_user_email,
      v_user_name,
      'ADJUST',
      'batch',
      p_medication_id,
      COALESCE(v_medication.nombre, 'Desconocido'),
      'failed',
      SQLERRM,
      'critical',
      jsonb_build_object(
        'tipo_movimiento', p_tipo_movimiento,
        'cantidad', p_cantidad,
        'error', SQLERRM
      )
    );

    -- Retornar error
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM,
      'message', 'Error al registrar movimiento'
    );
END;
$$ LANGUAGE plpgsql;

-- Función para generar reporte de trazabilidad con filtros múltiples
CREATE OR REPLACE FUNCTION generate_traceability_report(
  p_medication_id UUID DEFAULT NULL,
  p_lote TEXT DEFAULT NULL,
  p_center_id UUID DEFAULT NULL,
  p_fecha_inicio DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT NULL,
  p_estado TEXT DEFAULT NULL,
  p_include_history BOOLEAN DEFAULT true
) RETURNS TABLE (
  medication_id UUID,
  medication_nombre TEXT,
  medication_lote TEXT,
  medication_cantidad INTEGER,
  medication_fecha_caducidad DATE,
  medication_estado TEXT,
  medication_ubicacion TEXT,
  center_id UUID,
  center_name TEXT,
  ultimo_movimiento_tipo TEXT,
  ultimo_movimiento_fecha TIMESTAMP WITH TIME ZONE,
  ultimo_movimiento_usuario TEXT,
  total_movimientos BIGINT,
  historial_movimientos JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id AS medication_id,
    m.nombre AS medication_nombre,
    m.lote AS medication_lote,
    m.cantidad AS medication_cantidad,
    m.fecha_caducidad AS medication_fecha_caducidad,
    m.estado AS medication_estado,
    m.ubicacion_fisica AS medication_ubicacion,
    m.center_id,
    hc.name AS center_name,
    bm_last.tipo_movimiento AS ultimo_movimiento_tipo,
    bm_last.created_at AS ultimo_movimiento_fecha,
    up_last.full_name AS ultimo_movimiento_usuario,
    (SELECT COUNT(*) FROM batch_movements WHERE medication_id = m.id) AS total_movimientos,
    CASE
      WHEN p_include_history THEN
        (
          SELECT jsonb_agg(
            jsonb_build_object(
              'id', bm.id,
              'tipo', bm.tipo_movimiento,
              'cantidad', bm.cantidad,
              'cantidad_anterior', bm.cantidad_anterior,
              'cantidad_posterior', bm.cantidad_posterior,
              'motivo', bm.motivo,
              'usuario', up.full_name,
              'fecha', bm.created_at
            ) ORDER BY bm.created_at DESC
          )
          FROM batch_movements bm
          LEFT JOIN users_profiles up ON bm.usuario_responsable = up.id
          WHERE bm.medication_id = m.id
        )
      ELSE NULL
    END AS historial_movimientos
  FROM medications m
  LEFT JOIN health_centers hc ON m.center_id = hc.id
  LEFT JOIN LATERAL (
    SELECT * FROM batch_movements
    WHERE medication_id = m.id
    ORDER BY created_at DESC
    LIMIT 1
  ) bm_last ON true
  LEFT JOIN users_profiles up_last ON bm_last.usuario_responsable = up_last.id
  WHERE
    (p_medication_id IS NULL OR m.id = p_medication_id)
    AND (p_lote IS NULL OR m.lote ILIKE '%' || p_lote || '%')
    AND (p_center_id IS NULL OR m.center_id = p_center_id)
    AND (p_fecha_inicio IS NULL OR m.fecha_caducidad >= p_fecha_inicio)
    AND (p_fecha_fin IS NULL OR m.fecha_caducidad <= p_fecha_fin)
    AND (p_estado IS NULL OR m.estado = p_estado)
  ORDER BY m.fecha_caducidad ASC, m.nombre ASC;
END;
$$ LANGUAGE plpgsql;

-- Función para búsqueda avanzada de inventario con filtros
CREATE OR REPLACE FUNCTION search_inventory_with_batches(
  p_search_term TEXT DEFAULT NULL,
  p_center_id UUID DEFAULT NULL,
  p_stock_bajo INTEGER DEFAULT NULL,
  p_vencidos BOOLEAN DEFAULT false,
  p_proximos_vencer_dias INTEGER DEFAULT NULL,
  p_estado TEXT DEFAULT NULL
) RETURNS TABLE (
  id UUID,
  center_id UUID,
  center_name TEXT,
  catalog_id UUID,
  nombre TEXT,
  formula_activa TEXT,
  lote TEXT,
  cantidad INTEGER,
  fecha_caducidad DATE,
  fecha_ingreso DATE,
  estado TEXT,
  ubicacion_fisica TEXT,
  dias_para_vencer INTEGER,
  stock_alert BOOLEAN,
  expired_alert BOOLEAN,
  expiring_soon_alert BOOLEAN,
  total_movements BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id,
    m.center_id,
    hc.name AS center_name,
    m.catalog_id,
    m.nombre,
    m.formula_activa,
    m.lote,
    m.cantidad,
    m.fecha_caducidad,
    m.fecha_ingreso,
    m.estado,
    m.ubicacion_fisica,
    (m.fecha_caducidad - CURRENT_DATE) AS dias_para_vencer,
    (p_stock_bajo IS NOT NULL AND m.cantidad <= p_stock_bajo) AS stock_alert,
    (m.fecha_caducidad < CURRENT_DATE) AS expired_alert,
    (p_proximos_vencer_dias IS NOT NULL AND
     m.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + (p_proximos_vencer_dias || ' days')::INTERVAL
    ) AS expiring_soon_alert,
    (SELECT COUNT(*) FROM batch_movements WHERE medication_id = m.id) AS total_movements
  FROM medications m
  LEFT JOIN health_centers hc ON m.center_id = hc.id
  WHERE
    (p_search_term IS NULL OR
     m.nombre ILIKE '%' || p_search_term || '%' OR
     m.formula_activa ILIKE '%' || p_search_term || '%' OR
     m.lote ILIKE '%' || p_search_term || '%')
    AND (p_center_id IS NULL OR m.center_id = p_center_id)
    AND (p_stock_bajo IS NULL OR m.cantidad <= p_stock_bajo)
    AND (p_vencidos = false OR m.fecha_caducidad < CURRENT_DATE)
    AND (p_proximos_vencer_dias IS NULL OR
         m.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + (p_proximos_vencer_dias || ' days')::INTERVAL)
    AND (p_estado IS NULL OR m.estado = p_estado)
  ORDER BY
    CASE WHEN m.fecha_caducidad < CURRENT_DATE THEN 0 ELSE 1 END,
    m.fecha_caducidad ASC,
    m.nombre ASC;
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
