-- ============================================
-- MIGRACIÓN 14: QR CODES & ENHANCED EXPORTS
-- ============================================
-- Descripción: Sistema mejorado de exportación con códigos QR y trazabilidad
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Referencias: ISO/IEC 18004 (QR Code standard)

-- ============================================
-- 1. TABLA: QR CODES GENERADOS
-- ============================================

CREATE TABLE IF NOT EXISTS public.qr_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Tipo de QR
  qr_type TEXT CHECK (qr_type IN (
    'medication', -- Info de medicamento
    'batch', -- Info de lote
    'location', -- Ubicación de almacén
    'serialization', -- SGTIN serializado
    'export', -- Exportación/documento
    'verification', -- Verificación de autenticidad
    'patient_prescription', -- Receta de paciente
    'inventory_report' -- Reporte de inventario
  )) NOT NULL,

  -- Datos codificados
  encoded_data TEXT NOT NULL, -- Datos en el QR (URL, JSON, texto plano)
  encoded_format TEXT CHECK (encoded_format IN ('url', 'json', 'text', 'vcard')) DEFAULT 'json',

  -- Referencias
  medication_catalog_id UUID REFERENCES public.medication_catalog(id),
  batch_id UUID REFERENCES public.batches(id),
  serialization_id UUID REFERENCES public.medication_serializations(id),
  location_id UUID REFERENCES public.ubicaciones_almacen(id),

  -- Generación
  qr_version INTEGER, -- QR version (1-40)
  qr_error_correction TEXT CHECK (qr_error_correction IN ('L', 'M', 'Q', 'H')) DEFAULT 'M',
  qr_size INTEGER DEFAULT 256, -- Tamaño en pixeles
  qr_image_url TEXT, -- URL de la imagen generada (si se guarda)
  qr_image_base64 TEXT, -- Imagen en base64 (si se guarda)

  -- Metadatos
  generated_by UUID REFERENCES public.users_profiles(id),
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE, -- Si el QR expira

  -- Escaneos
  scan_count INTEGER DEFAULT 0,
  last_scanned_at TIMESTAMP WITH TIME ZONE,

  -- Estado
  is_active BOOLEAN DEFAULT true,
  revoked_at TIMESTAMP WITH TIME ZONE,
  revoked_reason TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_qr_codes_type ON public.qr_codes(qr_type);
CREATE INDEX idx_qr_codes_medication ON public.qr_codes(medication_catalog_id);
CREATE INDEX idx_qr_codes_batch ON public.qr_codes(batch_id);
CREATE INDEX idx_qr_codes_serialization ON public.qr_codes(serialization_id);
CREATE INDEX idx_qr_codes_generated ON public.qr_codes(generated_at DESC);
CREATE INDEX idx_qr_codes_active ON public.qr_codes(is_active) WHERE is_active = true;

COMMENT ON TABLE public.qr_codes IS 'Registro de códigos QR generados para trazabilidad y verificación';
COMMENT ON COLUMN public.qr_codes.qr_error_correction IS 'L=7%, M=15%, Q=25%, H=30% de corrección de errores';

-- ============================================
-- 2. TABLA: ESCANEOS DE QR CODES
-- ============================================

CREATE TABLE IF NOT EXISTS public.qr_code_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  qr_code_id UUID REFERENCES public.qr_codes(id) ON DELETE CASCADE,

  -- Usuario y dispositivo
  scanned_by UUID REFERENCES public.users_profiles(id),
  scanner_device_id TEXT,
  scanner_type TEXT, -- 'mobile', 'tablet', 'webcam', 'dedicated'

  -- Ubicación del escaneo
  scan_location_gps POINT,
  scan_location_name TEXT,
  ip_address INET,
  user_agent TEXT,

  -- Timestamp
  scanned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Validación
  is_valid BOOLEAN DEFAULT true,
  validation_result JSONB,

  -- Metadatos
  metadata JSONB,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_qr_scans_qr_code ON public.qr_code_scans(qr_code_id);
CREATE INDEX idx_qr_scans_user ON public.qr_code_scans(scanned_by);
CREATE INDEX idx_qr_scans_timestamp ON public.qr_code_scans(scanned_at DESC);

