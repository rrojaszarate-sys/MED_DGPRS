# 🚀 Guía de Deployment en Vercel - SIGIMED v2.0

## Método 1: Deploy desde la Interfaz Web de Vercel (RECOMENDADO)

### Paso 1: Preparar el Repositorio
✅ **YA COMPLETADO** - El código ya está en GitHub en la rama `claude/sigimed-pharmacy-inventory-system-011CUsPaLTQu1CP5Nk4mcdpD`

### Paso 2: Importar Proyecto en Vercel

1. Ve a [vercel.com](https://vercel.com)
2. Inicia sesión con tu cuenta (GitHub, GitLab, o Bitbucket)
3. Click en **"Add New..."** → **"Project"**
4. Busca el repositorio `MED_DGPRS`
5. Click en **"Import"**

### Paso 3: Configurar el Proyecto

En la pantalla de configuración:

#### Framework Preset
- Selecciona: **Vite**
- Vercel lo detectará automáticamente

#### Build and Output Settings
- **Build Command**: `npm run build` (detectado automáticamente)
- **Output Directory**: `dist` (detectado automáticamente)
- **Install Command**: `npm install` (detectado automáticamente)

#### Root Directory
- Dejar en blanco (raíz del proyecto)

### Paso 4: Variables de Entorno

Agrega las siguientes variables de entorno (Environment Variables):

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

**⚠️ IMPORTANTE**: Reemplaza con tus credenciales reales de Supabase

#### Cómo obtener las credenciales de Supabase:

1. Ve a [supabase.com](https://supabase.com)
2. Abre tu proyecto SIGIMED
3. Ve a **Settings** → **API**
4. Copia:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon public** key → `VITE_SUPABASE_ANON_KEY`

### Paso 5: Deploy

1. Click en **"Deploy"**
2. Espera 2-3 minutos mientras Vercel construye y despliega
3. ¡Listo! Tu aplicación estará disponible en `https://your-project.vercel.app`

---

## Método 2: Deploy desde la Línea de Comandos (ALTERNATIVO)

### Requisitos Previos
```bash
npm install -g vercel
```

### Paso 1: Login en Vercel
```bash
vercel login
```

### Paso 2: Deploy
```bash
# Desde la raíz del proyecto
vercel

# Sigue las instrucciones interactivas:
# - Set up and deploy? → Y
# - Which scope? → Selecciona tu cuenta
# - Link to existing project? → N
# - What's your project's name? → sigimed
# - In which directory is your code located? → ./
# - Want to override the settings? → N
```

### Paso 3: Configurar Variables de Entorno
```bash
# Agregar las variables de Supabase
vercel env add VITE_SUPABASE_URL
# Pega tu URL cuando te lo pida

vercel env add VITE_SUPABASE_ANON_KEY
# Pega tu anon key cuando te lo pida
```

### Paso 4: Deploy a Producción
```bash
vercel --prod
```

---

## Configuración Post-Deploy

### 1. Configurar Dominio Personalizado (Opcional)

En el dashboard de Vercel:
1. Ve a tu proyecto
2. Click en **"Settings"** → **"Domains"**
3. Agrega tu dominio personalizado (ej: `sigimed.tuempresa.com`)
4. Sigue las instrucciones para configurar DNS

### 2. Verificar Configuración de Supabase

Asegúrate de que Supabase permita tu dominio de Vercel:

1. Ve a Supabase → **Authentication** → **URL Configuration**
2. Agrega tu URL de Vercel a:
   - **Site URL**: `https://tu-proyecto.vercel.app`
   - **Redirect URLs**:
     - `https://tu-proyecto.vercel.app/**`
     - `https://tu-proyecto.vercel.app/login`

### 3. Habilitar CORS en Supabase

1. Ve a Supabase → **Settings** → **API**
2. En **API Settings**, asegúrate de que tu dominio de Vercel esté permitido

---

## Verificación del Deployment

### Checklist Post-Deploy ✅

- [ ] La aplicación carga correctamente en el navegador
- [ ] El login con Supabase funciona
- [ ] Las rutas funcionan correctamente (Dashboard, Inventario, Alertas, Admin)
- [ ] Las variables de entorno están configuradas
- [ ] Los datos de Supabase se cargan correctamente
- [ ] El build no tiene errores (verifica en Vercel logs)

### URLs Importantes

- **Dashboard de Vercel**: https://vercel.com/dashboard
- **Logs del Deployment**: En tu proyecto → **Deployments** → Click en el deployment → **View Function Logs**
- **Tu aplicación**: `https://tu-proyecto.vercel.app`

---

## Solución de Problemas Comunes

### Error: "404: NOT_FOUND"
- **Causa**: El archivo `vercel.json` no está configurado correctamente
- **Solución**: ✅ Ya está incluido en este commit

### Error: Variables de entorno no definidas
- **Síntoma**: Error "Cannot read property of undefined" al conectar a Supabase
- **Solución**:
  1. Ve a Vercel → **Settings** → **Environment Variables**
  2. Verifica que `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` estén configuradas
  3. Redeploy el proyecto

### Error: Build failed
- **Solución**:
  1. Verifica los logs en Vercel
  2. Ejecuta `npm run build` localmente para reproducir el error
  3. Revisa que todas las dependencias estén en `package.json`

### Error: CORS al conectar a Supabase
- **Solución**: Agrega tu dominio de Vercel a las URLs permitidas en Supabase (ver paso 2 arriba)

---

## Actualizaciones Futuras

### Deploy Automático
Vercel está configurado para hacer deploy automático cuando hagas push a la rama principal:

```bash
git push origin claude/sigimed-pharmacy-inventory-system-011CUsPaLTQu1CP5Nk4mcdpD
```

Vercel detectará el cambio y desplegará automáticamente.

### Previews de Ramas
Cada push a cualquier rama creará un preview deployment único que puedes compartir para testing.

---

## Comandos Útiles

```bash
# Ver status del proyecto
vercel ls

# Ver logs en tiempo real
vercel logs

# Remover el proyecto
vercel remove

# Ver información del proyecto
vercel inspect
```

---

## Recursos Adicionales

- [Documentación de Vercel](https://vercel.com/docs)
- [Vite en Vercel](https://vercel.com/docs/frameworks/vite)
- [Variables de Entorno en Vercel](https://vercel.com/docs/environment-variables)
- [Dominios Personalizados](https://vercel.com/docs/custom-domains)

---

## Soporte

Si encuentras problemas:

1. Revisa los logs en Vercel Dashboard
2. Verifica la configuración de Supabase
3. Consulta la documentación de Vercel
4. Abre un issue en el repositorio de GitHub

---

**¡Tu aplicación SIGIMED v2.0 está lista para producción! 🎉**

Última actualización: 2025-11-07
Versión: 2.0.0
