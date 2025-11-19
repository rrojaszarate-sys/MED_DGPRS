-- ============================================
-- MIGRACIÓN 09: CATÁLOGOS ADMINISTRABLES
-- Sistema: SIGIMED v2.0
-- Propósito: Crear catálogos dinámicos administrables desde UI
-- Fecha: 2025-11-19
-- ============================================

-- ============================================
-- 1. CATÁLOGO DE COLORES
-- ============================================
-- Tabla para gestionar paletas de colores del sistema
CREATE TABLE IF NOT EXISTS catalogo_colores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL UNIQUE, -- Ej: "Primario", "Secundario", "Éxito", "Peligro"
  codigo_hex TEXT NOT NULL, -- Código hexadecimal: #FF5733
  codigo_rgb TEXT, -- Código RGB: rgb(255, 87, 51)
  codigo_hsl TEXT, -- Código HSL: hsl(9, 100%, 60%)
  uso TEXT, -- Descripción del uso: "Botones principales", "Alertas de error"
  categoria TEXT NOT NULL DEFAULT 'general', -- 'principal', 'estados', 'graficos', 'alertas', 'general'
  orden INTEGER DEFAULT 0, -- Orden de visualización
  es_activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id)
);

-- Índices
CREATE INDEX idx_catalogo_colores_categoria ON catalogo_colores(categoria);
CREATE INDEX idx_catalogo_colores_activo ON catalogo_colores(es_activo);

-- Comentarios
COMMENT ON TABLE catalogo_colores IS 'Catálogo de colores del sistema - Administrable desde UI';
COMMENT ON COLUMN catalogo_colores.nombre IS 'Nombre descriptivo del color';
COMMENT ON COLUMN catalogo_colores.categoria IS 'Categoría del color: principal, estados, graficos, alertas, general';

-- ============================================
-- 2. CATÁLOGO DE ESTADOS
-- ============================================
-- Tabla para gestionar todos los estados del sistema
CREATE TABLE IF NOT EXISTS catalogo_estados (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  codigo TEXT NOT NULL, -- Código único: 'disponible', 'pendiente', 'aprobado'
  nombre TEXT NOT NULL, -- Nombre legible: "Disponible", "Pendiente de Aprobación"
  descripcion TEXT, -- Descripción del estado
  modulo TEXT NOT NULL, -- A qué módulo pertenece: 'medicamentos', 'requisiciones', 'transferencias'
  color_id UUID REFERENCES catalogo_colores(id), -- Color asociado al estado
  icono TEXT, -- Nombre del ícono (ej: 'CheckCircle', 'Clock', 'XCircle')
  orden INTEGER DEFAULT 0, -- Orden de visualización
  es_estado_inicial BOOLEAN DEFAULT false, -- ¿Es el estado inicial del flujo?
  es_estado_final BOOLEAN DEFAULT false, -- ¿Es un estado final/terminal?
  permite_edicion BOOLEAN DEFAULT true, -- ¿Se puede editar en este estado?
  es_activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id),
  UNIQUE(codigo, modulo)
);

-- Índices
CREATE INDEX idx_catalogo_estados_modulo ON catalogo_estados(modulo);
CREATE INDEX idx_catalogo_estados_codigo ON catalogo_estados(codigo);
CREATE INDEX idx_catalogo_estados_activo ON catalogo_estados(es_activo);

-- Comentarios
COMMENT ON TABLE catalogo_estados IS 'Catálogo de estados del sistema por módulo - Administrable desde UI';
COMMENT ON COLUMN catalogo_estados.modulo IS 'Módulo al que pertenece: medicamentos, requisiciones, transferencias, etc.';

