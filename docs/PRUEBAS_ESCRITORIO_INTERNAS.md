# PRUEBAS DE ESCRITORIO INTERNAS - SIGIMED v2.0

## 📋 INFORMACIÓN GENERAL

**Sistema:** SIGIMED v2.0 - Sistema Integrado de Gestión de Inventario de Medicamentos
**Fecha:** 2025-11-19
**Responsable:** Equipo de Desarrollo
**Objetivo:** Validación interna completa de todos los módulos antes de QA externo

---

## ✅ CRITERIOS DE APROBACIÓN

Cada módulo debe cumplir:
- ✓ Carga sin errores en consola
- ✓ Muestra datos correctamente
- ✓ Formularios funcionan (crear, editar, eliminar)
- ✓ Validaciones funcionan correctamente
- ✓ Búsqueda y filtros operativos
- ✓ Responsive en móvil y desktop
- ✓ Permisos por rol funcionan

---

## 🔐 MÓDULO 1: AUTENTICACIÓN Y USUARIOS

### 1.1 Login
- [ ] Abrir `/login`
- [ ] Intentar login con credenciales incorrectas → Debe mostrar error
- [ ] Login con credenciales correctas → Redirige a dashboard
- [ ] Verificar que el token se guarda en localStorage
- [ ] Cerrar sesión → Limpia token y redirige a login

**Datos de prueba:**
```
Usuario Super Admin: admin@sigimed.com
Usuario Admin Centro: admin_centro@sigimed.com
Usuario Inventario: inventario@sigimed.com
Usuario Solo Lectura: lectura@sigimed.com
```

### 1.2 Gestión de Usuarios
- [ ] Navegar a `/admin/usuarios`
- [ ] Verificar listado de usuarios
- [ ] Crear nuevo usuario → Formulario valida campos requeridos
- [ ] Editar usuario existente → Cambios se reflejan
- [ ] Cambiar rol de usuario → Permisos se actualizan
- [ ] Desactivar usuario → No puede hacer login
- [ ] Filtrar por rol → Muestra usuarios correctos

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 🏥 MÓDULO 2: INSTITUCIONES

### 2.1 Listado de Instituciones
- [ ] Navegar a `/instituciones`
- [ ] Verificar que muestra las 2 instituciones iniciales
- [ ] Tabla muestra: nombre, clave, tipo, estado
- [ ] Paginación funciona (si hay >10 registros)
- [ ] Búsqueda por nombre funciona

### 2.2 CRUD de Instituciones
- [ ] Click en "Nueva Institución"
- [ ] Verificar validaciones:
  - Nombre (requerido)
  - Clave (requerido, único)
  - Tipo (requerido)
- [ ] Crear institución con datos válidos
- [ ] Editar institución → Cambios se guardan
- [ ] Intentar duplicar clave → Debe mostrar error
- [ ] Desactivar institución → Aparece como inactiva

**Datos de prueba:**
```
Nombre: Instituto Nacional de Salud
Clave: INS-2025
Tipo: Público
Descripción: Institución de prueba para validación
```

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 🏪 MÓDULO 3: CENTROS DE SALUD

### 3.1 Listado de Centros
- [ ] Navegar a `/centros`
- [ ] Verificar que muestra los 23 centros
- [ ] Filtrar por institución → Muestra centros correctos
- [ ] Filtrar por estado (activo/inactivo)
- [ ] Búsqueda por nombre o código

### 3.2 Detalle de Centro
- [ ] Click en un centro
- [ ] Verificar que muestra:
  - Información general
  - Dirección completa
  - Contacto
  - Capacidad de almacenamiento
  - Equipamiento (refrigeración)
- [ ] Verificar estadísticas del centro:
  - Total de medicamentos
  - Total de lotes
  - Alertas activas

### 3.3 CRUD de Centros
- [ ] Crear nuevo centro
- [ ] Validaciones obligatorias:
  - Nombre
  - Código (único)
  - Institución
  - Tipo
- [ ] Editar centro existente
- [ ] Asignar usuarios al centro
- [ ] Desactivar centro

**Datos de prueba:**
```
Nombre: Centro de Salud Prueba QA
Código: CS-QA-001
Tipo: Centro de Salud
Ciudad: Ciudad de México
Dirección: Av. Prueba 123
Teléfono: 55-1234-5678
Email: csqa@test.com
Responsable: Dr. Juan Pérez
Capacidad: 5000
Refrigeración: Sí
```

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 📦 MÓDULO 4: CATÁLOGOS ADMINISTRABLES

