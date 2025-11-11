# 🔍 PROBLEMA: Dashboard muestra 0 medicamentos

## 📊 SITUACIÓN REPORTADA

```
✅ Supabase: 4 medicamentos existen en tabla 'medications'
❌ Dashboard Vercel: Muestra 0 medicamentos
❌ Problema: Datos no llegan al frontend
```

---

## 🎯 CAUSA RAÍZ IDENTIFICADA

El Dashboard usa el hook `useMedicamentos(centroId)` que:

1. **REQUIERE** un `center_id` específico
2. Filtra medicamentos por centro de salud
3. **NO funciona** sin un centro seleccionado

### Código del Dashboard (DashboardPage.tsx:33)

```typescript
const { centroSeleccionado } = useCentro()
const { medicamentos, loading: loadingMeds } = useMedicamentos(centroSeleccionado?.id)
                                                                 ^^^^^^^^^^^^^^^^^^^^
                                                                 Requiere centro!
```

### Código del Hook (useMedicamentos.ts:12-14)

```typescript
useEffect(() => {
  if (centroId) {        // ← Solo ejecuta si hay centroId
    fetchMedicamentos()
  }
}, [centroId])
```

### Query SQL ejecutado (useMedicamentos.ts:43-50)

```typescript
let query = supabase
  .from('medications')
  .select('*')
  .order('created_at', { ascending: false })

if (centroId) {
  query = query.eq('center_id', centroId)  // ← Filtra por centro!
}
```

---

## 🚨 PROBLEMAS POSIBLES

### 1️⃣ **NO hay políticas RLS en tabla `medications`**
- RLS está habilitado pero SIN política SELECT
- Frontend no puede leer datos
- **Solución:** Ejecutar `SOLUCION_DASHBOARD_CERO_MEDICAMENTOS.sql`

### 2️⃣ **NO hay centros de salud registrados**
- Tabla `health_centers` está vacía
- Usuario no puede seleccionar centro
- **Solución:** Script crea centro automáticamente

### 3️⃣ **Medicamentos NO tienen `center_id`**
- Los 4 medicamentos existen pero `center_id` es NULL
- Query del Dashboard los filtra y no aparecen
- **Solución:** Script asigna center_id automáticamente

### 4️⃣ **Usuario NO seleccionó centro en frontend**
- Todo está correcto en BD
- Pero usuario no seleccionó centro en dropdown
- **Solución:** Seleccionar centro en UI

---

## ✅ SOLUCIÓN PASO A PASO

### **PASO 1: EJECUTAR DIAGNÓSTICO**

En Supabase SQL Editor:

```sql
-- Archivo: DIAGNOSTICO_DASHBOARD_CERO_MEDICAMENTOS.sql
-- Ejecutar para identificar problema específico
```

**Buscar en resultados:**

```
❌ PROBLEMA: NO hay política SELECT en medications
→ Ejecutar PASO 2

❌ PROBLEMA: NO hay centros de salud registrados
→ Ejecutar PASO 2

⚠️ PROBLEMA: X medicamentos SIN center_id
→ Ejecutar PASO 2

✅ Configuración correcta
→ Ir a PASO 3 (problema en frontend)
```

---

### **PASO 2: EJECUTAR SOLUCIÓN**

En Supabase SQL Editor:

```sql
-- Archivo: SOLUCION_DASHBOARD_CERO_MEDICAMENTOS.sql
-- Este script:
-- 1. Crea políticas RLS en 'medications'
-- 2. Crea centro de salud (si no existe)
-- 3. Asigna center_id a medicamentos huérfanos
-- 4. Verifica que todo está OK
```

**Resultado esperado:**

```
✅ Política SELECT creada
✅ Centro de salud creado/verificado
✅ Medicamentos asignados a centro
✅ TODAS LAS CORRECCIONES APLICADAS EXITOSAMENTE
```

---

### **PASO 3: VERIFICAR EN FRONTEND**

1. **Ir a Dashboard en Vercel:**
   ```
   https://med-dgprs-54g9-5gdjo38oe-rodrigo-rojas-projects-190f877f.vercel.app/
   ```

2. **Hacer login** (si es necesario)

3. **BUSCAR DROPDOWN DE CENTROS**
   - Debe aparecer en el header/navbar
   - Seleccionar "Centro de Salud Principal" (o el que creaste)

4. **VERIFICAR QUE APARECEN MEDICAMENTOS**
   - Dashboard debe mostrar: "Total Medicamentos: 4"
   - Si sigue mostrando 0 → Ir a PASO 4

---

### **PASO 4: DEBUGGEAR FRONTEND (Si sigue fallando)**

