# 🎯 PLAN MAESTRO DE IMPLEMENTACIÓN SIGIMED
## Sistema Completo Profesional de Gestión de Inventario Médico

**Fecha**: 2025-11-08
**Estado**: En ejecución
**Objetivo**: Implementar sistema COMPLETO según especificaciones profesionales

---

## 📋 RESUMEN EJECUTIVO

### Alcance Total:
- ✅ 15 tablas de base de datos
- ✅ 20+ funciones SQL
- ✅ 8 módulos completos
- ✅ Sistema de permisos granular
- ✅ Auditoría completa
- ✅ Gestión documental
- ✅ Contratos y suministros

---

## 🔍 FASE 0: AUDITORÍA INICIAL (ACTUAL)

### Qué existe:
- [x] Tablas: health_centers, medications, medication_catalog
- [x] 2 funciones SQL básicas
- [x] Frontend: 5 páginas (Dashboard, Inventario, Alertas, Admin, Reportes)
- [x] Autenticación básica
- [ ] RLS configurado
- [ ] Sistema de permisos
- [ ] Datos iniciales completos

### Qué falta (crítico):
- [ ] Tabla suppliers
- [ ] Tabla batches
- [ ] Tabla batch_movements completa
- [ ] Tabla audit_log
- [ ] Tabla user_centers
- [ ] Tabla storage_inspections
- [ ] Tabla contracts
- [ ] Tabla contract_items
- [ ] Tabla documentos_comprobantes
- [ ] Tabla instituciones
- [ ] Sistema de permisos completo
- [ ] RLS en todas las tablas
- [ ] Funciones SQL avanzadas

---

## 📅 FASE 1: ENTIDADES BASE Y DATOS INICIALES
**Duración estimada**: 30 minutos
**Prioridad**: CRÍTICA

### 1.1 Crear tablas faltantes

#### A. Tabla `suppliers` (proveedores)
```sql
CREATE TABLE suppliers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  rfc TEXT UNIQUE,
  razon_social TEXT,
  direccion TEXT,
  ciudad TEXT,
  estado TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  contacto_telefono TEXT,
  terminos_pago TEXT,
  dias_credito INTEGER,
  calificacion DECIMAL(2,1) CHECK (calificacion >= 0 AND calificacion <= 5),
  notas TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### B. Tabla `batches` (lotes)
```sql
CREATE TABLE batches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  center_id UUID REFERENCES health_centers(id),
  supplier_id UUID REFERENCES suppliers(id),
  numero_lote TEXT NOT NULL,
  cantidad_inicial INTEGER NOT NULL,
  cantidad_actual INTEGER NOT NULL,
  fecha_fabricacion DATE,
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  ubicacion_fisica TEXT,
  temperatura_almacenamiento TEXT,
  estado TEXT CHECK (estado IN ('disponible', 'cuarentena', 'vencido', 'agotado')),
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(medication_id, numero_lote, center_id)
);
```

#### C. Tabla `batch_movements` completa
```sql
CREATE TABLE batch_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
  medication_id UUID REFERENCES medications(id),
  center_id UUID REFERENCES health_centers(id),
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN (
    'entrada', 'salida', 'ajuste', 'transferencia_salida',
    'transferencia_entrada', 'devolucion', 'merma', 'vencimiento'
  )),
  cantidad INTEGER NOT NULL,
  cantidad_anterior INTEGER NOT NULL,
  cantidad_posterior INTEGER NOT NULL,
  centro_origen_id UUID REFERENCES health_centers(id),
  centro_destino_id UUID REFERENCES health_centers(id),
  numero_documento TEXT,
  motivo TEXT NOT NULL,
  observaciones TEXT,
  usuario_responsable UUID REFERENCES users_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);
