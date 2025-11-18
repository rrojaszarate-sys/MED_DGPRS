-- ============================================
-- MIGRACIÓN 12: DSCSA SERIALIZATION
-- ============================================
-- Descripción: Implementa serialización DSCSA (Drug Supply Chain Security Act) para compliance FDA
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Estándar: FDA DSCSA Title II of FDASIA
-- Referencias: https://www.fda.gov/drugs/drug-supply-chain-security-act-dscsa
-- Nota: Requerido para distribución de medicamentos en USA desde Nov 2023

-- ============================================
-- 1. TABLA: SERIALIZACIONES (SGTIN - Serialized GTIN)
-- ============================================

CREATE TABLE IF NOT EXISTS public.medication_serializations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identificación del producto (Product Identifier - PI)
  gtin_id UUID REFERENCES public.gs1_gtins(id) ON DELETE CASCADE,
  gtin TEXT NOT NULL, -- GTIN-14
  serial_number TEXT NOT NULL, -- Número serial único (SGTIN)
  lot_number TEXT NOT NULL, -- Número de lote
  expiry_date DATE NOT NULL, -- Fecha de caducidad

  -- NDC (National Drug Code) para USA
  ndc_code TEXT, -- Formato: 5-4-2 o 5-3-2 (ej: 12345-678-90)

  -- Identificador único combinado
  sgtin TEXT UNIQUE NOT NULL, -- Serialized GTIN completo

  -- Referencias internas
  medication_catalog_id UUID REFERENCES public.medication_catalog(id),
  batch_id UUID REFERENCES public.batches(id),

  -- Estado de serialización
  status TEXT CHECK (status IN ('active', 'dispensed', 'returned', 'destroyed', 'recalled', 'expired')) DEFAULT 'active',

  -- Comisionado y decomisionado
  commissioned_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  commissioned_by UUID REFERENCES public.users_profiles(id),
  decommissioned_date TIMESTAMP WITH TIME ZONE,
  decommissioned_reason TEXT,

  -- Ubicación actual
  current_location_id UUID REFERENCES public.ubicaciones_almacen(id),
  current_owner_organization TEXT, -- Organización dueña actual

  -- Metadatos
  manufacturing_date DATE,
  packaging_date DATE,

  -- Aggregation (para cajas/pallets)
  parent_sgtin TEXT, -- Si esta unidad está dentro de otra (ej: caja)
  aggregation_level INTEGER DEFAULT 0, -- 0=unidad, 1=caja, 2=pallet

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_medication_serializations_gtin ON public.medication_serializations(gtin);
CREATE INDEX idx_medication_serializations_serial ON public.medication_serializations(serial_number);
CREATE INDEX idx_medication_serializations_sgtin ON public.medication_serializations(sgtin);
CREATE INDEX idx_medication_serializations_status ON public.medication_serializations(status);
CREATE INDEX idx_medication_serializations_batch ON public.medication_serializations(batch_id);
CREATE INDEX idx_medication_serializations_expiry ON public.medication_serializations(expiry_date);

COMMENT ON TABLE public.medication_serializations IS 'Serialización DSCSA: cada unidad de medicamento tiene número serial único (SGTIN)';
COMMENT ON COLUMN public.medication_serializations.sgtin IS 'Serialized GTIN completo: GTIN + Serial';
COMMENT ON COLUMN public.medication_serializations.ndc_code IS 'National Drug Code requerido por FDA para USA';

-- ============================================
-- 2. TABLA: DSCSA TRANSACTION HISTORY
-- ============================================

