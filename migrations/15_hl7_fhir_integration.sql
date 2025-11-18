-- ============================================
-- MIGRACIÓN 15: HL7 FHIR INTEGRATION
-- ============================================
-- Descripción: Estructura básica para integración con HL7 FHIR R4
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Estándar: HL7 FHIR R4 (v4.0.1)
-- Referencias: https://www.hl7.org/fhir/
-- Nota: FHIR es el estándar moderno de interoperabilidad en salud

-- ============================================
-- 1. TABLA: FHIR ENDPOINTS
-- ============================================

CREATE TABLE IF NOT EXISTS public.fhir_endpoints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identificación
  name TEXT NOT NULL,
  description TEXT,

  -- URL del endpoint
  base_url TEXT NOT NULL, -- Base URL del servidor FHIR
  endpoint_url TEXT NOT NULL, -- URL completa del endpoint
  fhir_version TEXT DEFAULT 'R4', -- R4, R5, STU3, etc.

  -- Tipo de endpoint
  connection_type TEXT CHECK (connection_type IN (
    'hl7-fhir-rest', -- REST API
    'hl7-fhir-msg', -- Messaging
    'hl7-v2-mllp', -- HL7 v2 over MLLP
    'direct-project' -- Direct Protocol
  )) DEFAULT 'hl7-fhir-rest',

  -- Autenticación
  auth_type TEXT CHECK (auth_type IN (
    'none', 'basic', 'bearer', 'oauth2', 'smart-on-fhir'
  )) DEFAULT 'oauth2',
  auth_credentials JSONB, -- {username, password} o {client_id, client_secret, token_url}

  -- Configuración
  supports_read BOOLEAN DEFAULT true,
  supports_write BOOLEAN DEFAULT false,
  supports_search BOOLEAN DEFAULT true,
  supported_resources TEXT[], -- ['Medication', 'MedicationRequest', 'Patient']

  -- Organización asociada
  organization_name TEXT,
  organization_identifier TEXT,

  -- Estado
  is_active BOOLEAN DEFAULT true,
  last_tested TIMESTAMP WITH TIME ZONE,
  last_test_status TEXT, -- 'success', 'failed', 'unreachable'
  last_error TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_fhir_endpoints_active ON public.fhir_endpoints(is_active) WHERE is_active = true;

COMMENT ON TABLE public.fhir_endpoints IS 'Configuración de endpoints FHIR externos para interoperabilidad';
COMMENT ON COLUMN public.fhir_endpoints.fhir_version IS 'Versión FHIR: R4 (recomendado), R5, STU3, DSTU2';

-- ============================================
-- 2. TABLA: FHIR RESOURCE MAPPINGS
-- ============================================

CREATE TABLE IF NOT EXISTS public.fhir_resource_mappings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Recurso FHIR
  resource_type TEXT NOT NULL, -- 'Medication', 'MedicationRequest', 'Patient', etc.
  resource_profile TEXT, -- URL del perfil (ej: US Core, IPS)

  -- Mapeo interno
  internal_table TEXT NOT NULL, -- Tabla interna (ej: 'medication_catalog')
  internal_id_column TEXT DEFAULT 'id',

  -- Mapeo de campos (JSONB con estructura de mapeo)
  field_mappings JSONB NOT NULL, -- {
  --   "id": "id",
  --   "code.coding[0].code": "codigo_atc",
  --   "code.text": "nombre",
  --   "status": "is_active ? 'active' : 'inactive'"
  -- }

  -- Transformaciones
  custom_transformations JSONB, -- Funciones custom para transformar datos

  -- Estado
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_fhir_mappings_resource ON public.fhir_resource_mappings(resource_type);
CREATE INDEX idx_fhir_mappings_table ON public.fhir_resource_mappings(internal_table);

COMMENT ON TABLE public.fhir_resource_mappings IS 'Mapeo entre datos internos y recursos FHIR';

-- ============================================
-- 3. TABLA: FHIR TRANSACTIONS LOG
-- ============================================

