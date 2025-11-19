# 🚀 Instrucciones para Poblar la Base de Datos

## Script Único: `POBLAR_BASE_DATOS_COMPLETA.sql`

Este script **único** puebla toda la base de datos con datos de prueba realistas en una sola ejecución.

---

## ¿Qué Genera el Script?

✅ **6 Centros de Salud** (hospitales y clínicas)
✅ **5 Proveedores** de medicamentos
✅ **8 Instituciones** del sector salud (IMSS, ISSSTE, SSA, etc.)
✅ **30+ Medicamentos** en el catálogo maestro
✅ **200+ Items** de inventario (1-4 lotes por medicamento por centro)
✅ **10+ Usuarios** con diferentes roles (super admin, admin center, inventory user, read only)
✅ **20 Requisiciones** internas
✅ **15 Transferencias** entre centros
✅ **Alertas automáticas** de medicamentos próximos a vencer
✅ **Movimientos de entrada** registrados automáticamente

---

## 📋 Opción 1: Supabase Dashboard (Más Fácil)

### Paso 1: Acceder al SQL Editor

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. En el menú lateral, haz clic en **"SQL Editor"**

### Paso 2: Copiar y Pegar el Script

1. Abre el archivo `scripts/POBLAR_BASE_DATOS_COMPLETA.sql`
2. **Copia TODO el contenido** del archivo
3. **Pégalo** en el SQL Editor de Supabase
4. Haz clic en **"Run"** (botón verde en la esquina inferior derecha)

### Paso 3: Esperar Ejecución

- El script tomará aproximadamente **1-2 minutos**
- Verás mensajes de progreso en la consola
- Al final verás un **RESUMEN** con las estadísticas

### Paso 4: Verificar Resultados

```sql
-- Verificar centros
SELECT COUNT(*) FROM health_centers;

-- Verificar inventario
SELECT COUNT(*) FROM medications;

-- Verificar usuarios
SELECT COUNT(*) FROM users_profiles;

-- Verificar alertas
SELECT COUNT(*) FROM alertas_medicamentos;
```

---

## 📋 Opción 2: Supabase CLI (Línea de Comandos)

### Prerequisito: Instalar Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Windows (PowerShell)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Linux
brew install supabase/tap/supabase
```

### Ejecutar el Script

```bash
# Navegar al directorio del proyecto
cd /home/user/MED_DGPRS

# Ejecutar el script
supabase db execute --file scripts/POBLAR_BASE_DATOS_COMPLETA.sql

# O si estás logueado en un proyecto específico
supabase db execute --file scripts/POBLAR_BASE_DATOS_COMPLETA.sql --project-ref tu-project-ref
```

---

## 📋 Opción 3: psql (PostgreSQL directo)

### Prerequisito: Tener psql instalado

```bash
# Verificar si tienes psql
psql --version
```

### Obtener URL de Conexión

1. Ve a Supabase Dashboard
2. Settings → Database
3. Copia la **Connection String** (URI)
4. Reemplaza `[YOUR-PASSWORD]` con tu contraseña

### Ejecutar el Script

```bash
# Opción A: Variable de entorno
export DATABASE_URL="postgresql://postgres:[TU-PASSWORD]@db.xyz.supabase.co:5432/postgres"
psql $DATABASE_URL -f scripts/POBLAR_BASE_DATOS_COMPLETA.sql

# Opción B: Directamente
psql "postgresql://postgres:[TU-PASSWORD]@db.xyz.supabase.co:5432/postgres" \
  -f scripts/POBLAR_BASE_DATOS_COMPLETA.sql
```

---

## 🔐 IMPORTANTE: Crear Usuarios en Supabase Auth

El script crea los **perfiles** de usuario, pero las **credenciales de autenticación** deben crearse manualmente en Supabase.

### Opción A: Desde Supabase Dashboard

1. Ve a **Authentication → Users**
2. Haz clic en **"Add User"**
3. Para cada usuario, crear con:

| Email | Contraseña | Autoconfirmar |
|-------|------------|---------------|
| superadmin@sigimed.test | Test123! | ✅ Sí |
| admin.hgm@sigimed.test | Test123! | ✅ Sí |
| admin.hraei@sigimed.test | Test123! | ✅ Sí |
| inventario1@sigimed.test | Test123! | ✅ Sí |
| inventario2@sigimed.test | Test123! | ✅ Sí |
| inventario3@sigimed.test | Test123! | ✅ Sí |
| inventario4@sigimed.test | Test123! | ✅ Sí |
| inventario5@sigimed.test | Test123! | ✅ Sí |
| readonly1@sigimed.test | Test123! | ✅ Sí |
| readonly2@sigimed.test | Test123! | ✅ Sí |
| readonly3@sigimed.test | Test123! | ✅ Sí |

### Opción B: Desde la Aplicación

Simplemente **registra cada usuario** desde la interfaz de registro de tu aplicación.
- El trigger automático `handle_new_user()` creará el perfil en `users_profiles`

---

## ✅ Verificación Post-Ejecución

### Consultas SQL para Verificar

```sql
-- 1. Centros de salud (debe ser 6)
SELECT code, name, city FROM health_centers ORDER BY code;