CREATE TABLE IF NOT EXISTS public.dscsa_transaction_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Referencias
  serialization_id UUID REFERENCES public.medication_serializations(id) ON DELETE CASCADE,
  sgtin TEXT NOT NULL, -- Para búsqueda rápida

  -- Transaction Information (TI) - FDA Requirement
  transaction_type TEXT CHECK (transaction_type IN (
    'commission', -- Primera creación
    'ship', -- Envío
    'receive', -- Recepción
    'dispense', -- Dispensación a paciente
    'return', -- Devolución
    'destroy', -- Destrucción
    'recall', -- Retiro del mercado
    'verification' -- Verificación de autenticidad
  )) NOT NULL,

  -- Partes involucradas
  from_organization TEXT, -- Empresa origen (nombre legal completo)
  from_organization_dea TEXT, -- DEA number del origen
  from_organization_gln TEXT, -- GLN (Global Location Number)
  from_location_id UUID REFERENCES public.ubicaciones_almacen(id),

  to_organization TEXT, -- Empresa destino
  to_organization_dea TEXT, -- DEA number del destino
  to_organization_gln TEXT, -- GLN del destino
  to_location_id UUID REFERENCES public.ubicaciones_almacen(id),

  -- Transaction Statement (TS) - Attestation
  transaction_statement JSONB, -- {
  --   "authentic": true,
  --   "not_counterfeit": true,
  --   "not_diverted": true,
  --   "stored_properly": true,
  --   "attestation_signature": "...",
  --   "attested_by": "John Doe",
  --   "attested_date": "2025-11-18T10:00:00Z"
  -- }

  -- Documentos (DSCSA requiere mantener por 6 años)
  transaction_document_url TEXT, -- URL del documento T3 (TI, TS, TH)
  invoice_number TEXT,
  po_number TEXT, -- Purchase Order

  -- Cantidad
  quantity INTEGER DEFAULT 1,

  -- Timestamps
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  recorded_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  recorded_by UUID REFERENCES public.users_profiles(id),

  -- Verificación
  verified BOOLEAN DEFAULT false,
  verified_date TIMESTAMP WITH TIME ZONE,
  verified_by UUID REFERENCES public.users_profiles(id),
  verification_method TEXT, -- 'scan', 'manual', 'api'

  -- Metadatos
  metadata JSONB, -- Datos adicionales (temperatura, condiciones de transporte, etc.)

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_dscsa_history_sgtin ON public.dscsa_transaction_history(sgtin);
CREATE INDEX idx_dscsa_history_serialization ON public.dscsa_transaction_history(serialization_id);
CREATE INDEX idx_dscsa_history_type ON public.dscsa_transaction_history(transaction_type);
CREATE INDEX idx_dscsa_history_date ON public.dscsa_transaction_history(transaction_date DESC);
CREATE INDEX idx_dscsa_history_from_org ON public.dscsa_transaction_history(from_organization);
CREATE INDEX idx_dscsa_history_to_org ON public.dscsa_transaction_history(to_organization);

COMMENT ON TABLE public.dscsa_transaction_history IS 'Historial de transacciones DSCSA - mantener 6 años según FDA';
COMMENT ON COLUMN public.dscsa_transaction_history.transaction_statement IS 'Transaction Statement (TS) - attestación de autenticidad según DSCSA';

-- ============================================
-- 3. TABLA: EPCIS EVENTS (GS1 Standard)
-- ============================================

CREATE TABLE IF NOT EXISTS public.epcis_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- EPCIS Event Type
  event_type TEXT CHECK (event_type IN (
    'ObjectEvent', -- Observación de objetos
    'AggregationEvent', -- Agregación (ej: poner unidades en caja)
    'TransactionEvent', -- Transacción comercial
    'TransformationEvent' -- Transformación (ej: fabricación)
  )) NOT NULL,

  -- What (EPCs involucrados)
  epc_list TEXT[], -- Lista de EPCs/SGTINs
  parent_epc TEXT, -- EPC padre en caso de agregación

  -- When
  event_time TIMESTAMP WITH TIME ZONE NOT NULL,
  event_timezone TEXT DEFAULT 'America/Mexico_City',

  -- Where
  read_point_gln TEXT, -- GLN del punto de lectura
  read_point_name TEXT,
  biz_location_gln TEXT, -- GLN de la ubicación de negocio
  biz_location_name TEXT,
  location_id UUID REFERENCES public.ubicaciones_almacen(id),

  -- Why (Business Context)
  biz_step TEXT, -- Paso de negocio (ej: 'receiving', 'shipping', 'storing')
  disposition TEXT, -- Estado (ej: 'in_transit', 'in_progress', 'active')

  -- Action
  action TEXT CHECK (action IN ('ADD', 'OBSERVE', 'DELETE')),

  -- Cantidades
  quantity INTEGER,
  quantity_uom TEXT, -- Unidad de medida

  -- Source/Destination
  source_list JSONB, -- [{type: 'possessing_party', id: 'GLN'}]
  destination_list JSONB,

  -- Datos adicionales
  ilmd JSONB, -- Instance/Lot Master Data
  user_extensions JSONB, -- Extensiones custom

  -- Usuario
  recorded_by UUID REFERENCES public.users_profiles(id),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_epcis_events_type ON public.epcis_events(event_type);
CREATE INDEX idx_epcis_events_time ON public.epcis_events(event_time DESC);
CREATE INDEX idx_epcis_events_location ON public.epcis_events(location_id);

COMMENT ON TABLE public.epcis_events IS 'Eventos EPCIS (Electronic Product Code Information Services) según GS1 standard';

