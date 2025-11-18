-- ============================================
-- MIGRACIÓN 16: NOTIFICATIONS SYSTEM
-- ============================================
-- Descripción: Sistema completo de notificaciones (SMS, Email, Push)
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Integraciones: Twilio (SMS), SendGrid (Email), Firebase (Push)

-- ============================================
-- 1. TABLA: NOTIFICATION TEMPLATES
-- ============================================

CREATE TABLE IF NOT EXISTS public.notification_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identificación
  template_code TEXT UNIQUE NOT NULL, -- Código único (ej: 'MEDICATION_EXPIRING')
  template_name TEXT NOT NULL,
  description TEXT,

  -- Categoría
  category TEXT CHECK (category IN (
    'alert', 'reminder', 'expiration', 'low_stock',
    'temperature_excursion', 'system', 'approval',
    'transaction', 'report_ready'
  )) NOT NULL,

  -- Severidad
  severity TEXT CHECK (severity IN ('critical', 'high', 'medium', 'low', 'info')) DEFAULT 'medium',

  -- Canales
  channels TEXT[] DEFAULT ARRAY['email'], -- ['email', 'sms', 'push', 'in_app']

  -- Contenido (plantillas con variables {{variable_name}})
  subject_template TEXT, -- Para email
  body_template_text TEXT NOT NULL, -- Texto plano
  body_template_html TEXT, -- HTML para email
  sms_template TEXT, -- Plantilla corta para SMS (160 chars)
  push_title_template TEXT, -- Título para notificación push
  push_body_template TEXT, -- Cuerpo para notificación push

  -- Variables disponibles (para documentación)
  available_variables JSONB, -- {"medication_name": "string", "expiry_date": "date"}

  -- Configuración
  is_enabled BOOLEAN DEFAULT true,
  requires_acknowledgment BOOLEAN DEFAULT false,
  auto_dismiss_after_hours INTEGER, -- Autodesechar después de X horas

  -- Throttling (para evitar spam)
  max_per_user_per_day INTEGER,
  min_interval_minutes INTEGER, -- Mínimo intervalo entre notificaciones del mismo tipo

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notification_templates_code ON public.notification_templates(template_code);
CREATE INDEX idx_notification_templates_category ON public.notification_templates(category);
CREATE INDEX idx_notification_templates_enabled ON public.notification_templates(is_enabled) WHERE is_enabled = true;

COMMENT ON TABLE public.notification_templates IS 'Plantillas de notificaciones reutilizables con soporte multi-canal';

-- ============================================
-- 2. TABLA: USER NOTIFICATION PREFERENCES
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID REFERENCES public.users_profiles(id) ON DELETE CASCADE,

  -- Canales habilitados
  email_enabled BOOLEAN DEFAULT true,
  sms_enabled BOOLEAN DEFAULT false,
  push_enabled BOOLEAN DEFAULT true,
  in_app_enabled BOOLEAN DEFAULT true,

  -- Contactos
  email_address TEXT,
  phone_number TEXT, -- Formato E.164: +52XXXXXXXXXX
  push_token TEXT, -- FCM/APNs device token
  push_device_type TEXT, -- 'android', 'ios', 'web'

  -- Horarios (quiet hours)
  quiet_hours_enabled BOOLEAN DEFAULT false,
  quiet_hours_start TIME, -- Ej: 22:00
  quiet_hours_end TIME, -- Ej: 08:00
  quiet_hours_timezone TEXT DEFAULT 'America/Mexico_City',

  -- Preferencias por categoría
  category_preferences JSONB DEFAULT '{
    "alert": {"email": true, "sms": true, "push": true},
    "reminder": {"email": true, "sms": false, "push": true},
    "expiration": {"email": true, "sms": false, "push": true},
    "low_stock": {"email": true, "sms": false, "push": false},
    "temperature_excursion": {"email": true, "sms": true, "push": true},
    "system": {"email": true, "sms": false, "push": false}
  }'::JSONB,

  -- Digest (resumen diario/semanal)
  digest_enabled BOOLEAN DEFAULT false,
  digest_frequency TEXT CHECK (digest_frequency IN ('daily', 'weekly')) DEFAULT 'daily',
  digest_time TIME DEFAULT '08:00',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id)
);

CREATE INDEX idx_user_notif_prefs_user ON public.user_notification_preferences(user_id);

COMMENT ON TABLE public.user_notification_preferences IS 'Preferencias de notificaciones por usuario';

-- ============================================
-- 3. TABLA: NOTIFICATION QUEUE
-- ============================================