-- 2. Proveedores (debe ser 5)
SELECT name, ruc, rating FROM suppliers;

-- 3. Medicamentos en catálogo (debe ser 30+)
SELECT COUNT(*) as total_medicamentos FROM medication_catalog WHERE is_active = true;

-- 4. Inventario por centro
SELECT
    h.code,
    h.name,
    COUNT(m.id) as total_items,
    SUM(m.cantidad) as stock_total
FROM health_centers h
LEFT JOIN medications m ON m.center_id = h.id
GROUP BY h.id, h.code, h.name
ORDER BY h.code;

-- 5. Usuarios por rol
SELECT role, COUNT(*) as total
FROM users_profiles
GROUP BY role
ORDER BY role;

-- 6. Requisiciones por estado
SELECT status, COUNT(*) as total
FROM requisitions
GROUP BY status
ORDER BY status;

-- 7. Transferencias por estado
SELECT status, COUNT(*) as total
FROM transfers
GROUP BY status
ORDER BY status;

-- 8. Alertas por nivel
SELECT nivel_alerta, COUNT(*) as total
FROM alertas_medicamentos
WHERE NOT resuelta
GROUP BY nivel_alerta
ORDER BY
    CASE nivel_alerta
        WHEN 'critico' THEN 1
        WHEN 'urgente' THEN 2
        WHEN 'preventivo' THEN 3
    END;

-- 9. Medicamentos próximos a vencer (top 10)
SELECT
    m.nombre,
    m.lote,
    m.fecha_caducidad,
    m.cantidad,
    h.name as centro,
    (m.fecha_caducidad - CURRENT_DATE) as dias_restantes
FROM medications m
JOIN health_centers h ON m.center_id = h.id
WHERE m.fecha_caducidad > CURRENT_DATE
ORDER BY m.fecha_caducidad
LIMIT 10;

-- 10. Resumen general
SELECT
    (SELECT COUNT(*) FROM health_centers WHERE is_active = true) as centros,
    (SELECT COUNT(*) FROM suppliers WHERE is_active = true) as proveedores,
    (SELECT COUNT(*) FROM medication_catalog WHERE is_active = true) as medicamentos_catalogo,
    (SELECT COUNT(*) FROM medications) as items_inventario,
    (SELECT SUM(cantidad) FROM medications WHERE estado = 'Disponible') as stock_total,
    (SELECT COUNT(*) FROM users_profiles) as usuarios,
    (SELECT COUNT(*) FROM requisitions) as requisiciones,
    (SELECT COUNT(*) FROM transfers) as transferencias,
    (SELECT COUNT(*) FROM alertas_medicamentos WHERE NOT resuelta) as alertas_activas;
```

### Resultado Esperado

Deberías ver algo como:

```
centros: 6
proveedores: 5
medicamentos_catalogo: 30
items_inventario: 200+
stock_total: 30000+
usuarios: 11
requisiciones: 20
transferencias: 15
alertas_activas: 10-50
```

---

## 🔄 Si Necesitas Resetear

Si algo salió mal y quieres volver a ejecutar el script:

```sql
-- CUIDADO: Esto borrará todos los datos de prueba

BEGIN;

-- Deshabilitar triggers temporalmente
SET session_replication_role = 'replica';

