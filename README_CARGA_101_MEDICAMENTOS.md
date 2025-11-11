# 📦 CARGA MASIVA: 101 MEDICAMENTOS + LOTES

## 🎯 DESCRIPCIÓN

Script SQL que carga **101 medicamentos reales** con:

- ✅ Entrada en **medication_catalog** (catálogo maestro)
- ✅ Instancia en **medications** (asignada a centro)
- ✅ **Lotes iniciales** con stock (100-500 unidades/lote)
- ✅ Centro: **"Centro de Salud Urbano La Esperanza"**
- ✅ Contrato: **CA-0158-2025**
- ✅ Proveedor: **Distribuidora Farmacéutica Nacional**

---

## 📋 CONTENIDO DEL SCRIPT

### **101 Medicamentos Incluidos:**

#### Antiinfecciosos (25)
- Ketoconazol + Clindamicina, Amoxicilina, Ciprofloxacino, Azitromicina
- Cefalexina, Metronidazol, Clotrimazol, Fluconazol, Aciclovir
- Penicilina G, Eritromicina, Levofloxacino, Nitrofurantoína
- Trimetoprima/Sulfametoxazol, Doxiciclina, Claritromicina
- Mebendazol, Albendazol, Nistatina, Ceftriaxona, Gentamicina
- Vancomicina, Ampicilina, Oseltamivir, Ivermectina

#### Analgésicos y Antiinflamatorios (25)
- Paracetamol (500mg, 1g), Ibuprofeno (400mg, 600mg)
- Naproxeno, Diclofenaco, Ketorolaco, Meloxicam, Metamizol
- Tramadol, Morfina, Celecoxib, Aspirina, Etoricoxib
- Ketoprofeno, Piroxicam, Paracetamol+Codeína, Butilhioscina
- Colchicina, Dexametasona, Prednisona (5mg, 20mg)
- Betametasona, Hidrocortisona

#### Cardiovasculares y Antidiabéticos (25)
- Enalapril (10mg, 20mg), Losartán (50mg, 100mg)
- Amlodipino (5mg, 10mg), Metformina (500mg, 850mg, 1000mg)
- Glibenclamida, Insulina NPH, Insulina Rápida
- Atorvastatina, Simvastatina, Propranolol, Carvedilol
- Furosemida, Hidroclorotiazida, Espironolactona, Digoxina
- Clopidogrel, Warfarina, Glimepirida, Captopril, Valsartán

#### Gastrointestinales y Otros (26)
- Omeprazol, Ranitidina, Pantoprazol, Metoclopramida
- Loperamida, Lactulosa, Bisacodilo, Hidróxido de Aluminio
- Domperidona, Simeticona, Levotiroxina (50mcg, 100mcg)
- Loratadina, Cetirizina, Fexofenadina, Montelukast
- Salbutamol Inhalador, Beclometasona Inhalador, Fluticasona Nasal
- Alprazolam, Clonazepam, Diazepam, Sertralina, Fluoxetina
- Ácido Fólico, Complejo B Inyectable

---

## 🚀 CÓMO USAR EL SCRIPT

### **PASO 1: Ir a Supabase Dashboard**

1. https://supabase.com/dashboard
2. Seleccionar proyecto SIGIMED
3. Panel izquierdo → "SQL Editor"
4. Click "+ New query"

---

### **PASO 2: Copiar y Ejecutar Script**

1. Abrir archivo: `CARGA_101_MEDICAMENTOS_LOTES.sql`
2. Copiar **TODO** el contenido
3. Pegarlo en SQL Editor
4. Click **"Run"** (botón verde)

---

### **PASO 3: Verificar Resultados**

El script mostrará mensajes como:

```
====================================
INICIO: Carga de 101 medicamentos
====================================
✅ Centro creado: Centro de Salud Urbano La Esperanza (ID: xxx)
✅ Proveedor creado: Distribuidora Farmacéutica Nacional (ID: xxx)
✅ Contrato creado: CA-0158-2025 (ID: xxx)
====================================
PASO 6: Insertando medicamentos
====================================
  → Procesados 20 medicamentos...
  → Procesados 40 medicamentos...
  → Procesados 60 medicamentos...
  → Procesados 80 medicamentos...
  → Procesados 100 medicamentos...
====================================
✅ COMPLETADO: 101 medicamentos cargados
====================================

RESUMEN FINAL
====================================
Centro: Centro de Salud Urbano La Esperanza
Contrato: CA-0158-2025
Proveedor: Distribuidora Farmacéutica Nacional

Medicamentos en medication_catalog: 101
Instancias en medications: 101
Lotes creados: 101

✅ Stock total disponible: ~25,000 unidades
====================================
```

