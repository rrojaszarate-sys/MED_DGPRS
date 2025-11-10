-- ============================================
-- FASE 2: SISTEMA DE PERMISOS Y RLS
-- ============================================
-- Fecha: 2025-11-08
-- Propósito: Implementar sistema de roles, permisos y Row Level Security
-- Tiempo estimado: 45 minutos
-- Ejecutar DESPUÉS de Fase 1

BEGIN;

-- ============================================
-- PARTE 2.1: TABLA DE PERMISOS
-- ============================================

-- Tabla: permissions (Permisos granulares)
CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name TEXT NOT NULL CHECK (role_name IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  resource TEXT NOT NULL, -- 'medications', 'batches', 'suppliers', etc.
  action TEXT NOT NULL CHECK (action IN ('create', 'read', 'update', 'delete', 'export', 'approve')),
  allowed BOOLEAN DEFAULT true,
  conditions JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(role_name, resource, action)
);

CREATE INDEX IF NOT EXISTS idx_permissions_role ON permissions(role_name);
CREATE INDEX IF NOT EXISTS idx_permissions_resource ON permissions(resource);

COMMENT ON TABLE permissions IS 'Define permisos granulares por rol y recurso';
COMMENT ON COLUMN permissions.conditions IS 'Condiciones adicionales en formato JSON (ej: {"only_own_center": true})';

-- ============================================
-- PARTE 2.2: TABLA DE ROLES DE USUARIOS
-- ============================================

