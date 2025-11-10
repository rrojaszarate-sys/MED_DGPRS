# 🚨 INSTRUCCIONES URGENTES - SOLUCIONAR PERSISTENCIA

## PROBLEMA REPORTADO
- ❌ Medicamentos se crean en frontend pero NO persisten en Supabase
- ❌ Al recargar (F5) los datos DESAPARECEN
- ❌ Medicamento de prueba: MED-TEST-001 no se guardó

## CAUSA PROBABLE
Las políticas RLS (Row Level Security) no se aplicaron correctamente en la tabla `medication_catalog`, bloqueando las operaciones INSERT desde el frontend.

---

## 📋 PROCESO DE DIAGNÓSTICO Y CORRECCIÓN

### PASO 1: DIAGNOSTICAR EL PROBLEMA

1. **Ir a Supabase Dashboard**
   - URL: https://supabase.com/dashboard
   - Selecciona tu proyecto SIGIMED

2. **Abrir SQL Editor**
   - Panel izquierdo → "SQL Editor"
   - Click en "+ New query"

3. **Ejecutar script de diagnóstico**
   - Abrir archivo: `DIAGNOSTICO_VERCEL_PERSISTENCIA.sql`
   - Copiar TODO el contenido
   - Pegarlo en el SQL Editor
   - Click en "Run" (botón verde)

4. **Interpretar resultados**

   **Si ves esto → PROBLEMA CONFIRMADO:**
   ```
   ❌ CRÍTICO: RLS habilitado pero SIN política INSERT
   ```

   **Continúa al PASO 2**

   **Si ves esto → Otro problema:**
   ```
   ⚠️ NO HAY DATOS - Tabla vacía
   ```

   Primero ejecuta: `CARGA_MEDICAMENTOS_CSV.sql` (ver PASO 3)

---

### PASO 2: APLICAR POLÍTICAS RLS (SOLUCIÓN)

1. **En el mismo SQL Editor de Supabase**
   - Click en "+ New query" (nueva pestaña)

2. **Ejecutar script de solución**
   - Abrir archivo: `APLICAR_POLITICAS_RLS_GARANTIZADO.sql`
   - Copiar TODO el contenido
   - Pegarlo en el SQL Editor
   - Click en "Run"

3. **Verificar mensajes de éxito**

   Debes ver estos mensajes en los resultados:
   ```
   ✅ ÉXITO: Política INSERT creada correctamente
   ✅ ÉXITO: Política SELECT creada correctamente
   ✅ PRUEBA INSERT EXITOSA
   ✅ PRUEBA SELECT EXITOSA
   🎉 TODAS LAS PRUEBAS PASARON
   ```

4. **Si ves errores**
   - Copia el mensaje de error completo
   - Envíamelo para analizar

---

### PASO 3: CARGAR MEDICAMENTOS (Si tabla está vacía)

1. **En el SQL Editor**
   - Click en "+ New query"

2. **Ejecutar script de carga**
   - Abrir archivo: `CARGA_MEDICAMENTOS_CSV.sql`
   - Copiar TODO el contenido
   - Pegarlo en el SQL Editor
   - Click en "Run"

3. **Verificar carga**
   ```sql
   SELECT count(*) FROM medication_catalog;
   ```

   Debe retornar: **101 medicamentos**

---

### PASO 4: VERIFICAR EN FRONTEND

1. **Ir a la aplicación Vercel**
   ```
   https://med-dgprs-54g9-5gdjo38oe-rodrigo-rojas-projects-190f877f.vercel.app/
   ```

2. **Hacer login** (si es necesario)

3. **Ir a /admin**

4. **Crear medicamento de prueba**
   - Click "Agregar Medicamento al Catálogo"
   - Llenar datos:
     ```
     Código: MED-PERSIST-TEST-001
     Nombre Genérico: Prueba Persistencia Final
     Forma: Tableta
     Vía: Oral
     Unidad: Caja
     ```
   - Click "Agregar Medicamento"

5. **ABRIR CONSOLA DEL NAVEGADOR (F12)**
   - Pestaña "Console"
   - Buscar estos mensajes:
     ```
     📤 Intentando crear medicamento en catálogo: {...}
     ✅ Medicamento creado exitosamente: {...}
     ```

6. **RECARGAR PÁGINA (F5 o Ctrl+R)**

7. **VERIFICAR QUE EL MEDICAMENTO SIGUE APARECIENDO**
   - Si aparece → ✅ **PROBLEMA SOLUCIONADO**
   - Si desaparece → ❌ **Hay otro problema (ver PASO 5)**