### 4.1 Catálogo de Colores
- [ ] Navegar a `/catalogos` → Tab "Colores"
- [ ] Verificar colores existentes
- [ ] Crear nuevo color:
  - Nombre
  - Código HEX válido
  - Categoría
- [ ] Editar color → Preview muestra cambio
- [ ] Desactivar color
- [ ] Verificar que colores inactivos no aparecen en selectores

### 4.2 Catálogo de Estados
- [ ] Tab "Estados"
- [ ] Verificar estados por módulo (medicamentos, lotes, etc.)
- [ ] Crear estado nuevo con:
  - Código único
  - Nombre
  - Módulo
  - Color asociado
  - Estado inicial/final
- [ ] Verificar que el estado aparece en el módulo correspondiente

### 4.3 Catálogo de Tipos de Movimiento
- [ ] Tab "Tipos de Movimiento"
- [ ] Verificar tipos: entrada, salida, ajuste, transferencia, etc.
- [ ] Crear tipo personalizado
- [ ] Configurar si afecta stock (+/-)
- [ ] Verificar en módulo de movimientos

### 4.4 Catálogo de Formas Farmacéuticas
- [ ] Tab "Formas Farmacéuticas"
- [ ] Verificar formas: tableta, cápsula, jarabe, etc.
- [ ] Crear forma farmacéutica
- [ ] Asociar vía de administración
- [ ] Verificar en creación de medicamentos

### 4.5 Catálogo de Prioridades
- [ ] Tab "Prioridades"
- [ ] Verificar niveles: baja, media, alta, crítica
- [ ] Crear prioridad personalizada
- [ ] Asignar tiempo de respuesta
- [ ] Verificar en alertas

### 4.6 Catálogo de Configuraciones
- [ ] Tab "Configuraciones"
- [ ] Verificar parámetros del sistema
- [ ] Modificar configuración
- [ ] Verificar que el cambio se refleja en el sistema

**Resultado esperado por catálogo:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 💊 MÓDULO 5: CATÁLOGO DE MEDICAMENTOS

### 5.1 Listado de Medicamentos del Catálogo
- [ ] Verificar los 99 medicamentos del catálogo
- [ ] Búsqueda por nombre
- [ ] Filtrar por categoría farmacológica
- [ ] Filtrar por forma farmacéutica
- [ ] Ver detalles completos de medicamento

### 5.2 Detalle de Medicamento
- [ ] Click en medicamento
- [ ] Verificar información:
  - Nombre genérico y comercial
  - Principio activo
  - Forma farmacéutica
  - Concentración
  - Uso terapéutico
  - Contraindicaciones
  - Temperatura de almacenamiento
  - Precio unitario

### 5.3 CRUD Catálogo
- [ ] Crear medicamento en catálogo
- [ ] Validaciones:
  - Código único
  - Nombre genérico (requerido)
  - Forma farmacéutica
- [ ] Marcar como controlado
- [ ] Requerir receta médica
- [ ] Editar medicamento
- [ ] Desactivar medicamento

**Datos de prueba:**
```
Código: TEST-MED-001
Nombre Genérico: Medicamento de Prueba QA
Nombre Comercial: TestMed
Principio Activo: Principio Activo Test
Forma Farmacéutica: Tableta
Concentración: 500mg
Vía: Oral
Categoría: Pruebas
Controlado: No
Requiere Receta: Sí
Temperatura: 15-25°C
```

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 📊 MÓDULO 6: INVENTARIO DE MEDICAMENTOS

### 6.1 Vista de Inventario
- [ ] Navegar a `/inventario` o `/medicamentos`
- [ ] Verificar listado de ~2,277 medicamentos
- [ ] Filtrar por centro de salud
- [ ] Filtrar por estado (Disponible, No Disponible, etc.)
- [ ] Búsqueda por nombre de medicamento
- [ ] Ordenar por cantidad, fecha de caducidad, etc.

### 6.2 Detalle de Medicamento en Inventario
- [ ] Click en medicamento
- [ ] Verificar información:
  - Centro asignado
  - Lote actual
  - Cantidad disponible
  - Fecha de caducidad
  - Ubicación física
  - Proveedor
  - Costos
- [ ] Ver historial de movimientos
- [ ] Ver lotes asociados

### 6.3 Alertas de Inventario
- [ ] Verificar medicamentos con stock bajo
- [ ] Verificar medicamentos próximos a vencer (< 60 días)
- [ ] Verificar medicamentos vencidos
- [ ] Verificar medicamentos en cuarentena