CREATE TABLE IF NOT EXISTS public.fhir_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Endpoint
  endpoint_id UUID REFERENCES public.fhir_endpoints(id),

  -- Tipo de transacción
  transaction_type TEXT CHECK (transaction_type IN (
    'read', 'vread', 'update', 'patch', 'delete', 'create',
    'search', 'history', 'batch', 'transaction'
  )) NOT NULL,

  -- Recurso
  resource_type TEXT NOT NULL, -- 'Medication', 'Patient', etc.
  resource_id TEXT, -- ID del recurso FHIR
  internal_id UUID, -- ID interno en nuestra base de datos

  -- Request
  request_method TEXT, -- GET, POST, PUT, DELETE
  request_url TEXT,
  request_headers JSONB,
  request_body JSONB, -- Recurso FHIR enviado

  -- Response
  response_status INTEGER, -- 200, 201, 400, 404, 500, etc.
  response_headers JSONB,
  response_body JSONB, -- Recurso FHIR recibido
  response_time_ms INTEGER,

  -- Usuario
  initiated_by UUID REFERENCES public.users_profiles(id),

  -- Errores
  has_error BOOLEAN DEFAULT false,
  error_message TEXT,
  error_details JSONB,

  -- Timestamp
  transaction_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_fhir_transactions_endpoint ON public.fhir_transactions(endpoint_id);
CREATE INDEX idx_fhir_transactions_type ON public.fhir_transactions(transaction_type);
CREATE INDEX idx_fhir_transactions_resource ON public.fhir_transactions(resource_type);
CREATE INDEX idx_fhir_transactions_timestamp ON public.fhir_transactions(transaction_timestamp DESC);
CREATE INDEX idx_fhir_transactions_error ON public.fhir_transactions(has_error) WHERE has_error = true;

COMMENT ON TABLE public.fhir_transactions IS 'Log de todas las transacciones FHIR para auditoría y debugging';

-- ============================================
-- 4. TABLA: FHIR IDENTIFIERS
-- ============================================

CREATE TABLE IF NOT EXISTS public.fhir_identifiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- ID interno
  internal_table TEXT NOT NULL,
  internal_id UUID NOT NULL,

  -- ID FHIR
  fhir_resource_type TEXT NOT NULL,
  fhir_resource_id TEXT NOT NULL,
  fhir_identifier_system TEXT, -- URL del sistema (ej: http://hospital.org/medication-id)
  fhir_identifier_value TEXT, -- Valor del identifier

  -- Endpoint
  endpoint_id UUID REFERENCES public.fhir_endpoints(id),

  -- Versionado
  fhir_version_id TEXT, -- Para versionado de recursos
  last_synced_at TIMESTAMP WITH TIME ZONE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(internal_table, internal_id, endpoint_id)
);

CREATE INDEX idx_fhir_identifiers_internal ON public.fhir_identifiers(internal_table, internal_id);
CREATE INDEX idx_fhir_identifiers_fhir ON public.fhir_identifiers(fhir_resource_type, fhir_resource_id);
CREATE INDEX idx_fhir_identifiers_endpoint ON public.fhir_identifiers(endpoint_id);

COMMENT ON TABLE public.fhir_identifiers IS 'Mapeo entre IDs internos e IDs de recursos FHIR en sistemas externos';

-- ============================================
-- 5. FUNCIÓN: CONVERTIR MEDICATION A FHIR
-- ============================================

