# 📊 GUÍA DE DATOS DE PRUEBA - SIGIMED

## 🎯 Objetivo

Insertar datos de prueba realistas en el sistema SIGIMED para verificar que todas las funcionalidades estén funcionando correctamente después del deployment en Vercel.

---

## ⚡ EJECUCIÓN RÁPIDA (3 pasos)

### Paso 1: Abrir Supabase SQL Editor
1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto SIGIMED
3. Click en "SQL Editor" en el menú lateral

### Paso 2: Ejecutar MIGRATION_SQL_FINAL.sql (Si no lo has hecho)
```sql
-- Copiar y pegar el contenido de MIGRATION_SQL_FINAL.sql
-- Click en "Run" o presionar Ctrl+Enter
```

### Paso 3: Ejecutar DATOS_PRUEBA.sql
```sql
-- Copiar y pegar el contenido de DATOS_PRUEBA.sql
-- Click en "Run" o presionar Ctrl+Enter
```

### Paso 4 (Opcional): Ejecutar DATOS_PRUEBA_MOVIMIENTOS.sql
```sql
-- Copiar y pegar el contenido de DATOS_PRUEBA_MOVIMIENTOS.sql
-- Click en "Run" o presionar Ctrl+Enter
```

---

## 📦 ¿QUÉ DATOS SE INSERTAN?

### 1. Centros de Salud (3)
- ✅ **Hospital Central de Prueba** (Código: TEST-HCP-001)
  - Ubicación: Lima
  - Capacidad: 5000 unidades
  - Con refrigeración

- ✅ **Centro de Salud Norte** (Código: TEST-CSN-002)
  - Ubicación: Lima
  - Capacidad: 2000 unidades
  - Con refrigeración

- ✅ **Posta Médica Sur** (Código: TEST-PMS-003)
  - Ubicación: Arequipa
  - Capacidad: 1000 unidades
  - Sin refrigeración

### 2. Proveedores (2)
- ✅ Farmacéutica Global SAC (RUC: TEST20123456789)
- ✅ Distribuidora MediPharma EIRL (RUC: TEST20987654321)

### 3. Catálogo de Medicamentos (10)
- ✅ Antibióticos: Amoxicilina, Ciprofloxacino
- ✅ Analgésicos: Paracetamol, Ibuprofeno
- ✅ Antihipertensivos: Losartán, Enalapril
- ✅ Antidiabéticos: Metformina
- ✅ Inyectables: Insulina NPH (refrigerada)
- ✅ Jarabes: Ambroxol
- ✅ Vitaminas: Complejo B

### 4. Inventario de Medicamentos (16 lotes)

**Hospital Central (11 lotes):**
- 500 und Amoxicilina (vence en 12 meses) ✅ Stock bueno
- 45 und Amoxicilina (vence en 45 días) ⚠️ Próximo a vencer
- 15 und Ciprofloxacino ⚠️ Stock crítico
- 1500 und Paracetamol ✅ Stock excelente
- 200 und Ibuprofeno ✅ Stock medio
- 80 und Losartán (vence en 15 días) 🚨 Vence pronto
- 350 und Enalapril ✅ Stock bueno
- 800 und Metformina ✅ Stock excelente
- 25 und Insulina (refrigerada) ⚠️ Stock bajo
- 120 und Ambroxol jarabe ✅ Stock medio
- 60 und Complejo B ⚠️ Stock bajo

**Centro de Salud Norte (4 lotes):**
- 600 und Paracetamol ✅
- 10 und Amoxicilina (vence en 20 días) 🚨
- 150 und Metformina ✅
- 50 und Ibuprofeno (EN CUARENTENA) ⚠️

**Posta Médica Sur (2 lotes):**
- 100 und Paracetamol ⚠️ Stock bajo
- 8 und Ambroxol jarabe 🚨 Stock crítico

### 5. Movimientos de Lote (13 movimientos)

**Script DATOS_PRUEBA_MOVIMIENTOS.sql genera:**
- ✅ 2 Entradas (compras)
- ✅ 6 Salidas (dispensaciones)
- ✅ 2 Ajustes de inventario
- ✅ 1 Transferencia entre centros
- ✅ 1 Retiro por vencimiento
- ✅ 1 Merma por daño

---

## 🧪 VERIFICAR QUE TODO FUNCIONA

### 1. Verificar en la Interfaz Web

#### A. Login y Selección de Centro
1. Abre tu app en Vercel
2. Haz login con tu usuario
3. Selecciona: **Hospital Central de Prueba**

#### B. Verificar Inventario
1. Ve a la pestaña **"Inventario"**
2. Deberías ver **11 medicamentos** listados
3. Busca: **"PARACETAMOL"** → Debe mostrar 1500 unidades
4. Busca: **"INSULINA"** → Debe mostrar 25 unidades