### 6.4 Operaciones de Inventario
- [ ] Registrar nueva entrada de medicamento
- [ ] Registrar salida (dispensación)
- [ ] Ajuste de inventario
- [ ] Transferencia entre centros
- [ ] Baja por caducidad

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 📦 MÓDULO 7: GESTIÓN DE LOTES

### 7.1 Listado de Lotes
- [ ] Navegar a `/lotes` o sección de lotes
- [ ] Verificar ~2,277 lotes
- [ ] Filtrar por centro
- [ ] Filtrar por medicamento
- [ ] Filtrar por estado (disponible, cuarentena, vencido, agotado)
- [ ] Filtrar por proveedor
- [ ] Búsqueda por número de lote

### 7.2 Detalle de Lote
- [ ] Click en un lote
- [ ] Verificar información:
  - Número de lote
  - Medicamento asociado
  - Cantidad inicial y actual
  - Fechas (fabricación, caducidad, ingreso)
  - Ubicación física
  - Temperatura de almacenamiento
  - Stock mínimo y máximo
  - Estado actual
  - Proveedor
  - Contrato asociado

### 7.3 Trazabilidad de Lote
- [ ] Ver historial completo del lote
- [ ] Verificar todos los movimientos:
  - Entrada inicial
  - Salidas
  - Ajustes
  - Transferencias
- [ ] Verificar usuario responsable de cada movimiento
- [ ] Verificar fechas y cantidades

### 7.4 Operaciones con Lotes
- [ ] Crear nuevo lote
- [ ] Validaciones:
  - Número de lote único por centro
  - Fecha de caducidad > fecha actual
  - Cantidad inicial >= 0
- [ ] Mover lote a cuarentena
- [ ] Liberar lote de cuarentena
- [ ] Marcar lote como vencido
- [ ] Dar de baja lote

**Datos de prueba:**
```
Medicamento: Seleccionar del catálogo
Centro: Seleccionar centro activo
Número Lote: TEST-LOTE-001
Cantidad Inicial: 5000
Fecha Fabricación: 2024-06-01
Fecha Caducidad: 2026-06-01
Ubicación: Anaquel A-001
Temperatura: 15-25°C
Proveedor: Farmacéutica Nacional
Stock Mínimo: 500
Stock Máximo: 8000
```

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 🔄 MÓDULO 8: MOVIMIENTOS DE INVENTARIO

### 8.1 Registro de Movimientos
- [ ] Verificar ~2,277+ movimientos
- [ ] Filtrar por tipo:
  - Entrada
  - Salida
  - Ajuste
  - Transferencia
  - Devolución
  - Merma
  - Vencimiento
- [ ] Filtrar por fecha (hoy, última semana, último mes, rango)
- [ ] Filtrar por centro
- [ ] Filtrar por usuario responsable

### 8.2 Detalle de Movimiento
- [ ] Click en movimiento
- [ ] Verificar:
  - Tipo de movimiento
  - Lote afectado
  - Medicamento
  - Cantidad
  - Cantidad anterior y posterior
  - Centro origen/destino (si es transferencia)
  - Motivo
  - Observaciones
  - Usuario responsable
  - Fecha y hora exacta
  - Documento asociado (si aplica)

### 8.3 Tipos de Movimientos

#### 8.3.1 Entrada
- [ ] Registrar entrada de medicamento
- [ ] Especificar:
  - Lote
  - Cantidad
  - Motivo (compra, donación, transferencia recibida)
  - Documento (orden de compra, etc.)
- [ ] Verificar que aumenta el stock
- [ ] Verificar registro en historial

#### 8.3.2 Salida
- [ ] Registrar salida
- [ ] Especificar:
  - Lote
  - Cantidad
  - Motivo (dispensación, transferencia enviada, uso interno)
  - Documento de respaldo
- [ ] Verificar que disminuye el stock
- [ ] Validar que no permite salida > stock disponible

#### 8.3.3 Ajuste
- [ ] Registrar ajuste de inventario
- [ ] Motivos: inventario físico, corrección, merma
- [ ] Puede aumentar o disminuir stock
- [ ] Requiere justificación obligatoria

#### 8.3.4 Transferencia
- [ ] Registrar transferencia entre centros
- [ ] Seleccionar centro origen y destino
- [ ] Verificar que:
  - Disminuye stock en origen
  - Aumenta stock en destino
  - Se crean 2 movimientos (salida + entrada)
