# 🧪 GUÍA DE PRUEBAS AUTOMATIZADAS - SIGIMED

## 🎯 Objetivo

Ejecutar pruebas automatizadas completas del sistema SIGIMED para verificar que TODAS las funcionalidades están funcionando correctamente después del deployment.

---

## ⚡ EJECUCIÓN RÁPIDA (1 MINUTO)

### Paso 1: Abrir Supabase SQL Editor
1. Ve a: **https://supabase.com/dashboard**
2. Selecciona tu proyecto **SIGIMED**
3. Click en **"SQL Editor"** en el menú lateral izquierdo
4. Click en **"New query"** (botón + arriba a la derecha)

### Paso 2: Ejecutar Script de Pruebas
1. Abre el archivo **`TEST_COMPLETO_AUTOMATIZADO.sql`** desde este repositorio
2. **Copia TODO el contenido** (Ctrl+A, Ctrl+C)
3. **Pega** en el SQL Editor de Supabase
4. Click en **"RUN"** (botón verde) o presiona **Ctrl+Enter**
5. **Espera ~30 segundos** mientras se ejecutan todas las pruebas

### Paso 3: Revisar Resultados
En la pestaña **"Results"** (abajo) verás la salida de las pruebas:

```
============================================================
  REPORTE FINAL DE PRUEBAS
============================================================

┌─────────────────────────────────────────────────────────┐
│                  RESUMEN DE PRUEBAS                     │
├─────────────────────────────────────────────────────────┤
│  Total de Pruebas:         16                           │
│  Pruebas Exitosas:         16 ✅                        │
│  Pruebas Fallidas:          0 ❌                        │
│  Tasa de Éxito:           100.00 %                      │
└─────────────────────────────────────────────────────────┘
```

**✅ Si ves "16 ✅" y "0 ❌" → TODO FUNCIONA PERFECTAMENTE**

---

## 📊 ¿QUÉ SE PRUEBA?

El script ejecuta **16 pruebas automatizadas** que verifican:

### 1. Inserción de Datos (Tests 1-4)
- ✅ **TEST 1**: Inserción de 3 Centros de Salud
- ✅ **TEST 2**: Inserción de 2 Proveedores
- ✅ **TEST 3**: Inserción de 5 Medicamentos en Catálogo
- ✅ **TEST 4**: Inserción de 7 Lotes en Inventario

### 2. Funciones de Base de Datos (Tests 5-10)
- ✅ **TEST 5**: `registrar_movimiento_lote()` - ENTRADA (incrementa stock)
- ✅ **TEST 6**: `registrar_movimiento_lote()` - SALIDA (decrementa stock)
- ✅ **TEST 7**: `search_inventory_with_batches()` - Búsqueda por nombre
- ✅ **TEST 8**: `search_inventory_with_batches()` - Filtro stock bajo (<50 und)
- ✅ **TEST 9**: `search_inventory_with_batches()` - Filtro próximos a vencer (30 días)
- ✅ **TEST 10**: `generate_traceability_report()` - Trazabilidad de lotes

### 3. Consultas de Inventario (Tests 11-14)
- ✅ **TEST 11**: Listar inventario completo de un centro
- ✅ **TEST 12**: Búsqueda por nombre de medicamento
- ✅ **TEST 13**: Filtro de stock bajo (<50 unidades)
- ✅ **TEST 14**: Filtro por estado (Disponible)

### 4. Sistema de Alertas (Tests 15-16)
- ✅ **TEST 15**: Detección de medicamentos próximos a vencer
- ✅ **TEST 16**: Registro automático en `batch_movements`

---

## 🔍 INTERPRETACIÓN DE RESULTADOS

### ✅ CASO EXITOSO (Esperado):
```
============================================================
  REPORTE FINAL DE PRUEBAS
============================================================

  Total de Pruebas:         16
  Pruebas Exitosas:         16 ✅
  Pruebas Fallidas:          0 ❌
  Tasa de Éxito:           100.00 %

🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE
```

**Significado**: El sistema está 100% funcional. Todas las características están operativas.

---

### ⚠️ CASO CON FALLOS:
```
  Total de Pruebas:         16
  Pruebas Exitosas:         14 ✅
  Pruebas Fallidas:          2 ❌
  Tasa de Éxito:            87.50 %

⚠️  ALGUNAS PRUEBAS FALLARON - Revisar detalles arriba
```

**Acciones**:
1. **Scroll hacia arriba** en los resultados
2. Busca las líneas con **❌**
3. Revisa el mensaje de error específico

