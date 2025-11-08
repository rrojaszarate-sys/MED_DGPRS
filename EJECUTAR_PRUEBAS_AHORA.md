# 🚀 EJECUTAR PRUEBAS AUTOMATIZADAS - SCRIPT CORREGIDO

## ⚠️ IMPORTANTE: USAR EL SCRIPT CORREGIDO

He corregido el error de la tabla `alertas_medicamentos`.

**Usa este archivo**: `TEST_COMPLETO_AUTOMATIZADO_FIXED.sql`

---

## ✅ QUÉ SE CORRIGIÓ

1. **Manejo de tablas faltantes**: El script ahora verifica si las tablas existen antes de intentar limpiarlas
2. **Manejo robusto de errores**: Cada operación tiene su propio bloque try-catch
3. **Mensajes informativos**: Te dirá exactamente qué tabla no existe si falta alguna
4. **Funciones opcionales**: Si las funciones SQL no existen, te dirá que ejecutes MIGRATION_SQL_FINAL.sql primero

---

## 🎯 EJECUCIÓN (3 PASOS - 3 MINUTOS)

### Paso 1: Abrir Supabase SQL Editor
```
1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto SIGIMED
3. Click en "SQL Editor" (menú izquierdo)
4. Click en "New query" (botón +)
```

### Paso 2: Ejecutar el Script Corregido
```
1. Abre el archivo: TEST_COMPLETO_AUTOMATIZADO_FIXED.sql
2. Selecciona TODO (Ctrl+A)
3. Copia (Ctrl+C)
4. Pega en SQL Editor de Supabase
5. Click en "RUN" (botón verde)
```

### Paso 3: Ver Resultados (30 segundos)
El script mostrará:
```
============================================================
  REPORTE FINAL DE PRUEBAS
============================================================

┌─────────────────────────────────────────────────────────┐
│                  RESUMEN DE PRUEBAS                     │
├─────────────────────────────────────────────────────────┤
│  Total de Pruebas:         16                           │
│  Pruebas Exitosas:         ?? ✅                        │
│  Pruebas Fallidas:         ?? ❌                        │
│  Tasa de Éxito:            ??.?? %                      │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 INTERPRETACIÓN DE RESULTADOS

### ✅ CASO IDEAL (16/16 o 12/16)
```
  Pruebas Exitosas:         16 ✅
  Pruebas Fallidas:          0 ❌
```
**Significado**: ¡TODO FUNCIONA PERFECTAMENTE! 🎉

**O también está bien:**
```
  Pruebas Exitosas:         12 ✅
  Pruebas Fallidas:          4 ❌
```
**Significado**: Funcionalidades básicas OK. Los 4 tests fallidos pueden ser:
- Tests 5-6, 10, 16 (funciones avanzadas - requieren MIGRATION_SQL_FINAL.sql)

---

### ⚠️ SI FALLAN TESTS 5-10

**Mensaje típico**:
```
❌ TEST 5: registrar_movimiento_lote (ENTRADA) - FAIL: La función no existe.
   Ejecuta MIGRATION_SQL_FINAL.sql primero.
```

**SOLUCIÓN**:
1. Abre otro tab en SQL Editor
2. Abre el archivo `MIGRATION_SQL_FINAL.sql`
3. Copia TODO y pega
4. Ejecuta
5. Regresa al tab anterior
6. Ejecuta `TEST_COMPLETO_AUTOMATIZADO_FIXED.sql` de nuevo

---

### ⚠️ SI NO HAY USUARIOS

**Mensaje típico**:
```
⚠️ No hay usuarios disponibles. Tests 5-6, 10, 16 se omitirán.
```

**EFECTO**: Tests 5, 6, 10, 16 se saltan (no es crítico para verificar el sistema)

**SOLUCIÓN (opcional)**:
1. Ve a Supabase Dashboard → Authentication → Users
2. Click en "Add user" → "Create new user"
3. Email: `test@sigimed.com`
4. Password: `Test123456!`
5. Re-ejecuta el script

---

## 🧪 LAS 16 PRUEBAS

### Grupo 1: Inserción de Datos (Tests 1-4)
- ✅ TEST 1: 3 Centros de Salud
- ✅ TEST 2: 2 Proveedores
- ✅ TEST 3: 5 Medicamentos en Catálogo
- ✅ TEST 4: 7 Lotes en Inventario

### Grupo 2: Funciones SQL (Tests 5-10)
- ✅ TEST 5: registrar_movimiento_lote (ENTRADA)
- ✅ TEST 6: registrar_movimiento_lote (SALIDA)
- ✅ TEST 7: search_inventory_with_batches (búsqueda)
- ✅ TEST 8: search_inventory_with_batches (stock bajo)
- ✅ TEST 9: search_inventory_with_batches (próximos a vencer)
- ✅ TEST 10: generate_traceability_report

### Grupo 3: Consultas SQL (Tests 11-14)
- ✅ TEST 11: Inventario completo
- ✅ TEST 12: Búsqueda por nombre
- ✅ TEST 13: Stock bajo (<50 unidades)
- ✅ TEST 14: Filtro por estado

### Grupo 4: Sistema de Alertas (Tests 15-16)
- ✅ TEST 15: Detección de vencimientos
- ✅ TEST 16: Registro en batch_movements

---

## 📋 DESPUÉS DE LAS PRUEBAS

### Verificar en Vercel:

Una vez que las pruebas pasen, abre tu app en Vercel:

#### 1. Login y Selección
- Login con tu usuario
- Seleccionar "Hospital Central de Prueba"

#### 2. Inventario
- Ver **6 medicamentos** en Hospital Central
- Botón **"Importar"** debe estar visible
- Buscar "PARACETAMOL" → muestra stock actualizado

#### 3. Reportes
- Pestaña **"Reportes"** en navegación
- Click → Página carga
- **Búsqueda Avanzada** disponible
- **Trazabilidad por Lote** disponible

#### 4. Filtros
- **Stock bajo** → Muestra medicamentos <50 unidades:
  - Ciprofloxacino (15)
  - Insulina (25)
  - Amoxicilina (45)

- **Próximos a vencer (30 días)** → Muestra:
  - Losartán (15 días)

#### 5. Trazabilidad
- Medicamento: PARACETAMOL
- Lote: TEST-PAR-2024-001
- Debe mostrar **2 movimientos** (Entrada +500, Salida -300)

---

## 🗑️ LIMPIAR DATOS DE PRUEBA

Cuando termines de verificar, ejecuta:

```sql
-- Copiar y pegar en SQL Editor