CREATE TABLE IF NOT EXISTS public.notification_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Destinatario
  user_id UUID REFERENCES public.users_profiles(id) ON DELETE CASCADE,
  recipient_email TEXT,
  recipient_phone TEXT,
  recipient_push_token TEXT,

  -- Tipo de notificación
  template_id UUID REFERENCES public.notification_templates(id),
  template_code TEXT NOT NULL,
  category TEXT NOT NULL,
  severity TEXT NOT NULL,

  -- Canales a usar
  channels TEXT[] NOT NULL, -- ['email', 'sms', 'push']

  -- Contenido (renderizado con variables)
  subject TEXT,
  body_text TEXT NOT NULL,
  body_html TEXT,
  sms_text TEXT,
  push_title TEXT,
  push_body TEXT,

  -- Variables usadas (para debugging)
  template_variables JSONB,

  -- Metadata
  metadata JSONB, -- Datos adicionales (enlaces, botones, etc.)

  -- Relacionado a
  related_entity_type TEXT, -- 'batch', 'medication', 'alert'
  related_entity_id UUID,

  -- Estado
  status TEXT CHECK (status IN (
    'queued', 'sending', 'sent', 'failed', 'cancelled'
  )) DEFAULT 'queued',

  -- Programación
  scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  send_after TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,

  -- Delivery tracking
  sent_at TIMESTAMP WITH TIME ZONE,
  email_sent_at TIMESTAMP WITH TIME ZONE,
  sms_sent_at TIMESTAMP WITH TIME ZONE,
  push_sent_at TIMESTAMP WITH TIME ZONE,

  -- Errores
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  last_error TEXT,
  error_details JSONB,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notification_queue_user ON public.notification_queue(user_id);
CREATE INDEX idx_notification_queue_status ON public.notification_queue(status);
CREATE INDEX idx_notification_queue_scheduled ON public.notification_queue(scheduled_for) WHERE status = 'queued';
CREATE INDEX idx_notification_queue_template ON public.notification_queue(template_code);
CREATE INDEX idx_notification_queue_category ON public.notification_queue(category);

COMMENT ON TABLE public.notification_queue IS 'Cola de notificaciones pendientes de envío';

-- ============================================
-- 4. TABLA: NOTIFICATION DELIVERY LOG
-- ============================================

CREATE TABLE IF NOT EXISTS public.notification_delivery_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  notification_queue_id UUID REFERENCES public.notification_queue(id) ON DELETE CASCADE,

  -- Canal específico
  channel TEXT CHECK (channel IN ('email', 'sms', 'push', 'in_app')) NOT NULL,

  -- Estado de entrega
  delivery_status TEXT CHECK (delivery_status IN (
    'sent', 'delivered', 'failed', 'bounced', 'rejected', 'clicked', 'opened'
  )) NOT NULL,

  -- Proveedor
  provider TEXT, -- 'twilio', 'sendgrid', 'firebase', 'ses'
  provider_message_id TEXT, -- ID del mensaje en el proveedor
  provider_response JSONB,

  -- Destinatario
  recipient TEXT NOT NULL, -- email, phone, o push token

  -- Tracking
  delivered_at TIMESTAMP WITH TIME ZONE,
  opened_at TIMESTAMP WITH TIME ZONE,
  clicked_at TIMESTAMP WITH TIME ZONE,
  bounced_at TIMESTAMP WITH TIME ZONE,

  -- Errores
  error_message TEXT,
  error_code TEXT,

  -- Costos (si aplica)
  cost_amount DECIMAL(10, 6), -- Ej: 0.0075 USD por SMS
  cost_currency TEXT DEFAULT 'USD',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notif_delivery_queue ON public.notification_delivery_log(notification_queue_id);
CREATE INDEX idx_notif_delivery_channel ON public.notification_delivery_log(channel);
CREATE INDEX idx_notif_delivery_status ON public.notification_delivery_log(delivery_status);
CREATE INDEX idx_notif_delivery_created ON public.notification_delivery_log(created_at DESC);

COMMENT ON TABLE public.notification_delivery_log IS 'Log detallado de entregas de notificaciones por canal';

-- ============================================
-- 5. TABLA: IN-APP NOTIFICATIONS
-- ============================================

