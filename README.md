# SIGIMED - Sistema de Gestión de Inventario de Medicamentos

## 📚 Documentación Rápida

- 🚀 **[Guía de Ejecución Local](docs/GUIA_EJECUCION_LOCAL.md)** - Cómo ejecutar el proyecto localmente
- 📖 **[Documentación Técnica](docs/DOCUMENTACION_TECNICA.md)** - Arquitectura y especificaciones técnicas
- 📘 **[Manual de Usuario](docs/MANUAL_DE_USUARIO.md)** - Guía completa para usuarios finales
- 🧪 **[Plan de Pruebas](docs/PLAN_PRUEBAS_AUTOMATIZADAS.md)** - Estrategia de testing
- ✅ **[Pruebas de Escritorio](docs/PRUEBAS_ESCRITORIO_INTERNAS.md)** - Testing interno
- 🔍 **[Validación QA](docs/VALIDACION_EXTERNA_QA.md)** - Checklist de QA externa

## 🎯 Objetivo Principal

Sistema web moderno para la gestión integral, segura y trazable del inventario de medicamentos en múltiples centros de salud.

## ✨ Características Principales

- **Control Total del Inventario**: Registro preciso de entradas, salidas, transferencias y ajustes con monitoreo en tiempo real
- **Trazabilidad Completa**: Seguimiento detallado de cada medicamento desde ingreso hasta salida con auditoría de todas las acciones
- **Gestión Documental Inteligente**: Generación automática de PDFs con firma digital, OCR para extracción de datos
- **Optimización de Recursos**: Prevención de desabastecimiento mediante análisis predictivo
- **Cumplimiento Normativo**: Documentación completa para auditorías sanitarias
- **Sistema Gamificado de Alertas**: Experiencia interactiva que motiva al personal

## 🆕 Nuevas Funcionalidades (v2.0.1)

- **✨ Transferencias entre Centros**: Workflow completo de 5 estados con control de cantidades en cada etapa (solicitada, aprobada, enviada, recibida)
- **✨ Requisiciones Internas**: Sistema de solicitudes por departamento con 3 niveles de prioridad (Normal, Urgente, Emergencia)
- **✨ Ajustes de Inventario**: 4 tipos de ajustes (merma, corrección, devolución, reclasificación) con evidencia fotográfica y autorización
- **✨ Gestión Completa de Lotes**: CRUD completo con cambio de estados, tracking de proveedores y control de caducidad
- **✨ 33 Tablas de Base de Datos**: Estructura robusta con catálogos configurables y sistema de auditoría completo

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
- Catálogo maestro de medicamentos
- Gestión completa de lotes (batches)
  - Creación, edición y eliminación de lotes
  - Control de estados: Disponible, Cuarentena, Vencido, Agotado
  - Tracking de cantidades (inicial, actual, stock mínimo/máximo)
  - Trazabilidad por proveedor y centro de salud
- Control de caducidad por lote
- Búsqueda y filtros avanzados

### 4. Sistema de Alertas Gamificado
- **Crítico** (0-7 días): Zona de Peligro 🔴
- **Urgente** (8-30 días): Zona de Advertencia 🟠
- **Preventivo** (31-90 días): Zona de Prevención 🟡
- Sistema de puntos y logros
- Ranking entre centros

### 5. Transferencias entre Centros
- Solicitud de transferencias entre centros de salud
- **Flujo completo de estados**:
  - 📝 Pendiente → ✅ Aprobada/❌ Rechazada → 🚚 En Tránsito → 📦 Recibida → ✔️ Completada
- Control de cantidades por etapa:
  - Cantidad solicitada
  - Cantidad aprobada (puede diferir de la solicitada)
  - Cantidad enviada
  - Cantidad recibida (detección automática de faltantes)
- Tracking de usuarios responsables en cada etapa
- Múltiples ítems por transferencia
- Documentación automática con número de seguimiento
- Visualización de origen y destino con códigos de centro

### 6. Requisiciones Internas
- Solicitudes de medicamentos por servicio/departamento
- **Flujo completo de estados**:
  - 📝 Borrador → 📤 Solicitada → ✅ Aprobada/❌ Rechazada → 📦 Surtida → ✔️ Completada
- Control de cantidades en tres niveles:
  - Cantidad solicitada (original)
  - Cantidad aprobada (ajustada por autorizador)
  - Cantidad surtida (real entregada)
- **Sistema de priorización**:
  - 🟢 Normal - Suministro regular
  - 🟡 Urgente - Requiere atención prioritaria
  - 🔴 Emergencia - Atención inmediata