---

### **PASO 4: Verificar en Frontend**

1. **Ir a Dashboard:**
   ```
   https://med-dgprs-54g9-5gdjo38oe-rodrigo-rojas-projects-190f877f.vercel.app/
   ```

2. **Login y Seleccionar Centro:**
   - Seleccionar: "Centro de Salud Urbano La Esperanza"

3. **Ver Dashboard:**
   ```
   Total Medicamentos: 101
   Stock Total: ~25,000 unidades
   Lotes activos: 101
   ```

4. **Verificar /inventario:**
   - Dropdown debe mostrar 101 medicamentos
   - Cada medicamento debe tener 1 lote disponible

---

## 📊 ESTRUCTURA DE DATOS CREADOS

### **1. medication_catalog (Catálogo Maestro)**

```sql
codigo_medicamento: MED-2531012615 a MED-2531012715
nombre_generico: Ketoconazol 400mg + Clindamicina 100mg, etc.
nombre_comercial: Maver, Pisa, Loefler, etc.
forma_farmaceutica: Tableta, Cápsula, Inyectable, etc.
via_administracion: Oral, Tópica, Intravenosa, etc.
concentracion: 500mg, 1g, 100UI/mL, etc.
categoria: Antibiótico, AINE, Antidiabético, etc.
requiere_receta: true/false
controlado: true/false (medicamentos controlados)
temperatura_almacenamiento: 15-25°C o 2-8°C (refrigerados)
```

### **2. medications (Instancias por Centro)**

```sql
center_id: Centro de Salud Urbano La Esperanza
catalog_id: Referencia a medication_catalog
nombre: Nombre del medicamento
unidad_medida: Caja, Ampolleta, Frasco, Tubo, etc.
categoria: Antibiótico, AINE, etc.
requiere_refrigeracion: true para insulinas, vacunas
```

### **3. batches (Lotes de Inventario)**

```sql
medication_id: Referencia a medications
numero_lote: LOTE-CA-0158-2025-001 a LOTE-CA-0158-2025-101
cantidad_inicial: 100-500 unidades (aleatorio)
cantidad_actual: 100-500 unidades
fecha_fabricacion: Hace 6 meses
fecha_caducidad: En 18 meses (vigencia de 2 años)
fecha_ingreso: Hace 1 mes
stock_minimo: 50
stock_maximo: 1000
estado: 'disponible'
```

---

## 🔧 CARACTERÍSTICAS DEL SCRIPT

### **Eficiencia con PL/pgSQL:**

- ✅ Usa **variables** para IDs (no consultas repetidas)
- ✅ **Loop FOREACH** para insertar 101 medicamentos
- ✅ **ON CONFLICT** para evitar duplicados
- ✅ **Transacción única** (BEGIN/COMMIT)
- ✅ **Logs cada 20 registros** para seguimiento
- ✅ **Resumen final** con estadísticas

### **Datos Realistas:**

- ✅ Códigos únicos: MED-2531012615 a MED-2531012715
- ✅ Nombres comerciales reales: Maver, Pisa, Tafirol, Actron, etc.
- ✅ Categorías correctas: Antibiótico, AINE, Antidiabético, etc.
- ✅ Temperaturas según medicamento: 15-25°C o 2-8°C
- ✅ Stock aleatorio: 100-500 unidades por lote
- ✅ Fechas de caducidad realistas: 18 meses desde hoy

### **Medicamentos Controlados:**

Los siguientes se marcan como `controlado = true`:

- Tramadol, Morfina (Analgésicos opioides)
- Insulina NPH, Insulina Rápida (Antidiabéticos)
- Vancomicina (Antibiótico)
- Digoxina, Warfarina (Cardiovasculares)
- Alprazolam, Clonazepam, Diazepam (Benzodiacepinas)

### **Medicamentos Refrigerados:**

Requieren temperatura 2-8°C:

- Penicilina G Benzatínica
- Vancomicina
- Insulina NPH
- Insulina Rápida

---

## ✅ VERIFICACIÓN POST-CARGA

### **Query 1: Contar por tabla**

