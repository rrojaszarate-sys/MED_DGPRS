# 🏗️ ARQUITECTURA DEL SISTEMA - SIGIMED v2.0

## Documentación Técnica de Arquitectura

**Documento:** Arquitectura del Sistema
**Versión:** 2.0.0
**Fecha:** Noviembre 2025
**Estado:** Producción

---

## 📑 ÍNDICE

1. [Visión General](#visión-general)
2. [Arquitectura de Alto Nivel](#arquitectura-de-alto-nivel)
3. [Arquitectura de Frontend](#arquitectura-de-frontend)
4. [Arquitectura de Backend](#arquitectura-de-backend)
5. [Flujo de Datos](#flujo-de-datos)
6. [Patrones de Diseño](#patrones-de-diseño)
7. [Seguridad](#seguridad)
8. [Escalabilidad](#escalabilidad)
9. [Performance](#performance)
10. [Decisiones Arquitectónicas](#decisiones-arquitectónicas)

---

## 🎯 VISIÓN GENERAL

### Tipo de Aplicación

SIGIMED v2.0 es una **Single Page Application (SPA)** moderna con arquitectura de tres capas:

- **Frontend SPA:** React 18 + TypeScript
- **Backend BaaS:** Supabase (PostgreSQL + PostgREST + GoTrue)
- **Edge Functions:** Supabase Edge (Deno Runtime)

### Principios Arquitectónicos

1. **Separación de Responsabilidades** - Capas claramente definidas
2. **Modularidad** - Componentes independientes y reutilizables
3. **Type Safety** - TypeScript en toda la aplicación
4. **Real-time First** - Subscripciones en tiempo real
5. **Security by Design** - RLS y validación en múltiples capas
6. **Progressive Enhancement** - Funcionalidad básica sin JavaScript

---

## 🏗️ ARQUITECTURA DE ALTO NIVEL

### Diagrama de Componentes

```
┌────────────────────────────────────────────────────────────────┐
│                       CAPA DE CLIENTE                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Web Browser                           │  │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐  │  │
│  │  │   React    │  │ TypeScript │  │  Tailwind CSS    │  │  │
│  │  │   18.2     │  │    5.2     │  │      3.3         │  │  │
│  │  └────────────┘  └────────────┘  └──────────────────┘  │  │
│  │                                                          │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │         React Router 6 (Client-side)              │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │                                                          │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │           Supabase JS Client                      │ │  │
│  │  │  • Auth (JWT)                                     │ │  │
│  │  │  • Database (REST API)                            │ │  │
│  │  │  • Realtime (WebSocket)                           │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS / WebSocket
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                    CAPA DE BACKEND (Supabase)                   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    API Gateway                           │  │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐  │  │
│  │  │  PostgREST │  │   GoTrue   │  │  Realtime        │  │  │
│  │  │  (REST)    │  │   (Auth)   │  │  (WebSocket)     │  │  │
│  │  └────────────┘  └────────────┘  └──────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │               PostgreSQL 14 Database                     │  │
│  │                                                          │  │
│  │  ┌────────────────┐  ┌────────────────┐  ┌──────────┐  │  │
│  │  │     Tables     │  │   Functions    │  │ Triggers │  │  │
│  │  │   (12 main)    │  │  (Validation)  │  │ (Audit)  │  │  │
│  │  └────────────────┘  └────────────────┘  └──────────┘  │  │
│  │                                                          │  │
│  │  ┌────────────────┐  ┌────────────────┐  ┌──────────┐  │  │
│  │  │      RLS       │  │    Indexes     │  │  Views   │  │  │
│  │  │  (Security)    │  │ (Performance)  │  │(Reports) │  │  │
│  │  └────────────────┘  └────────────────┘  └──────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Storage (S3)                          │  │
│  │  • PDFs de contratos                                    │  │
│  │  • Documentos de auditoría                              │  │
│  │  • Archivos de importación                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

### Capas Arquitectónicas

#### 1. Capa de Presentación

**Responsabilidad:** Interfaz de usuario y experiencia

**Tecnologías:**
- React 18 (UI Components)
- TypeScript 5 (Type Safety)
- Tailwind CSS 3 (Styling)
- Recharts 2 (Data Visualization)

**Componentes Principales:**
- 11 Páginas principales
- 23 Componentes reutilizables
- 13 Custom Hooks
- 2 Contextos globales

#### 2. Capa de Lógica de Negocio

**Responsabilidad:** Procesamiento y validación

**Implementación:**
- Custom Hooks (React)
- Utilidades de validación
- Transformación de datos
- Cache local (opcional)

**Componentes:**
- useAuth - Autenticación
- useBatches - Gestión de lotes
- useMovements - Movimientos
- useContracts - Contratos
- Y 9 hooks más especializados

#### 3. Capa de Datos

**Responsabilidad:** Persistencia y acceso a datos

**Tecnologías:**
- PostgreSQL 14
- PostgREST (API REST automática)
- Realtime (WebSocket)
- Row Level Security

**Esquema:**
- 12 tablas principales
- 8 migraciones aplicadas
- RLS en todas las tablas
- Triggers de auditoría

---

## 💻 ARQUITECTURA DE FRONTEND

### Estructura de Carpetas

```
src/
├── components/          # Componentes React
│   ├── ui/             # Componentes base (Button, Input, etc.)
│   ├── auth/           # Componentes de autenticación
│   ├── layout/         # Layouts y estructura
│   └── [domain]/       # Componentes por dominio
├── pages/              # Páginas principales
├── hooks/              # Custom hooks
├── context/            # Context API
├── lib/                # Configuración de librerías
├── types/              # Definiciones TypeScript
└── utils/              # Funciones utilitarias
```

### Patrón de Componentes

#### 1. Componentes UI (Presentacionales)

**Características:**
- Sin lógica de negocio
- Props tipadas
- Reutilizables
- Composables

**Ejemplo: Button.tsx**
```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  onClick?: () => void
  children: ReactNode
}

export function Button({
  variant = 'primary',
  size = 'md',
  onClick,
  children
}: ButtonProps) {
  const baseClasses = 'rounded-lg font-medium transition-colors'
  const variantClasses = {
    primary: 'bg-primary text-white hover:bg-primary-dark',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
    danger: 'bg-red-600 text-white hover:bg-red-700'
  }
  const sizeClasses = {
    sm: 'px-3 py-1 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg'
  }

  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]}`}
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

#### 2. Componentes de Dominio (Container)

**Características:**
- Contiene lógica de negocio
- Usa custom hooks
- Maneja estado local
- Integra componentes UI

**Ejemplo: InventoryPage.tsx**
```typescript
export function InventoryPage() {
  // Hooks de datos
  const { centroSeleccionado } = useCentro()
  const { batches, loading, createBatch, updateBatch } = useBatches(centroSeleccionado?.id)

  // Estado local
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedBatch, setSelectedBatch] = useState<Batch | null>(null)
  const [searchTerm, setSearchTerm] = useState('')

  // Handlers
  const handleCreate = async (data: BatchData) => {
    await createBatch(data)
    setIsModalOpen(false)
  }

  // Filtrado
  const filteredBatches = batches.filter(batch =>
    batch.medication?.nombre.toLowerCase().includes(searchTerm.toLowerCase())
  )

  // Render
  return (
    <div>
      <SearchBar value={searchTerm} onChange={setSearchTerm} />
      <BatchList batches={filteredBatches} onEdit={handleEdit} />
      {isModalOpen && <BatchModal onSubmit={handleCreate} />}
    </div>
  )
}
```

### Custom Hooks Pattern

**Estructura estándar de un hook:**

```typescript
export function useEntity(centroId?: string) {
  // Estado
  const [data, setData] = useState<Entity[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Fetch inicial
  useEffect(() => {
    if (!centroId) return
    fetchData()
  }, [centroId])

  // Real-time subscriptions
  useRealtime({
    table: 'entities',
    onInsert: (newEntity) => setData(prev => [newEntity, ...prev]),
    onUpdate: (updatedEntity) => setData(prev =>
      prev.map(e => e.id === updatedEntity.id ? updatedEntity : e)
    ),
    onDelete: (deletedId) => setData(prev =>
      prev.filter(e => e.id !== deletedId)
    )
  })

  // CRUD Operations
  async function create(entity: Omit<Entity, 'id' | 'created_at'>) {
    try {
      const { data, error } = await supabase
        .from('entities')
        .insert([entity])
        .select()
        .single()

      if (error) throw error
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function update(id: string, updates: Partial<Entity>) {
    // Similar pattern
  }

  async function remove(id: string) {
    // Similar pattern
  }

  return {
    data,
    loading,
    error,
    create,
    update,
    remove,
    refresh: fetchData
  }
}
```

### Context API Pattern

**AuthContext - Gestión de Autenticación**

```typescript
interface AuthContextType {
  user: User | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Listen for changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password
    })
    if (error) throw error
  }

  const signOut = async () => {
    await supabase.auth.signOut()
  }

  return (
    <AuthContext.Provider value={{ user, loading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}
```

### Routing Architecture

**React Router 6 - Client-side Routing**

```typescript
// App.tsx
function App() {
  return (
    <Router>
      <Routes>
        {/* Public Route */}
        <Route path="/login" element={<LoginPage />} />

        {/* Protected Routes */}
        <Route path="/" element={
          <ProtectedRoute>
            <MainLayout>
              <DashboardPage />
            </MainLayout>
          </ProtectedRoute>
        } />

        {/* Role-based Routes */}
        <Route path="/admin" element={
          <ProtectedRoute>
            <RoleGuard allowedRoles={['super_admin', 'admin_center']}>
              <MainLayout>
                <AdminPage />
              </MainLayout>
            </RoleGuard>
          </ProtectedRoute>
        } />

        {/* Catch-all */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  )
}
```

**Protected Route HOC:**

```typescript
export function ProtectedRoute({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth()
  const location = useLocation()

  if (loading) {
    return <LoadingSpinner />
  }

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  return <>{children}</>
}
```

---

## 🗄️ ARQUITECTURA DE BACKEND

### Supabase Stack

**Componentes Principales:**

1. **PostgreSQL 14** - Base de datos relacional
2. **PostgREST** - API REST automática
3. **GoTrue** - Servicio de autenticación
4. **Realtime** - WebSocket server
5. **Storage** - Almacenamiento de archivos

### Database Schema

**Tablas Principales (12):**

```sql
-- Usuarios y Centros
users               -- Usuarios del sistema
health_centers      -- Centros de salud
instituciones       -- Instituciones médicas

-- Catálogo
medication_catalog  -- Catálogo de medicamentos

-- Inventario
medications         -- Medicamentos por centro
batches             -- Lotes de medicamentos
batch_movements     -- Movimientos de lotes

-- Proveedores y Contratos
suppliers           -- Proveedores
contracts           -- Contratos
contract_items      -- Items de contrato

-- Sistema
alerts              -- Alertas
audit_logs          -- Auditoría
```

### Row Level Security (RLS)

**Políticas de Seguridad:**

```sql
-- Ejemplo: Política para batches
CREATE POLICY "Users can view batches from their center" ON batches
  FOR SELECT
  USING (
    center_id IN (
      SELECT id FROM health_centers
      WHERE id = auth.jwt() ->> 'center_id'
    )
  );

CREATE POLICY "Only admins can insert batches" ON batches
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Only admins can update batches" ON batches
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('super_admin', 'admin_center')
    )
  );

CREATE POLICY "Only super_admin can delete batches" ON batches
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );
```

### Triggers y Functions

**Audit Logging Trigger:**

```sql
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_logs (
    user_id,
    action_type,
    entity_type,
    entity_id,
    old_values,
    new_values,
    created_at
  ) VALUES (
    auth.uid(),
    TG_OP,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    row_to_json(OLD),
    row_to_json(NEW),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger a todas las tablas críticas
CREATE TRIGGER audit_batches
  AFTER INSERT OR UPDATE OR DELETE ON batches
  FOR EACH ROW EXECUTE FUNCTION audit_changes();
```

**Validation Function:**

```sql
CREATE OR REPLACE FUNCTION validate_batch_movement()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar cantidad suficiente para salida
  IF NEW.tipo_movimiento IN ('salida', 'transferencia_salida') THEN
    IF (SELECT cantidad_actual FROM batches WHERE id = NEW.batch_id) < NEW.cantidad THEN
      RAISE EXCEPTION 'Cantidad insuficiente en lote';
    END IF;
  END IF;

  -- Validar fecha de caducidad
  IF (SELECT fecha_caducidad FROM batches WHERE id = NEW.batch_id) < CURRENT_DATE THEN
    RAISE EXCEPTION 'Lote vencido, no se pueden realizar movimientos';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_movement
  BEFORE INSERT ON batch_movements
  FOR EACH ROW EXECUTE FUNCTION validate_batch_movement();
```

### Realtime Subscriptions

**WebSocket Channels:**

```typescript
// Frontend: Subscribe to changes
const channel = supabase
  .channel('batches_changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'batches',
      filter: `center_id=eq.${centroId}`
    },
    (payload) => {
      console.log('Change received!', payload)
      // Update local state
    }
  )
  .subscribe()

// Cleanup
return () => {
  supabase.removeChannel(channel)
}
```

---

## 🔄 FLUJO DE DATOS

### Flujo de Lectura (Query)

```
┌─────────────┐
│  Component  │
└──────┬──────┘
       │ 1. Call hook
       ▼
┌─────────────┐
│ Custom Hook │
└──────┬──────┘
       │ 2. Query Supabase
       ▼
┌─────────────┐
│   Supabase  │
│   Client    │
└──────┬──────┘
       │ 3. HTTP Request
       ▼
┌─────────────┐
│  PostgREST  │
│   (API)     │
└──────┬──────┘
       │ 4. SQL Query
       ▼
┌─────────────┐
│ PostgreSQL  │
│  + RLS      │
└──────┬──────┘
       │ 5. Check RLS
       │ 6. Return data
       ▼
┌─────────────┐
│   Response  │
└──────┬──────┘
       │ 7. Transform
       ▼
┌─────────────┐
│   useState  │
└──────┬──────┘
       │ 8. Re-render
       ▼
┌─────────────┐
│     UI      │
└─────────────┘
```

### Flujo de Escritura (Mutation)

```
┌─────────────┐
│  User Input │
└──────┬──────┘
       │ 1. Form submit
       ▼
┌─────────────┐
│ Validation  │
│  (Client)   │
└──────┬──────┘
       │ 2. Call create/update
       ▼
┌─────────────┐
│ Custom Hook │
└──────┬──────┘
       │ 3. Optimistic update (optional)
       │ 4. API call
       ▼
┌─────────────┐
│   Supabase  │
│   Client    │
└──────┬──────┘
       │ 5. HTTP POST/PATCH
       ▼
┌─────────────┐
│  PostgREST  │
└──────┬──────┘
       │ 6. SQL INSERT/UPDATE
       ▼
┌─────────────┐
│ PostgreSQL  │
│  + RLS      │
│  + Triggers │
└──────┬──────┘
       │ 7. Check RLS
       │ 8. Execute triggers
       │ 9. Audit log
       │ 10. Notify subscribers
       ▼
┌─────────────┐
│  Realtime   │
│   Server    │
└──────┬──────┘
       │ 11. WebSocket push
       ▼
┌─────────────┐
│ Subscribers │
│  (Other     │
│   Users)    │
└──────┬──────┘
       │ 12. Update UI
       ▼
┌─────────────┐
│  Toast      │
│Notification │
└─────────────┘
```

### Flujo de Autenticación

```
┌─────────────┐
│ LoginPage   │
└──────┬──────┘
       │ 1. Submit email/password
       ▼
┌─────────────┐
│ AuthContext │
│  .signIn()  │
└──────┬──────┘
       │ 2. Call Supabase Auth
       ▼
┌─────────────┐
│   GoTrue    │
│   (Auth)    │
└──────┬──────┘
       │ 3. Verify credentials
       │ 4. Generate JWT
       ▼
┌─────────────┐
│     JWT     │
│   Token     │
└──────┬──────┘
       │ 5. Set in localStorage
       │ 6. Set in HTTP headers
       ▼
┌─────────────┐
│ onAuthState │
│   Change    │
└──────┬──────┘
       │ 7. Update context
       ▼
┌─────────────┐
│   Redirect  │
│     to      │
│  Dashboard  │
└─────────────┘
```

---

## 🎨 PATRONES DE DISEÑO

### 1. Container/Presentational Pattern

**Separación clara entre lógica y presentación:**

```typescript
// Container (InventoryPage.tsx)
export function InventoryPage() {
  const { batches, loading } = useBatches()
  const [search, setSearch] = useState('')

  const filtered = batches.filter(b =>
    b.medication?.nombre.includes(search)
  )

  return (
    <InventoryView
      batches={filtered}
      loading={loading}
      search={search}
      onSearchChange={setSearch}
    />
  )
}

// Presentational (InventoryView.tsx)
interface InventoryViewProps {
  batches: Batch[]
  loading: boolean
  search: string
  onSearchChange: (value: string) => void
}

export function InventoryView({
  batches,
  loading,
  search,
  onSearchChange
}: InventoryViewProps) {
  return (
    <div>
      <SearchBar value={search} onChange={onSearchChange} />
      {loading ? <Spinner /> : <BatchList batches={batches} />}
    </div>
  )
}
```

### 2. Custom Hooks Pattern

**Encapsulación de lógica reutilizable:**

```typescript
// useEntity.ts
export function useEntity<T>(
  table: string,
  filter?: Record<string, any>
) {
  const [data, setData] = useState<T[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchData()
  }, [table, filter])

  async function fetchData() {
    let query = supabase.from(table).select('*')

    if (filter) {
      Object.entries(filter).forEach(([key, value]) => {
        query = query.eq(key, value)
      })
    }

    const { data, error } = await query
    if (!error) setData(data)
    setLoading(false)
  }

  return { data, loading, refresh: fetchData }
}

// Usage
const { data: batches, loading } = useEntity<Batch>(
  'batches',
  { center_id: centroId }
)
```

### 3. Observer Pattern (Real-time)

**Subscripción a cambios:**

```typescript
export function useRealtime<T>(config: RealtimeConfig<T>) {
  useEffect(() => {
    const channel = supabase
      .channel(`${config.table}_changes`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: config.table,
          filter: config.filter
        },
        (payload) => {
          switch (payload.eventType) {
            case 'INSERT':
              config.onInsert?.(payload.new as T)
              break
            case 'UPDATE':
              config.onUpdate?.(payload.new as T)
              break
            case 'DELETE':
              config.onDelete?.(payload.old.id)
              break
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [config.table])
}
```

### 4. HOC Pattern (Higher Order Components)

**Composición de comportamiento:**

```typescript
// withAuth HOC
export function withAuth<P extends object>(
  Component: ComponentType<P>
) {
  return function AuthenticatedComponent(props: P) {
    const { user, loading } = useAuth()

    if (loading) return <LoadingSpinner />
    if (!user) return <Navigate to="/login" />

    return <Component {...props} />
  }
}

// Usage
export const ProtectedDashboard = withAuth(DashboardPage)
```

### 5. Render Props Pattern

**Flexibilidad en rendering:**

```typescript
interface DataFetcherProps<T> {
  url: string
  children: (data: T | null, loading: boolean) => ReactNode
}

export function DataFetcher<T>({ url, children }: DataFetcherProps<T>) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => {
        setData(data)
        setLoading(false)
      })
  }, [url])

  return <>{children(data, loading)}</>
}

// Usage
<DataFetcher url="/api/batches">
  {(batches, loading) => (
    loading ? <Spinner /> : <BatchList batches={batches} />
  )}
</DataFetcher>
```

### 6. Compound Components Pattern

**Componentes que trabajan juntos:**

```typescript
// Modal compound component
export function Modal({ children }: { children: ReactNode }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50">
      {children}
    </div>
  )
}

Modal.Header = function ModalHeader({ title }: { title: string }) {
  return <h2 className="text-xl font-bold">{title}</h2>
}

Modal.Body = function ModalBody({ children }: { children: ReactNode }) {
  return <div className="p-6">{children}</div>
}

Modal.Footer = function ModalFooter({ children }: { children: ReactNode }) {
  return <div className="flex justify-end gap-2 p-4">{children}</div>
}

// Usage
<Modal>
  <Modal.Header title="Crear Lote" />
  <Modal.Body>
    <BatchForm />
  </Modal.Body>
  <Modal.Footer>
    <Button onClick={onSave}>Guardar</Button>
  </Modal.Footer>
</Modal>
```

---

## 🔒 SEGURIDAD

### Múltiples Capas de Seguridad

```
┌────────────────────────────────────────────┐
│   1. Client-side Validation (TypeScript)   │
│   - Type checking                          │
│   - Input validation                       │
│   - Format validation                      │
└────────────────┬───────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────┐
│   2. Authentication (JWT)                  │
│   - GoTrue auth                            │
│   - Secure token storage                   │
│   - Token refresh                          │
└────────────────┬───────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────┐
│   3. Authorization (RLS)                   │
│   - Row Level Security                     │
│   - Role-based access                      │
│   - Center-based isolation                 │
└────────────────┬───────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────┐
│   4. Database Constraints                  │
│   - Foreign keys                           │
│   - Check constraints                      │
│   - Not null constraints                   │
└────────────────┬───────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────┐
│   5. Triggers & Functions                  │
│   - Business rule validation               │
│   - Audit logging                          │
│   - Data integrity checks                  │
└────────────────────────────────────────────┘
```

### Roles y Permisos

| Rol | Permisos |
|-----|----------|
| `super_admin` | Acceso total, gestión de instituciones |
| `admin_center` | Admin completo de su centro |
| `inventory_user` | CRUD inventario, solo lectura otros módulos |
| `read_only` | Solo consulta de datos |

### Manejo de Secretos

**Variables de Entorno:**
```bash
# ✅ Correcto - Anon Key (pública)
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1...

# ❌ NUNCA - Service Role Key (privada)
# NUNCA exponer en frontend
```

**JWT Claims:**
```json
{
  "sub": "user-id",
  "email": "user@example.com",
  "role": "admin_center",
  "center_id": "centro-123",
  "exp": 1234567890
}
```

---

## 📈 ESCALABILIDAD

### Estrategias de Escalabilidad

#### 1. Code Splitting

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'supabase': ['@supabase/supabase-js'],
          'charts': ['recharts']
        }
      }
    }
  }
})
```

**Resultado:**
- react-vendor: 160 KB
- supabase: 171 KB
- charts: 421 KB
- app: 215 KB

#### 2. Lazy Loading

```typescript
// Lazy load páginas
const AdminPage = lazy(() => import('./pages/AdminPage'))
const ReportsPage = lazy(() => import('./pages/ReportsPage'))

// Uso con Suspense
<Suspense fallback={<LoadingSpinner />}>
  <Route path="/admin" element={<AdminPage />} />
</Suspense>
```

#### 3. Memoization

```typescript
// useMemo para cálculos costosos
const filteredBatches = useMemo(() => {
  return batches.filter(batch => {
    const matchesSearch = batch.medication?.nombre
      .toLowerCase()
      .includes(searchTerm.toLowerCase())
    const matchesFilter = filterStatus === 'all' ||
      batch.estado === filterStatus
    return matchesSearch && matchesFilter
  })
}, [batches, searchTerm, filterStatus])

// useCallback para funciones
const handleSubmit = useCallback(async (data: FormData) => {
  await createBatch(data)
}, [createBatch])
```

#### 4. Pagination

```typescript
// Backend pagination
const { data, count } = await supabase
  .from('batches')
  .select('*', { count: 'exact' })
  .range(page * pageSize, (page + 1) * pageSize - 1)

// Frontend state
const [page, setPage] = useState(0)
const pageSize = 20
```

#### 5. Indexes de Base de Datos

```sql
-- Indexes para queries frecuentes
CREATE INDEX idx_batches_center_id ON batches(center_id);
CREATE INDEX idx_batches_medication_id ON batches(medication_id);
CREATE INDEX idx_batches_fecha_caducidad ON batches(fecha_caducidad);
CREATE INDEX idx_batch_movements_batch_id ON batch_movements(batch_id);
CREATE INDEX idx_batch_movements_created_at ON batch_movements(created_at DESC);
```

---

## ⚡ PERFORMANCE

### Optimizaciones Implementadas

#### 1. Vite Build Optimizations

- **Tree Shaking:** Elimina código no usado
- **Minification:** esbuild minifier
- **Code Splitting:** 4 chunks principales
- **Asset Optimization:** Imágenes comprimidas

#### 2. React Optimizations

```typescript
// React.memo para componentes puros
export const BatchCard = memo(function BatchCard({ batch }: Props) {
  return <div>{batch.nombre}</div>
})

// useMemo para valores derivados
const totalStock = useMemo(() =>
  batches.reduce((sum, b) => sum + b.cantidad_actual, 0),
  [batches]
)

// useCallback para callbacks
const handleUpdate = useCallback((id: string, data: Update) => {
  updateBatch(id, data)
}, [updateBatch])
```

#### 3. Supabase Optimizations

```typescript
// Select solo campos necesarios
const { data } = await supabase
  .from('batches')
  .select('id, numero_lote, cantidad_actual, medication(nombre)')

// Limitar resultados
const { data } = await supabase
  .from('batches')
  .select('*')
  .limit(100)

// Orden eficiente
const { data } = await supabase
  .from('batches')
  .select('*')
  .order('created_at', { ascending: false })
```

#### 4. Caching Strategy

```typescript
// React Query (opcional, no implementado)
const { data, isLoading } = useQuery(
  ['batches', centroId],
  () => fetchBatches(centroId),
  {
    staleTime: 5 * 60 * 1000, // 5 minutos
    cacheTime: 10 * 60 * 1000 // 10 minutos
  }
)
```

### Métricas de Performance

| Métrica | Target | Actual |
|---------|--------|--------|
| First Contentful Paint | < 1.5s | ~1.2s |
| Time to Interactive | < 3.0s | ~2.5s |
| Largest Contentful Paint | < 2.5s | ~2.0s |
| Bundle Size (gzip) | < 300KB | ~260KB |

---

## 🎯 DECISIONES ARQUITECTÓNICAS

### 1. React + TypeScript

**Decisión:** React 18 con TypeScript 5 strict mode

**Razones:**
- ✅ Type safety en toda la aplicación
- ✅ Mejor DX con autocompletado
- ✅ Prevención de errores en tiempo de desarrollo
- ✅ Refactoring seguro

**Trade-offs:**
- ⚠️ Curva de aprendizaje para tipos complejos
- ⚠️ Tiempo de desarrollo inicial mayor

### 2. Supabase como Backend

**Decisión:** Usar Supabase (BaaS) en lugar de backend custom

**Razones:**
- ✅ Desarrollo más rápido
- ✅ Real-time out of the box
- ✅ Auth integrado
- ✅ RLS para seguridad
- ✅ Escalabilidad automática

**Trade-offs:**
- ⚠️ Vendor lock-in parcial
- ⚠️ Menos control sobre infraestructura
- ⚠️ Costos por uso

### 3. Tailwind CSS

**Decisión:** Tailwind en lugar de CSS-in-JS o SCSS

**Razones:**
- ✅ Desarrollo rápido
- ✅ Consistencia de diseño
- ✅ No hay CSS unused en producción
- ✅ Customización fácil

**Trade-offs:**
- ⚠️ Clases verbosas
- ⚠️ Curva de aprendizaje

### 4. Custom Hooks sobre Redux

**Decisión:** Custom hooks + Context en lugar de Redux

**Razones:**
- ✅ Menor boilerplate
- ✅ Más simple para este caso de uso
- ✅ Built-in en React
- ✅ Mejor performance con hooks

**Trade-offs:**
- ⚠️ No hay herramientas de debugging como Redux DevTools
- ⚠️ Puede ser difícil manejar estado muy complejo

### 5. Vite sobre Create React App

**Decisión:** Vite como build tool

**Razones:**
- ✅ Desarrollo instantáneo (HMR)
- ✅ Build más rápido
- ✅ Mejor tree-shaking
- ✅ Configuración más simple

**Trade-offs:**
- ⚠️ Ecosistema menos maduro que Webpack

---

## 📊 DIAGRAMAS DE ARQUITECTURA

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────┐
│                       FRONTEND                          │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │                 PAGES (11)                      │  │
│  │  Dashboard │ Inventory │ Admin │ Reports ...   │  │
│  └─────────────────────┬───────────────────────────┘  │
│                        │                               │
│  ┌─────────────────────▼───────────────────────────┐  │
│  │             COMPONENTS (23)                     │  │
│  │  UI │ Auth │ Layout │ Domain-specific          │  │
│  └─────────────────────┬───────────────────────────┘  │
│                        │                               │
│  ┌─────────────────────▼───────────────────────────┐  │
│  │              HOOKS (13)                         │  │
│  │  useBatches │ useAuth │ useMovements ...       │  │
│  └─────────────────────┬───────────────────────────┘  │
│                        │                               │
│  ┌─────────────────────▼───────────────────────────┐  │
│  │          CONTEXT (2)                            │  │
│  │  AuthContext │ CentroContext                   │  │
│  └─────────────────────┬───────────────────────────┘  │
│                        │                               │
│  ┌─────────────────────▼───────────────────────────┐  │
│  │           SUPABASE CLIENT                       │  │
│  └─────────────────────┬───────────────────────────┘  │
└────────────────────────┼─────────────────────────────┘
                         │ HTTP/WebSocket
┌────────────────────────▼─────────────────────────────┐
│                     BACKEND                          │
│  ┌─────────────────────────────────────────────┐    │
│  │  PostgREST │ GoTrue │ Realtime │ Storage   │    │
│  └─────────────────────┬─────────────────────────┘    │
│                        │                              │
│  ┌─────────────────────▼─────────────────────────┐   │
│  │         PostgreSQL + RLS + Triggers          │   │
│  └──────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

---

## 🔮 FUTURAS MEJORAS

### Short-term (1-3 meses)

1. **Testing**
   - Unit tests con Vitest
   - Integration tests con React Testing Library
   - E2E tests con Playwright

2. **Performance**
   - Implementar React Query para caching
   - Virtual scrolling para listas largas
   - Image optimization

3. **Features**
   - Exportación PDF/Excel completa
   - Notificaciones push
   - Modo offline

### Mid-term (3-6 meses)

1. **Mobile**
   - Progressive Web App (PWA)
   - Responsive design mejorado
   - App móvil nativa (React Native)

2. **Analytics**
   - Dashboard analytics avanzado
   - Reportes predictivos
   - Machine learning para alertas

3. **Integrations**
   - API REST pública
   - Webhooks
   - Integración con sistemas externos

### Long-term (6-12 meses)

1. **Microservicios**
   - Separar módulos en servicios
   - Message queue (RabbitMQ/Kafka)
   - Service mesh

2. **Multi-tenancy avanzado**
   - Schema per tenant
   - Aislamiento completo de datos
   - Personalización por tenant

3. **AI/ML**
   - Predicción de demanda
   - Optimización de inventario
   - Detección de anomalías

---

**Documento preparado por:** Equipo de Arquitectura SIGIMED
**Última actualización:** Noviembre 2025
**Próxima revisión:** Febrero 2026