-- ============================================
-- 4. TABLA: DSCSA VERIFICATION REQUESTS
-- ============================================

CREATE TABLE IF NOT EXISTS public.dscsa_verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Producto a verificar
  gtin TEXT NOT NULL,
  serial_number TEXT NOT NULL,
  lot_number TEXT,
  expiry_date DATE,
  ndc_code TEXT,

  -- Solicitante
  requester_organization TEXT NOT NULL,
  requester_dea TEXT,
  requester_gln TEXT,
  requested_by UUID REFERENCES public.users_profiles(id),

  -- Tipo de verificación
  verification_type TEXT CHECK (verification_type IN (
    'saleable_return', -- Devolución vendible
    'suspect_product', -- Producto sospechoso
    'illegitimate_product', -- Producto ilegítimo
    'routine_check' -- Verificación rutinaria
  )) NOT NULL,

  -- Resultado
  status TEXT CHECK (status IN ('pending', 'verified', 'failed', 'suspect', 'illegitimate')) DEFAULT 'pending',
  verification_result JSONB, -- {
  --   "is_legitimate": true,
  --   "owner_verified": true,
  --   "transaction_history_complete": true,
  --   "alerts": []
  -- }

  -- Respuesta
  response_sent BOOLEAN DEFAULT false,
  response_sent_date TIMESTAMP WITH TIME ZONE,
  response_method TEXT, -- 'email', 'api', 'fax'

  -- Timestamps (FDA requiere respuesta en 24-48 horas)
  request_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  response_deadline TIMESTAMP WITH TIME ZONE, -- 24-48 horas después
  response_date TIMESTAMP WITH TIME ZONE,

  -- Notas
  notes TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_dscsa_verification_gtin ON public.dscsa_verification_requests(gtin, serial_number);
CREATE INDEX idx_dscsa_verification_status ON public.dscsa_verification_requests(status);
CREATE INDEX idx_dscsa_verification_deadline ON public.dscsa_verification_requests(response_deadline);

COMMENT ON TABLE public.dscsa_verification_requests IS 'Solicitudes de verificación DSCSA - FDA requiere respuesta en 24-48 horas';

-- ============================================
-- 5. FUNCIÓN: GENERAR SGTIN
-- ============================================

CREATE OR REPLACE FUNCTION generate_sgtin(
  p_gtin TEXT,
  p_serial_prefix TEXT DEFAULT 'SN'
)
RETURNS TEXT AS $$
DECLARE
  v_serial_number TEXT;
  v_sgtin TEXT;
  v_count INTEGER;
BEGIN
  -- Obtener contador para este GTIN
  SELECT COUNT(*) INTO v_count
  FROM public.medication_serializations
  WHERE gtin = p_gtin;

  -- Generar serial único
  v_serial_number := p_serial_prefix || LPAD((v_count + 1)::TEXT, 10, '0');

  -- SGTIN = GTIN + Serial
  v_sgtin := p_gtin || '.' || v_serial_number;

  RETURN v_sgtin;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_sgtin IS 'Genera un SGTIN (Serialized GTIN) único';

-- ============================================
-- 6. FUNCIÓN: COMISIONAR UNIDAD (DSCSA)
-- ============================================