CREATE TABLE IF NOT EXISTS public.in_app_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID REFERENCES public.users_profiles(id) ON DELETE CASCADE,
  notification_queue_id UUID REFERENCES public.notification_queue(id),

  -- Contenido
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT NOT NULL,
  severity TEXT NOT NULL,

  -- Acción
  action_url TEXT, -- URL a abrir al hacer click
  action_label TEXT, -- Texto del botón (ej: "Ver detalle")

  -- Relacionado
  related_entity_type TEXT,
  related_entity_id UUID,

  -- Estado
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  is_dismissed BOOLEAN DEFAULT false,
  dismissed_at TIMESTAMP WITH TIME ZONE,

  -- Reconocimiento (para notificaciones críticas)
  requires_acknowledgment BOOLEAN DEFAULT false,
  acknowledged_at TIMESTAMP WITH TIME ZONE,

  -- Expiración
  expires_at TIMESTAMP WITH TIME ZONE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_in_app_notif_user ON public.in_app_notifications(user_id);
CREATE INDEX idx_in_app_notif_unread ON public.in_app_notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_in_app_notif_category ON public.in_app_notifications(category);
CREATE INDEX idx_in_app_notif_created ON public.in_app_notifications(created_at DESC);

COMMENT ON TABLE public.in_app_notifications IS 'Notificaciones in-app (campana de notificaciones)';

-- ============================================
-- 6. FUNCIÓN: RENDERIZAR PLANTILLA
-- ============================================

CREATE OR REPLACE FUNCTION render_template(
  p_template TEXT,
  p_variables JSONB
)
RETURNS TEXT AS $$
DECLARE
  v_result TEXT := p_template;
  v_key TEXT;
  v_value TEXT;
BEGIN
  -- Reemplazar cada variable {{key}} con su valor
  FOR v_key, v_value IN SELECT * FROM jsonb_each_text(p_variables)
  LOOP
    v_result := REPLACE(v_result, '{{' || v_key || '}}', v_value);
  END LOOP;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION render_template IS 'Renderiza una plantilla reemplazando {{variables}} con valores del JSONB';

-- ============================================
-- 7. FUNCIÓN: CREAR NOTIFICACIÓN
-- ============================================

CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_template_code TEXT,
  p_variables JSONB DEFAULT '{}'::JSONB,
  p_related_entity_type TEXT DEFAULT NULL,
  p_related_entity_id UUID DEFAULT NULL,
  p_override_channels TEXT[] DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_template record;
  v_preferences record;
  v_queue_id UUID;
  v_channels TEXT[];
  v_subject TEXT;
  v_body_text TEXT;
  v_body_html TEXT;
  v_sms_text TEXT;
  v_push_title TEXT;
  v_push_body TEXT;
  v_in_quiet_hours BOOLEAN := false;