**Ejemplo de error**:
```
❌ TEST 8: search_inventory_with_batches (Stock Bajo) - FAIL (0 medicamentos)
```

**Posibles causas**:
- La función `search_inventory_with_batches()` no existe → Ejecutar `MIGRATION_SQL_FINAL.sql`
- Permisos insuficientes → Verificar RLS policies
- Datos no insertados correctamente → Re-ejecutar el script

---

## 📋 CHECKLIST POST-PRUEBAS

Después de ejecutar el script y ver **16/16 PASS**, verifica en la interfaz web:

### En Vercel:

#### 1. Dashboard
- [ ] Login funciona
- [ ] Puedo seleccionar "Hospital Central de Prueba"
- [ ] Dashboard muestra estadísticas

#### 2. Inventario
- [ ] Veo **6 medicamentos** en el Hospital Central
- [ ] Botón **"Importar"** visible
- [ ] Puedo buscar "PARACETAMOL" → muestra 1 resultado
- [ ] Puedo buscar "AMOXICILINA" → muestra 2 resultados

#### 3. Reportes
- [ ] Pestaña **"Reportes"** visible en navegación
- [ ] Página de Reportes carga correctamente
- [ ] **Búsqueda Avanzada** funciona
- [ ] Filtro **"Stock bajo"** → muestra 3 medicamentos (Ciprofloxacino 15, Insulina 25, Amoxicilina 45)
- [ ] Filtro **"Próximos a vencer (30 días)"** → muestra 1 medicamento (Losartán 15 días)

#### 4. Trazabilidad
- [ ] En Reportes → **Trazabilidad por Lote**
- [ ] Buscar medicamento: **PARACETAMOL**
- [ ] Lote: **TEST-PAR-2024-001**
- [ ] Click "Generar Reporte" → Muestra **2 movimientos** (Entrada +500, Salida -300)

#### 5. Alertas
- [ ] Pestaña **"Alertas"** muestra medicamentos próximos a vencer
- [ ] Muestra **Losartán** (vence en 15 días)

---

## 🔧 SOLUCIÓN DE PROBLEMAS

### Problema 1: "function registrar_movimiento_lote() does not exist"

**Causa**: El script `MIGRATION_SQL_FINAL.sql` no se ha ejecutado.

**Solución**:
1. Abrir Supabase SQL Editor
2. Copiar contenido de `MIGRATION_SQL_FINAL.sql`
3. Ejecutar
4. Re-ejecutar `TEST_COMPLETO_AUTOMATIZADO.sql`

---

### Problema 2: "No hay usuarios disponibles"

**Causa**: No existe ningún usuario en `auth.users`.

**Efecto**: Tests 5, 6, 10 y 16 se saltarán (no es crítico).

**Solución** (opcional):
1. Ve a Supabase Dashboard → **Authentication** → **Users**
2. Click en **"Add user"** → **"Create new user"**
3. Ingresa email y contraseña
4. Re-ejecutar pruebas

**Nota**: Los tests principales (1-4, 7-9, 11-15) NO requieren usuarios.

---

### Problema 3: TEST 7-10 fallan (Funciones no encontradas)

**Causa**: Las funciones SQL no existen en la base de datos.

**Solución**:
1. Verificar que `MIGRATION_SQL_FINAL.sql` se ejecutó correctamente
2. Ejecutar esta consulta para verificar:
   ```sql
   SELECT routine_name
   FROM information_schema.routines
   WHERE routine_schema = 'public'
     AND routine_name IN (
       'registrar_movimiento_lote',
       'search_inventory_with_batches',
       'generate_traceability_report'
     );
   ```
3. Debe mostrar las 3 funciones
4. Si no aparecen, ejecutar `MIGRATION_SQL_FINAL.sql` de nuevo

---

### Problema 4: TEST 15 falla (No detecta vencimientos)

**Causa**: Los datos de prueba expiran en fechas futuras relativas a `CURRENT_DATE`.

**Efecto**: Si ejecutas el script mucho tiempo después de hoy, algunas fechas pueden haber cambiado.

**Solución**: Este test debería pasar siempre si se ejecuta dentro de 15 días. Si falla, no es crítico.

---

### Problema 5: Permisos insuficientes (permission denied)

**Causa**: Row Level Security (RLS) está bloqueando las operaciones.

**Solución**:
1. Ve a Supabase Dashboard → **Authentication** → **Policies**
2. Verifica que existen políticas para las tablas:
   - `health_centers`
   - `suppliers`
   - `medication_catalog`
   - `medications`
   - `batch_movements`
3. Si faltan políticas, ejecutar `MIGRATION_SQL_FINAL.sql`

