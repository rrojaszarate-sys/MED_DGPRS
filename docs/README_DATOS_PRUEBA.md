# Generación de Datos de Prueba - SIGIMED v2.0

## Descripción

Este paquete contiene scripts y documentación para generar datos de prueba completos, ejecutar pruebas automatizadas y validar el sistema SIGIMED v2.0.

## Contenido del Paquete

### Scripts SQL

```
scripts/
├── 00_ejecutar_todo.sh                      # Script maestro de ejecución
├── 01_generar_inventario_aleatorio.sql      # Genera inventario para todos los centros
├── 02_generar_datos_completos.sql           # Genera usuarios, órdenes, transferencias, etc.
└── 03_pruebas_automatizadas.sql             # Suite de pruebas automatizadas
```

### Documentación

```
docs/
├── README_DATOS_PRUEBA.md                   # Este archivo
├── PLAN_PRUEBAS_ESCRITORIO.md               # Plan de pruebas internas
└── DOCUMENTO_VALIDACION_EXTERNA.md          # Documento para equipo de QA externo
```

---

## Guía de Uso Rápido

### Opción 1: Ejecución Automática (Recomendado)

```bash
# Dar permisos de ejecución al script
chmod +x scripts/00_ejecutar_todo.sh

# Ejecutar el menú interactivo
./scripts/00_ejecutar_todo.sh
```

El script mostrará un menú con las siguientes opciones:
1. Generar SOLO inventario aleatorio
2. Generar datos completos (inventario + usuarios + órdenes)
3. Ejecutar pruebas automatizadas
4. Ejecutar TODO (datos + pruebas)
5. Limpiar base de datos
6. Salir

### Opción 2: Ejecución Manual con Supabase CLI

```bash
# Asegúrate de tener configurado Supabase CLI
supabase login

# Ejecutar scripts en orden
supabase db execute --file scripts/01_generar_inventario_aleatorio.sql
supabase db execute --file scripts/02_generar_datos_completos.sql
supabase db execute --file scripts/03_pruebas_automatizadas.sql
```

### Opción 3: Ejecución Manual con psql

```bash
# Conectar a tu base de datos
# Opción A: Variable de entorno
export DATABASE_URL="postgresql://user:password@host:port/database"

# Ejecutar scripts
psql $DATABASE_URL -f scripts/01_generar_inventario_aleatorio.sql
psql $DATABASE_URL -f scripts/02_generar_datos_completos.sql
psql $DATABASE_URL -f scripts/03_pruebas_automatizadas.sql
```

---

## Descripción Detallada de Scripts

### 1. Generación de Inventario Aleatorio

**Archivo:** `01_generar_inventario_aleatorio.sql`

**Qué hace:**
- Crea 6 centros de salud si no existen
- Genera un catálogo maestro de 30+ medicamentos
- Crea 5 proveedores
- Genera inventario aleatorio para cada centro (200+ items)
- Registra movimientos de entrada inicial
- Genera alertas de caducidad automáticas

**Datos generados:**
- 6 centros de salud activos
- 30+ medicamentos en el catálogo
- 5 proveedores
- 1-4 lotes por medicamento por centro
- Cantidades aleatorias entre 10 y 500
- Fechas de caducidad entre 1 mes y 24 meses futuros
- Alertas automáticas de medicamentos próximos a vencer

**Tiempo de ejecución:** ~30-60 segundos

**Salida esperada:**
```
==================================================
RESUMEN DE GENERACIÓN DE INVENTARIO
==================================================
Centros de salud activos: 6
Medicamentos diferentes: 30
Total de items en inventario: 200+
Stock total disponible: XXXXX unidades
Alertas activas: XX
==================================================
```

---

### 2. Generación de Datos Completos

**Archivo:** `02_generar_datos_completos.sql`

**Qué hace:**
- Crea instituciones del sector salud (IMSS, ISSSTE, SSA, etc.)
- Genera usuarios de prueba con diferentes roles
- Crea requisiciones internas de ejemplo
- Genera transferencias entre centros
- Crea ajustes de inventario
- Registra movimientos adicionales de stock
- Genera contratos con proveedores
- Refresca vistas materializadas

**Datos generados:**
- 8 instituciones del sector salud
- 10+ usuarios (super admin, admin center, inventory user, read only)
- 20 requisiciones en diferentes estados
- 15 transferencias entre centros
- 25 ajustes de inventario
- 50 movimientos adicionales de stock
- 10 contratos con proveedores

**Usuarios creados:**

| Email | Contraseña | Rol |
|-------|------------|-----|
| superadmin@sigimed.test | Test123! | super_admin |
| admin.hgm@sigimed.test | Test123! | admin_center (HG-001) |
| admin.hraei@sigimed.test | Test123! | admin_center (HRAE-002) |
| inventario1-5@sigimed.test | Test123! | inventory_user |
| readonly1-3@sigimed.test | Test123! | read_only |

**IMPORTANTE:** Estos usuarios deben ser creados manualmente en Supabase Auth si no existen. El script solo crea los perfiles.

**Tiempo de ejecución:** ~45-90 segundos