-- ============================================
-- 3. CATÁLOGO DE TIPOS DE MOVIMIENTO
-- ============================================
-- Tabla para gestionar tipos de movimientos de inventario
CREATE TABLE IF NOT EXISTS catalogo_tipos_movimiento (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  codigo TEXT NOT NULL UNIQUE, -- Código único: 'entrada', 'salida', 'ajuste'
  nombre TEXT NOT NULL, -- Nombre legible: "Entrada de Compra", "Salida por Dispensación"
  descripcion TEXT, -- Descripción del tipo de movimiento
  categoria TEXT NOT NULL, -- 'entrada', 'salida', 'ajuste', 'transferencia'
  afecta_stock TEXT NOT NULL CHECK (afecta_stock IN ('incrementa', 'decrementa', 'neutro')),
  requiere_aprobacion BOOLEAN DEFAULT false,
  requiere_documento BOOLEAN DEFAULT false, -- ¿Requiere número de documento?
  requiere_justificacion BOOLEAN DEFAULT false,
  color_id UUID REFERENCES catalogo_colores(id),
  icono TEXT,
  orden INTEGER DEFAULT 0,
  es_activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id)
);

-- Índices
CREATE INDEX idx_catalogo_tipos_movimiento_categoria ON catalogo_tipos_movimiento(categoria);
CREATE INDEX idx_catalogo_tipos_movimiento_codigo ON catalogo_tipos_movimiento(codigo);
CREATE INDEX idx_catalogo_tipos_movimiento_activo ON catalogo_tipos_movimiento(es_activo);

-- Comentarios
COMMENT ON TABLE catalogo_tipos_movimiento IS 'Catálogo de tipos de movimientos de inventario - Administrable desde UI';
COMMENT ON COLUMN catalogo_tipos_movimiento.afecta_stock IS 'Cómo afecta el stock: incrementa, decrementa, neutro';

-- ============================================
-- 4. CATÁLOGO DE FORMAS FARMACÉUTICAS
-- ============================================
-- Tabla para gestionar formas farmacéuticas de medicamentos
CREATE TABLE IF NOT EXISTS catalogo_formas_farmaceuticas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  codigo TEXT NOT NULL UNIQUE, -- Código único: 'tableta', 'capsula', 'jarabe'
  nombre TEXT NOT NULL, -- Nombre legible: "Tableta", "Cápsula", "Jarabe"
  descripcion TEXT, -- Descripción de la forma farmacéutica
  via_administracion TEXT, -- Oral, Parenteral, Tópica, etc.
  requiere_refrigeracion BOOLEAN DEFAULT false,
  unidad_medida TEXT, -- 'unidad', 'ml', 'mg', 'g'
  icono TEXT,
  orden INTEGER DEFAULT 0,
  es_activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id)
);

-- Índices
CREATE INDEX idx_catalogo_formas_farmaceuticas_codigo ON catalogo_formas_farmaceuticas(codigo);
CREATE INDEX idx_catalogo_formas_farmaceuticas_activo ON catalogo_formas_farmaceuticas(es_activo);

-- Comentarios
COMMENT ON TABLE catalogo_formas_farmaceuticas IS 'Catálogo de formas farmacéuticas - Administrable desde UI';
COMMENT ON COLUMN catalogo_formas_farmaceuticas.via_administracion IS 'Vía de administración del medicamento';

-- ============================================
-- 5. CATÁLOGO DE PRIORIDADES
-- ============================================
-- Tabla para gestionar niveles de prioridad
CREATE TABLE IF NOT EXISTS catalogo_prioridades (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  codigo TEXT NOT NULL, -- Código único: 'baja', 'normal', 'alta', 'urgente', 'emergencia'
  nombre TEXT NOT NULL, -- Nombre legible: "Baja", "Normal", "Alta"
  descripcion TEXT, -- Descripción de la prioridad
  modulo TEXT NOT NULL, -- A qué módulo pertenece: 'requisiciones', 'transferencias', 'general'
  nivel INTEGER NOT NULL, -- Nivel numérico (1=baja, 5=emergencia)
  color_id UUID REFERENCES catalogo_colores(id),
  icono TEXT,
  tiempo_respuesta_horas INTEGER, -- Tiempo esperado de respuesta en horas
  requiere_notificacion BOOLEAN DEFAULT false,
  orden INTEGER DEFAULT 0,
  es_activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id),
  UNIQUE(codigo, modulo)
);