-- Tabla: user_roles (Roles asignados a usuarios)
CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role_name TEXT NOT NULL CHECK (role_name IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  assigned_by UUID,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}'::jsonb,
  UNIQUE(user_id, role_name, center_id)
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role_name);
CREATE INDEX IF NOT EXISTS idx_user_roles_center ON user_roles(center_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_active ON user_roles(is_active) WHERE is_active = true;

COMMENT ON TABLE user_roles IS 'Roles asignados a usuarios con alcance por centro';
COMMENT ON COLUMN user_roles.center_id IS 'NULL para super_admin (alcance global), obligatorio para otros roles';
COMMENT ON COLUMN user_roles.valid_until IS 'Fecha de expiración del rol (NULL = sin expiración)';

-- ============================================
-- PARTE 2.3: INSERTAR PERMISOS POR ROL
-- ============================================

-- Permisos para SUPER_ADMIN (acceso total)
INSERT INTO permissions (role_name, resource, action, allowed) VALUES
  ('super_admin', 'medications', 'create', true),
  ('super_admin', 'medications', 'read', true),
  ('super_admin', 'medications', 'update', true),
  ('super_admin', 'medications', 'delete', true),
  ('super_admin', 'medications', 'export', true),
  ('super_admin', 'batches', 'create', true),
  ('super_admin', 'batches', 'read', true),
  ('super_admin', 'batches', 'update', true),
  ('super_admin', 'batches', 'delete', true),
  ('super_admin', 'suppliers', 'create', true),
  ('super_admin', 'suppliers', 'read', true),
  ('super_admin', 'suppliers', 'update', true),
  ('super_admin', 'suppliers', 'delete', true),
  ('super_admin', 'contracts', 'create', true),
  ('super_admin', 'contracts', 'read', true),
  ('super_admin', 'contracts', 'update', true),
  ('super_admin', 'contracts', 'approve', true),
  ('super_admin', 'users', 'create', true),
  ('super_admin', 'users', 'read', true),
  ('super_admin', 'users', 'update', true),
  ('super_admin', 'users', 'delete', true)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

-- Permisos para ADMIN_CENTER (administrador de centro)
INSERT INTO permissions (role_name, resource, action, allowed, conditions) VALUES
  ('admin_center', 'medications', 'create', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'update', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'delete', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'medications', 'export', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'create', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'update', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'batches', 'delete', false, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'suppliers', 'read', true, '{}'::jsonb),
  ('admin_center', 'contracts', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'users', 'read', true, '{"only_own_center": true}'::jsonb),
  ('admin_center', 'users', 'update', true, '{"only_own_center": true}'::jsonb)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

-- Permisos para INVENTORY_USER (usuario de inventario)
INSERT INTO permissions (role_name, resource, action, allowed, conditions) VALUES
  ('inventory_user', 'medications', 'create', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'medications', 'read', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'medications', 'update', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'medications', 'delete', false, '{}'::jsonb),
  ('inventory_user', 'medications', 'export', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'create', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'read', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'update', true, '{"only_own_center": true}'::jsonb),
  ('inventory_user', 'batches', 'delete', false, '{}'::jsonb),
  ('inventory_user', 'suppliers', 'read', true, '{}'::jsonb),
  ('inventory_user', 'contracts', 'read', true, '{"only_own_center": true}'::jsonb)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

-- Permisos para READ_ONLY (solo lectura)
INSERT INTO permissions (role_name, resource, action, allowed, conditions) VALUES
  ('read_only', 'medications', 'read', true, '{"only_own_center": true}'::jsonb),
  ('read_only', 'batches', 'read', true, '{"only_own_center": true}'::jsonb),
  ('read_only', 'suppliers', 'read', true, '{}'::jsonb),
  ('read_only', 'contracts', 'read', true, '{"only_own_center": true}'::jsonb),
  ('read_only', 'medications', 'export', true, '{"only_own_center": true}'::jsonb)
ON CONFLICT (role_name, resource, action) DO UPDATE SET allowed = EXCLUDED.allowed;

COMMIT;

-- ============================================
-- PARTE 2.4: FUNCIONES HELPER PARA RLS
-- ============================================

-- Función: Obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role(p_user_id UUID DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
  v_user_id UUID;
  v_role TEXT;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());

  SELECT role_name INTO v_role
  FROM user_roles
  WHERE user_id = v_user_id
    AND is_active = true
    AND (valid_until IS NULL OR valid_until > NOW())
  ORDER BY
    CASE role_name
      WHEN 'super_admin' THEN 1
      WHEN 'admin_center' THEN 2
      WHEN 'inventory_user' THEN 3
      WHEN 'read_only' THEN 4
    END
  LIMIT 1;

  RETURN COALESCE(v_role, 'read_only');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_user_role IS 'Obtiene el rol más privilegiado del usuario actual';

-- Función: Verificar si usuario tiene permiso
CREATE OR REPLACE FUNCTION has_permission(
  p_resource TEXT,
  p_action TEXT,
  p_user_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_id UUID;
  v_role TEXT;
  v_allowed BOOLEAN;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());
  v_role := get_user_role(v_user_id);

  SELECT allowed INTO v_allowed
  FROM permissions
  WHERE role_name = v_role
    AND resource = p_resource
    AND action = p_action;

  RETURN COALESCE(v_allowed, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION has_permission IS 'Verifica si el usuario tiene un permiso específico';

-- Función: Obtener centros del usuario
CREATE OR REPLACE FUNCTION get_user_centers(p_user_id UUID DEFAULT NULL)
RETURNS TABLE (center_id UUID) AS $$
DECLARE
  v_user_id UUID;
  v_role TEXT;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());
  v_role := get_user_role(v_user_id);

  -- Super admin tiene acceso a todos los centros
  IF v_role = 'super_admin' THEN
    RETURN QUERY SELECT id FROM health_centers WHERE is_active = true;
  ELSE
    -- Otros roles solo sus centros asignados
    RETURN QUERY
    SELECT DISTINCT uc.center_id
    FROM user_centers uc
    WHERE uc.user_id = v_user_id
    UNION
    SELECT DISTINCT ur.center_id
    FROM user_roles ur
    WHERE ur.user_id = v_user_id
      AND ur.is_active = true
      AND ur.center_id IS NOT NULL
      AND (ur.valid_until IS NULL OR ur.valid_until > NOW());
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_user_centers IS 'Obtiene los centros a los que el usuario tiene acceso';

-- Función: Verificar si usuario es super admin
CREATE OR REPLACE FUNCTION is_super_admin(p_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN get_user_role(COALESCE(p_user_id, auth.uid())) = 'super_admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función: Verificar acceso a un centro específico
CREATE OR REPLACE FUNCTION has_center_access(p_center_id UUID, p_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());

  -- Super admin tiene acceso a todos
  IF is_super_admin(v_user_id) THEN
    RETURN true;
  END IF;

  -- Verificar si el centro está en la lista del usuario
  RETURN EXISTS (
    SELECT 1 FROM get_user_centers(v_user_id) WHERE center_id = p_center_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION has_center_access IS 'Verifica si el usuario tiene acceso a un centro específico';

COMMIT;

-- ============================================
-- PARTE 2.5: POLÍTICAS RLS
-- ============================================

BEGIN;

-- Habilitar RLS en todas las tablas principales
ALTER TABLE health_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contract_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE documentos_comprobantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS: HEALTH_CENTERS
-- ============================================

DROP POLICY IF EXISTS "health_centers_select_policy" ON health_centers;
CREATE POLICY "health_centers_select_policy" ON health_centers
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(id)
  );

DROP POLICY IF EXISTS "health_centers_insert_policy" ON health_centers;
CREATE POLICY "health_centers_insert_policy" ON health_centers
  FOR INSERT
  WITH CHECK (is_super_admin());

DROP POLICY IF EXISTS "health_centers_update_policy" ON health_centers;
CREATE POLICY "health_centers_update_policy" ON health_centers
  FOR UPDATE
  USING (
    is_super_admin()
    OR (get_user_role() = 'admin_center' AND has_center_access(id))
  );

DROP POLICY IF EXISTS "health_centers_delete_policy" ON health_centers;
CREATE POLICY "health_centers_delete_policy" ON health_centers
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: MEDICATIONS
-- ============================================

DROP POLICY IF EXISTS "medications_select_policy" ON medications;
CREATE POLICY "medications_select_policy" ON medications
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(center_id)
  );

DROP POLICY IF EXISTS "medications_insert_policy" ON medications;
CREATE POLICY "medications_insert_policy" ON medications
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR (has_permission('medications', 'create') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "medications_update_policy" ON medications;
CREATE POLICY "medications_update_policy" ON medications
  FOR UPDATE
  USING (
    is_super_admin()
    OR (has_permission('medications', 'update') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "medications_delete_policy" ON medications;
CREATE POLICY "medications_delete_policy" ON medications
  FOR DELETE
  USING (
    is_super_admin()
    OR (has_permission('medications', 'delete') AND has_center_access(center_id))
  );

-- ============================================
-- RLS: BATCHES
-- ============================================

DROP POLICY IF EXISTS "batches_select_policy" ON batches;
CREATE POLICY "batches_select_policy" ON batches
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(center_id)
  );

DROP POLICY IF EXISTS "batches_insert_policy" ON batches;
CREATE POLICY "batches_insert_policy" ON batches
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR (has_permission('batches', 'create') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "batches_update_policy" ON batches;
CREATE POLICY "batches_update_policy" ON batches
  FOR UPDATE
  USING (
    is_super_admin()
    OR (has_permission('batches', 'update') AND has_center_access(center_id))
  );

DROP POLICY IF EXISTS "batches_delete_policy" ON batches;
CREATE POLICY "batches_delete_policy" ON batches
  FOR DELETE
  USING (
    is_super_admin()
    OR (has_permission('batches', 'delete') AND has_center_access(center_id))
  );

-- ============================================
-- RLS: BATCH_MOVEMENTS
-- ============================================

DROP POLICY IF EXISTS "batch_movements_select_policy" ON batch_movements;
CREATE POLICY "batch_movements_select_policy" ON batch_movements
  FOR SELECT
  USING (
    is_super_admin()
    OR has_center_access(center_id)
  );

DROP POLICY IF EXISTS "batch_movements_insert_policy" ON batch_movements;
CREATE POLICY "batch_movements_insert_policy" ON batch_movements
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_center_access(center_id)
  );

-- Movimientos son inmutables (no UPDATE/DELETE después de crear)
DROP POLICY IF EXISTS "batch_movements_update_policy" ON batch_movements;
CREATE POLICY "batch_movements_update_policy" ON batch_movements
  FOR UPDATE
  USING (is_super_admin());

DROP POLICY IF EXISTS "batch_movements_delete_policy" ON batch_movements;
CREATE POLICY "batch_movements_delete_policy" ON batch_movements
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: SUPPLIERS (Todos pueden leer)
-- ============================================

DROP POLICY IF EXISTS "suppliers_select_policy" ON suppliers;
CREATE POLICY "suppliers_select_policy" ON suppliers
  FOR SELECT
  USING (true); -- Todos pueden ver proveedores

DROP POLICY IF EXISTS "suppliers_insert_policy" ON suppliers;
CREATE POLICY "suppliers_insert_policy" ON suppliers
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('suppliers', 'create')
  );

DROP POLICY IF EXISTS "suppliers_update_policy" ON suppliers;
CREATE POLICY "suppliers_update_policy" ON suppliers
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('suppliers', 'update')
  );

DROP POLICY IF EXISTS "suppliers_delete_policy" ON suppliers;
CREATE POLICY "suppliers_delete_policy" ON suppliers
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: CONTRACTS
-- ============================================

DROP POLICY IF EXISTS "contracts_select_policy" ON contracts;
CREATE POLICY "contracts_select_policy" ON contracts
  FOR SELECT
  USING (
    is_super_admin()
    OR has_permission('contracts', 'read')
  );

DROP POLICY IF EXISTS "contracts_insert_policy" ON contracts;
CREATE POLICY "contracts_insert_policy" ON contracts
  FOR INSERT
  WITH CHECK (
    is_super_admin()
    OR has_permission('contracts', 'create')
  );

DROP POLICY IF EXISTS "contracts_update_policy" ON contracts;
CREATE POLICY "contracts_update_policy" ON contracts
  FOR UPDATE
  USING (
    is_super_admin()
    OR has_permission('contracts', 'update')
  );

DROP POLICY IF EXISTS "contracts_delete_policy" ON contracts;
CREATE POLICY "contracts_delete_policy" ON contracts
  FOR DELETE
  USING (is_super_admin());

-- ============================================
-- RLS: AUDIT_LOG (Solo lectura, super_admin puede todo)
-- ============================================

DROP POLICY IF EXISTS "audit_log_select_policy" ON audit_log;
CREATE POLICY "audit_log_select_policy" ON audit_log
  FOR SELECT
  USING (
    is_super_admin()
    OR user_id = auth.uid()
  );

DROP POLICY IF EXISTS "audit_log_insert_policy" ON audit_log;
CREATE POLICY "audit_log_insert_policy" ON audit_log
  FOR INSERT
  WITH CHECK (true); -- Cualquiera puede insertar en audit log

DROP POLICY IF EXISTS "audit_log_update_policy" ON audit_log;
CREATE POLICY "audit_log_update_policy" ON audit_log
  FOR UPDATE
  USING (false); -- Audit log es inmutable

DROP POLICY IF EXISTS "audit_log_delete_policy" ON audit_log;
CREATE POLICY "audit_log_delete_policy" ON audit_log
  FOR DELETE
  USING (is_super_admin()); -- Solo super_admin puede eliminar logs

COMMIT;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ FASE 2 COMPLETADA' as resultado;

SELECT 'TABLAS DE PERMISOS' as seccion;
SELECT table_name, 'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('permissions', 'user_roles')
ORDER BY table_name;

SELECT 'FUNCIONES RLS' as seccion;
SELECT routine_name as funcion, 'OK' as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'get_user_role', 'has_permission', 'get_user_centers',
    'is_super_admin', 'has_center_access'
  )
ORDER BY routine_name;

SELECT 'POLÍTICAS RLS' as seccion;
SELECT
  schemaname as schema,
  tablename as tabla,
  COUNT(*) as politicas
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY schemaname, tablename
ORDER BY tablename;

SELECT 'PERMISOS CONFIGURADOS' as seccion;
SELECT role_name, COUNT(*) as permisos_totales
FROM permissions
GROUP BY role_name
ORDER BY role_name;