CREATE OR REPLACE FUNCTION commission_serialized_unit(
  p_gtin TEXT,
  p_lot_number TEXT,
  p_expiry_date DATE,
  p_batch_id UUID,
  p_user_id UUID,
  p_organization TEXT DEFAULT 'Sistema SIGIMED',
  p_ndc_code TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_serialization_id UUID;
  v_sgtin TEXT;
  v_gtin_id UUID;
  v_medication_catalog_id UUID;
BEGIN
  -- Obtener gtin_id
  SELECT id, medication_catalog_id INTO v_gtin_id, v_medication_catalog_id
  FROM public.gs1_gtins
  WHERE gtin = p_gtin
  AND is_active = true;

  IF v_gtin_id IS NULL THEN
    RAISE EXCEPTION 'GTIN % no encontrado o inactivo', p_gtin;
  END IF;

  -- Generar SGTIN único
  v_sgtin := generate_sgtin(p_gtin);

  -- Crear serialización
  INSERT INTO public.medication_serializations (
    gtin_id,
    gtin,
    serial_number,
    lot_number,
    expiry_date,
    ndc_code,
    sgtin,
    medication_catalog_id,
    batch_id,
    status,
    commissioned_by,
    current_owner_organization
  ) VALUES (
    v_gtin_id,
    p_gtin,
    split_part(v_sgtin, '.', 2),
    p_lot_number,
    p_expiry_date,
    p_ndc_code,
    v_sgtin,
    v_medication_catalog_id,
    p_batch_id,
    'active',
    p_user_id,
    p_organization
  )
  RETURNING id INTO v_serialization_id;

  -- Registrar evento de comisionado
  INSERT INTO public.dscsa_transaction_history (
    serialization_id,
    sgtin,
    transaction_type,
    to_organization,
    quantity,
    transaction_date,
    recorded_by,
    verified,
    transaction_statement
  ) VALUES (
    v_serialization_id,
    v_sgtin,
    'commission',
    p_organization,
    1,
    NOW(),
    p_user_id,
    true,
    jsonb_build_object(
      'authentic', true,
      'not_counterfeit', true,
      'not_diverted', true,
      'stored_properly', true,
      'attested_date', NOW()
    )
  );

  RETURN v_serialization_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION commission_serialized_unit IS 'Comisiona una unidad serializada según DSCSA - crea SGTIN y primer registro de transacción';

-- ============================================
-- 7. FUNCIÓN: REGISTRAR TRANSACCIÓN DSCSA
-- ============================================

CREATE OR REPLACE FUNCTION register_dscsa_transaction(
  p_sgtin TEXT,
  p_transaction_type TEXT,
  p_from_organization TEXT,
  p_to_organization TEXT,
  p_user_id UUID,
  p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_transaction_id UUID;
  v_serialization_id UUID;
  v_current_status TEXT;
BEGIN
  -- Obtener serialización
  SELECT id, status INTO v_serialization_id, v_current_status
  FROM public.medication_serializations
  WHERE sgtin = p_sgtin;

  IF v_serialization_id IS NULL THEN
    RAISE EXCEPTION 'SGTIN % no encontrado', p_sgtin;
  END IF;

  -- Validar que no esté decomisionado
  IF v_current_status IN ('destroyed', 'dispensed') THEN
    RAISE EXCEPTION 'No se puede realizar transacción en unidad con status %', v_current_status;
  END IF;

  -- Registrar transacción
  INSERT INTO public.dscsa_transaction_history (
    serialization_id,
    sgtin,
    transaction_type,
    from_organization,
    to_organization,
    quantity,
    transaction_date,
    recorded_by,
    metadata,
    transaction_statement
  ) VALUES (
    v_serialization_id,
    p_sgtin,
    p_transaction_type,
    p_from_organization,
    p_to_organization,
    1,
    NOW(),
    p_user_id,
    p_metadata,
    jsonb_build_object(
      'authentic', true,
      'not_counterfeit', true,
      'not_diverted', true,
      'stored_properly', true,
      'attested_by', p_user_id::TEXT,
      'attested_date', NOW()
    )
  )
  RETURNING id INTO v_transaction_id;

  -- Actualizar estado de serialización según tipo
  IF p_transaction_type = 'dispense' THEN
    UPDATE public.medication_serializations
    SET status = 'dispensed',
        decommissioned_date = NOW(),
        decommissioned_reason = 'Dispensed to patient'
    WHERE id = v_serialization_id;
  ELSIF p_transaction_type = 'destroy' THEN
    UPDATE public.medication_serializations
    SET status = 'destroyed',
        decommissioned_date = NOW(),
        decommissioned_reason = 'Destroyed'
    WHERE id = v_serialization_id;
  ELSIF p_transaction_type = 'recall' THEN
    UPDATE public.medication_serializations
    SET status = 'recalled'
    WHERE id = v_serialization_id;
  END IF;

  -- Actualizar owner
  IF p_to_organization IS NOT NULL THEN
    UPDATE public.medication_serializations
    SET current_owner_organization = p_to_organization
    WHERE id = v_serialization_id;
  END IF;

  RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION register_dscsa_transaction IS 'Registra una transacción DSCSA y actualiza estado de la unidad';

-- ============================================
-- 8. FUNCIÓN: VERIFICAR AUTENTICIDAD (DSCSA)
-- ============================================

CREATE OR REPLACE FUNCTION verify_dscsa_product(
  p_gtin TEXT,
  p_serial_number TEXT,
  p_lot_number TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
  v_serialization record;
  v_transaction_count INTEGER;
  v_has_suspect_history BOOLEAN := false;
BEGIN
  -- Buscar serialización
  SELECT * INTO v_serialization
  FROM public.medication_serializations
  WHERE gtin = p_gtin
  AND serial_number = p_serial_number
  AND (p_lot_number IS NULL OR lot_number = p_lot_number);

  IF v_serialization.id IS NULL THEN
    RETURN jsonb_build_object(
      'is_legitimate', false,
      'status', 'not_found',
      'message', 'Producto no encontrado en sistema DSCSA'
    );
  END IF;

  -- Contar transacciones
  SELECT COUNT(*) INTO v_transaction_count
  FROM public.dscsa_transaction_history
  WHERE serialization_id = v_serialization.id;

  -- Verificar si hay historial sospechoso
  SELECT EXISTS(
    SELECT 1 FROM public.dscsa_transaction_history
    WHERE serialization_id = v_serialization.id
    AND verified = false
  ) INTO v_has_suspect_history;

  -- Construir resultado
  v_result := jsonb_build_object(
    'is_legitimate', CASE
      WHEN v_serialization.status IN ('destroyed', 'recalled') THEN false
      WHEN v_has_suspect_history THEN false
      WHEN v_transaction_count = 0 THEN false
      ELSE true
    END,
    'status', v_serialization.status,
    'sgtin', v_serialization.sgtin,
    'current_owner', v_serialization.current_owner_organization,
    'commissioned_date', v_serialization.commissioned_date,
    'expiry_date', v_serialization.expiry_date,
    'transaction_count', v_transaction_count,
    'has_suspect_history', v_has_suspect_history,
    'lot_number', v_serialization.lot_number,
    'ndc_code', v_serialization.ndc_code
  );

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION verify_dscsa_product IS 'Verifica autenticidad de producto según DSCSA - usado para responder verification requests';

-- ============================================
-- 9. TRIGGER: ACTUALIZAR UPDATED_AT
-- ============================================

CREATE TRIGGER trigger_update_serializations_updated_at
  BEFORE UPDATE ON public.medication_serializations
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- ============================================
-- 10. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.medication_serializations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dscsa_transaction_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.epcis_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dscsa_verification_requests ENABLE ROW LEVEL SECURITY;

-- Políticas para medication_serializations
CREATE POLICY "Usuarios pueden ver serializaciones"
  ON public.medication_serializations FOR SELECT
  USING (true);

CREATE POLICY "Admin puede gestionar serializaciones"
  ON public.medication_serializations FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center', 'pharmacist')
    )
  );

-- Políticas para dscsa_transaction_history
CREATE POLICY "Usuarios pueden ver historial DSCSA"
  ON public.dscsa_transaction_history FOR SELECT
  USING (true);

CREATE POLICY "Usuarios autorizados pueden registrar transacciones"
  ON public.dscsa_transaction_history FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center', 'pharmacist', 'warehouse_manager')
    )
  );

