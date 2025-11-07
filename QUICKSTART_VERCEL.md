# 🚀 Deployment Rápido en Vercel - SIGIMED

## Opción 1: Deploy con 1 Click desde GitHub

### Paso 1: Ve a Vercel
👉 **[Abrir Vercel](https://vercel.com/new)**

### Paso 2: Importar Repositorio
1. Click en **"Import Git Repository"**
2. Busca `MED_DGPRS`
3. Click **"Import"**

### Paso 3: Configurar Variables de Entorno
Agrega estas 2 variables en la sección **Environment Variables**:

```
VITE_SUPABASE_URL
VITE_SUPABASE_ANON_KEY
```

**📋 Cómo obtenerlas:**
1. Ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Abre tu proyecto
3. **Settings** → **API**
4. Copia:
   - `Project URL` → `VITE_SUPABASE_URL`
   - `anon public` → `VITE_SUPABASE_ANON_KEY`

### Paso 4: Deploy
1. Click **"Deploy"**
2. Espera 2-3 minutos ⏱️
3. ¡Listo! 🎉

---

## Opción 2: Deploy desde Terminal

```bash
# 1. Instalar Vercel CLI
npm install -g vercel

# 2. Login
vercel login

# 3. Deploy
vercel

# 4. Agregar variables de entorno
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY

# 5. Deploy a producción
vercel --prod
```

---

## Configuración de Supabase

**⚠️ IMPORTANTE:** Después del deploy, configura tu URL de Vercel en Supabase:

1. Ve a Supabase → **Authentication** → **URL Configuration**
2. Agrega en **Redirect URLs**:
   ```
   https://tu-proyecto.vercel.app/**
   ```

---

## Verificación

Después del deploy, verifica que funcione:

✅ Login con Supabase
✅ Dashboard carga correctamente
✅ Inventario muestra datos
✅ Alertas funcionan
✅ Admin panel (para admin_center/super_admin)

---

## ¿Problemas?

Consulta la guía completa: **[DEPLOYMENT_VERCEL.md](./DEPLOYMENT_VERCEL.md)**

---

**Tiempo estimado:** 5-10 minutos ⏱️
