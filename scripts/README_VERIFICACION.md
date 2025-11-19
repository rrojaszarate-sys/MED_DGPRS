# 🔍 SCRIPTS DE VERIFICACIÓN DE DATOS

## Propósito
Verificar que la base de datos tiene suficientes datos de prueba para el sistema de catálogos.

---

## 📋 OPCIÓN 1: Supabase Dashboard (Recomendado)

### Pasos:

1. **Abrir Supabase Dashboard**
   - Ir a: https://app.supabase.com
   - Seleccionar tu proyecto

2. **Abrir SQL Editor**
   - Menú lateral → SQL Editor
   - New Query

3. **Copiar y ejecutar script**
   - Abrir archivo: `scripts/verificar_datos_prueba.sql`
   - Copiar TODO el contenido
   - Pegar en SQL Editor
   - Click en "Run" o Ctrl/Cmd + Enter

4. **Copiar resultados**
   - Aparecerán múltiples tablas de resultados
   - Copiar TODOS los resultados
   - Pegar en la conversación con Claude

---

## 📋 OPCIÓN 2: Cliente PostgreSQL (psql)

### Requisitos:
- psql instalado
- Variables de entorno configuradas

### Comando:

```bash
# Desde el directorio del proyecto
psql $DATABASE_URL -f scripts/verificar_datos_prueba.sql
```

**O con conexión directa:**

```bash
psql "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres" \
  -f scripts/verificar_datos_prueba.sql
```

---

## 📋 OPCIÓN 3: DBeaver / TablePlus / pgAdmin

1. Conectar a tu base de datos Supabase
2. Abrir SQL Console / Query Tool
3. Abrir archivo `scripts/verificar_datos_prueba.sql`
4. Ejecutar
5. Copiar todos los resultados

---

## 📊 QUÉ ESPERAR

### Sección 1: Conteo de Tablas
```
tabla                              | total_registros | activos | inactivos
-----------------------------------+-----------------+---------+-----------
catalogo_colores                   | 15              | 15      | 0
catalogo_estados                   | 20              | 20      | 0
catalogo_tipos_movimiento          | 15              | 15      | 0
catalogo_formas_farmaceuticas      | 12              | 12      | 0
catalogo_prioridades               | 9               | 9       | 0
catalogo_configuraciones           | 10              | 10      | 0
```

**✅ Total esperado: ~81 registros activos**

---

### Sección 2-8: Datos de Muestra

Mostrará muestras de cada catálogo con sus campos principales.

---

### Sección 9: Verificación de Datos Críticos

```
verificacion                | encontrados | estado
---------------------------+-------------+--------
Colores principales         | 5           | ✓ OK
Estados por módulo          | 5           | ✓ OK
Tipos entrada/salida        | 4           | ✓ OK
Formas farmacéuticas        | 12          | ✓ OK
Niveles de prioridad        | 9           | ✓ OK
Configuraciones sistema     | 10          | ✓ OK
```

**✅ Todos deben mostrar "✓ OK"**

---

### Sección 11: Resumen Final

```
total_colores | total_estados | total_tipos_movimiento | total_formas | total_prioridades | total_configs | total_general
--------------+---------------+------------------------+--------------+-------------------+---------------+---------------
15            | 20            | 15                     | 12           | 9                 | 10            | 81
```

**✅ Total esperado: 81 registros**

---

## ❌ QUÉ HACER SI HAY PROBLEMAS

### Problema: "relation 'catalogo_colores' does not exist"

**Causa:** Migración no ejecutada

**Solución:**
```sql
-- Ejecutar migración
-- En Supabase SQL Editor:
-- Copiar y ejecutar: migrations/09_catalogos_administrables.sql
```

---

### Problema: Conteo = 0 en alguna tabla

**Causa:** Datos no insertados

**Solución:**
1. Verificar que ejecutaste la migración COMPLETA
2. La migración incluye INSERTs al final
3. Re-ejecutar sección de INSERTs de la migración

---

### Problema: Todos los estados muestran "✗ FALTAN DATOS"

**Causa:** Migración ejecutada parcialmente

**Solución:**
1. Verificar logs de Supabase al ejecutar migración
2. Buscar errores en ejecución
3. Re-ejecutar migración completa

---

## 🎯 CRITERIO DE APROBACIÓN

**PASA si:**
- ✅ Total general ≥ 75 registros
- ✅ Todos los "estado" muestran "✓ OK"
- ✅ Cada tabla tiene al menos:
  - Colores: ≥ 10
  - Estados: ≥ 15
  - Tipos Movimiento: ≥ 10
  - Formas Farmacéuticas: ≥ 10
  - Prioridades: ≥ 5
  - Configuraciones: ≥ 8

**FALLA si:**
- ❌ Alguna tabla no existe
- ❌ Alguna tabla tiene 0 registros
- ❌ Total general < 50 registros
- ❌ Algún "estado" muestra "✗"

---

## 📝 FORMATO DE REPORTE

**Al pegar resultados en la conversación, incluir:**

```
=== VERIFICACIÓN DE DATOS DE PRUEBA ===
Fecha: [DD/MM/YYYY]
Base de datos: [Proyecto Supabase]

[PEGAR TODOS LOS RESULTADOS AQUÍ]

=== FIN VERIFICACIÓN ===
```

---

## 🔧 TROUBLESHOOTING

### Error: "permission denied"

**Solución:**
- Verificar que estás conectado como superadmin
- Verificar políticas RLS no están bloqueando

### Error: "syntax error near..."

**Solución:**
- Verificar que copiaste el script COMPLETO
- Algunos editores truncan el script

### Resultados vacíos

**Solución:**
- Verificar conexión a base de datos correcta
- Verificar que estás en el proyecto correcto

---

**¡Listo para verificar! 🚀**