**Salida esperada:**
```
==================================================
RESUMEN DE DATOS COMPLETOS GENERADOS
==================================================
Instituciones: 8
Usuarios: 10+
Requisiciones: 20
Transferencias: 15
Ajustes de inventario: 25
Movimientos de stock: 50+
Contratos: 10
==================================================
```

---

### 3. Pruebas Automatizadas

**Archivo:** `03_pruebas_automatizadas.sql`

**Qué hace:**
- Crea tabla `test_results` para almacenar resultados
- Ejecuta 20+ pruebas automatizadas en 5 categorías:
  1. Estructura de Base de Datos
  2. Integridad de Datos
  3. Funcionalidad de Negocio
  4. Rendimiento
  5. Seguridad y Permisos
- Genera reporte de resultados

**Categorías de Pruebas:**

**1. Estructura de DB (3 pruebas):**
- ✅ Verificar tablas principales
- ✅ Verificar índices críticos
- ✅ Verificar funciones críticas

**2. Integridad de Datos (4 pruebas):**
- ✅ Cantidad no negativa
- ✅ Integridad referencial catálogo
- ✅ Códigos únicos de centros
- ✅ Fechas de caducidad válidas

**3. Funcionalidad (3 pruebas):**
- ✅ Generación de alertas
- ✅ Registro de movimientos
- ✅ Niveles de alerta correctos

**4. Rendimiento (2 pruebas):**
- ✅ Consulta inventario completo
- ✅ Búsqueda por lote

**5. Seguridad (2 pruebas):**
- ✅ RLS habilitado
- ✅ Roles de usuario

**Tiempo de ejecución:** ~10-20 segundos

**Salida esperada:**
```
==================================================
RESUMEN DE PRUEBAS AUTOMATIZADAS
==================================================
Total de pruebas: 14+
Exitosas (PASSED): XX (XX.XX%)
Fallidas (FAILED): X
Errores (ERROR): X
==================================================
✓ TODAS LAS PRUEBAS PASARON EXITOSAMENTE
==================================================
```

**Ver resultados:**
```sql
-- Ver todas las pruebas
SELECT * FROM test_results ORDER BY test_category, test_name;

-- Ver solo las fallidas
SELECT * FROM test_results WHERE status IN ('FAILED', 'ERROR');

-- Resumen por categoría
SELECT
    test_category,
    status,
    COUNT(*) as total
FROM test_results
GROUP BY test_category, status
ORDER BY test_category;
```

---

## Usuarios de Prueba

### Creación Manual en Supabase

Los scripts SQL crean perfiles de usuario, pero las credenciales de autenticación deben crearse manualmente en Supabase:

**Método 1: Desde Supabase Dashboard**
1. Ir a Authentication → Users
2. Crear cada usuario con:
   - Email del usuario (ej: superadmin@sigimed.test)
   - Contraseña: Test123!
   - Confirmar email automáticamente

**Método 2: Desde Supabase SQL Editor**
```sql
-- Ejemplo para crear usuario
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at
)
VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'superadmin@sigimed.test',
    crypt('Test123!', gen_salt('bf')),
    now(),
    now(),
    now()
);
```

**Método 3: Desde la aplicación (Registro)**
- Simplemente registrar cada usuario desde la interfaz
- El trigger automático creará el perfil en `users_profiles`

---

## Pruebas de Escritorio

**Documento:** `docs/PLAN_PRUEBAS_ESCRITORIO.md`

Este documento contiene un plan detallado de 42 pruebas manuales para ejecutar internamente antes de la validación externa.

**Incluye:**
- 15 módulos a probar
- Pasos detallados para cada prueba
- Resultados esperados
- Formato de registro de resultados
- Plantilla de defectos

**Cómo usar:**
1. Abrir el documento `PLAN_PRUEBAS_ESCRITORIO.md`
2. Ejecutar cada prueba siguiendo los pasos
3. Marcar resultado: [ ] Pasó [ ] Falló [ ] No Ejecutado
4. Anotar observaciones en cada prueba
5. Completar resumen al final

**Módulos incluidos:**
1. Autenticación y Usuarios
2. Dashboard
3. Centros de Salud
4. Catálogo de Medicamentos
5. Inventario
6. Lotes
7. Movimientos
8. Alertas
9. Requisiciones
10. Transferencias
11. Proveedores
12. Contratos
13. Ajustes
14. Auditoría
15. Reportes

---

## Validación Externa

**Documento:** `docs/DOCUMENTO_VALIDACION_EXTERNA.md`

Este es el documento que debe entregarse al equipo de QA externo para validación formal.

**Incluye:**
- Información completa del sistema
- Credenciales de acceso
- 20+ casos de prueba detallados
- Criterios de aceptación
- Formato de reporte de defectos
- Anexos con datos de prueba

**Categorías de pruebas:**
1. Funcionalidad Básica (Login, Logout)
2. Gestión de Inventario (CRUD)
3. Movimientos de Stock
4. Alertas de Caducidad
5. Requisiciones
6. Transferencias
7. Seguridad y Permisos
8. Reportes y Exportaciones
9. Auditoría y Trazabilidad
10. Rendimiento y UX

