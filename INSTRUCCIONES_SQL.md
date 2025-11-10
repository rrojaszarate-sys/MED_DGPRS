# 📋 INSTRUCCIONES - SCRIPTS SQL

He creado **3 scripts SQL** revisados y sin errores. Aquí te explico cuál usar y cuándo.

---

## 🎯 OPCIÓN 1: INSTALACIÓN LIMPIA (Recomendado)

Si es la **primera vez** o quieres asegurarte de que todo esté bien:

### Paso 1: Ejecutar MIGRATION_SQL_FINAL.sql

```
1. Abre Supabase Dashboard → SQL Editor
2. New Query
3. Copia TODO el contenido de: MIGRATION_SQL_FINAL.sql
4. Pega y ejecuta (Run)
5. Espera el mensaje de verificación al final
```

**Resultado esperado:**
```
✅ INSTALACIÓN EXITOSA - TODO FUNCIONANDO
```

### Paso 2: Verificar con QUICK_TEST.sql

```
1. New Query en Supabase
2. Copia TODO el contenido de: QUICK_TEST.sql
3. Ejecuta
4. Revisa que todo esté ✅
```

**Resultado esperado:**
```
🟢 TODAS LAS FUNCIONALIDADES OPERATIVAS ✅
```

---

## 🔄 OPCIÓN 2: REINSTALACIÓN (Si algo falló)

Si ya ejecutaste el script anterior y algo salió mal:

### Paso 1: Borrar todo (RESET_DATABASE.sql)

```
1. Supabase → SQL Editor → New Query
2. Copia contenido de: RESET_DATABASE.sql
3. ⚠️  LEE LA ADVERTENCIA que aparece
4. Espera 5 segundos
5. Se borrará todo lo relacionado con funcionalidades avanzadas
```

**Esto elimina:**
- ❌ Tabla batch_movements y sus datos
- ❌ Triggers de auditoría
- ❌ Funciones SQL
- ❌ Políticas RLS

### Paso 2: Instalar de nuevo

```
1. Ejecuta MIGRATION_SQL_FINAL.sql (ver Opción 1)
2. Ejecuta QUICK_TEST.sql para verificar
```

---

## 📄 DESCRIPCIÓN DE LOS SCRIPTS

### 1. MIGRATION_SQL_FINAL.sql ⭐ PRINCIPAL
**Tamaño:** ~600 líneas
**Qué hace:**
- ✅ Crea tabla `batch_movements` con índices
- ✅ Crea función `audit_trigger_func()`
- ✅ Aplica 5 triggers de auditoría automática
- ✅ Crea función `registrar_movimiento_lote()`
- ✅ Crea función `generate_traceability_report()`
- ✅ Crea función `search_inventory_with_batches()`
- ✅ Configura políticas RLS
- ✅ Incluye verificación automática al final

**Características:**
- 🔒 Es **idempotente** (se puede ejecutar varias veces)
- 🛡️ Maneja errores sin fallar
- ✅ Verifica automáticamente la instalación

### 2. QUICK_TEST.sql 🧪 PRUEBAS
**Tamaño:** ~250 líneas
**Qué hace:**
- Verifica que todas las tablas existan
- Verifica que todas las funciones existan
- Verifica que todos los triggers estén activos
- Muestra estadísticas del sistema
- Prueba las funciones de búsqueda
- Da un resumen final con ✅ o ❌

**Cuándo usarlo:**
- Después de ejecutar MIGRATION_SQL_FINAL.sql
- Para verificar que todo funciona
- Para diagnosticar problemas

### 3. RESET_DATABASE.sql 🔄 BORRAR TODO
**Tamaño:** ~80 líneas
**Qué hace:**
- ⚠️ BORRA toda la tabla batch_movements
- ⚠️ ELIMINA todos los triggers
- ⚠️ ELIMINA todas las funciones
- ⚠️ ELIMINA políticas RLS

**Cuándo usarlo:**
- Solo si necesitas empezar de cero
- Si la instalación falló y quieres limpiar
- **NO lo uses si ya tienes datos importantes**

---

## ✅ FLUJO RECOMENDADO

### Primera vez:
```
1. MIGRATION_SQL_FINAL.sql  ← Instalar
2. QUICK_TEST.sql          ← Verificar
3. ¡Listo! ✅
```

### Si algo falla:
```
1. RESET_DATABASE.sql      ← Borrar
2. MIGRATION_SQL_FINAL.sql  ← Reinstalar
3. QUICK_TEST.sql          ← Verificar
4. ¡Listo! ✅
```

---

## 🔍 QUÉ VERÁS DESPUÉS DE EJECUTAR

### MIGRATION_SQL_FINAL.sql

Al final verás mensajes NOTICE como:

```
NOTICE:
NOTICE:  ============================================
NOTICE:  VERIFICACIÓN DE INSTALACIÓN
NOTICE:  ============================================
NOTICE:  Tabla batch_movements: ✅ OK
NOTICE:  Tabla audit_log: ✅ OK
NOTICE:  Funciones SQL: 4 de 4
NOTICE:  Triggers: 5 de 5
NOTICE:  ============================================
NOTICE:  🎉 INSTALACIÓN EXITOSA - TODO FUNCIONANDO
NOTICE:  ============================================
```

### QUICK_TEST.sql

Verás tablas con resultados de cada test:

```
TEST 1: VERIFICANDO ESTRUCTURA
✅ batch_movements existe
✅ audit_log existe
Columnas en batch_movements: 16

TEST 2: VERIFICANDO FUNCIONES SQL
✅ audit_trigger_func
✅ generate_traceability_report
✅ registrar_movimiento_lote
✅ search_inventory_with_batches

...

RESUMEN FINAL
✅ Tabla batch_movements
✅ Función registrar_movimiento_lote
✅ Función generate_traceability_report
✅ Función search_inventory_with_batches
✅ Triggers de auditoría (5)

🟢 TODAS LAS FUNCIONALIDADES OPERATIVAS ✅
```

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error: "table batch_movements already exists"
**Solución:** El script es idempotente, esto no debería pasar. Si pasa:
1. Ejecuta RESET_DATABASE.sql
2. Ejecuta MIGRATION_SQL_FINAL.sql de nuevo

### Error: "relation medications does not exist"
**Solución:** Tu base de datos no tiene las tablas base.
1. Primero ejecuta el schema completo base (`database-schema.sql`)
2. Luego ejecuta MIGRATION_SQL_FINAL.sql

### Error: "function auth.uid() does not exist"
**Solución:** Estás usando PostgreSQL normal en vez de Supabase.
- Este script está diseñado para Supabase
- `auth.uid()` es una función de Supabase

### Mensaje: "⚠️ INSTALACIÓN INCOMPLETA"
**Solución:**
1. Revisa los mensajes de error en Supabase
2. Ejecuta RESET_DATABASE.sql
3. Ejecuta MIGRATION_SQL_FINAL.sql de nuevo
4. Si persiste, copia el error y busca ayuda

---

## 📊 VALIDACIÓN MANUAL

Después de ejecutar los scripts, valida manualmente:

```sql
-- 1. Ver tablas
SELECT table_name FROM information_schema.tables
WHERE table_name IN ('batch_movements', 'audit_log');

-- 2. Ver funciones
SELECT routine_name FROM information_schema.routines
WHERE routine_name LIKE '%batch%' OR routine_name LIKE '%audit%';

-- 3. Ver triggers
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_name LIKE 'audit_%';

-- 4. Contar datos
SELECT
  (SELECT COUNT(*) FROM batch_movements) as movimientos,
  (SELECT COUNT(*) FROM audit_log) as auditorias;
```

---

## 🎯 SIGUIENTE PASO: PROBAR EN LA APP

Una vez que todo esté ✅:

1. Configura Vercel para usar el branch:
   ```
   claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k
   ```

2. Haz redeploy

3. Abre la app y edita un medicamento

4. Verifica en Supabase:
   ```sql
   SELECT * FROM audit_log ORDER BY created_at DESC LIMIT 5;
   ```

5. Deberías ver el registro de tu edición ✅

---

## 📁 RESUMEN DE ARCHIVOS

| Archivo | Ejecutar | Propósito |
|---------|----------|-----------|
| **MIGRATION_SQL_FINAL.sql** | ✅ SÍ (primero) | Instalar funcionalidades |
| **QUICK_TEST.sql** | ✅ SÍ (después) | Verificar que funciona |
| **RESET_DATABASE.sql** | ⚠️ Solo si necesitas | Borrar todo y empezar de nuevo |
| MIGRATION_SQL.sql | ❌ NO (obsoleto) | Versión antigua |
| VERIFICATION_TESTS.sql | ⚠️ Opcional | Similar a QUICK_TEST |

---

## ✅ CHECKLIST FINAL

- [ ] Ejecuté MIGRATION_SQL_FINAL.sql
- [ ] Vi el mensaje "INSTALACIÓN EXITOSA"
- [ ] Ejecuté QUICK_TEST.sql
- [ ] Todos los tests muestran ✅
- [ ] El resumen final dice "FUNCIONALIDADES OPERATIVAS"
- [ ] Configuré Vercel al branch correcto
- [ ] La app está desplegada y funcionando

**Si marcaste todo ✅, ¡el sistema está listo para producción!** 🎉

---

**Última actualización:** 2025-01-07
**Branch:** claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k
**Commit:** 0b981d7
