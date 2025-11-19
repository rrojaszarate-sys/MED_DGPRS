# Documentación Técnica - SIGIMED v2.0

## Sistema de Gestión de Inventario de Medicamentos

**Versión:** 2.0.0
**Fecha:** Enero 2025
**Desarrollado para:** Dirección General de Protección y Regulación Sanitaria

---

## Tabla de Contenidos

1. [Arquitectura del Sistema](#1-arquitectura-del-sistema)
2. [Tecnologías Utilizadas](#2-tecnologías-utilizadas)
3. [Estructura del Proyecto](#3-estructura-del-proyecto)
4. [Base de Datos](#4-base-de-datos)
5. [Módulos Principales](#5-módulos-principales)
6. [Hooks y API](#6-hooks-y-api)
7. [Componentes UI](#7-componentes-ui)
8. [Autenticación y Seguridad](#8-autenticación-y-seguridad)
9. [Deployment](#9-deployment)
10. [Guía para Desarrolladores](#10-guía-para-desarrolladores)

---

## 1. Arquitectura del Sistema

### 1.1 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────┐
│                   FRONTEND (React)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │  Pages   │  │Components│  │  Hooks   │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │             │              │                 │
│       └─────────────┴──────────────┘                │
│                     │                                │
│              ┌──────▼──────┐                        │
│              │   Context   │                        │
│              │  (Auth/UI)  │                        │
│              └──────┬──────┘                        │
└─────────────────────┼──────────────────────────────┘
                      │
                      │ HTTPS/WSS
                      │
┌─────────────────────▼──────────────────────────────┐
│              SUPABASE (Backend)                     │
│  ┌──────────────┐  ┌──────────────┐               │
│  │ PostgreSQL   │  │ Realtime     │               │
│  │   Database   │  │ Subscriptions│               │
│  └──────┬───────┘  └──────────────┘               │
│         │                                           │
│  ┌──────▼────────┐  ┌──────────────┐              │
│  │ Row Level     │  │ Auth Service │              │
│  │ Security (RLS)│  │   (JWT)      │              │
│  └───────────────┘  └──────────────┘              │
└───────────────────────────────────────────────────┘
```

### 1.2 Patrón de Arquitectura

**Tipo:** Single Page Application (SPA) con arquitectura Cliente-Servidor

**Características:**
- **Frontend:** React 18 con TypeScript
- **Backend:** Supabase (PostgreSQL + API REST + Realtime)
- **Estado:** Context API + Custom Hooks
- **Routing:** React Router v6
- **Styling:** Tailwind CSS

---

## 2. Tecnologías Utilizadas

### 2.1 Frontend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| React | 18.2.0 | Framework UI |
| TypeScript | 5.2.2 | Tipado estático |
| Vite | 5.0.8 | Build tool |
| React Router | 6.20.0 | Enrutamiento |
| Tailwind CSS | 3.3.6 | Estilos |
| Lucide React | 0.294.0 | Iconografía |
| Recharts | 2.10.3 | Gráficas |
| React Hot Toast | 2.6.0 | Notificaciones |
| date-fns | 2.30.0 | Manejo de fechas |

### 2.2 Backend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Supabase | Latest | BaaS (Backend as a Service) |
| PostgreSQL | 15+ | Base de datos |
| PostgREST | - | API REST automática |
| Realtime | - | WebSocket subscriptions |

### 2.3 Utilidades

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| jsPDF | 2.5.1 | Generación de PDFs |
| jsPDF AutoTable | 3.8.2 | Tablas en PDF |
| XLSX | 0.18.5 | Exportar Excel |
| PapaParse | 5.5.3 | Parse CSV |

### 2.4 Testing

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Vitest | Latest | Test runner |
| Testing Library | Latest | Testing utilidades |
| jsdom | Latest | DOM virtual |

---

## 3. Estructura del Proyecto

```
MED_DGPRS/
├── .github/
│   └── workflows/          # CI/CD pipelines
├── docs/                   # Documentación
│   ├── DOCUMENTACION_TECNICA.md
│   ├── PLAN_PRUEBAS_AUTOMATIZADAS.md
│   ├── PRUEBAS_ESCRITORIO_INTERNAS.md
│   └── VALIDACION_EXTERNA_QA.md
├── scripts/                # Scripts SQL
│   ├── INSTALAR_BD_COMPLETA.sql
│   ├── PRUEBAS_INVENTARIO_ALEATORIO.sql
│   └── PRODUCCION_BD_LIMPIA.sql
├── src/
│   ├── components/         # Componentes React
│   │   ├── admin/          # Administración
│   │   ├── auth/           # Autenticación
│   │   ├── batches/        # Lotes
│   │   ├── catalogos/      # Catálogos
│   │   ├── contracts/      # Contratos
│   │   ├── dashboard/      # Dashboard
│   │   ├── inventory/      # Inventario
│   │   ├── layout/         # Layout general
│   │   ├── movements/      # Movimientos
│   │   ├── suppliers/      # Proveedores
│   │   └── ui/             # Componentes UI base
│   ├── context/            # Context API
│   │   ├── AuthContext.tsx
│   │   └── CentroContext.tsx
│   ├── hooks/              # Custom Hooks
│   │   ├── useAuth.ts
│   │   ├── useMedicamentos.ts
│   │   ├── useLotes.ts
│   │   ├── useMovements.ts
│   │   ├── useSuppliers.ts
│   │   ├── useCatalogos.ts
│   │   ├── useInstituciones.ts
│   │   ├── useCentros.ts
│   │   ├── useAlertas.ts
│   │   └── __tests__/      # Tests unitarios
│   ├── lib/                # Librerías
│   │   └── supabase.ts     # Cliente Supabase
│   ├── pages/              # Páginas
│   │   ├── DashboardPage.tsx
│   │   ├── InventoryPage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── AdminPage.tsx
│   │   ├── CatalogosPage.tsx
│   │   ├── InstitutionsPage.tsx
│   │   ├── HealthCentersPage.tsx
│   │   ├── MovementsPage.tsx
│   │   ├── SuppliersPage.tsx
│   │   ├── ReportsPage.tsx
│   │   ├── AlertasPage.tsx
│   │   └── ContractsPage.tsx
│   ├── test/               # Setup de tests
│   │   └── setup.ts
│   ├── types/              # TypeScript types
│   │   └── index.ts
│   ├── utils/              # Utilidades
│   │   ├── exportUtils.ts
│   │   └── importUtils.ts
│   ├── App.tsx             # Componente raíz
│   ├── main.tsx            # Entry point
│   └── vite-env.d.ts
├── .env.local              # Variables de entorno (desarrollo)
├── .env.production         # Variables de entorno (producción)
├── index.html
├── package.json
├── tailwind.config.js
├── tsconfig.json
├── vite.config.ts
└── vitest.config.ts
```

---

## 4. Base de Datos

### 4.1 Diagrama Entidad-Relación

```
┌─────────────────┐
│  instituciones  │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐
│ centros_salud   │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐       ┌──────────────────────┐
│  medicamentos   │◄──────│catalogo_medicamentos │
└────────┬────────┘  N:1  └──────────────────────┘
         │ 1:N
         ▼
┌─────────────────┐       ┌──────────────────┐
│     lotes       │◄──────│   proveedores    │
└────────┬────────┘  N:1  └──────────────────┘
         │ 1:N
         ▼
┌─────────────────┐
│movimientos_lotes│
└─────────────────┘
```

### 4.2 Tablas Principales

#### **instituciones**
Almacena instituciones de salud

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK, auto-generado |
| name | TEXT | Nombre de la institución |
| tipo | TEXT | Tipo (Hospital, Clínica, etc.) |
| rfc | TEXT | RFC único |
| is_active | BOOLEAN | Estado activo/inactivo |
| created_at | TIMESTAMPTZ | Fecha de creación |

#### **centros_salud**
Centros de salud pertenecientes a instituciones

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK, auto-generado |
| name | TEXT | Nombre del centro |
| code | TEXT | Código único |
| institucion_id | UUID | FK a instituciones |
| direccion | TEXT | Dirección física |
| ciudad | TEXT | Ciudad |
| estado | TEXT | Estado |
| is_active | BOOLEAN | Estado activo/inactivo |

#### **catalogo_medicamentos**
Catálogo general de medicamentos

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK, auto-generado |
| nombre | TEXT | Nombre comercial |
| nombre_generico | TEXT | Nombre genérico |
| presentacion | TEXT | Presentación |
| concentracion | TEXT | Concentración |
| forma_farmaceutica_id | UUID | FK a catálogo |
| via_administracion_id | UUID | FK a catálogo |
| is_active | BOOLEAN | Estado activo/inactivo |

#### **medicamentos**
Inventario de medicamentos por centro

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK |
| center_id | UUID | FK a centros_salud |
| catalog_id | UUID | FK a catalogo_medicamentos |
| nombre | TEXT | Nombre |
| formula_activa | TEXT | Fórmula activa (NOT NULL) |
| lote | TEXT | Número de lote (NOT NULL) |
| cantidad | INTEGER | Cantidad disponible (≥0) |
| fecha_caducidad | DATE | Fecha de caducidad (NOT NULL) |
| estado | TEXT | 'Disponible', 'No Disponible', 'Cuarentena', 'Vencido' |
| proveedor_id | UUID | FK a proveedores |
| ubicacion_fisica | TEXT | Ubicación en almacén |

**CHECK Constraints:**
- `cantidad >= 0`
- `estado IN ('Disponible', 'No Disponible', 'Cuarentena', 'Vencido')`

#### **lotes**
Control de lotes de medicamentos

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK |
| medication_id | UUID | FK a medicamentos |
| medication_catalog_id | UUID | FK a catalogo_medicamentos |
| centro_id | UUID | FK a centros_salud |
| numero_lote | TEXT | Número de lote (NOT NULL) |
| cantidad_inicial | INTEGER | Cantidad inicial (≥0) |
| cantidad_actual | INTEGER | Cantidad actual (≥0) |
| fecha_fabricacion | DATE | Fecha de fabricación |
| fecha_caducidad | DATE | Fecha de caducidad (NOT NULL) |
| estado | TEXT | 'disponible', 'cuarentena', 'vencido', 'agotado' |
| stock_minimo | INTEGER | Stock mínimo |
| is_active | BOOLEAN | Activo |

**UNIQUE Constraint:**
- `(medication_catalog_id, numero_lote, centro_id)`

**CHECK Constraints:**
- `cantidad_inicial >= 0`
- `cantidad_actual >= 0`
- `estado IN ('disponible', 'cuarentena', 'vencido', 'agotado')`

#### **movimientos_lotes**
Historial de movimientos de inventario

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK |
| batch_id | UUID | FK a lotes |
| medication_id | UUID | FK a medicamentos |
| center_id | UUID | FK a centros_salud |
| tipo_movimiento | TEXT | Tipo de movimiento |
| cantidad | INTEGER | Cantidad del movimiento |
| cantidad_anterior | INTEGER | Cantidad antes del movimiento |
| cantidad_posterior | INTEGER | Cantidad después del movimiento |
| motivo | TEXT | Motivo del movimiento (NOT NULL) |
| observaciones | TEXT | Observaciones |
| created_at | TIMESTAMPTZ | Fecha del movimiento |

**Tipos de movimiento:**
- `'entrada'`: Ingreso de nuevo stock
- `'salida'`: Dispensación o uso
- `'ajuste'`: Ajuste de inventario
- `'transferencia_salida'`: Envío a otro centro
- `'transferencia_entrada'`: Recepción de otro centro
- `'devolucion'`: Devolución
- `'merma'`: Pérdida o merma
- `'vencimiento'`: Baja por vencimiento
- `'destruccion'`: Destrucción

#### **proveedores**
Proveedores de medicamentos

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | UUID | PK |
| nombre | TEXT | Nombre del proveedor (NOT NULL) |
| rfc | TEXT | RFC |
| razon_social | TEXT | Razón social |
| direccion | TEXT | Dirección |
| ciudad | TEXT | Ciudad |
| telefono | TEXT | Teléfono |
| email | TEXT | Email |
| terminos_pago | TEXT | Términos de pago |
| dias_credito | INTEGER | Días de crédito |
| calificacion | NUMERIC | Calificación (0-5) |
| is_active | BOOLEAN | Activo |

### 4.3 Vistas

Para compatibilidad con el frontend (español → inglés):

```sql
CREATE VIEW health_centers AS
SELECT id, name, code, direccion as address,
       ciudad as city, estado as region, ...
FROM centros_salud;

CREATE VIEW medications AS
SELECT id, center_id, catalog_id, nombre, ...
FROM medicamentos;

CREATE VIEW batches AS
SELECT id, medication_id, centro_id as center_id, ...
FROM lotes;

CREATE VIEW batch_movements AS
SELECT * FROM movimientos_lotes;

CREATE VIEW suppliers AS
SELECT * FROM proveedores;
```

### 4.4 Row Level Security (RLS)

Supabase implementa RLS para control de acceso a nivel de fila:

```sql
-- Ejemplo: Solo usuarios autenticados pueden leer medicamentos
CREATE POLICY "Allow read for authenticated users"
ON medicamentos FOR SELECT
TO authenticated
USING (true);

-- Ejemplo: Solo administradores pueden insertar
CREATE POLICY "Allow insert for admins"
ON medicamentos FOR INSERT
TO authenticated
WITH CHECK (
  auth.jwt() ->> 'role' = 'admin'
);
```

---

## 5. Módulos Principales

### 5.1 Autenticación y Usuarios

**Archivo:** `src/context/AuthContext.tsx`

**Roles de usuario:**
- **admin**: Administrador completo
- **almacenista**: Gestión de inventario y lotes
- **farmaceutico**: Dispensación de medicamentos
- **consulta**: Solo lectura

**Funcionalidades:**
- Login/Logout
- Persistencia de sesión
- Protección de rutas
- Control de acceso por roles

**Componentes:**
- `LoginPage.tsx`: Página de login
- `ProtectedRoute.tsx`: HOC para rutas protegidas
- `RoleGuard.tsx`: Control de acceso por rol

### 5.2 Dashboard

**Archivo:** `src/pages/DashboardPage.tsx`

**Funcionalidades:**
- Vista general del inventario
- Alertas de stock bajo
- Medicamentos próximos a vencer
- Gráficas de movimientos
- Selector de centro de salud

**Widgets:**
- Total de medicamentos
- Lotes activos
- Movimientos del mes
- Alertas críticas

### 5.3 Instituciones

**Archivo:** `src/pages/InstitutionsPage.tsx`

**Funcionalidades:**
- CRUD de instituciones
- Búsqueda y filtrado
- Validación de RFC único
- Soft delete (is_active)

**Campos:**
- Nombre, Tipo, RFC
- Dirección completa
- Contacto
- Estado activo/inactivo

### 5.4 Centros de Salud

**Archivo:** `src/pages/HealthCentersPage.tsx`

**Funcionalidades:**
- CRUD de centros
- Asignación a institución
- Código único por centro
- Filtrado por institución

**Campos:**
- Nombre, Código
- Institución (FK)
- Dirección, Ciudad, Estado
- Responsable

### 5.5 Catálogos Administrables

**Archivo:** `src/pages/CatalogosPage.tsx`

**Catálogos:**
1. Formas Farmacéuticas (tableta, cápsula, etc.)
2. Vías de Administración (oral, intravenosa, etc.)
3. Unidades de Medida (mg, ml, g, etc.)
4. Tipos de Medicamento (genérico, patente, etc.)
5. Colores
6. Olores

**Funcionalidades:**
- CRUD para cada catálogo
- Validación de nombres únicos
- Activación/desactivación

### 5.6 Catálogo de Medicamentos

**Archivo:** `src/pages/AdminPage.tsx`

**Funcionalidades:**
- CRUD de medicamentos en catálogo general
- Asignación de:
  - Forma farmacéutica
  - Vía de administración
  - Tipo de medicamento
  - Color, Olor
- Búsqueda avanzada
- Importación masiva desde Excel

**Campos:**
- Nombre comercial / genérico
- Presentación, Concentración
- Código de barras
- Relaciones con catálogos

### 5.7 Inventario de Medicamentos

**Archivo:** `src/pages/InventoryPage.tsx`

**Funcionalidades:**
- Vista de inventario por centro
- Búsqueda por nombre/código
- Filtros por estado
- Detección de alertas
- Exportar a Excel/PDF

**Alertas automáticas:**
- Stock bajo mínimo
- Próximos a vencer (3 meses)
- Medicamentos vencidos
- En cuarentena

### 5.8 Gestión de Lotes

**Componente:** `BatchFormModal.tsx`

**Funcionalidades:**
- Crear nuevo lote
- Editar lote existente
- Validación de número único
- Control de fechas
- Cambio de estado

**Estados de lote:**
- disponible
- cuarentena
- vencido
- agotado

### 5.9 Movimientos de Inventario

**Archivo:** `src/pages/MovementsPage.tsx`

**Tipos de movimiento:**
1. **Entrada**: Recepción de nuevo stock
2. **Salida**: Dispensación a pacientes
3. **Ajuste**: Corrección de inventario
4. **Transferencia**: Entre centros
5. **Devolución**: Devolución de áreas
6. **Merma**: Pérdidas
7. **Vencimiento**: Baja por caducidad
8. **Destrucción**: Destrucción de medicamentos

**Funcionalidades:**
- Registro de movimientos
- Validación de stock disponible
- Actualización automática de cantidades
- Historial completo
- Timeline de movimientos
- Exportar historial

### 5.10 Proveedores

**Archivo:** `src/pages/SuppliersPage.tsx`

**Funcionalidades:**
- CRUD de proveedores
- Registro completo de datos
- Calificación de proveedores
- Términos de pago
- Historial de compras

### 5.11 Reportes

**Archivo:** `src/pages/ReportsPage.tsx`

**Tipos de reportes:**
1. Inventario general
2. Movimientos por período
3. Medicamentos por vencer
4. Stock bajo
5. Consumo por medicamento
6. Valorización de inventario

**Formatos de exportación:**
- Excel (.xlsx)
- PDF
- CSV

### 5.12 Alertas

**Archivo:** `src/pages/AlertasPage.tsx`

**Tipos de alertas:**
- Stock bajo mínimo
- Próximos a vencer
- Vencidos
- En cuarentena
- Sin movimientos (90 días)

---

## 6. Hooks y API

### 6.1 Estructura de Hooks

Todos los hooks siguen el patrón:

```typescript
export function useHook() {
  const [data, setData] = useState<Type[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    // Fetch from Supabase
  };

  const create = async (item: Type) => {
    // Insert
  };

  const update = async (id: string, item: Partial<Type>) => {
    // Update
  };

  const remove = async (id: string) => {
    // Delete
  };

  return {
    data,
    loading,
    error,
    create,
    update,
    remove,
    refresh: fetchData,
  };
}
```

### 6.2 Hooks Disponibles

#### **useMedicamentos(centerId?: string)**
Gestión de inventario de medicamentos

```typescript
const {
  medicamentos,
  loading,
  error,
  createMedicamento,
  updateMedicamento,
  deleteMedicamento,
  refresh,
} = useMedicamentos(centerId);
```

#### **useLotes(medicamentoId?: string)**
Gestión de lotes

```typescript
const {
  lotes,
  loading,
  error,
  createLote,
  updateLote,
  deleteLote,
  refresh,
} = useLotes(medicamentoId);
```

#### **useMovements(centerId?: string)**
Gestión de movimientos

```typescript
const {
  movements,
  loading,
  error,
  createMovement,
  refresh,
} = useMovements(centerId);
```

#### **useSuppliers()**
Gestión de proveedores

```typescript
const {
  suppliers,
  loading,
  error,
  createSupplier,
  updateSupplier,
  deleteSupplier,
  refresh,
} = useSuppliers();
```

#### **useCatalogos(tipo: string)**
Gestión de catálogos administrables

```typescript
const {
  catalogos,
  loading,
  error,
  create,
  update,
  remove,
  refresh,
} = useCatalogos('formas_farmaceuticas');
```

#### **useAlertas(centerId?: string)**
Sistema de alertas

```typescript
const {
  alertas,
  loading,
  stockBajo,
  proximosVencer,
  vencidos,
  enCuarentena,
} = useAlertas(centerId);
```

#### **useRealtime(table: string, callback)**
Suscripciones en tiempo real

```typescript
useRealtime('medicamentos', (payload) => {
  console.log('Change received!', payload);
});
```

### 6.3 Cliente Supabase

**Archivo:** `src/lib/supabase.ts`

```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

**Operaciones básicas:**

```typescript
// SELECT
const { data, error } = await supabase
  .from('medicamentos')
  .select('*')
  .eq('center_id', centerId);

// INSERT
const { data, error } = await supabase
  .from('medicamentos')
  .insert([{ nombre: 'Paracetamol', ... }]);

// UPDATE
const { data, error } = await supabase
  .from('medicamentos')
  .update({ cantidad: 100 })
  .eq('id', medicamentoId);

// DELETE
const { data, error } = await supabase
  .from('medicamentos')
  .delete()
  .eq('id', medicamentoId);
```

---

## 7. Componentes UI

### 7.1 Componentes Base

Ubicados en `src/components/ui/`

#### **Button**
```typescript
<Button variant="primary" onClick={handleClick}>
  Guardar
</Button>
```

Variantes: `primary`, `secondary`, `danger`, `ghost`

#### **Input**
```typescript
<Input
  label="Nombre"
  value={nombre}
  onChange={(e) => setNombre(e.target.value)}
  required
/>
```

#### **Select**
```typescript
<Select
  label="Estado"
  options={[
    { value: 'activo', label: 'Activo' },
    { value: 'inactivo', label: 'Inactivo' },
  ]}
  value={estado}
  onChange={(e) => setEstado(e.target.value)}
/>
```

#### **Modal**
```typescript
<Modal
  isOpen={isOpen}
  onClose={() => setIsOpen(false)}
  title="Nuevo Medicamento"
>
  {/* Contenido */}
</Modal>
```

#### **Table**
```typescript
<Table
  columns={[
    { key: 'nombre', label: 'Nombre' },
    { key: 'cantidad', label: 'Cantidad' },
  ]}
  data={medicamentos}
  onEdit={handleEdit}
  onDelete={handleDelete}
/>
```

#### **Card**
```typescript
<Card title="Total Medicamentos" value={1000} icon={Package} />
```

#### **Badge**
```typescript
<Badge variant="success">Disponible</Badge>
<Badge variant="warning">Bajo Stock</Badge>
<Badge variant="danger">Vencido</Badge>
```

#### **Toast**
```typescript
import { toast } from 'react-hot-toast';

toast.success('Medicamento creado exitosamente');
toast.error('Error al guardar');
toast.loading('Guardando...');
```

### 7.2 Componentes de Layout

#### **MainLayout**
Layout principal con sidebar y header

```typescript
<MainLayout>
  {/* Contenido de la página */}
</MainLayout>
```

### 7.3 Componentes Especializados

- **BatchFormModal**: Formulario de lotes
- **BatchMovementModal**: Registro de movimientos
- **CatalogoTable**: Tabla de catálogos administrables
- **ContractFormModal**: Formulario de contratos
- **ImportMedications**: Importación masiva
- **MovementTimeline**: Timeline de movimientos
- **SupplierFormModal**: Formulario de proveedores

---

## 8. Autenticación y Seguridad

### 8.1 Flujo de Autenticación

```
1. Usuario ingresa credenciales
   ↓
2. Supabase Auth valida usuario
   ↓
3. Genera JWT token
   ↓
4. Token almacenado en localStorage
   ↓
5. AuthContext provee estado global
   ↓
6. ProtectedRoute valida token en cada ruta
   ↓
7. RoleGuard valida permisos por rol
```

### 8.2 AuthContext

```typescript
interface AuthContextType {
  user: User | null;
  role: UserRole | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}
```

### 8.3 Protección de Rutas

```typescript
<Route
  path="/admin"
  element={
    <ProtectedRoute allowedRoles={['admin']}>
      <AdminPage />
    </ProtectedRoute>
  }
/>
```

### 8.4 Row Level Security (RLS)

Políticas de seguridad implementadas en Supabase:

```sql
-- Solo usuarios autenticados
CREATE POLICY authenticated_read
ON medicamentos FOR SELECT
TO authenticated
USING (true);

-- Solo almacenistas y admins pueden insertar
CREATE POLICY almacenista_insert
ON medicamentos FOR INSERT
TO authenticated
WITH CHECK (
  auth.jwt() ->> 'role' IN ('admin', 'almacenista')
);

-- Farmacéuticos solo pueden actualizar cantidad (salidas)
CREATE POLICY farmaceutico_update
ON medicamentos FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'role' IN ('admin', 'farmaceutico')
)
WITH CHECK (true);
```

### 8.5 Buenas Prácticas de Seguridad

1. **Variables de entorno:** Nunca exponer credenciales en código
2. **JWT tokens:** Validación en cada request
3. **Input validation:** Validar todos los inputs del usuario
4. **SQL Injection:** Usar prepared statements (Supabase lo maneja)
5. **XSS Protection:** React escapa automáticamente
6. **HTTPS:** Siempre usar conexión segura
7. **Rate limiting:** Configurado en Supabase

---

## 9. Deployment

### 9.1 Despliegue en Vercel

**Configuración:**

1. Conectar repositorio de GitHub
2. Configurar variables de entorno:
   ```
   VITE_SUPABASE_URL=https://xxx.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJxxx...
   VITE_APP_NAME=SIGIMED
   VITE_APP_VERSION=2.0
   VITE_DEV_MODE=false
   NODE_ENV=production
   ```

3. Build settings:
   - **Framework:** Vite
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`

4. Deploy automático en cada push a `main`

**URL de producción:** `https://sigimed.vercel.app`

### 9.2 Configuración de Supabase

1. **Proyecto creado:** cyslhzynfuetthxngpoy
2. **URL:** https://cyslhzynfuetthxngpoy.supabase.co
3. **Región:** us-east-1

**Configuraciones:**
- Auth: Email/Password habilitado
- RLS: Habilitado en todas las tablas
- Realtime: Habilitado en tablas principales
- Storage: Configurado para archivos (opcional)

### 9.3 Scripts de Deployment

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "deploy": "npm run build && vercel --prod"
  }
}
```

### 9.4 CI/CD Pipeline

GitHub Actions (`.github/workflows/deploy.yml`):

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run build
      - run: npm run test:run
      - uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
```

---

## 10. Guía para Desarrolladores

### 10.1 Setup Local

```bash
# 1. Clonar repositorio
git clone https://github.com/rrojaszarate-sys/MED_DGPRS.git
cd MED_DGPRS

# 2. Instalar dependencias
npm install

# 3. Configurar variables de entorno
cp .env.example .env.local
# Editar .env.local con tus credenciales

# 4. Ejecutar en desarrollo
npm run dev

# 5. Abrir navegador
http://localhost:5173
```

### 10.2 Estructura de Commits

```
tipo(scope): descripción corta

Descripción detallada opcional

BREAKING CHANGE: descripción de cambio incompatible
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formato de código
- `refactor`: Refactorización
- `test`: Tests
- `chore`: Tareas de mantenimiento

**Ejemplo:**
```
feat(inventory): agregar exportación a Excel

- Implementar botón de exportar
- Usar librería XLSX
- Incluir todos los campos

Closes #123
```

### 10.3 Crear Nueva Funcionalidad

#### Paso 1: Crear Hook

```typescript
// src/hooks/useNuevaFuncionalidad.ts
export function useNuevaFuncionalidad() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    const { data, error } = await supabase
      .from('tabla')
      .select('*');

    if (error) throw error;
    setData(data);
    setLoading(false);
  };

  return { data, loading };
}
```

#### Paso 2: Crear Página

```typescript
// src/pages/NuevaPage.tsx
export default function NuevaPage() {
  const { data, loading } = useNuevaFuncionalidad();

  if (loading) return <div>Cargando...</div>;

  return (
    <MainLayout>
      <h1>Nueva Funcionalidad</h1>
      {/* Contenido */}
    </MainLayout>
  );
}
```

#### Paso 3: Agregar Ruta

```typescript
// src/App.tsx
<Route
  path="/nueva"
  element={
    <ProtectedRoute>
      <NuevaPage />
    </ProtectedRoute>
  }
/>
```

#### Paso 4: Crear Tests

```typescript
// src/hooks/__tests__/useNuevaFuncionalidad.test.ts
describe('useNuevaFuncionalidad', () => {
  it('debe cargar datos correctamente', async () => {
    const { result } = renderHook(() => useNuevaFuncionalidad());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.data).toHaveLength(5);
  });
});
```

### 10.4 Debugging

**Herramientas:**
- React DevTools
- Redux DevTools (si se usa)
- Supabase Studio (inspección de BD)
- Network tab (requests HTTP)

**Logs:**
```typescript
console.log('Debug:', data);
console.error('Error:', error);
console.table(array); // Tablas en consola
```

**Breakpoints:**
```typescript
debugger; // Detiene ejecución
```

### 10.5 Performance

**Optimizaciones:**

1. **Lazy loading de rutas:**
```typescript
const AdminPage = lazy(() => import('./pages/AdminPage'));
```

2. **Memoización:**
```typescript
const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);
const memoizedCallback = useCallback(() => doSomething(a, b), [a, b]);
```

3. **React.memo para componentes:**
```typescript
export default React.memo(MyComponent);
```

4. **Paginación en queries:**
```typescript
const { data } = await supabase
  .from('medicamentos')
  .select('*')
  .range(0, 9); // Primeros 10 registros
```

### 10.6 Convenciones de Código

**Nombres:**
- Componentes: PascalCase (`InventoryPage.tsx`)
- Hooks: camelCase con prefijo `use` (`useMedicamentos.ts`)
- Constantes: UPPER_SNAKE_CASE (`MAX_ITEMS = 100`)
- Variables/funciones: camelCase (`getUserData`)

**Archivos:**
- Componentes: `.tsx`
- Hooks/utils: `.ts`
- Tests: `.test.ts` o `.test.tsx`

**Organización:**
- Un componente por archivo
- Agrupar componentes relacionados
- Separar lógica de negocio en hooks

---

## Apéndices

### A. Variables de Entorno

```env
# Supabase
VITE_SUPABASE_URL=https://cyslhzynfuetthxngpoy.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# App
VITE_APP_NAME=SIGIMED
VITE_APP_VERSION=2.0.0
VITE_DEV_MODE=false

# Environment
NODE_ENV=production
```

### B. Scripts Útiles

```bash
# Desarrollo
npm run dev

# Build
npm run build

# Preview build
npm run preview

# Lint
npm run lint

# Tests
npm run test
npm run test:ui
npm run test:coverage

# Deploy
npm run deploy
```

### C. Recursos Adicionales

- **Documentación React:** https://react.dev
- **Documentación Supabase:** https://supabase.com/docs
- **Documentación Tailwind:** https://tailwindcss.com/docs
- **Documentación Vite:** https://vitejs.dev
- **Testing Library:** https://testing-library.com

---

**Actualizado:** 2025-01-19
**Versión del documento:** 1.0
**Autor:** Equipo de Desarrollo SIGIMED