CREATE OR REPLACE FUNCTION medication_to_fhir(p_medication_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_medication record;
  v_fhir_resource JSONB;
  v_ingredients JSONB;
BEGIN
  -- Obtener medicamento
  SELECT * INTO v_medication
  FROM public.medication_catalog
  WHERE id = p_medication_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Medication % no encontrado', p_medication_id;
  END IF;

  -- Obtener ingredientes activos
  SELECT jsonb_agg(
    jsonb_build_object(
      'itemCodeableConcept', jsonb_build_object(
        'coding', jsonb_build_array(
          jsonb_build_object(
            'system', 'http://www.nlm.nih.gov/research/umls/rxnorm',
            'code', ai.rxcui,
            'display', ai.name
          )
        ),
        'text', ai.name
      ),
      'strength', jsonb_build_object(
        'numerator', jsonb_build_object(
          'value', mai.strength,
          'unit', mai.strength_unit,
          'system', 'http://unitsofmeasure.org',
          'code', mai.strength_unit
        )
      )
    )
  )
  INTO v_ingredients
  FROM public.medication_active_ingredients mai
  JOIN public.active_ingredients ai ON mai.active_ingredient_id = ai.id
  WHERE mai.medication_catalog_id = p_medication_id;

  -- Construir recurso FHIR Medication (R4)
  v_fhir_resource := jsonb_build_object(
    'resourceType', 'Medication',
    'id', v_medication.id,
    'meta', jsonb_build_object(
      'versionId', '1',
      'lastUpdated', v_medication.updated_at
    ),
    'identifier', jsonb_build_array(
      jsonb_build_object(
        'system', 'http://sigimed.com/medication-id',
        'value', v_medication.id
      )
    ),
    'code', jsonb_build_object(
      'coding', jsonb_build_array(
        jsonb_build_object(
          'system', 'http://www.whocc.no/atc',
          'code', v_medication.codigo_atc,
          'display', v_medication.nombre
        )
      ),
      'text', v_medication.nombre
    ),
    'status', CASE WHEN v_medication.is_active THEN 'active' ELSE 'inactive' END,
    'manufacturer', jsonb_build_object(
      'display', v_medication.laboratorio
    ),
    'form', jsonb_build_object(
      'coding', jsonb_build_array(
        jsonb_build_object(
          'system', 'http://snomed.info/sct',
          'display', v_medication.forma_farmaceutica
        )
      ),
      'text', v_medication.forma_farmaceutica
    ),
    'ingredient', COALESCE(v_ingredients, '[]'::JSONB)
  );

  RETURN v_fhir_resource;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION medication_to_fhir IS 'Convierte un medicamento interno a recurso FHIR Medication R4';

-- ============================================
-- 6. FUNCIÓN: CONVERTIR BATCH A FHIR MEDICATION
-- ============================================

CREATE OR REPLACE FUNCTION batch_to_fhir_medication(p_batch_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_batch record;
  v_fhir_resource JSONB;
BEGIN
  -- Obtener batch con medicamento
  SELECT b.*, m.nombre, m.codigo_atc, m.laboratorio
  INTO v_batch
  FROM public.batches b
  JOIN public.medication_catalog m ON b.medication_catalog_id = m.id
  WHERE b.id = p_batch_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Batch % no encontrado', p_batch_id;
  END IF;

  -- Primero obtener el recurso base del medicamento
  v_fhir_resource := medication_to_fhir(v_batch.medication_catalog_id);

  -- Agregar información del lote
  v_fhir_resource := v_fhir_resource || jsonb_build_object(
    'batch', jsonb_build_object(
      'lotNumber', v_batch.numero_lote,
      'expirationDate', v_batch.fecha_caducidad
    )
  );

  RETURN v_fhir_resource;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION batch_to_fhir_medication IS 'Convierte un lote a recurso FHIR Medication con información de batch';

-- ============================================
-- 7. FUNCIÓN: CONVERTIR LOCATION A FHIR
-- ============================================

CREATE OR REPLACE FUNCTION location_to_fhir(p_location_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_location record;
  v_fhir_resource JSONB;
BEGIN
  SELECT * INTO v_location
  FROM public.ubicaciones_almacen
  WHERE id = p_location_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Location % no encontrada', p_location_id;
  END IF;

  v_fhir_resource := jsonb_build_object(
    'resourceType', 'Location',
    'id', v_location.id,
    'meta', jsonb_build_object(
      'lastUpdated', v_location.updated_at
    ),
    'identifier', jsonb_build_array(
      jsonb_build_object(
        'system', 'http://sigimed.com/location-id',
        'value', v_location.codigo
      )
    ),
    'status', CASE WHEN v_location.is_active THEN 'active' ELSE 'inactive' END,
    'name', COALESCE(v_location.nombre, v_location.codigo),
    'description', v_location.observaciones,
    'mode', 'instance',
    'type', jsonb_build_array(
      jsonb_build_object(
        'coding', jsonb_build_array(
          jsonb_build_object(
            'system', 'http://terminology.hl7.org/CodeSystem/v3-RoleCode',
            'code', 'PHARM',
            'display', 'Pharmacy'
          )
        )
      )
    ),
    'physicalType', jsonb_build_object(
      'coding', jsonb_build_array(
        jsonb_build_object(
          'system', 'http://terminology.hl7.org/CodeSystem/location-physical-type',
          'code', CASE v_location.tipo
            WHEN 'ambiente' THEN 'wa' -- Ward/Area
            WHEN 'refrigerado' THEN 'ro' -- Room
            WHEN 'congelado' THEN 'ro'
            ELSE 'wa'
          END,
          'display', v_location.tipo
        )
      )
    )
  );

  -- Agregar temperatura si aplica
  IF v_location.temperatura_min IS NOT NULL OR v_location.temperatura_max IS NOT NULL THEN
    v_fhir_resource := v_fhir_resource || jsonb_build_object(
      'extension', jsonb_build_array(
        jsonb_build_object(
          'url', 'http://sigimed.com/fhir/StructureDefinition/temperature-range',
          'valueRange', jsonb_build_object(
            'low', jsonb_build_object(
              'value', v_location.temperatura_min,
              'unit', 'Celsius',
              'system', 'http://unitsofmeasure.org',
              'code', 'Cel'
            ),
            'high', jsonb_build_object(
              'value', v_location.temperatura_max,
              'unit', 'Celsius',
              'system', 'http://unitsofmeasure.org',
              'code', 'Cel'
            )
          )
        )
      )
    );
  END IF;

  RETURN v_fhir_resource;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION location_to_fhir IS 'Convierte una ubicación de almacén a recurso FHIR Location R4';

-- ============================================
-- 8. FUNCIÓN: REGISTRAR TRANSACCIÓN FHIR
-- ============================================

CREATE OR REPLACE FUNCTION log_fhir_transaction(
  p_endpoint_id UUID,
  p_transaction_type TEXT,
  p_resource_type TEXT,
  p_request_method TEXT,
  p_request_url TEXT,
  p_request_body JSONB,
  p_response_status INTEGER,
  p_response_body JSONB,
  p_user_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_transaction_id UUID;
  v_has_error BOOLEAN;
BEGIN
  -- Determinar si hay error
  v_has_error := (p_response_status >= 400);

  INSERT INTO public.fhir_transactions (
    endpoint_id,
    transaction_type,
    resource_type,
    request_method,
    request_url,
    request_body,
    response_status,
    response_body,
    initiated_by,
    has_error,
    error_message
  ) VALUES (
    p_endpoint_id,
    p_transaction_type,
    p_resource_type,
    p_request_method,
    p_request_url,
    p_request_body,
    p_response_status,
    p_response_body,
    p_user_id,
    v_has_error,
    CASE WHEN v_has_error THEN p_response_body->>'message' END
  )
  RETURNING id INTO v_transaction_id;

  RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_fhir_transaction IS 'Registra una transacción FHIR para auditoría';

-- ============================================
-- 9. FUNCIÓN: BUSCAR RECURSO FHIR POR ID INTERNO
-- ============================================

CREATE OR REPLACE FUNCTION get_fhir_resource(
  p_internal_table TEXT,
  p_internal_id UUID,
  p_resource_type TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_fhir_resource JSONB;
BEGIN
  -- Determinar tipo de recurso si no se especifica
  IF p_resource_type IS NULL THEN
    p_resource_type := CASE p_internal_table
      WHEN 'medication_catalog' THEN 'Medication'
      WHEN 'batches' THEN 'Medication'
      WHEN 'ubicaciones_almacen' THEN 'Location'
      ELSE NULL
    END;
  END IF;

  IF p_resource_type IS NULL THEN
    RAISE EXCEPTION 'No se puede determinar el tipo de recurso FHIR para tabla %', p_internal_table;
  END IF;

  -- Llamar a función específica según tipo
  CASE p_resource_type
    WHEN 'Medication' THEN
      IF p_internal_table = 'batches' THEN
        v_fhir_resource := batch_to_fhir_medication(p_internal_id);
      ELSE
        v_fhir_resource := medication_to_fhir(p_internal_id);
      END IF;
    WHEN 'Location' THEN
      v_fhir_resource := location_to_fhir(p_internal_id);
    ELSE
      RAISE EXCEPTION 'Conversión a FHIR no implementada para tipo %', p_resource_type;
  END CASE;

  RETURN v_fhir_resource;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_fhir_resource IS 'Obtiene un recurso FHIR a partir de un ID interno';

-- ============================================
-- 10. TRIGGER: ACTUALIZAR UPDATED_AT
-- ============================================

CREATE TRIGGER trigger_update_fhir_endpoints_updated_at
  BEFORE UPDATE ON public.fhir_endpoints
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_fhir_mappings_updated_at
  BEFORE UPDATE ON public.fhir_resource_mappings
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- ============================================
-- 11. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.fhir_endpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fhir_resource_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fhir_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fhir_identifiers ENABLE ROW LEVEL SECURITY;

-- Solo admin puede ver/modificar endpoints
CREATE POLICY "Solo admin puede ver endpoints FHIR"
  ON public.fhir_endpoints FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Solo super admin puede modificar endpoints"
  ON public.fhir_endpoints FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- Transacciones - usuarios ven las suyas
CREATE POLICY "Usuarios ven transacciones FHIR de su centro"
  ON public.fhir_transactions FOR SELECT
  USING (
    initiated_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

-- ============================================
-- 12. VISTAS ÚTILES
-- ============================================

-- Vista: Resumen de transacciones FHIR
CREATE OR REPLACE VIEW v_fhir_transactions_summary AS
SELECT
  DATE(transaction_timestamp) AS transaction_date,
  endpoint_id,
  e.name AS endpoint_name,
  resource_type,
  transaction_type,
  COUNT(*) AS total_transactions,
  COUNT(*) FILTER (WHERE has_error = false) AS successful,
  COUNT(*) FILTER (WHERE has_error = true) AS failed,
  AVG(response_time_ms) AS avg_response_time_ms
FROM public.fhir_transactions ft
JOIN public.fhir_endpoints e ON ft.endpoint_id = e.id
GROUP BY DATE(transaction_timestamp), endpoint_id, e.name, resource_type, transaction_type
ORDER BY transaction_date DESC, endpoint_name;

COMMENT ON VIEW v_fhir_transactions_summary IS 'Resumen diario de transacciones FHIR por endpoint y tipo de recurso';

-- ============================================
-- 13. DATOS DE EJEMPLO
-- ============================================

-- Insertar endpoint FHIR de prueba
INSERT INTO public.fhir_endpoints (
  name,
  description,
  base_url,
  endpoint_url,
  fhir_version,
  connection_type,
  auth_type,
  supported_resources,
  is_active
) VALUES (
  'HAPI FHIR Test Server',
  'Servidor de prueba público HAPI FHIR',
  'http://hapi.fhir.org/baseR4',
  'http://hapi.fhir.org/baseR4',
  'R4',
  'hl7-fhir-rest',
  'none',
  ARRAY['Medication', 'MedicationRequest', 'Location', 'Organization'],
  false -- Desactivado por defecto
) ON CONFLICT DO NOTHING;

-- ============================================
-- FIN DE MIGRACIÓN 15
-- ============================================

SELECT 'Migración 15 completada. Sistema HL7 FHIR Integration implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('fhir_endpoints', 'fhir_resource_mappings', 'fhir_transactions', 'fhir_identifiers');