COMMENT ON TABLE public.qr_code_scans IS 'Registro de todos los escaneos de códigos QR para auditoría';

-- ============================================
-- 3. TABLA: EXPORTACIONES MEJORADAS
-- ============================================

CREATE TABLE IF NOT EXISTS public.enhanced_exports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Tipo de exportación
  export_type TEXT CHECK (export_type IN (
    'pdf', 'excel', 'csv', 'json', 'xml', 'hl7'
  )) NOT NULL,

  -- Categoría
  category TEXT CHECK (category IN (
    'inventory', 'transactions', 'batches', 'alerts',
    'audit_log', 'temperature_log', 'dscsa_report',
    'regulatory_report', 'financial_report'
  )) NOT NULL,

  -- Archivo
  file_name TEXT NOT NULL,
  file_path TEXT, -- Path donde se guardó
  file_url TEXT, -- URL de descarga
  file_size_bytes BIGINT,
  file_hash TEXT, -- SHA-256 para integridad

  -- QR Code asociado (para verificación del documento)
  qr_code_id UUID REFERENCES public.qr_codes(id),
  has_digital_signature BOOLEAN DEFAULT false,
  digital_signature TEXT, -- Firma digital del documento

  -- Filtros aplicados
  filters_applied JSONB, -- {centro_id, fecha_inicio, fecha_fin, etc.}

  -- Estadísticas del reporte
  total_records INTEGER,
  summary_data JSONB,

  -- Generación
  generated_by UUID REFERENCES public.users_profiles(id),
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  generation_time_ms INTEGER, -- Tiempo que tardó en generarse

  -- Acceso
  download_count INTEGER DEFAULT 0,
  last_downloaded_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE, -- Cuándo expira el link de descarga

  -- Estado
  status TEXT CHECK (status IN ('generating', 'ready', 'expired', 'deleted')) DEFAULT 'generating',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_enhanced_exports_type ON public.enhanced_exports(export_type);
CREATE INDEX idx_enhanced_exports_category ON public.enhanced_exports(category);
CREATE INDEX idx_enhanced_exports_user ON public.enhanced_exports(generated_by);
CREATE INDEX idx_enhanced_exports_generated ON public.enhanced_exports(generated_at DESC);
CREATE INDEX idx_enhanced_exports_status ON public.enhanced_exports(status);

COMMENT ON TABLE public.enhanced_exports IS 'Registro mejorado de exportaciones con QR codes y firmas digitales';

-- ============================================
-- 4. FUNCIÓN: GENERAR QR CODE
-- ============================================

