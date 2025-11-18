-- ============================================
-- MIGRACIÓN 11: SISTEMA GS1 BARCODING
-- ============================================
-- Descripción: Implementa sistema de códigos de barras GS1 para interoperabilidad global
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Estándar: GS1 Global Standards
-- Referencias: https://www.gs1.org/standards/barcodes

-- ============================================
-- 1. CONFIGURACIÓN EMPRESA GS1
-- ============================================

CREATE TABLE IF NOT EXISTS public.gs1_company_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_prefix TEXT NOT NULL UNIQUE, -- Prefijo GS1 (7-10 dígitos comprado a GS1)
  company_name TEXT NOT NULL,
  country_code TEXT DEFAULT 'MX', -- País (ej: MX, US, ES)
  license_number TEXT, -- Número de licencia GS1
  license_expiry_date DATE,
  contact_email TEXT,
  contact_phone TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.gs1_company_config IS 'Configuración de prefijo GS1 de la compañía';
COMMENT ON COLUMN public.gs1_company_config.company_prefix IS 'Prefijo GS1 asignado por GS1 (ej: 7501234 para México)';

-- ============================================
-- 2. TABLA: GTINs (Global Trade Item Numbers)
-- ============================================

CREATE TABLE IF NOT EXISTS public.gs1_gtins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_catalog_id UUID REFERENCES public.medication_catalog(id) ON DELETE CASCADE,
  gtin TEXT UNIQUE NOT NULL, -- GTIN-14 (14 dígitos)
  gtin_8 TEXT, -- GTIN-8 (8 dígitos) para productos pequeños
  gtin_12 TEXT, -- GTIN-12 / UPC (12 dígitos) para USA
  gtin_13 TEXT, -- GTIN-13 / EAN (13 dígitos) para Europa
  gtin_14 TEXT, -- GTIN-14 (14 dígitos) para cajas/pallets

  company_prefix TEXT NOT NULL, -- Prefijo de la compañía
  item_reference TEXT NOT NULL, -- Referencia del item (único por compañía)
  check_digit INTEGER NOT NULL, -- Dígito verificador calculado

  -- Códigos adicionales GS1
  packaging_level TEXT CHECK (packaging_level IN ('each', 'case', 'pallet')) DEFAULT 'each',
  indicator_digit INTEGER DEFAULT 0 CHECK (indicator_digit BETWEEN 0 AND 9),

  -- Metadatos
  description TEXT,
  brand TEXT,
  net_content TEXT, -- Contenido neto (ej: "500mg", "10ml")
  net_content_uom TEXT, -- Unidad de medida (mg, ml, g, etc.)

  -- Estado
  is_active BOOLEAN DEFAULT true,
  date_assigned DATE DEFAULT CURRENT_DATE,
  date_retired DATE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT valid_gtin_length CHECK (length(gtin) = 14)
);

COMMENT ON TABLE public.gs1_gtins IS 'GTINs (Global Trade Item Numbers) para medicamentos según estándar GS1';
COMMENT ON COLUMN public.gs1_gtins.gtin IS 'GTIN-14 completo con padding (00614141123452)';
COMMENT ON COLUMN public.gs1_gtins.check_digit IS 'Último dígito del GTIN calculado con algoritmo GS1';

-- ============================================
-- 3. TABLA: CÓDIGOS DE BARRAS IMPRESOS
-- ============================================

CREATE TABLE IF NOT EXISTS public.barcode_labels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gtin_id UUID REFERENCES public.gs1_gtins(id) ON DELETE CASCADE,
  batch_id UUID REFERENCES public.batches(id) ON DELETE CASCADE,

  -- Datos del código de barras
  barcode_format TEXT CHECK (barcode_format IN ('GS1-128', 'DataMatrix', 'QR', 'EAN-13', 'UPC-A')) DEFAULT 'GS1-128',
  barcode_data TEXT NOT NULL, -- Datos completos del código (Application Identifiers)

  -- Application Identifiers GS1
  ai_01_gtin TEXT, -- (01) GTIN
  ai_10_lot TEXT, -- (10) Lote
  ai_17_expiry TEXT, -- (17) Fecha caducidad YYMMDD
  ai_21_serial TEXT, -- (21) Número serial
  ai_37_count INTEGER, -- (37) Cantidad de items

  -- Impresión
  printed_at TIMESTAMP WITH TIME ZONE,
  printed_by UUID REFERENCES public.users_profiles(id),
  printer_id TEXT, -- ID de la impresora
  label_template TEXT, -- Template usado (ZPL, EPL, etc.)

  -- Verificación
  verified BOOLEAN DEFAULT false,
  verified_at TIMESTAMP WITH TIME ZONE,
  verified_by UUID REFERENCES public.users_profiles(id),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.barcode_labels IS 'Registro de códigos de barras GS1 impresos';
