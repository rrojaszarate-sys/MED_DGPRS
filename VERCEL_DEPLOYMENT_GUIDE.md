# 🚀 Guía de Deployment en Vercel - SIGIMED

## Paso 1: Preparar el Repositorio

Asegúrate de que tu código esté en un repositorio de Git (GitHub, GitLab o Bitbucket).

```bash
# Verificar que estás en la rama correcta
git branch

# Si necesitas hacer push de cambios pendientes
git add .
git commit -m "Preparar para deployment en Vercel"
git push origin main
```

## Paso 2: Crear Cuenta en Vercel

1. Ve a [vercel.com](https://vercel.com)
2. Haz clic en **"Sign Up"**
3. Conecta con tu cuenta de GitHub/GitLab/Bitbucket
4. Autoriza a Vercel para acceder a tus repositorios

## Paso 3: Importar el Proyecto

### Opción A: Desde el Dashboard de Vercel

1. En el dashboard, haz clic en **"Add New..."** → **"Project"**
2. Selecciona el repositorio **MED_DGPRS**
3. Haz clic en **"Import"**

### Opción B: Usando Vercel CLI (Avanzado)

```bash
# Instalar Vercel CLI globalmente
npm i -g vercel

# Navegar a tu proyecto
cd /ruta/a/MED_DGPRS

# Iniciar deployment
vercel

# Para production
vercel --prod
```

## Paso 4: Configurar el Proyecto

### Build Settings

En la pantalla de configuración del proyecto, establece:

| Campo | Valor |
|-------|-------|
| **Framework Preset** | Vite |
| **Root Directory** | ./ |
| **Build Command** | `npm run build` |
| **Output Directory** | `dist` |
| **Install Command** | `npm install` |
| **Node Version** | 18.x |

### Environment Variables

Haz clic en **"Environment Variables"** y agrega las siguientes variables:

#### Variables Requeridas:

1. **VITE_SUPABASE_URL**
   - Value: `https://cyslhzynfuetthxngpoy.supabase.co`
   - Environments: ✅ Production, ✅ Preview, ✅ Development

2. **VITE_SUPABASE_ANON_KEY**
   - Value: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY`
   - Environments: ✅ Production, ✅ Preview, ✅ Development

3. **VITE_APP_NAME**
   - Value: `SIGIMED`
   - Environments: ✅ Production, ✅ Preview, ✅ Development

4. **VITE_APP_VERSION**
   - Value: `2.0`
   - Environments: ✅ Production, ✅ Preview, ✅ Development

5. **NODE_ENV**
   - Value: `production`
   - Environments: ✅ Production only

### Captura de Pantalla de Referencia:

```
┌─────────────────────────────────────────────┐
│ Environment Variables                       │
├─────────────────────────────────────────────┤
│ NAME                    VALUE              │
│ VITE_SUPABASE_URL      https://cyslh...    │
│ VITE_SUPABASE_ANON_KEY eyJhbGciOiJ...      │
│ VITE_APP_NAME          SIGIMED             │
│ VITE_APP_VERSION       2.0                 │
│ NODE_ENV               production          │
└─────────────────────────────────────────────┘
```

## Paso 5: Desplegar

1. Haz clic en **"Deploy"**
2. Espera de 2-5 minutos mientras Vercel:
   - Clona tu repositorio
   - Instala dependencias
   - Ejecuta el build
   - Despliega a la CDN global

## Paso 6: Verificar el Deployment

### 6.1 Verificar la URL

Una vez completado, verás:
```
✅ Production: https://sigimed.vercel.app
   Preview: https://sigimed-git-main-user.vercel.app
```

### 6.2 Probar la Aplicación

Abre la URL de production y verifica:

- ✅ La página carga sin errores
- ✅ Los estilos de Tailwind CSS se aplican correctamente
- ✅ El formulario de login aparece
- ✅ No hay errores en la consola del navegador (F12)

### 6.3 Probar Conexión a Supabase

1. Abre las DevTools (F12) → Console
2. Intenta hacer login con:
   - Email: `admin@sigimed.com`
   - Password: `Admin123!`
3. Si la conexión es exitosa, deberías ver:
   - Redirección al dashboard
   - Datos cargando desde Supabase

## Paso 7: Configurar Dominio Personalizado (Opcional)

### Si tienes un dominio propio:

1. Ve a **Settings** → **Domains**
2. Haz clic en **"Add"**
3. Ingresa tu dominio (ej: `sigimed.tuempresa.com`)
4. Sigue las instrucciones para configurar DNS:

```dns
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

5. Espera propagación (5-60 minutos)
6. Vercel emitirá certificado SSL automáticamente

## Paso 8: Configurar Auto-Deploy

### Deploy automático en cada push:

Vercel ya está configurado para auto-deploy por defecto:

- ✅ **Push a `main`** → Deploy a Production
- ✅ **Push a otras branches** → Deploy a Preview
- ✅ **Pull Requests** → Deploy Preview con URL única

### Deshabilitar auto-deploy (si es necesario):

1. **Settings** → **Git**
2. Desactiva **"Production Branch"**

## Paso 9: Monitoreo y Analytics

### Ver Logs de Build:

1. Ve a **Deployments**
2. Haz clic en el deployment
3. Pestaña **"Build Logs"**

### Ver Logs de Runtime:

1. Pestaña **"Runtime Logs"**
2. Filtra por errores, warnings, info

### Analytics (Opcional - Plan Pro):

- **Settings** → **Analytics**
- Habilita Vercel Analytics
- Agrega el snippet a tu código:

```tsx
// src/main.tsx
import { Analytics } from '@vercel/analytics/react';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
    <Analytics />
  </React.StrictMode>
);
```

## Paso 10: Troubleshooting

### Error: "Build failed"

**Solución:**
```bash
# Verificar que el build funciona localmente
npm install
npm run build

# Si falla localmente, arreglar primero
# Si funciona localmente, revisar logs en Vercel
```

### Error: "Cannot connect to Supabase"

**Solución:**
1. Verificar que las variables de entorno estén correctas
2. Verificar que Supabase esté activo
3. Revisar CORS en Supabase:
   - Dashboard Supabase → Settings → API
   - Add `https://sigimed.vercel.app` a allowed origins

### Error: "Module not found"

**Solución:**
```bash
# Asegurarse de que package.json está completo
npm install --save-dev @types/node vite

# Commitear y pushear
git add package.json package-lock.json
git commit -m "Fix dependencies"
git push
```

### Error: "Environment variable not defined"

**Solución:**
1. Ve a Settings → Environment Variables
2. Verifica que todas las variables tienen el prefijo `VITE_`
3. Redeploy el proyecto después de agregar variables

## Paso 11: Optimizaciones Post-Deploy

### 11.1 Configurar Headers de Seguridad

Crea `vercel.json` en la raíz:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ]
}
```

### 11.2 Configurar Redirects

Agregar al `vercel.json`:

```json
{
  "redirects": [
    {
      "source": "/admin",
      "destination": "/dashboard",
      "permanent": false
    }
  ],
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### 11.3 Habilitar Compresión

Ya está habilitado por defecto en Vercel ✅

### 11.4 Configurar Cache

```json
{
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

## Comandos Útiles de Vercel CLI

```bash
# Ver estado del proyecto
vercel list

# Ver logs en tiempo real
vercel logs

# Ver información del último deployment
vercel inspect

# Promover un preview a production
vercel promote [deployment-url]

# Eliminar un deployment
vercel remove [deployment-id]

# Ver variables de entorno
vercel env ls

# Agregar variable de entorno
vercel env add NOMBRE_VARIABLE

# Pull de variables de entorno
vercel env pull .env.local
```

## Checklist de Deployment ✅

Antes de marcar como completado, verifica:

- [ ] ✅ Código pusheado a GitHub/GitLab
- [ ] ✅ Proyecto importado en Vercel
- [ ] ✅ Variables de entorno configuradas (5 variables)
- [ ] ✅ Build exitoso
- [ ] ✅ Deployment a production completado
- [ ] ✅ URL de production accesible
- [ ] ✅ Login funcional con Supabase
- [ ] ✅ Dashboard carga correctamente
- [ ] ✅ No hay errores en consola
- [ ] ✅ Responsive en mobile (probar)
- [ ] ✅ SSL activo (HTTPS)
- [ ] ✅ Auto-deploy configurado

## Soporte

### Documentación Oficial:
- [Vercel Docs](https://vercel.com/docs)
- [Deploy Vite](https://vercel.com/guides/deploying-vite-with-vercel)
- [Environment Variables](https://vercel.com/docs/concepts/projects/environment-variables)

### Comunidad:
- [Vercel Discord](https://vercel.com/discord)
- [Supabase Discord](https://discord.supabase.com)

---

## 🎉 ¡Deployment Completado!

Tu aplicación SIGIMED ahora está:
- ✅ Live en producción
- ✅ Con SSL automático
- ✅ En CDN global (edge network)
- ✅ Con auto-deploy en cada push
- ✅ Con backups automáticos
- ✅ Escalable automáticamente

**URL de Producción**: https://sigimed.vercel.app (o tu dominio personalizado)

Puedes compartir esta URL con tu equipo para comenzar a usar SIGIMED.

---

**Última actualización**: Noviembre 2024
**Versión de esta guía**: 1.0
