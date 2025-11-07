# 🛠️ Guía de Desarrollo Local - SIGIMED v2.0

## Requisitos Previos

- **Node.js** v18 o superior
- **npm** v9 o superior
- **Git**
- Cuenta en [Supabase](https://supabase.com)

---

## 🚀 Configuración Inicial

### 1. Clonar el Repositorio (si aún no lo tienes)

```bash
git clone <url-del-repositorio>
cd MED_DGPRS
```

### 2. Instalar Dependencias

```bash
npm install
```

### 3. Configurar Variables de Entorno

El archivo `.env` ya está configurado con las credenciales de Supabase:

```env
VITE_SUPABASE_URL=https://cyslhzynfuetthxngpoy.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

✅ **YA ESTÁ LISTO** - No necesitas cambiar nada para desarrollo local.

---

## 🏃 Ejecutar la Aplicación

### Modo Desarrollo (con Hot Reload)

```bash
npm run dev
```

La aplicación se abrirá en: **http://localhost:5173**

### Preview del Build de Producción

```bash
# 1. Construir la aplicación
npm run build

# 2. Preview del build
npm run preview
```

Esto abrirá el build optimizado en: **http://localhost:4173**

---

## 🗂️ Estructura del Proyecto

```
MED_DGPRS/
├── src/
│   ├── components/
│   │   ├── admin/          # Componentes del panel de admin
│   │   ├── auth/           # Componentes de autenticación
│   │   ├── dashboard/      # Componentes del dashboard
│   │   ├── inventory/      # Componentes de inventario
│   │   ├── layout/         # Layout principal
│   │   └── ui/             # Componentes UI reutilizables
│   │
│   ├── context/            # Context providers (Auth, Centro)
│   ├── hooks/              # Custom hooks
│   ├── lib/                # Configuraciones (Supabase)
│   ├── pages/              # Páginas principales
│   ├── types/              # Definiciones de TypeScript
│   ├── utils/              # Utilidades (exportUtils)
│   │
│   ├── App.tsx             # Componente principal + rutas
│   ├── main.tsx            # Entry point
│   └── index.css           # Estilos globales
│
├── public/                 # Assets estáticos
├── dist/                   # Build de producción (generado)
│
├── .env                    # Variables de entorno
├── vercel.json             # Configuración de Vercel
├── vite.config.ts          # Configuración de Vite
├── tailwind.config.js      # Configuración de Tailwind CSS
└── tsconfig.json           # Configuración de TypeScript
```

---

## 🔑 Credenciales de Prueba

Para probar la aplicación en desarrollo, usa estas credenciales:

**Usuario de Prueba:**
```
Email: admin@sigimed.com
Password: admin123
```

**Nota:** Estas credenciales deben existir en tu base de datos de Supabase.

---

## 🧪 Comandos Disponibles

```bash
# Desarrollo con hot reload
npm run dev

# Build para producción
npm run build

# Preview del build
npm run preview

# Linter (revisar código)
npm run lint

# Verificar tipos TypeScript
npx tsc --noEmit
```

---

## 🔧 Tecnologías Utilizadas

### Frontend
- **React 18** - Biblioteca UI
- **TypeScript** - Tipado estático
- **Vite** - Build tool y dev server
- **React Router v6** - Enrutamiento
- **Tailwind CSS** - Estilos

### Backend
- **Supabase** - Backend as a Service
  - PostgreSQL Database
  - Authentication
  - Real-time subscriptions
  - Row Level Security (RLS)

### Librerías Adicionales
- **@supabase/supabase-js** - Cliente de Supabase
- **date-fns** - Manejo de fechas
- **lucide-react** - Iconos
- **jspdf** + **jspdf-autotable** - Generación de PDFs
- **xlsx** - Generación de Excel
- **recharts** - Gráficos (preparado para analytics)

---

## 📦 Funcionalidades Implementadas

### ✅ Módulo de Autenticación
- Login con email/password
- Protección de rutas
- Guard de roles (super_admin, admin_center, inventory_user, read_only)
- Logout
- Persistencia de sesión

### ✅ Dashboard
- KPIs en tiempo real
- Resumen de inventario
- Alertas activas por nivel
- Selector de centro de salud

### ✅ Inventario
- CRUD completo de medicamentos
- Búsqueda por nombre, fórmula, lote
- Filtros por estado
- Indicadores de caducidad con colores
- **Real-time updates** entre usuarios
- Exportación a PDF/Excel

### ✅ Sistema de Alertas Gamificado
- 3 niveles: Crítico (0-7 días), Urgente (8-30 días), Preventivo (31-90 días)
- Sistema de puntos: 100, 50, 20 pts respectivamente
- Marcar como visto
- Resolver alertas
- **Real-time updates**
- Exportación a PDF/Excel

### ✅ Panel de Administración
- CRUD de catálogo de medicamentos
- Gestión de categorías
- Activar/desactivar medicamentos
- Búsqueda y filtros
- **Real-time updates**
- Exportación a PDF/Excel
- Solo accesible para admin_center y super_admin

---

## 🔄 Sistema de Real-time

Todas las operaciones CRUD tienen actualizaciones en tiempo real gracias a Supabase Realtime:

- **Inventario**: Cuando otro usuario agrega, edita o elimina un medicamento, tu UI se actualiza automáticamente
- **Alertas**: Las nuevas alertas aparecen automáticamente
- **Catálogo**: Cambios en el catálogo se reflejan inmediatamente

---

## 🎨 Personalización

### Colores Corporativos (Pantone)

Definidos en `tailwind.config.js`:

```javascript
colors: {
  primary: '#7F2141',    // Pantone 505 C (Vino/Burgundy)
  secondary: '#AF8D6B',  // Pantone 7504 C (Dorado)
  accent: '#B39F82',     // Pantone 7530 C (Beige)
  neutral: '#D4D0C8'     // Pantone Warm Gray 3 C
}
```

### Modificar Temas

Edita `src/index.css` para cambiar estilos globales.

---

## 🐛 Debugging

### Ver logs de Supabase en el navegador

```javascript
// En src/lib/supabase.ts, puedes agregar:
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    debug: true  // Activar logs de auth
  }
})
```

### Ver errores de TypeScript en tiempo real

```bash
# En una terminal separada
npx tsc --watch --noEmit
```

### DevTools Útiles

- **React DevTools** - Inspeccionar componentes
- **Redux DevTools** - No usado, pero Context API es debuggeable
- **Network Tab** - Ver llamadas a Supabase

---

## 📝 Convenciones de Código

### Nombres de Archivos
- Componentes: `PascalCase.tsx` (ej: `DashboardPage.tsx`)
- Hooks: `camelCase.ts` con prefijo "use" (ej: `useMedicamentos.ts`)
- Utilidades: `camelCase.ts` (ej: `exportUtils.ts`)

### Estructura de Componentes

```typescript
// Imports
import { useState } from 'react'
import { useAuth } from '../context/AuthContext'