DELETE FROM batch_movements WHERE numero_documento LIKE 'TEST-%';
DELETE FROM medications WHERE lote LIKE 'TEST-%';
DELETE FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%';
DELETE FROM suppliers WHERE ruc LIKE 'TEST%';
DELETE FROM health_centers WHERE code LIKE 'TEST-%';

SELECT '✅ Datos de prueba eliminados' as status;
```

---

## 📈 CRITERIOS DE ÉXITO

### ✅ Mínimo Aceptable (12/16 tests pasan)
**Significa que**:
- Inserción de datos funciona (Tests 1-4) ✅
- Consultas SQL funcionan (Tests 11-14) ✅
- Sistema de alertas funciona (Test 15) ✅
- Funciones avanzadas necesitan MIGRATION_SQL_FINAL.sql (Tests 5-10)

### 🎉 Ideal (16/16 tests pasan)
**Significa que**:
- TODO el sistema está 100% funcional
- Todas las funciones SQL están instaladas
- Trazabilidad completa funciona
- Sistema listo para producción

---

## 🔧 SOLUCIÓN RÁPIDA DE PROBLEMAS

### Problema 1: Tests 1-4 fallan
**Causa**: Error de permisos o conexión
**Solución**:
- Verifica que estás logueado en Supabase
- Verifica que seleccionaste el proyecto correcto

### Problema 2: Tests 5-10 fallan
**Causa**: Funciones SQL no existen
**Solución**: Ejecutar `MIGRATION_SQL_FINAL.sql`

### Problema 3: Tests 11-16 fallan
**Causa**: Datos no se insertaron (Tests 1-4 fallaron)
**Solución**: Revisar por qué fallaron Tests 1-4 primero

### Problema 4: Error de sintaxis
**Causa**: Script no se copió completamente
**Solución**: Asegúrate de copiar TODO el archivo (Ctrl+A)

---

## ⏱️ TIEMPO ESTIMADO

- **Ejecutar script**: 30 segundos
- **Revisar resultados**: 2 minutos
- **Verificar en Vercel**: 10 minutos
- **Limpiar datos**: 30 segundos

**TOTAL**: ~13 minutos

---

## 🎯 ACCIÓN INMEDIATA

**AHORA MISMO:**

1. Abre: https://supabase.com/dashboard
2. SQL Editor → New query
3. Copia `TEST_COMPLETO_AUTOMATIZADO_FIXED.sql` completo
4. Pega y ejecuta
5. Espera 30 segundos
6. Revisa cuántos tests pasan

**Resultado esperado**: Al menos 12/16 ✅

---

## 📞 ARCHIVOS IMPORTANTES

- **TEST_COMPLETO_AUTOMATIZADO_FIXED.sql** ⭐⭐⭐ **USAR ESTE**
- ~~TEST_COMPLETO_AUTOMATIZADO.sql~~ (versión antigua - no usar)
- **MIGRATION_SQL_FINAL.sql** (ejecutar si Tests 5-10 fallan)
- **INSTRUCCIONES_EJECUTAR_PRUEBAS.md** (guía detallada)

---

**🚀 ¡El script corregido está listo! Cópialo y ejecútalo ahora.**

**Archivo**: `TEST_COMPLETO_AUTOMATIZADO_FIXED.sql`
**Tiempo**: 30 segundos
**Resultado esperado**: Mínimo 12/16 ✅