-- Índices
CREATE INDEX idx_catalogo_prioridades_modulo ON catalogo_prioridades(modulo);
CREATE INDEX idx_catalogo_prioridades_nivel ON catalogo_prioridades(nivel);
CREATE INDEX idx_catalogo_prioridades_activo ON catalogo_prioridades(es_activo);

-- Comentarios
COMMENT ON TABLE catalogo_prioridades IS 'Catálogo de niveles de prioridad - Administrable desde UI';
COMMENT ON COLUMN catalogo_prioridades.nivel IS 'Nivel numérico de prioridad (1=baja, 5=emergencia)';

-- ============================================
-- 6. CATÁLOGO DE CONFIGURACIONES
-- ============================================
-- Tabla para configuraciones generales del sistema
CREATE TABLE IF NOT EXISTS catalogo_configuraciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE, -- Clave única: 'dias_alerta_critica', 'email_notificaciones'
  valor TEXT NOT NULL, -- Valor de la configuración (puede ser JSON)
  tipo_dato TEXT NOT NULL CHECK (tipo_dato IN ('texto', 'numero', 'booleano', 'json', 'fecha')),
  nombre TEXT NOT NULL, -- Nombre legible
  descripcion TEXT, -- Descripción de la configuración
  categoria TEXT NOT NULL, -- 'sistema', 'alertas', 'notificaciones', 'seguridad', 'general'
  valor_por_defecto TEXT, -- Valor por defecto
  es_requerido BOOLEAN DEFAULT false,
  es_sensible BOOLEAN DEFAULT false, -- ¿Es información sensible? (passwords, API keys)
  orden INTEGER DEFAULT 0,
  es_activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id)
);

-- Índices
CREATE INDEX idx_catalogo_configuraciones_clave ON catalogo_configuraciones(clave);
CREATE INDEX idx_catalogo_configuraciones_categoria ON catalogo_configuraciones(categoria);
CREATE INDEX idx_catalogo_configuraciones_activo ON catalogo_configuraciones(es_activo);

-- Comentarios
COMMENT ON TABLE catalogo_configuraciones IS 'Catálogo de configuraciones generales del sistema - Administrable desde UI';
COMMENT ON COLUMN catalogo_configuraciones.es_sensible IS 'Indica si es información sensible que debe ocultarse en UI';

-- ============================================
-- 7. TRIGGERS PARA UPDATED_AT
-- ============================================

-- Función genérica para actualizar updated_at
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para cada tabla de catálogo
CREATE TRIGGER trigger_actualizar_catalogo_colores_updated_at
  BEFORE UPDATE ON catalogo_colores
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_actualizar_catalogo_estados_updated_at
  BEFORE UPDATE ON catalogo_estados
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_actualizar_catalogo_tipos_movimiento_updated_at
  BEFORE UPDATE ON catalogo_tipos_movimiento
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_actualizar_catalogo_formas_farmaceuticas_updated_at
  BEFORE UPDATE ON catalogo_formas_farmaceuticas
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_actualizar_catalogo_prioridades_updated_at
  BEFORE UPDATE ON catalogo_prioridades
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_actualizar_catalogo_configuraciones_updated_at
  BEFORE UPDATE ON catalogo_configuraciones
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

