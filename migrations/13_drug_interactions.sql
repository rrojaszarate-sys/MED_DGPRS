-- ============================================
-- MIGRACIÓN 13: DRUG INTERACTIONS & CLINICAL DECISION SUPPORT
-- ============================================
-- Descripción: Sistema de verificación de interacciones medicamentosas y soporte de decisiones clínicas
-- Fecha: 2025-11-18
-- Autor: Sistema Automático
-- Estándar: FDA Drug Interactions, DrugBank, Lexicomp
-- Referencias: https://www.fda.gov/drugs/drug-interactions-labeling
-- Nota: Sistema crítico para seguridad del paciente

-- ============================================
-- 1. TABLA: PRINCIPIOS ACTIVOS (ACTIVE INGREDIENTS)
-- ============================================

CREATE TABLE IF NOT EXISTS public.active_ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identificación
  name TEXT NOT NULL, -- Nombre genérico (ej: "Paracetamol")
  scientific_name TEXT, -- Nombre científico (ej: "N-acetyl-p-aminophenol")

  -- Códigos internacionales
  rxcui TEXT, -- RxNorm Concept Unique Identifier (FDA)
  atc_code TEXT, -- Anatomical Therapeutic Chemical (WHO)
  unii TEXT, -- Unique Ingredient Identifier (FDA)
  cas_number TEXT, -- Chemical Abstracts Service
  drugbank_id TEXT, -- DrugBank ID (ej: DB00316)

  -- Clasificación
  therapeutic_class TEXT, -- Clase terapéutica
  pharmacological_class TEXT, -- Clase farmacológica
  chemical_class TEXT, -- Clase química

  -- Metadatos
  description TEXT,
  mechanism_of_action TEXT,

  -- Control
  is_controlled_substance BOOLEAN DEFAULT false,
  dea_schedule TEXT, -- I, II, III, IV, V (si aplica)

  -- Estado
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_active_ingredients_name ON public.active_ingredients(name);
CREATE INDEX idx_active_ingredients_rxcui ON public.active_ingredients(rxcui);
CREATE INDEX idx_active_ingredients_atc ON public.active_ingredients(atc_code);
CREATE INDEX idx_active_ingredients_drugbank ON public.active_ingredients(drugbank_id);

COMMENT ON TABLE public.active_ingredients IS 'Catálogo de principios activos farmacológicos con códigos internacionales';
COMMENT ON COLUMN public.active_ingredients.rxcui IS 'RxNorm CUI - estándar FDA/NIH para medicamentos';
COMMENT ON COLUMN public.active_ingredients.atc_code IS 'Código ATC de la OMS - clasificación anatómica, terapéutica y química';

-- ============================================
-- 2. TABLA: RELACIÓN MEDICAMENTO - PRINCIPIO ACTIVO
-- ============================================

CREATE TABLE IF NOT EXISTS public.medication_active_ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_catalog_id UUID REFERENCES public.medication_catalog(id) ON DELETE CASCADE,
  active_ingredient_id UUID REFERENCES public.active_ingredients(id) ON DELETE CASCADE,

  -- Concentración
  strength DECIMAL(10, 4), -- Cantidad del principio activo
  strength_unit TEXT, -- mg, g, ml, %, etc.

  -- Orden (para combinaciones)
  is_primary BOOLEAN DEFAULT true, -- ¿Es el principio activo principal?
  display_order INTEGER DEFAULT 1,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(medication_catalog_id, active_ingredient_id)
);

CREATE INDEX idx_medication_ingredients_medication ON public.medication_active_ingredients(medication_catalog_id);
CREATE INDEX idx_medication_ingredients_ingredient ON public.medication_active_ingredients(active_ingredient_id);

COMMENT ON TABLE public.medication_active_ingredients IS 'Relación N:M entre medicamentos y principios activos (para combinaciones)';

-- ============================================
-- 3. TABLA: INTERACCIONES MEDICAMENTOSAS
-- ============================================

