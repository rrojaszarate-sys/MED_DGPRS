# INSTRUCCIONES URGENTES - Corregir Catálogo de Medicamentos

## Problema Detectado

El catálogo de medicamentos no se muestra porque:

1. **RLS (Row Level Security) está habilitado** en la tabla `medication_catalog`
2. **NO hay políticas** que permitan leer los datos
3. **Resultado:** Las consultas retornan vacío aunque haya datos

## Solución Inmediata

### Opción 1: Ejecutar migración completa (RECOMENDADO)

1. Ir a **Supabase Dashboard** → Tu proyecto
2. Ir a **SQL Editor**
3. Copiar y pegar el contenido del archivo: `migrations/09_fix_medication_catalog_rls.sql`
4. Click en **Run**

### Opción 2: Ejecutar solo las políticas RLS (Rápido)

Si la estructura de la tabla ya es correcta, ejecuta solo esto en SQL Editor:

```sql
-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Catalog readable by all authenticated" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog readable by anon" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog insertable by admins" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog updatable by admins" ON medication_catalog;
DROP POLICY IF EXISTS "Catalog deletable by super admins" ON medication_catalog;

-- Habilitar RLS
ALTER TABLE medication_catalog ENABLE ROW LEVEL SECURITY;

-- Crear políticas
CREATE POLICY "Catalog readable by all authenticated"
ON medication_catalog FOR SELECT TO authenticated USING (true);

CREATE POLICY "Catalog readable by anon"
ON medication_catalog FOR SELECT TO anon USING (is_active = true);

CREATE POLICY "Catalog insertable by admins"
ON medication_catalog FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')));

CREATE POLICY "Catalog updatable by admins"
ON medication_catalog FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid() AND role IN ('super_admin', 'admin_center')));

CREATE POLICY "Catalog deletable by super admins"
ON medication_catalog FOR DELETE TO authenticated
USING (EXISTS (SELECT 1 FROM users_profiles WHERE id = auth.uid() AND role = 'super_admin'));
```

### Opción 3: Deshabilitar RLS temporalmente (Solo para testing)

```sql
ALTER TABLE medication_catalog DISABLE ROW LEVEL SECURITY;
```

**ADVERTENCIA:** Esto permite acceso sin restricciones. Solo usar para diagnóstico.

## Verificar que funcionó

Después de aplicar la solución, ejecuta esta consulta en SQL Editor:

```sql
-- Verificar políticas
SELECT * FROM pg_policies WHERE tablename = 'medication_catalog';

-- Verificar datos
SELECT COUNT(*) FROM medication_catalog;

-- Ver algunos registros
SELECT codigo_medicamento, nombre_generico, is_active
FROM medication_catalog
LIMIT 5;
```

## Si la tabla tiene estructura incorrecta

La tabla `medication_catalog` debe tener estas columnas:

| Columna | Tipo | Requerido |
|---------|------|-----------|
| id | UUID | Sí |
| codigo_medicamento | TEXT | Sí |
| nombre_generico | TEXT | Sí |
| nombre_comercial | TEXT | No |
| principio_activo | TEXT | No |
| forma_farmaceutica | TEXT | No |
| via_administracion | TEXT | No |
| concentracion | TEXT | No |
| unidad_medida | TEXT | No |
| categoria | TEXT | No |
| requiere_receta | BOOLEAN | No (default false) |
| controlado | BOOLEAN | No (default false) |
| temperatura_almacenamiento | TEXT | No |
| observaciones | TEXT | No |
| is_active | BOOLEAN | No (default true) |
| created_at | TIMESTAMPTZ | No |
| updated_at | TIMESTAMPTZ | No |

Si faltan columnas, ejecuta la migración completa: `migrations/09_fix_medication_catalog_rls.sql`

## Contacto

Si el problema persiste, verifica:

1. Las credenciales de Supabase en Vercel (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`)
2. Que el usuario esté autenticado correctamente
3. Los logs de la consola del navegador (F12 → Console)
