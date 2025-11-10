# 🚀 GUÍA RÁPIDA - SISTEMA SIGIMED v2.0

## ✅ INSTALACIÓN EXITOSA

El sistema SIGIMED ha sido instalado correctamente en tu base de datos Supabase.

---

## 📊 LO QUE TIENES INSTALADO

### 🗄️ **13 TABLAS**
1. **instituciones** - IMSS, ISSSTE, SSA
2. **health_centers** - Centros de salud por institución
3. **medication_catalog** - Catálogo nacional de medicamentos
4. **medications** - Medicamentos por centro de salud
5. **suppliers** - Proveedores farmacéuticos
6. **batches** - Lotes de medicamentos (inventario)
7. **batch_movements** - Movimientos de entrada/salida
8. **user_centers** - Asignación de usuarios a centros
9. **audit_log** - Auditoría completa del sistema
10. **contracts** - Contratos con proveedores
11. **contract_items** - Detalle de contratos
12. **storage_inspections** - Inspecciones de almacén
13. **documentos_comprobantes** - Gestión documental

### ⚙️ **5 FUNCIONES SQL**
1. **registrar_movimiento_lote()** - Registrar entradas/salidas
2. **detectar_lotes_vencidos()** - Alertas de vencimiento
3. **lotes_proximos_vencer()** - Alertas preventivas
4. **dashboard_ejecutivo()** - Métricas del sistema
5. **crear_lote_ejemplo()** - Crear lotes rápidamente

### 📦 **DATOS DE EJEMPLO**
- ✅ **3 Instituciones**: IMSS, ISSSTE, SSA
- ✅ **3 Centros de Salud**:
  - HGZ1 - Hospital General de Zona No. 1
  - CMF23 - Clínica de Medicina Familiar No. 23
  - CSU-ESP - Centro de Salud Urbano La Esperanza
- ✅ **3 Proveedores**:
  - Farmacéutica Nacional S.A. (Calificación: 4.5)
  - Distribuidora Médica del Centro S.A. (Calificación: 4.8)
  - Medicamentos y Suministros del Norte (Calificación: 4.2)
- ✅ **4 Medicamentos en Catálogo**:
  - Paracetamol 500mg
  - Ibuprofeno 400mg
  - Amoxicilina 500mg
  - Insulina Humana 100 UI/mL
- ✅ **4 Medicamentos en Inventario HGZ1** (listos para usar)

---

## 🎯 OPERACIONES BÁSICAS

### 1️⃣ **Ver Métricas del Sistema**
```sql
SELECT * FROM dashboard_ejecutivo();
```

### 2️⃣ **Crear un Lote de Medicamento**
```sql
-- Paracetamol, HGZ1, Farmacéutica Nacional, 500 unidades
SELECT * FROM crear_lote_ejemplo(
  '40000000-0000-0000-0000-000000000001'::UUID,
  '10000000-0000-0000-0000-000000000001'::UUID,
  '20000000-0000-0000-0000-000000000001'::UUID,
  500
);
```

### 3️⃣ **Ver Lotes Existentes**
```sql
SELECT
  hc.code as centro,
  m.nombre as medicamento,
  b.numero_lote,
  b.cantidad_actual,
  b.fecha_caducidad,
  b.estado
FROM batches b
JOIN medications m ON b.medication_id = m.id
JOIN health_centers hc ON b.center_id = hc.id
ORDER BY b.fecha_caducidad;
```

### 4️⃣ **Registrar una Salida de Medicamento**
```sql
-- Primero obtén el batch_id del lote
SELECT id, numero_lote, cantidad_actual
FROM batches
WHERE medication_id = '40000000-0000-0000-0000-000000000001'
LIMIT 1;

-- Luego registra la salida
SELECT * FROM registrar_movimiento_lote(
  'AQUI_VA_EL_BATCH_ID'::UUID,
  'salida',
  50,
  'Dispensación a pacientes'
);
```

### 5️⃣ **Ver Lotes Próximos a Vencer (90 días)**
```sql
SELECT * FROM lotes_proximos_vencer(90);
```

### 6️⃣ **Ver Lotes Vencidos**
```sql
SELECT * FROM detectar_lotes_vencidos();
```

### 7️⃣ **Ver Todos los Movimientos**
```sql
SELECT
  to_char(bm.created_at, 'DD/MM/YYYY HH24:MI') as fecha,
  hc.code as centro,
  m.nombre as medicamento,
  bm.tipo_movimiento,
  bm.cantidad,
  bm.cantidad_anterior,
  bm.cantidad_posterior,
  bm.motivo
FROM batch_movements bm
JOIN medications m ON bm.medication_id = m.id
JOIN health_centers hc ON bm.center_id = hc.id
ORDER BY bm.created_at DESC;
```

---

## 🆔 IDs IMPORTANTES (para copiar y pegar)

