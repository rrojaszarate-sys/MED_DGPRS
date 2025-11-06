# SIGIMED - Especificación Técnica Detallada

## 📐 Arquitectura del Sistema

### Estructura de Carpetas

```
sigimed/
├── src/
│   ├── components/
│   │   ├── auth/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── AuthProvider.tsx
│   │   │   ├── ProtectedRoute.tsx
│   │   │   └── RoleGuard.tsx
│   │   ├── dashboard/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── KPICard.tsx
│   │   │   └── CentroSelector.tsx
│   │   ├── alertas/
│   │   │   ├── AlertaDashboard.tsx
│   │   │   ├── AlertCard.tsx
│   │   │   ├── AlertTimeline.tsx
│   │   │   ├── LogrosBadge.tsx
│   │   │   └── RankingCentros.tsx
│   │   ├── inventory/
│   │   │   ├── InventoryTable.tsx
│   │   │   ├── MedicamentoForm.tsx
│   │   │   └── CatalogModal.tsx
│   │   ├── admin/
│   │   │   ├── AdminPanel.tsx
│   │   │   ├── UserManagement.tsx
│   │   │   ├── CenterManagement.tsx
│   │   │   ├── CatalogManagement.tsx
│   │   │   └── SupplierManagement.tsx
│   │   └── ui/
│   │       ├── Button.tsx
│   │       ├── Modal.tsx
│   │       ├── Toast.tsx
│   │       ├── Badge.tsx
│   │       └── Card.tsx
│   ├── context/
│   │   ├── AuthContext.tsx
│   │   └── AlertasContext.tsx
│   ├── hooks/
│   │   ├── useSupabase.ts
│   │   ├── useMedicamentos.ts
│   │   ├── useAlertas.ts
│   │   └── useRealtime.ts
│   ├── lib/
│   │   ├── supabase.ts
│   │   └── utils.ts
│   ├── types/
│   │   └── index.ts
│   ├── App.tsx
│   └── main.tsx
├── public/
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

## 🗄️ Esquema de Base de Datos

### Tablas Core

#### 1. users_profiles
```sql
CREATE TABLE users_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin_center', 'inventory_user', 'read_only')),
  permissions JSONB DEFAULT '[]',
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE,
  deleted_by UUID REFERENCES users_profiles(id)
);
```

#### 2. health_centers
```sql
CREATE TABLE health_centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  address TEXT,
  city TEXT,
  region TEXT,
  phone TEXT,
  email TEXT,
  responsible_name TEXT,
  responsible_role TEXT,
  storage_capacity INTEGER,
  has_refrigeration BOOLEAN DEFAULT false,
  operating_hours JSONB,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. medication_catalog
```sql
CREATE TABLE medication_catalog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_comercial TEXT NOT NULL,
  nombre_generico TEXT NOT NULL,
  formula_activa TEXT NOT NULL,
  concentracion TEXT,
  forma_farmaceutica TEXT NOT NULL,
  uso_terapeutico TEXT,
  categoria_farmacologica TEXT,
  contraindicaciones TEXT,
  efectos_secundarios TEXT,
  interacciones TEXT,
  dosis_usual TEXT,
  fabricantes_autorizados TEXT[],
  imagen_producto TEXT,
  ficha_tecnica_url TEXT,
  requiere_receta BOOLEAN DEFAULT false,
  es_controlado BOOLEAN DEFAULT false,
  temperatura_almacenamiento TEXT,
  temperatura_min DECIMAL(5, 2),
  temperatura_max DECIMAL(5, 2),
  condiciones_especiales TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id),
  updated_by UUID REFERENCES users_profiles(id)
);
```

#### 4. medications (Inventario)
```sql
CREATE TABLE medications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  center_id UUID REFERENCES health_centers(id) ON DELETE CASCADE,
  catalog_id UUID REFERENCES medication_catalog(id),
  nombre TEXT NOT NULL,
  formula_activa TEXT NOT NULL,
  lote TEXT NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
  fecha_caducidad DATE NOT NULL,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  estado TEXT NOT NULL CHECK (estado IN ('Disponible', 'No Disponible', 'Cuarentena')),
  proveedor_id UUID REFERENCES suppliers(id),
  costo_unitario DECIMAL(10, 2),
  precio_venta DECIMAL(10, 2),
  ubicacion_fisica TEXT,
  codigo_barras TEXT,
  qr_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users_profiles(id)
);
```