1. **Abrir Consola del Navegador (F12)**
   - Pestaña "Console"

2. **Buscar errores de Supabase:**
   ```javascript
   // Error típico si falta política SELECT:
   "Failed to fetch medications: permission denied for table medications"

   // Error si no hay centro seleccionado:
   "useMedicamentos: centroId is undefined"
   ```

3. **Verificar centro seleccionado:**
   ```javascript
   // En consola, ejecutar:
   localStorage.getItem('selected_center')
   // Debe retornar un ID, no null
   ```

4. **Verificar autenticación:**
   ```javascript
   // En consola, ejecutar:
   const { data } = await supabase.auth.getSession()
   console.log('Usuario:', data.session?.user)
   // Debe mostrar usuario, no null
   ```

---

## 📋 CHECKLIST DE VERIFICACIÓN

Marca cada item conforme lo verifiques:

**En Supabase:**
- [ ] Ejecuté `DIAGNOSTICO_DASHBOARD_CERO_MEDICAMENTOS.sql`
- [ ] Vi el mensaje de diagnóstico
- [ ] Ejecuté `SOLUCION_DASHBOARD_CERO_MEDICAMENTOS.sql`
- [ ] Vi "✅ TODAS LAS CORRECCIONES APLICADAS EXITOSAMENTE"
- [ ] Query de prueba retorna los 4 medicamentos

**En Frontend:**
- [ ] Abrí Dashboard en Vercel
- [ ] Hice login correctamente
- [ ] Veo dropdown de centros de salud
- [ ] Seleccioné un centro
- [ ] Dashboard muestra "Total Medicamentos: 4" ← **ÉXITO**

---

## 🎯 RESULTADO ESPERADO

Después de seguir todos los pasos:

```
Dashboard muestra:
┌─────────────────────────────┐
│ Total Medicamentos          │
│        4                    │
└─────────────────────────────┘

Stock Total: XXX unidades
Lotes activos: X
Alertas: X
```

---

## 🚨 SI SIGUE FALLANDO

Reporta estos datos:

1. **Output de** `DIAGNOSTICO_DASHBOARD_CERO_MEDICAMENTOS.sql`
2. **Output de** `SOLUCION_DASHBOARD_CERO_MEDICAMENTOS.sql`
3. **Screenshot** de Dashboard mostrando 0 medicamentos
4. **Screenshot** de consola del navegador (F12) con errores
5. **¿Hay dropdown de centros visible?** (Sí/No)
6. **¿Está seleccionado algún centro?** (Sí/No)

---

## 💡 EXPLICACIÓN TÉCNICA

### Arquitectura del Sistema

```
┌─────────────────────────────────────────────────┐
│                  DASHBOARD                      │
│  useMedicamentos(centroSeleccionado?.id)       │
│         │                                        │
│         ▼                                        │
│  if (centroId) {                               │
│    supabase                                     │
│      .from('medications')                       │
│      .select('*')                               │
│      .eq('center_id', centroId)  ← FILTRO      │
│  }                                              │
└─────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│            SUPABASE (medications)               │
│                                                  │
│  ┌────────────────────────────────┐            │
│  │ id │ center_id │ nombre        │            │
│  ├────┼───────────┼──────────────┤            │
│  │ 1  │ abc-123   │ Paracetamol  │ ← Filtrado │
│  │ 2  │ abc-123   │ Ibuprofeno   │ ← Filtrado │
│  │ 3  │ abc-123   │ Aspirina     │ ← Filtrado │
│  │ 4  │ abc-123   │ Amoxicilina  │ ← Filtrado │
│  └────────────────────────────────┘            │
│                                                  │
│  RLS Policies:                                   │
│  ✅ SELECT: authenticated OR anon               │
│  ✅ INSERT: authenticated                        │
│  ✅ UPDATE: authenticated                        │
│  ✅ DELETE: authenticated                        │
└─────────────────────────────────────────────────┘
```

### ¿Por qué se filtra por centro?

El sistema está diseñado para **multi-centro:**

- Hospital A tiene sus medicamentos
- Hospital B tiene sus medicamentos
- Usuario del Hospital A NO ve medicamentos del Hospital B

Por eso el Dashboard **REQUIERE** que selecciones un centro.

---

## 📞 SOPORTE

Si después de seguir todos los pasos el problema persiste, proporciona:

1. Screenshot del resultado de ambos scripts SQL
2. Screenshot del Dashboard mostrando 0
3. Screenshot de la consola (F12) con errores
4. ¿Aparece dropdown de centros? (Sí/No)
5. ¿Cuántos centros aparecen en el dropdown?

---

**¡A solucionarlo!** 🚀