### 🏥 **Centros de Salud**
```
HGZ1:     10000000-0000-0000-0000-000000000001
CMF23:    10000000-0000-0000-0000-000000000002
CSU-ESP:  10000000-0000-0000-0000-000000000003
```

### 💊 **Medicamentos (HGZ1)**
```
Paracetamol:  40000000-0000-0000-0000-000000000001
Ibuprofeno:   40000000-0000-0000-0000-000000000002
Amoxicilina:  40000000-0000-0000-0000-000000000003
Insulina:     40000000-0000-0000-0000-000000000004
```

### 🏭 **Proveedores**
```
Farmacéutica Nacional:     20000000-0000-0000-0000-000000000001
Distribuidora Médica:      20000000-0000-0000-0000-000000000002
Medicamentos del Norte:    20000000-0000-0000-0000-000000000003
```

### 📋 **Catálogo de Medicamentos**
```
Paracetamol:  30000000-0000-0000-0000-000000000001
Ibuprofeno:   30000000-0000-0000-0000-000000000002
Amoxicilina:  30000000-0000-0000-0000-000000000003
Insulina:     30000000-0000-0000-0000-000000000004
```

---

## 📝 TIPOS DE MOVIMIENTOS PERMITIDOS

- **entrada** - Recepción de medicamentos
- **salida** - Dispensación a pacientes
- **ajuste** - Ajuste de inventario
- **transferencia_salida** - Envío a otro centro
- **transferencia_entrada** - Recepción desde otro centro
- **devolucion** - Devolución de medicamentos
- **merma** - Pérdida o deterioro
- **vencimiento** - Medicamento vencido

---

## 🔍 VERIFICACIÓN COMPLETA

Para ver toda la información instalada, ejecuta:
```sql
-- Archivo: VERIFICAR_TODO.sql
```

Este script te mostrará:
- ✅ Resumen ejecutivo
- ✅ Instituciones instaladas
- ✅ Centros de salud
- ✅ Proveedores
- ✅ Catálogo completo de medicamentos
- ✅ Medicamentos en inventario
- ✅ Lotes existentes
- ✅ Movimientos de inventario
- ✅ Contratos
- ✅ Tablas del sistema
- ✅ Funciones disponibles
- ✅ Alertas y recomendaciones

---

## 💡 EJEMPLOS PRÁCTICOS

### Crear 3 lotes diferentes:
```sql
-- Lote 1: Paracetamol en HGZ1
SELECT * FROM crear_lote_ejemplo(
  '40000000-0000-0000-0000-000000000001'::UUID,
  '10000000-0000-0000-0000-000000000001'::UUID,
  '20000000-0000-0000-0000-000000000001'::UUID,
  1000
);

-- Lote 2: Ibuprofeno en HGZ1
SELECT * FROM crear_lote_ejemplo(
  '40000000-0000-0000-0000-000000000002'::UUID,
  '10000000-0000-0000-0000-000000000001'::UUID,
  '20000000-0000-0000-0000-000000000002'::UUID,
  750
);

-- Lote 3: Amoxicilina en HGZ1
SELECT * FROM crear_lote_ejemplo(
  '40000000-0000-0000-0000-000000000003'::UUID,
  '10000000-0000-0000-0000-000000000001'::UUID,
  '20000000-0000-0000-0000-000000000003'::UUID,
  500
);
```

### Ver el estado del inventario:
```sql
SELECT
  m.nombre as medicamento,
  COUNT(b.id) as num_lotes,
  SUM(b.cantidad_actual) as stock_total,
  MIN(b.fecha_caducidad) as proxima_caducidad
FROM medications m
LEFT JOIN batches b ON m.id = b.medication_id AND b.cantidad_actual > 0
WHERE m.center_id = '10000000-0000-0000-0000-000000000001'
GROUP BY m.nombre
ORDER BY m.nombre;
```

---

## 🎓 PRÓXIMOS PASOS

1. ✅ **Crear tus primeros lotes** (usa `crear_lote_ejemplo`)
2. ✅ **Registrar movimientos** (entradas/salidas)
3. ✅ **Monitorear vencimientos** (usa `lotes_proximos_vencer`)
4. ✅ **Ver métricas** (usa `dashboard_ejecutivo`)
5. ✅ **Agregar más centros, proveedores y medicamentos** según necesites

---

## 📚 DOCUMENTACIÓN COMPLETA

Archivos disponibles en el repositorio:
- **INSTALAR_LIMPIO.sql** - Script de instalación completa
- **VERIFICAR_TODO.sql** - Verificación completa del sistema
- **GUIA_RAPIDA_USO.md** - Este archivo
- **FASE_COMPLETA_SISTEMA_SIGIMED.sql** - Sistema completo (todas las fases)

---

## ✨ ¡SISTEMA LISTO PARA USAR!

Tu sistema SIGIMED v2.0 está completamente operativo. Puedes comenzar a:
- Registrar medicamentos
- Crear lotes
- Gestionar inventario
- Monitorear vencimientos
- Generar reportes

¡Éxito con tu proyecto! 🎉