CREATE TABLE IF NOT EXISTS public.drug_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Medicamentos/Principios involucrados
  ingredient_a_id UUID REFERENCES public.active_ingredients(id) ON DELETE CASCADE,
  ingredient_b_id UUID REFERENCES public.active_ingredients(id) ON DELETE CASCADE,

  -- Tipo de interacción
  interaction_type TEXT CHECK (interaction_type IN (
    'drug-drug', -- Medicamento-Medicamento
    'drug-food', -- Medicamento-Alimento
    'drug-alcohol', -- Medicamento-Alcohol
    'drug-disease', -- Medicamento-Enfermedad
    'drug-lab' -- Medicamento-Prueba de laboratorio
  )) DEFAULT 'drug-drug',

  -- Severidad (según FDA/Lexicomp)
  severity TEXT CHECK (severity IN (
    'contraindicated', -- Contraindicado - NO usar juntos
    'major', -- Mayor - puede causar daño serio
    'moderate', -- Moderado - monitorear
    'minor' -- Menor - usualmente no clínicamente significativo
  )) NOT NULL,

  -- Nivel de evidencia
  evidence_level TEXT CHECK (evidence_level IN (
    'established', -- Establecido - evidencia fuerte
    'probable', -- Probable - evidencia moderada
    'suspected', -- Sospechado - evidencia limitada
    'theoretical' -- Teórico - basado en farmacología
  )),

  -- Descripción
  description TEXT NOT NULL, -- Descripción de la interacción
  clinical_effects TEXT, -- Efectos clínicos esperados
  mechanism TEXT, -- Mecanismo farmacológico

  -- Manejo clínico
  management TEXT, -- Recomendaciones de manejo
  alternative_drugs TEXT, -- Medicamentos alternativos sugeridos

  -- Onset (tiempo de aparición)
  onset TEXT CHECK (onset IN ('rapid', 'delayed', 'unspecified')),

  -- Documentation level
  documentation TEXT CHECK (documentation IN ('excellent', 'good', 'fair', 'poor')),

  -- Referencias
  references TEXT[], -- Referencias bibliográficas
  source TEXT, -- Fuente: 'DrugBank', 'Lexicomp', 'Micromedex', 'FDA', etc.
  source_id TEXT, -- ID en la fuente externa

  -- Metadatos
  last_reviewed_date DATE,
  is_active BOOLEAN DEFAULT true,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT different_ingredients CHECK (ingredient_a_id != ingredient_b_id)
);

CREATE INDEX idx_drug_interactions_ingredient_a ON public.drug_interactions(ingredient_a_id);
CREATE INDEX idx_drug_interactions_ingredient_b ON public.drug_interactions(ingredient_b_id);
CREATE INDEX idx_drug_interactions_severity ON public.drug_interactions(severity);
CREATE INDEX idx_drug_interactions_type ON public.drug_interactions(interaction_type);
CREATE INDEX idx_drug_interactions_active ON public.drug_interactions(is_active) WHERE is_active = true;

-- Índice compuesto para búsqueda bidireccional
CREATE INDEX idx_drug_interactions_pair ON public.drug_interactions(
  LEAST(ingredient_a_id::TEXT, ingredient_b_id::TEXT),
  GREATEST(ingredient_a_id::TEXT, ingredient_b_id::TEXT)
);

COMMENT ON TABLE public.drug_interactions IS 'Base de datos de interacciones medicamentosas con severidad y manejo clínico';
COMMENT ON COLUMN public.drug_interactions.severity IS 'contraindicated=NO usar, major=peligro serio, moderate=monitorear, minor=bajo riesgo';

-- ============================================
-- 4. TABLA: CONTRAINDICACIONES POR CONDICIÓN
-- ============================================

CREATE TABLE IF NOT EXISTS public.drug_contraindications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  active_ingredient_id UUID REFERENCES public.active_ingredients(id) ON DELETE CASCADE,

  -- Condición médica
  condition_name TEXT NOT NULL, -- Nombre de la condición (ej: "Insuficiencia renal")
  condition_code TEXT, -- Código ICD-10 o SNOMED

  -- Tipo de contraindicación
  contraindication_type TEXT CHECK (contraindication_type IN (
    'absolute', -- Contraindicación absoluta - NUNCA usar
    'relative', -- Contraindicación relativa - usar con precaución
    'pregnancy', -- Embarazo
    'breastfeeding', -- Lactancia
    'pediatric', -- Pediátrico
    'geriatric' -- Geriátrico
  )) NOT NULL,

  -- Severidad
  severity TEXT CHECK (severity IN ('high', 'moderate', 'low')) DEFAULT 'high',

  -- Descripción
  description TEXT NOT NULL,
  clinical_guidance TEXT, -- Guía clínica
  alternatives TEXT, -- Alternativas sugeridas

  -- Referencias
  references TEXT[],
  source TEXT,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_drug_contraindications_ingredient ON public.drug_contraindications(active_ingredient_id);
CREATE INDEX idx_drug_contraindications_type ON public.drug_contraindications(contraindication_type);
CREATE INDEX idx_drug_contraindications_severity ON public.drug_contraindications(severity);

COMMENT ON TABLE public.drug_contraindications IS 'Contraindicaciones de medicamentos por condiciones médicas y poblaciones especiales';