#### C. Verificar Botón de Importación
1. En la página de Inventario
2. Deberías ver un botón **"Importar"**
3. Click en Importar → Debe abrir modal
4. Deberías ver opción para subir CSV/Excel
5. Deberías ver botón "Descargar Plantilla"

#### D. Verificar Pestaña Reportes
1. En el menú principal, busca la pestaña **"Reportes"**
2. Click en Reportes
3. Deberías ver 2 opciones:
   - 📊 Búsqueda Avanzada de Inventario
   - 📜 Reporte de Trazabilidad por Lote

#### E. Probar Búsqueda Avanzada
1. En Reportes, selecciona "Búsqueda Avanzada"
2. Activa filtro: **"Stock bajo (< 50 und)"**
3. Click en **"Buscar"**
4. Deberías ver:
   - Ciprofloxacino (15 und)
   - Insulina (25 und)
   - Amoxicilina (45 und)
   - Complejo B (60 und si aplica)

#### F. Probar Medicamentos Próximos a Vencer
1. En Reportes, Búsqueda Avanzada
2. Activa filtro: **"Próximos a vencer (30 días)"**
3. Click en **"Buscar"**
4. Deberías ver:
   - Losartán (vence en 15 días)
   - Amoxicilina en Centro Norte (vence en 20 días)

#### G. Probar Trazabilidad (Si ejecutaste DATOS_PRUEBA_MOVIMIENTOS.sql)
1. En Reportes, selecciona "Trazabilidad por Lote"
2. En "Medicamento", busca: **PARACETAMOL**
3. En "Número de Lote", ingresa: **TEST-PAR-2024-001**
4. Click en **"Generar Reporte"**
5. Deberías ver:
   - Entrada de 500 unidades
   - Salida de 800 unidades
   - Transferencia de 200 unidades
   - Stock final calculado

#### H. Verificar Alertas
1. Ve a la pestaña **"Alertas"**
2. Deberías ver alertas para:
   - Losartán (vence en 15 días)
   - Amoxicilina en Centro Norte (vence en 20 días)
   - Medicamentos con stock bajo

---

### 2. Verificar en la Base de Datos (Supabase)

#### Consulta 1: Total de datos de prueba
```sql
SELECT
  'Centros de Salud' as tabla,
  COUNT(*) as registros
FROM health_centers
WHERE code LIKE 'TEST%'

UNION ALL

SELECT
  'Catálogo Medicamentos',
  COUNT(*)
FROM medication_catalog
WHERE nombre_comercial LIKE '%PRUEBA%'

UNION ALL

SELECT
  'Inventario',
  COUNT(*)
FROM medications
WHERE lote LIKE 'TEST%'

UNION ALL

SELECT
  'Movimientos',
  COUNT(*)
FROM batch_movements
WHERE metadata->>'test_data' = 'true'
  OR numero_documento LIKE 'DISP-2024%'
  OR numero_documento LIKE 'TRANS-2024%';
```

**Resultado esperado:**
- Centros de Salud: 3
- Catálogo Medicamentos: 10
- Inventario: 16
- Movimientos: 13 (si ejecutaste DATOS_PRUEBA_MOVIMIENTOS.sql)

#### Consulta 2: Stock por centro
```sql
SELECT
  hc.name as centro,
  COUNT(m.id) as total_lotes,
  SUM(m.cantidad) as total_unidades,
  COUNT(CASE WHEN m.cantidad < 50 THEN 1 END) as lotes_stock_bajo
FROM health_centers hc
LEFT JOIN medications m ON hc.id = m.center_id
WHERE hc.code LIKE 'TEST%'
GROUP BY hc.id, hc.name
ORDER BY total_unidades DESC;
```

**Resultado esperado:**
- Hospital Central: 11 lotes, ~3600 unidades, 4 con stock bajo
- Centro Norte: 4 lotes, ~810 unidades, 2 con stock bajo
- Posta Sur: 2 lotes, ~108 unidades, 2 con stock bajo

#### Consulta 3: Próximos a vencer
```sql
SELECT
  hc.name as centro,
  m.nombre,
  m.lote,
  m.cantidad,
  m.fecha_caducidad,
  (m.fecha_caducidad - CURRENT_DATE) as dias_restantes
FROM medications m
INNER JOIN health_centers hc ON m.center_id = hc.id
WHERE m.lote LIKE 'TEST%'
  AND m.fecha_caducidad <= CURRENT_DATE + INTERVAL '60 days'
ORDER BY m.fecha_caducidad ASC;
```

**Resultado esperado:**
- Losartán: 15 días restantes
- Amoxicilina (Centro Norte): 20 días restantes
- Amoxicilina (Hospital): 45 días restantes