-- Limpiar datos
TRUNCATE medications CASCADE;
TRUNCATE batch_movements CASCADE;
TRUNCATE requisitions CASCADE;
TRUNCATE requisition_items CASCADE;
TRUNCATE transfers CASCADE;
TRUNCATE transfer_items CASCADE;
TRUNCATE inventory_adjustments CASCADE;
TRUNCATE alertas_medicamentos CASCADE;
TRUNCATE audit_log CASCADE;
TRUNCATE users_profiles CASCADE;
TRUNCATE health_centers CASCADE;
TRUNCATE suppliers CASCADE;
TRUNCATE medication_catalog CASCADE;
TRUNCATE instituciones CASCADE;

-- Rehabilitar triggers
SET session_replication_role = 'origin';

COMMIT;

-- Ahora vuelve a ejecutar POBLAR_BASE_DATOS_COMPLETA.sql
```

---

## 📊 Datos Generados

### Centros de Salud

| Código | Nombre | Ciudad |
|--------|--------|--------|
| HG-001 | Hospital General Dr. Manuel Gea González | Ciudad de México |
| HRAE-002 | Hospital Regional de Alta Especialidad de Ixtapaluca | Ixtapaluca |
| CS-003 | Centro de Salud T-III Balbuena | Ciudad de México |
| HMI-004 | Hospital Materno Infantil de Tlaxcala | Tlaxcala |
| HC-005 | Hospital Comunitario de Tepoztlán | Tepoztlán |
| UNEME-006 | UNEME Enfermedades Crónicas Guadalajara | Guadalajara |

### Usuarios de Prueba

| Email | Contraseña | Rol |
|-------|------------|-----|
| superadmin@sigimed.test | Test123! | Super Admin |
| admin.hgm@sigimed.test | Test123! | Admin Centro (HG-001) |
| admin.hraei@sigimed.test | Test123! | Admin Centro (HRAE-002) |
| inventario1-5@sigimed.test | Test123! | Usuario Inventario |
| readonly1-3@sigimed.test | Test123! | Solo Lectura |

### Medicamentos (Ejemplos)

- **Antibióticos:** Amoxicilina, Ciprofloxacino, Azitromicina, Ceftriaxona
- **Analgésicos:** Paracetamol, Ibuprofeno, Ketorolaco, Diclofenaco
- **Antihipertensivos:** Losartán, Enalapril, Amlodipino
- **Antidiabéticos:** Metformina, Glibenclamida
- **Insulinas:** NPH, Rápida (con refrigeración)
- Y más... (30+ en total)

---

## 🎯 Próximos Pasos

Una vez que la base de datos esté poblada:

1. ✅ **Crear usuarios en Supabase Auth** (ver sección arriba)
2. ✅ **Iniciar sesión** en la aplicación con `superadmin@sigimed.test`
3. ✅ **Explorar el Dashboard** y verificar que se muestran datos
4. ✅ **Revisar Inventario** en cada centro
5. ✅ **Verificar Alertas** de medicamentos próximos a vencer
6. ✅ **Probar Requisiciones** y Transferencias
7. ✅ **Ejecutar Pruebas Automatizadas** (script `03_pruebas_automatizadas.sql`)

---

## 🆘 Solución de Problemas

### Error: "permission denied for table"

**Solución:** Tu usuario de base de datos necesita permisos. Contacta al administrador o ejecuta desde el SQL Editor de Supabase Dashboard.

### Error: "function generar_alertas_caducidad does not exist"

**Solución:** Primero ejecuta las migraciones:
```bash
supabase db execute --file migrations/03_funciones_y_triggers.sql
```

### Error: "duplicate key value violates unique constraint"

**Solución:** Los datos ya existen. Ejecuta el script de limpieza (ver sección "Si Necesitas Resetear") antes de volver a ejecutar.

### Los usuarios no pueden hacer login

**Solución:** Debes crear los usuarios en Supabase Auth. El script SQL solo crea los perfiles, no las credenciales de autenticación.

---

## 📞 Soporte

Si tienes problemas, revisa:

1. 📄 **Documentación completa:** `docs/README_DATOS_PRUEBA.md`
2. 📋 **Plan de pruebas:** `docs/PLAN_PRUEBAS_ESCRITORIO.md`
3. 🎯 **Resumen ejecutivo:** `docs/RESUMEN_EJECUTIVO_PRUEBAS.md`

---

## ⏱️ Tiempo de Ejecución

- **Script completo:** 1-2 minutos
- **Crear usuarios en Auth:** 2-3 minutos
- **Verificación:** 1-2 minutos
- **Total:** ~5 minutos

---

**¡Listo! Tu base de datos estará completamente poblada y lista para pruebas. 🎉**