// Types/Interfaces
interface Props {
  title: string
  onSubmit: () => void
}

// Component
export function MyComponent({ title, onSubmit }: Props) {
  // Hooks
  const { user } = useAuth()
  const [loading, setLoading] = useState(false)

  // Functions
  const handleClick = () => {
    // logic
  }

  // Render
  return (
    <div>
      {/* JSX */}
    </div>
  )
}
```

---

## 🔐 Seguridad

### Variables de Entorno

- ✅ `.env` está en `.gitignore` - **NO se sube a Git**
- ✅ `.env.example` muestra la estructura sin valores reales
- ⚠️ **NUNCA** expongas `SUPABASE_SERVICE_ROLE_KEY` en el frontend

### Row Level Security (RLS)

Todas las tablas en Supabase tienen RLS habilitado:
- Los usuarios solo ven datos de sus centros asignados
- Los roles determinan qué operaciones pueden hacer

---

## 🚀 Preparar para Producción

### Checklist Pre-Deploy

- [ ] Ejecutar `npm run build` sin errores
- [ ] Verificar que todas las variables de entorno estén en Vercel
- [ ] Probar todas las funcionalidades en modo preview
- [ ] Verificar que el login funcione
- [ ] Confirmar que RLS esté habilitado en Supabase
- [ ] Revisar que no haya console.logs innecesarios

### Build Optimization

El proyecto ya tiene:
- ✅ Code splitting automático (Vite)
- ✅ Manual chunks para vendors (react, supabase, charts)
- ✅ Tree shaking
- ✅ Minificación

---

## 📚 Recursos Útiles

- [Documentación de Vite](https://vitejs.dev/)
- [Documentación de React](https://react.dev/)
- [Documentación de Supabase](https://supabase.com/docs)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [React Router v6](https://reactrouter.com/)

---

## 🆘 Problemas Comunes

### Error: "Cannot find module '@supabase/supabase-js'"

```bash
# Reinstalar dependencias
rm -rf node_modules package-lock.json
npm install
```

### Error: Variables de entorno undefined

Asegúrate de que:
1. El archivo `.env` existe en la raíz
2. Las variables tienen el prefijo `VITE_`
3. Reiniciaste el servidor después de crear/editar `.env`

```bash
# Ctrl+C para detener el servidor
npm run dev  # Reiniciar
```

### Error: Puerto 5173 en uso

```bash
# Cambiar puerto
npm run dev -- --port 3000
```

### Error de CORS con Supabase

Verifica en Supabase → Settings → API que `localhost:5173` esté permitido.

---

## 🤝 Contribuir

### Flujo de Trabajo Git

```bash
# 1. Crear rama para tu feature
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios y commits
git add .
git commit -m "Descripción clara del cambio"

# 3. Push a tu rama
git push origin feature/nueva-funcionalidad

# 4. Crear Pull Request en GitHub
```

---

**¡Happy Coding! 🎉**

Última actualización: 2025-11-07
Versión: 2.0.0