#### Consulta 4: Movimientos recientes
```sql
SELECT
  bm.created_at::date as fecha,
  tipo_movimiento,
  COUNT(*) as cantidad_movimientos
FROM batch_movements bm
WHERE bm.created_at >= NOW() - INTERVAL '1 day'
GROUP BY bm.created_at::date, tipo_movimiento
ORDER BY fecha DESC, cantidad_movimientos DESC;
```

---

## 🧹 LIMPIAR DATOS DE PRUEBA

Si necesitas eliminar todos los datos de prueba:

```sql
BEGIN;

-- Eliminar en orden inverso de dependencias
DELETE FROM batch_movements WHERE metadata->>'test_data' = 'true'
  OR numero_documento LIKE 'DISP-2024%'
  OR numero_documento LIKE 'TRANS-2024%'
  OR numero_documento LIKE 'FC-2024%'
  OR numero_documento LIKE 'INV-2024%'
  OR numero_documento LIKE 'VEN-2024%'
  OR numero_documento LIKE 'MERMA-2024%';

DELETE FROM alertas_medicamentos WHERE id IN (
  SELECT a.id FROM alertas_medicamentos a
  INNER JOIN medications m ON a.medicamento_id = m.id
  WHERE m.nombre LIKE '%PRUEBA%'
);

DELETE FROM medications WHERE nombre LIKE '%PRUEBA%' OR lote LIKE 'TEST%';

DELETE FROM user_centers WHERE center_id IN (
  SELECT id FROM health_centers WHERE code LIKE 'TEST%'
);

DELETE FROM medication_catalog WHERE nombre_comercial LIKE '%PRUEBA%';

DELETE FROM suppliers WHERE ruc LIKE 'TEST%';

DELETE FROM health_centers WHERE code LIKE 'TEST%';

COMMIT;

-- Verificar
SELECT '✅ Datos de prueba eliminados' as status;
```

---

## ❓ PREGUNTAS FRECUENTES

### P: ¿Los datos de prueba afectan a los datos reales?
**R:** No. Todos los datos de prueba tienen identificadores únicos (código TEST%, nombre %PRUEBA%, lote TEST%). Son completamente independientes.

### P: ¿Puedo ejecutar los scripts múltiples veces?
**R:** Sí. Los scripts son **idempotentes**. Cada ejecución elimina los datos anteriores e inserta nuevos.

### P: ¿Necesito crear usuarios primero?
**R:** Para DATOS_PRUEBA.sql NO (solo crea datos). Para DATOS_PRUEBA_MOVIMIENTOS.sql SÍ necesitas al menos un usuario en `auth.users` porque la función `registrar_movimiento_lote()` requiere un usuario responsable.

### P: No veo la pestaña "Reportes" en Vercel
**R:** Posibles causas:
1. Vercel no está desplegando desde el branch correcto
2. El build cache de Vercel está usando una versión anterior
3. Necesitas hacer "Redeploy" sin cache en Vercel

**Solución:**
- Ir a Vercel → Deployments → Click en "..." → Redeploy
- Desactivar "Use existing Build Cache"
- Confirmar Redeploy

### P: El botón "Importar" no aparece
**R:** Mismo problema que arriba. Asegúrate de que Vercel esté desplegando desde `claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k` o que hayas hecho merge a `main`.

### P: Los movimientos no se registran
**R:** Verifica:
1. La función `registrar_movimiento_lote()` existe:
   ```sql
   SELECT routine_name FROM information_schema.routines
   WHERE routine_name = 'registrar_movimiento_lote';
   ```
2. Tienes un usuario autenticado
3. Los UUIDs de medicamentos son correctos

---

## 📞 SOPORTE

Si encuentras problemas:

1. **Revisa los logs de Supabase SQL Editor** para ver mensajes de error
2. **Verifica que MIGRATION_SQL_FINAL.sql se ejecutó correctamente**
3. **Confirma que tu usuario tiene permisos** (Row Level Security)
4. **Revisa los logs de deployment en Vercel** para errores de build

---

## ✅ CHECKLIST DE VERIFICACIÓN

Usa este checklist para verificar que todo funciona:

- [ ] Scripts SQL ejecutados sin errores
- [ ] 3 centros de salud creados
- [ ] 10 medicamentos en catálogo
- [ ] 16 lotes en inventario
- [ ] Login funciona en Vercel
- [ ] Puedo seleccionar "Hospital Central de Prueba"
- [ ] Veo 11 medicamentos en Inventario
- [ ] Veo botón "Importar" en Inventario
- [ ] Veo pestaña "Reportes" en navegación
- [ ] Puedo abrir página de Reportes
- [ ] Búsqueda avanzada funciona
- [ ] Filtro "Stock bajo" muestra resultados
- [ ] Filtro "Próximos a vencer" muestra resultados
- [ ] Trazabilidad por lote funciona (si ejecuté movimientos)
- [ ] Alertas se muestran en pestaña Alertas

---

**¡Listo para probar! 🚀**

Si todos los checks están ✅, el sistema está funcionando correctamente.