COMMENT ON COLUMN public.barcode_labels.barcode_data IS 'Datos completos en formato GS1: (01)GTIN(10)LOT(17)EXPIRY(21)SERIAL';

-- ============================================
-- 4. TABLA: ESCANEOS DE CÓDIGOS DE BARRAS
-- ============================================

CREATE TABLE IF NOT EXISTS public.barcode_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Datos del escaneo
  barcode_raw TEXT NOT NULL, -- Código escaneado sin procesar
  barcode_parsed JSONB, -- Datos parseados en JSON
  scan_type TEXT CHECK (scan_type IN ('receiving', 'dispensing', 'inventory', 'verification', 'shipping', 'quality_control')),

  -- Referencias
  gtin_id UUID REFERENCES public.gs1_gtins(id),
  batch_id UUID REFERENCES public.batches(id),
  location_id UUID REFERENCES public.ubicaciones_almacen(id),

  -- Usuario y dispositivo
  scanned_by UUID REFERENCES public.users_profiles(id),
  scanner_device_id TEXT, -- ID del escáner (ej: SCANNER-001)
  scanner_type TEXT, -- Tipo: mobile, handheld, fixed

  -- Ubicación física
  scan_location_gps POINT, -- Coordenadas GPS si disponible
  scan_location_name TEXT, -- Nombre de ubicación

  -- Validación
  is_valid BOOLEAN DEFAULT true,
  validation_errors TEXT[], -- Array de errores si hay

  -- Metadatos
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB -- Datos adicionales (IP, user agent, etc.)
);

CREATE INDEX idx_barcode_scans_timestamp ON public.barcode_scans(timestamp DESC);
CREATE INDEX idx_barcode_scans_type ON public.barcode_scans(scan_type);
CREATE INDEX idx_barcode_scans_user ON public.barcode_scans(scanned_by);
CREATE INDEX idx_barcode_scans_batch ON public.barcode_scans(batch_id);

COMMENT ON TABLE public.barcode_scans IS 'Registro de todos los escaneos de códigos de barras en el sistema';
COMMENT ON COLUMN public.barcode_scans.barcode_parsed IS 'Datos del código parseados: {gtin, lot, expiry, serial, etc.}';

-- ============================================
-- 5. ÍNDICES
-- ============================================

CREATE INDEX idx_gs1_gtins_medication ON public.gs1_gtins(medication_catalog_id);
CREATE INDEX idx_gs1_gtins_gtin ON public.gs1_gtins(gtin);
CREATE INDEX idx_gs1_gtins_active ON public.gs1_gtins(is_active) WHERE is_active = true;

CREATE INDEX idx_barcode_labels_gtin ON public.barcode_labels(gtin_id);
CREATE INDEX idx_barcode_labels_batch ON public.barcode_labels(batch_id);
CREATE INDEX idx_barcode_labels_printed ON public.barcode_labels(printed_at DESC);

-- ============================================
-- 6. FUNCIÓN: CALCULAR CHECK DIGIT GTIN
-- ============================================

CREATE OR REPLACE FUNCTION calculate_gtin_check_digit(p_gtin_base TEXT)
RETURNS INTEGER AS $$
DECLARE
  v_sum INTEGER := 0;
  v_digit INTEGER;
  v_multiplier INTEGER;
  v_check_digit INTEGER;
  i INTEGER;
BEGIN
  -- Algoritmo GS1 para calcular dígito verificador
  -- Multiplicar dígitos alternadamente por 3 y 1, de derecha a izquierda

  FOR i IN 1..length(p_gtin_base) LOOP
    v_digit := substring(p_gtin_base FROM length(p_gtin_base) - i + 1 FOR 1)::INTEGER;

    -- Multiplicar por 3 si posición es impar, por 1 si es par
    v_multiplier := CASE WHEN i % 2 = 1 THEN 3 ELSE 1 END;
    v_sum := v_sum + (v_digit * v_multiplier);
  END LOOP;

  -- Check digit es el número que suma a múltiplo de 10
  v_check_digit := (10 - (v_sum % 10)) % 10;

  RETURN v_check_digit;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_gtin_check_digit IS 'Calcula el dígito verificador de un GTIN según algoritmo GS1';

-- ============================================
-- 7. FUNCIÓN: GENERAR GTIN
-- ============================================

CREATE OR REPLACE FUNCTION generate_gtin(
  p_medication_catalog_id UUID,
  p_packaging_level TEXT DEFAULT 'each'
)
RETURNS TEXT AS $$
DECLARE
  v_company_prefix TEXT;
  v_item_reference TEXT;
  v_indicator_digit INTEGER;
  v_gtin_base TEXT;
  v_check_digit INTEGER;
  v_gtin_final TEXT;
  v_next_reference INTEGER;