-- ============================================
-- 8. DATOS INICIALES - COLORES
-- ============================================
INSERT INTO catalogo_colores (nombre, codigo_hex, codigo_rgb, categoria, uso, orden) VALUES
  -- Colores principales
  ('Primario', '#3B82F6', 'rgb(59, 130, 246)', 'principal', 'Color principal del sistema, botones primarios', 1),
  ('Secundario', '#6B7280', 'rgb(107, 114, 128)', 'principal', 'Color secundario, elementos de soporte', 2),
  ('Acento', '#8B5CF6', 'rgb(139, 92, 246)', 'principal', 'Color de acento para destacar', 3),

  -- Estados
  ('Éxito', '#10B981', 'rgb(16, 185, 129)', 'estados', 'Operaciones exitosas, estados completados', 10),
  ('Advertencia', '#F59E0B', 'rgb(245, 158, 11)', 'estados', 'Advertencias, alertas importantes', 11),
  ('Peligro', '#EF4444', 'rgb(239, 68, 68)', 'estados', 'Errores, estados críticos', 12),
  ('Información', '#3B82F6', 'rgb(59, 130, 246)', 'estados', 'Mensajes informativos', 13),

  -- Alertas específicas
  ('Alerta Crítica', '#DC2626', 'rgb(220, 38, 38)', 'alertas', 'Alertas críticas (≤7 días)', 20),
  ('Alerta Urgente', '#F59E0B', 'rgb(245, 158, 11)', 'alertas', 'Alertas urgentes (≤30 días)', 21),
  ('Alerta Preventiva', '#3B82F6', 'rgb(59, 130, 246)', 'alertas', 'Alertas preventivas (≤90 días)', 22),

  -- Gráficos
  ('Gráfico 1', '#3B82F6', 'rgb(59, 130, 246)', 'graficos', 'Primera serie en gráficos', 30),
  ('Gráfico 2', '#10B981', 'rgb(16, 185, 129)', 'graficos', 'Segunda serie en gráficos', 31),
  ('Gráfico 3', '#F59E0B', 'rgb(245, 158, 11)', 'graficos', 'Tercera serie en gráficos', 32),
  ('Gráfico 4', '#8B5CF6', 'rgb(139, 92, 246)', 'graficos', 'Cuarta serie en gráficos', 33),
  ('Gráfico 5', '#EC4899', 'rgb(236, 72, 153)', 'graficos', 'Quinta serie en gráficos', 34)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- 9. DATOS INICIALES - ESTADOS
-- ============================================

-- Estados para Medicamentos
INSERT INTO catalogo_estados (codigo, nombre, descripcion, modulo, orden, es_estado_inicial, permite_edicion) VALUES
  ('disponible', 'Disponible', 'Medicamento disponible para uso', 'medicamentos', 1, true, true),
  ('no_disponible', 'No Disponible', 'Medicamento no disponible temporalmente', 'medicamentos', 2, false, true),
  ('cuarentena', 'En Cuarentena', 'Medicamento en cuarentena por verificación', 'medicamentos', 3, false, false),
  ('vencido', 'Vencido', 'Medicamento vencido', 'medicamentos', 4, false, false),
  ('agotado', 'Agotado', 'Medicamento sin stock', 'medicamentos', 5, false, false)
ON CONFLICT (codigo, modulo) DO NOTHING;

-- Estados para Requisiciones
INSERT INTO catalogo_estados (codigo, nombre, descripcion, modulo, orden, es_estado_inicial, es_estado_final, permite_edicion) VALUES
  ('borrador', 'Borrador', 'Requisición en borrador', 'requisiciones', 1, true, false, true),
  ('solicitada', 'Solicitada', 'Requisición enviada para aprobación', 'requisiciones', 2, false, false, false),
  ('aprobada', 'Aprobada', 'Requisición aprobada', 'requisiciones', 3, false, false, false),
  ('rechazada', 'Rechazada', 'Requisición rechazada', 'requisiciones', 4, false, true, false),
  ('surtida', 'Surtida', 'Requisición surtida', 'requisiciones', 5, false, false, false),
  ('completada', 'Completada', 'Requisición completada', 'requisiciones', 6, false, true, false),
  ('cancelada', 'Cancelada', 'Requisición cancelada', 'requisiciones', 7, false, true, false)
ON CONFLICT (codigo, modulo) DO NOTHING;

-- Estados para Transferencias
INSERT INTO catalogo_estados (codigo, nombre, descripcion, modulo, orden, es_estado_inicial, es_estado_final, permite_edicion) VALUES
  ('pending', 'Pendiente', 'Transferencia pendiente de aprobación', 'transferencias', 1, true, false, true),
  ('approved', 'Aprobada', 'Transferencia aprobada', 'transferencias', 2, false, false, false),
  ('rejected', 'Rechazada', 'Transferencia rechazada', 'transferencias', 3, false, true, false),
  ('in_transit', 'En Tránsito', 'Transferencia en tránsito', 'transferencias', 4, false, false, false),
  ('received', 'Recibida', 'Transferencia recibida', 'transferencias', 5, false, false, false),
  ('completed', 'Completada', 'Transferencia completada', 'transferencias', 6, false, true, false),
  ('cancelled', 'Cancelada', 'Transferencia cancelada', 'transferencias', 7, false, true, false)