-- ============================================
-- 5. TABLA: ALERTAS DE INTERACCIONES (LOG)
-- ============================================

CREATE TABLE IF NOT EXISTS public.interaction_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Contexto
  alert_type TEXT CHECK (alert_type IN (
    'drug-drug',
    'drug-disease',
    'duplicate-therapy',
    'allergy',
    'dose-range',
    'renal-adjustment',
    'hepatic-adjustment'
  )) NOT NULL,

  severity TEXT CHECK (severity IN ('critical', 'major', 'moderate', 'minor')) NOT NULL,

  -- Medicamentos involucrados
  medication_ids UUID[], -- Array de IDs de medicamentos
  active_ingredient_ids UUID[], -- Array de IDs de principios activos
  interaction_id UUID REFERENCES public.drug_interactions(id),

  -- Mensaje
  alert_message TEXT NOT NULL,
  clinical_recommendation TEXT,

  -- Paciente (si aplica - futuro)
  patient_id UUID, -- Referencia a paciente (tabla a crear)

  -- Usuario y acción
  alerted_user_id UUID REFERENCES public.users_profiles(id),
  alert_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Respuesta del usuario
  user_response TEXT CHECK (user_response IN ('acknowledged', 'overridden', 'cancelled', 'pending')) DEFAULT 'pending',
  override_reason TEXT, -- Si fue sobreescrito, razón
  responded_at TIMESTAMP WITH TIME ZONE,

  -- Metadatos
  metadata JSONB, -- Contexto adicional

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_interaction_alerts_timestamp ON public.interaction_alerts(alert_timestamp DESC);
CREATE INDEX idx_interaction_alerts_user ON public.interaction_alerts(alerted_user_id);
CREATE INDEX idx_interaction_alerts_severity ON public.interaction_alerts(severity);
CREATE INDEX idx_interaction_alerts_response ON public.interaction_alerts(user_response);

COMMENT ON TABLE public.interaction_alerts IS 'Log de alertas de interacciones mostradas a usuarios - para auditoría y mejora continua';

-- ============================================
-- 6. FUNCIÓN: VERIFICAR INTERACCIONES ENTRE MEDICAMENTOS
-- ============================================

CREATE OR REPLACE FUNCTION check_drug_interactions(
  p_medication_ids UUID[]
)
RETURNS TABLE (
  interaction_id UUID,
  severity TEXT,
  ingredient_a_name TEXT,
  ingredient_b_name TEXT,
  description TEXT,
  clinical_effects TEXT,
  management TEXT
) AS $$
BEGIN
  RETURN QUERY
  WITH medication_ingredients AS (
    -- Obtener todos los principios activos de los medicamentos
    SELECT DISTINCT mai.active_ingredient_id
    FROM public.medication_active_ingredients mai
    WHERE mai.medication_catalog_id = ANY(p_medication_ids)
  )
  SELECT
    di.id AS interaction_id,
    di.severity,
    ai_a.name AS ingredient_a_name,
    ai_b.name AS ingredient_b_name,
    di.description,
    di.clinical_effects,
    di.management
  FROM public.drug_interactions di
  JOIN public.active_ingredients ai_a ON di.ingredient_a_id = ai_a.id
  JOIN public.active_ingredients ai_b ON di.ingredient_b_id = ai_b.id
  WHERE di.is_active = true
  AND (
    (di.ingredient_a_id IN (SELECT active_ingredient_id FROM medication_ingredients)
     AND di.ingredient_b_id IN (SELECT active_ingredient_id FROM medication_ingredients))
  )
  ORDER BY
    CASE di.severity
      WHEN 'contraindicated' THEN 1
      WHEN 'major' THEN 2
      WHEN 'moderate' THEN 3
      WHEN 'minor' THEN 4
    END,
    ai_a.name;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_drug_interactions IS 'Verifica interacciones entre una lista de medicamentos - retorna interacciones ordenadas por severidad';

-- ============================================
-- 7. FUNCIÓN: VERIFICAR CONTRAINDICACIONES
-- ============================================