CREATE OR REPLACE FUNCTION generate_qr_code(
  p_qr_type TEXT,
  p_encoded_data TEXT,
  p_encoded_format TEXT DEFAULT 'json',
  p_user_id UUID DEFAULT NULL,
  p_reference_id UUID DEFAULT NULL,
  p_expires_in_days INTEGER DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_qr_id UUID;
  v_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Calcular expiración
  IF p_expires_in_days IS NOT NULL THEN
    v_expires_at := NOW() + (p_expires_in_days || ' days')::INTERVAL;
  END IF;

  -- Insertar QR
  INSERT INTO public.qr_codes (
    qr_type,
    encoded_data,
    encoded_format,
    generated_by,
    expires_at,
    -- Asignar referencias según tipo
    medication_catalog_id = CASE WHEN p_qr_type = 'medication' THEN p_reference_id END,
    batch_id = CASE WHEN p_qr_type = 'batch' THEN p_reference_id END,
    serialization_id = CASE WHEN p_qr_type = 'serialization' THEN p_reference_id END,
    location_id = CASE WHEN p_qr_type = 'location' THEN p_reference_id END
  ) VALUES (
    p_qr_type,
    p_encoded_data,
    p_encoded_format,
    p_user_id,
    v_expires_at
  )
  RETURNING id INTO v_qr_id;

  RETURN v_qr_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_qr_code IS 'Genera un código QR y lo registra en la base de datos';

-- ============================================
-- 5. FUNCIÓN: REGISTRAR ESCANEO DE QR
-- ============================================

CREATE OR REPLACE FUNCTION register_qr_scan(
  p_qr_code_id UUID,
  p_user_id UUID DEFAULT NULL,
  p_scanner_device_id TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_scan_id UUID;
  v_is_valid BOOLEAN := true;
  v_validation_result JSONB := '{}'::JSONB;
  v_qr_expires_at TIMESTAMP WITH TIME ZONE;
  v_qr_is_active BOOLEAN;
BEGIN
  -- Verificar estado del QR
  SELECT expires_at, is_active
  INTO v_qr_expires_at, v_qr_is_active
  FROM public.qr_codes
  WHERE id = p_qr_code_id;

  IF NOT FOUND THEN
    v_is_valid := false;
    v_validation_result := jsonb_build_object('error', 'QR code not found');
  ELSIF NOT v_qr_is_active THEN
    v_is_valid := false;
    v_validation_result := jsonb_build_object('error', 'QR code revoked or inactive');
  ELSIF v_qr_expires_at IS NOT NULL AND v_qr_expires_at < NOW() THEN
    v_is_valid := false;
    v_validation_result := jsonb_build_object('error', 'QR code expired', 'expired_at', v_qr_expires_at);
  ELSE
    v_validation_result := jsonb_build_object('success', true, 'scanned_at', NOW());
  END IF;

  -- Registrar escaneo
  INSERT INTO public.qr_code_scans (
    qr_code_id,
    scanned_by,
    scanner_device_id,
    is_valid,
    validation_result,
    metadata
  ) VALUES (
    p_qr_code_id,
    p_user_id,
    p_scanner_device_id,
    v_is_valid,
    v_validation_result,
    p_metadata
  )
  RETURNING id INTO v_scan_id;

  -- Actualizar contador de escaneos en qr_codes
  IF v_is_valid THEN
    UPDATE public.qr_codes
    SET scan_count = scan_count + 1,
        last_scanned_at = NOW()
    WHERE id = p_qr_code_id;
  END IF;

  RETURN v_scan_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION register_qr_scan IS 'Registra un escaneo de QR code y valida su estado';

-- ============================================
-- 6. FUNCIÓN: CREAR EXPORTACIÓN MEJORADA
-- ============================================

CREATE OR REPLACE FUNCTION create_enhanced_export(
  p_export_type TEXT,
  p_category TEXT,
  p_file_name TEXT,
  p_filters JSONB,
  p_user_id UUID,
  p_total_records INTEGER DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
  v_export_id UUID;
  v_qr_id UUID;
  v_qr_data JSONB;
BEGIN
  -- Crear registro de exportación
  INSERT INTO public.enhanced_exports (
    export_type,
    category,
    file_name,
    filters_applied,
    total_records,
    generated_by,
    status,
    expires_at
  ) VALUES (
    p_export_type,
    p_category,
    p_file_name,
    p_filters,
    p_total_records,
    p_user_id,
    'generating',
    NOW() + INTERVAL '7 days' -- Expira en 7 días
  )
  RETURNING id INTO v_export_id;

  -- Generar QR para verificación del documento
  v_qr_data := jsonb_build_object(
    'export_id', v_export_id,
    'type', p_export_type,
    'category', p_category,
    'generated_at', NOW(),
    'generated_by', p_user_id,
    'verify_url', 'https://sigimed.com/verify/' || v_export_id
  );

  v_qr_id := generate_qr_code(
    'export',
    v_qr_data::TEXT,
    'json',
    p_user_id,
    NULL,
    7 -- Expira en 7 días
  );

  -- Asociar QR con exportación
  UPDATE public.enhanced_exports
  SET qr_code_id = v_qr_id
  WHERE id = v_export_id;

  RETURN v_export_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_enhanced_export IS 'Crea un registro de exportación con QR code de verificación';

-- ============================================
-- 7. FUNCIÓN: GENERAR QR PARA BATCH
-- ============================================

CREATE OR REPLACE FUNCTION generate_batch_qr(
  p_batch_id UUID,
  p_user_id UUID
)
RETURNS UUID AS $$
DECLARE
  v_qr_id UUID;
  v_batch_data JSONB;
BEGIN
  -- Obtener datos del lote
  SELECT jsonb_build_object(
    'batch_id', b.id,
    'numero_lote', b.numero_lote,
    'medication', m.nombre,
    'fecha_caducidad', b.fecha_caducidad,
    'cantidad_actual', b.cantidad_actual,
    'proveedor', b.proveedor,
    'verify_url', 'https://sigimed.com/batch/' || b.id
  )
  INTO v_batch_data
  FROM public.batches b
  LEFT JOIN public.medication_catalog m ON b.medication_catalog_id = m.id
  WHERE b.id = p_batch_id;

  IF v_batch_data IS NULL THEN
    RAISE EXCEPTION 'Batch % no encontrado', p_batch_id;
  END IF;

  -- Generar QR
  INSERT INTO public.qr_codes (
    qr_type,
    encoded_data,
    encoded_format,
    batch_id,
    generated_by
  ) VALUES (
    'batch',
    v_batch_data::TEXT,
    'json',
    p_batch_id,
    p_user_id
  )
  RETURNING id INTO v_qr_id;

  RETURN v_qr_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_batch_qr IS 'Genera código QR con información de un lote para trazabilidad';

-- ============================================
-- 8. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.qr_code_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enhanced_exports ENABLE ROW LEVEL SECURITY;

-- QR Codes
CREATE POLICY "Usuarios pueden ver QR codes activos"
  ON public.qr_codes FOR SELECT
  USING (is_active = true);

CREATE POLICY "Usuarios autorizados pueden generar QR codes"
  ON public.qr_codes FOR INSERT
  WITH CHECK (
    generated_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center', 'pharmacist', 'warehouse_manager')
    )
  );

-- QR Scans
CREATE POLICY "Usuarios pueden ver sus escaneos"
  ON public.qr_code_scans FOR SELECT
  USING (
    scanned_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Usuarios pueden registrar escaneos"
  ON public.qr_code_scans FOR INSERT
  WITH CHECK (true); -- Cualquiera puede escanear

-- Enhanced Exports
CREATE POLICY "Usuarios ven sus exportaciones"
  ON public.enhanced_exports FOR SELECT
  USING (
    generated_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Usuarios autorizados pueden crear exportaciones"
  ON public.enhanced_exports FOR INSERT
  WITH CHECK (
    generated_by = auth.uid()
  );

-- ============================================
-- 9. VISTAS ÚTILES
-- ============================================

-- Vista: QR Codes con estadísticas
CREATE OR REPLACE VIEW v_qr_codes_stats AS
SELECT
  qc.id,
  qc.qr_type,
  qc.generated_at,
  qc.expires_at,
  qc.is_active,
  qc.scan_count,
  qc.last_scanned_at,
  CASE
    WHEN qc.expires_at IS NOT NULL AND qc.expires_at < NOW() THEN 'expired'
    WHEN NOT qc.is_active THEN 'revoked'
    WHEN qc.scan_count = 0 THEN 'unused'
    ELSE 'active'
  END AS status,
  up.full_name AS generated_by_name,
  COUNT(DISTINCT qcs.id) AS total_scans,
  COUNT(DISTINCT qcs.scanned_by) AS unique_scanners
FROM public.qr_codes qc
LEFT JOIN public.users_profiles up ON qc.generated_by = up.id
LEFT JOIN public.qr_code_scans qcs ON qc.id = qcs.qr_code_id
GROUP BY qc.id, qc.qr_type, qc.generated_at, qc.expires_at, qc.is_active,
         qc.scan_count, qc.last_scanned_at, up.full_name;

COMMENT ON VIEW v_qr_codes_stats IS 'Vista de códigos QR con estadísticas de uso';

-- ============================================
-- FIN DE MIGRACIÓN 14
-- ============================================

SELECT 'Migración 14 completada. Sistema QR Codes y Enhanced Exports implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('qr_codes', 'qr_code_scans', 'enhanced_exports');
