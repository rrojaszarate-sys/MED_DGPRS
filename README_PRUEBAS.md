# 🧪 BATERÍA DE PRUEBAS - SIGIMED v2.0

## ⚡ EJECUCIÓN RÁPIDA (2 minutos)

### 1️⃣ **Abre Supabase SQL Editor**
```
https://cyslhzynfuetthxngpoy.supabase.co/project/_/sql/new
```

### 2️⃣ **Copia el script de pruebas**
Abre este archivo y cópialo completo:
```
BATERIA_PRUEBAS_RAPIDA.sql
```

O desde GitHub:
```
https://github.com/rrojaszarate-sys/MED_DGPRS/blob/claude/debug-processing-delays-011CUuJoQiB6xnJ4SEEtBQ6k/BATERIA_PRUEBAS_RAPIDA.sql
```

### 3️⃣ **Ejecuta el script completo**
- Pega en el editor SQL
- Click **"Run"** o presiona **Ctrl+Enter**
- Espera 10-15 segundos

---

## ✅ QUÉ PRUEBA ESTE SCRIPT

### **PRUEBA 1: Estructura Instalada**
- ✅ 13 tablas creadas
- ✅ 5 funciones operativas

### **PRUEBA 2: Datos Iniciales**
- ✅ 3 instituciones (IMSS, ISSSTE, SSA)
- ✅ 3 centros de salud
- ✅ 3 proveedores
- ✅ 4 medicamentos en catálogo
- ✅ 4 medicamentos en inventario

### **PRUEBA 3: Crear Lotes**
- 🔵 Lote 1: Paracetamol (1000 unidades)
- 🔵 Lote 2: Ibuprofeno (750 unidades)
- 🔵 Lote 3: Amoxicilina (500 unidades)
- 🔵 Lote 4: Insulina (200 unidades)

### **PRUEBA 4: Registrar Movimientos**
- 🟡 Salida: Paracetamol -150 unidades
- 🟡 Salida: Ibuprofeno -100 unidades
- 🟢 Entrada: Amoxicilina +250 unidades
- 🟠 Ajuste: Insulina = 180 unidades

### **PRUEBA 5: Estado del Inventario**
- Ver stock inicial vs actual
- Ver consumo por medicamento
- Ver fechas de vencimiento

### **PRUEBA 6: Historial de Movimientos**
- Ver todos los movimientos registrados
- Con fecha, hora, tipo, cantidad

### **PRUEBA 7: Dashboard Ejecutivo**
- Métricas principales del sistema
- Totales por categoría

### **PRUEBA 8: Alertas de Vencimiento**
- Lotes próximos a vencer (90 días)
- Lotes vencidos

### **PRUEBA 9: Alertas de Stock Bajo**
- Nivel crítico (≤ 50% del mínimo)
- Nivel bajo (≤ 100% del mínimo)
- Nivel normal

### **PRUEBA 10: Resumen por Centro**
- Medicamentos distintos
- Lotes totales
- Unidades totales
- Movimientos totales

---

## 🎯 RESULTADO ESPERADO

Al finalizar deberías ver:

```
╔══════════════════════════════════════════════════╗
║              RESUMEN FINAL DE PRUEBAS             ║
╠══════════════════════════════════════════════════╣
║  ✅ Estructura instalada: 13 tablas + 5 funciones║
║  ✅ Datos iniciales: 3 instituciones, 3 centros  ║
║  ✅ Lotes creados: 4 lotes de ejemplo            ║
║  ✅ Movimientos: 4 movimientos registrados       ║
║  ✅ Inventario: Stock actualizado correctamente  ║
║  ✅ Dashboard: Métricas operativas               ║
║  ✅ Alertas: Sistema de alertas funcionando      ║
╠══════════════════════════════════════════════════╣
║           🎉 SISTEMA 100% FUNCIONAL 🎉           ║
╚══════════════════════════════════════════════════╝
```

Más una tabla final con el conteo de todos los componentes.

---

## 📊 TABLA FINAL ESPERADA

| Componente | Cantidad | Estado |
|------------|----------|--------|
| TABLAS | 13 | ✅ |
| FUNCIONES | 5 | ✅ |
| INSTITUCIONES | 3 | ✅ |
| CENTROS | 3 | ✅ |
| PROVEEDORES | 3 | ✅ |
| MEDICAMENTOS CATÁLOGO | 4 | ✅ |
| MEDICAMENTOS INVENTARIO | 4 | ✅ |
| LOTES | 4 | ✅ |
| MOVIMIENTOS | 4 | ✅ |

---

## ❌ SI ALGO FALLA

### Error: "relation already exists"
**Solución**: El script ya se ejecutó antes. Los lotes se duplicarán pero no hay problema.

### Error: "duplicate key value"
**Solución**: Algunas inserciones fallan porque ya existen, pero el resto funciona.

### No se ven resultados
**Solución**: Scroll hacia abajo, hay MUCHOS resultados (10 pruebas diferentes).

---

## 🚀 DESPUÉS DE LAS PRUEBAS

### Conectar con tu aplicación Vercel:

1. **Copia las credenciales de Supabase**:
```env
NEXT_PUBLIC_SUPABASE_URL=https://cyslhzynfuetthxngpoy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu_anon_key_aqui
```

2. **Usa el SDK de Supabase en tu app**:
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

// Ver lotes
const { data: batches } = await supabase
  .from('batches')
  .select('*, medications(*), health_centers(*), suppliers(*)')

// Crear movimiento
const { data } = await supabase
  .rpc('registrar_movimiento_lote', {
    p_batch_id: 'uuid-aqui',
    p_tipo_movimiento: 'salida',
    p_cantidad: 50,
    p_motivo: 'Dispensación'
  })
```

---

## 📁 ARCHIVOS RELACIONADOS

- **INSTALAR_LIMPIO.sql** - Instalación completa del sistema
- **VERIFICAR_TODO.sql** - Verificación detallada sin modificar datos
- **BATERIA_PRUEBAS_RAPIDA.sql** - Este archivo (pruebas con datos)
- **GUIA_RAPIDA_USO.md** - Guía de uso del sistema

---

## ✨ LISTO PARA PRODUCCIÓN

Si todas las pruebas pasan ✅, tu sistema está listo para:
- Conectar con el frontend
- Implementar autenticación
- Configurar RLS (Row Level Security)
- Desplegar en producción

🎉 **¡Éxito con tu proyecto!**