ON CONFLICT (codigo, modulo) DO NOTHING;

-- ============================================
-- 10. DATOS INICIALES - TIPOS DE MOVIMIENTO
-- ============================================
INSERT INTO catalogo_tipos_movimiento (codigo, nombre, descripcion, categoria, afecta_stock, requiere_documento, requiere_justificacion, orden) VALUES
  ('entrada_compra', 'Entrada por Compra', 'Entrada de medicamento por compra a proveedor', 'entrada', 'incrementa', true, false, 1),
  ('entrada_donacion', 'Entrada por Donación', 'Entrada de medicamento por donación', 'entrada', 'incrementa', true, false, 2),
  ('entrada_transferencia', 'Entrada por Transferencia', 'Entrada de medicamento por transferencia de otro centro', 'entrada', 'incrementa', true, false, 3),
  ('entrada_ajuste', 'Entrada por Ajuste', 'Entrada de medicamento por ajuste de inventario', 'entrada', 'incrementa', false, true, 4),

  ('salida_dispensacion', 'Salida por Dispensación', 'Salida de medicamento por dispensación a paciente', 'salida', 'decrementa', false, false, 10),
  ('salida_transferencia', 'Salida por Transferencia', 'Salida de medicamento por transferencia a otro centro', 'salida', 'decrementa', true, false, 11),
  ('salida_vencimiento', 'Salida por Vencimiento', 'Salida de medicamento por vencimiento', 'salida', 'decrementa', false, true, 12),
  ('salida_merma', 'Salida por Merma', 'Salida de medicamento por merma o daño', 'salida', 'decrementa', false, true, 13),
  ('salida_devolucion', 'Salida por Devolución', 'Salida de medicamento por devolución a proveedor', 'salida', 'decrementa', true, true, 14),
  ('salida_destruccion', 'Salida por Destrucción', 'Salida de medicamento por destrucción autorizada', 'salida', 'decrementa', true, true, 15),

  ('ajuste_correccion', 'Ajuste por Corrección', 'Ajuste de inventario por corrección de conteo', 'ajuste', 'neutro', false, true, 20),
  ('ajuste_reclasificacion', 'Ajuste por Reclasificación', 'Ajuste por reclasificación de lote', 'ajuste', 'neutro', false, true, 21)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- 11. DATOS INICIALES - FORMAS FARMACÉUTICAS
-- ============================================
INSERT INTO catalogo_formas_farmaceuticas (codigo, nombre, descripcion, via_administracion, unidad_medida, orden) VALUES
  ('tableta', 'Tableta', 'Forma farmacéutica sólida oral', 'Oral', 'unidad', 1),
  ('capsula', 'Cápsula', 'Forma farmacéutica con cubierta de gelatina', 'Oral', 'unidad', 2),
  ('jarabe', 'Jarabe', 'Solución líquida dulce', 'Oral', 'ml', 3),
  ('suspension', 'Suspensión', 'Preparación líquida con partículas en suspensión', 'Oral', 'ml', 4),
  ('inyectable', 'Inyectable', 'Preparación para administración parenteral', 'Parenteral', 'ml', 5),
  ('crema', 'Crema', 'Preparación semisólida para uso tópico', 'Tópica', 'g', 6),
  ('unguento', 'Ungüento', 'Preparación grasa para uso tópico', 'Tópica', 'g', 7),
  ('supositorio', 'Supositorio', 'Forma farmacéutica para uso rectal o vaginal', 'Rectal/Vaginal', 'unidad', 8),
  ('gotas', 'Gotas', 'Solución líquida en gotas', 'Oral/Oftálmica/Ótica', 'ml', 9),
  ('aerosol', 'Aerosol', 'Preparación en spray', 'Inhalatoria/Tópica', 'ml', 10),
  ('solucion', 'Solución', 'Preparación líquida homogénea', 'Oral/Tópica', 'ml', 11),
  ('polvo', 'Polvo', 'Forma farmacéutica en polvo', 'Oral', 'g', 12),
  ('gel', 'Gel', 'Preparación semisólida transparente', 'Tópica', 'g', 13),
  ('parche', 'Parche', 'Sistema de liberación transdérmica', 'Transdérmica', 'unidad', 14),
  ('ovulo', 'Óvulo', 'Forma farmacéutica vaginal', 'Vaginal', 'unidad', 15)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- 12. DATOS INICIALES - PRIORIDADES
