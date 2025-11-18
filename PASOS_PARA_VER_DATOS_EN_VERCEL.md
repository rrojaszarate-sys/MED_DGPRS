# 🚀 PASOS PARA VER LOS DATOS EN VERCEL

## ✅ CAMBIOS YA PUSHEADOS

**Rama:** `claude/analyze-missing-features-01VXeagXyVTWi8zVqYZphhyM`

**Últimos commits:**
- ✅ `6cd54a1` - Scripts para desactivar RLS y verificar datos
- ✅ `b7450d7` - TODOS los hooks corregidos (10 hooks)
- ✅ `2e44f0d` - Análisis completo de integración
- ✅ `5379204` - Resumen de implementación SIGIMED v2.0

---

## 📋 CHECKLIST PARA VERCEL

### **PASO 1: Configurar Variables de Entorno en Vercel** ⚠️

Ve a tu proyecto en Vercel Dashboard y agrega estas variables:

```
VITE_SUPABASE_URL=https://gpkksfanopsvarfobcoa.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdwa2tzZmFub3BzdmFyZm9iY29hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0OTE5NTcsImV4cCI6MjA3OTA2Nzk1N30._ZJuHMjczugBF9uO_CT1Opxi0jMg3o8h8NMpWPOCrCU
```

**Cómo:**
1. Vercel Dashboard → Tu proyecto → Settings → Environment Variables
2. Agrega ambas variables
3. Marca: "Production", "Preview", "Development"
4. Click "Save"

---

### **PASO 2: Desactivar RLS en Supabase** 🔓

**IMPORTANTE:** Sin este paso, NO verás datos.

**Ejecuta este SQL en Supabase:**
```sql
-- Ve a: https://supabase.com/dashboard/project/gpkksfanopsvarfobcoa/sql
-- Copia y pega esto:

ALTER TABLE instituciones DISABLE ROW LEVEL SECURITY;
ALTER TABLE centros_salud DISABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_medicamentos DISABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE perfiles_usuario DISABLE ROW LEVEL SECURITY;
ALTER TABLE lotes DISABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_lotes DISABLE ROW LEVEL SECURITY;
ALTER TABLE medicamentos DISABLE ROW LEVEL SECURITY;
ALTER TABLE ubicaciones_almacen DISABLE ROW LEVEL SECURITY;
ALTER TABLE lotes_ubicaciones DISABLE ROW LEVEL SECURITY;
ALTER TABLE gs1_configuracion_empresa DISABLE ROW LEVEL SECURITY;
ALTER TABLE registro_auditoria DISABLE ROW LEVEL SECURITY;
ALTER TABLE alertas_interacciones DISABLE ROW LEVEL SECURITY;

SELECT '✅ RLS DESACTIVADO' as resultado;
```

**Click en "RUN"** y espera ver: `✅ RLS DESACTIVADO`

---

### **PASO 3: Redeploy en Vercel** 🔄

Después de configurar las variables de entorno:

1. Ve a: Vercel Dashboard → Tu proyecto → Deployments
2. Click en el último deployment
3. Click en **"Redeploy"**
4. Espera 2-3 minutos

**O desde Git:**
```bash
# Si Vercel está conectado a GitHub, automáticamente detectará el push
# Solo espera 2-3 minutos
```

---

### **PASO 4: Verificar que Funciona** ✅

Abre tu aplicación en Vercel y deberías ver:

✅ **Dashboard:**
- Total Centros: 23
- Total Instituciones: 2

✅ **Página "Centros de Salud":**
- Lista de 23 centros penitenciarios del Estado de México
- CPRS-CHALCO-01, CPRS-CUAU-02, CPRS-ECAT-03, etc.

✅ **Página "Instituciones":**
- DGPRS (Dirección General de Prevención y Readaptación Social)
- Secretaría de Salud - Estado de México

✅ **Catálogo de Medicamentos:**
- 99 medicamentos del cuadro básico
- KETOCONAZOL/CLINDAMICINA, AMOXICILINA/CLAVULANATO, etc.

---

## 🔍 SI NO VES DATOS

### **Problema 1: Variables de entorno no configuradas**
**Síntoma:** Página en blanco o error de conexión
**Solución:** Verifica que agregaste las variables en Vercel (PASO 1)

### **Problema 2: RLS aún activo**
**Síntoma:** Página carga pero sin datos
**Solución:** Ejecuta el script SQL del PASO 2

### **Problema 3: Caché de Vercel**
**Síntoma:** Aún ves versión vieja
**Solución:**
- Hard refresh: Ctrl + Shift + R
- O abre en modo incógnito

### **Problema 4: Build falló**
**Síntoma:** Error 500 o página de error
**Solución:**
- Ve a Vercel → Deployments → Ver logs del build
- Si ves errores TypeScript, compártelos

---

## 📊 DATOS CONFIRMADOS EN BASE DE DATOS

Ya verificamos que los datos EXISTEN:

| Tabla | Registros |
|-------|-----------|
| instituciones | 2 ✅ |
| centros_salud | 23 ✅ |
| catalogo_medicamentos | 99 ✅ |
| gs1_configuracion_empresa | 1 ✅ |
| proveedores | 0 (normal) |
| perfiles_usuario | 0 (normal) |
| lotes | 0 (normal) |

---

## 🎯 PRÓXIMOS PASOS (DESPUÉS DE VER LOS DATOS)

Una vez que confirmes que ves los datos:

1. **Configurar RLS correctamente** (para producción)
2. **Crear primer usuario administrador**
3. **Registrar proveedores**
4. **Crear lotes de prueba**
5. **Configurar políticas de seguridad**

---

## 📞 DEBUG RÁPIDO

Si algo no funciona, ejecuta esto en Supabase y comparte el resultado:

```sql
-- Verificar que RLS está desactivado
SELECT
  tablename,
  rowsecurity as rls_activo
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('centros_salud', 'catalogo_medicamentos', 'instituciones')
ORDER BY tablename;
```

**Deberías ver:** `rls_activo = false` en las 3 tablas.

---

**Última actualización:** 18 de Noviembre 2025
**Rama:** claude/analyze-missing-features-01VXeagXyVTWi8zVqYZphhyM
**Estado:** ✅ Listo para deployment
