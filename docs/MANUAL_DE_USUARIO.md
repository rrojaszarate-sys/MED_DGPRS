# Manual de Usuario - SIGIMED v2.0

## Sistema de Gestión de Inventario de Medicamentos

**Versión:** 2.0.0
**Fecha:** Enero 2025
**Dirigido a:** Usuarios finales del sistema

---

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Acceso al Sistema](#2-acceso-al-sistema)
3. [Pantalla Principal (Dashboard)](#3-pantalla-principal-dashboard)
4. [Módulo de Instituciones](#4-módulo-de-instituciones)
5. [Módulo de Centros de Salud](#5-módulo-de-centros-de-salud)
6. [Módulo de Catálogos](#6-módulo-de-catálogos)
7. [Catálogo de Medicamentos](#7-catálogo-de-medicamentos)
8. [Inventario de Medicamentos](#8-inventario-de-medicamentos)
9. [Gestión de Lotes](#9-gestión-de-lotes)
10. [Movimientos de Inventario](#10-movimientos-de-inventario)
11. [Proveedores](#11-proveedores)
12. [Reportes](#12-reportes)
13. [Alertas](#13-alertas)
14. [Preguntas Frecuentes](#14-preguntas-frecuentes)
15. [Solución de Problemas](#15-solución-de-problemas)

---

## 1. Introducción

### 1.1 ¿Qué es SIGIMED?

SIGIMED (Sistema de Gestión de Inventario de Medicamentos) es una plataforma web que permite gestionar de manera eficiente el inventario de medicamentos en instituciones de salud.

### 1.2 Funcionalidades Principales

- ✅ Control de inventario en tiempo real
- ✅ Gestión de lotes y fechas de caducidad
- ✅ Registro de movimientos (entradas, salidas, transferencias)
- ✅ Alertas automáticas de stock bajo y medicamentos próximos a vencer
- ✅ Reportes y estadísticas
- ✅ Exportación a Excel y PDF
- ✅ Gestión de múltiples centros de salud
- ✅ Control de acceso por roles

### 1.3 Roles de Usuario

| Rol | Permisos |
|-----|----------|
| **Administrador** | Acceso completo al sistema |
| **Almacenista** | Gestión de inventario, lotes y movimientos |
| **Farmacéutico** | Consulta y registro de salidas (dispensación) |
| **Consulta** | Solo lectura de información |

### 1.4 Requisitos del Sistema

**Para usar SIGIMED necesitas:**
- Conexión a Internet
- Navegador web moderno (Chrome, Firefox, Edge, Safari)
- Credenciales de acceso proporcionadas por tu administrador

---

## 2. Acceso al Sistema

### 2.1 Iniciar Sesión

**Paso 1:** Abre tu navegador web

**Paso 2:** Ingresa a la URL del sistema:
```
https://sigimed.vercel.app
```

**Paso 3:** Verás la pantalla de inicio de sesión con:
- Campo de **Email**
- Campo de **Contraseña**
- Botón **Iniciar Sesión**

**Paso 4:** Ingresa tus credenciales:

```
Ejemplo:
Email: usuario@hospital.gob.mx
Contraseña: ********
```

**Paso 5:** Haz clic en "Iniciar Sesión"

### 2.2 Primera Vez en el Sistema

Si es tu primera vez:
1. Usa las credenciales temporales que te proporcionó el administrador
2. Te recomendamos cambiar tu contraseña inmediatamente

### 2.3 Cerrar Sesión

1. Haz clic en tu nombre de usuario (esquina superior derecha)
2. Selecciona "Cerrar Sesión"
3. Confirma que deseas salir

---

## 3. Pantalla Principal (Dashboard)

Al ingresar al sistema, verás el Dashboard con información general:

### 3.1 Componentes del Dashboard

#### **Selector de Centro de Salud** (parte superior)
- Lista desplegable con todos los centros disponibles
- Selecciona el centro que deseas administrar
- Los datos se actualizan automáticamente

#### **Tarjetas de Resumen**

1. **Total de Medicamentos**
   - Muestra el total de medicamentos en inventario
   - Número de medicamentos disponibles vs total

2. **Lotes Activos**
   - Cantidad de lotes vigentes
   - Lotes disponibles para dispensación

3. **Movimientos del Mes**
   - Total de movimientos registrados este mes
   - Incluye entradas, salidas y transferencias

4. **Alertas Críticas**
   - Número de alertas que requieren atención
   - Stock bajo, próximos a vencer, vencidos

#### **Gráficas**

**Movimientos de Inventario (últimos 7 días)**
- Gráfica de barras
- Muestra entradas en verde, salidas en rojo
- Permite identificar tendencias

**Medicamentos por Estado**
- Gráfica de pastel
- Distribución: Disponible, No Disponible, Cuarentena, Vencido

### 3.2 Navegación

**Menú lateral izquierdo:**
- 📊 Dashboard
- 🏥 Instituciones
- 🏢 Centros de Salud
- 📋 Catálogos
- 💊 Catálogo de Medicamentos
- 📦 Inventario
- 📦 Lotes
- 🔄 Movimientos
- 🏪 Proveedores
- 📈 Reportes
- ⚠️ Alertas

Haz clic en cualquier opción para acceder al módulo correspondiente.

---

## 4. Módulo de Instituciones

### 4.1 Acceder al Módulo

1. En el menú lateral, haz clic en **🏥 Instituciones**
2. Verás la lista de todas las instituciones registradas

### 4.2 Lista de Instituciones

**Columnas mostradas:**
- Nombre de la institución
- Tipo (Hospital, Clínica, Centro de Salud)
- RFC
- Estado (Activo/Inactivo)
- Acciones (Editar/Eliminar)

### 4.3 Crear Nueva Institución

**Paso 1:** Haz clic en el botón **+ Nueva Institución**

**Paso 2:** Se abrirá un formulario modal con los siguientes campos:

**Campos obligatorios:**
- **Nombre**: Nombre completo de la institución
- **Tipo**: Selecciona de la lista (Hospital, Clínica, Centro de Salud, etc.)
- **RFC**: Registro Federal de Contribuyentes (13 caracteres)

**Campos opcionales:**
- Dirección
- Ciudad
- Estado
- Teléfono
- Email de contacto

**Ejemplo:**
```
Nombre: Hospital General de Zona No. 1
Tipo: Hospital
RFC: HGZ010101AAA
Dirección: Av. Reforma 123
Ciudad: Oaxaca
Estado: Oaxaca
Teléfono: 951-123-4567
Email: contacto@hgz01.gob.mx
```

**Paso 3:** Haz clic en **Guardar**

**Resultado:** Verás un mensaje de éxito y la nueva institución aparecerá en la lista

### 4.4 Editar Institución

1. Localiza la institución en la lista
2. Haz clic en el icono de lápiz ✏️ (Editar)
3. Modifica los campos necesarios
4. Haz clic en **Guardar cambios**

### 4.5 Desactivar Institución

> ⚠️ **Nota:** No se eliminan instituciones, solo se desactivan

1. Haz clic en el icono de papelera 🗑️
2. Confirma la acción
3. La institución cambiará a estado "Inactivo"

### 4.6 Buscar Instituciones

- Usa el campo de búsqueda en la parte superior
- Escribe el nombre o RFC
- La lista se filtrará automáticamente

---

## 5. Módulo de Centros de Salud

### 5.1 Acceder al Módulo

1. En el menú lateral, haz clic en **🏢 Centros de Salud**
2. Verás la lista de centros registrados

### 5.2 Crear Nuevo Centro

**Paso 1:** Haz clic en **+ Nuevo Centro**

**Paso 2:** Completa el formulario:

**Campos obligatorios:**
- **Nombre**: Nombre del centro
- **Código**: Código único (ej: CS-OAX-001)
- **Institución**: Selecciona de la lista desplegable

**Campos opcionales:**
- Dirección completa
- Ciudad
- Estado
- Teléfono
- Email
- Nombre del responsable
- Teléfono del responsable

**Ejemplo:**
```
Nombre: Centro de Salud Urbano Xochimilco
Código: CS-OAX-001
Institución: Hospital General de Zona No. 1
Dirección: Calle Morelos 456
Ciudad: Oaxaca de Juárez
Estado: Oaxaca
Responsable: Dr. Juan Pérez López
Teléfono: 951-234-5678
```

**Paso 3:** Haz clic en **Guardar**

### 5.3 Filtrar por Institución

- Usa el filtro "Institución" en la parte superior
- Selecciona una institución
- Solo se mostrarán los centros de esa institución

### 5.4 Validaciones

- ✅ El código debe ser único
- ✅ Debe seleccionarse una institución válida
- ✅ Los campos obligatorios no pueden estar vacíos

---

## 6. Módulo de Catálogos

Los catálogos son listas maestras que se usan en todo el sistema.

### 6.1 Acceder a Catálogos

1. Haz clic en **📋 Catálogos** en el menú
2. Verás pestañas para cada tipo de catálogo

### 6.2 Tipos de Catálogos

#### **Formas Farmacéuticas**
Ejemplos: Tableta, Cápsula, Jarabe, Inyectable, Crema, Ungüento

#### **Vías de Administración**
Ejemplos: Oral, Intravenosa, Intramuscular, Tópica, Sublingual

#### **Unidades de Medida**
Ejemplos: mg, g, ml, L, UI (Unidades Internacionales)

#### **Tipos de Medicamento**
Ejemplos: Genérico, Patente, Controlado, Antibiótico

#### **Colores**
Ejemplos: Blanco, Azul, Rojo, Verde, Amarillo

#### **Olores**
Ejemplos: Inodoro, Característico, Mentolado

### 6.3 Agregar a un Catálogo

**Ejemplo: Agregar Forma Farmacéutica**

1. Haz clic en la pestaña **Formas Farmacéuticas**
2. Haz clic en **+ Agregar**
3. Ingresa el nombre: "Supositorio"
4. Opcionalmente, agrega descripción: "Forma sólida para administración rectal"
5. Haz clic en **Guardar**

### 6.4 Editar Elemento de Catálogo

1. Localiza el elemento en la lista
2. Haz clic en ✏️ (Editar)
3. Modifica el nombre o descripción
4. Haz clic en **Guardar**

### 6.5 Desactivar Elemento

> ⚠️ **Nota:** No se eliminan registros de catálogos en uso

1. Haz clic en el interruptor de activación
2. El elemento cambiará a "Inactivo"
3. Ya no aparecerá en los formularios, pero se conserva en registros históricos

---

## 7. Catálogo de Medicamentos

El catálogo general de medicamentos disponibles para tu organización.

### 7.1 Acceder al Catálogo

1. Haz clic en **💊 Catálogo de Medicamentos**
2. Verás la lista completa de medicamentos

### 7.2 Crear Nuevo Medicamento

**Paso 1:** Haz clic en **+ Nuevo Medicamento**

**Paso 2:** Completa el formulario:

**Información Básica:**
- **Nombre Comercial**: Nombre con el que se conoce (ej: Tempra)
- **Nombre Genérico**: Principio activo (ej: Paracetamol)
- **Presentación**: Cómo viene el producto (ej: Tabletas, Jarabe)
- **Concentración**: Dosis (ej: 500mg, 120ml)

**Clasificación:**
- **Forma Farmacéutica**: Selecciona de la lista
- **Vía de Administración**: Selecciona de la lista
- **Tipo de Medicamento**: Selecciona de la lista

**Características Físicas:**
- **Color**: Selecciona de la lista
- **Olor**: Selecciona de la lista
- **Sabor**: (Opcional)

**Otros Datos:**
- **Código de Barras**: (Opcional)
- **Observaciones**: (Opcional)

**Ejemplo completo:**
```
Nombre Comercial: Paracetamol Genérico
Nombre Genérico: Paracetamol
Presentación: Tabletas
Concentración: 500mg
Forma Farmacéutica: Tableta
Vía de Administración: Oral
Tipo: Genérico
Color: Blanco
Olor: Inodoro
Código de Barras: 7501234567890
```

**Paso 3:** Haz clic en **Guardar**

### 7.3 Buscar Medicamentos

**Opciones de búsqueda:**
- Por nombre comercial
- Por nombre genérico
- Por código de barras

**Filtros disponibles:**
- Forma farmacéutica
- Tipo de medicamento
- Estado (Activo/Inactivo)

### 7.4 Importar Medicamentos Masivamente

> ℹ️ **Para administradores**: Importa múltiples medicamentos desde Excel

**Paso 1:** Haz clic en **Importar desde Excel**

**Paso 2:** Descarga la plantilla de ejemplo

**Paso 3:** Llena la plantilla con tus medicamentos:
```
| Nombre | Genérico | Presentación | Concentración | ... |
|--------|----------|--------------|---------------|-----|
| Tempra | Paracetamol | Tabletas | 500mg | ... |
| Advil | Ibuprofeno | Tabletas | 400mg | ... |
```

**Paso 4:** Sube el archivo completado

**Paso 5:** Revisa la vista previa y confirma

---

## 8. Inventario de Medicamentos

Gestión del inventario real de medicamentos en cada centro.

### 8.1 Acceder al Inventario

1. Haz clic en **📦 Inventario**
2. Selecciona el centro de salud (si no está seleccionado)
3. Verás el inventario de ese centro

### 8.2 Vista de Inventario

**Columnas mostradas:**
- Nombre del medicamento
- Lote
- Cantidad disponible
- Fecha de caducidad
- Estado
- Ubicación física
- Acciones

**Indicadores visuales:**
- 🟢 Verde: Stock normal
- 🟡 Amarillo: Stock bajo
- 🟠 Naranja: Próximo a vencer
- 🔴 Rojo: Vencido o sin stock

### 8.3 Registrar Nueva Entrada

> **Nota:** Para registrar una entrada completa (con lote), usa el módulo de Lotes

**Vista rápida del inventario:**
1. Haz clic en un medicamento
2. Ve el detalle con todos sus lotes
3. Observa el historial de movimientos

### 8.4 Buscar en el Inventario

**Campo de búsqueda:**
- Escribe el nombre del medicamento
- Escribe el número de lote
- Filtra por estado

**Filtros avanzados:**
- Estado (Disponible, Vencido, etc.)
- Rango de fechas de caducidad
- Ubicación física

### 8.5 Exportar Inventario

**Paso 1:** Haz clic en **Exportar**

**Paso 2:** Selecciona formato:
- **Excel**: Para trabajar con los datos
- **PDF**: Para imprimir o enviar

**Resultado:** Se descargará un archivo con todo el inventario

---

## 9. Gestión de Lotes

Control detallado de cada lote de medicamentos.

### 9.1 Acceder a Lotes

1. Haz clic en **📦 Lotes** en el menú
2. Verás todos los lotes registrados

### 9.2 Crear Nuevo Lote

**Paso 1:** Haz clic en **+ Nuevo Lote**

**Paso 2:** Selecciona el medicamento del catálogo

**Paso 3:** Completa la información del lote:

**Información del Lote:**
- **Número de Lote**: Código único del fabricante (ej: L-202501-001)
- **Cantidad Inicial**: Unidades recibidas (ej: 1000)
- **Cantidad Actual**: Se llena automáticamente (igual a inicial)

**Fechas:**
- **Fecha de Fabricación**: Cuando fue producido
- **Fecha de Caducidad**: Cuando vence
- **Fecha de Ingreso**: Cuando llegó al almacén (hoy por defecto)

**Ubicación:**
- **Ubicación Física**: Dónde está guardado (ej: Anaquel A, Refrigerador 1)
- **Temperatura de Almacenamiento**: Si requiere refrigeración (ej: 2-8°C)

**Control de Stock:**
- **Stock Mínimo**: Cantidad mínima antes de alertar (ej: 100)
- **Stock Máximo**: Capacidad máxima (ej: 5000)

**Proveedor:**
- **Selecciona el proveedor**: De la lista desplegable

**Ejemplo:**
```
Medicamento: Paracetamol 500mg Tabletas
Número de Lote: L-2025-01-ABC123
Cantidad Inicial: 5000
Fecha de Fabricación: 15/10/2024
Fecha de Caducidad: 15/10/2026
Fecha de Ingreso: 19/01/2025
Ubicación: Anaquel A, Nivel 2
Temperatura: 15-25°C (Temperatura ambiente)
Stock Mínimo: 500
Stock Máximo: 10000
Proveedor: Farmacéutica Nacional
Estado: Disponible
```

**Paso 4:** Haz clic en **Guardar**

**Resultado:**
- Se crea el lote
- Se registra automáticamente un movimiento de ENTRADA
- El inventario se actualiza

### 9.3 Estados de un Lote

| Estado | Descripción | Acción |
|--------|-------------|--------|
| **Disponible** | Listo para usar | Dispensar normalmente |
| **Cuarentena** | En revisión | No dispensar hasta autorización |
| **Vencido** | Fecha de caducidad pasada | Dar de baja |
| **Agotado** | Cantidad = 0 | Reabastecer |

### 9.4 Cambiar Estado de Lote

**Ejemplo: Poner lote en cuarentena**

1. Busca el lote en la lista
2. Haz clic en ✏️ (Editar)
3. Cambia el estado a "Cuarentena"
4. Agrega observaciones: "Lote en revisión por posible defecto"
5. Haz clic en **Guardar**

### 9.5 Consultar Historial de un Lote

1. Haz clic en el lote
2. Ve la pestaña "Movimientos"
3. Verás todos los movimientos registrados:
   - Fecha y hora
   - Tipo de movimiento
   - Cantidad
   - Usuario que lo registró
   - Observaciones

---

## 10. Movimientos de Inventario

Registro de todas las operaciones que modifican el inventario.

### 10.1 Tipos de Movimientos

#### **1. Entrada**
Ingreso de nuevo stock al almacén

**Cuándo usar:**
- Compra a proveedor
- Donaciones
- Devoluciones de otras áreas

#### **2. Salida**
Dispensación o uso de medicamentos

**Cuándo usar:**
- Dispensación a pacientes
- Uso interno (procedimientos)
- Traslado a otra área

#### **3. Ajuste**
Corrección de cantidades

**Cuándo usar:**
- Ajuste por inventario físico
- Corrección de errores de captura
- Merma o pérdida

#### **4. Transferencia**
Envío entre centros de salud

**Cuándo usar:**
- Redistribución de inventario
- Apoyo a otro centro

### 10.2 Registrar Movimiento de Entrada

**Paso 1:** Ve a **🔄 Movimientos**

**Paso 2:** Haz clic en **+ Nuevo Movimiento**

**Paso 3:** Selecciona tipo: **Entrada**

**Paso 4:** Selecciona el lote que se está recibiendo

**Paso 5:** Completa el formulario:

```
Tipo: Entrada
Lote: Paracetamol 500mg - L-2025-01-ABC123
Cantidad: 1000 unidades
Motivo: Compra programada
Documento de referencia: Factura F-12345
Observaciones: Entrega completa y en buen estado
```

**Paso 6:** Haz clic en **Registrar Movimiento**

**Resultado:**
- Se suma la cantidad al lote
- Se registra en el historial
- Se actualiza el inventario automáticamente

### 10.3 Registrar Movimiento de Salida (Dispensación)

**Paso 1:** Nuevo Movimiento → Tipo: **Salida**

**Paso 2:** Selecciona el lote del que se dispensará

> ⚠️ **Importante:** El sistema valida que haya stock suficiente

**Paso 3:** Completa el formulario:

```
Tipo: Salida
Lote: Paracetamol 500mg - L-2025-01-ABC123
Cantidad: 50 unidades
Motivo: Dispensación a pacientes
Receta/Folio: 2025-001234
Observaciones: Paciente: María López - 10 tabletas c/12h x 5 días
```

**Paso 4:** Haz clic en **Registrar Movimiento**

**Resultado:**
- Se resta la cantidad del lote
- Cantidad actual = 5000 - 50 = 4950
- Si queda por debajo del stock mínimo, se genera alerta

### 10.4 Registrar Ajuste de Inventario

**Cuándo:**  Después de un conteo físico que no coincide con el sistema

**Paso 1:** Nuevo Movimiento → Tipo: **Ajuste**

**Paso 2:** Selecciona el lote

**Paso 3:** Completa:

```
Tipo: Ajuste
Lote: Ibuprofeno 400mg - L-2025-02-XYZ456
Cantidad en sistema: 2500
Cantidad física contada: 2480
Diferencia: -20
Motivo: Ajuste por inventario físico
Observaciones: Conteo realizado el 19/01/2025. Autorizado por supervisor.
```

**Paso 4:** Registrar

**Resultado:** Cantidad actualizada a 2480

### 10.5 Registrar Transferencia entre Centros

**Paso 1:** Nuevo Movimiento → Tipo: **Transferencia Salida**

**Paso 2:** Completa:

```
Centro Origen: Centro de Salud Urbano Xochimilco
Centro Destino: Centro de Salud Rural Tlacolula
Lote: Amoxicilina 500mg - L-2025-03-QWE789
Cantidad: 500
Motivo: Apoyo por desabasto en centro destino
Documento: Oficio T-2025-001
Responsable de recepción: Dr. Pedro Martínez
```

**Paso 3:** Registrar

**Resultado:**
- Se resta del inventario del centro origen
- Se genera movimiento de entrada automática en centro destino
- Ambos centros pueden ver el historial

### 10.6 Timeline de Movimientos

En la vista de movimientos verás una línea de tiempo:

```
19 Ene 2025, 14:30 - ENTRADA - +1000 unidades
├─ Compra programada
├─ Usuario: Juan López
└─ Cantidad total: 5000

19 Ene 2025, 16:45 - SALIDA - -50 unidades
├─ Dispensación a pacientes
├─ Usuario: María García
└─ Cantidad total: 4950

20 Ene 2025, 09:15 - SALIDA - -100 unidades
├─ Uso interno
├─ Usuario: Pedro Ramírez
└─ Cantidad total: 4850
```

---

## 11. Proveedores

Gestión del catálogo de proveedores.

### 11.1 Crear Nuevo Proveedor

**Paso 1:** Ve a **🏪 Proveedores**

**Paso 2:** Haz clic en **+ Nuevo Proveedor**

**Paso 3:** Completa el formulario:

**Información Legal:**
- **Nombre**: Nombre comercial
- **Razón Social**: Nombre legal completo
- **RFC**: Registro Federal de Contribuyentes

**Contacto:**
- Dirección completa
- Ciudad y Estado
- Teléfono
- Email
- Nombre del contacto

**Términos Comerciales:**
- Términos de pago (ej: Crédito 30 días)
- Días de crédito (ej: 30)

**Calificación:**
- Calificación de 1 a 5 estrellas

**Ejemplo:**
```
Nombre: Farmacéutica Nacional
Razón Social: Farmacéutica Nacional S.A. de C.V.
RFC: FNA120101ABC
Dirección: Av. Insurgentes Sur 1234
Ciudad: Ciudad de México
Estado: CDMX
Teléfono: 55-1234-5678
Email: ventas@farmanacional.mx
Contacto: Juan Pérez López
Términos de Pago: Crédito 30 días
Días de Crédito: 30
Calificación: ⭐⭐⭐⭐⭐ (5/5)
```

**Paso 4:** Guardar

### 11.2 Editar Proveedor

1. Busca el proveedor
2. Haz clic en ✏️ (Editar)
3. Modifica la información
4. Guarda los cambios

### 11.3 Calificar Proveedor

Puedes actualizar la calificación basándote en:
- Calidad de los productos
- Tiempo de entrega
- Servicio al cliente
- Precios competitivos

---

## 12. Reportes

Generación de reportes y estadísticas.

### 12.1 Acceder a Reportes

1. Haz clic en **📈 Reportes**
2. Verás las opciones de reportes disponibles

### 12.2 Reporte de Inventario General

**Qué incluye:**
- Lista completa de medicamentos
- Cantidad por lote
- Estado de cada lote
- Valor del inventario

**Paso 1:** Selecciona "Inventario General"

**Paso 2:** Configura filtros:
- Centro de salud (o todos)
- Rango de fechas
- Estado (Disponible, Vencido, etc.)

**Paso 3:** Haz clic en **Generar Reporte**

**Paso 4:** Selecciona formato:
- **Excel**: Para análisis detallado
- **PDF**: Para imprimir

### 12.3 Reporte de Movimientos

**Qué incluye:**
- Todos los movimientos en un período
- Tipo, cantidad, usuario
- Antes y después de cada movimiento

**Ejemplo de uso:**
```
Reporte de Movimientos
Período: 01/01/2025 - 31/01/2025
Centro: Centro de Salud Urbano Xochimilco

Filtros:
✓ Solo SALIDAS
✓ Solo medicamentos controlados
```

**Resultado:** Excel con todas las salidas de medicamentos controlados en enero

### 12.4 Reporte de Medicamentos Próximos a Vencer

**Qué incluye:**
- Medicamentos que vencen en los próximos 3 meses
- Cantidad disponible
- Fecha exacta de caducidad
- Valor económico

**Uso:** Programar uso prioritario o gestionar devoluciones

### 12.5 Reporte de Stock Bajo

**Qué incluye:**
- Medicamentos por debajo del stock mínimo
- Cantidad actual vs mínima
- Centros afectados

**Uso:** Programar compras

### 12.6 Reporte de Consumo

**Qué incluye:**
- Consumo por medicamento
- Tendencias
- Comparativa entre períodos

**Ejemplo:**
```
Reporte de Consumo - Paracetamol 500mg
Enero 2025: 15,000 unidades
Diciembre 2024: 12,000 unidades
Variación: +25%

Promedio mensual: 13,500 unidades
Proyección febrero: 14,000 unidades
```

---

## 13. Alertas

Sistema automático de alertas y notificaciones.

### 13.1 Acceder a Alertas

1. Haz clic en **⚠️ Alertas**
2. Verás todas las alertas activas

### 13.2 Tipos de Alertas

#### **🔴 Alerta Crítica: Stock Agotado**
```
Medicamento: Insulina Glargina 100UI/ml
Centro: Centro de Salud Urbano
Estado: AGOTADO (0 unidades)
Acción: Reabastecer URGENTE
```

#### **🟠 Alerta Alta: Stock Bajo**
```
Medicamento: Paracetamol 500mg
Centro: CS Rural Tlacolula
Cantidad Actual: 45 unidades
Stock Mínimo: 100 unidades
Acción: Programar compra o transferencia
```

#### **🟡 Advertencia: Próximo a Vencer**
```
Medicamento: Amoxicilina 500mg
Lote: L-2025-03-QWE789
Fecha de Caducidad: 15/04/2025 (85 días)
Cantidad: 500 unidades
Acción: Usar prioritariamente
```

#### **🔴 Crítica: Medicamento Vencido**
```
Medicamento: Ibuprofeno 400mg
Lote: L-2024-06-OLD123
Fecha de Caducidad: 31/12/2024 (VENCIDO)
Cantidad: 200 unidades
Acción: DAR DE BAJA inmediatamente
```

### 13.3 Atender una Alerta

**Ejemplo: Alerta de Stock Bajo**

**Paso 1:** Identifica la alerta

**Paso 2:** Evalúa opciones:
- ¿Hay stock en otro centro? → Transferir
- ¿No hay en la institución? → Comprar

**Paso 3:** Ejecuta la acción

**Transferencia:**
1. Ve a Movimientos
2. Crea transferencia desde centro con stock
3. La alerta se resolverá automáticamente al llegar el stock

**Compra:**
1. Genera reporte de faltantes
2. Envía a compras
3. Cuando llegue, registra la entrada

**Paso 4:** La alerta desaparecerá automáticamente cuando se resuelva

### 13.4 Configurar Alertas

**Para administradores:**

1. Ve a Configuración
2. Sección "Alertas"
3. Configura umbrales:
   - Stock bajo: % o cantidad
   - Días antes de vencer: 90 días (default)
   - Envío de emails: Sí/No

---

## 14. Preguntas Frecuentes

### **P: ¿Cómo recupero mi contraseña?**
R: Contacta a tu administrador del sistema. Ellos pueden restablecerla.

### **P: ¿Puedo cambiar de centro sin cerrar sesión?**
R: Sí, usa el selector de centro en el Dashboard o en la parte superior de cualquier pantalla.

### **P: ¿Los cambios son inmediatos?**
R: Sí, el sistema actualiza en tiempo real. Otros usuarios verán los cambios automáticamente.

### **P: ¿Puedo eliminar un movimiento registrado por error?**
R: No se pueden eliminar movimientos, pero puedes hacer un ajuste correctivo. Contacta a tu supervisor.

### **P: ¿Qué hago si un lote llega dañado?**
R: Regístralo con estado "Cuarentena" y documenta el incidente en observaciones. No lo uses hasta que se autorice.

### **P: ¿Puedo exportar todos los datos?**
R: Sí, cada módulo tiene opción de exportar a Excel o PDF.

### **P: ¿El sistema guarda automáticamente?**
R: No, debes hacer clic en "Guardar" explícitamente en cada formulario.

### **P: ¿Qué pasa si pierdo conexión a Internet?**
R: No podrás hacer cambios hasta recuperar la conexión. Los datos ya guardados están seguros en la nube.

### **P: ¿Puedo ver quién hizo cada cambio?**
R: Sí, todos los movimientos registran el usuario y fecha/hora. Ve el historial de cada lote.

### **P: ¿Cómo sé si un medicamento requiere refrigeración?**
R: Lo verás en el campo "Temperatura de Almacenamiento" del lote. Si dice "2-8°C", requiere refrigeración.

---

## 15. Solución de Problemas

### **Problema: No puedo iniciar sesión**

**Posibles causas:**
1. Contraseña incorrecta
2. Usuario desactivado
3. Problema de conexión

**Solución:**
1. Verifica que escribiste correctamente tu email y contraseña
2. Verifica tu conexión a Internet
3. Si continúa, contacta al administrador

---

### **Problema: No veo ningún dato**

**Causa:** No has seleccionado un centro de salud

**Solución:**
1. Ve al selector de centro (parte superior)
2. Selecciona tu centro de salud
3. Los datos se cargarán automáticamente

---

### **Problema: Error al guardar**

**Posibles causas:**
1. Campos obligatorios vacíos
2. Datos duplicados (RFC, código, lote)
3. Formato incorrecto

**Solución:**
1. Lee el mensaje de error (aparece en rojo)
2. Verifica los campos marcados en rojo
3. Corrige y vuelve a intentar

**Ejemplo de error común:**
```
❌ "El RFC ya está registrado"
→ Verifica que no estés duplicando un proveedor

❌ "El código debe ser único"
→ Usa otro código para el centro de salud

❌ "La cantidad debe ser mayor a cero"
→ Ingresa una cantidad válida
```

---

### **Problema: El sistema está lento**

**Posibles causas:**
1. Conexión lenta a Internet
2. Muchos datos cargando
3. Navegador con muchas pestañas abiertas

**Solución:**
1. Cierra pestañas innecesarias
2. Actualiza la página (F5)
3. Si persiste, contacta a soporte técnico

---

### **Problema: No puedo exportar a Excel**

**Causa:** Navegador bloqueando descargas

**Solución:**
1. Revisa si el navegador bloqueó la descarga (ícono en la barra de direcciones)
2. Permite las descargas para este sitio
3. Vuelve a intentar la exportación

---

### **Problema: El reporte PDF no se ve bien**

**Solución:**
1. Usa Chrome o Firefox (navegadores recomendados)
2. Actualiza tu navegador a la última versión
3. Si imprimes, selecciona "Ajustar a página"

---

## Contacto y Soporte

### **Soporte Técnico**

**Email:** soporte@sigimed.gob.mx
**Teléfono:** 800-123-4567
**Horario:** Lunes a Viernes, 8:00 AM - 6:00 PM

### **Capacitación**

Para solicitar capacitación adicional, contacta a tu administrador local o al equipo de soporte.

### **Reportar un Error**

Si encuentras un error en el sistema:
1. Toma una captura de pantalla
2. Anota los pasos que causaron el error
3. Envía al soporte técnico con:
   - Tu usuario
   - Fecha y hora
   - Descripción del problema
   - Captura de pantalla

---

## Glosario

**API**: Interfaz de programación de aplicaciones
**Dashboard**: Pantalla principal con resumen de información
**Lote**: Conjunto de unidades de un medicamento con el mismo número de fabricación
**RLS**: Row Level Security (Seguridad a nivel de fila)
**Stock**: Inventario disponible
**UUID**: Identificador único universal

---

**Versión del manual:** 1.0
**Última actualización:** 19 de enero de 2025
**Elaborado por:** Equipo SIGIMED

---

**¡Gracias por usar SIGIMED v2.0!**

Para más información, visita la documentación técnica o contacta a soporte.