#### 5. alertas_medicamentos
```sql
CREATE TABLE alertas_medicamentos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medicamento_id UUID REFERENCES medications(id) ON DELETE CASCADE,
  centro_id UUID REFERENCES health_centers(id),
  nivel_alerta TEXT NOT NULL CHECK (nivel_alerta IN ('critico', 'urgente', 'preventivo')),
  dias_restantes INTEGER NOT NULL,
  visto BOOLEAN DEFAULT false,
  resuelta BOOLEAN DEFAULT false,
  visto_por UUID REFERENCES users_profiles(id),
  visto_en TIMESTAMP WITH TIME ZONE,
  resuelta_por UUID REFERENCES users_profiles(id),
  resuelta_en TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 6. transfers (Transferencias)
```sql
CREATE TABLE transfers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  transfer_number TEXT UNIQUE NOT NULL,
  origin_center_id UUID NOT NULL REFERENCES health_centers(id),
  destination_center_id UUID NOT NULL REFERENCES health_centers(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'approved', 'rejected', 'in_transit', 'received', 'completed'
  )),
  requested_by UUID NOT NULL REFERENCES users_profiles(id),
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_by UUID REFERENCES users_profiles(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  shipped_by UUID REFERENCES users_profiles(id),
  shipped_at TIMESTAMP WITH TIME ZONE,
  received_by UUID REFERENCES users_profiles(id),
  received_at TIMESTAMP WITH TIME ZONE,
  rejection_reason TEXT,
  notes TEXT,
  tracking_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 7. requisitions (Requisiciones)
```sql
CREATE TABLE requisitions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  requisition_number TEXT UNIQUE NOT NULL,
  requesting_service TEXT NOT NULL,
  requesting_user_id UUID NOT NULL REFERENCES users_profiles(id),
  center_id UUID NOT NULL REFERENCES health_centers(id),
  status TEXT NOT NULL DEFAULT 'borrador' CHECK (status IN (
    'borrador', 'solicitada', 'aprobada', 'rechazada', 'surtida', 'completada'
  )),
  fecha_solicitud TIMESTAMP WITH TIME ZONE,
  fecha_necesaria DATE,
  aprobada_por UUID REFERENCES users_profiles(id),
  aprobada_en TIMESTAMP WITH TIME ZONE,
  motivo_rechazo TEXT,
  surtida_por UUID REFERENCES users_profiles(id),
  surtida_en TIMESTAMP WITH TIME ZONE,
  observaciones TEXT,
  prioridad TEXT CHECK (prioridad IN ('normal', 'urgente', 'emergencia')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 8. inventory_adjustments
```sql
CREATE TABLE inventory_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  adjustment_number TEXT UNIQUE NOT NULL,
  medication_id UUID REFERENCES medications(id),
  center_id UUID NOT NULL REFERENCES health_centers(id),
  adjustment_type TEXT NOT NULL CHECK (adjustment_type IN (
    'merma', 'correccion', 'devolucion', 'reclasificacion'
  )),
  cantidad_sistema INTEGER NOT NULL,
  cantidad_fisica INTEGER NOT NULL,
  diferencia INTEGER GENERATED ALWAYS AS (cantidad_fisica - cantidad_sistema) STORED,
  motivo TEXT NOT NULL,
  justificacion TEXT NOT NULL,
  evidencia_fotografica TEXT[],
  autorizado_por UUID REFERENCES users_profiles(id),
  autorizado_en TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users_profiles(id)
);
```

#### 9. audit_log
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users_profiles(id),
  user_email TEXT,
  user_name TEXT,
  user_role TEXT,
  action_type TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  entity_name TEXT,
  old_values JSONB,
  new_values JSONB,
  changes_summary TEXT,
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  device_type TEXT,
  browser TEXT,
  result TEXT CHECK (result IN ('success', 'failed', 'partial')),
  error_message TEXT,
  error_code TEXT,
  metadata JSONB,
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  location_lat DECIMAL(10, 8),
  location_lon DECIMAL(11, 8),
  location_city TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔐 Row Level Security (RLS) Policies

### Ejemplo: Medications Table

```sql
-- Habilitar RLS
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;

-- Usuarios solo ven medicamentos de sus centros asignados
CREATE POLICY "Users see medications from their centers"
ON medications FOR SELECT
TO authenticated
USING (
  center_id IN (
    SELECT center_id FROM user_centers
    WHERE user_id = auth.uid()
  )
);

-- Solo admins pueden eliminar
CREATE POLICY "Only admins can delete medications"
ON medications FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users_profiles
    WHERE id = auth.uid()
    AND role IN ('super_admin', 'admin_center')
  )
);
```

## 📊 Funciones de Base de Datos

### Generar Alertas de Caducidad

```sql
CREATE OR REPLACE FUNCTION generar_alertas_caducidad()
RETURNS void AS $$
BEGIN
  DELETE FROM alertas_medicamentos
  WHERE medicamento_id IN (
    SELECT id FROM medications
    WHERE fecha_caducidad < CURRENT_DATE OR estado = 'No Disponible'
  );

  INSERT INTO alertas_medicamentos (medicamento_id, centro_id, nivel_alerta, dias_restantes)
  SELECT
    m.id,
    m.center_id,
    CASE
      WHEN (m.fecha_caducidad - CURRENT_DATE) <= 7 THEN 'critico'
      WHEN (m.fecha_caducidad - CURRENT_DATE) <= 30 THEN 'urgente'
      WHEN (m.fecha_caducidad - CURRENT_DATE) <= 90 THEN 'preventivo'
    END as nivel_alerta,
    (m.fecha_caducidad - CURRENT_DATE) as dias_restantes
  FROM medications m
  WHERE m.fecha_caducidad > CURRENT_DATE
    AND m.fecha_caducidad <= (CURRENT_DATE + INTERVAL '90 days')
    AND m.estado = 'Disponible'
    AND NOT EXISTS (
      SELECT 1 FROM alertas_medicamentos a
      WHERE a.medicamento_id = m.id AND a.resuelta = false
    );