```

#### D. Tabla `user_centers` (multi-tenancy)
```sql
CREATE TABLE user_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users_profiles(id) ON DELETE CASCADE,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, center_id)
);
```

#### E. Tabla `audit_log` completa
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users_profiles(id),
  user_email TEXT,
  user_name TEXT,
  user_role TEXT,
  action_type TEXT NOT NULL CHECK (action_type IN (
    'CREATE', 'READ', 'UPDATE', 'DELETE',
    'LOGIN', 'LOGOUT', 'LOGIN_FAILED',
    'EXPORT', 'IMPORT', 'APPROVE', 'REJECT', 'SIGN'
  )),
  entity_type TEXT NOT NULL,
  entity_id UUID,
  entity_name TEXT,
  old_values JSONB,
  new_values JSONB,
  changes_summary TEXT,
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  result TEXT CHECK (result IN ('success', 'failed', 'partial')),
  error_message TEXT,
  metadata JSONB,
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 1.2 Datos iniciales específicos

#### A. Centros de salud institucionales
```sql
INSERT INTO health_centers (name, code, city, region, responsible_name, is_active) VALUES
('HOSPITAL GENERAL DE ZONA #1', 'HGZ1', 'Monterrey', 'Nuevo León', 'Dr. Juan Pérez', true),
('CLÍNICA DE MEDICINA FAMILIAR #23', 'CMF23', 'Guadalajara', 'Jalisco', 'Dra. Laura Ramírez', true);
```

#### B. Catálogo de medicamentos
```sql
INSERT INTO medication_catalog (...) VALUES
('Paracetamol 500mg', 'Paracetamol', 'Paracetamol 500mg', 'tableta', ...),
('Amoxicilina 875mg', 'Amoxicilina', 'Amoxicilina 875mg', 'tableta', ...),
('Omeprazol 20mg', 'Omeprazol', 'Omeprazol 20mg', 'capsula', ...);
```

#### C. Proveedores
```sql
INSERT INTO suppliers (...) VALUES
('Farmacéutica Nacional S.A.', 'FNA850101XYZ', ...),
('Distribuidora Médica del Norte', 'DMN920315ABC', ...);
```

#### D. Lotes iniciales (4 lotes, 2 por centro)
```sql
-- HGZ1 - Paracetamol
INSERT INTO batches (...) VALUES (...);
-- HGZ1 - Amoxicilina
INSERT INTO batches (...) VALUES (...);
-- CMF23 - Paracetamol
INSERT INTO batches (...) VALUES (...);
-- CMF23 - Omeprazol
INSERT INTO batches (...) VALUES (...);
```

### 1.3 Funciones SQL base

#### `registrar_movimiento_lote()`
- Registra movimientos de entrada/salida
- Actualiza cantidades automáticamente
- Valida stock disponible
- Registra en audit_log

---

## 📅 FASE 2: PERMISOS, ROLES Y RLS
**Duración estimada**: 45 minutos
**Prioridad**: ALTA

### 2.1 Sistema de permisos

#### A. Archivo `src/lib/permissions.ts`
```typescript
export const PERMISSIONS = {
  // Inventario
  INVENTORY_VIEW: 'inventory.view',
  INVENTORY_CREATE: 'inventory.create',
  INVENTORY_UPDATE: 'inventory.update',
  INVENTORY_DELETE: 'inventory.delete',
  INVENTORY_EXPORT: 'inventory.export',

  // Catálogo
  CATALOG_VIEW: 'catalog.view',
  CATALOG_MANAGE: 'catalog.manage',

  // Movimientos
  MOVEMENTS_VIEW: 'movements.view',
  MOVEMENTS_CREATE: 'movements.create',
  MOVEMENTS_APPROVE: 'movements.approve',

  // Contratos
  CONTRACTS_VIEW: 'contracts.view',
  CONTRACTS_MANAGE: 'contracts.manage',
  CONTRACTS_SIGN: 'contracts.sign',

  // Usuarios
  USERS_VIEW: 'users.view',
  USERS_MANAGE: 'users.manage',

  // Auditoría
  AUDIT_VIEW: 'audit.view',

  // Reportes
  REPORTS_VIEW: 'reports.view',
  REPORTS_EXPORT: 'reports.export',
}