BEGIN
  -- Obtener prefijo de compañía
  SELECT company_prefix INTO v_company_prefix
  FROM public.gs1_company_config
  WHERE is_active = true
  LIMIT 1;

  IF v_company_prefix IS NULL THEN
    RAISE EXCEPTION 'No hay configuración GS1 activa. Configure un prefijo de compañía primero.';
  END IF;

  -- Determinar indicator digit según nivel de empaque
  v_indicator_digit := CASE p_packaging_level
    WHEN 'each' THEN 0
    WHEN 'case' THEN 1
    WHEN 'pallet' THEN 2
    ELSE 0
  END;

  -- Generar item reference (secuencial)
  SELECT COALESCE(MAX(item_reference::INTEGER), 0) + 1
  INTO v_next_reference
  FROM public.gs1_gtins
  WHERE company_prefix = v_company_prefix;

  -- Formatear item reference con padding
  v_item_reference := LPAD(v_next_reference::TEXT, 5, '0');

  -- Construir GTIN base (13 dígitos sin check digit)
  -- Format: I (1) + Company Prefix (7-10) + Item Reference (variable) = 13 dígitos
  v_gtin_base := v_indicator_digit || v_company_prefix || v_item_reference;

  -- Asegurar que tenemos 13 dígitos
  v_gtin_base := LPAD(v_gtin_base, 13, '0');

  -- Calcular check digit
  v_check_digit := calculate_gtin_check_digit(v_gtin_base);

  -- GTIN final (14 dígitos)
  v_gtin_final := v_gtin_base || v_check_digit::TEXT;

  -- Insertar en tabla
  INSERT INTO public.gs1_gtins (
    medication_catalog_id,
    gtin,
    gtin_14,
    company_prefix,
    item_reference,
    check_digit,
    packaging_level,
    indicator_digit
  ) VALUES (
    p_medication_catalog_id,
    v_gtin_final,
    v_gtin_final,
    v_company_prefix,
    v_item_reference,
    v_check_digit,
    p_packaging_level,
    v_indicator_digit
  );

  RETURN v_gtin_final;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_gtin IS 'Genera un GTIN nuevo para un medicamento según estándar GS1';

-- ============================================
-- 8. FUNCIÓN: PARSEAR CÓDIGO GS1-128
-- ============================================

CREATE OR REPLACE FUNCTION parse_gs1_barcode(p_barcode TEXT)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB := '{}'::JSONB;
  v_ai TEXT;
  v_value TEXT;
  v_remaining TEXT := p_barcode;
BEGIN
  -- Parsear Application Identifiers GS1
  -- Format: (01)GTIN(10)LOT(17)EXPIRY(21)SERIAL

  -- AI 01 - GTIN (14 dígitos)
  IF v_remaining ~ '^\(01\)' THEN
    v_value := substring(v_remaining FROM 5 FOR 14);
    v_result := v_result || jsonb_build_object('gtin', v_value);
    v_remaining := substring(v_remaining FROM 19);
  END IF;

  -- AI 10 - Lote (variable, hasta \x1D o siguiente AI)
  IF v_remaining ~ '^\(10\)' THEN
    v_value := substring(v_remaining FROM 5 FOR position('(' IN substring(v_remaining FROM 5)) - 1);
    IF v_value = '' THEN
      v_value := substring(v_remaining FROM 5);
    END IF;
    v_result := v_result || jsonb_build_object('lot', v_value);
    v_remaining := substring(v_remaining FROM length('(10)' || v_value) + 1);
  END IF;

  -- AI 17 - Fecha caducidad YYMMDD (6 dígitos)
  IF v_remaining ~ '^\(17\)' THEN
    v_value := substring(v_remaining FROM 5 FOR 6);
    v_result := v_result || jsonb_build_object('expiry_yymmdd', v_value);
    v_result := v_result || jsonb_build_object('expiry_date',
      ('20' || substring(v_value FROM 1 FOR 2) || '-' ||
       substring(v_value FROM 3 FOR 2) || '-' ||
       substring(v_value FROM 5 FOR 2))::DATE
    );
    v_remaining := substring(v_remaining FROM 11);
  END IF;

  -- AI 21 - Serial number (variable)
  IF v_remaining ~ '^\(21\)' THEN
    v_value := substring(v_remaining FROM 5);
    v_result := v_result || jsonb_build_object('serial', v_value);
  END IF;

  -- AI 37 - Cantidad
  IF v_remaining ~ '^\(37\)' THEN
    v_value := substring(v_remaining FROM 5 FOR 8);
    v_result := v_result || jsonb_build_object('count', v_value::INTEGER);
    v_remaining := substring(v_remaining FROM 13);
  END IF;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION parse_gs1_barcode IS 'Parsea un código de barras GS1-128 en sus componentes (GTIN, lote, caducidad, serial)';