---

## 🗑️ LIMPIAR DATOS DE PRUEBA

Si quieres eliminar todos los datos de prueba después de verificar:

```sql
BEGIN;

DELETE FROM batch_movements WHERE numero_documento LIKE 'TEST-%';
DELETE FROM alertas_medicamentos WHERE medicamento_id IN (
  SELECT id FROM medications WHERE lote LIKE 'TEST-%'
);
DELETE FROM medications WHERE lote LIKE 'TEST-%';
DELETE FROM user_centers WHERE center_id IN (
  SELECT id FROM health_centers WHERE code LIKE 'TEST-%'
);
DELETE FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%';
DELETE FROM suppliers WHERE ruc LIKE 'TEST%';
DELETE FROM health_centers WHERE code LIKE 'TEST-%';

COMMIT;

SELECT '✅ Datos de prueba eliminados' as status;
```

---

## 📊 DATOS DE PRUEBA INCLUIDOS

El script inserta automáticamente:

### Centros de Salud (3):
- **Hospital Central de Prueba** (TEST-HCP-001) - Lima
- **Centro de Salud Norte** (TEST-CSN-002) - Lima
- **Posta Médica Sur** (TEST-PMS-003) - Arequipa

### Proveedores (2):
- **Farmacéutica Global SAC** (RUC: TEST20123456789)
- **Distribuidora MediPharma EIRL** (RUC: TEST20987654321)

### Catálogo (5 medicamentos):
- AMOXICILINA PRUEBA 500mg
- PARACETAMOL PRUEBA 500mg
- CIPROFLOXACINO PRUEBA 500mg
- LOSARTAN PRUEBA 50mg
- INSULINA PRUEBA NPH 100UI/ml

### Inventario (7 lotes):

**Hospital Central (6 lotes):**
- 1500 und PARACETAMOL (vence en 18 meses) ✅
- 500 und AMOXICILINA (vence en 12 meses) ✅
- 45 und AMOXICILINA (vence en 45 días) ⚠️
- 15 und CIPROFLOXACINO (vence en 6 meses) ⚠️ Stock bajo
- 80 und LOSARTAN (vence en 15 días) 🚨 Vence pronto
- 25 und INSULINA (vence en 8 meses) ⚠️ Stock bajo + Refrigerado

**Centro Norte (1 lote):**
- 600 und PARACETAMOL (vence en 16 meses) ✅

### Movimientos (2):
- **ENTRADA**: +500 und Paracetamol (Documento: TEST-ENTRADA-001)
- **SALIDA**: -300 und Paracetamol (Documento: TEST-SALIDA-001)

---

## ⏱️ TIEMPO DE EJECUCIÓN

- **Preparación**: 1 minuto (copiar/pegar script)
- **Ejecución**: ~30 segundos
- **Revisión**: 2-3 minutos
- **TOTAL**: ~5 minutos

---

## ✅ RESULTADO ESPERADO

Al finalizar, deberías ver:

```
🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE

📋 PRÓXIMOS PASOS:
  1. Verificar la interfaz web en Vercel
  2. Probar funcionalidad de importación manual
  3. Validar reportes en formato PDF/Excel
  4. Revisar navegación y UI de la aplicación
```

Y en la última tabla de verificación:

| Categoría | Cantidad |
|-----------|----------|
| centros_salud | 3 |
| proveedores | 2 |
| catalogo | 5 |
| inventario | 7 |
| movimientos_recientes | 2 |

---

## 🚀 SIGUIENTE PASO: VERIFICAR VERCEL

Una vez que todas las pruebas pasan (16/16 ✅), el siguiente paso es:

1. **Abrir tu aplicación en Vercel**
2. **Login** con tu usuario
3. **Seleccionar** "Hospital Central de Prueba" en el selector de centro
4. **Verificar cada funcionalidad** según el checklist arriba

Si no ves la opción "Hospital Central de Prueba" o los cambios en Vercel:
- Revisar **`HACER_PRINCIPAL.md`** para configurar Vercel correctamente
- O hacer **Redeploy** en Vercel sin cache

---

## 📞 SOPORTE

Si alguna prueba falla:

1. **Captura screenshot** del resultado completo (scroll hasta el inicio)
2. **Identifica** qué test falló (número y nombre)
3. **Revisa** la sección "Solución de Problemas" arriba
4. **Ejecuta** la consulta de verificación correspondiente
5. **Reporta** el problema con el screenshot si persiste

---

**🎉 ¡Listo para ejecutar las pruebas!**

Tiempo estimado total: **5 minutos**
