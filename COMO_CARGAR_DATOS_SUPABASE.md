# 📦 Cómo Cargar Datos de Medicamentos en Supabase

## 🎯 Objetivo

Este documento explica cómo ejecutar el script de carga de datos `CARGA_MEDICAMENTOS_COMPLETA.sql` en tu base de datos de Supabase para poblar el sistema SIGIMED con datos reales de medicamentos.

---

## 📋 Prerrequisitos

✅ Cuenta activa en Supabase
✅ Proyecto SIGIMED creado en Supabase
✅ Schema de base de datos creado (migraciones ejecutadas)
✅ Acceso al SQL Editor de Supabase

---

## 🚀 Pasos para Ejecutar el Script

### Paso 1: Acceder a Supabase SQL Editor

1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto SIGIMED
4. En el menú lateral izquierdo, busca **"SQL Editor"** (icono <>)
5. Haz clic en **"SQL Editor"**

---

### Paso 2: Verificar que las Migraciones Estén Ejecutadas

Antes de cargar datos, asegúrate de que las tablas existan:

```sql
-- Ejecuta esta consulta primero
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'health_centers',
    'suppliers',
    'medication_catalog',
    'medications',
    'batches',
    'batch_movements',
    'contracts',
    'contract_items',
    'users_profiles'
  )
ORDER BY table_name;
```

**Resultado esperado:** Deberías ver las 9 tablas listadas.

Si NO ves las tablas, primero ejecuta las migraciones en orden:

```bash
# Orden de ejecución de migraciones:
1. migrations/01_crear_tablas_core.sql
2. migrations/02_insertar_datos_iniciales.sql
3. migrations/03_funciones_y_triggers.sql
4. migrations/04_sistema_permisos_rls.sql
5. migrations/05_control_calidad.sql
6. migrations/06_modulo_contratos.sql
7. migrations/07_gestion_documental.sql
8. migrations/08_testing_reportes.sql
```

---

### Paso 3: Abrir el Script de Carga

Hay **3 opciones** para ejecutar el script:

#### Opción A: Copiar y Pegar (MÁS FÁCIL)

1. Abre el archivo `CARGA_MEDICAMENTOS_COMPLETA.sql` desde tu repositorio local
2. Copia **TODO** el contenido del archivo (Ctrl+A, Ctrl+C)
3. En Supabase SQL Editor:
   - Haz clic en **"New Query"** (Nueva consulta)
   - Pega el contenido copiado (Ctrl+V)
   - Haz clic en **"Run"** (Ejecutar) o presiona **Ctrl+Enter**

#### Opción B: Desde GitHub (Si ya subiste los archivos)

1. Ve a tu repositorio en GitHub
2. Navega a `CARGA_MEDICAMENTOS_COMPLETA.sql`
3. Haz clic en el botón **"Raw"**
4. Copia todo el contenido
5. Pégalo en Supabase SQL Editor
6. Ejecuta

#### Opción C: Subir archivo (Si Supabase lo permite)

Algunas versiones de Supabase permiten cargar archivos SQL directamente. Si ves un botón de "Import" o "Upload", puedes usarlo.

---

### Paso 4: Ejecutar el Script

1. Una vez que el script esté en el editor, haz clic en **"Run"** (botón verde)
2. **IMPORTANTE:** La ejecución puede tomar **1-2 minutos** dependiendo del tamaño

**Verás mensajes como:**
```
====================================
CARGA CSV: Medicamentos + Lotes Reales
Contrato: CA-0158-2025
====================================
✅ Usuario del sistema creado
✅ Centro creado: Centro de Salud Urbano La Esperanza
✅ Proveedor creado: Distribuidora Farmacéutica Nacional S.A. de C.V.
✅ Contrato creado: CA-0158-2025
...
→ Procesados 5 medicamentos...
→ Procesados 10 medicamentos...
...
✅ CARGA COMPLETADA EXITOSAMENTE
====================================
Medicamentos cargados: 30
Lotes creados: 40
Stock total en unidades: 250000+
```

---

### Paso 5: Verificar la Carga

Después de ejecutar el script, verifica que los datos se cargaron correctamente:

```sql
-- 1. Verificar centro de salud
SELECT * FROM health_centers WHERE code = 'CS-URB-ESP-001';

-- 2. Verificar proveedor
SELECT * FROM suppliers WHERE rfc = 'DFN850101ABC';

-- 3. Verificar medicamentos en catálogo
SELECT COUNT(*) as total_medicamentos
FROM medication_catalog
WHERE codigo_medicamento LIKE '25310%';

-- 4. Verificar lotes creados
SELECT
  COUNT(*) as total_lotes,
  SUM(cantidad_actual) as stock_total
FROM batches;

-- 5. Ver detalle de medicamentos por ubicación
SELECT
  ubicacion_fisica,
  COUNT(*) as num_lotes,
  SUM(cantidad_actual) as stock
FROM batches
GROUP BY ubicacion_fisica
ORDER BY ubicacion_fisica;
```

**Resultado esperado:**
- ✅ 1 centro de salud
- ✅ 1 proveedor
- ✅ ~30 medicamentos en catálogo
- ✅ ~40 lotes
- ✅ ~250,000 unidades en stock total

---

## ⚠️ Troubleshooting (Solución de Problemas)