CREATE OR REPLACE FUNCTION check_drug_contraindications(
  p_medication_id UUID,
  p_patient_conditions TEXT[] DEFAULT NULL
)
RETURNS TABLE (
  contraindication_id UUID,
  ingredient_name TEXT,
  condition_name TEXT,
  contraindication_type TEXT,
  severity TEXT,
  description TEXT,
  clinical_guidance TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    dc.id AS contraindication_id,
    ai.name AS ingredient_name,
    dc.condition_name,
    dc.contraindication_type,
    dc.severity,
    dc.description,
    dc.clinical_guidance
  FROM public.drug_contraindications dc
  JOIN public.active_ingredients ai ON dc.active_ingredient_id = ai.id
  JOIN public.medication_active_ingredients mai ON ai.id = mai.active_ingredient_id
  WHERE mai.medication_catalog_id = p_medication_id
  AND dc.is_active = true
  AND (
    p_patient_conditions IS NULL
    OR dc.condition_name = ANY(p_patient_conditions)
  )
  ORDER BY
    CASE dc.severity
      WHEN 'high' THEN 1
      WHEN 'moderate' THEN 2
      WHEN 'low' THEN 3
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_drug_contraindications IS 'Verifica contraindicaciones de un medicamento para condiciones específicas';

-- ============================================
-- 8. FUNCIÓN: REGISTRAR ALERTA DE INTERACCIÓN
-- ============================================

CREATE OR REPLACE FUNCTION log_interaction_alert(
  p_alert_type TEXT,
  p_severity TEXT,
  p_medication_ids UUID[],
  p_interaction_id UUID,
  p_alert_message TEXT,
  p_user_id UUID
)
RETURNS UUID AS $$
DECLARE
  v_alert_id UUID;
  v_ingredient_ids UUID[];
BEGIN
  -- Obtener principios activos involucrados
  SELECT ARRAY_AGG(DISTINCT mai.active_ingredient_id)
  INTO v_ingredient_ids
  FROM public.medication_active_ingredients mai
  WHERE mai.medication_catalog_id = ANY(p_medication_ids);

  -- Insertar alerta
  INSERT INTO public.interaction_alerts (
    alert_type,
    severity,
    medication_ids,
    active_ingredient_ids,
    interaction_id,
    alert_message,
    alerted_user_id
  ) VALUES (
    p_alert_type,
    p_severity,
    p_medication_ids,
    v_ingredient_ids,
    p_interaction_id,
    p_alert_message,
    p_user_id
  )
  RETURNING id INTO v_alert_id;

  RETURN v_alert_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_interaction_alert IS 'Registra una alerta de interacción para auditoría';

-- ============================================
-- 9. FUNCIÓN: OBTENER ALTERNATIVAS SEGURAS
-- ============================================

CREATE OR REPLACE FUNCTION get_safe_alternatives(
  p_medication_id UUID,
  p_contraindicated_with UUID[] DEFAULT NULL
)
RETURNS TABLE (
  alternative_medication_id UUID,
  medication_name TEXT,
  active_ingredient_name TEXT,
  therapeutic_class TEXT,
  has_interactions BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  WITH target_medication AS (
    -- Obtener clase terapéutica del medicamento original
    SELECT DISTINCT ai.therapeutic_class
    FROM public.medication_active_ingredients mai
    JOIN public.active_ingredients ai ON mai.active_ingredient_id = ai.id
    WHERE mai.medication_catalog_id = p_medication_id
    LIMIT 1
  ),
  alternative_ingredients AS (
    -- Buscar otros principios activos de la misma clase
    SELECT ai.id, ai.name, ai.therapeutic_class
    FROM public.active_ingredients ai
    CROSS JOIN target_medication tm
    WHERE ai.therapeutic_class = tm.therapeutic_class
    AND ai.id NOT IN (
      SELECT mai.active_ingredient_id
      FROM public.medication_active_ingredients mai
      WHERE mai.medication_catalog_id = p_medication_id
    )
    AND ai.is_active = true
  )
  SELECT DISTINCT
    mc.id AS alternative_medication_id,
    mc.nombre AS medication_name,
    ai.name AS active_ingredient_name,
    ai.therapeutic_class,
    EXISTS(
      SELECT 1 FROM public.drug_interactions di
      WHERE (di.ingredient_a_id = ai.id OR di.ingredient_b_id = ai.id)
      AND di.ingredient_a_id IN (
        SELECT mai2.active_ingredient_id
        FROM public.medication_active_ingredients mai2
        WHERE p_contraindicated_with IS NOT NULL
        AND mai2.medication_catalog_id = ANY(p_contraindicated_with)
      )
      AND di.severity IN ('contraindicated', 'major')
    ) AS has_interactions
  FROM alternative_ingredients ai
  JOIN public.medication_active_ingredients mai ON ai.id = mai.active_ingredient_id
  JOIN public.medication_catalog mc ON mai.medication_catalog_id = mc.id
  WHERE mc.is_active = true
  ORDER BY has_interactions, mc.nombre;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_safe_alternatives IS 'Obtiene medicamentos alternativos de la misma clase terapéutica sin interacciones';

-- ============================================
-- 10. TRIGGER: ACTUALIZAR UPDATED_AT
-- ============================================

CREATE TRIGGER trigger_update_active_ingredients_updated_at
  BEFORE UPDATE ON public.active_ingredients
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

CREATE TRIGGER trigger_update_drug_interactions_updated_at
  BEFORE UPDATE ON public.drug_interactions
  FOR EACH ROW
  EXECUTE FUNCTION update_ubicaciones_almacen_updated_at();

-- ============================================
-- 11. ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.active_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medication_active_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drug_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drug_contraindications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interaction_alerts ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura pública (datos médicos de referencia)
CREATE POLICY "Usuarios pueden ver principios activos"
  ON public.active_ingredients FOR SELECT
  USING (true);

CREATE POLICY "Usuarios pueden ver interacciones"
  ON public.drug_interactions FOR SELECT
  USING (is_active = true);

CREATE POLICY "Usuarios pueden ver contraindicaciones"
  ON public.drug_contraindications FOR SELECT
  USING (is_active = true);

-- Solo admin puede modificar datos de referencia
CREATE POLICY "Solo admin puede modificar interacciones"
  ON public.drug_interactions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'pharmacist')
    )
  );

