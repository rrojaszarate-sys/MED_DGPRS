# 🚀 Instrucciones para Ejecutar Fase 1

## Opción A: Usando Supabase SQL Editor (RECOMENDADO)

### Pasos:

1. **Abre el SQL Editor de Supabase:**
   ```
   https://cyslhzynfuetthxngpoy.supabase.co/project/_/sql/new
   ```

2. **Copia el contenido completo del archivo:**
   ```
   EJECUTAR_FASE_1_COMPLETA.sql
   ```

3. **Pega el contenido en el editor**

4. **Click en "Run" o presiona Ctrl+Enter**

5. **Verifica los resultados:**
   - Deberías ver: "✅ FASE 1 COMPLETADA"
   - Lista de 10 tablas creadas
   - Conteo de índices creados

---

## Opción B: Usando psql desde terminal

Si tienes la contraseña de PostgreSQL:

```bash
# Formato de conexión
psql "postgresql://postgres:[TU_PASSWORD]@db.cyslhzynfuetthxngpoy.supabase.co:5432/postgres" \
  -f EJECUTAR_FASE_1_COMPLETA.sql
```

### ¿Dónde encontrar la contraseña?

1. Ve a: https://cyslhzynfuetthxngpoy.supabase.co/project/_/settings/database
2. Busca "Database Password" o "Connection String"
3. Copia la contraseña

---

## Verificación Post-Ejecución

Ejecuta esta query para verificar:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'suppliers', 'batches', 'batch_movements',
    'user_centers', 'audit_log', 'instituciones',
    'contracts', 'contract_items',
    'storage_inspections', 'documentos_comprobantes'
  )
ORDER BY table_name;
```

Deberías ver **10 tablas**.

---

## ✅ Resultado Esperado

```
tabla_creada              | estado
--------------------------+--------
audit_log                 | OK
batch_movements           | OK
batches                   | OK
contract_items            | OK
contracts                 | OK
documentos_comprobantes   | OK
instituciones             | OK
storage_inspections       | OK
suppliers                 | OK
user_centers              | OK
```

**Total: 10 tablas + 31 índices**

---

## 🆘 Si encuentras errores

Avísame y te ayudo a resolverlos. Errores comunes:

- **"relation already exists"**: Normal, el script usa `IF NOT EXISTS`
- **"permission denied"**: Asegúrate de estar usando el SQL Editor de Supabase
- **"syntax error"**: Verifica que copiaste TODO el contenido del archivo

---

**Una vez ejecutado, avísame para continuar con la Fase 1.4 (insertar datos iniciales).**