### Error: "there is no unique or exclusion constraint matching the ON CONFLICT specification"

**Problema:** Error en versión antigua del script que intentaba insertar en auth.users
**Solución:** ✅ **YA CORREGIDO** en la versión 2.0 del script. Asegúrate de usar la versión más reciente desde GitHub

### Error: "relation does not exist"

**Problema:** Las tablas no existen
**Solución:** Ejecuta primero todas las migraciones (Paso 2)

### Error: "duplicate key value violates unique constraint"

**Problema:** Los datos ya existen (script ejecutado anteriormente)
**Solución:** El script tiene `ON CONFLICT DO NOTHING`, así que es seguro. Si quieres empezar de cero:

```sql
-- ⚠️ CUIDADO: Esto BORRA todos los datos
BEGIN;
DELETE FROM batches;
DELETE FROM medications;
DELETE FROM medication_catalog WHERE codigo_medicamento LIKE '25310%';
DELETE FROM contracts WHERE codigo_contrato = 'CA-0158-2025';
DELETE FROM suppliers WHERE rfc = 'DFN850101ABC';
DELETE FROM health_centers WHERE code = 'CS-URB-ESP-001';
COMMIT;
```

Luego vuelve a ejecutar el script de carga.

### Error: "permission denied for table"

**Problema:** No tienes permisos para insertar datos
**Solución:** Asegúrate de estar conectado como propietario del proyecto en Supabase

### Error: "syntax error at or near"

**Problema:** El script no se copió completo
**Solución:** Vuelve a copiar TODO el script completo, desde `BEGIN;` hasta el final

---

## 📊 ¿Qué Datos Se Cargarán?

El script `CARGA_MEDICAMENTOS_COMPLETA.sql` carga:

| Componente | Cantidad | Descripción |
|------------|----------|-------------|
| **Centro de Salud** | 1 | Centro de Salud Urbano La Esperanza |
| **Proveedor** | 1 | Distribuidora Farmacéutica Nacional S.A. |
| **Contrato** | 1 | CA-0158-2025 (vigente 2025) |
| **Medicamentos** | ~30 | Medicamentos comunes (Paracetamol, Ibuprofeno, Amoxicilina, etc.) |
| **Lotes** | ~40 | Lotes con fechas de caducidad reales |
| **Stock Total** | ~250,000 | Unidades distribuidas en ~40 lotes |

### Medicamentos Incluidos (Muestra)

- Antibióticos: Amoxicilina, Ampicilina, Azitromicina, Ciprofloxacino
- Analgésicos: Paracetamol, Ibuprofeno, Diclofenaco
- Antihipertensivos: Losartán, Captopril, Enalapril
- Antidiabéticos: Metformina, Glibenclamida
- Antiácidos: Omeprazol, Ranitidina
- Broncodilatadores: Salbutamol
- Otros: Atorvastatina, Furosemida, Levotiroxina, etc.

---

## 🔄 Ejecutar Script Nuevamente

Si necesitas volver a ejecutar el script (por ejemplo, para agregar más stock):

1. El script tiene protecciones `ON CONFLICT DO NOTHING`
2. No duplicará centros, proveedores ni medicamentos existentes
3. Agregará nuevos lotes si los números de lote son diferentes

---

## 📱 Verificar en la Aplicación

Después de cargar los datos:

1. Abre tu aplicación SIGIMED
2. Inicia sesión
3. Ve al módulo de **Inventario**
4. Deberías ver todos los medicamentos cargados
5. Ve al módulo de **Dashboard** para ver estadísticas

---

## 🆘 Soporte

Si encuentras problemas:

1. **Revisa los mensajes de error** en Supabase SQL Editor
2. **Verifica que las migraciones** estén ejecutadas (Paso 2)
3. **Consulta el archivo** `BASE_DE_DATOS.md` para entender el schema
4. **Revisa el código del script** en `CARGA_MEDICAMENTOS_COMPLETA.sql`

---

## 📌 Notas Importantes

⚠️ **Row Level Security (RLS):** Asegúrate de que las políticas RLS estén configuradas correctamente, o temporalmente desactívalas para la carga inicial:

```sql
-- Desactivar RLS temporalmente (solo para carga inicial)
ALTER TABLE medication_catalog DISABLE ROW LEVEL SECURITY;
ALTER TABLE medications DISABLE ROW LEVEL SECURITY;
ALTER TABLE batches DISABLE ROW LEVEL SECURITY;
ALTER TABLE batch_movements DISABLE ROW LEVEL SECURITY;

-- ... ejecutar script de carga ...

-- Reactivar RLS después de la carga
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_movements ENABLE ROW LEVEL SECURITY;
```

---

## ✅ Checklist de Ejecución

- [ ] Accedí a Supabase SQL Editor
- [ ] Verifiqué que las tablas existen
- [ ] Copié el script completo `CARGA_MEDICAMENTOS_COMPLETA.sql`
- [ ] Pegué el script en SQL Editor
- [ ] Ejecuté el script con "Run"
- [ ] Vi los mensajes de éxito
- [ ] Verifiqué los datos con las consultas de verificación
- [ ] Los datos aparecen en la aplicación SIGIMED

---

**¡Listo! Tu base de datos ahora tiene datos reales de medicamentos para trabajar.** 🎉
