# 🔍 ARQUITECTURA DE TABLAS - ACLARACIÓN CRÍTICA

## SIGIMED TIENE **DOS TABLAS DIFERENTES** DE MEDICAMENTOS

---

## 1️⃣ **`medication_catalog`** - CATÁLOGO MAESTRO

**Propósito:** Base de datos GLOBAL de medicamentos disponibles

**Campos principales:**
```typescript
{
  id: UUID
  codigo_medicamento: string          // MED-KET-CLN-001
  nombre_generico: string              // Ketoconazol + Clindamicina
  nombre_comercial: string             // Maver, Pisa, etc.
  principio_activo: string
  forma_farmaceutica: string           // Tableta, Óvulo, Inyectable
  via_administracion: string           // Oral, Tópica, IV
  concentracion: string                // 400mg + 100mg
  unidad_medida: string                // Caja, Frasco, Ampolleta
  categoria: string
  requiere_receta: boolean
  controlado: boolean
  temperatura_almacenamiento: string
  observaciones: string
  is_active: boolean
  created_at: timestamp
}
```

**Usado en:**
- ✅ `/admin` → AdminPage.tsx → `useCatalogo.ts`
- Para gestionar catálogo global
- NO está ligado a ningún centro específico

**Hook:**
```typescript
// src/hooks/useCatalogo.ts
supabase.from('medication_catalog')  // ← TABLA CORRECTA
```

---

## 2️⃣ **`medications`** - INSTANCIAS EN CENTROS

**Propósito:** Medicamentos ESPECÍFICOS asignados a un CENTRO

**Campos principales:**
```typescript
{
  id: UUID
  center_id: UUID                      // ← Ligado a un centro
  catalog_id: UUID                     // ← Referencia a medication_catalog
  nombre: string
  descripcion: string
  unidad_medida: string
  categoria: string
  requiere_refrigeracion: boolean
  is_active: boolean
  created_at: timestamp
}
```

**Usado en:**
- `/inventario` → Medications específicos de un centro
- Ligado a `center_id`
- Puede referenciar `medication_catalog.id` via `catalog_id`

**Hook:**
```typescript
// src/hooks/useMedicamentos.ts
supabase.from('medications')  // ← Tabla para instancias en centros
```

---

## 🎯 PROBLEMA REPORTADO

**Tu reporte original decía:**
> "Creé medicamento en /admin → apareció → recargué → DESAPARECIÓ"

**Módulo afectado:** `/admin` → AdminPage.tsx

**Tabla usada:** `medication_catalog` ← **MIS SCRIPTS ESTÁN CORRECTOS**

---

## ✅ MIS SCRIPTS USAN LA TABLA CORRECTA

### Script 1: `DIAGNOSTICO_VERCEL_PERSISTENCIA.sql`
```sql
-- Línea 14: Verifica la tabla CORRECTA
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'medication_catalog';  -- ← CORRECTA
```

### Script 2: `APLICAR_POLITICAS_RLS_GARANTIZADO.sql`
```sql
-- Línea 30: Aplica políticas a la tabla CORRECTA
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;  -- ← CORRECTA

CREATE POLICY "medication_catalog_insert_policy"
ON medication_catalog  -- ← CORRECTA
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');
```

### Script 3: `CARGA_MEDICAMENTOS_CSV.sql`
```sql
-- Línea 5: Inserta en la tabla CORRECTA
INSERT INTO medication_catalog (  -- ← CORRECTA
  codigo_medicamento,
  nombre_generico,
  ...
) VALUES (...);
```

---

## ⚠️ TU CONFUSIÓN

Cuando ejecutaste en Supabase SQL Editor y viste:
```
ERROR: 42P01: relation 'medicamentos' does not exist
```

**Probablemente ejecutaste:**
- ❌ Un query incorrecto con `medicamentos` (tabla que NO existe)
- ❌ O un script viejo que no actualicé

**Pero MIS SCRIPTS usan:** `medication_catalog` ✅

---

## 🔧 QUÉ NECESITAS HACER AHORA

### PASO 1: Verificar AMBAS tablas tienen políticas RLS

Ejecuta este query en Supabase SQL Editor:

```sql
-- Ver políticas en medication_catalog
SELECT
  'medication_catalog' as tabla,
  policyname,
  cmd as operacion
FROM pg_policy
WHERE polrelid = 'medication_catalog'::regclass
ORDER BY cmd;

-- Ver políticas en medications
SELECT
  'medications' as tabla,
  policyname,
  cmd as operacion
FROM pg_policy
WHERE polrelid = 'medications'::regclass
ORDER BY cmd;
```

**Resultado esperado para `medication_catalog`:**
```
✅ SELECT policy existe
✅ INSERT policy existe
✅ UPDATE policy existe
✅ DELETE policy existe
```

**Si NO tienes 4 políticas → EJECUTA:** `APLICAR_POLITICAS_RLS_GARANTIZADO.sql`

---

### PASO 2: Verificar datos en medication_catalog

```sql
SELECT count(*) as total
FROM medication_catalog
WHERE is_active = true;
```

**Resultado esperado:** 101 medicamentos (si ejecutaste `CARGA_MEDICAMENTOS_CSV.sql`)

---

### PASO 3: Probar INSERT en medication_catalog

```sql
INSERT INTO medication_catalog (
  codigo_medicamento,
  nombre_generico,
  forma_farmaceutica,
  via_administracion,
  unidad_medida,
  requiere_receta,
  controlado,
  is_active
) VALUES (
  'TEST-FINAL-001',
  'Prueba Final de Persistencia',
  'Tableta',
  'Oral',
  'Caja',
  false,
  false,
  true
);

-- Verificar que se guardó
SELECT * FROM medication_catalog
WHERE codigo_medicamento = 'TEST-FINAL-001';
```

**Si falla → Copiar el error exacto y enviármelo**

---

## 🚨 RESUMEN

| Tabla | Propósito | Usado en | Mis scripts |
|-------|-----------|----------|-------------|
| `medication_catalog` | Catálogo global | `/admin` | ✅ CORRECTOS |
| `medications` | Instancias en centros | `/inventario` | No aplica al problema |
| `medicamentos` | ❌ NO EXISTE | Ninguno | ❌ Nunca lo usé |

---

## 📋 PRÓXIMOS PASOS

1. **Ejecuta los queries de verificación** (PASO 1, 2, 3 de arriba)
2. **Copia los resultados exactos** y envíamelos
3. Si hay error, **copia el mensaje completo**
4. Confirmaré si necesitas ejecutar mis scripts o hay otro problema

---

**¿Ejecutaste mis scripts (`APLICAR_POLITICAS_RLS_GARANTIZADO.sql`) o ejecutaste otro query?** Necesito saber para ayudarte correctamente.