BEGIN
  -- Obtener template
  SELECT * INTO v_template
  FROM public.notification_templates
  WHERE template_code = p_template_code
  AND is_enabled = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Template % no encontrado o deshabilitado', p_template_code;
  END IF;

  -- Obtener preferencias del usuario
  SELECT * INTO v_preferences
  FROM public.user_notification_preferences
  WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    -- Crear preferencias por defecto
    INSERT INTO public.user_notification_preferences (user_id)
    VALUES (p_user_id)
    RETURNING * INTO v_preferences;
  END IF;

  -- Determinar canales a usar
  IF p_override_channels IS NOT NULL THEN
    v_channels := p_override_channels;
  ELSE
    v_channels := ARRAY[]::TEXT[];

    -- Verificar cada canal según preferencias
    IF v_template.channels @> ARRAY['email'] AND v_preferences.email_enabled AND
       (v_preferences.category_preferences->v_template.category->>'email')::BOOLEAN THEN
      v_channels := array_append(v_channels, 'email');
    END IF;

    IF v_template.channels @> ARRAY['sms'] AND v_preferences.sms_enabled AND
       (v_preferences.category_preferences->v_template.category->>'sms')::BOOLEAN THEN
      v_channels := array_append(v_channels, 'sms');
    END IF;

    IF v_template.channels @> ARRAY['push'] AND v_preferences.push_enabled AND
       (v_preferences.category_preferences->v_template.category->>'push')::BOOLEAN THEN
      v_channels := array_append(v_channels, 'push');
    END IF;

    -- In-app siempre se crea si está habilitado
    IF v_preferences.in_app_enabled THEN
      v_channels := array_append(v_channels, 'in_app');
    END IF;
  END IF;

  -- Si no hay canales, no crear notificación
  IF array_length(v_channels, 1) = 0 THEN
    RETURN NULL;
  END IF;

  -- Renderizar plantillas
  v_subject := render_template(COALESCE(v_template.subject_template, ''), p_variables);
  v_body_text := render_template(v_template.body_template_text, p_variables);
  v_body_html := render_template(COALESCE(v_template.body_template_html, ''), p_variables);
  v_sms_text := render_template(COALESCE(v_template.sms_template, v_template.body_template_text), p_variables);
  v_push_title := render_template(COALESCE(v_template.push_title_template, v_template.subject_template, ''), p_variables);
  v_push_body := render_template(COALESCE(v_template.push_body_template, v_template.body_template_text), p_variables);

  -- Truncar SMS a 160 caracteres
  IF length(v_sms_text) > 160 THEN
    v_sms_text := substring(v_sms_text, 1, 157) || '...';
  END IF;

  -- Insertar en cola
  INSERT INTO public.notification_queue (
    user_id,
    recipient_email,
    recipient_phone,
    recipient_push_token,
    template_id,
    template_code,
    category,
    severity,
    channels,
    subject,
    body_text,
    body_html,
    sms_text,
    push_title,
    push_body,
    template_variables,
    related_entity_type,
    related_entity_id
  ) VALUES (
    p_user_id,
    v_preferences.email_address,
    v_preferences.phone_number,
    v_preferences.push_token,
    v_template.id,
    p_template_code,
    v_template.category,
    v_template.severity,
    v_channels,
    v_subject,
    v_body_text,
    v_body_html,
    v_sms_text,
    v_push_title,
    v_push_body,
    p_variables,
    p_related_entity_type,
    p_related_entity_id
  )
  RETURNING id INTO v_queue_id;

  -- Si incluye in-app, crear notificación in-app
  IF 'in_app' = ANY(v_channels) THEN
    INSERT INTO public.in_app_notifications (
      user_id,
      notification_queue_id,
      title,
      message,
      category,
      severity,
      related_entity_type,
      related_entity_id,
      requires_acknowledgment
    ) VALUES (
      p_user_id,
      v_queue_id,
      v_push_title,
      v_push_body,
      v_template.category,
      v_template.severity,
      p_related_entity_type,
      p_related_entity_id,
      v_template.requires_acknowledgment
    );
  END IF;

  RETURN v_queue_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_notification IS 'Crea una notificación basada en template y preferencias del usuario';

-- ============================================
-- 8. FUNCIÓN: MARCAR NOTIFICACIÓN COMO LEÍDA
-- ============================================

CREATE OR REPLACE FUNCTION mark_notification_read(p_notification_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_updated BOOLEAN;
BEGIN
  UPDATE public.in_app_notifications
  SET is_read = true,
      read_at = NOW()
  WHERE id = p_notification_id
  AND user_id = p_user_id
  AND is_read = false
  RETURNING true INTO v_updated;

  RETURN COALESCE(v_updated, false);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. FUNCIÓN: MARCAR TODAS COMO LEÍDAS
-- ============================================

CREATE OR REPLACE FUNCTION mark_all_notifications_read(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  UPDATE public.in_app_notifications
  SET is_read = true,
      read_at = NOW()
  WHERE user_id = p_user_id
  AND is_read = false
  RETURNING COUNT(*) INTO v_count;

  RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. TRIGGER: AUTO-NOTIFICAR MEDICAMENTOS PRÓXIMOS A VENCER
-- ============================================

CREATE OR REPLACE FUNCTION notify_expiring_medications()
RETURNS void AS $$
DECLARE
  v_batch record;
  v_users UUID[];
BEGIN
  -- Buscar lotes que vencen en 30 días
  FOR v_batch IN
    SELECT
      b.id,
      b.numero_lote,
      b.fecha_caducidad,
      m.nombre AS medication_name,
      b.cantidad_actual
    FROM public.batches b
    JOIN public.medication_catalog m ON b.medication_catalog_id = m.id
    WHERE b.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
    AND b.cantidad_actual > 0
    AND b.is_active = true
  LOOP
    -- Obtener usuarios del centro (simplificado - en producción sería más específico)
    SELECT ARRAY_AGG(id) INTO v_users
    FROM public.users_profiles
    WHERE role IN ('pharmacist', 'warehouse_manager', 'admin_center')
    LIMIT 10;

    -- Crear notificación para cada usuario
    FOR i IN 1..COALESCE(array_length(v_users, 1), 0) LOOP
      PERFORM create_notification(
        v_users[i],
        'MEDICATION_EXPIRING',
        jsonb_build_object(
          'medication_name', v_batch.medication_name,
          'lot_number', v_batch.numero_lote,
          'expiry_date', v_batch.fecha_caducidad::TEXT,
          'quantity', v_batch.cantidad_actual,
          'days_until_expiry', (v_batch.fecha_caducidad - CURRENT_DATE)::TEXT
        ),
        'batch',
        v_batch.id
      );
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 11. TRIGGER: ACTUALIZAR UPDATED_AT
-- ============================================

CREATE TRIGGER trigger_update_notification_templates_updated_at
  BEFORE UPDATE ON public.notification_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_user_notif_prefs_updated_at
  BEFORE UPDATE ON public.user_notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- ============================================
-- 12. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_delivery_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.in_app_notifications ENABLE ROW LEVEL SECURITY;

-- Templates - todos pueden ver
CREATE POLICY "Usuarios pueden ver templates"
  ON public.notification_templates FOR SELECT
  USING (is_enabled = true);

-- Preferencias - solo el usuario
CREATE POLICY "Usuarios ven sus preferencias"
  ON public.user_notification_preferences FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Usuarios modifican sus preferencias"
  ON public.user_notification_preferences FOR ALL
  USING (user_id = auth.uid());

-- Cola - solo admin y el usuario
CREATE POLICY "Usuarios ven sus notificaciones en cola"
  ON public.notification_queue FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.users_profiles WHERE id = auth.uid() AND role = 'super_admin')
  );