-- ============================================
-- 9. FUNCIÓN: REGISTRAR ESCANEO
-- ============================================

CREATE OR REPLACE FUNCTION register_barcode_scan(
  p_barcode_raw TEXT,
  p_scan_type TEXT,
  p_user_id UUID,
  p_scanner_device_id TEXT DEFAULT NULL,
  p_location_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_scan_id UUID;
  v_parsed JSONB;
  v_gtin_id UUID;
  v_batch_id UUID;
  v_is_valid BOOLEAN := true;
  v_errors TEXT[] := ARRAY[]::TEXT[];
BEGIN
  -- Parsear código
  v_parsed := parse_gs1_barcode(p_barcode_raw);

  -- Buscar GTIN
  IF v_parsed->>'gtin' IS NOT NULL THEN
    SELECT id INTO v_gtin_id
    FROM public.gs1_gtins
    WHERE gtin = v_parsed->>'gtin'
    AND is_active = true;

    IF v_gtin_id IS NULL THEN
      v_is_valid := false;
      v_errors := array_append(v_errors, 'GTIN no encontrado en sistema');
    END IF;
  ELSE
    v_is_valid := false;
    v_errors := array_append(v_errors, 'GTIN no presente en código');
  END IF;

  -- Buscar batch por lote
  IF v_parsed->>'lot' IS NOT NULL THEN
    SELECT id INTO v_batch_id
    FROM public.batches
    WHERE numero_lote = v_parsed->>'lot'
    LIMIT 1;
  END IF;

  -- Insertar escaneo
  INSERT INTO public.barcode_scans (
    barcode_raw,
    barcode_parsed,
    scan_type,
    gtin_id,
    batch_id,
    location_id,
    scanned_by,
    scanner_device_id,
    is_valid,
    validation_errors
  ) VALUES (
    p_barcode_raw,
    v_parsed,
    p_scan_type,
    v_gtin_id,
    v_batch_id,
    p_location_id,
    p_user_id,
    p_scanner_device_id,
    v_is_valid,
    CASE WHEN array_length(v_errors, 1) > 0 THEN v_errors ELSE NULL END
  )
  RETURNING id INTO v_scan_id;

  RETURN v_scan_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION register_barcode_scan IS 'Registra un escaneo de código de barras y valida los datos';

-- ============================================
-- 10. TRIGGER: ACTUALIZAR UPDATED_AT
-- ============================================

CREATE TRIGGER trigger_update_gs1_company_config_updated_at
  BEFORE UPDATE ON public.gs1_company_config
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_gs1_gtins_updated_at
  BEFORE UPDATE ON public.gs1_gtins
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- ============================================
-- 11. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.gs1_company_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gs1_gtins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barcode_labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barcode_scans ENABLE ROW LEVEL SECURITY;

-- Políticas para gs1_company_config
CREATE POLICY "Usuarios pueden ver configuración GS1"
  ON public.gs1_company_config FOR SELECT
  USING (true);

CREATE POLICY "Solo Super Admin puede modificar configuración GS1"
  ON public.gs1_company_config FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- Políticas para gs1_gtins
CREATE POLICY "Usuarios pueden ver GTINs"
  ON public.gs1_gtins FOR SELECT
  USING (true);

CREATE POLICY "Admin puede gestionar GTINs"
  ON public.gs1_gtins FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

-- Políticas para barcode_scans
CREATE POLICY "Usuarios pueden ver escaneos de su centro"
  ON public.barcode_scans FOR SELECT
  USING (
    scanned_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Usuarios pueden registrar escaneos"
  ON public.barcode_scans FOR INSERT
  WITH CHECK (
    scanned_by = auth.uid()
  );

-- ============================================
-- 12. DATOS DE EJEMPLO
-- ============================================

-- Insertar configuración GS1 de ejemplo (México)
INSERT INTO public.gs1_company_config (
  company_prefix,
  company_name,
  country_code,
  license_number
) VALUES (
  '7501234', -- Prefijo GS1 de ejemplo para México
  'Sistema SIGIMED',
  'MX',
  'MX-GS1-2025-001'
) ON CONFLICT (company_prefix) DO NOTHING;

-- ============================================
-- FIN DE MIGRACIÓN 11
-- ============================================

-- Verificar creación
SELECT 'Migración 11 completada. Sistema GS1 Barcoding implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('gs1_company_config', 'gs1_gtins', 'barcode_labels', 'barcode_scans');