- [ ] Validar que centros sean diferentes

#### 8.3.5 Devolución
- [ ] Registrar devolución
- [ ] Aumenta stock del lote
- [ ] Especificar motivo de devolución

#### 8.3.6 Merma
- [ ] Registrar merma
- [ ] Disminuye stock
- [ ] Requiere justificación detallada

#### 8.3.7 Vencimiento/Baja
- [ ] Registrar baja por vencimiento
- [ ] Lleva stock a 0
- [ ] Marca lote como vencido
- [ ] Requiere autorización

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 🏭 MÓDULO 9: PROVEEDORES

### 9.1 Listado de Proveedores
- [ ] Navegar a `/proveedores`
- [ ] Verificar 3 proveedores iniciales
- [ ] Filtrar por estado (activo/inactivo)
- [ ] Búsqueda por nombre o RFC
- [ ] Ordenar por nombre, calificación

### 9.2 Detalle de Proveedor
- [ ] Click en proveedor
- [ ] Verificar información:
  - Nombre comercial
  - Razón social
  - RFC
  - Dirección completa
  - Contacto (nombre, teléfono, email)
  - Términos de pago
  - Días de crédito
  - Calificación (0-5 estrellas)
  - Notas

### 9.3 CRUD Proveedores
- [ ] Crear nuevo proveedor
- [ ] Validaciones:
  - Nombre (requerido)
  - RFC (formato válido)
  - Email (formato válido)
  - Calificación (0-5)
- [ ] Editar proveedor
- [ ] Calificar proveedor (actualizar estrellas)
- [ ] Desactivar proveedor
- [ ] Verificar que proveedor inactivo no aparece en selects

**Datos de prueba:**
```
Nombre: Distribuidora Farmacéutica Prueba S.A.
RFC: DFP850101ABC
Razón Social: Distribuidora Farmacéutica Prueba S.A. de C.V.
Dirección: Av. Farmacia 456
Ciudad: Monterrey
Estado: Nuevo León
Teléfono: 81-8765-4321
Email: contacto@dfprueba.com
Contacto: Lic. María González
Tel. Contacto: 81-1234-5678
Términos: Pago a 30 días
Días Crédito: 30
Calificación: 4.5
```

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 📊 MÓDULO 10: REPORTES Y DASHBOARD

### 10.1 Dashboard Principal
- [ ] Navegar a `/dashboard` o página principal
- [ ] Verificar KPIs:
  - Total de medicamentos en inventario
  - Total de lotes activos
  - Alertas pendientes
  - Movimientos del día
- [ ] Gráficas:
  - Stock por centro
  - Medicamentos por categoría
  - Movimientos por tipo (últimos 30 días)
  - Top 10 medicamentos más utilizados

### 10.2 Alertas del Sistema
- [ ] Panel de alertas
- [ ] Verificar alertas:
  - Stock bajo (< stock mínimo)
  - Próximos a vencer (< 60 días)
  - Ya vencidos
  - En cuarentena
  - Discrepancias de inventario
- [ ] Click en alerta → Navega al elemento
- [ ] Marcar alerta como vista/resuelta

### 10.3 Reportes

#### 10.3.1 Reporte de Inventario
- [ ] Generar reporte de inventario actual
- [ ] Filtrar por centro, fecha, medicamento
- [ ] Exportar a Excel/PDF
- [ ] Verificar datos correctos

#### 10.3.2 Reporte de Movimientos
- [ ] Generar reporte de movimientos
- [ ] Filtrar por rango de fechas, tipo, centro
- [ ] Exportar
- [ ] Verificar trazabilidad completa

#### 10.3.3 Reporte de Vencimientos
- [ ] Reporte de lotes próximos a vencer
- [ ] Agrupar por centro
- [ ] Exportar lista para gestión

#### 10.3.4 Reporte de Valorización
- [ ] Reporte de valor total del inventario
- [ ] Por centro
- [ ] Por categoría de medicamento
- [ ] Exportar

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 🔒 MÓDULO 11: SEGURIDAD Y PERMISOS

### 11.1 Roles y Permisos

#### Super Admin
- [ ] Puede acceder a todos los módulos
- [ ] Puede crear/editar/eliminar en todo
- [ ] Puede gestionar usuarios
- [ ] Puede gestionar catálogos

#### Admin Centro
- [ ] Solo ve su centro asignado
- [ ] Puede gestionar inventario de su centro
- [ ] Puede ver reportes de su centro
- [ ] NO puede gestionar catálogos globales

