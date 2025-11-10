# ✅ CÓMO VERIFICAR QUE TODO FUNCIONA

Dijiste que ya ejecutaste el script SQL. Perfecto! Ahora sigue estos pasos para **verificar que todo está operativo**.

---

## 🔍 PASO 1: VERIFICAR EN SUPABASE SQL EDITOR

### 1.1 Abrir SQL Editor
1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto: **SIGIMED**
3. Click en **SQL Editor** en el menú lateral
4. Click en **New Query**

### 1.2 Ejecutar Script de Verificación
1. Abre el archivo `VERIFICATION_TESTS.sql` (está en tu repositorio)
2. **COPIA TODO** el contenido
3. **PÉGALO** en Supabase SQL Editor
4. Click en **Run** (Ctrl+Enter)

### 1.3 Revisar Resultados

El script te mostrará:

✅ **TEST 1: Tablas principales**
- Debe mostrar "✅ Tabla batch_movements existe"
- Debe mostrar "✅ Tabla audit_log existe"

✅ **TEST 2: Índices**
- Deberías ver 6+ índices para batch_movements
- Deberías ver índices para audit_log

✅ **TEST 3: Funciones SQL**
- ✅ registrar_movimiento_lote
- ✅ generate_traceability_report
- ✅ search_inventory_with_batches
- ✅ audit_trigger_func

✅ **TEST 4: Triggers**
- Debe mostrar 5 triggers (audit_medications, audit_users_profiles, etc.)

✅ **TEST 5-10: Datos y pruebas**
- Estadísticas del sistema
- Estructura de tablas
- Políticas RLS
- Pruebas funcionales

### 1.4 ¿Qué esperar?

Al final del script verás un **RESUMEN** como este:

```
✅ Tabla batch_movements
✅ Tabla audit_log
✅ Función registrar_movimiento_lote
✅ Función generate_traceability_report
✅ Función search_inventory_with_batches
✅ Triggers de auditoría (5)

🎯 Total de componentes verificados: 10 / 10
📊 Estado general: 🟢 TODAS LAS FUNCIONALIDADES OPERATIVAS
```

---

## 🧪 PASO 2: PROBAR FUNCIONALIDADES MANUALMENTE

### 2.1 Probar Función de Movimientos de Lotes

En Supabase SQL Editor, ejecuta:

```sql
-- IMPORTANTE: Primero obtener IDs reales
SELECT id, nombre, cantidad FROM medications LIMIT 5;
SELECT id, email FROM users_profiles LIMIT 5;

-- Luego ejecutar (reemplaza los IDs)
SELECT registrar_movimiento_lote(
  'AQUI_VA_EL_ID_DEL_MEDICAMENTO'::uuid,  -- Copia un ID de arriba
  'entrada',                                -- Tipo de movimiento
  10,                                       -- Cantidad a agregar
  'Prueba manual de verificación',         -- Motivo
  'AQUI_VA_EL_ID_DEL_USUARIO'::uuid,      -- Copia un ID de usuario
  NULL,                                     -- centro_origen_id
  NULL,                                     -- centro_destino_id
  NULL,                                     -- transfer_id
  NULL,                                     -- requisition_id
  NULL,                                     -- adjustment_id
  NULL,                                     -- numero_documento
  'Verificando que la función funciona'    -- observaciones
);
```

**Resultado esperado:**
```json
{
  "success": true,
  "movement_id": "uuid-del-movimiento",
  "cantidad_anterior": 50,
  "cantidad_posterior": 60,
  "message": "Movimiento registrado exitosamente: entrada"
}
```

### 2.2 Verificar que se creó el movimiento

```sql
-- Ver el último movimiento creado
SELECT * FROM batch_movements
ORDER BY created_at DESC
LIMIT 1;
```

**Deberías ver:**
- tipo_movimiento: 'entrada'
- cantidad: 10
- cantidad_anterior: (la que tenía antes)
- cantidad_posterior: (cantidad_anterior + 10)
- motivo: 'Prueba manual de verificación'

### 2.3 Verificar auditoría automática

```sql
-- Ver últimos registros de auditoría
SELECT
  action_type,
  entity_type,
  entity_name,
  user_email,
  created_at
FROM audit_log
ORDER BY created_at DESC
LIMIT 5;
```

**Deberías ver:**
- Un registro con action_type = 'CREATE' o 'ADJUST'
- entity_type = 'batch'
- Con el movimiento que acabas de crear

### 2.4 Probar búsqueda avanzada

```sql
-- Buscar medicamentos próximos a vencer
SELECT
  nombre,
  lote,
  cantidad,
  fecha_caducidad,
  dias_para_vencer,
  CASE
    WHEN expired_alert THEN '🔴 VENCIDO'
    WHEN expiring_soon_alert THEN '🟡 PRÓXIMO A VENCER'
    ELSE '🟢 OK'
  END as estado_alerta,
  total_movements
FROM search_inventory_with_batches(
  p_proximos_vencer_dias := 90
)
LIMIT 10;
```

### 2.5 Probar reporte de trazabilidad

```sql
-- Obtener reporte con historial
SELECT
  medication_nombre,
  medication_lote,
  medication_cantidad,
  center_name,
  ultimo_movimiento_tipo,
  total_movimientos,
  historial_movimientos
FROM generate_traceability_report(
  p_include_history := true
)
LIMIT 5;
```

---

## 🌐 PASO 3: VERIFICAR EN LA APLICACIÓN WEB

### 3.1 Verificar Vercel