```sql
-- En medication_catalog
SELECT count(*) FROM medication_catalog
WHERE codigo_medicamento LIKE 'MED-2531%';
-- Resultado esperado: 101

-- En medications
SELECT count(*) FROM medications
WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001');
-- Resultado esperado: 101

-- En batches
SELECT count(*), sum(cantidad_actual) FROM batches
WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001');
-- Resultado esperado: 101 lotes, ~25,000 unidades
```

### **Query 2: Ver medicamentos por categoría**

```sql
SELECT
  categoria,
  count(*) as cantidad
FROM medication_catalog
WHERE codigo_medicamento LIKE 'MED-2531%'
GROUP BY categoria
ORDER BY cantidad DESC;
```

### **Query 3: Verificar medicamentos controlados**

```sql
SELECT
  codigo_medicamento,
  nombre_generico,
  categoria,
  controlado
FROM medication_catalog
WHERE codigo_medicamento LIKE 'MED-2531%'
  AND controlado = true;
-- Resultado esperado: ~10 medicamentos controlados
```

### **Query 4: Ver lotes próximos a caducar**

```sql
SELECT
  mc.nombre_generico,
  b.numero_lote,
  b.cantidad_actual,
  b.fecha_caducidad,
  (b.fecha_caducidad - current_date) as dias_restantes
FROM batches b
JOIN medications m ON b.medication_id = m.id
JOIN medication_catalog mc ON m.catalog_id = mc.id
WHERE b.center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001')
ORDER BY b.fecha_caducidad ASC
LIMIT 10;
```

---

## 🚨 TROUBLESHOOTING

### **Error: "relation does not exist"**

**Problema:** Alguna tabla no existe en tu BD

**Solución:**
```sql
-- Verificar qué tablas existen
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('medication_catalog', 'medications', 'batches', 'health_centers', 'suppliers', 'contracts');
```

Si falta alguna tabla, ejecuta primero los scripts de migración.

---

### **Error: "duplicate key value"**

**Problema:** Ya existen medicamentos con esos códigos

**Solución:**

El script usa `ON CONFLICT DO UPDATE` para actualizar si existe.

Si quieres limpiar datos anteriores:
```sql
-- CUIDADO: Esto BORRA datos existentes
DELETE FROM batches WHERE numero_lote LIKE 'LOTE-CA-0158-2025-%';
DELETE FROM medications WHERE center_id = (SELECT id FROM health_centers WHERE code = 'CS-URB-ESP-001');
DELETE FROM medication_catalog WHERE codigo_medicamento LIKE 'MED-2531%';
```

---

### **Error: "violates foreign key constraint"**

**Problema:** Faltan datos en tablas relacionadas

**Solución:**

El script crea automáticamente:
- Centro de salud (si no existe)
- Proveedor (si no existe)
- Contrato (si no existe)

Pero verifica que existan estas tablas:
```sql
SELECT * FROM health_centers WHERE code = 'CS-URB-ESP-001';
SELECT * FROM suppliers WHERE nombre = 'Distribuidora Farmacéutica Nacional';
SELECT * FROM contracts WHERE codigo_contrato = 'CA-0158-2025';
```

---

## 📈 DATOS GENERADOS

### **Stock Total Aproximado:**

- **101 lotes** × **~250 unidades promedio** = **~25,000 unidades**

### **Distribución por Categoría:**

- Antiinfecciosos: 25 medicamentos
- Analgésicos/AINE: 25 medicamentos
- Cardiovasculares/Antidiabéticos: 25 medicamentos
- Gastrointestinales/Otros: 26 medicamentos

### **Fechas:**

- **Fabricación:** Hace 6 meses
- **Ingreso:** Hace 1 mes
- **Caducidad:** En 18 meses (vigencia de 2 años total)

---

## 🎯 RESULTADO FINAL

Después de ejecutar el script, tendrás:

✅ **101 medicamentos** en catálogo maestro
✅ **101 instancias** asignadas al Centro La Esperanza
✅ **101 lotes** con stock inicial (100-500 unidades c/u)
✅ **~25,000 unidades** de stock total disponible
✅ Centro, proveedor y contrato configurados

---

## 📞 SOPORTE

Si tienes problemas:

1. Copia el **mensaje de error completo**
2. Ejecuta las queries de verificación
3. Envía screenshot de resultados

---

**¡Script listo para cargar 101 medicamentos en un solo clic!** 🚀
