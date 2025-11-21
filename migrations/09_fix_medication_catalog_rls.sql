-- ============================================
-- SIGIMED v2.0 - MIGRACIÓN 09
-- Corregir políticas RLS para medication_catalog
-- ============================================
-- PROBLEMA: RLS está habilitado pero no hay políticas
-- SOLUCIÓN: Agregar políticas que permitan acceso
-- ============================================

-- ============================================
-- PASO 1: Verificar y corregir estructura de la tabla
-- ============================================

-- Agregar columnas faltantes si no existen
DO $$
BEGIN
    -- codigo_medicamento
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'medication_catalog' AND column_name = 'codigo_medicamento') THEN
        ALTER TABLE medication_catalog ADD COLUMN codigo_medicamento TEXT;
        -- Generar códigos únicos para registros existentes
        UPDATE medication_catalog SET codigo_medicamento = 'MED-' || UPPER(SUBSTRING(id::text, 1, 8)) WHERE codigo_medicamento IS NULL;
        ALTER TABLE medication_catalog ALTER COLUMN codigo_medicamento SET NOT NULL;
        ALTER TABLE medication_catalog ADD CONSTRAINT medication_catalog_codigo_unique UNIQUE (codigo_medicamento);
    END IF;

    -- principio_activo (si existe formula_activa, renombrar)
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'formula_activa')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'principio_activo') THEN
        ALTER TABLE medication_catalog RENAME COLUMN formula_activa TO principio_activo;
    ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'principio_activo') THEN
        ALTER TABLE medication_catalog ADD COLUMN principio_activo TEXT;
    END IF;

    -- via_administracion
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'medication_catalog' AND column_name = 'via_administracion') THEN
        ALTER TABLE medication_catalog ADD COLUMN via_administracion TEXT;
    END IF;

    -- unidad_medida
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'medication_catalog' AND column_name = 'unidad_medida') THEN
        ALTER TABLE medication_catalog ADD COLUMN unidad_medida TEXT;
    END IF;

    -- categoria (si existe categoria_farmacologica, renombrar)
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'categoria_farmacologica')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'categoria') THEN
        ALTER TABLE medication_catalog RENAME COLUMN categoria_farmacologica TO categoria;
    ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'categoria') THEN
        ALTER TABLE medication_catalog ADD COLUMN categoria TEXT;
    END IF;

    -- controlado (si existe es_controlado, renombrar)
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'es_controlado')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'controlado') THEN
        ALTER TABLE medication_catalog RENAME COLUMN es_controlado TO controlado;
    ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'medication_catalog' AND column_name = 'controlado') THEN
        ALTER TABLE medication_catalog ADD COLUMN controlado BOOLEAN DEFAULT false;
    END IF;

    -- observaciones
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'medication_catalog' AND column_name = 'observaciones') THEN
        ALTER TABLE medication_catalog ADD COLUMN observaciones TEXT;
    END IF;

    -- temperatura_almacenamiento (convertir a TEXT si es enum)
    -- Esto es más complejo, así que solo verificamos que exista
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'medication_catalog' AND column_name = 'temperatura_almacenamiento') THEN
        ALTER TABLE medication_catalog ADD COLUMN temperatura_almacenamiento TEXT;
    END IF;

    RAISE NOTICE 'Estructura de medication_catalog verificada y actualizada';
END $$;

-- ============================================
-- PASO 2: Eliminar políticas existentes (si las hay)
-- ============================================
DROP POLICY IF EXISTS "Catalog readable by all authenticated" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog insertable by admins" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog updatable by admins" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog deletable by admins" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_select" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_insert" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_update" ON medication_catalog;
DROP POLICY IF EXISTS "medication_catalog_delete" ON medication_catalog;

-- ============================================
-- PASO 3: Habilitar RLS (si no está habilitado)
-- ============================================
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 4: Crear políticas RLS correctas
-- ============================================

-- El catálogo es PÚBLICO para lectura (todos los usuarios autenticados pueden ver)
CREATE POLICY "Catalog readable by all authenticated"
ON medication_catalog FOR SELECT
TO authenticated
USING (true);

-- Solo administradores pueden insertar
CREATE POLICY "Catalog insertable by admins"
ON medication_catalog FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid()
    AND role IN ('super_admin', 'admin_center')
  )
);