-- Políticas para verification requests
CREATE POLICY "Admin puede ver verification requests"
  ON public.dscsa_verification_requests FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center', 'pharmacist')
    )
  );

CREATE POLICY "Usuarios pueden crear verification requests"
  ON public.dscsa_verification_requests FOR INSERT
  WITH CHECK (
    requested_by = auth.uid()
  );

-- ============================================
-- 11. VISTAS ÚTILES
-- ============================================

-- Vista: Productos serializados activos
CREATE OR REPLACE VIEW v_active_serialized_products AS
SELECT
  s.id,
  s.sgtin,
  s.gtin,
  s.serial_number,
  s.lot_number,
  s.expiry_date,
  s.ndc_code,
  s.status,
  s.current_owner_organization,
  s.current_location_id,
  g.description AS product_description,
  m.nombre AS medication_name,
  COUNT(DISTINCT t.id) AS transaction_count,
  MAX(t.transaction_date) AS last_transaction_date
FROM public.medication_serializations s
LEFT JOIN public.gs1_gtins g ON s.gtin_id = g.id
LEFT JOIN public.medication_catalog m ON s.medication_catalog_id = m.id
LEFT JOIN public.dscsa_transaction_history t ON s.id = t.serialization_id
WHERE s.status = 'active'
GROUP BY s.id, s.sgtin, s.gtin, s.serial_number, s.lot_number, s.expiry_date,
         s.ndc_code, s.status, s.current_owner_organization, s.current_location_id,
         g.description, m.nombre;

COMMENT ON VIEW v_active_serialized_products IS 'Vista de productos serializados activos con conteo de transacciones';

-- ============================================
-- FIN DE MIGRACIÓN 12
-- ============================================

-- Verificar creación
SELECT 'Migración 12 completada. Sistema DSCSA Serialization implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('medication_serializations', 'dscsa_transaction_history', 'epcis_events', 'dscsa_verification_requests');