1. Ve a tu dashboard de Vercel: https://vercel.com/dashboard
2. Busca tu proyecto SIGIMED
3. Ve a **Deployments**
4. El último deployment debe estar en estado "Ready" ✅

### 3.2 Configurar branch correcto (si no lo hiciste)

1. **Settings** → **Git**
2. En **Production Branch** cambia a:
   ```
   claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k
   ```
3. Guarda y haz **Redeploy**

### 3.3 Abrir la aplicación

1. Abre tu URL de Vercel (ej: `https://tu-proyecto.vercel.app`)
2. Inicia sesión
3. Selecciona un centro de salud

### 3.4 Probar auditoría automática

1. Ve a la página de **Inventario**
2. Edita cualquier medicamento (cambia la cantidad)
3. Guarda los cambios
4. Ve a Supabase SQL Editor y ejecuta:

```sql
SELECT * FROM audit_log
WHERE action_type = 'UPDATE'
AND entity_type = 'medications'
ORDER BY created_at DESC
LIMIT 1;
```

✅ **Debe aparecer el registro de tu edición**

---

## 📊 PASO 4: VERIFICAR ESTADÍSTICAS

Ejecuta en Supabase:

```sql
-- Estadísticas completas
SELECT
  (SELECT COUNT(*) FROM medications) as total_medicamentos,
  (SELECT COUNT(*) FROM health_centers) as total_centros,
  (SELECT COUNT(*) FROM batch_movements) as total_movimientos,
  (SELECT COUNT(*) FROM audit_log) as total_auditorias,
  (SELECT COUNT(*) FROM users_profiles) as total_usuarios;
```

---

## ✅ CHECKLIST DE VERIFICACIÓN

Marca cada item cuando esté verificado:

### Base de Datos (Supabase)
- [ ] Script `MIGRATION_SQL.sql` ejecutado sin errores
- [ ] Script `VERIFICATION_TESTS.sql` muestra "🟢 TODAS LAS FUNCIONALIDADES OPERATIVAS"
- [ ] Tabla `batch_movements` existe y tiene datos
- [ ] Tabla `audit_log` existe y tiene registros
- [ ] Función `registrar_movimiento_lote` ejecuta correctamente
- [ ] Función `search_inventory_with_batches` retorna resultados
- [ ] 5 triggers de auditoría están activos

### Aplicación Web
- [ ] Vercel está desplegando el branch correcto
- [ ] La aplicación carga sin errores
- [ ] Puedo iniciar sesión
- [ ] Puedo ver inventario
- [ ] Al editar medicamentos se registra en audit_log

### Nuevas Funcionalidades
- [ ] Movimientos de lotes funcionan (probado manualmente en SQL)
- [ ] Auditoría automática funciona (verificado después de editar)
- [ ] Búsqueda avanzada retorna datos con alertas
- [ ] Reporte de trazabilidad incluye historial

---

## 🆘 SI ALGO NO FUNCIONA

### Problema: "Tabla batch_movements no existe"
**Solución:** Ejecuta nuevamente el archivo `MIGRATION_SQL.sql` completo

### Problema: "Función no encontrada"
**Solución:**
1. Verifica que ejecutaste TODO el script de migración
2. Ve a Supabase Dashboard → Database → Functions
3. Deberías ver las 4 funciones listadas

### Problema: "No veo registros en audit_log"
**Solución:**
1. Los triggers solo se activan con operaciones DESPUÉS de su creación
2. Crea/edita/elimina algo nuevo (medicamento, centro, etc.)
3. Consulta nuevamente audit_log

### Problema: "Permission denied"
**Solución:**
Las políticas RLS están activas. Necesitas estar autenticado:
1. Usa la aplicación web para operaciones
2. O ejecuta consultas SQL como admin desde Supabase Dashboard

---

## 📸 CAPTURAS ESPERADAS

### En Supabase Table Editor

Deberías ver estas tablas:
- ✅ medications
- ✅ health_centers
- ✅ users_profiles
- ✅ batch_movements ← **NUEVA**
- ✅ audit_log
- ✅ alertas_medicamentos
- ✅ medication_catalog
- ✅ transfers
- ✅ requisitions
- ✅ inventory_adjustments

### En Supabase Database → Functions

Deberías ver:
- ✅ registrar_movimiento_lote
- ✅ generate_traceability_report
- ✅ search_inventory_with_batches
- ✅ generar_alertas_caducidad
- ✅ audit_trigger_func

---

## 🎯 PRÓXIMOS PASOS OPCIONALES

Una vez verificado que todo funciona:

### 1. Integrar componente de importación

```typescript
// En src/pages/InventoryPage.tsx
import { ImportMedications } from '../components/inventory/ImportMedications';

// Agregar un botón o sección:
<ImportMedications />
```

### 2. Crear página de reportes

Crear `src/pages/ReportsPage.tsx` usando las funciones SQL de reportes

### 3. Crear dashboard de auditoría

Para super_admin, mostrar logs de `audit_log` con filtros

---

## 📞 AYUDA

**Archivos importantes:**
- `MIGRATION_SQL.sql` - Script de migración principal
- `VERIFICATION_TESTS.sql` - Script de pruebas (ejecuta este)
- `DEPLOYMENT_INSTRUCTIONS.md` - Instrucciones completas de deployment
- `COMO_VERIFICAR.md` - Este archivo

**Branch con los cambios:**
```
claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k
```

**Commits:**
- `ad93bb8` - Funcionalidades principales
- `9657ffa` - Scripts de deployment
- `861a80e` - Scripts de verificación

---

¡Si todos los tests pasan, el sistema está 100% funcional! 🎉