**Criterios de aceptación:**
- ✅ 100% de casos CRÍTICOS pasan
- ✅ >= 95% de casos ALTOS pasan
- ✅ >= 90% de casos MEDIOS pasan
- ✅ 0 defectos críticos abiertos
- ✅ <= 2 defectos altos abiertos

---

## Solución de Problemas

### Error: "permission denied for table"

**Causa:** Usuario de la base de datos no tiene permisos suficientes

**Solución:**
```sql
-- Ejecutar como superusuario de PostgreSQL
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO [tu_usuario];
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO [tu_usuario];
```

### Error: "function does not exist"

**Causa:** Las funciones del sistema no están creadas

**Solución:**
```bash
# Ejecutar primero las migraciones
psql $DATABASE_URL -f migrations/03_funciones_y_triggers.sql
```

### Los usuarios no pueden hacer login

**Causa:** Los usuarios no existen en `auth.users` de Supabase

**Solución:**
- Crear usuarios manualmente en Supabase Dashboard (ver sección "Usuarios de Prueba")

### Las pruebas automatizadas fallan

**Causa:** Datos insuficientes o estructura incompleta

**Solución:**
```bash
# Ejecutar scripts en orden correcto
psql $DATABASE_URL -f scripts/01_generar_inventario_aleatorio.sql
psql $DATABASE_URL -f scripts/02_generar_datos_completos.sql
# Luego ejecutar pruebas
psql $DATABASE_URL -f scripts/03_pruebas_automatizadas.sql
```

### Errores de "duplicate key value"

**Causa:** Los scripts se ejecutaron más de una vez

**Solución:**
```sql
-- Limpiar datos de prueba
TRUNCATE medications CASCADE;
TRUNCATE batch_movements CASCADE;
TRUNCATE requisitions CASCADE;
TRUNCATE transfers CASCADE;
TRUNCATE test_results CASCADE;

-- Luego volver a ejecutar los scripts
```

---

## Limpieza de Datos

Si necesitas resetear los datos de prueba:

```sql
-- CUIDADO: Esto eliminará todos los datos de prueba

-- Deshabilitar temporalmente triggers
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
TRUNCATE contracts CASCADE;
TRUNCATE contract_items CASCADE;
TRUNCATE test_results CASCADE;
TRUNCATE audit_log CASCADE;

-- Opcional: Limpiar usuarios de prueba
DELETE FROM users_profiles WHERE email LIKE '%@sigimed.test';

-- Opcional: Limpiar centros de prueba
DELETE FROM health_centers WHERE code LIKE 'TEST-%';

-- Rehabilitar triggers
SET session_replication_role = 'origin';

-- Ahora puedes volver a ejecutar los scripts de generación
```

---

## Mejores Prácticas

### Para Desarrollo

1. **Ejecutar scripts en ambiente de desarrollo primero**
   ```bash
   # Configurar ambiente de desarrollo
   export DATABASE_URL="postgresql://...desarrollo..."
   ```

2. **Hacer backup antes de ejecutar**
   ```bash
   supabase db dump > backup_antes_pruebas.sql
   ```

3. **Verificar resultados de pruebas**
   ```sql
   SELECT * FROM test_results WHERE status != 'PASSED';
   ```

### Para Staging

1. **Limpiar datos antiguos**
2. **Ejecutar todos los scripts en orden**
3. **Verificar que todas las pruebas pasan**
4. **Documentar cualquier anomalía**

### Para Producción

⚠️ **NUNCA ejecutar estos scripts en producción**

Estos scripts son solo para ambientes de desarrollo y staging.

---

## Cronograma Sugerido

### Día 1: Preparación
- [ ] Configurar ambiente de staging
- [ ] Ejecutar scripts de generación de datos
- [ ] Verificar que todo funciona correctamente

### Día 2-3: Pruebas Internas
- [ ] Ejecutar pruebas automatizadas
- [ ] Realizar pruebas de escritorio
- [ ] Documentar defectos encontrados
- [ ] Corregir defectos críticos y altos

### Día 4: Preparación para QA Externa
- [ ] Verificar que criterios de aceptación interna se cumplen
- [ ] Preparar ambiente para QA externo
- [ ] Entregar documento de validación externa

### Día 5-10: Validación Externa
- [ ] Equipo de QA ejecuta pruebas
- [ ] Recibir reportes de defectos
- [ ] Corregir defectos encontrados
- [ ] Re-validar correcciones

### Día 11: Aprobación Final
- [ ] Revisión de resultados
- [ ] Aprobación para producción
- [ ] Planificar despliegue

---

## Contacto y Soporte

Para dudas o problemas con los scripts de prueba:

- **Email:** [tu-email@dominio.com]
- **Slack/Teams:** [Canal del proyecto]
- **Documentación adicional:** `/docs`

---

## Registro de Cambios

| Versión | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0 | 2025-11-19 | Equipo Dev | Versión inicial |

---

## Licencia

Estos scripts son de uso interno para el proyecto SIGIMED v2.0.

---

**¡Buenas Pruebas! 🧪**
