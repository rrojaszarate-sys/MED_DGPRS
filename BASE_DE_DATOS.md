# 🗄️ BASE DE DATOS - SIGIMED v2.0

## Documentación Completa del Esquema de Base de Datos

**Base de Datos:** PostgreSQL 14
**ORM:** Supabase (PostgREST)
**Migraciones:** 8 archivos SQL (3,977 líneas)
**Última actualización:** Noviembre 2025

---

## 📑 ÍNDICE

1. [Visión General](#visión-general)
2. [Diagrama Entidad-Relación](#diagrama-entidad-relación)
3. [Tablas Principales](#tablas-principales)
4. [Relaciones](#relaciones)
5. [Índices](#índices)
6. [Funciones y Triggers](#funciones-y-triggers)
7. [Row Level Security](#row-level-security)
8. [Vistas](#vistas)
9. [Enumeraciones](#enumeraciones)
10. [Migraciones](#migraciones)

---

## 🎯 VISIÓN GENERAL

### Estadísticas del Esquema

| Métrica | Cantidad |
|---------|----------|
| Tablas Principales | 12 |
| Relaciones (FK) | 15+ |
| Índices | 25+ |
| Triggers | 12 |
| Funciones | 8 |
| Políticas RLS | 40+ |
| Vistas | 5 |

### Principios de Diseño

1. **Normalización** - 3ra forma normal (3NF)
2. **Integridad Referencial** - Foreign keys estrictas
3. **Auditoría** - Triggers en tablas críticas
4. **Seguridad** - RLS en todas las tablas
5. **Performance** - Índices estratégicos
6. **Trazabilidad** - Timestamps y soft deletes

---

## 📊 DIAGRAMA ENTIDAD-RELACIÓN

```
┌─────────────────┐         ┌─────────────────┐
│   instituciones │         │  health_centers │
│─────────────────│         │─────────────────│
│ id (PK)         │         │ id (PK)         │
│ nombre          │         │ name            │
│ clave           │         │ code            │
│ tipo            │         │ address         │
│ created_at      │         │ city            │
└────────┬────────┘         │ phone           │
         │                  │ is_active       │
         │                  └────────┬────────┘
         │                           │
         │                           │ 1:N
         │                           │
         │                  ┌────────▼────────┐
         │                  │      users      │
         │                  │─────────────────│
         │                  │ id (PK)         │
         │                  │ email           │
         │                  │ full_name       │
         │                  │ role            │
         │                  │ center_id (FK)  │
         │                  │ is_active       │
         │                  └─────────────────┘
         │
         │                  ┌─────────────────┐
         └──────────────────│  medications    │◄───────┐
                            │─────────────────│        │
                            │ id (PK)         │        │
                            │ center_id (FK)  │────────┤
                            │ catalog_id (FK) │◄───┐   │
                            │ nombre          │    │   │
                            │ is_active       │    │   │
                            └────────┬────────┘    │   │
                                     │ 1:N         │   │
                                     │             │   │
                            ┌────────▼────────┐    │   │
                            │  batches        │    │   │
                            │─────────────────│    │   │
                            │ id (PK)         │    │   │
                            │ medication_id(FK)────┘   │
                            │ center_id (FK)  │────────┤
                            │ supplier_id(FK) │◄───┐   │
                            │ numero_lote     │    │   │
                            │ cantidad_actual │    │   │
                            │ fecha_caducidad │    │   │
                            │ estado          │    │   │
                            └────────┬────────┘    │   │
                                     │ 1:N         │   │
                                     │             │   │
                            ┌────────▼────────┐    │   │
                            │batch_movements  │    │   │
                            │─────────────────│    │   │
                            │ id (PK)         │    │   │
                            │ medication_id   │────┘   │
                            │ tipo_movimiento │        │
                            │ cantidad        │        │
                            │ centro_orig (FK)│◄───────┤
                            │ centro_dest (FK)│◄───────┤
                            │ usuario_resp.   │        │
                            │ metadata        │        │
                            └─────────────────┘        │
                                                       │
┌─────────────────┐         ┌─────────────────┐      │
│   suppliers     │         │medication_catalog│      │
│─────────────────│         │─────────────────│      │
│ id (PK)         │         │ id (PK)         │──────┘
│ nombre          │         │ codigo_med.     │
│ rfc             │         │ nombre_generico │
│ contacto        │         │ principio_activo│
│ is_active       │         │ categoria       │
└────────┬────────┘         │ requiere_receta │
         │ 1:N              │ controlado      │
         │                  └─────────────────┘
         │
┌────────▼────────┐
│   contracts     │
│─────────────────│
│ id (PK)         │
│ supplier_id (FK)│
│ codigo_contrato │
│ fecha_inicio    │
│ fecha_fin       │
│ estado          │
│ monto_total     │
└────────┬────────┘
         │ 1:N
         │
┌────────▼────────┐
│ contract_items  │
│─────────────────│
│ id (PK)         │
│ contract_id (FK)│
│ medication_id   │
│ cantidad        │
│ precio_unitario │
│ center_dest.(FK)│
└─────────────────┘

┌─────────────────┐         ┌─────────────────┐
│     alerts      │         │   audit_logs    │
│─────────────────│         │─────────────────│
│ id (PK)         │         │ id (PK)         │
│ medicamento_id  │         │ user_id         │
│ centro_id (FK)  │         │ action_type     │
│ nivel_alerta    │         │ entity_type     │
│ dias_restantes  │         │ entity_id       │
│ visto           │         │ old_values      │
│ resuelta        │         │ new_values      │
└─────────────────┘         │ created_at      │
                            └─────────────────┘
```

---

## 📋 TABLAS PRINCIPALES

### 1. users

**Descripción:** Usuarios del sistema con roles y permisos.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  center_id UUID REFERENCES health_centers(id),
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK, generado automáticamente |
| `email` | TEXT | Email único, requerido |
| `full_name` | TEXT | Nombre completo del usuario |
| `role` | TEXT | Rol: super_admin, admin_center, inventory_user, read_only |
| `center_id` | UUID | FK a health_centers (nullable para super_admin) |
| `avatar_url` | TEXT | URL de avatar |
| `is_active` | BOOLEAN | Usuario activo/inactivo |
| `created_at` | TIMESTAMPTZ | Fecha de creación |
| `updated_at` | TIMESTAMPTZ | Última actualización |

**Índices:**
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_center_id ON users(center_id);
CREATE INDEX idx_users_role ON users(role);
```

**Restricciones:**
- Email único
- Role debe ser uno de los 4 valores permitidos
- center_id obligatorio para roles que no sean super_admin

---

### 2. health_centers

**Descripción:** Centros de salud que usan el sistema.

```sql
CREATE TABLE health_centers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  address TEXT,
  city TEXT,
  phone TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `name` | TEXT | Nombre del centro |
| `code` | TEXT | Código único del centro |
| `address` | TEXT | Dirección física |
| `city` | TEXT | Ciudad |
| `phone` | TEXT | Teléfono de contacto |
| `is_active` | BOOLEAN | Centro activo/inactivo |
| `created_at` | TIMESTAMPTZ | Fecha de creación |

**Índices:**
```sql
CREATE UNIQUE INDEX idx_health_centers_code ON health_centers(code);
CREATE INDEX idx_health_centers_active ON health_centers(is_active);
```

---

### 3. instituciones

**Descripción:** Instituciones del sector salud (IMSS, ISSSTE, SSA, etc.).

```sql
CREATE TABLE instituciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  clave TEXT,
  tipo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `nombre` | TEXT | Nombre de la institución |
| `clave` | TEXT | Clave única de institución |
| `tipo` | TEXT | Tipo: IMSS, ISSSTE, SSA, SEDENA, etc. |
| `created_at` | TIMESTAMPTZ | Fecha de creación |

**Tipos Comunes:**
- IMSS - Instituto Mexicano del Seguro Social
- ISSSTE - Instituto de Seguridad y Servicios Sociales
- SSA - Secretaría de Salud
- SEDENA - Secretaría de la Defensa Nacional
- SEMAR - Secretaría de Marina
- PEMEX - Petróleos Mexicanos
- IMSS Bienestar
- Privado

---

### 4. medication_catalog

**Descripción:** Catálogo maestro de medicamentos (datos normativos).

```sql
CREATE TABLE medication_catalog (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo_medicamento TEXT UNIQUE NOT NULL,
  nombre_generico TEXT NOT NULL,
  nombre_comercial TEXT,
  principio_activo TEXT,
  forma_farmaceutica TEXT,
  via_administracion TEXT,
  concentracion TEXT,
  unidad_medida TEXT,
  categoria TEXT,
  requiere_receta BOOLEAN DEFAULT false,
  controlado BOOLEAN DEFAULT false,
  temperatura_almacenamiento TEXT,
  observaciones TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `codigo_medicamento` | TEXT | Código único del medicamento |
| `nombre_generico` | TEXT | Nombre genérico (DCI) |
| `nombre_comercial` | TEXT | Nombre comercial/marca |
| `principio_activo` | TEXT | Sustancia activa |
| `forma_farmaceutica` | TEXT | Tableta, cápsula, jarabe, etc. |
| `via_administracion` | TEXT | Oral, IV, IM, tópica, etc. |
| `concentracion` | TEXT | 500mg, 100mg/5ml, etc. |
| `unidad_medida` | TEXT | tabletas, ml, gr, etc. |
| `categoria` | TEXT | Analgésico, antibiótico, etc. |
| `requiere_receta` | BOOLEAN | Si requiere receta médica |
| `controlado` | BOOLEAN | Si es medicamento controlado |
| `temperatura_almacenamiento` | TEXT | Ambiente, 2-8°C, etc. |
| `observaciones` | TEXT | Notas adicionales |
| `is_active` | BOOLEAN | Activo en catálogo |
| `created_at` | TIMESTAMPTZ | Fecha de creación |
| `updated_at` | TIMESTAMPTZ | Última actualización |

**Índices:**
```sql
CREATE UNIQUE INDEX idx_med_catalog_codigo ON medication_catalog(codigo_medicamento);
CREATE INDEX idx_med_catalog_nombre ON medication_catalog(nombre_generico);
CREATE INDEX idx_med_catalog_categoria ON medication_catalog(categoria);
CREATE INDEX idx_med_catalog_active ON medication_catalog(is_active);
```

---

### 5. medications

**Descripción:** Medicamentos específicos por centro de salud.

```sql
CREATE TABLE medications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  center_id UUID NOT NULL REFERENCES health_centers(id) ON DELETE CASCADE,
  catalog_id UUID REFERENCES medication_catalog(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  unidad_medida TEXT NOT NULL,
  categoria TEXT,
  requiere_refrigeracion BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `center_id` | UUID | FK a health_centers (requerido) |
| `catalog_id` | UUID | FK a medication_catalog (opcional) |
| `nombre` | TEXT | Nombre del medicamento |
| `descripcion` | TEXT | Descripción adicional |
| `unidad_medida` | TEXT | Unidad de medida |
| `categoria` | TEXT | Categoría del medicamento |
| `requiere_refrigeracion` | BOOLEAN | Si requiere refrigeración |
| `is_active` | BOOLEAN | Medicamento activo |
| `created_at` | TIMESTAMPTZ | Fecha de creación |
| `updated_at` | TIMESTAMPTZ | Última actualización |

**Índices:**
```sql
CREATE INDEX idx_medications_center ON medications(center_id);
CREATE INDEX idx_medications_catalog ON medications(catalog_id);
CREATE INDEX idx_medications_nombre ON medications(nombre);
```

**Nota:** Esta tabla vincula el catálogo maestro con instancias específicas por centro.

---

### 6. suppliers

**Descripción:** Proveedores de medicamentos.

```sql
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  rfc TEXT,
  razon_social TEXT,
  direccion TEXT,
  ciudad TEXT,
  estado TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  contacto_telefono TEXT,
  terminos_pago TEXT,
  dias_credito INTEGER DEFAULT 0,
  calificacion INTEGER CHECK (calificacion >= 1 AND calificacion <= 5),
  notas TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `nombre` | TEXT | Nombre del proveedor |
| `rfc` | TEXT | RFC fiscal |
| `razon_social` | TEXT | Razón social |
| `direccion` | TEXT | Dirección |
| `ciudad` | TEXT | Ciudad |
| `estado` | TEXT | Estado |
| `telefono` | TEXT | Teléfono |
| `email` | TEXT | Email de contacto |
| `contacto_nombre` | TEXT | Nombre del contacto |
| `contacto_telefono` | TEXT | Teléfono del contacto |
| `terminos_pago` | TEXT | Términos de pago |
| `dias_credito` | INTEGER | Días de crédito (default 0) |
| `calificacion` | INTEGER | Calificación 1-5 |
| `notas` | TEXT | Notas adicionales |
| `is_active` | BOOLEAN | Proveedor activo |
| `created_at` | TIMESTAMPTZ | Fecha de creación |
| `updated_at` | TIMESTAMPTZ | Última actualización |

**Índices:**
```sql
CREATE INDEX idx_suppliers_nombre ON suppliers(nombre);
CREATE INDEX idx_suppliers_active ON suppliers(is_active);
```

---

### 7. batches

**Descripción:** Lotes específicos de medicamentos con stock y fechas.

```sql
CREATE TABLE batches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  medication_id UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
  center_id UUID NOT NULL REFERENCES health_centers(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES suppliers(id),
  numero_lote TEXT NOT NULL,
  cantidad_inicial INTEGER NOT NULL CHECK (cantidad_inicial > 0),
  cantidad_actual INTEGER NOT NULL CHECK (cantidad_actual >= 0),
  fecha_fabricacion DATE,
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  ubicacion_fisica TEXT,
  temperatura_almacenamiento TEXT,
  stock_minimo INTEGER DEFAULT 10,
  stock_maximo INTEGER,
  estado TEXT NOT NULL CHECK (estado IN ('disponible', 'cuarentena', 'vencido', 'agotado')),
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `medication_id` | UUID | FK a medications (requerido) |
| `center_id` | UUID | FK a health_centers (requerido) |
| `supplier_id` | UUID | FK a suppliers (opcional) |
| `numero_lote` | TEXT | Número de lote del proveedor |
| `cantidad_inicial` | INTEGER | Cantidad inicial (> 0) |
| `cantidad_actual` | INTEGER | Cantidad actual (>= 0) |
| `fecha_fabricacion` | DATE | Fecha de fabricación |
| `fecha_caducidad` | DATE | Fecha de caducidad (requerido) |
| `fecha_ingreso` | DATE | Fecha de ingreso al sistema |
| `ubicacion_fisica` | TEXT | Ubicación física en almacén |
| `temperatura_almacenamiento` | TEXT | Temperatura de almacenamiento |
| `stock_minimo` | INTEGER | Stock mínimo (default 10) |
| `stock_maximo` | INTEGER | Stock máximo |
| `estado` | TEXT | disponible, cuarentena, vencido, agotado |
| `observaciones` | TEXT | Notas adicionales |
| `created_at` | TIMESTAMPTZ | Fecha de creación |
| `updated_at` | TIMESTAMPTZ | Última actualización |

**Índices:**
```sql
CREATE INDEX idx_batches_medication ON batches(medication_id);
CREATE INDEX idx_batches_center ON batches(center_id);
CREATE INDEX idx_batches_supplier ON batches(supplier_id);
CREATE INDEX idx_batches_fecha_caducidad ON batches(fecha_caducidad);
CREATE INDEX idx_batches_estado ON batches(estado);
CREATE INDEX idx_batches_numero_lote ON batches(numero_lote);
```

**Restricciones:**
- cantidad_inicial > 0
- cantidad_actual >= 0
- estado solo puede ser uno de los 4 valores
- Constraint único: (medication_id, numero_lote, center_id)

---

### 8. batch_movements

**Descripción:** Registro de todos los movimientos de lotes (auditoría completa).

```sql
CREATE TABLE batch_movements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  medication_id UUID NOT NULL REFERENCES medications(id),
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN (
    'entrada', 'salida', 'ajuste', 'vencimiento', 'merma',
    'transferencia_salida', 'transferencia_entrada', 'devolucion', 'destruccion'
  )),
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  cantidad_anterior INTEGER NOT NULL,
  cantidad_posterior INTEGER NOT NULL,
  centro_origen_id UUID REFERENCES health_centers(id),
  centro_destino_id UUID REFERENCES health_centers(id),
  motivo TEXT NOT NULL,
  observaciones TEXT,
  usuario_responsable UUID NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `medication_id` | UUID | FK a medications |
| `tipo_movimiento` | TEXT | Tipo de movimiento (9 opciones) |
| `cantidad` | INTEGER | Cantidad del movimiento |
| `cantidad_anterior` | INTEGER | Cantidad antes del movimiento |
| `cantidad_posterior` | INTEGER | Cantidad después del movimiento |
| `centro_origen_id` | UUID | Centro origen (para transferencias) |
| `centro_destino_id` | UUID | Centro destino (para transferencias) |
| `motivo` | TEXT | Motivo del movimiento |
| `observaciones` | TEXT | Notas adicionales |
| `usuario_responsable` | UUID | Usuario que realizó el movimiento |
| `metadata` | JSONB | Metadatos adicionales |
| `created_at` | TIMESTAMPTZ | Fecha del movimiento |

**Tipos de Movimiento:**
1. **entrada** - Ingreso de nuevo lote
2. **salida** - Salida por dispensación
3. **ajuste** - Ajuste de inventario (corrección)
4. **vencimiento** - Lote vencido
5. **merma** - Pérdida por daño/robo
6. **transferencia_salida** - Salida a otro centro
7. **transferencia_entrada** - Entrada desde otro centro
8. **devolucion** - Devolución de medicamento
9. **destruccion** - Destrucción controlada

**Índices:**
```sql
CREATE INDEX idx_batch_movements_medication ON batch_movements(medication_id);
CREATE INDEX idx_batch_movements_tipo ON batch_movements(tipo_movimiento);
CREATE INDEX idx_batch_movements_created ON batch_movements(created_at DESC);
CREATE INDEX idx_batch_movements_user ON batch_movements(usuario_responsable);
```

**Metadata JSONB Example:**
```json
{
  "batch_id": "uuid",
  "numero_lote": "L123456",
  "user_name": "Juan Pérez",
  "centro_origen_name": "Centro A",
  "centro_destino_name": "Centro B",
  "authorization_code": "AUTH-001"
}
```

---

### 9. contracts

**Descripción:** Contratos con proveedores.

```sql
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo_contrato TEXT UNIQUE NOT NULL,
  supplier_id UUID NOT NULL REFERENCES suppliers(id),
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  monto_total NUMERIC(12,2),
  estado TEXT NOT NULL CHECK (estado IN ('borrador', 'activo', 'vencido', 'cancelado')),
  pdf_url TEXT,
  firmado_por TEXT,
  fecha_firma DATE,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `codigo_contrato` | TEXT | Código único del contrato |
| `supplier_id` | UUID | FK a suppliers |
| `fecha_inicio` | DATE | Fecha de inicio de vigencia |
| `fecha_fin` | DATE | Fecha de fin de vigencia |
| `monto_total` | NUMERIC | Monto total del contrato |
| `estado` | TEXT | borrador, activo, vencido, cancelado |
| `pdf_url` | TEXT | URL del PDF del contrato |
| `firmado_por` | TEXT | Nombre del firmante |
| `fecha_firma` | DATE | Fecha de firma |
| `observaciones` | TEXT | Notas adicionales |
| `created_at` | TIMESTAMPTZ | Fecha de creación |
| `updated_at` | TIMESTAMPTZ | Última actualización |

**Índices:**
```sql
CREATE UNIQUE INDEX idx_contracts_codigo ON contracts(codigo_contrato);
CREATE INDEX idx_contracts_supplier ON contracts(supplier_id);
CREATE INDEX idx_contracts_estado ON contracts(estado);
CREATE INDEX idx_contracts_vigencia ON contracts(fecha_inicio, fecha_fin);
```

---

### 10. contract_items

**Descripción:** Items/partidas de cada contrato (relación N:N entre contratos y medicamentos).

```sql
CREATE TABLE contract_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
  medication_catalog_id UUID NOT NULL REFERENCES medication_catalog(id),
  cantidad_comprometida INTEGER NOT NULL CHECK (cantidad_comprometida > 0),
  precio_unitario NUMERIC(10,2),
  center_destino_id UUID REFERENCES health_centers(id),
  fecha_estimada_entrega DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `contract_id` | UUID | FK a contracts |
| `medication_catalog_id` | UUID | FK a medication_catalog |
| `cantidad_comprometida` | INTEGER | Cantidad comprometida |
| `precio_unitario` | NUMERIC | Precio por unidad |
| `center_destino_id` | UUID | Centro destino (opcional) |
| `fecha_estimada_entrega` | DATE | Fecha estimada de entrega |
| `created_at` | TIMESTAMPTZ | Fecha de creación |

**Índices:**
```sql
CREATE INDEX idx_contract_items_contract ON contract_items(contract_id);
CREATE INDEX idx_contract_items_medication ON contract_items(medication_catalog_id);
CREATE INDEX idx_contract_items_center ON contract_items(center_destino_id);
```

---

### 11. alerts

**Descripción:** Alertas de vencimiento y stock bajo.

```sql
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  medicamento_id UUID NOT NULL REFERENCES medications(id),
  centro_id UUID NOT NULL REFERENCES health_centers(id),
  nivel_alerta TEXT NOT NULL CHECK (nivel_alerta IN ('critico', 'urgente', 'preventivo')),
  dias_restantes INTEGER,
  visto BOOLEAN DEFAULT false,
  resuelta BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `medicamento_id` | UUID | FK a medications |
| `centro_id` | UUID | FK a health_centers |
| `nivel_alerta` | TEXT | critico, urgente, preventivo |
| `dias_restantes` | INTEGER | Días hasta vencimiento |
| `visto` | BOOLEAN | Si fue vista por usuario |
| `resuelta` | BOOLEAN | Si fue resuelta |
| `created_at` | TIMESTAMPTZ | Fecha de creación |

**Niveles de Alerta:**
- **critico**: Stock bajo crítico (< 10% stock_minimo)
- **urgente**: Próximo a vencer (< 7 días)
- **preventivo**: Preventiva (< 30 días o < 50% stock_minimo)

**Índices:**
```sql
CREATE INDEX idx_alerts_medicamento ON alerts(medicamento_id);
CREATE INDEX idx_alerts_centro ON alerts(centro_id);
CREATE INDEX idx_alerts_nivel ON alerts(nivel_alerta);
CREATE INDEX idx_alerts_pendientes ON alerts(visto, resuelta);
```

---

### 12. audit_logs

**Descripción:** Registro de auditoría de todas las operaciones críticas.

```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID,
  user_email TEXT,
  user_name TEXT,
  action_type TEXT NOT NULL CHECK (action_type IN (
    'CREATE', 'READ', 'UPDATE', 'DELETE',
    'LOGIN', 'LOGOUT', 'EXPORT', 'IMPORT',
    'ADJUST', 'TRANSFER'
  )),
  entity_type TEXT NOT NULL CHECK (entity_type IN (
    'medication', 'user', 'center', 'transfer',
    'batch', 'catalog', 'contract', 'supplier'
  )),
  entity_id UUID,
  entity_name TEXT,
  old_values JSONB,
  new_values JSONB,
  changes_summary TEXT,
  result TEXT CHECK (result IN ('success', 'failed', 'partial')),
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Columnas:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID | PK |
| `user_id` | UUID | ID del usuario |
| `user_email` | TEXT | Email del usuario |
| `user_name` | TEXT | Nombre del usuario |
| `action_type` | TEXT | Tipo de acción |
| `entity_type` | TEXT | Tipo de entidad afectada |
| `entity_id` | UUID | ID de entidad afectada |
| `entity_name` | TEXT | Nombre de entidad |
| `old_values` | JSONB | Valores antiguos |
| `new_values` | JSONB | Valores nuevos |
| `changes_summary` | TEXT | Resumen de cambios |
| `result` | TEXT | Resultado de la operación |
| `severity` | TEXT | Severidad del evento |
| `metadata` | JSONB | Metadatos adicionales |
| `created_at` | TIMESTAMPTZ | Fecha del evento |

**Índices:**
```sql
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action_type);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_severity ON audit_logs(severity);
```

---

## 🔗 RELACIONES

### Diagrama de Relaciones Clave

```
users N:1 health_centers
  ↓
medications N:1 health_centers
medications N:1 medication_catalog
  ↓
batches N:1 medications
batches N:1 health_centers
batches N:1 suppliers
  ↓
batch_movements N:1 medications
batch_movements N:1 health_centers (origen)
batch_movements N:1 health_centers (destino)

contracts N:1 suppliers
  ↓
contract_items N:1 contracts
contract_items N:1 medication_catalog
contract_items N:1 health_centers (destino)

alerts N:1 medications
alerts N:1 health_centers
```

### Foreign Keys

```sql
-- users
ALTER TABLE users ADD CONSTRAINT fk_users_center
  FOREIGN KEY (center_id) REFERENCES health_centers(id);

-- medications
ALTER TABLE medications ADD CONSTRAINT fk_medications_center
  FOREIGN KEY (center_id) REFERENCES health_centers(id) ON DELETE CASCADE;
ALTER TABLE medications ADD CONSTRAINT fk_medications_catalog
  FOREIGN KEY (catalog_id) REFERENCES medication_catalog(id);

-- batches
ALTER TABLE batches ADD CONSTRAINT fk_batches_medication
  FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE;
ALTER TABLE batches ADD CONSTRAINT fk_batches_center
  FOREIGN KEY (center_id) REFERENCES health_centers(id) ON DELETE CASCADE;
ALTER TABLE batches ADD CONSTRAINT fk_batches_supplier
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id);

-- batch_movements
ALTER TABLE batch_movements ADD CONSTRAINT fk_movements_medication
  FOREIGN KEY (medication_id) REFERENCES medications(id);
ALTER TABLE batch_movements ADD CONSTRAINT fk_movements_centro_origen
  FOREIGN KEY (centro_origen_id) REFERENCES health_centers(id);
ALTER TABLE batch_movements ADD CONSTRAINT fk_movements_centro_destino
  FOREIGN KEY (centro_destino_id) REFERENCES health_centers(id);

-- contracts
ALTER TABLE contracts ADD CONSTRAINT fk_contracts_supplier
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id);

-- contract_items
ALTER TABLE contract_items ADD CONSTRAINT fk_contract_items_contract
  FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE;
ALTER TABLE contract_items ADD CONSTRAINT fk_contract_items_medication
  FOREIGN KEY (medication_catalog_id) REFERENCES medication_catalog(id);
ALTER TABLE contract_items ADD CONSTRAINT fk_contract_items_center
  FOREIGN KEY (center_destino_id) REFERENCES health_centers(id);

-- alerts
ALTER TABLE alerts ADD CONSTRAINT fk_alerts_medication
  FOREIGN KEY (medicamento_id) REFERENCES medications(id);
ALTER TABLE alerts ADD CONSTRAINT fk_alerts_center
  FOREIGN KEY (centro_id) REFERENCES health_centers(id);
```

---

## 🔍 ÍNDICES

### Índices de Performance

**Principios:**
1. Índices en FKs para joins rápidos
2. Índices en columnas de búsqueda frecuente
3. Índices compuestos para queries comunes
4. Índices únicos para constraints

**Índices Compuestos:**

```sql
-- Búsqueda de batches por centro y estado
CREATE INDEX idx_batches_center_estado ON batches(center_id, estado);

-- Búsqueda de movimientos por fecha y tipo
CREATE INDEX idx_movements_fecha_tipo ON batch_movements(created_at DESC, tipo_movimiento);

-- Búsqueda de lotes por fecha de caducidad y centro
CREATE INDEX idx_batches_caducidad_center ON batches(fecha_caducidad, center_id);

-- Alertas pendientes por centro
CREATE INDEX idx_alerts_pendientes_centro ON alerts(centro_id, visto, resuelta)
  WHERE visto = false AND resuelta = false;
```

**Índices de Texto:**

```sql
-- Full-text search en medicamentos
CREATE INDEX idx_medications_nombre_trgm ON medications
  USING gin (nombre gin_trgm_ops);

-- Full-text search en catálogo
CREATE INDEX idx_catalog_nombre_trgm ON medication_catalog
  USING gin (nombre_generico gin_trgm_ops);
```

---

## ⚙️ FUNCIONES Y TRIGGERS

### 1. Update Timestamp Trigger

**Actualizar automáticamente updated_at:**

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a todas las tablas con updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medications_updated_at
  BEFORE UPDATE ON medications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Y así para todas las tablas...
```

### 2. Audit Logging Trigger

**Registrar cambios automáticamente:**

```sql
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
DECLARE
  user_data RECORD;
BEGIN
  -- Obtener datos del usuario
  SELECT email, full_name INTO user_data
  FROM users WHERE id = auth.uid();

  INSERT INTO audit_logs (
    user_id,
    user_email,
    user_name,
    action_type,
    entity_type,
    entity_id,
    old_values,
    new_values,
    result,
    severity
  ) VALUES (
    auth.uid(),
    user_data.email,
    user_data.full_name,
    TG_OP,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
    'success',
    CASE TG_OP
      WHEN 'DELETE' THEN 'high'
      WHEN 'UPDATE' THEN 'medium'
      ELSE 'low'
    END
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar a tablas críticas
CREATE TRIGGER audit_batches_changes
  AFTER INSERT OR UPDATE OR DELETE ON batches
  FOR EACH ROW EXECUTE FUNCTION audit_changes();

CREATE TRIGGER audit_medications_changes
  AFTER INSERT OR UPDATE OR DELETE ON medications
  FOR EACH ROW EXECUTE FUNCTION audit_changes();
```

### 3. Validate Batch Movement

**Validar movimientos de lotes:**

```sql
CREATE OR REPLACE FUNCTION validate_batch_movement()
RETURNS TRIGGER AS $$
DECLARE
  batch_record RECORD;
BEGIN
  -- Obtener información del lote
  SELECT * INTO batch_record
  FROM batches
  WHERE id = NEW.batch_id;

  -- Validar cantidad suficiente para salida
  IF NEW.tipo_movimiento IN ('salida', 'transferencia_salida', 'destruccion') THEN
    IF batch_record.cantidad_actual < NEW.cantidad THEN
      RAISE EXCEPTION 'Cantidad insuficiente en lote. Disponible: %, Solicitado: %',
        batch_record.cantidad_actual, NEW.cantidad;
    END IF;
  END IF;

  -- Validar fecha de caducidad
  IF batch_record.fecha_caducidad < CURRENT_DATE THEN
    RAISE EXCEPTION 'Lote vencido, no se pueden realizar movimientos';
  END IF;

  -- Validar estado del lote
  IF batch_record.estado NOT IN ('disponible') THEN
    RAISE EXCEPTION 'Lote en estado %, no disponible para movimientos', batch_record.estado;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_movement_before_insert
  BEFORE INSERT ON batch_movements
  FOR EACH ROW EXECUTE FUNCTION validate_batch_movement();
```

### 4. Update Batch Quantity

**Actualizar cantidad automáticamente después de movimiento:**

```sql
CREATE OR REPLACE FUNCTION update_batch_quantity()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tipo_movimiento IN ('entrada', 'transferencia_entrada', 'devolucion') THEN
    -- Incrementar cantidad
    UPDATE batches
    SET cantidad_actual = cantidad_actual + NEW.cantidad,
        estado = CASE
          WHEN cantidad_actual + NEW.cantidad > 0 THEN 'disponible'
          ELSE estado
        END
    WHERE id = NEW.batch_id;

  ELSIF NEW.tipo_movimiento IN ('salida', 'transferencia_salida', 'merma', 'destruccion') THEN
    -- Decrementar cantidad
    UPDATE batches
    SET cantidad_actual = cantidad_actual - NEW.cantidad,
        estado = CASE
          WHEN cantidad_actual - NEW.cantidad = 0 THEN 'agotado'
          ELSE estado
        END
    WHERE id = NEW.batch_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity_after_movement
  AFTER INSERT ON batch_movements
  FOR EACH ROW EXECUTE FUNCTION update_batch_quantity();
```

### 5. Generate Alerts

**Generar alertas automáticas:**

```sql
CREATE OR REPLACE FUNCTION generate_alerts()
RETURNS void AS $$
DECLARE
  batch_record RECORD;
  alert_level TEXT;
  days_remaining INTEGER;
BEGIN
  -- Limpiar alertas antiguas
  DELETE FROM alerts WHERE resuelta = true AND created_at < NOW() - INTERVAL '30 days';

  -- Generar alertas de caducidad
  FOR batch_record IN
    SELECT b.*, m.nombre as med_nombre
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    WHERE b.estado = 'disponible'
      AND b.fecha_caducidad > CURRENT_DATE
      AND b.fecha_caducidad < CURRENT_DATE + INTERVAL '30 days'
  LOOP
    days_remaining := batch_record.fecha_caducidad - CURRENT_DATE;

    -- Determinar nivel de alerta
    IF days_remaining <= 7 THEN
      alert_level := 'urgente';
    ELSE
      alert_level := 'preventivo';
    END IF;

    -- Insertar alerta si no existe
    INSERT INTO alerts (medicamento_id, centro_id, nivel_alerta, dias_restantes)
    SELECT batch_record.medication_id, batch_record.center_id, alert_level, days_remaining
    WHERE NOT EXISTS (
      SELECT 1 FROM alerts
      WHERE medicamento_id = batch_record.medication_id
        AND centro_id = batch_record.center_id
        AND resuelta = false
    );
  END LOOP;

  -- Generar alertas de stock bajo
  FOR batch_record IN
    SELECT b.*, m.nombre as med_nombre
    FROM batches b
    JOIN medications m ON b.medication_id = m.id
    WHERE b.estado = 'disponible'
      AND b.cantidad_actual < b.stock_minimo
  LOOP
    INSERT INTO alerts (medicamento_id, centro_id, nivel_alerta)
    SELECT batch_record.medication_id, batch_record.center_id, 'critico'
    WHERE NOT EXISTS (
      SELECT 1 FROM alerts
      WHERE medicamento_id = batch_record.medication_id
        AND centro_id = batch_record.center_id
        AND nivel_alerta = 'critico'
        AND resuelta = false
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar cada hora
-- (Configurar con pg_cron o cron job externo)
```

---

## 🔒 ROW LEVEL SECURITY

### Políticas RLS por Tabla

#### users

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Super admins pueden ver todos
CREATE POLICY "Super admins view all users" ON users
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- Usuarios ven solo su centro
CREATE POLICY "Users view own center users" ON users
  FOR SELECT
  USING (
    center_id IN (
      SELECT center_id FROM users
      WHERE id = auth.uid()
    )
  );

-- Solo super_admin puede insertar
CREATE POLICY "Only super_admin can insert users" ON users
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );
```

#### batches

```sql
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;

-- Ver batches de su centro
CREATE POLICY "Users view batches from their center" ON batches
  FOR SELECT
  USING (
    center_id IN (
      SELECT center_id FROM users
      WHERE id = auth.uid()
    )
  );

-- Admins y usuarios inventario pueden insertar
CREATE POLICY "Admins and inventory users can insert batches" ON batches
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center', 'inventory_user')
      AND (role = 'super_admin' OR center_id = batches.center_id)
    )
  );

-- Similar para UPDATE y DELETE con roles apropiados
```

#### audit_logs

```sql
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Solo lectura, nadie puede modificar
CREATE POLICY "Users can view own audit logs" ON audit_logs
  FOR SELECT
  USING (user_id = auth.uid());

-- Super admin puede ver todos
CREATE POLICY "Super admin views all audit logs" ON audit_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- Solo el sistema puede insertar (via trigger)
CREATE POLICY "System can insert audit logs" ON audit_logs
  FOR INSERT
  WITH CHECK (true);
```

---

## 📊 VISTAS

### 1. vista_inventario_actual

**Inventario consolidado por medicamento y centro:**

```sql
CREATE OR REPLACE VIEW vista_inventario_actual AS
SELECT
  m.id as medication_id,
  m.nombre as medicamento,
  m.center_id,
  hc.name as centro,
  m.categoria,
  COUNT(b.id) as total_lotes,
  SUM(b.cantidad_actual) as stock_total,
  MIN(b.fecha_caducidad) as proxima_caducidad,
  AVG(b.stock_minimo) as stock_minimo_promedio,
  CASE
    WHEN SUM(b.cantidad_actual) = 0 THEN 'agotado'
    WHEN SUM(b.cantidad_actual) < AVG(b.stock_minimo) THEN 'bajo'
    WHEN SUM(b.cantidad_actual) < AVG(b.stock_minimo) * 2 THEN 'medio'
    ELSE 'suficiente'
  END as estado_stock
FROM medications m
LEFT JOIN batches b ON m.id = b.medication_id AND b.estado = 'disponible'
JOIN health_centers hc ON m.center_id = hc.id
WHERE m.is_active = true
GROUP BY m.id, m.nombre, m.center_id, hc.name, m.categoria;
```

### 2. vista_movimientos_diarios

**Resumen de movimientos por día:**

```sql
CREATE OR REPLACE VIEW vista_movimientos_diarios AS
SELECT
  DATE(bm.created_at) as fecha,
  bm.centro_origen_id as center_id,
  hc.name as centro,
  bm.tipo_movimiento,
  COUNT(*) as cantidad_movimientos,
  SUM(bm.cantidad) as cantidad_total
FROM batch_movements bm
LEFT JOIN health_centers hc ON bm.centro_origen_id = hc.id
GROUP BY DATE(bm.created_at), bm.centro_origen_id, hc.name, bm.tipo_movimiento
ORDER BY fecha DESC, centro;
```

### 3. vista_alertas_pendientes

**Alertas no resueltas por centro:**

```sql
CREATE OR REPLACE VIEW vista_alertas_pendientes AS
SELECT
  a.id,
  a.centro_id,
  hc.name as centro,
  m.nombre as medicamento,
  a.nivel_alerta,
  a.dias_restantes,
  a.visto,
  a.created_at
FROM alerts a
JOIN medications m ON a.medicamento_id = m.id
JOIN health_centers hc ON a.centro_id = hc.id
WHERE a.resuelta = false
ORDER BY
  CASE a.nivel_alerta
    WHEN 'critico' THEN 1
    WHEN 'urgente' THEN 2
    WHEN 'preventivo' THEN 3
  END,
  a.dias_restantes NULLS LAST,
  a.created_at DESC;
```

### 4. vista_contratos_vigentes

**Contratos activos con sus items:**

```sql
CREATE OR REPLACE VIEW vista_contratos_vigentes AS
SELECT
  c.id as contract_id,
  c.codigo_contrato,
  s.nombre as proveedor,
  c.fecha_inicio,
  c.fecha_fin,
  c.monto_total,
  COUNT(ci.id) as total_items,
  SUM(ci.cantidad_comprometida * ci.precio_unitario) as monto_calculado
FROM contracts c
JOIN suppliers s ON c.supplier_id = s.id
LEFT JOIN contract_items ci ON c.id = ci.contract_id
WHERE c.estado = 'activo'
  AND c.fecha_fin >= CURRENT_DATE
GROUP BY c.id, c.codigo_contrato, s.nombre, c.fecha_inicio, c.fecha_fin, c.monto_total;
```

### 5. vista_estadisticas_centro

**Estadísticas generales por centro:**

```sql
CREATE OR REPLACE VIEW vista_estadisticas_centro AS
SELECT
  hc.id as center_id,
  hc.name as centro,
  COUNT(DISTINCT m.id) as total_medicamentos,
  COUNT(DISTINCT b.id) as total_lotes,
  SUM(b.cantidad_actual) as stock_total,
  COUNT(DISTINCT CASE WHEN a.resuelta = false THEN a.id END) as alertas_pendientes,
  COUNT(DISTINCT bm.id) as movimientos_mes_actual
FROM health_centers hc
LEFT JOIN medications m ON hc.id = m.center_id AND m.is_active = true
LEFT JOIN batches b ON m.id = b.medication_id AND b.estado = 'disponible'
LEFT JOIN alerts a ON hc.id = a.centro_id
LEFT JOIN batch_movements bm ON hc.id = bm.centro_origen_id
  AND bm.created_at >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY hc.id, hc.name;
```

---

## 🔢 ENUMERACIONES

### Tipos Enumerados (CHECK Constraints)

```sql
-- Roles de Usuario
CHECK (role IN ('super_admin', 'admin_center', 'inventory_user', 'read_only'))

-- Estados de Lote
CHECK (estado IN ('disponible', 'cuarentena', 'vencido', 'agotado'))

-- Tipos de Movimiento
CHECK (tipo_movimiento IN (
  'entrada', 'salida', 'ajuste', 'vencimiento', 'merma',
  'transferencia_salida', 'transferencia_entrada', 'devolucion', 'destruccion'
))

-- Estados de Contrato
CHECK (estado IN ('borrador', 'activo', 'vencido', 'cancelado'))

-- Niveles de Alerta
CHECK (nivel_alerta IN ('critico', 'urgente', 'preventivo'))

-- Tipos de Acción (Auditoría)
CHECK (action_type IN (
  'CREATE', 'READ', 'UPDATE', 'DELETE',
  'LOGIN', 'LOGOUT', 'EXPORT', 'IMPORT',
  'ADJUST', 'TRANSFER'
))

-- Tipos de Entidad (Auditoría)
CHECK (entity_type IN (
  'medication', 'user', 'center', 'transfer',
  'batch', 'catalog', 'contract', 'supplier'
))

-- Resultado de Operación
CHECK (result IN ('success', 'failed', 'partial'))

-- Severidad
CHECK (severity IN ('low', 'medium', 'high', 'critical'))
```

---

## 🚀 MIGRACIONES

### Orden de Ejecución

```bash
migrations/
├── 01_crear_tablas_core.sql           # Tablas básicas
├── 02_insertar_datos_iniciales.sql    # Datos de prueba
├── 03_funciones_y_triggers.sql        # Lógica de negocio
├── 04_sistema_permisos_rls.sql        # Seguridad
├── 05_control_calidad.sql             # Validaciones
├── 06_modulo_contratos.sql            # Contratos
├── 07_gestion_documental.sql          # Documentos
└── 08_testing_reportes.sql            # Testing
```

### Ejemplo de Migración

**01_crear_tablas_core.sql:**
```sql
-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Tabla: health_centers
CREATE TABLE health_centers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  address TEXT,
  city TEXT,
  phone TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE UNIQUE INDEX idx_health_centers_code ON health_centers(code);
CREATE INDEX idx_health_centers_active ON health_centers(is_active);

-- Comentarios
COMMENT ON TABLE health_centers IS 'Centros de salud que utilizan el sistema';
COMMENT ON COLUMN health_centers.code IS 'Código único del centro (ej: CS-001)';
```

---

## 📈 OPTIMIZACIÓN

### Estrategias de Optimización

1. **Particionamiento** (para tablas grandes)
```sql
-- Particionar batch_movements por mes
CREATE TABLE batch_movements_2024_11 PARTITION OF batch_movements
  FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
```

2. **Materialized Views** (para reportes pesados)
```sql
CREATE MATERIALIZED VIEW mv_inventario_mensual AS
SELECT * FROM vista_inventario_actual;

CREATE UNIQUE INDEX ON mv_inventario_mensual(medication_id);

-- Refresh manual o programado
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_inventario_mensual;
```

3. **VACUUM y ANALYZE**
```sql
-- Mantenimiento regular
VACUUM ANALYZE batches;
VACUUM ANALYZE batch_movements;

-- Autovacuum configurado en postgresql.conf
```

4. **Query Planning**
```sql
-- Analizar query plan
EXPLAIN ANALYZE
SELECT * FROM batches
WHERE center_id = 'uuid'
  AND estado = 'disponible'
  AND fecha_caducidad < CURRENT_DATE + INTERVAL '30 days';
```

---

## 🔄 BACKUP Y RESTORE

### Backup Completo

```bash
# Backup completo
pg_dump -h localhost -U postgres -d sigimed > backup_sigimed_$(date +%Y%m%d).sql

# Backup solo esquema
pg_dump -h localhost -U postgres -d sigimed --schema-only > schema_only.sql

# Backup solo datos
pg_dump -h localhost -U postgres -d sigimed --data-only > data_only.sql

# Backup tabla específica
pg_dump -h localhost -U postgres -d sigimed -t batches > batches_backup.sql
```

### Restore

```bash
# Restore completo
psql -h localhost -U postgres -d sigimed < backup_sigimed_20251110.sql

# Restore a nueva base de datos
createdb sigimed_restored
psql -h localhost -U postgres -d sigimed_restored < backup_sigimed_20251110.sql
```

### Backup en Supabase

```bash
# Via Supabase CLI
supabase db dump -f backup.sql

# Restore
supabase db reset
psql -h db.xxx.supabase.co -U postgres -d postgres < backup.sql
```

---

## 📚 MEJORES PRÁCTICAS

### 1. Naming Conventions

✅ **DO:**
- Tablas: plural, snake_case (`batch_movements`)
- Columnas: singular, snake_case (`fecha_caducidad`)
- FKs: `<table>_id` (`center_id`)
- Índices: `idx_<table>_<column>`
- Constraints: `fk_<table>_<ref_table>`

❌ **DON'T:**
- CamelCase en database
- Nombres genéricos (`data`, `info`)
- Abreviaciones confusas

### 2. Tipos de Datos

✅ **DO:**
- UUID para PKs
- TIMESTAMPTZ para fechas (timezone-aware)
- NUMERIC para dinero
- JSONB para metadatos
- TEXT para strings

❌ **DON'T:**
- VARCHAR(255) sin razón
- TIMESTAMP sin timezone
- FLOAT para dinero

### 3. Constraints

✅ **DO:**
- NOT NULL donde sea apropiado
- CHECK constraints para validación
- UNIQUE donde sea necesario
- Foreign keys siempre

❌ **DON'T:**
- Validación solo en app
- Permitir NULL sin razón
- Ignorar integridad referencial

---

**Documento mantenido por:** Equipo de Desarrollo SIGIMED
**Última actualización:** Noviembre 2025
**Próxima revisión:** Febrero 2026
**Versión del esquema:** 2.0.0