END;
$$ LANGUAGE plpgsql;
```

### Calcular Racha de Centro

```sql
CREATE OR REPLACE FUNCTION calcular_racha_centro(centro_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
  racha INTEGER := 0;
  fecha_actual DATE := CURRENT_DATE;
BEGIN
  WHILE NOT EXISTS (
    SELECT 1 FROM medications
    WHERE center_id = centro_uuid
    AND fecha_caducidad = fecha_actual
    AND estado = 'No Disponible'
  ) AND racha < 365 LOOP
    racha := racha + 1;
    fecha_actual := fecha_actual - INTERVAL '1 day';
  END LOOP;

  RETURN racha;
END;
$$ LANGUAGE plpgsql;
```

## 🎮 Sistema de Gamificación

### Badges del Sistema

| Badge | Condición | Puntos |
|-------|-----------|--------|
| 🏆 Principiante Organizado | Primera alerta resuelta | 10 |
| ⭐ Guardián Atento | 10 alertas resueltas | 50 |
| 💎 Maestro del Inventario | 50 alertas resueltas | 200 |
| 🔥 Racha de Fuego | 7 días sin alertas críticas | 100 |
| 🌟 Estrella del Mes | Más alertas resueltas del mes | 500 |
| 🎯 Precisión Total | 0 medicamentos vencidos en 30 días | 300 |
| ⚡ Respuesta Rápida | Resolver alerta crítica en <24hrs | 150 |
| 🌱 Prevención Proactiva | 20 alertas preventivas resueltas | 100 |

### Cálculo de Puntos

```typescript
const calcularPuntos = (nivel: NivelAlerta): number => {
  const puntosBase = {
    critico: 100,
    urgente: 50,
    preventivo: 20
  };
  return puntosBase[nivel];
};
```

## 🔄 Flujos de Trabajo

### Flujo de Transferencia

```
1. PENDING (Solicitud creada)
   ↓
2. APPROVED/REJECTED (Revisión del administrador)
   ↓
3. IN_TRANSIT (Medicamento enviado)
   ↓
4. RECEIVED (Medicamento recibido en destino)
   ↓
5. COMPLETED (Inventario actualizado)
```

### Flujo de Requisición

```
1. BORRADOR (Usuario crea requisición)
   ↓
2. SOLICITADA (Usuario envía requisición)
   ↓
3. APROBADA/RECHAZADA (Jefe aprueba/rechaza)
   ↓
4. SURTIDA (Farmacia surte medicamentos)
   ↓
5. COMPLETADA (Servicio confirma recepción)
```

## 📱 Diseño Responsive

### Breakpoints Tailwind

```javascript
module.exports = {
  theme: {
    screens: {
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',
    }
  }
}
```

### Mobile-First Approach

```css
/* Mobile por defecto */
.grid { grid-template-columns: 1fr; }

/* Tablet */
@media (min-width: 768px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
}

/* Desktop */
@media (min-width: 1024px) {
  .grid { grid-template-columns: repeat(4, 1fr); }
}
```

## 🧪 Testing Strategy

### Unit Tests
- Componentes UI aislados
- Funciones de utilidad
- Custom hooks

### Integration Tests
- Flujos de autenticación
- CRUD operations
- Interacciones entre componentes

### E2E Tests
- User journeys completos
- Flujos de transferencia
- Sistema de alertas

## 📦 Deployment

### Vercel (Frontend)
```bash
vercel --prod
```

### Supabase (Backend)
- Auto-deployed en push
- Migrations automáticas
- Edge Functions en CDN

## 🔒 Mejores Prácticas de Seguridad

1. **Nunca exponer Service Role Key en frontend**
2. **Usar RLS para todos los datos sensibles**
3. **Validar datos en cliente Y servidor**
4. **Implementar rate limiting en API**
5. **Logs de auditoría para acciones críticas**
6. **Encriptar datos sensibles en reposo**
7. **HTTPS obligatorio en producción**
8. **Tokens JWT con expiración corta**

## 📊 Métricas de Performance

### Objetivos
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3s
- Lighthouse Score: > 90
- Bundle Size: < 500KB (gzipped)

---

**Documento vivo - Se actualiza con cada iteración del proyecto**