- Justificación por ítem
- Tracking de fechas clave (solicitud, aprobación, surtido)
- Identificación de servicio solicitante

### 7. Ajustes de Inventario
- **Tipos de ajuste**:
  - 📉 Merma - Pérdidas por deterioro, rotura, vencimiento
  - 🔧 Corrección - Ajustes entre cantidad física vs. sistema
  - ↩️ Devolución - Retorno de productos a proveedor
  - 🔄 Reclasificación - Cambio de categorización
- **Cálculo automático de diferencias**:
  - Cantidad en sistema
  - Cantidad física contada
  - Diferencia calculada automáticamente (física - sistema)
- **Sistema de evidencia fotográfica**:
  - Upload de múltiples fotos por ajuste
  - Almacenamiento en Supabase Storage
  - Galería visual en la interfaz
- **Flujo de autorización**:
  - Creación por usuario de inventario
  - Requiere autorización por supervisor
  - Tracking de autorizador y fecha
- Motivo y justificación obligatorios
- Generación automática de número de ajuste

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

### Tablas Principales (33 tablas implementadas)

#### Usuarios y Autenticación
- `users_profiles` - Perfiles extendidos de usuario con roles
- `audit_log` - Registro completo de auditoría

#### Organización
- `instituciones` - Instituciones de salud
- `health_centers` - Centros de salud por institución

#### Catálogos Maestros
- `medication_catalog` - Catálogo nacional de medicamentos
- `suppliers` - Catálogo de proveedores

#### Inventario y Lotes
- `medications` - Medicamentos por centro de salud
- `batches` - Lotes de medicamentos con tracking completo
- `batch_movements` - Movimientos detallados de lotes

#### Workflows de Operación
- `transfers` - Transferencias entre centros
- `transfer_items` - Items de cada transferencia
- `requisitions` - Requisiciones internas por servicio
- `requisition_items` - Items de cada requisición
- `inventory_adjustments` - Ajustes de inventario con evidencia

#### Contratos y Compras
- `contracts` - Contratos con proveedores
- `contract_items` - Items de cada contrato

#### Sistema de Alertas
- `alertas_medicamentos` - Alertas de caducidad y stock

#### Catálogos Configurables (Sistema Avanzado)
- `catalogo_colores` - Paleta de colores del sistema
- `catalogo_estados` - Estados por módulo
- `catalogo_tipos_movimiento` - Tipos de movimientos
- `catalogo_formas_farmaceuticas` - Formas farmacéuticas
- `catalogo_prioridades` - Niveles de prioridad
- `catalogo_configuraciones` - Configuraciones del sistema

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

### Desarrollo
- `npm run dev` - Ejecutar en modo desarrollo con banner de MODO DESARROLLO
- `npm run build` - Build para producción
- `npm run preview` - Preview del build de producción

### Testing
- `npm run test` - Ejecutar tests en modo watch
- `npm run test:run` - Ejecutar tests una sola vez
- `npm run test:ui` - Abrir interfaz visual de tests
- `npm run test:coverage` - Generar reporte de cobertura

### Calidad de Código
- `npm run lint` - Ejecutar linter ESLint

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

## 📊 Estado del Proyecto

**Versión**: 2.0.1
**Última actualización**: Noviembre 2024
**Estado**: En desarrollo activo - **~75% completado**

### Módulos Implementados ✅
- ✅ Autenticación y Roles
- ✅ Dashboard con KPIs
- ✅ Gestión de Inventario
- ✅ Gestión de Lotes (CRUD completo)
- ✅ Sistema de Alertas Gamificado
- ✅ **Transferencias entre Centros** (workflow completo)
- ✅ **Requisiciones Internas** (workflow completo)
- ✅ **Ajustes de Inventario** (con evidencia fotográfica)
- ✅ Reportes y Exportación
- ✅ Administración (Usuarios, Centros, Catálogos)
- ✅ Sistema de Auditoría
- ✅ Gestión de Proveedores
- ✅ Gestión de Contratos

### En Desarrollo 🚧
- 🚧 Órdenes de Compra
- 🚧 Recepción de Mercancía
- 🚧 Devoluciones a Proveedores
- 🚧 Análisis Predictivo Avanzado
- 🚧 Formularios de creación/edición en modales

### Roadmap 🗺️
- 📋 Integración con sistemas externos
- 📋 App móvil nativa
- 📋 Notificaciones push
- 📋 Reportes personalizados avanzados
