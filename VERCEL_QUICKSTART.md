# ⚡ VERCEL QUICKSTART - SIGIMED

## 🎯 Deploy en 5 Minutos

### 1️⃣ Conectar Repositorio
- Ve a [vercel.com/new](https://vercel.com/new)
- Importa el repositorio `MED_DGPRS`

### 2️⃣ Configurar Build
```
Framework: Vite
Build Command: npm run build
Output Directory: dist
Install Command: npm install
```

### 3️⃣ Variables de Entorno
Copia y pega estas 5 variables en Vercel:

```bash
VITE_SUPABASE_URL=https://cyslhzynfuetthxngpoy.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY
VITE_APP_NAME=SIGIMED
VITE_APP_VERSION=2.0
NODE_ENV=production
```

### 4️⃣ Deploy
- Click **"Deploy"**
- Espera 2-3 minutos ☕

### 5️⃣ Verificar
- Abre la URL de production
- Prueba login: `admin@sigimed.com` / `Admin123!`

---

## 📱 Acceso Rápido a Archivos

| Archivo | Descripción |
|---------|-------------|
| `.env` | Variables de entorno completas |
| `.env.production` | Solo para producción |
| `VERCEL_ENV.txt` | Formato para copiar/pegar |
| `VERCEL_DEPLOYMENT_GUIDE.md` | Guía completa paso a paso |

---

## 🔧 Comandos Útiles

```bash
# Deploy manual (primera vez)
npx vercel

# Deploy a production
npx vercel --prod

# Ver logs
npx vercel logs

# Descargar env vars
npx vercel env pull
```

---

## ✅ Checklist Pre-Deploy

- [ ] Supabase configurado (schema ejecutado)
- [ ] Usuarios de prueba creados
- [ ] Variables de entorno listas
- [ ] Código en GitHub/GitLab
- [ ] package.json actualizado

---

## 🆘 Problemas Comunes

**Build failed?**
```bash
# Probar build local
npm run build
```

**No conecta a Supabase?**
- Verificar variables de entorno en Vercel
- Verificar que Supabase esté activo

**404 en rutas?**
- Verificar que `dist/` tiene `index.html`
- Agregar rewrites en `vercel.json`

---

## 📞 Soporte

- [Vercel Docs](https://vercel.com/docs)
- [Deployment Guide Completa](./VERCEL_DEPLOYMENT_GUIDE.md)

🎉 **¡Listo para deploy!**
