# 🚀 INSTRUCCIONES DE DEPLOYMENT - SIGIMED

## ⚠️ IMPORTANTE: Sigue estos pasos EN ORDEN

---

## 📋 PASO 1: APLICAR SCHEMA SQL EN SUPABASE

### 1.1 Abrir Supabase Dashboard
1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto SIGIMED
3. En el menú lateral, haz click en **SQL Editor**
4. Haz click en **New Query**

### 1.2 Ejecutar Script de Migración
1. Abre el archivo: `MIGRATION_SQL.sql` (creado en este proyecto)
2. **COPIA TODO EL CONTENIDO** del archivo
3. **PÉGALO** en el editor SQL de Supabase
4. Haz click en **Run** (o presiona Ctrl+Enter)
5. Espera a que termine (debería mostrar "Success")

### 1.3 Verificar que funcionó
Al final del script hay consultas de verificación que mostrarán:
- ✅ Tabla `batch_movements` con sus columnas
- ✅ 5 triggers de auditoría
- ✅ 4 funciones SQL nuevas

**Si algo falla:**
- Lee el mensaje de error
- Verifica que todas las tablas base existen (medications, users_profiles, etc.)
- Asegúrate de que el schema base está aplicado primero

---

## 📋 PASO 2: CONFIGURAR VERCEL PARA EL BRANCH CORRECTO

### Opción A: Configurar desde Vercel Dashboard (Recomendado)

1. **Ir a Vercel Dashboard**
   - https://vercel.com/dashboard
   - Selecciona tu proyecto SIGIMED

2. **Configurar Git Branch**
   - Ve a: **Settings** → **Git**
   - En **Production Branch**, cambia a:
     ```
     claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k
     ```
   - Guarda los cambios

3. **Hacer Re-deploy**
   - Ve a la pestaña **Deployments**
   - Click en **Redeploy** en el último deployment
   - Selecciona **Use existing Build Cache** → NO
   - Click **Redeploy**

### Opción B: Hacer Push a un branch principal

Si prefieres usar un branch main/master:

```bash
# En tu máquina local, NO en Claude Code
git clone https://github.com/rrojaszarate-sys/MED_DGPRS.git
cd MED_DGPRS

# Crear branch main desde el branch con cambios
git checkout claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k
git checkout -b main

# Push a GitHub
git push origin main

# Configurar Vercel para usar 'main'
```

---

## 📋 PASO 3: VERIFICAR QUE FUNCIONA

### 3.1 Verificar en Supabase
1. Ve a **Table Editor** en Supabase
2. Busca la tabla `batch_movements` (debería aparecer)
3. Busca la tabla `audit_log` (debería existir)

### 3.2 Verificar en Vercel
1. Espera a que termine el deployment (2-3 minutos)
2. Abre tu app: https://[tu-proyecto].vercel.app
3. Deberías ver las nuevas funcionalidades

### 3.3 Verificar las Nuevas Funcionalidades

**EN LA APLICACIÓN:**

1. **Importación Masiva** (Componente creado pero no integrado aún)
   - Necesitas agregarlo a una página
   - Ver archivo: `src/components/inventory/ImportMedications.tsx`

2. **Movimientos de Lotes** (Backend listo)
   - Prueba desde consola Supabase:
   ```sql
   SELECT registrar_movimiento_lote(
     '[id-medicamento-existente]'::uuid,
     'entrada',
     100,
     'Compra inicial',
     '[id-usuario-existente]'::uuid
   );
   ```

3. **Auditoría** (Automática)
   - Crea, edita o elimina cualquier medicamento
   - Verifica en tabla `audit_log`:
   ```sql
   SELECT * FROM audit_log ORDER BY created_at DESC LIMIT 10;
   ```

4. **Reportes Avanzados** (Backend listo)
   ```sql
   -- Probar búsqueda avanzada
   SELECT * FROM search_inventory_with_batches(
     p_search_term := 'paracetamol',
     p_vencidos := false,
     p_proximos_vencer_dias := 30
   );
   ```

---

## 📋 PASO 4: INTEGRAR EL COMPONENTE DE IMPORTACIÓN (Opcional)

Si quieres usar la importación masiva en la UI:

### 4.1 Editar InventoryPage.tsx

```typescript
// src/pages/InventoryPage.tsx
import { ImportMedications } from '../components/inventory/ImportMedications';

// Agregar dentro del componente:
<ImportMedications />
```

### 4.2 O crear una nueva ruta

```typescript
// src/App.tsx
import { ImportPage } from './pages/ImportPage';

// Agregar en las rutas:
<Route path="/import" element={<ImportPage />} />
```

---

## 🎯 RESUMEN DE CAMBIOS IMPLEMENTADOS

### ✅ Base de Datos (Supabase)
1. **Tabla `batch_movements`** - Trazabilidad completa de movimientos
2. **Función `registrar_movimiento_lote()`** - Registra movimientos con validaciones
3. **Sistema de auditoría automático** - 5 triggers en tablas principales
4. **Funciones de reportes**:
   - `generate_traceability_report()` - Reporte con historial
   - `search_inventory_with_batches()` - Búsqueda avanzada

### ✅ Frontend (React + TypeScript)
1. **Hooks:**
   - `useBatchMovements` - Gestión de movimientos
   - `useImport` - Importación masiva con validación
   - `useAuditLog` - Consulta de auditoría
2. **Utilidades:**
   - `importUtils.ts` - Parser CSV/Excel con validaciones
3. **Componentes:**
   - `ImportMedications` - UI completa de importación
4. **Tipos TypeScript:**
   - `BatchMovement`
   - `AuditLog`

### ✅ Dependencias Instaladas
- `papaparse` - Parser CSV
- `@types/papaparse` - Tipos TypeScript
- `react-hot-toast` - Notificaciones

---

## 🆘 TROUBLESHOOTING

### Problema: "Function registrar_movimiento_lote does not exist"
**Solución:** El script SQL no se ejecutó. Repite PASO 1.

### Problema: "Table batch_movements does not exist"
**Solución:** El script SQL no se ejecutó completamente. Verifica errores en Supabase.

### Problema: "No veo cambios en Vercel"
**Solución:**
1. Verifica que Vercel esté usando el branch correcto (PASO 2)
2. Haz redeploy manual desde Vercel Dashboard
3. Limpia cache del navegador (Ctrl+Shift+R)

### Problema: Errores de RLS (Row Level Security)
**Solución:** Las policies están al final del script SQL. Asegúrate de ejecutar TODO el script.

---

## 📞 SOPORTE

Si encuentras errores:
1. Copia el mensaje de error completo
2. Indica en qué paso estás
3. Verifica los logs de Supabase y Vercel

---

## ✅ CHECKLIST FINAL

- [ ] Script SQL ejecutado en Supabase sin errores
- [ ] Tabla `batch_movements` visible en Supabase Table Editor
- [ ] Vercel configurado al branch correcto
- [ ] Deployment completado en Vercel
- [ ] Aplicación accesible en navegador
- [ ] Prueba de auditoría funcionando (crear/editar medicamento)
- [ ] (Opcional) Componente de importación integrado

---

**Fecha de implementación:** 2025-01-07
**Branch:** `claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k`
**Commit:** `ad93bb8`
