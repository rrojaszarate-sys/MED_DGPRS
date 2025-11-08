# 🚀 EJECUCIÓN MANUAL - FASE 1 COMPLETA

## ⚡ Método Más Rápido (2 minutos)

### Opción A: Copiar/Pegar en Supabase SQL Editor

1. **Abre el SQL Editor:**
   ```
   https://cyslhzynfuetthxngpoy.supabase.co/project/_/sql/new
   ```

2. **Abre el archivo en tu editor:**
   ```
   FASE_1_COMPLETA_ALL_IN_ONE.sql
   ```

3. **Selecciona TODO (Ctrl+A) → Copia (Ctrl+C)**

4. **Pega en Supabase SQL Editor (Ctrl+V)**

5. **Click en "Run" o presiona Ctrl+Enter**

6. **Espera 10-30 segundos**

7. **Verifica el resultado:**
   Deberías ver:
   ```
   🎉 FASE 1 COMPLETADA EXITOSAMENTE

   TABLAS: 10
   ÍNDICES: 31
   FUNCIONES: 4
   TRIGGERS: 2
   ```

---

## 🔧 Opción B: Desde Terminal (si tienes psql)

Si conoces la contraseña de PostgreSQL de tu proyecto Supabase:

```bash
psql "postgresql://postgres:[TU_PASSWORD]@db.cyslhzynfuetthxngpoy.supabase.co:5432/postgres" \
  -f FASE_1_COMPLETA_ALL_IN_ONE.sql
```

**¿Dónde encontrar la contraseña?**
1. Ve a: https://cyslhzynfuetthxngpoy.supabase.co/project/_/settings/database
2. Sección "Database Password"
3. Click en "Reset Database Password" si no la recuerdas

---

## 📋 Verificación Post-Ejecución

Después de ejecutar, verifica con esta query:

```sql
SELECT
  table_name,
  'OK' as estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'suppliers', 'batches', 'batch_movements',
    'user_centers', 'audit_log', 'instituciones',
    'contracts', 'contract_items', 'storage_inspections',
    'documentos_comprobantes'
  )
ORDER BY table_name;
```

Deberías ver **10 tablas**.

---

## ❌ Si hay errores

### Error: "relation already exists"
✅ **Normal** - El script usa `IF NOT EXISTS`, es seguro volver a ejecutarlo

### Error: "permission denied"
❌ Asegúrate de estar en el **SQL Editor de Supabase** (no en otro cliente)

### Error: "syntax error at or near..."
❌ Verifica que copiaste **TODO** el contenido del archivo (622 líneas completas)

---

## 📞 Después de Ejecutar

**Avísame cuando hayas ejecutado el script** para que yo pueda:
1. ✅ Verificar que todo se creó correctamente
2. ✅ Continuar con la Fase 2 (Permisos y RLS)
3. ✅ Seguir con el resto del plan maestro

---

## 📦 Archivos Importantes

- **`FASE_1_COMPLETA_ALL_IN_ONE.sql`** ← Este es el que debes ejecutar
- `PLAN_MAESTRO_IMPLEMENTACION.md` ← Plan completo de 6 fases
- `migrations/01_crear_tablas_core.sql` ← Script individual (opcional)
- `migrations/02_insertar_datos_iniciales.sql` ← Script individual (opcional)
- `migrations/03_funciones_y_triggers.sql` ← Script individual (opcional)

**Recomendación:** Usa el archivo `FASE_1_COMPLETA_ALL_IN_ONE.sql` que incluye todo en un solo paso.
