# 🔧 Modo de Desarrollo - SIGIMED

## Variables de Entorno para Desarrollo

```env
VITE_SUPABASE_URL=https://cyslhzynfuetthxngpoy.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_APP_NAME=SIGIMED
VITE_APP_VERSION=2.0
VITE_DEV_MODE=true  ← ACTIVADO: Permite seleccionar perfil sin login
```

## 🚀 Cómo Usar

1. Asegúrate de que `VITE_DEV_MODE=true` en tu `.env`
2. Ejecuta: `npm run dev`
3. Abre: http://localhost:5173
4. Verás una sección amarilla: **🚀 Acceso Rápido - Desarrollo**
5. Selecciona un perfil del dropdown
6. Click en **⚡ Entrar Sin Login**

## 👥 Perfiles Disponibles

| Perfil | Rol | Acceso Panel Admin |
|--------|-----|-------------------|
| Super Admin | `super_admin` | ✅ Sí |
| Administrador Centro | `admin_center` | ✅ Sí |
| Usuario Inventario | `inventory_user` | ❌ No |
| Solo Lectura | `read_only` | ❌ No |

## ⚠️ Importante

- **SOLO para desarrollo local**
- **NUNCA activar en producción** (`VITE_DEV_MODE=false` o sin definir)
- Sin autenticación real = Sin seguridad

## 🔄 Desactivar Modo Desarrollo

Cambia en `.env`:
```env
VITE_DEV_MODE=false
```

Reinicia el servidor y verás el login normal con Supabase.
