-- ============================================
-- FASE 5: GESTIÓN DOCUMENTAL Y FIRMAS DIGITALES
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Sistema completo de documentos, vales, actas y firmas digitales
-- Tiempo estimado: 90 minutos
-- Ejecutar DESPUÉS de Fase 4

BEGIN;

-- ============================================
-- PARTE 5.1: TABLAS DE DOCUMENTACIÓN
-- ============================================

-- Tabla: vales_entrada (Vales de entrada de medicamentos)
CREATE TABLE IF NOT EXISTS vales_entrada (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_vale TEXT UNIQUE NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES suppliers(id),
  contract_id UUID REFERENCES contracts(id),
  fecha_entrada DATE DEFAULT CURRENT_DATE,
  numero_factura TEXT,
  numero_remision TEXT,
  recibido_por UUID,
  autorizado_por UUID,
  total_items INTEGER DEFAULT 0,
  monto_total DECIMAL(15,2),
  observaciones TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'autorizado', 'aplicado', 'cancelado')),
  documento_pdf_url TEXT,
  firma_recepcion TEXT,
  firma_autorizacion TEXT,
  fecha_firma_recepcion TIMESTAMPTZ,
  fecha_firma_autorizacion TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_entrada_numero ON vales_entrada(numero_vale);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_center ON vales_entrada(center_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_supplier ON vales_entrada(supplier_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_fecha ON vales_entrada(fecha_entrada DESC);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_estado ON vales_entrada(estado);

COMMENT ON TABLE vales_entrada IS 'Vales de entrada de medicamentos con trazabilidad completa';

-- Tabla: vales_entrada_items (Items de vales de entrada)
CREATE TABLE IF NOT EXISTS vales_entrada_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vale_entrada_id UUID REFERENCES vales_entrada(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  numero_lote TEXT NOT NULL,
  fecha_caducidad DATE NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(15,2),
  subtotal DECIMAL(15,2),
  ubicacion_fisica TEXT,
  temperatura_recepcion DECIMAL(5,2),
  condicion TEXT CHECK (condicion IN ('optima', 'aceptable', 'deficiente', 'rechazada')),
  observaciones TEXT,
  batch_id UUID REFERENCES batches(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_entrada_items_vale ON vales_entrada_items(vale_entrada_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_items_medication ON vales_entrada_items(medication_catalog_id);
CREATE INDEX IF NOT EXISTS idx_vales_entrada_items_lote ON vales_entrada_items(numero_lote);

COMMENT ON TABLE vales_entrada_items IS 'Detalle de items en vales de entrada';

-- Tabla: vales_salida (Vales de salida/dispensación)
CREATE TABLE IF NOT EXISTS vales_salida (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_vale TEXT UNIQUE NOT NULL,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  tipo_salida TEXT NOT NULL CHECK (tipo_salida IN (
    'dispensacion', 'transferencia', 'devolucion', 'merma', 'baja'
  )),
  destino_centro_id UUID REFERENCES health_centers(id),
  destino_descripcion TEXT,
  solicitado_por TEXT,
  despachado_por UUID,
  autorizado_por UUID,
  fecha_salida DATE DEFAULT CURRENT_DATE,
  total_items INTEGER DEFAULT 0,
  observaciones TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'autorizado', 'despachado', 'recibido', 'cancelado')),
  documento_pdf_url TEXT,
  firma_despacho TEXT,
  firma_autorizacion TEXT,
  firma_recepcion TEXT,
  fecha_firma_despacho TIMESTAMPTZ,
  fecha_firma_autorizacion TIMESTAMPTZ,
  fecha_firma_recepcion TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_salida_numero ON vales_salida(numero_vale);
CREATE INDEX IF NOT EXISTS idx_vales_salida_center ON vales_salida(center_id);
CREATE INDEX IF NOT EXISTS idx_vales_salida_tipo ON vales_salida(tipo_salida);
CREATE INDEX IF NOT EXISTS idx_vales_salida_fecha ON vales_salida(fecha_salida DESC);
CREATE INDEX IF NOT EXISTS idx_vales_salida_estado ON vales_salida(estado);

COMMENT ON TABLE vales_salida IS 'Vales de salida, dispensación y transferencia de medicamentos';

-- Tabla: vales_salida_items (Items de vales de salida)
CREATE TABLE IF NOT EXISTS vales_salida_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vale_salida_id UUID REFERENCES vales_salida(id) ON DELETE CASCADE,
  batch_id UUID REFERENCES batches(id),
  medication_id UUID REFERENCES medications(id),
  numero_lote TEXT NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  fecha_caducidad DATE,
  observaciones TEXT,
  movement_id UUID REFERENCES batch_movements(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vales_salida_items_vale ON vales_salida_items(vale_salida_id);
CREATE INDEX IF NOT EXISTS idx_vales_salida_items_batch ON vales_salida_items(batch_id);
CREATE INDEX IF NOT EXISTS idx_vales_salida_items_medication ON vales_salida_items(medication_id);

COMMENT ON TABLE vales_salida_items IS 'Detalle de items en vales de salida';

-- Tabla: actas_entrega (Actas de entrega-recepción)
CREATE TABLE IF NOT EXISTS actas_entrega (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_acta TEXT UNIQUE NOT NULL,
  tipo_acta TEXT CHECK (tipo_acta IN ('transferencia', 'donacion', 'devolucion', 'entrega_contrato')),
  center_origen_id UUID REFERENCES health_centers(id),
  center_destino_id UUID REFERENCES health_centers(id),
  fecha_acta DATE DEFAULT CURRENT_DATE,
  entrega TEXT NOT NULL, -- Nombre de quien entrega
  recibe TEXT NOT NULL, -- Nombre de quien recibe
  testigo_1 TEXT,
  testigo_2 TEXT,
  motivo TEXT NOT NULL,
  total_items INTEGER DEFAULT 0,
  valor_estimado DECIMAL(15,2),
  observaciones TEXT,
  estado TEXT DEFAULT 'borrador' CHECK (estado IN ('borrador', 'firmada', 'cancelada')),
  documento_pdf_url TEXT,
  firma_entrega TEXT,
  firma_recibe TEXT,
  firma_testigo_1 TEXT,
  firma_testigo_2 TEXT,
  fecha_firma_entrega TIMESTAMPTZ,
  fecha_firma_recibe TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_actas_entrega_numero ON actas_entrega(numero_acta);
CREATE INDEX IF NOT EXISTS idx_actas_entrega_origen ON actas_entrega(center_origen_id);
CREATE INDEX IF NOT EXISTS idx_actas_entrega_destino ON actas_entrega(center_destino_id);
CREATE INDEX IF NOT EXISTS idx_actas_entrega_fecha ON actas_entrega(fecha_acta DESC);

COMMENT ON TABLE actas_entrega IS 'Actas de entrega-recepción formales con firmas';

-- Tabla: actas_entrega_items (Items de actas)
CREATE TABLE IF NOT EXISTS actas_entrega_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acta_id UUID REFERENCES actas_entrega(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  numero_lote TEXT,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  fecha_caducidad DATE,
  valor_unitario DECIMAL(15,2),
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_actas_entrega_items_acta ON actas_entrega_items(acta_id);

COMMENT ON TABLE actas_entrega_items IS 'Detalle de medicamentos en actas de entrega';

-- Tabla: firmas_digitales (Registro de firmas)
CREATE TABLE IF NOT EXISTS firmas_digitales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  documento_tipo TEXT NOT NULL CHECK (documento_tipo IN (
    'vale_entrada', 'vale_salida', 'acta_entrega', 'contrato', 'inspeccion'
  )),
  documento_id UUID NOT NULL,
  tipo_firma TEXT CHECK (tipo_firma IN ('recepcion', 'autorizacion', 'despacho', 'testigo', 'aprobacion')),
  firma_data TEXT NOT NULL, -- Firma en base64 o hash
  ip_address INET,
  user_agent TEXT,
  geolocalizacion JSONB,
  certificado_digital TEXT,
  timestamp_firma TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_firmas_digitales_user ON firmas_digitales(user_id);
CREATE INDEX IF NOT EXISTS idx_firmas_digitales_documento ON firmas_digitales(documento_tipo, documento_id);
CREATE INDEX IF NOT EXISTS idx_firmas_digitales_timestamp ON firmas_digitales(timestamp_firma DESC);

COMMENT ON TABLE firmas_digitales IS 'Registro inmutable de todas las firmas digitales del sistema';
COMMENT ON COLUMN firmas_digitales.firma_data IS 'Datos de la firma (base64, hash, o certificado)';

COMMIT;

-- ============================================
-- PARTE 5.2: FUNCIONES PARA VALES DE ENTRADA
-- ============================================

-- Función: Crear vale de entrada
CREATE OR REPLACE FUNCTION crear_vale_entrada(
  p_numero_vale TEXT,
  p_center_id UUID,
  p_supplier_id UUID,
  p_numero_factura TEXT,
  p_items JSONB,
  p_recibido_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  vale_id UUID
) AS $$
DECLARE
  v_vale_id UUID;
  v_item JSONB;
  v_total_items INTEGER := 0;
  v_monto_total DECIMAL := 0;
BEGIN
  -- Validar que no exista el número de vale
  IF EXISTS (SELECT 1 FROM vales_entrada WHERE numero_vale = p_numero_vale) THEN
    RETURN QUERY SELECT false, 'El número de vale ya existe', NULL::UUID;
    RETURN;
  END IF;

  -- Crear el vale
  INSERT INTO vales_entrada (
    numero_vale,
    center_id,
    supplier_id,
    numero_factura,
    recibido_por,
    estado
  ) VALUES (
    p_numero_vale,
    p_center_id,
    p_supplier_id,
    p_numero_factura,
    p_recibido_por,
    'borrador'
  ) RETURNING id INTO v_vale_id;

  -- Insertar items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    INSERT INTO vales_entrada_items (
      vale_entrada_id,
      medication_catalog_id,
      numero_lote,
      fecha_caducidad,
      cantidad,
      precio_unitario,
      subtotal,
      ubicacion_fisica,
      condicion
    ) VALUES (
      v_vale_id,
      (v_item->>'medication_catalog_id')::UUID,
      v_item->>'numero_lote',
      (v_item->>'fecha_caducidad')::DATE,
      (v_item->>'cantidad')::INTEGER,
      (v_item->>'precio_unitario')::DECIMAL,
      (v_item->>'cantidad')::INTEGER * (v_item->>'precio_unitario')::DECIMAL,
      v_item->>'ubicacion_fisica',
      COALESCE(v_item->>'condicion', 'optima')
    );

    v_total_items := v_total_items + 1;
    v_monto_total := v_monto_total + ((v_item->>'cantidad')::INTEGER * (v_item->>'precio_unitario')::DECIMAL);
  END LOOP;

  -- Actualizar totales
  UPDATE vales_entrada
  SET
    total_items = v_total_items,
    monto_total = v_monto_total
  WHERE id = v_vale_id;

  RETURN QUERY SELECT true, 'Vale de entrada creado exitosamente', v_vale_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_vale_entrada IS 'Crea un vale de entrada con sus items';

-- Función: Aplicar vale de entrada (crear lotes en batches)
CREATE OR REPLACE FUNCTION aplicar_vale_entrada(
  p_vale_id UUID,
  p_autorizado_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  lotes_creados INTEGER
) AS $$
DECLARE
  v_vale RECORD;
  v_item RECORD;
  v_batch_id UUID;
  v_medication_id UUID;
  v_count INTEGER := 0;
BEGIN
  -- Obtener vale
  SELECT * INTO v_vale FROM vales_entrada WHERE id = p_vale_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Vale no encontrado', 0;
    RETURN;
  END IF;

  IF v_vale.estado != 'autorizado' THEN
    RETURN QUERY SELECT false, 'El vale debe estar autorizado para aplicarse', 0;
    RETURN;
  END IF;

  -- Procesar cada item
  FOR v_item IN
    SELECT * FROM vales_entrada_items WHERE vale_entrada_id = p_vale_id
  LOOP
    -- Buscar o crear medicamento en medications
    SELECT id INTO v_medication_id
    FROM medications
    WHERE catalog_id = v_item.medication_catalog_id
      AND center_id = v_vale.center_id
    LIMIT 1;

    IF v_medication_id IS NULL THEN
      -- Crear medicamento si no existe
      INSERT INTO medications (
        catalog_id,
        center_id,
        nombre,
        lote,
        cantidad,
        fecha_caducidad,
        fecha_ingreso,
        estado,
        ubicacion_fisica
      )
      SELECT
        mc.id,
        v_vale.center_id,
        mc.nombre_comercial,
        v_item.numero_lote,
        v_item.cantidad,
        v_item.fecha_caducidad,
        v_vale.fecha_entrada,
        'disponible',
        v_item.ubicacion_fisica
      FROM medication_catalog mc
      WHERE mc.id = v_item.medication_catalog_id
      RETURNING id INTO v_medication_id;
    END IF;

    -- Crear lote en batches
    INSERT INTO batches (
      medication_id,
      center_id,
      supplier_id,
      numero_lote,
      cantidad_inicial,
      cantidad_actual,
      fecha_caducidad,
      fecha_ingreso,
      ubicacion_fisica,
      estado
    ) VALUES (
      v_medication_id,
      v_vale.center_id,
      v_vale.supplier_id,
      v_item.numero_lote,
      v_item.cantidad,
      v_item.cantidad,
      v_item.fecha_caducidad,
      v_vale.fecha_entrada,
      v_item.ubicacion_fisica,
      'disponible'
    ) RETURNING id INTO v_batch_id;

    -- Registrar movimiento
    INSERT INTO batch_movements (
      batch_id,
      medication_id,
      center_id,
      tipo_movimiento,
      cantidad,
      cantidad_anterior,
      cantidad_posterior,
      numero_documento,
      motivo,
      observaciones,
      usuario_responsable,
      metadata
    ) VALUES (
      v_batch_id,
      v_medication_id,
      v_vale.center_id,
      'entrada',
      v_item.cantidad,
      0,
      v_item.cantidad,
      v_vale.numero_vale,
      'Entrada por vale: ' || v_vale.numero_vale,
      v_vale.observaciones,
      p_autorizado_por,
      jsonb_build_object(
        'vale_id', p_vale_id,
        'factura', v_vale.numero_factura,
        'supplier_id', v_vale.supplier_id
      )
    );

    -- Actualizar referencia en item
    UPDATE vales_entrada_items
    SET batch_id = v_batch_id
    WHERE id = v_item.id;

    v_count := v_count + 1;
  END LOOP;

  -- Marcar vale como aplicado
  UPDATE vales_entrada
  SET
    estado = 'aplicado',
    updated_at = NOW()
  WHERE id = p_vale_id;

  RETURN QUERY SELECT true, format('%s lotes creados exitosamente', v_count), v_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION aplicar_vale_entrada IS 'Aplica un vale de entrada creando lotes y movimientos';

-- ============================================
-- PARTE 5.3: FUNCIONES PARA VALES DE SALIDA
-- ============================================

-- Función: Crear vale de salida
CREATE OR REPLACE FUNCTION crear_vale_salida(
  p_numero_vale TEXT,
  p_center_id UUID,
  p_tipo_salida TEXT,
  p_destino_centro_id UUID,
  p_items JSONB,
  p_despachado_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  vale_id UUID
) AS $$
DECLARE
  v_vale_id UUID;
  v_item JSONB;
  v_batch RECORD;
  v_total_items INTEGER := 0;
BEGIN
  -- Validar número de vale
  IF EXISTS (SELECT 1 FROM vales_salida WHERE numero_vale = p_numero_vale) THEN
    RETURN QUERY SELECT false, 'El número de vale ya existe', NULL::UUID;
    RETURN;
  END IF;

  -- Crear vale
  INSERT INTO vales_salida (
    numero_vale,
    center_id,
    tipo_salida,
    destino_centro_id,
    despachado_por,
    estado
  ) VALUES (
    p_numero_vale,
    p_center_id,
    p_tipo_salida,
    p_destino_centro_id,
    p_despachado_por,
    'borrador'
  ) RETURNING id INTO v_vale_id;

  -- Insertar items y validar stock
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    -- Obtener lote
    SELECT * INTO v_batch
    FROM batches
    WHERE id = (v_item->>'batch_id')::UUID;

    IF NOT FOUND THEN
      RETURN QUERY SELECT false, 'Lote no encontrado: ' || (v_item->>'batch_id'), NULL::UUID;
      RETURN;
    END IF;

    -- Validar stock disponible
    IF v_batch.cantidad_actual < (v_item->>'cantidad')::INTEGER THEN
      RETURN QUERY SELECT
        false,
        format('Stock insuficiente en lote %s. Disponible: %s, Solicitado: %s',
          v_batch.numero_lote, v_batch.cantidad_actual, (v_item->>'cantidad')::INTEGER),
        NULL::UUID;
      RETURN;
    END IF;

    -- Insertar item
    INSERT INTO vales_salida_items (
      vale_salida_id,
      batch_id,
      medication_id,
      numero_lote,
      cantidad,
      fecha_caducidad
    ) VALUES (
      v_vale_id,
      v_batch.id,
      v_batch.medication_id,
      v_batch.numero_lote,
      (v_item->>'cantidad')::INTEGER,
      v_batch.fecha_caducidad
    );

    v_total_items := v_total_items + 1;
  END LOOP;

  -- Actualizar total
  UPDATE vales_salida SET total_items = v_total_items WHERE id = v_vale_id;

  RETURN QUERY SELECT true, 'Vale de salida creado exitosamente', v_vale_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_vale_salida IS 'Crea un vale de salida validando stock disponible';

-- Función: Aplicar vale de salida (descontar stock)
CREATE OR REPLACE FUNCTION aplicar_vale_salida(
  p_vale_id UUID,
  p_autorizado_por UUID
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  movimientos_creados INTEGER
) AS $$
DECLARE
  v_vale RECORD;
  v_item RECORD;
  v_movement_id UUID;
  v_count INTEGER := 0;
  v_result RECORD;
BEGIN
  -- Obtener vale
  SELECT * INTO v_vale FROM vales_salida WHERE id = p_vale_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Vale no encontrado', 0;
    RETURN;
  END IF;

  IF v_vale.estado != 'autorizado' THEN
    RETURN QUERY SELECT false, 'El vale debe estar autorizado', 0;
    RETURN;
  END IF;

  -- Procesar cada item
  FOR v_item IN
    SELECT * FROM vales_salida_items WHERE vale_salida_id = p_vale_id
  LOOP
    -- Registrar movimiento usando la función existente
    SELECT * INTO v_result
    FROM registrar_movimiento_lote(
      v_item.batch_id,
      CASE v_vale.tipo_salida
        WHEN 'transferencia' THEN 'transferencia_salida'
        WHEN 'dispensacion' THEN 'salida'
        WHEN 'devolucion' THEN 'devolucion'
        WHEN 'merma' THEN 'merma'
        ELSE 'salida'
      END,
      v_item.cantidad,
      'Salida por vale: ' || v_vale.numero_vale,
      v_vale.destino_centro_id,
      v_vale.numero_vale,
      v_vale.observaciones,
      p_autorizado_por
    );

    IF NOT v_result.success THEN
      RETURN QUERY SELECT false, v_result.message, 0;
      RETURN;
    END IF;

    -- Actualizar referencia del movimiento
    UPDATE vales_salida_items
    SET movement_id = v_result.movement_id
    WHERE id = v_item.id;

    v_count := v_count + 1;
  END LOOP;

  -- Marcar vale como despachado
  UPDATE vales_salida
  SET
    estado = 'despachado',
    updated_at = NOW()
  WHERE id = p_vale_id;

  RETURN QUERY SELECT true, format('%s movimientos aplicados', v_count), v_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION aplicar_vale_salida IS 'Aplica un vale de salida descontando stock';

-- ============================================
-- PARTE 5.4: FUNCIONES DE FIRMAS DIGITALES
-- ============================================

-- Función: Registrar firma digital
CREATE OR REPLACE FUNCTION registrar_firma_digital(
  p_user_id UUID,
  p_documento_tipo TEXT,
  p_documento_id UUID,
  p_tipo_firma TEXT,
  p_firma_data TEXT,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  firma_id UUID
) AS $$
DECLARE
  v_firma_id UUID;
BEGIN
  -- Registrar firma
  INSERT INTO firmas_digitales (
    user_id,
    documento_tipo,
    documento_id,
    tipo_firma,
    firma_data,
    ip_address,
    user_agent
  ) VALUES (
    p_user_id,
    p_documento_tipo,
    p_documento_id,
    p_tipo_firma,
    p_firma_data,
    p_ip_address,
    p_user_agent
  ) RETURNING id INTO v_firma_id;

  -- Actualizar documento según tipo
  CASE p_documento_tipo
    WHEN 'vale_entrada' THEN
      IF p_tipo_firma = 'recepcion' THEN
        UPDATE vales_entrada
        SET firma_recepcion = p_firma_data, fecha_firma_recepcion = NOW()
        WHERE id = p_documento_id;
      ELSIF p_tipo_firma = 'autorizacion' THEN
        UPDATE vales_entrada
        SET
          firma_autorizacion = p_firma_data,
          fecha_firma_autorizacion = NOW(),
          estado = 'autorizado',
          autorizado_por = p_user_id
        WHERE id = p_documento_id;
      END IF;

    WHEN 'vale_salida' THEN
      IF p_tipo_firma = 'despacho' THEN
        UPDATE vales_salida
        SET firma_despacho = p_firma_data, fecha_firma_despacho = NOW()
        WHERE id = p_documento_id;
      ELSIF p_tipo_firma = 'autorizacion' THEN
        UPDATE vales_salida
        SET
          firma_autorizacion = p_firma_data,
          fecha_firma_autorizacion = NOW(),
          estado = 'autorizado',
          autorizado_por = p_user_id
        WHERE id = p_documento_id;
      END IF;

    WHEN 'acta_entrega' THEN
      IF p_tipo_firma = 'recepcion' THEN
        UPDATE actas_entrega
        SET firma_recibe = p_firma_data, fecha_firma_recibe = NOW()
        WHERE id = p_documento_id;
      ELSIF p_tipo_firma = 'autorizacion' THEN
        UPDATE actas_entrega
        SET
          firma_entrega = p_firma_data,
          fecha_firma_entrega = NOW(),
          estado = 'firmada'
        WHERE id = p_documento_id;
      END IF;

    ELSE
      -- Otros tipos de documentos
      NULL;
  END CASE;

  -- Registrar en audit log
  INSERT INTO audit_log (
    user_id,
    action_type,
    entity_type,
    entity_id,
    changes_summary,
    result,
    severity,
    ip_address,
    user_agent
  ) VALUES (
    p_user_id,
    'SIGN',
    p_documento_tipo,
    p_documento_id,
    'Firma digital registrada: ' || p_tipo_firma,
    'success',
    'high',
    p_ip_address,
    p_user_agent
  );

  RETURN QUERY SELECT true, 'Firma registrada exitosamente', v_firma_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_firma_digital IS 'Registra una firma digital en un documento';

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 5 COMPLETADA' as resultado;

SELECT 'TABLAS DOCUMENTALES' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'vales_entrada', 'vales_entrada_items',
    'vales_salida', 'vales_salida_items',
    'actas_entrega', 'actas_entrega_items',
    'firmas_digitales'
  )
ORDER BY table_name;

SELECT 'FUNCIONES DOCUMENTALES' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'crear_vale_entrada',
    'aplicar_vale_entrada',
    'crear_vale_salida',
    'aplicar_vale_salida',
    'registrar_firma_digital'
  )
ORDER BY routine_name;