-- Alertas - usuarios ven sus propias alertas
CREATE POLICY "Usuarios ven sus alertas"
  ON public.interaction_alerts FOR SELECT
  USING (
    alerted_user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.users_profiles
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Sistema puede crear alertas"
  ON public.interaction_alerts FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Usuarios pueden responder a sus alertas"
  ON public.interaction_alerts FOR UPDATE
  USING (alerted_user_id = auth.uid());

-- ============================================
-- 12. DATOS DE EJEMPLO
-- ============================================

-- Insertar algunos principios activos comunes
INSERT INTO public.active_ingredients (name, scientific_name, atc_code, therapeutic_class, pharmacological_class) VALUES
  ('Paracetamol', 'N-acetyl-p-aminophenol', 'N02BE01', 'Analgésico', 'Analgésico no opioide'),
  ('Ibuprofeno', 'Ibuprofen', 'M01AE01', 'AINE', 'Antiinflamatorio no esteroideo'),
  ('Amoxicilina', 'Amoxicillin', 'J01CA04', 'Antibiótico', 'Penicilina'),
  ('Warfarina', 'Warfarin', 'B01AA03', 'Anticoagulante', 'Antagonista vitamina K'),
  ('Aspirina', 'Acetylsalicylic acid', 'N02BA01', 'AINE', 'Antiinflamatorio no esteroideo')
ON CONFLICT DO NOTHING;

-- Insertar interacción de ejemplo (Warfarina + Aspirina)
DO $$
DECLARE
  v_warfarin_id UUID;
  v_aspirin_id UUID;
BEGIN
  SELECT id INTO v_warfarin_id FROM public.active_ingredients WHERE name = 'Warfarina' LIMIT 1;
  SELECT id INTO v_aspirin_id FROM public.active_ingredients WHERE name = 'Aspirina' LIMIT 1;

  IF v_warfarin_id IS NOT NULL AND v_aspirin_id IS NOT NULL THEN
    INSERT INTO public.drug_interactions (
      ingredient_a_id,
      ingredient_b_id,
      interaction_type,
      severity,
      evidence_level,
      description,
      clinical_effects,
      mechanism,
      management,
      onset,
      documentation,
      source
    ) VALUES (
      v_warfarin_id,
      v_aspirin_id,
      'drug-drug',
      'major',
      'established',
      'La combinación de warfarina y aspirina aumenta significativamente el riesgo de sangrado.',
      'Sangrado mayor (hemorragia gastrointestinal, intracraneal), incremento del INR',
      'Ambos medicamentos afectan la coagulación por diferentes mecanismos: warfarina inhibe síntesis de factores de coagulación, aspirina inhibe agregación plaquetaria.',
      'Si es necesario usar ambos: Monitorear INR frecuentemente. Usar dosis bajas de aspirina (≤100mg). Vigilar signos de sangrado. Considerar inhibidor de bomba de protones para protección gástrica.',
      'delayed',
      'excellent',
      'FDA, Lexicomp'
    )
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================
-- FIN DE MIGRACIÓN 13
-- ============================================

-- Verificar creación
SELECT 'Migración 13 completada. Sistema de Drug Interactions implementado.' AS mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public'
AND tablename IN ('active_ingredients', 'medication_active_ingredients', 'drug_interactions', 'drug_contraindications', 'interaction_alerts');