#### Usuario Inventario
- [ ] Puede registrar movimientos
- [ ] Puede ver inventario (solo lectura de catálogos)
- [ ] NO puede eliminar registros
- [ ] NO puede gestionar usuarios

#### Solo Lectura
- [ ] Solo puede ver información
- [ ] NO puede crear/editar/eliminar nada
- [ ] Puede generar reportes

### 11.2 Seguridad
- [ ] Intentar acceso sin login → Redirige a login
- [ ] Token expira después de X tiempo → Requiere re-login
- [ ] Intentar acceso a módulo sin permiso → Error 403
- [ ] SQL Injection protegido (intentar en búsquedas)
- [ ] XSS protegido (intentar scripts en campos de texto)

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 📱 MÓDULO 12: RESPONSIVE Y UX

### 12.1 Desktop (1920x1080)
- [ ] Todos los módulos se ven correctamente
- [ ] Tablas no se deforman
- [ ] Formularios alineados
- [ ] Gráficas se renderizan bien

### 12.2 Tablet (768x1024)
- [ ] Menú collapsa correctamente
- [ ] Tablas son scrollables horizontalmente
- [ ] Formularios adaptables
- [ ] Botones accesibles

### 12.3 Móvil (375x667)
- [ ] Menú hamburguesa funciona
- [ ] Tablas en modo lista/cards
- [ ] Formularios en una sola columna
- [ ] Todos los botones accesibles con el pulgar

### 12.4 Navegadores
- [ ] Chrome/Edge (últimas 2 versiones)
- [ ] Firefox (últimas 2 versiones)
- [ ] Safari (última versión)

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## ⚡ MÓDULO 13: RENDIMIENTO

### 13.1 Tiempos de Carga
- [ ] Página principal carga en < 2 segundos
- [ ] Listados con 1000+ registros cargan en < 3 segundos
- [ ] Búsquedas responden en < 1 segundo
- [ ] Filtros aplican en < 500ms

### 13.2 Paginación
- [ ] Tablas con >100 registros paginan automáticamente
- [ ] Selector de items por página funciona (10, 25, 50, 100)
- [ ] Navegación entre páginas fluida

### 13.3 Optimización
- [ ] Imágenes optimizadas
- [ ] JavaScript minimizado
- [ ] CSS minimizado
- [ ] Sin memory leaks (verificar con DevTools)

**Resultado esperado:** ✅ PASS / ❌ FAIL
**Observaciones:**

---

## 📝 RESUMEN DE PRUEBAS

| Módulo | Estado | Errores Críticos | Errores Menores | Notas |
|--------|--------|------------------|-----------------|-------|
| 1. Autenticación | ⬜ | 0 | 0 | |
| 2. Instituciones | ⬜ | 0 | 0 | |
| 3. Centros | ⬜ | 0 | 0 | |
| 4. Catálogos | ⬜ | 0 | 0 | |
| 5. Catálogo Medicamentos | ⬜ | 0 | 0 | |
| 6. Inventario | ⬜ | 0 | 0 | |
| 7. Lotes | ⬜ | 0 | 0 | |
| 8. Movimientos | ⬜ | 0 | 0 | |
| 9. Proveedores | ⬜ | 0 | 0 | |
| 10. Reportes | ⬜ | 0 | 0 | |
| 11. Seguridad | ⬜ | 0 | 0 | |
| 12. Responsive | ⬜ | 0 | 0 | |
| 13. Rendimiento | ⬜ | 0 | 0 | |

**Leyenda:**
- ✅ PASS - Todas las pruebas pasaron
- ⚠️ PASS CON OBSERVACIONES - Funciona pero con mejoras sugeridas
- ❌ FAIL - Requiere corrección

---

## 🔴 ERRORES CRÍTICOS ENCONTRADOS

| # | Módulo | Descripción | Reproducción | Prioridad |
|---|--------|-------------|--------------|-----------|
| 1 | | | | Alta/Media/Baja |

---

## 🟡 ERRORES MENORES Y MEJORAS

| # | Módulo | Descripción | Sugerencia |
|---|--------|-------------|------------|
| 1 | | | |

---

## ✅ APROBACIÓN

**Resultado General:** ⬜ APROBADO / ⬜ APROBADO CON OBSERVACIONES / ⬜ RECHAZADO

**Responsable de Pruebas:** ___________________________
**Fecha:** ___________________________
**Firma:** ___________________________

**Notas Finales:**
