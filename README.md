# SIGIMED - Sistema de Gestión de Inventario de Medicamentos

## 🎯 Objetivo Principal

Sistema web moderno para la gestión integral, segura y trazable del inventario de medicamentos en múltiples centros de salud.

## ✨ Características Principales

- **Control Total del Inventario**: Registro preciso de entradas, salidas, transferencias y ajustes con monitoreo en tiempo real
- **Trazabilidad Completa**: Seguimiento detallado de cada medicamento desde ingreso hasta salida con auditoría de todas las acciones
- **Gestión Documental Inteligente**: Generación automática de PDFs con firma digital, OCR para extracción de datos
- **Optimización de Recursos**: Prevención de desabastecimiento mediante análisis predictivo
- **Cumplimiento Normativo**: Documentación completa para auditorías sanitarias
- **Sistema Gamificado de Alertas**: Experiencia interactiva que motiva al personal

## 🎨 Paleta de Colores Corporativa

### Colores Principales
- **Pantone 505 C**: `#7F2141` (RGB: 127, 33, 65) - Botones principales, headers
- **Pantone 7504 C**: `#AF8D6B` (RGB: 175, 141, 107) - Enlaces, elementos interactivos
- **Pantone 467 C**: `#B39F82` (RGB: 179, 159, 130) - Separadores, bordes
- **Pantone Warm Grey 1 C**: `#D4D0C8` (RGB: 212, 208, 200) - Fondos suaves

### Colores Secundarios
- **Pantone 7420 C**: `#9F2241` (RGB: 159, 34, 65)
- **Pantone 4635 C**: `#945F50` (RGB: 148, 95, 80)
- **Pantone 465 C**: `#8D6F5B` (RGB: 141, 111, 91)
- **Pantone 468 C**: `#8D8264` (RGB: 141, 130, 100)

## 🛠️ Stack Tecnológico

### Frontend
- **Framework**: React 18+ con TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Estado**: React Context API + useReducer
- **Navegación**: React Router DOM v6
- **Fechas**: date-fns
- **Iconos**: Lucide React
- **Gráficos**: Recharts

### Backend
- **Base de Datos**: PostgreSQL (Supabase)
- **Autenticación**: Supabase Auth
- **API**: REST APIs auto-generadas
- **Real-time**: Supabase Realtime
- **Funciones**: Edge Functions

## 📋 Módulos Principales

### 1. Autenticación y Usuarios
- Login con email/password
- Roles: Super Admin, Admin de Centro, Usuario de Inventario, Solo Lectura
- Permisos granulares
- Gestión de sesiones

### 2. Dashboard
- KPIs en tiempo real
- Selector de centro de salud
- Alertas de stock bajo
- Métricas de caducidad

### 3. Gestión de Inventario
- CRUD completo de medicamentos
- Catálogo maestro
- Control de lotes y caducidad
- Búsqueda y filtros avanzados

### 4. Sistema de Alertas Gamificado
- **Crítico** (0-7 días): Zona de Peligro 🔴
- **Urgente** (8-30 días): Zona de Advertencia 🟠
- **Preventivo** (31-90 días): Zona de Prevención 🟡
- Sistema de puntos y logros
- Ranking entre centros

### 5. Transferencias
- Solicitud de transferencias entre centros
- Flujo de aprobación
- Tracking en tiempo real
- Documentación automática

### 6. Requisiciones Internas
- Solicitudes por servicio/departamento
- Flujo: Borrador → Solicitada → Aprobada → Surtida
- Control de cantidades
- Priorización (Normal, Urgente, Emergencia)

### 7. Ajustes de Inventario
- Mermas por deterioro/rotura
- Correcciones de inventario físico
- Devoluciones a proveedor
- Evidencia fotográfica

### 8. Reportes y Análisis
- Reportes predefinidos
- Exportación a Excel/PDF
- Gráficos y visualizaciones
- Análisis predictivo

### 9. Administración
- Gestión de usuarios
- Gestión de centros de salud
- Catálogo de medicamentos
- Gestión de proveedores
- Configuración del sistema

### 10. Auditoría
- Logs detallados de todas las acciones
- Trazabilidad completa
- Información de dispositivo y ubicación
- Alertas de acciones críticas

## 🗄️ Estructura de Base de Datos

### Tablas Principales
- `users_profiles` - Perfiles de usuario
- `health_centers` - Centros de salud
- `medication_catalog` - Catálogo maestro
- `medications` - Inventario por centro
- `transfers` - Transferencias entre centros
- `requisitions` - Requisiciones internas
- `inventory_adjustments` - Ajustes de inventario
- `alertas_medicamentos` - Sistema de alertas
- `audit_log` - Registro de auditoría

## 🚀 Instalación y Configuración

### Requisitos Previos
- Node.js 18+
- Cuenta de Supabase
- Git

### Variables de Entorno
```bash
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Instalación
```bash
# Clonar repositorio
git clone <repository-url>
cd MED_DGPRS

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Ejecutar en desarrollo
npm run dev

# Build para producción
npm run build
```

## 📦 Scripts Disponibles

- `npm run dev` - Ejecutar en modo desarrollo
- `npm run build` - Build para producción
- `npm run preview` - Preview del build
- `npm run lint` - Ejecutar linter
- `npm test` - Ejecutar tests

## 🎮 Sistema de Gamificación

### Niveles de Alerta
1. **🔴 CRÍTICO (0-7 días)** - 100 puntos de urgencia
2. **🟠 URGENTE (8-30 días)** - 50 puntos de urgencia
3. **🟡 PREVENTIVO (31-90 días)** - 20 puntos de urgencia

### Badges Disponibles
- 🏆 Principiante Organizado
- ⭐ Guardián Atento
- 💎 Maestro del Inventario
- 🔥 Racha de Fuego
- 🌟 Estrella del Mes
- 🎯 Precisión Total
- ⚡ Respuesta Rápida
- 🌱 Prevención Proactiva

## 🔒 Seguridad

- Row Level Security (RLS) en PostgreSQL
- Autenticación JWT
- Encriptación de datos sensibles
- Auditoría completa de acciones
- Sesiones seguras con timeout

## 📱 Responsive Design

- Mobile-first approach
- Breakpoints: sm (640px), md (768px), lg (1024px), xl (1280px)
- Adaptación completa a todos los dispositivos

## 🧪 Testing

- Unit tests con Vitest
- Integration tests
- E2E tests con Playwright

## 📄 Licencia

Propietario - Todos los derechos reservados

## 👥 Equipo de Desarrollo

Desarrollado para optimizar la gestión farmacéutica en centros de salud.

## 📞 Soporte

Para soporte técnico, contactar al equipo de desarrollo.

---

**Versión**: 2.0
**Última actualización**: Noviembre 2024
**Estado**: En desarrollo