---

### PASO 5: SI SIGUE SIN FUNCIONAR

Si después de ejecutar los scripts el problema persiste:

#### A. Verificar autenticación en consola

En la consola del navegador (F12), ejecuta:
```javascript
const { data: { session } } = await supabase.auth.getSession()
console.log('Usuario autenticado:', session?.user)
console.log('Rol:', session?.user?.role)
```

**Resultado esperado:**
```javascript
Usuario autenticado: { id: "...", email: "...", ... }
Rol: "authenticated"
```

**Si es null o undefined:**
- ❌ No estás autenticado
- Solución: Hacer login en la aplicación

#### B. Verificar URL de Supabase

En la consola del navegador:
```javascript
console.log('SUPABASE_URL:', import.meta.env.VITE_SUPABASE_URL)
```

**Copiar el URL que aparece** y enviármelo para verificar que coincide con tu proyecto.

#### C. Probar INSERT directo desde Supabase

En SQL Editor de Supabase:
```sql
INSERT INTO medication_catalog (
  codigo_medicamento,
  nombre_generico,
  forma_farmaceutica,
  via_administracion,
  unidad_medida,
  is_active
) VALUES (
  'MANUAL-TEST-001',
  'Prueba Manual Directa',
  'Tableta',
  'Oral',
  'Caja',
  true
);

SELECT * FROM medication_catalog WHERE codigo_medicamento = 'MANUAL-TEST-001';
```

**Si esto funciona** → El problema está en el frontend/autenticación
**Si esto falla** → El problema está en las políticas RLS

---

## 🔍 CHECKLIST DE VERIFICACIÓN

Marca cada paso conforme lo completes:

- [ ] **PASO 1:** Ejecuté `DIAGNOSTICO_VERCEL_PERSISTENCIA.sql`
- [ ] **PASO 1:** Vi el resultado del diagnóstico
- [ ] **PASO 2:** Ejecuté `APLICAR_POLITICAS_RLS_GARANTIZADO.sql`
- [ ] **PASO 2:** Vi mensaje "🎉 TODAS LAS PRUEBAS PASARON"
- [ ] **PASO 3:** Ejecuté `CARGA_MEDICAMENTOS_CSV.sql` (si era necesario)
- [ ] **PASO 4:** Abrí la aplicación en Vercel
- [ ] **PASO 4:** Creé medicamento de prueba
- [ ] **PASO 4:** Abrí consola (F12) y vi logs
- [ ] **PASO 4:** Vi mensaje "✅ Medicamento creado exitosamente"
- [ ] **PASO 4:** Recargué página (F5)
- [ ] **PASO 4:** El medicamento SIGUE APARECIENDO ← **ÉXITO!**

---

## 📞 REPORTAR RESULTADOS

Después de ejecutar los pasos, envíame:

1. ✅ Screenshot del resultado de `DIAGNOSTICO_VERCEL_PERSISTENCIA.sql`
2. ✅ Screenshot del resultado de `APLICAR_POLITICAS_RLS_GARANTIZADO.sql`
3. ✅ Screenshot de la consola del navegador (F12) al crear medicamento
4. ✅ Confirmar si el medicamento persiste después de F5

---

## 🎯 RESULTADO ESPERADO

Después de estos pasos:

✅ Políticas RLS correctamente aplicadas
✅ Medicamentos se guardan en Supabase
✅ Datos persisten después de recargar
✅ 101+ medicamentos disponibles en el catálogo
✅ Sistema 100% funcional

---

## ⚡ SCRIPTS DISPONIBLES

1. **DIAGNOSTICO_VERCEL_PERSISTENCIA.sql**
   - Diagnóstica el problema
   - No modifica nada

2. **APLICAR_POLITICAS_RLS_GARANTIZADO.sql**
   - Aplica políticas RLS correctas
   - Incluye pruebas automáticas

3. **CARGA_MEDICAMENTOS_CSV.sql**
   - Carga 101 medicamentos reales
   - Solo si tabla está vacía

---

## 🚀 PRÓXIMOS PASOS

Una vez que confirmes que la persistencia funciona:

1. Cargar medicamentos faltantes (si aplica)
2. Crear lotes de inventario
3. Probar módulo completo de inventario
4. Verificar reportes y estadísticas

---

**¡Ejecuta los pasos en orden y repórtame los resultados!** 🎯