export const ROLE_PERMISSIONS = {
  super_admin: Object.values(PERMISSIONS),
  admin_center: [
    PERMISSIONS.INVENTORY_VIEW,
    PERMISSIONS.INVENTORY_CREATE,
    PERMISSIONS.INVENTORY_UPDATE,
    PERMISSIONS.INVENTORY_EXPORT,
    PERMISSIONS.CATALOG_VIEW,
    PERMISSIONS.MOVEMENTS_VIEW,
    PERMISSIONS.MOVEMENTS_CREATE,
    PERMISSIONS.MOVEMENTS_APPROVE,
    PERMISSIONS.CONTRACTS_VIEW,
    PERMISSIONS.USERS_VIEW,
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_EXPORT,
  ],
  inventory_user: [
    PERMISSIONS.INVENTORY_VIEW,
    PERMISSIONS.INVENTORY_CREATE,
    PERMISSIONS.INVENTORY_UPDATE,
    PERMISSIONS.CATALOG_VIEW,
    PERMISSIONS.MOVEMENTS_VIEW,
    PERMISSIONS.MOVEMENTS_CREATE,
    PERMISSIONS.REPORTS_VIEW,
  ],
  read_only: [
    PERMISSIONS.INVENTORY_VIEW,
    PERMISSIONS.CATALOG_VIEW,
    PERMISSIONS.MOVEMENTS_VIEW,
    PERMISSIONS.REPORTS_VIEW,
  ],
}
```

#### B. Hook `src/hooks/usePermissions.ts`
```typescript
export function usePermissions() {
  const { user } = useAuth()

  const hasPermission = (permission: string) => {
    if (!user) return false
    const userPermissions = ROLE_PERMISSIONS[user.role] || []
    return userPermissions.includes(permission)
  }

  const canManageInventory = () => hasPermission(PERMISSIONS.INVENTORY_MANAGE)
  const canManageContracts = () => hasPermission(PERMISSIONS.CONTRACTS_MANAGE)
  const canViewAudit = () => hasPermission(PERMISSIONS.AUDIT_VIEW)

  return { hasPermission, canManageInventory, canManageContracts, canViewAudit }
}
```

### 2.2 RLS Completo

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE health_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Políticas por tabla (ejemplo: medications)
CREATE POLICY "Users see medications from their centers"
  ON medications FOR SELECT
  USING (
    center_id IN (
      SELECT center_id FROM user_centers WHERE user_id = auth.uid()
    )
  );
```

---

## 📅 FASE 3: CONTROL Y CALIDAD AVANZADO
**Duración estimada**: 1 hora
**Prioridad**: ALTA

### 3.1 Caducidad automática
- Función `detectar_lotes_vencidos()`
- Componente `ExpiryAlerts.tsx`
- Vista filtrada por días restantes

### 3.2 Stock mínimo/máximo
- Agregar columnas a `batches`
- Alertas visuales
- Dashboard de alertas