-- ============================================

-- Prioridades para Requisiciones
INSERT INTO catalogo_prioridades (codigo, nombre, descripcion, modulo, nivel, tiempo_respuesta_horas, requiere_notificacion, orden) VALUES
  ('normal', 'Normal', 'Prioridad normal de requisición', 'requisiciones', 1, 72, false, 1),
  ('urgente', 'Urgente', 'Requisición urgente que requiere atención prioritaria', 'requisiciones', 2, 24, true, 2),
  ('emergencia', 'Emergencia', 'Requisición de emergencia inmediata', 'requisiciones', 3, 4, true, 3)
ON CONFLICT (codigo, modulo) DO NOTHING;

-- Prioridades para Transferencias
INSERT INTO catalogo_prioridades (codigo, nombre, descripcion, modulo, nivel, tiempo_respuesta_horas, requiere_notificacion, orden) VALUES
  ('baja', 'Baja', 'Transferencia de baja prioridad', 'transferencias', 1, 168, false, 1),
  ('normal', 'Normal', 'Transferencia de prioridad normal', 'transferencias', 2, 72, false, 2),
  ('alta', 'Alta', 'Transferencia de alta prioridad', 'transferencias', 3, 24, true, 3),
  ('urgente', 'Urgente', 'Transferencia urgente', 'transferencias', 4, 8, true, 4)
ON CONFLICT (codigo, modulo) DO NOTHING;

-- ============================================
-- 13. DATOS INICIALES - CONFIGURACIONES
-- ============================================
INSERT INTO catalogo_configuraciones (clave, valor, tipo_dato, nombre, descripcion, categoria, valor_por_defecto, es_requerido, orden) VALUES
  -- Configuraciones de alertas
  ('dias_alerta_critica', '7', 'numero', 'Días para Alerta Crítica', 'Número de días antes del vencimiento para generar alerta crítica', 'alertas', '7', true, 1),
  ('dias_alerta_urgente', '30', 'numero', 'Días para Alerta Urgente', 'Número de días antes del vencimiento para generar alerta urgente', 'alertas', '30', true, 2),
  ('dias_alerta_preventiva', '90', 'numero', 'Días para Alerta Preventiva', 'Número de días antes del vencimiento para generar alerta preventiva', 'alertas', '90', true, 3),

  -- Configuraciones de sistema
  ('nombre_sistema', 'SIGIMED v2.0', 'texto', 'Nombre del Sistema', 'Nombre completo del sistema', 'sistema', 'SIGIMED v2.0', true, 10),
  ('registros_por_pagina', '10', 'numero', 'Registros por Página', 'Número de registros a mostrar por página en listados', 'sistema', '10', true, 11),
  ('idioma_sistema', 'es', 'texto', 'Idioma del Sistema', 'Idioma predeterminado del sistema (es, en)', 'sistema', 'es', true, 12),
  ('zona_horaria', 'America/Mexico_City', 'texto', 'Zona Horaria', 'Zona horaria del sistema', 'sistema', 'America/Mexico_City', true, 13),

  -- Configuraciones de notificaciones
  ('email_notificaciones', 'false', 'booleano', 'Email de Notificaciones', 'Activar/desactivar envío de notificaciones por email', 'notificaciones', 'false', true, 20),
  ('email_servidor', '', 'texto', 'Servidor de Email', 'Dirección del servidor SMTP para envío de emails', 'notificaciones', '', false, 21),
  ('email_puerto', '587', 'numero', 'Puerto de Email', 'Puerto del servidor SMTP', 'notificaciones', '587', false, 22),

  -- Configuraciones de seguridad
  ('sesion_timeout_minutos', '60', 'numero', 'Timeout de Sesión', 'Minutos de inactividad antes de cerrar sesión automáticamente', 'seguridad', '60', true, 30),
  ('permitir_registro_usuarios', 'false', 'booleano', 'Permitir Registro de Usuarios', 'Permitir que usuarios se registren desde la aplicación', 'seguridad', 'false', true, 31),
  ('longitud_minima_password', '8', 'numero', 'Longitud Mínima de Contraseña', 'Número mínimo de caracteres para contraseñas', 'seguridad', '8', true, 32)
