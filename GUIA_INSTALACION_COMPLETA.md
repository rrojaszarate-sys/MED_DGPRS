# 🚀 GUÍA DE INSTALACIÓN COMPLETA - SIGIMED v2.0

**Fecha**: 2025-11-18
**Versión**: 2.0.1
**Autor**: Sistema SIGIMED

---

## 📋 ÍNDICE

1. [Prerequisitos](#prerequisitos)
2. [Paso 1: Configurar Base de Datos](#paso-1-configurar-base-de-datos)
3. [Paso 2: Configurar Variables de Entorno](#paso-2-configurar-variables-de-entorno)
4. [Paso 3: Instalar Dependencias](#paso-3-instalar-dependencias)
5. [Paso 4: Ejecutar Aplicación](#paso-4-ejecutar-aplicación)
6. [Credenciales de Prueba](#credenciales-de-prueba)
7. [Solución de Problemas](#solución-de-problemas)

---

## ✅ PREREQUISITOS

Antes de comenzar, asegúrate de tener:

- [ ] **Node.js 18+** instalado
- [ ] **npm** o **yarn** instalado
- [ ] **Cuenta de Supabase** (gratis en https://supabase.com)
- [ ] **Git** instalado
- [ ] Navegador web moderno (Chrome, Firefox, Edge)

---

## 🗄️ PASO 1: CONFIGURAR BASE DE DATOS

### 1.1 Acceder a Supabase SQL Editor

Abre esta URL en tu navegador (usa tu Project ID):

```
https://supabase.com/dashboard/project/cyslhzynfuetthxngpoy/sql
```

O manualmente:
1. Ve a https://supabase.com/dashboard
2. Selecciona tu proyecto **SIGIMED**
3. En el menú lateral, click en **SQL Editor**

### 1.2 Ejecutar Script Completo

**Opción A: Usando el archivo consolidado (RECOMENDADO)**

1. **Abrir el archivo SQL** en GitHub:
   ```
   https://github.com/rrojaszarate-sys/MED_DGPRS/blob/claude/analyze-missing-features-01VXeagXyVTWi8zVqYZphhyM/migrations/SIGIMED_v2_DB_COMPLETA.sql
   ```

2. **Copiar TODO el contenido**:
   - Click en el icono 📄 "Copy raw contents" (esquina superior derecha)
   - O seleccionar todo (Ctrl+A) y copiar (Ctrl+C)

3. **Pegar en Supabase SQL Editor**:
   - Click en el editor
   - Pegar (Ctrl+V)

4. **Ejecutar**:
   - Click en botón verde **"RUN"** (o F5)
   - ⏳ **Esperar 3-7 minutos** (el script es grande)

5. **Verificar resultado**:
   - Al final deberías ver mensajes de éxito
   - "✅ INSTALACIÓN COMPLETADA EXITOSAMENTE"

**Opción B: Usando archivos locales**

Si tienes el proyecto clonado localmente:

```bash
# En la carpeta del proyecto
cat migrations/SIGIMED_v2_DB_COMPLETA.sql | pbcopy  # Mac
cat migrations/SIGIMED_v2_DB_COMPLETA.sql | clip    # Windows
cat migrations/SIGIMED_v2_DB_COMPLETA.sql | xclip -selection clipboard  # Linux
```

Luego pegar en Supabase SQL Editor y ejecutar.

### 1.3 Cargar Datos de Prueba (Opcional)

**Datos incluidos en el script base:**
- ✅ 1 Centro de salud de ejemplo
- ✅ 1 Usuario admin (admin@sigimed.com)
- ✅ Algunos medicamentos de ejemplo

**Para cargar datos reales de centros penitenciarios:**

1. Abrir archivo: `migrations/DATOS_PRUEBA_COMPLETOS.sql`
2. Copiar contenido
3. Pegar en SQL Editor de Supabase
4. Click **RUN**

Esto cargará:
- 23 Centros Penitenciarios del Estado de México
- 80+ Medicamentos del catálogo
- 110+ Lotes con fechas y proveedores

### 1.4 Verificar Instalación

Ir al **Table Editor** de Supabase:
```
https://supabase.com/dashboard/project/cyslhzynfuetthxngpoy/editor
```

Deberías ver **~60 tablas** creadas, incluyendo:
- ✅ `centros_salud`
- ✅ `users_profiles`
- ✅ `medication_catalog`
- ✅ `batches`
- ✅ `dispensaciones`
- ✅ `gs1_gtins`
- ✅ `medication_serializations`
- ✅ `drug_interactions`
- ✅ `qr_codes`
- ✅ `fhir_endpoints`
- ✅ `notification_templates`
- ✅ `kpi_definitions`
- Y muchas más...

---

## 🔧 PASO 2: CONFIGURAR VARIABLES DE ENTORNO

### 2.1 Copiar archivo de configuración

En la raíz del proyecto:

```bash
# Copiar el template
cp .env.local .env

# O si no existe .env.local
cp .env.example .env
```

### 2.2 Editar archivo .env

Abrir el archivo `.env` con tu editor favorito y asegurarte que tenga:

```env
# SUPABASE CONFIGURATION
VITE_SUPABASE_URL=https://cyslhzynfuetthxngpoy.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY

# APPLICATION SETTINGS
VITE_APP_NAME=SIGIMED
VITE_APP_VERSION=2.0.1
NODE_ENV=development
```

### 2.3 Verificar credenciales

Las credenciales están en:
```
Supabase Dashboard → Settings → API
```

O directamente:
```
https://supabase.com/dashboard/project/cyslhzynfuetthxngpoy/settings/api
```

---

## 📦 PASO 3: INSTALAR DEPENDENCIAS

En la terminal, en la raíz del proyecto:

```bash
# Instalar dependencias con npm
npm install

# O con yarn
yarn install

# O con pnpm
pnpm install
```

**Tiempo estimado**: 2-5 minutos

---

## ▶️ PASO 4: EJECUTAR APLICACIÓN

### 4.1 Modo Desarrollo

```bash
# Iniciar servidor de desarrollo
npm run dev

# O con yarn
yarn dev

# O con pnpm
pnpm dev
```

La aplicación se abrirá en:
```
http://localhost:5173
```

### 4.2 Build de Producción

```bash
# Crear build optimizado
npm run build

# Previsualizar build
npm run preview
```

---

## 🔑 CREDENCIALES DE PRUEBA

### Usuario Administrador

Las siguientes credenciales están pre-cargadas en la base de datos:

```
📧 Email: admin@sigimed.com
🔒 Password: Admin123!
👤 Rol: Super Admin
```

### Otros usuarios de prueba

Si ejecutaste el script completo, también tienes:

```
📧 Email: farmaceutico@sigimed.com
🔒 Password: Farm123!
👤 Rol: Farmacéutico

📧 Email: almacenista@sigimed.com
🔒 Password: Alma123!
👤 Rol: Warehouse Manager
```

---

## 🎯 ESTRUCTURA DE LA BASE DE DATOS

### Tablas Core (01-10)

| Tabla | Descripción | Registros |
|-------|-------------|-----------|
| `centros_salud` | Centros de salud/penitenciarios | 1-23 |
| `users_profiles` | Usuarios del sistema | 1-3 |
| `medication_catalog` | Catálogo de medicamentos | 0-80 |
| `batches` | Lotes de medicamentos | 0-110 |
| `dispensaciones` | Registro de dispensaciones | 0+ |
| `ubicaciones_almacen` | Ubicaciones físicas | 0+ |

### Funcionalidades Avanzadas (11-17)

| Tabla | Descripción | Estándar |
|-------|-------------|----------|
| `gs1_gtins` | Códigos de barras GS1 | GS1 Global |
| `medication_serializations` | Serialización DSCSA | FDA DSCSA |
| `drug_interactions` | Interacciones medicamentosas | DrugBank |
| `qr_codes` | Códigos QR generados | ISO/IEC 18004 |
| `fhir_endpoints` | Endpoints FHIR | HL7 FHIR R4 |
| `notification_templates` | Plantillas de notificaciones | Multi-channel |
| `kpi_definitions` | Definiciones de KPIs | BI |

**Total**: ~60 tablas, ~60 funciones, ~20 vistas

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "syntax error at or near..."

**Causa**: El script SQL no se copió completo o hay caracteres especiales

**Solución**:
1. Limpiar la base de datos (si es nueva)
2. Copiar el script nuevamente desde GitHub
3. Asegurarse de copiar TODO (Ctrl+A, Ctrl+C)
4. Ejecutar de nuevo

### Error: "Connection refused" al iniciar app

**Causa**: Variables de entorno incorrectas

**Solución**:
1. Verificar que `.env` existe
2. Verificar que tiene las credenciales correctas
3. Reiniciar el servidor de desarrollo: `npm run dev`

### Error: "Failed to fetch" en la app

**Causa**: URL de Supabase incorrecta o base de datos no configurada

**Solución**:
1. Verificar `VITE_SUPABASE_URL` en `.env`
2. Verificar que las migraciones se ejecutaron correctamente
3. Ir a Supabase → Table Editor y verificar que hay tablas

### Error: "Invalid credentials" al hacer login

**Causa**: Usuario no creado o password incorrecto

**Solución**:
1. Verificar que el script completo se ejecutó
2. Ir a Supabase → Authentication → Users
3. Debe aparecer `admin@sigimed.com`
4. Si no aparece, ejecutar manualmente:
   ```sql
   -- En Supabase SQL Editor
   SELECT * FROM users_profiles WHERE email = 'admin@sigimed.com';
   ```

### Tablas no aparecen en Table Editor

**Causa**: Script no se ejecutó o hubo error

**Solución**:
1. Ir a Supabase SQL Editor
2. Ejecutar:
   ```sql
   SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';
   ```
3. Debe retornar ~60
4. Si retorna menos, re-ejecutar script completo

### Error de permisos (RLS)

**Causa**: Row Level Security bloqueando acceso

**Solución**:
1. Verificar que estás autenticado
2. Logout y login de nuevo
3. Verificar rol del usuario:
   ```sql
   SELECT email, role FROM users_profiles WHERE email = 'admin@sigimed.com';
   ```

---

## 📚 DOCUMENTACIÓN ADICIONAL

### Archivos importantes

- `IMPLEMENTACION_FUNCIONALIDADES_AVANZADAS.md` - Documentación técnica completa
- `ANALISIS_GAPS_ESTANDARES_INTERNACIONALES.md` - Análisis de gaps y estándares
- `migrations/SIGIMED_v2_DB_COMPLETA.sql` - Script completo de base de datos
- `migrations/DATOS_PRUEBA_COMPLETOS.sql` - Datos de prueba (centros y medicamentos)

### Enlaces útiles

**GitHub**
```
https://github.com/rrojaszarate-sys/MED_DGPRS
```

**Supabase Dashboard**
```
https://supabase.com/dashboard/project/cyslhzynfuetthxngpoy
```

**SQL Editor**
```
https://supabase.com/dashboard/project/cyslhzynfuetthxngpoy/sql
```

**Table Editor**
```
https://supabase.com/dashboard/project/cyslhzynfuetthxngpoy/editor
```

---

## 🎉 ¡LISTO!

Si seguiste todos los pasos, deberías tener:

- ✅ Base de datos completa con 60+ tablas
- ✅ Funcionalidades avanzadas (GS1, DSCSA, FHIR, etc.)
- ✅ Variables de entorno configuradas
- ✅ Aplicación corriendo en http://localhost:5173
- ✅ Usuario admin funcionando

**Próximo paso**: ¡Empezar a usar SIGIMED! 🚀

---

## 📞 SOPORTE

Si tienes problemas:

1. **Revisar esta guía** completa
2. **Consultar documentación** técnica
3. **Revisar logs** de la consola del navegador (F12)
4. **Crear Issue** en GitHub con detalles del error

---

**SIGIMED v2.0** - Sistema Integral de Gestión de Medicamentos
© 2025 - Todos los derechos reservados
