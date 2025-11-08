# 🚀 INSTALACIÓN COMPLETA DEL SISTEMA SIGIMED

## ⚠️ IMPORTANTE

Los errores anteriores ocurrieron porque **el schema base no estaba instalado** en tu base de datos Supabase.

Yo creé el schema completo en `database-schema.sql`, pero tú necesitas ejecutarlo primero en Supabase.

---

## 📋 ORDEN DE EJECUCIÓN (3 PASOS - 5 MINUTOS)

### 🔍 PASO 0: Verificar Estado Actual (OPCIONAL)

**Archivo**: `TEST_VERIFICAR_SCHEMA.sql`

```
1. Abre: https://supabase.com/dashboard
2. SQL Editor → New query
3. Copia TODO el contenido de: TEST_VERIFICAR_SCHEMA.sql
4. Pega y ejecuta
```

**Este script te dirá**:
- ✅ Qué tablas ya existen
- ❌ Qué tablas faltan
- ✅ Qué funciones ya existen
- ❌ Qué funciones faltan
- 📋 Qué scripts ejecutar

---

### 1️⃣ PASO 1: Instalar Schema Base (OBLIGATORIO)

**Archivo**: `database-schema.sql` (archivo completo con TODAS las tablas)

```
1. Abre: https://supabase.com/dashboard
2. SQL Editor → New query
3. Copia TODO el contenido de: database-schema.sql
4. Pega y ejecuta
5. Espera ~30 segundos
```

**Esto crea**:
- ✅ Tabla `health_centers` (con columna `code`)
- ✅ Tabla `users_profiles`
- ✅ Tabla `suppliers`
- ✅ Tabla `medication_catalog`
- ✅ Tabla `medications`
- ✅ Tabla `alertas_medicamentos`
- ✅ Tabla `batch_movements` (básica)
- ✅ Tabla `transfers`
- ✅ Tabla `requisitions`
- ✅ Tabla `inventory_adjustments`
- ✅ Tabla `audit_log`
- ✅ Políticas RLS (seguridad)
- ✅ Índices para performance

**⏱️ Tiempo**: 30 segundos

---

### 2️⃣ PASO 2: Instalar Funciones Avanzadas (OBLIGATORIO)

**Archivo**: `MIGRATION_SQL_FINAL.sql`

```
1. Nueva query en SQL Editor
2. Copia TODO el contenido de: MIGRATION_SQL_FINAL.sql
3. Pega y ejecuta
4. Espera ~20 segundos
```

**Esto crea**:
- ✅ Función `registrar_movimiento_lote()`
- ✅ Función `search_inventory_with_batches()`
- ✅ Función `generate_traceability_report()`
- ✅ Función `audit_trigger_func()`
- ✅ Triggers de auditoría automática
- ✅ Políticas RLS adicionales

**Verificación automática al final**:
```
============================================
VERIFICACIÓN DE INSTALACIÓN
============================================
Tabla batch_movements: ✅ OK
Tabla audit_log: ✅ OK
Funciones SQL: 4 de 4
Triggers: 5 de 5
============================================
🎉 INSTALACIÓN EXITOSA - TODO FUNCIONANDO
============================================
```

**⏱️ Tiempo**: 20 segundos

---

### 3️⃣ PASO 3: Ejecutar Tests (VERIFICACIÓN)

**Archivo**: `TEST_COMPLETO.sql` (nuevo, usa el schema correcto)

```
1. Nueva query en SQL Editor
2. Copia TODO el contenido de: TEST_COMPLETO.sql
3. Pega y ejecuta
4. Espera ~30 segundos
```

**Esto prueba**:
- ✅ Inserción de centros de salud (con columna `code`)
- ✅ Inserción de proveedores
- ✅ Inserción de catálogo de medicamentos
- ✅ Inserción de medicamentos en inventario
- ✅ Función `registrar_movimiento_lote()`
- ✅ Función `search_inventory_with_batches()`
- ✅ Función `generate_traceability_report()`
- ✅ Búsquedas avanzadas
- ✅ Filtros por stock bajo
- ✅ Filtros por próximos a vencer
- ✅ Sistema de alertas

**Resultado esperado**: 16/16 tests ✅

**⏱️ Tiempo**: 30 segundos

---

## 🎯 RESUMEN RÁPIDO

```bash
PASO 0 (OPCIONAL):  TEST_VERIFICAR_SCHEMA.sql   → Ve qué falta
PASO 1 (REQUERIDO): database-schema.sql         → Crea tablas base
PASO 2 (REQUERIDO): MIGRATION_SQL_FINAL.sql     → Instala funciones
PASO 3 (VERIFICAR): TEST_COMPLETO.sql           → Prueba todo (16 tests)
```

**Tiempo total**: ~5 minutos

---

## ❓ POR QUÉ FALLABAN LOS TESTS ANTERIORES

**Errores que reportaste**:

1. ❌ `relation "alertas_medicamentos" does not exist`
   - **Causa**: No ejecutaste `database-schema.sql` primero
   - **Solución**: Ejecutar PASO 1

2. ❌ `column "code" does not exist`
   - **Causa**: No ejecutaste `database-schema.sql` primero
   - **Solución**: Ejecutar PASO 1

3. ❌ `relation "suppliers" does not exist`
   - **Causa**: No ejecutaste `database-schema.sql` primero
   - **Solución**: Ejecutar PASO 1

**El schema completo YA está definido en `database-schema.sql`**. Solo necesitas ejecutarlo.

---

## ✅ DESPUÉS DE LOS 3 PASOS

Tu base de datos tendrá:

### Tablas (9):
- health_centers
- users_profiles
- user_centers
- suppliers
- medication_catalog
- medications
- alertas_medicamentos
- batch_movements
- transfers
- requisitions
- inventory_adjustments
- audit_log

### Funciones SQL (4):
- registrar_movimiento_lote()
- search_inventory_with_batches()
- generate_traceability_report()
- audit_trigger_func()

### Triggers (5):
- audit_medications
- audit_users_profiles
- audit_health_centers
- audit_medication_catalog
- audit_transfers

### Seguridad:
- ✅ RLS habilitado en todas las tablas
- ✅ Políticas de acceso por usuario y centro
- ✅ Auditoría automática de cambios

---

## 🧪 VERIFICAR EN VERCEL

Una vez que los 3 pasos estén completos:

1. **Login** en tu app Vercel
2. **Seleccionar** "Hospital Central de Prueba"
3. **Ver inventario** → Debería mostrar 6 medicamentos de prueba
4. **Buscar** "PARACETAMOL" → Stock actualizado con movimientos
5. **Reportes** → Búsqueda avanzada y trazabilidad disponibles
6. **Filtros**:
   - Stock bajo → Muestra medicamentos <50 unidades
   - Próximos a vencer → Muestra medicamentos a <30 días

---

## 🗑️ LIMPIAR DATOS DE PRUEBA

Después de verificar:

```sql
DELETE FROM batch_movements WHERE numero_documento LIKE 'TEST-%';
DELETE FROM medications WHERE lote LIKE 'TEST-%';
DELETE FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%';
DELETE FROM suppliers WHERE ruc LIKE 'TEST%';
DELETE FROM health_centers WHERE code LIKE 'TEST-%';

SELECT '✅ Datos de prueba eliminados' as status;
```

---

## 📞 ARCHIVOS IMPORTANTES

### Instalación:
- **database-schema.sql** ⭐⭐⭐ **EJECUTAR PRIMERO**
- **MIGRATION_SQL_FINAL.sql** ⭐⭐⭐ **EJECUTAR SEGUNDO**

### Testing:
- **TEST_VERIFICAR_SCHEMA.sql** ⭐ (opcional - ver estado)
- **TEST_COMPLETO.sql** ⭐⭐⭐ **EJECUTAR TERCERO**

### Antiguos (no usar):
- ~~TEST_MINIMO.sql~~ (versión anterior adaptativa - no necesaria)
- ~~DESCUBRIR_SCHEMA.sql~~ (versión anterior - no necesaria)
- ~~TEST_COMPLETO_AUTOMATIZADO.sql~~ (versión antigua)
- ~~TEST_COMPLETO_AUTOMATIZADO_FIXED.sql~~ (versión antigua)
- ~~TEST_FINAL_ROBUSTO.sql~~ (versión antigua)

---

## 🚨 SI ALGO FALLA

### Error: "relation already exists"
**Causa**: Ya ejecutaste parte del schema antes
**Solución**: Está bien, continúa con el siguiente paso

### Error: "function already exists"
**Causa**: Ya ejecutaste MIGRATION_SQL_FINAL.sql antes
**Solución**: Está bien, continúa con los tests

### Error: "permission denied"
**Causa**: Usuario sin permisos suficientes
**Solución**: Asegúrate de estar usando el usuario admin de Supabase

### Tests fallan después de ejecutar PASOS 1 y 2
**Causa**: Poco probable si ejecutaste todo en orden
**Solución**:
1. Ejecuta TEST_VERIFICAR_SCHEMA.sql para ver qué falta
2. Reporta el error específico

---

## 🎯 ACCIÓN INMEDIATA

**AHORA MISMO:**

1. Abre: https://supabase.com/dashboard
2. SQL Editor → New query
3. Ejecuta en este orden:
   - `database-schema.sql` (30 seg)
   - `MIGRATION_SQL_FINAL.sql` (20 seg)
   - `TEST_COMPLETO.sql` (30 seg)

**Resultado esperado**: 16/16 tests ✅

**Tiempo total**: ~2 minutos de ejecución + 3 minutos de verificación = **5 minutos**

---

**🚀 ¡Todo está listo! Solo necesitas ejecutar los 3 scripts en orden.**