ON CONFLICT (clave) DO NOTHING;

-- ============================================
-- 14. PERMISOS Y POLÍTICAS RLS
-- ============================================

-- Habilitar RLS en todas las tablas de catálogos
ALTER TABLE catalogo_colores ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_estados ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_tipos_movimiento ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_formas_farmaceuticas ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_prioridades ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_configuraciones ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden leer catálogos activos
CREATE POLICY "Permitir lectura de colores activos" ON catalogo_colores FOR SELECT USING (es_activo = true);
CREATE POLICY "Permitir lectura de estados activos" ON catalogo_estados FOR SELECT USING (es_activo = true);
CREATE POLICY "Permitir lectura de tipos movimiento activos" ON catalogo_tipos_movimiento FOR SELECT USING (es_activo = true);
CREATE POLICY "Permitir lectura de formas farmacéuticas activas" ON catalogo_formas_farmaceuticas FOR SELECT USING (es_activo = true);
CREATE POLICY "Permitir lectura de prioridades activas" ON catalogo_prioridades FOR SELECT USING (es_activo = true);
CREATE POLICY "Permitir lectura de configuraciones activas" ON catalogo_configuraciones FOR SELECT USING (es_activo = true);

-- Política: Solo admins pueden insertar/actualizar/eliminar catálogos
CREATE POLICY "Solo admins modifican colores" ON catalogo_colores FOR ALL
  USING (EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')
  ));

CREATE POLICY "Solo admins modifican estados" ON catalogo_estados FOR ALL
  USING (EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')
  ));

CREATE POLICY "Solo admins modifican tipos movimiento" ON catalogo_tipos_movimiento FOR ALL
  USING (EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')
  ));

CREATE POLICY "Solo admins modifican formas farmacéuticas" ON catalogo_formas_farmaceuticas FOR ALL
  USING (EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')
  ));

CREATE POLICY "Solo admins modifican prioridades" ON catalogo_prioridades FOR ALL
  USING (EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')
  ));

CREATE POLICY "Solo super admins modifican configuraciones" ON catalogo_configuraciones FOR ALL
  USING (EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid() AND role = 'super_admin'
  ));

-- ============================================
-- FIN DE MIGRACIÓN
-- ============================================

-- Verificación final
DO $$
DECLARE
  v_colores INTEGER;
  v_estados INTEGER;
  v_tipos_mov INTEGER;
  v_formas INTEGER;
  v_prioridades INTEGER;
  v_configs INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_colores FROM catalogo_colores;
  SELECT COUNT(*) INTO v_estados FROM catalogo_estados;
  SELECT COUNT(*) INTO v_tipos_mov FROM catalogo_tipos_movimiento;
  SELECT COUNT(*) INTO v_formas FROM catalogo_formas_farmaceuticas;
  SELECT COUNT(*) INTO v_prioridades FROM catalogo_prioridades;
  SELECT COUNT(*) INTO v_configs FROM catalogo_configuraciones;

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'MIGRACIÓN 09 COMPLETADA EXITOSAMENTE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Catálogo de Colores: % registros', v_colores;
  RAISE NOTICE 'Catálogo de Estados: % registros', v_estados;
  RAISE NOTICE 'Catálogo de Tipos de Movimiento: % registros', v_tipos_mov;
  RAISE NOTICE 'Catálogo de Formas Farmacéuticas: % registros', v_formas;
  RAISE NOTICE 'Catálogo de Prioridades: % registros', v_prioridades;
  RAISE NOTICE 'Catálogo de Configuraciones: % registros', v_configs;
  RAISE NOTICE '========================================';
END $$;
