# 📘 DOCUMENTACIÓN TÉCNICA - SIGIMED v2.0

## Sistema de Gestión Integral de Inventario de Medicamentos

**Versión:** 2.0.0
**Fecha:** Noviembre 2025
**Autor:** Sistema desarrollado para gestión de medicamentos en centros de salud
**Licencia:** Propietario

---

## 📋 TABLA DE CONTENIDOS

1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Configuración del Entorno](#configuración-del-entorno)
6. [Instalación](#instalación)
7. [Scripts Disponibles](#scripts-disponibles)
8. [Variables de Entorno](#variables-de-entorno)
9. [Convenciones de Código](#convenciones-de-código)
10. [Testing](#testing)
11. [Deployment](#deployment)
12. [Documentación Adicional](#documentación-adicional)

---

## 📝 DESCRIPCIÓN GENERAL

**SIGIMED v2.0** es un sistema web moderno (SPA - Single Page Application) diseñado para la gestión integral de inventarios de medicamentos en instituciones del sector salud. El sistema permite control exhaustivo de lotes, movimientos, alertas de caducidad, contratos con proveedores y reportes analíticos en tiempo real.

### 🎯 Objetivos del Sistema

- **Trazabilidad completa** de medicamentos desde ingreso hasta salida
- **Control de stock** con alertas inteligentes de vencimiento y reposición
- **Gestión multi-centro** con segregación de datos por institución
- **Auditoría** completa de todas las operaciones
- **Reportes en tiempo real** con dashboards interactivos
- **Cumplimiento normativo** con estándares del sector salud

### 👥 Usuarios del Sistema

El sistema soporta 4 niveles de usuario:

1. **Super Admin** - Control total del sistema, gestión de instituciones
2. **Admin Centro** - Administración completa de un centro específico
3. **Usuario Inventario** - Operaciones diarias de inventario
4. **Solo Lectura** - Consulta de reportes y estadísticas

---

## 🏗️ ARQUITECTURA DEL SISTEMA

### Tipo de Arquitectura

**SPA (Single Page Application)** con arquitectura de 3 capas:

```
┌─────────────────────────────────────────────────────────────┐
│                     CAPA DE PRESENTACIÓN                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   React 18   │  │ TypeScript 5 │  │  Tailwind 3  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  React Router 6 - Enrutamiento Cliente              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CAPA DE LÓGICA                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Custom Hooks │  │   Context    │  │  Utilidades  │     │
│  │   (13)       │  │    API       │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Supabase Client - Comunicación Backend             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CAPA DE DATOS                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Supabase (PostgreSQL 14)                   │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │  │
│  │  │   Database   │  │  Auth (JWT)  │  │ Realtime │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │  │
│  │  │     RLS      │  │   Storage    │  │  Edge    │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Patrones de Diseño Implementados

1. **Container/Presentational Pattern**
   - Páginas actúan como containers
   - Componentes UI son presentacionales puros

2. **Custom Hooks Pattern**
   - Lógica de negocio encapsulada en hooks
   - Reutilización de lógica entre componentes

3. **Context API Pattern**
   - Estado global para autenticación y centro seleccionado
   - Evita prop drilling

4. **HOC (Higher Order Components)**
   - `ProtectedRoute` - Requiere autenticación
   - `RoleGuard` - Requiere rol específico

5. **Observer Pattern**
   - Real-time subscriptions con Supabase
   - Actualizaciones automáticas de UI

---

## 💻 STACK TECNOLÓGICO

### Frontend Core

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| React | 18.2.0 | Framework UI |
| TypeScript | 5.2.2 | Type Safety |
| Vite | 5.0.8 | Build Tool & Dev Server |
| React Router DOM | 6.20.0 | Client-side Routing |
| Tailwind CSS | 3.3.6 | Utility-first CSS |

### Backend & Database

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Supabase | 2.39.0 | BaaS (Backend as a Service) |
| PostgreSQL | 14 | Base de datos relacional |
| PostgREST | - | API REST automática |
| GoTrue | - | Autenticación JWT |

### Librerías UI/UX

| Librería | Versión | Propósito |
|----------|---------|-----------|
| Recharts | 2.10.3 | Gráficos y visualizaciones |
| Lucide React | 0.294.0 | Iconos SVG |
| React Hot Toast | 2.6.0 | Notificaciones toast |
| date-fns | 2.30.0 | Manipulación de fechas |

### Librerías de Datos

| Librería | Versión | Propósito |
|----------|---------|-----------|
| jsPDF | 2.5.1 | Generación de PDF |
| jspdf-autotable | 3.8.2 | Tablas en PDF |
| xlsx | 0.18.5 | Lectura/escritura Excel |
| papaparse | 5.5.3 | Parsing de CSV |

### Herramientas de Desarrollo

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| ESLint | 8.55.0 | Linting JavaScript/TypeScript |
| PostCSS | 8.4.32 | Procesamiento CSS |
| Autoprefixer | 10.4.16 | Prefijos CSS automáticos |

---

## 📁 ESTRUCTURA DEL PROYECTO

```
sigimed/
├── 📂 src/                          # Código fuente principal
│   ├── 📂 components/               # Componentes React
│   │   ├── 📂 ui/                   # Componentes UI base (11)
│   │   ├── 📂 auth/                 # Autenticación (2)
│   │   ├── 📂 layout/               # Layout (1)
│   │   ├── 📂 admin/                # Admin (2)
│   │   ├── 📂 batches/              # Lotes (2)
│   │   ├── 📂 movements/            # Movimientos (1)
│   │   ├── 📂 suppliers/            # Proveedores (1)
│   │   ├── 📂 contracts/            # Contratos (2)
│   │   └── 📂 inventory/            # Inventario (1)
│   ├── 📂 pages/                    # Páginas principales (11)
│   │   ├── 📄 LoginPage.tsx
│   │   ├── 📄 DashboardPage.tsx
│   │   ├── 📄 InventoryPage.tsx
│   │   ├── 📄 AdminPage.tsx
│   │   ├── 📄 AlertasPage.tsx
│   │   ├── 📄 ReportsPage.tsx
│   │   ├── 📄 SuppliersPage.tsx
│   │   ├── 📄 MovementsPage.tsx
│   │   ├── 📄 ContractsPage.tsx
│   │   ├── 📄 InstitutionsPage.tsx
│   │   └── 📄 HealthCentersPage.tsx
│   ├── 📂 hooks/                    # Custom Hooks (13)
│   │   ├── 📄 useRealtime.ts
│   │   ├── 📄 useMedicamentos.ts
│   │   ├── 📄 useBatches.ts
│   │   ├── 📄 useCentros.ts
│   │   ├── 📄 useCatalogo.ts
│   │   ├── 📄 useSuppliers.ts
│   │   ├── 📄 useContracts.ts
│   │   ├── 📄 useMovements.ts
│   │   ├── 📄 useBatchMovements.ts
│   │   ├── 📄 useAlertas.ts
│   │   ├── 📄 useAuditLog.ts
│   │   ├── 📄 useImport.ts
│   │   └── 📄 useInstituciones.ts
│   ├── 📂 context/                  # Context API (2)
│   │   ├── 📄 AuthContext.tsx
│   │   └── 📄 CentroContext.tsx
│   ├── 📂 lib/                      # Librerías (1)
│   │   └── 📄 supabase.ts
│   ├── 📂 types/                    # TypeScript Types (1)
│   │   └── 📄 index.ts
│   ├── 📂 utils/                    # Utilidades (2)
│   │   ├── 📄 exportUtils.ts
│   │   └── 📄 importUtils.ts
│   ├── 📄 App.tsx                   # Componente raíz
│   ├── 📄 main.tsx                  # Entry point
│   ├── 📄 index.css                 # Estilos globales
│   └── 📄 vite-env.d.ts            # Tipos Vite
│
├── 📂 migrations/                   # Migraciones SQL (8)
│   ├── 📄 01_crear_tablas_core.sql
│   ├── 📄 02_insertar_datos_iniciales.sql
│   ├── 📄 03_funciones_y_triggers.sql
│   ├── 📄 04_sistema_permisos_rls.sql
│   ├── 📄 05_control_calidad.sql
│   ├── 📄 06_modulo_contratos.sql
│   ├── 📄 07_gestion_documental.sql
│   └── 📄 08_testing_reportes.sql
│
├── 📂 public/                       # Assets estáticos
├── 📂 dist/                         # Build de producción
│
├── 📄 package.json                  # Dependencias
├── 📄 tsconfig.json                 # Config TypeScript
├── 📄 vite.config.ts                # Config Vite
├── 📄 tailwind.config.js            # Config Tailwind
├── 📄 postcss.config.js             # Config PostCSS
├── 📄 vercel.json                   # Config Vercel
├── 📄 .env.example                  # Ejemplo env vars
├── 📄 .env.production               # Env producción
└── 📄 .gitignore                    # Exclusiones Git
```

**Estadísticas:**
- **Total de archivos TypeScript/TSX:** 57+
- **Componentes React:** 23
- **Páginas:** 11
- **Custom Hooks:** 13
- **Contextos:** 2
- **Líneas de código SQL:** 3,977

---

## ⚙️ CONFIGURACIÓN DEL ENTORNO

### Requisitos Previos

- **Node.js:** v18.0.0 o superior
- **npm:** v9.0.0 o superior (o yarn/pnpm)
- **Git:** v2.0.0 o superior
- **Cuenta Supabase:** Proyecto configurado

### Configuración de Supabase

1. Crear proyecto en [supabase.com](https://supabase.com)
2. Obtener credenciales:
   - **Project URL:** `https://[project-id].supabase.co`
   - **Anon Key:** Clave pública para cliente

3. Ejecutar migraciones SQL (en orden):
   ```sql
   -- En SQL Editor de Supabase Dashboard
   migrations/01_crear_tablas_core.sql
   migrations/02_insertar_datos_iniciales.sql
   migrations/03_funciones_y_triggers.sql
   migrations/04_sistema_permisos_rls.sql
   migrations/05_control_calidad.sql
   migrations/06_modulo_contratos.sql
   migrations/07_gestion_documental.sql
   migrations/08_testing_reportes.sql
   ```

---

## 🚀 INSTALACIÓN

### 1. Clonar Repositorio

```bash
git clone https://github.com/[usuario]/MED_DGPRS.git
cd MED_DGPRS
```

### 2. Instalar Dependencias

```bash
npm install
```

Esto instalará todas las dependencias listadas en `package.json`:
- Dependencias de producción: 14
- Dependencias de desarrollo: 8

### 3. Configurar Variables de Entorno

Copiar archivo de ejemplo:
```bash
cp .env.example .env
```

Editar `.env` con tus credenciales:
```bash
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu-anon-key-aqui
```

**⚠️ IMPORTANTE:** Nunca expongas la Service Role Key en el frontend.

### 4. Ejecutar Desarrollo

```bash
npm run dev
```

La aplicación estará disponible en: `http://localhost:5173`

---

## 📜 SCRIPTS DISPONIBLES

### Desarrollo

```bash
npm run dev
```
Inicia servidor de desarrollo Vite con Hot Module Replacement (HMR).
- Puerto: 5173
- Host: 0.0.0.0 (accesible desde red local)

### Build Producción

```bash
npm run build
```
Compila TypeScript y bundlea la aplicación para producción:
1. Compilación TypeScript (`tsc`)
2. Optimización con Vite
3. Code splitting automático
4. Minificación con esbuild

**Output:** `dist/` directory

### Preview Build

```bash
npm run preview
```
Sirve el build de producción localmente para testing.

### Linting

```bash
npm run lint
```
Ejecuta ESLint en todos los archivos `.ts` y `.tsx`:
- Reglas TypeScript habilitadas
- Reglas React Hooks
- Warnings por unused variables

---

## 🔐 VARIABLES DE ENTORNO

### Variables Requeridas

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `VITE_SUPABASE_URL` | URL del proyecto Supabase | `https://abc123.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Clave anónima pública | `eyJhbGciOiJIUzI1...` |

### Variables Opcionales

| Variable | Descripción | Default |
|----------|-------------|---------|
| `NODE_ENV` | Entorno (development/production) | `development` |
| `VITE_PORT` | Puerto del servidor dev | `5173` |

**Nota sobre NODE_ENV:**
Solo `NODE_ENV=development` es soportado en `.env`. Para producción, configurar en `vite.config.ts`.

---

## 📐 CONVENCIONES DE CÓDIGO

### Nomenclatura

#### Archivos
- **Componentes:** PascalCase - `Button.tsx`, `MainLayout.tsx`
- **Hooks:** camelCase con prefijo `use` - `useAuth.ts`
- **Utilidades:** camelCase - `exportUtils.ts`
- **Tipos:** PascalCase - `index.ts` (contiene interfaces)

#### Código
```typescript
// Componentes y Tipos
export interface UserData { }
export function MainComponent() { }

// Variables y funciones
const userName = 'John'
function getUserData() { }

// Constantes
const API_BASE_URL = 'https://...'
const MAX_RETRIES = 3
```

### Estructura de Componentes

```typescript
// 1. Imports
import { useState, useEffect, type ReactNode } from 'react'
import { Icon } from 'lucide-react'
import { useCustomHook } from '../hooks/useCustomHook'
import { Component } from '../components/Component'
import type { Type } from '../types'

// 2. Interface de Props
interface ComponentProps {
  prop: string
  optional?: number
  children?: ReactNode
}

// 3. Componente
export function Component({ prop, optional = 0, children }: ComponentProps) {
  // 3.1 Hooks
  const [state, setState] = useState<string>('')
  const { data } = useCustomHook()

  // 3.2 Effects
  useEffect(() => {
    // Logic
  }, [dependencies])

  // 3.3 Handlers
  const handleClick = () => {
    // Logic
  }

  // 3.4 Render
  return (
    <div>
      {children}
    </div>
  )
}
```

### TypeScript

**Reglas Estrictas Activadas:**
```json
{
  "strict": true,
  "noUnusedLocals": true,
  "noUnusedParameters": true,
  "noImplicitAny": true,
  "strictNullChecks": true
}
```

**Tipos Explícitos:**
```typescript
// ✅ Bueno
const user: User = await getUser()
const items: Item[] = []

// ❌ Evitar
const user = await getUser() // Tipo inferido puede cambiar
```

### Manejo de Errores

```typescript
try {
  const { data, error } = await supabase
    .from('table')
    .select()

  if (error) throw error

  return { data, error: null }
} catch (err: any) {
  console.error('Error descriptivo:', err)
  return { data: null, error: err.message }
}
```

### Estilos con Tailwind

```tsx
// ✅ Clases utilitarias
<button className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark">
  Click
</button>

// ✅ Clases condicionales
<div className={`base-class ${condition ? 'active' : 'inactive'}`}>

// ✅ Responsive
<div className="w-full md:w-1/2 lg:w-1/3">
```

### Comentarios

```typescript
// Comentarios solo cuando es necesario
// Preferir código auto-documentado

/**
 * Procesa un batch de medicamentos
 * @param batchId - ID del lote
 * @param quantity - Cantidad a procesar
 * @returns Resultado de la operación
 */
async function processBatch(batchId: string, quantity: number): Promise<Result> {
  // Implementación
}
```

---

## 🧪 TESTING

### Estado Actual

**⚠️ Testing pendiente de implementación**

### Testing Recomendado

#### Unit Testing
- **Librería:** Vitest (compatible con Vite)
- **Coverage:** Hooks y utilidades
- **Mocking:** Supabase client

#### Integration Testing
- **Librería:** React Testing Library
- **Coverage:** Componentes con hooks
- **Mocking:** Context API

#### E2E Testing
- **Librería:** Playwright o Cypress
- **Coverage:** Flujos críticos
- **Ambiente:** Staging con datos de prueba

### Scripts de Testing (Propuestos)

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test"
  }
}
```

---

## 🚢 DEPLOYMENT

### Vercel (Recomendado)

**Configuración incluida:** `vercel.json`

#### Deploy desde CLI

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
vercel

# Deploy producción
vercel --prod
```

#### Deploy desde GitHub

1. Conectar repositorio en [vercel.com](https://vercel.com)
2. Configurar variables de entorno:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
3. Deploy automático en cada push a `main`

### Variables de Entorno en Vercel

```bash
# Via CLI
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY

# O en Dashboard: Settings → Environment Variables
```

### Build Settings

- **Framework Preset:** Vite
- **Build Command:** `npm run build`
- **Output Directory:** `dist`
- **Install Command:** `npm install`

### Dominios Personalizados

Configurar en: Project Settings → Domains

---

## 📚 DOCUMENTACIÓN ADICIONAL

### Documentos Principales

- **ARQUITECTURA.md** - Arquitectura detallada del sistema
- **COMPONENTES.md** - Documentación de todos los componentes
- **BASE_DE_DATOS.md** - Esquema y estructura de base de datos
- **FLUJO_DE_TRABAJO.md** - Flujos de usuario y casos de uso
- **GUIA_DESARROLLO.md** - Guía para desarrolladores
- **DEPLOYMENT_VERCEL.md** - Guía de despliegue en Vercel
- **GUIA_RAPIDA_USO.md** - Guía de usuario final

### Recursos Externos

- [Documentación React](https://react.dev/)
- [Documentación TypeScript](https://www.typescriptlang.org/docs/)
- [Documentación Supabase](https://supabase.com/docs)
- [Documentación Vite](https://vitejs.dev/)
- [Documentación Tailwind](https://tailwindcss.com/docs)
- [Documentación Recharts](https://recharts.org/)

---

## 🤝 CONTRIBUCIÓN

### Flujo de Trabajo

1. **Fork** del repositorio
2. **Branch** para feature: `git checkout -b feature/nueva-funcionalidad`
3. **Commit** con mensaje descriptivo
4. **Push** a branch: `git push origin feature/nueva-funcionalidad`
5. **Pull Request** a `main`

### Convenciones de Commit

```
tipo(scope): descripción corta

Descripción detallada del cambio

- Cambio 1
- Cambio 2

Closes #123
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formato de código
- `refactor`: Refactorización
- `test`: Tests
- `chore`: Mantenimiento

---

## 📞 SOPORTE

### Reportar Issues

Crear issue en GitHub con:
- Descripción del problema
- Pasos para reproducir
- Comportamiento esperado vs actual
- Screenshots si aplica
- Versión del sistema
- Navegador y versión

### Contacto

Para soporte técnico o consultas, contactar al equipo de desarrollo.

---

## 📄 LICENCIA

Este proyecto es propietario. Todos los derechos reservados.

---

## 🔄 CHANGELOG

### v2.0.0 (Noviembre 2025)

**Funcionalidades Principales:**
- ✅ Sistema completo de gestión de inventario
- ✅ Control de lotes y movimientos
- ✅ Alertas inteligentes de vencimiento
- ✅ Gestión de proveedores y contratos
- ✅ Dashboards con gráficas interactivas (Recharts)
- ✅ Real-time updates con Supabase
- ✅ Row Level Security (RLS)
- ✅ Sistema de auditoría
- ✅ Gestión de instituciones y centros

**Mejoras:**
- ✅ TypeScript strict mode
- ✅ Code splitting optimizado
- ✅ Build verificado 100% exitoso

**Pendiente:**
- ⚠️ Exportación PDF/Excel completa
- ⚠️ Testing automatizado
- ⚠️ Optimizaciones mobile

---

**Última actualización:** Noviembre 2025
**Mantenido por:** Equipo de Desarrollo SIGIMED