-- Solo administradores pueden actualizar
CREATE POLICY "Catalog updatable by admins"
ON medication_catalog FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid()
    AND role IN ('super_admin', 'admin_center')
  )
);

-- Solo super_admin puede eliminar
CREATE POLICY "Catalog deletable by super admins"
ON medication_catalog FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid()
    AND role = 'super_admin'
  )
);

-- ============================================
-- PASO 5: Política para acceso anónimo (lectura)
-- Útil para APIs públicas o cuando no hay sesión
-- ============================================
CREATE POLICY "Catalog readable by anon"
ON medication_catalog FOR SELECT
TO anon
USING (is_active = true);

-- ============================================
-- PASO 6: Verificar políticas creadas
-- ============================================
DO $$
DECLARE
    policy_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename = 'medication_catalog';

    RAISE NOTICE 'Políticas RLS creadas para medication_catalog: %', policy_count;
END $$;

-- ============================================
-- PASO 7: Agregar datos de ejemplo si la tabla está vacía
-- ============================================
INSERT INTO medication_catalog (
    codigo_medicamento,
    nombre_generico,
    nombre_comercial,
    principio_activo,
    forma_farmaceutica,
    via_administracion,
    concentracion,
    unidad_medida,
    categoria,
    requiere_receta,
    controlado,
    temperatura_almacenamiento,
    observaciones,
    is_active
)
SELECT
    'MED-PAR-500',
    'Paracetamol',
    'Tempra',
    'Paracetamol',
    'Tableta',
    'Oral',
    '500mg',
    'tableta',
    'Analgésico',
    false,
    false,
    '15-25°C',
    'Analgésico y antipirético de uso común',
    true
WHERE NOT EXISTS (SELECT 1 FROM medication_catalog LIMIT 1)

UNION ALL

SELECT
    'MED-AMO-500',
    'Amoxicilina',
    'Amoxil',
    'Amoxicilina trihidratada',
    'Cápsula',
    'Oral',
    '500mg',
    'cápsula',
    'Antibiótico',
    true,
    false,
    '15-25°C',
    'Antibiótico de amplio espectro',
    true
WHERE NOT EXISTS (SELECT 1 FROM medication_catalog LIMIT 1)

UNION ALL

SELECT
    'MED-IBU-400',
    'Ibuprofeno',
    'Advil',
    'Ibuprofeno',
    'Tableta',
    'Oral',
    '400mg',
    'tableta',
    'Antiinflamatorio',
    false,
    false,
    '15-25°C',
    'AINE - Antiinflamatorio no esteroideo',
    true
WHERE NOT EXISTS (SELECT 1 FROM medication_catalog LIMIT 1)

UNION ALL

SELECT
    'MED-OME-20',
    'Omeprazol',
    'Losec',
    'Omeprazol',
    'Cápsula',
    'Oral',
    '20mg',
    'cápsula',
    'Gastroenterología',
    false,
    false,
    '15-25°C',
    'Inhibidor de la bomba de protones',
    true
WHERE NOT EXISTS (SELECT 1 FROM medication_catalog LIMIT 1)

UNION ALL

SELECT
    'MED-MET-850',
    'Metformina',
    'Glucophage',
    'Metformina clorhidrato',
    'Tableta',
    'Oral',
    '850mg',
    'tableta',
    'Antidiabético',
    true,
    false,
    '15-25°C',
    'Antidiabético oral de primera línea',
    true
WHERE NOT EXISTS (SELECT 1 FROM medication_catalog LIMIT 1);

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================
DO $$
DECLARE
    catalog_count INTEGER;
    rls_enabled BOOLEAN;
BEGIN
    -- Contar registros
    SELECT COUNT(*) INTO catalog_count FROM medication_catalog;

    -- Verificar RLS
    SELECT relrowsecurity INTO rls_enabled
    FROM pg_class
    WHERE relname = 'medication_catalog';

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'MIGRACIÓN 09 COMPLETADA';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Registros en medication_catalog: %', catalog_count;
    RAISE NOTICE 'RLS habilitado: %', rls_enabled;
    RAISE NOTICE '==========================================';
END $$;