### 3.3 Inspecciones técnicas
```sql
CREATE TABLE storage_inspections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  center_id UUID REFERENCES health_centers(id),
  inspector_id UUID REFERENCES users_profiles(id),
  fecha_inspeccion TIMESTAMPTZ DEFAULT NOW(),
  temperatura_min DECIMAL(5,2),
  temperatura_max DECIMAL(5,2),
  humedad_relativa DECIMAL(5,2),
  condiciones_generales TEXT,
  observaciones TEXT,
  firma_digital TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.4 Auditoría detallada
- Trigger automático en todas las tablas
- Comparación campo por campo
- Vista histórica de cambios

### 3.5 Multi-institución
```sql
CREATE TABLE instituciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  clave TEXT UNIQUE,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE health_centers ADD COLUMN institucion_id UUID REFERENCES instituciones(id);
```

### 3.6 Log de acceso
- Registrar IP en cada login
- Componente `AccessLog.tsx`
- Vista de últimos accesos

---

## 📅 FASE 4: MÓDULO DE CONTRATOS
**Duración estimada**: 1 hora
**Prioridad**: MEDIA

### 4.1 Tablas

```sql
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_contrato TEXT UNIQUE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id),
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  monto_total DECIMAL(15,2),
  estado TEXT CHECK (estado IN ('borrador', 'activo', 'vencido', 'cancelado')),
  pdf_url TEXT,
  firmado_por UUID REFERENCES users_profiles(id),
  fecha_firma TIMESTAMPTZ,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE contract_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id) ON DELETE CASCADE,
  medication_catalog_id UUID REFERENCES medication_catalog(id),
  cantidad_comprometida INTEGER NOT NULL,
  center_destino_id UUID REFERENCES health_centers(id),
  fecha_estimada_entrega DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE contract_audit_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES contracts(id),
  medication_id UUID,
  batch_id UUID REFERENCES batches(id),
  cantidad_entregada INTEGER,
  fecha_entrega DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.2 Componentes
- `ContractsPage.tsx`
- `ContractForm.tsx`
- `ContractProgress.tsx`
- `ContractTracking.tsx`

---

## 📅 FASE 5: DOCUMENTOS Y COMPROBANTES
**Duración estimada**: 1.5 horas
**Prioridad**: MEDIA

### 5.1 Tabla
```sql
CREATE TABLE documentos_comprobantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_documento TEXT CHECK (tipo_documento IN (
    'vale_entrada', 'acta_entrega', 'vale_salida',
    'documento_transferencia', 'contrato_pdf', 'anexo'
  )),
  referencia_tipo TEXT,
  referencia_id UUID,
  nombre_archivo TEXT NOT NULL,
  url_archivo TEXT NOT NULL,
  size_bytes BIGINT,
  mime_type TEXT,
  firmado_por UUID REFERENCES users_profiles(id),
  fecha_firma TIMESTAMPTZ,
  requiere_firma BOOLEAN DEFAULT false,
  observaciones TEXT,
  uploaded_by UUID REFERENCES users_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5.2 Supabase Storage
- Bucket: `documentos-sigimed`
- Políticas de acceso
- Validación de tipos de archivo

### 5.3 Componentes
- `DocumentManager.tsx`
- `DocumentUploader.tsx`
- `DocumentViewer.tsx`
- `SignatureDialog.tsx`

---

## 📅 FASE 6: TESTING Y REPORTE FINAL
**Duración estimada**: 30 minutos

### 6.1 Pruebas
- Crear usuario de prueba por cada rol
- Probar permisos
- Probar RLS
- Probar flujos completos

### 6.2 Reporte final
```
SISTEMA SIGIMED - REPORTE DE IMPLEMENTACIÓN
==========================================

✅ TABLAS CREADAS: 15
✅ FUNCIONES SQL: 25
✅ COMPONENTES NUEVOS: 40+
✅ PERMISOS: 4 roles, 20 permisos
✅ RLS: Habilitado en 15 tablas
✅ DATOS INICIALES: 2 centros, 3 medicamentos, 4 lotes
✅ AUDITORÍA: Completa
✅ DOCUMENTOS: Sistema completo
```

---

## 📊 TIEMPO TOTAL ESTIMADO
- Fase 1: 30 min
- Fase 2: 45 min
- Fase 3: 60 min
- Fase 4: 60 min
- Fase 5: 90 min
- Fase 6: 30 min

**TOTAL: ~5 horas de implementación**

---

## 🚀 PRÓXIMOS PASOS

1. Ejecutar Fase 1 (crear este archivo primero para aprobar)
2. Validar cada fase antes de continuar
3. Probar cada módulo
4. Generar reporte final

**¿Apruebas este plan para comenzar la ejecución?**