-- In-app - solo el usuario
CREATE POLICY "Usuarios ven sus notificaciones in-app"
  ON public.in_app_notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Usuarios actualizan sus notificaciones in-app"
  ON public.in_app_notifications FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================
-- 13. DATOS DE EJEMPLO - TEMPLATES
-- ============================================

INSERT INTO public.notification_templates (
  template_code,
  template_name,
  description,
  category,
  severity,
  channels,
  subject_template,
  body_template_text,
  sms_template,
  push_title_template,
  push_body_template,
  available_variables
) VALUES
(
  'MEDICATION_EXPIRING',
  'Medicamento próximo a vencer',
  'Notifica cuando un medicamento está próximo a su fecha de caducidad',
  'expiration',
  'medium',
  ARRAY['email', 'push', 'in_app'],
  'Medicamento próximo a vencer: {{medication_name}}',
  'El medicamento {{medication_name}} (Lote: {{lot_number}}) vence el {{expiry_date}}. Cantidad actual: {{quantity}} unidades. Quedan {{days_until_expiry}} días.',
  'Medicamento {{medication_name}} vence en {{days_until_expiry}} días. Lote: {{lot_number}}',
  'Medicamento próximo a vencer',
  '{{medication_name}} vence en {{days_until_expiry}} días',
  '{"medication_name": "string", "lot_number": "string", "expiry_date": "date", "quantity": "number", "days_until_expiry": "number"}'::JSONB
),
(
  'LOW_STOCK_ALERT',
  'Stock bajo',
  'Alerta de stock bajo de medicamento',
  'low_stock',
  'high',
  ARRAY['email', 'push', 'in_app'],
  'Stock bajo: {{medication_name}}',
  'El medicamento {{medication_name}} tiene stock bajo. Cantidad actual: {{current_quantity}}. Punto de reorden: {{reorder_point}}.',
  'Stock bajo: {{medication_name}} - {{current_quantity}} unidades',
  'Stock Bajo',
  '{{medication_name}}: {{current_quantity}} unidades',
  '{"medication_name": "string", "current_quantity": "number", "reorder_point": "number"}'::JSONB
),
(
  'TEMPERATURE_EXCURSION',
  'Excursión térmica',
  'Alerta crítica de excursión térmica',
  'temperature_excursion',
  'critical',
  ARRAY['email', 'sms', 'push', 'in_app'],
  'URGENTE: Excursión térmica en {{location_name}}',
  'Se ha detectado una excursión térmica en {{location_name}}. Temperatura: {{temperature}}°C. Rango permitido: {{min_temp}}°C - {{max_temp}}°C. Acción inmediata requerida.',
  'URGENTE: Excursión térmica {{location_name}}: {{temperature}}°C',
  'Excursión Térmica',
  '{{location_name}}: {{temperature}}°C (crítico)',
  '{"location_name": "string", "temperature": "number", "min_temp": "number", "max_temp": "number"}'::JSONB
)
ON CONFLICT (template_code) DO NOTHING;

-- ============================================
-- FIN DE MIGRACIÓN 16
-- ============================================

SELECT 'Migración 16 completada. Sistema de Notificaciones implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('notification_templates', 'user_notification_preferences', 'notification_queue', 'in_app_notifications');
