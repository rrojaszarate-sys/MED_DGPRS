# Documento de Validación Externa - SIGIMED v2.0

**Sistema:** SIGIMED v2.0 - Sistema Integrado de Gestión de Inventario de Medicamentos
**Versión:** 2.0
**Fecha de Emisión:** 2025-11-19
**Organización:** [Nombre de su Organización]
**Para:** Equipo de Calidad / QA Externo

---

## Control de Documento

| Versión | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0 | 2025-11-19 | Equipo de Desarrollo | Versión inicial para validación externa |

---

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Objetivo del Documento](#objetivo-del-documento)
3. [Alcance de la Validación](#alcance-de-la-validación)
4. [Información del Sistema](#información-del-sistema)
5. [Ambiente de Pruebas](#ambiente-de-pruebas)
6. [Credenciales de Acceso](#credenciales-de-acceso)
7. [Casos de Uso Principales](#casos-de-uso-principales)
8. [Casos de Prueba para Validación](#casos-de-prueba-para-validación)
9. [Criterios de Aceptación](#criterios-de-aceptación)
10. [Reporte de Defectos](#reporte-de-defectos)
11. [Anexos](#anexos)

---

## 1. Introducción

El presente documento tiene como finalidad guiar al equipo de calidad externo en la validación funcional y de aceptación del Sistema SIGIMED v2.0.

SIGIMED v2.0 es un sistema integral de gestión de inventario de medicamentos diseñado para el sector salud público, que permite:

- Gestión centralizada de inventarios en múltiples centros de salud
- Trazabilidad completa de medicamentos desde entrada hasta salida
- Alertas automáticas de medicamentos próximos a vencer
- Transferencias inter-centros
- Requisiciones internas
- Auditoría completa de operaciones
- Reportes y exportaciones

---

## 2. Objetivo del Documento

Proporcionar al equipo de QA externo:

1. **Información completa** sobre la funcionalidad del sistema
2. **Casos de prueba estructurados** para validación
3. **Credenciales y ambiente** configurado con datos de prueba
4. **Criterios claros** de aceptación
5. **Formato estandarizado** para reporte de defectos

---

## 3. Alcance de la Validación

### 3.1 Módulos a Validar

| # | Módulo | Prioridad | Descripción |
|---|--------|-----------|-------------|
| 1 | Autenticación y Usuarios | CRÍTICA | Login, logout, gestión de usuarios y roles |
| 2 | Dashboard | ALTA | Visualización de KPIs y métricas principales |
| 3 | Centros de Salud | ALTA | CRUD de centros de salud |
| 4 | Catálogo de Medicamentos | CRÍTICA | Catálogo maestro de medicamentos |
| 5 | Inventario | CRÍTICA | Gestión de inventario por centro |
| 6 | Lotes | CRÍTICA | Trazabilidad de lotes |
| 7 | Movimientos | CRÍTICA | Registro de movimientos de stock |
| 8 | Alertas | CRÍTICA | Sistema de alertas de caducidad |
| 9 | Requisiciones | ALTA | Solicitudes internas de medicamentos |
| 10 | Transferencias | ALTA | Transferencias entre centros |
| 11 | Proveedores | MEDIA | Gestión de proveedores |
| 12 | Contratos | MEDIA | Contratos con proveedores |
| 13 | Ajustes de Inventario | ALTA | Ajustes, mermas, correcciones |
| 14 | Auditoría | CRÍTICA | Trazabilidad y logs |
| 15 | Reportes | ALTA | Generación y exportación de reportes |

### 3.2 Aspectos a Validar

- ✅ **Funcionalidad:** Todas las funciones operan según especificaciones
- ✅ **Usabilidad:** Interfaz intuitiva y fácil de usar
- ✅ **Integridad de Datos:** Los datos se mantienen consistentes
- ✅ **Seguridad:** Permisos y roles funcionan correctamente
- ✅ **Rendimiento:** Tiempos de respuesta aceptables
- ✅ **Compatibilidad:** Funciona en navegadores soportados
- ✅ **Exportaciones:** Reportes se generan correctamente

### 3.3 Fuera de Alcance

- ❌ Pruebas de carga y estrés (se realizarán en fase posterior)
- ❌ Pruebas de penetración de seguridad
- ❌ Pruebas de recuperación ante desastres
- ❌ Integración con sistemas externos (no implementada aún)

---

## 4. Información del Sistema

### 4.1 Arquitectura Técnica

- **Frontend:** React 18 + TypeScript + Tailwind CSS
- **Backend:** Supabase (PostgreSQL 14 + PostgREST)
- **Autenticación:** Supabase Auth (JWT)
- **Hosting:** [Especificar URL]

### 4.2 Navegadores Soportados

| Navegador | Versión Mínima | Estado |
|-----------|----------------|--------|
| Google Chrome | 90+ | ✅ Recomendado |
| Microsoft Edge | 90+ | ✅ Recomendado |
| Firefox | 88+ | ✅ Soportado |
| Safari | 14+ | ✅ Soportado |

### 4.3 Resoluciones de Pantalla

- **Mínima:** 1280x720 (HD)
- **Recomendada:** 1920x1080 (Full HD)
- **Responsive:** Tablets (1024x768+)

---

## 5. Ambiente de Pruebas

### 5.1 URL de Acceso

**URL del Sistema:** `[INSERTAR URL DE STAGING/PRUEBAS]`

**Estado del Ambiente:**
- ✅ Configurado con datos de prueba
- ✅ 6 centros de salud activos
- ✅ 30+ medicamentos en catálogo
- ✅ 200+ items en inventarios
- ✅ Usuarios de prueba creados
- ✅ Movimientos, requisiciones y transferencias de ejemplo

### 5.2 Base de Datos

**Estado:** Poblada con datos ficticios realistas
**Reseteo:** Los datos se pueden resetear ejecutando scripts de generación
**Backup:** Se realiza backup diario automático

---

## 6. Credenciales de Acceso

### 6.1 Usuarios de Prueba

| Usuario | Email | Contraseña | Rol | Centro | Descripción |
|---------|-------|------------|-----|--------|-------------|
| Super Admin | superadmin@sigimed.test | Test123! | super_admin | Todos | Acceso total al sistema |
| Admin HG | admin.hgm@sigimed.test | Test123! | admin_center | HG-001 | Administrador Hospital General |
| Admin HRAE | admin.hraei@sigimed.test | Test123! | admin_center | HRAE-002 | Administrador Hospital Regional |
| Inventario 1 | inventario1@sigimed.test | Test123! | inventory_user | Variable | Usuario de inventario |
| Inventario 2 | inventario2@sigimed.test | Test123! | inventory_user | Variable | Usuario de inventario |
| Solo Lectura | readonly1@sigimed.test | Test123! | read_only | Variable | Usuario de solo lectura |

**IMPORTANTE:** Estas credenciales son solo para ambiente de pruebas. NO usar en producción.

### 6.2 Permisos por Rol

| Funcionalidad | super_admin | admin_center | inventory_user | read_only |
|---------------|-------------|--------------|----------------|-----------|
| Ver Dashboard | ✅ | ✅ | ✅ | ✅ |
| Ver Inventario | ✅ Todos | ✅ Su centro | ✅ Su centro | ✅ Su centro |
| Agregar Medicamentos | ✅ | ✅ | ✅ | ❌ |
| Eliminar Medicamentos | ✅ | ✅ | ❌ | ❌ |
| Crear Requisiciones | ✅ | ✅ | ✅ | ❌ |
| Aprobar Requisiciones | ✅ | ✅ | ❌ | ❌ |
| Crear Transferencias | ✅ | ✅ | ❌ | ❌ |
| Aprobar Transferencias | ✅ | ✅ | ❌ | ❌ |
| Gestionar Usuarios | ✅ | ❌ | ❌ | ❌ |
| Ver Auditoría | ✅ | ✅ Limitada | ❌ | ❌ |
| Exportar Reportes | ✅ | ✅ | ✅ | ✅ |

---

## 7. Casos de Uso Principales

### CU-001: Login al Sistema

**Actor:** Cualquier usuario registrado
**Precondiciones:** Usuario tiene credenciales válidas
**Flujo Principal:**
1. Usuario accede a la URL del sistema
2. Sistema muestra página de login
3. Usuario ingresa email y contraseña
4. Usuario hace clic en "Iniciar Sesión"
5. Sistema valida credenciales
6. Sistema redirige a Dashboard
7. Sistema muestra nombre y rol del usuario

**Flujo Alternativo 3a - Credenciales Incorrectas:**
1. Sistema muestra mensaje "Credenciales incorrectas"
2. Usuario permanece en página de login

**Postcondiciones:** Usuario autenticado puede acceder a funcionalidades según su rol

---

### CU-002: Agregar Medicamento al Inventario

**Actor:** Admin Center, Inventory User
**Precondiciones:**
- Usuario autenticado
- Catálogo de medicamentos tiene items
- Proveedores registrados

**Flujo Principal:**
1. Usuario navega a "Inventario"
2. Usuario hace clic en "Agregar Medicamento"
3. Sistema muestra formulario
4. Usuario selecciona medicamento del catálogo
5. Usuario ingresa: lote, cantidad, fecha caducidad, proveedor, ubicación
6. Usuario hace clic en "Guardar"
7. Sistema valida datos
8. Sistema crea registro en inventario
9. Sistema genera movimiento de entrada
10. Sistema muestra mensaje de éxito
11. Sistema actualiza lista de inventario

**Validaciones:**
- Cantidad debe ser > 0
- Fecha de caducidad debe ser futura
- Número de lote no debe duplicarse para el mismo medicamento
- Todos los campos requeridos deben llenarse

**Postcondiciones:**
- Medicamento agregado al inventario
- Movimiento de entrada registrado
- Stock actualizado

---

### CU-003: Generar Alerta de Caducidad

**Actor:** Sistema (automático)
**Precondiciones:** Medicamentos en inventario con fechas de caducidad

**Flujo Principal:**
1. Sistema ejecuta proceso automático diario
2. Sistema consulta medicamentos por centro
3. Para cada medicamento, sistema calcula días restantes hasta caducidad
4. Si días <= 90, sistema clasifica nivel de alerta:
   - Crítico: <= 7 días
   - Urgente: <= 30 días
   - Preventivo: <= 90 días
5. Sistema crea registro de alerta
6. Sistema notifica a usuarios del centro

**Postcondiciones:** Alertas visibles en Dashboard y módulo de Alertas

---

### CU-004: Crear y Aprobar Requisición

**Actor:** Inventory User (crea), Admin Center (aprueba)
**Precondiciones:** Usuario autenticado, inventario tiene medicamentos

**Flujo Principal - Creación:**
1. Usuario navega a "Requisiciones"
2. Usuario hace clic en "Nueva Requisición"
3. Usuario ingresa:
   - Servicio solicitante
   - Prioridad
   - Fecha necesaria
4. Usuario agrega items (medicamentos y cantidades)
5. Usuario hace clic en "Crear Requisición"
6. Sistema genera número de requisición
7. Sistema guarda con estado "solicitada"

**Flujo Principal - Aprobación:**
1. Admin navega a "Requisiciones"
2. Admin filtra por "Solicitadas"
3. Admin selecciona requisición
4. Admin revisa items
5. Admin ajusta cantidades aprobadas (si necesario)
6. Admin hace clic en "Aprobar"
7. Sistema cambia estado a "aprobada"
8. Sistema registra usuario y fecha de aprobación

**Postcondiciones:** Requisición aprobada lista para surtir

---

### CU-005: Transferencia entre Centros

**Actores:** Admin Center (origen), Super Admin (aprueba), Admin Center (destino)
**Precondiciones:** Múltiples centros, inventario disponible

**Flujo Principal:**
1. **Creación** (Admin Centro Origen):
   - Navega a "Transferencias"
   - Clic en "Nueva Transferencia"
   - Selecciona centro destino
   - Agrega medicamentos y cantidades
   - Crea transferencia (estado: "pending")

2. **Aprobación** (Super Admin):
   - Ve transferencias pendientes
   - Revisa detalles
   - Aprueba transferencia (estado: "approved")

3. **Envío** (Admin Centro Origen):
   - Marca transferencia como enviada
   - Ingresa número de guía/tracking
   - Sistema genera movimientos de salida
   - Sistema reduce inventario origen (estado: "in_transit")

4. **Recepción** (Admin Centro Destino):
   - Ve transferencias en tránsito hacia su centro
   - Marca como recibida
   - Confirma cantidades recibidas
   - Sistema genera movimientos de entrada
   - Sistema aumenta inventario destino (estado: "completed")

**Postcondiciones:**
- Inventario origen reducido
- Inventario destino aumentado
- Trazabilidad completa registrada

---

### CU-006: Generar Reporte de Inventario

**Actor:** Cualquier usuario autenticado
**Precondiciones:** Usuario tiene acceso al centro

**Flujo Principal:**
1. Usuario navega a "Reportes" o "Inventario"
2. Usuario hace clic en "Exportar"
3. Usuario selecciona formato (Excel, PDF, CSV)
4. Usuario aplica filtros (opcional):
   - Por estado
   - Por fecha de caducidad
   - Por medicamento
5. Usuario hace clic en "Generar"
6. Sistema genera archivo
7. Sistema descarga archivo al navegador

**Validaciones:**
- Usuario solo ve datos de sus centros asignados
- Formato del archivo es correcto
- Datos corresponden a filtros aplicados

**Postcondiciones:** Archivo descargado con datos actuales

---

## 8. Casos de Prueba para Validación

### Categoría 1: Funcionalidad Básica

#### CP-001: Login Exitoso

**Prioridad:** CRÍTICA
**Prerequisitos:** Usuario registrado en el sistema

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Abrir URL del sistema | - | Página de login se muestra |
| 2 | Ingresar email | superadmin@sigimed.test | Campo acepta texto |
| 3 | Ingresar contraseña | Test123! | Campo oculta caracteres |
| 4 | Hacer clic en "Iniciar Sesión" | - | Redirige a Dashboard |
| 5 | Verificar nombre usuario | - | Muestra "Dr. Administrador General del Sistema" |
| 6 | Verificar rol | - | Muestra "Super Admin" o similar |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-002: Login con Credenciales Inválidas

**Prioridad:** CRÍTICA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Abrir página de login | - | Página se muestra |
| 2 | Ingresar email inválido | noexiste@test.com | Campo acepta texto |
| 3 | Ingresar contraseña | cualquiera | Campo acepta texto |
| 4 | Hacer clic en "Iniciar Sesión" | - | Muestra error "Credenciales incorrectas" |
| 5 | Verificar que permanece en login | - | No redirige |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-003: Logout del Sistema

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Iniciar sesión | superadmin@sigimed.test / Test123! | Dashboard se muestra |
| 2 | Hacer clic en menú de usuario | - | Muestra opciones |
| 3 | Hacer clic en "Cerrar Sesión" | - | Redirige a login |
| 4 | Intentar acceder a URL directa del dashboard | /dashboard | Redirige a login |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 2: Gestión de Inventario

#### CP-010: Agregar Medicamento al Inventario

**Prioridad:** CRÍTICA
**Prerequisito:** Login como admin_center

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Inventario" | - | Lista de medicamentos se muestra |
| 2 | Clic en "Agregar Medicamento" | - | Formulario se abre |
| 3 | Seleccionar medicamento | Paracetamol 500mg | Se llena información del catálogo |
| 4 | Ingresar lote | LOTE-QA-2025-001 | Campo acepta texto |
| 5 | Ingresar cantidad | 100 | Campo acepta número |
| 6 | Seleccionar fecha caducidad | 2026-12-31 | Selector de fecha funciona |
| 7 | Seleccionar proveedor | Cualquiera de la lista | Dropdown funciona |
| 8 | Ingresar ubicación | Estante A-1 | Campo acepta texto |
| 9 | Clic en "Guardar" | - | Mensaje de éxito aparece |
| 10 | Verificar en lista | - | Nuevo medicamento aparece |
| 11 | Verificar cantidad total | - | Se suma a stock total |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-011: Validación de Campos Requeridos

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Abrir formulario "Agregar Medicamento" | - | Formulario se muestra |
| 2 | Dejar todos los campos vacíos | - | - |
| 3 | Clic en "Guardar" | - | Muestra errores de validación |
| 4 | Verificar mensajes de error | - | "Este campo es requerido" o similar |
| 5 | Llenar solo medicamento | Paracetamol | - |
| 6 | Clic en "Guardar" | - | Aún muestra errores en otros campos |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-012: Cantidad Negativa No Permitida

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Abrir formulario "Agregar Medicamento" | - | Formulario se muestra |
| 2 | Llenar campos requeridos | Datos válidos | - |
| 3 | Ingresar cantidad negativa | -50 | Campo no acepta o muestra error |
| 4 | Intentar guardar | - | Muestra error de validación |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-013: Filtrar Inventario por Estado

**Prioridad:** MEDIA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Inventario" | - | Lista completa se muestra |
| 2 | Usar filtro "Estado" | - | Dropdown se abre |
| 3 | Seleccionar "Disponible" | - | Lista se filtra |
| 4 | Verificar resultados | - | Solo muestra medicamentos con estado "Disponible" |
| 5 | Verificar contador | - | Muestra cantidad filtrada |
| 6 | Limpiar filtro | - | Lista completa vuelve a mostrarse |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-014: Buscar Medicamento por Nombre

**Prioridad:** MEDIA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Inventario" | - | Lista se muestra |
| 2 | Usar campo de búsqueda | - | Campo activo |
| 3 | Escribir "Para" | Para | Lista se filtra mientras se escribe |
| 4 | Completar "Paracetamol" | Paracetamol | Solo muestra Paracetamol |
| 5 | Borrar búsqueda | - | Lista completa vuelve |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 3: Movimientos de Stock

#### CP-020: Registrar Salida de Medicamento

**Prioridad:** CRÍTICA
**Prerequisito:** Medicamento con cantidad > 10

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Movimientos" | - | Vista de movimientos |
| 2 | Clic en "Registrar Salida" | - | Formulario se abre |
| 3 | Seleccionar medicamento | Uno con cantidad > 10 | Muestra cantidad actual |
| 4 | Ingresar cantidad | 5 | Campo acepta |
| 5 | Seleccionar motivo | Dispensación a urgencias | Dropdown funciona |
| 6 | Ingresar observaciones | Prueba de validación | Campo acepta |
| 7 | Clic en "Guardar" | - | Mensaje de éxito |
| 8 | Verificar inventario | - | Cantidad se redujo en 5 |
| 9 | Verificar en historial | - | Movimiento aparece en lista |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-021: Validar Stock Insuficiente

**Prioridad:** CRÍTICA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Abrir formulario "Registrar Salida" | - | Formulario activo |
| 2 | Seleccionar medicamento | Uno con cantidad = 10 | Muestra cantidad: 10 |
| 3 | Ingresar cantidad mayor | 20 | Campo acepta temporalmente |
| 4 | Clic en "Guardar" | - | Muestra error "Stock insuficiente" |
| 5 | Verificar que no se guardó | - | Inventario sin cambios |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 4: Alertas de Caducidad

#### CP-030: Visualizar Alertas Activas

**Prioridad:** CRÍTICA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Login como admin_center | - | Dashboard cargado |
| 2 | Navegar a "Alertas" | - | Lista de alertas se muestra |
| 3 | Verificar agrupación | - | Alertas agrupadas por nivel |
| 4 | Verificar colores | - | Crítico=rojo, Urgente=amarillo, Preventivo=azul |
| 5 | Verificar información | - | Muestra: medicamento, lote, días restantes |
| 6 | Verificar contador | - | Número de alertas coincide |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-031: Marcar Alerta como Vista

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | En lista de alertas | - | Alertas visibles |
| 2 | Seleccionar una alerta no vista | - | Alerta resaltada |
| 3 | Clic en "Marcar como Vista" | - | Alerta cambia visualmente |
| 4 | Verificar estado | - | Muestra como "vista" |
| 5 | Verificar contador | - | Número de no vistas se reduce en 1 |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-032: Resolver Alerta

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Seleccionar alerta | - | Alerta activa |
| 2 | Clic en "Resolver" | - | Modal de confirmación |
| 3 | Ingresar motivo | Medicamento retirado | Campo acepta texto |
| 4 | Confirmar | - | Alerta marcada como resuelta |
| 5 | Verificar lista activas | - | Ya no aparece en activas |
| 6 | Ir a "Alertas Resueltas" | - | Aparece en histórico |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 5: Requisiciones

#### CP-040: Crear Requisición

**Prioridad:** ALTA
**Prerequisito:** Login como inventory_user

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Requisiciones" | - | Lista de requisiciones |
| 2 | Clic en "Nueva Requisición" | - | Formulario se abre |
| 3 | Ingresar servicio | Urgencias | Campo acepta |
| 4 | Seleccionar prioridad | Normal | Dropdown funciona |
| 5 | Seleccionar fecha necesaria | 7 días futuro | Date picker funciona |
| 6 | Clic en "Agregar Item" | - | Fila de item aparece |
| 7 | Seleccionar medicamento | Paracetamol | Dropdown funciona |
| 8 | Ingresar cantidad | 50 | Campo acepta |
| 9 | Agregar segundo item | Ibuprofeno, 30 | Funciona |
| 10 | Clic en "Crear Requisición" | - | Mensaje de éxito |
| 11 | Verificar número generado | - | Muestra REQ-YYYY-XXXXX |
| 12 | Verificar estado | - | Estado = "Solicitada" |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-041: Aprobar Requisición

**Prioridad:** ALTA
**Prerequisito:** Requisición en estado "Solicitada", login como admin_center

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Requisiciones" | - | Lista cargada |
| 2 | Filtrar por "Solicitadas" | - | Solo muestra solicitadas |
| 3 | Seleccionar una requisición | - | Detalles se muestran |
| 4 | Revisar items | - | Lista de items visible |
| 5 | Ajustar cantidad aprobada | Item 1: de 50 a 40 | Cambio se acepta |
| 6 | Clic en "Aprobar" | - | Modal de confirmación |
| 7 | Confirmar aprobación | - | Estado cambia a "Aprobada" |
| 8 | Verificar usuario aprobador | - | Muestra nombre del admin |
| 9 | Verificar fecha aprobación | - | Muestra fecha/hora actual |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 6: Transferencias entre Centros

#### CP-050: Crear Transferencia

**Prioridad:** ALTA
**Prerequisito:** Login como admin_center en HG-001

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Transferencias" | - | Lista cargada |
| 2 | Clic en "Nueva Transferencia" | - | Formulario se abre |
| 3 | Verificar centro origen | - | Muestra HG-001 (automático) |
| 4 | Seleccionar centro destino | HRAE-002 | Dropdown funciona |
| 5 | Ingresar motivo | Redistribución de stock | Campo acepta |
| 6 | Agregar item | Medicamento con cant > 20, qty: 10 | Item se agrega |
| 7 | Verificar validación stock | - | Valida que hay stock suficiente |
| 8 | Clic en "Crear Transferencia" | - | Mensaje de éxito |
| 9 | Verificar número | - | Muestra TRF-YYYY-XXXXX |
| 10 | Verificar estado | - | Estado = "Pending" |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-051: Flujo Completo de Transferencia

**Prioridad:** CRÍTICA
**Prerequisito:** Transferencia creada en CP-050

| Paso | Acción | Usuario | Resultado Esperado |
|------|--------|---------|-------------------|
| 1 | Aprobar transferencia | superadmin | Estado = "Approved" |
| 2 | Verificar notificación | admin HG-001 | Recibe notificación |
| 3 | Marcar como enviada | admin HG-001 | Estado = "In Transit" |
| 4 | Ingresar tracking | admin HG-001 | TRK-XXXXXXXXXX guardado |
| 5 | Verificar movimiento salida | admin HG-001 | Movimiento creado |
| 6 | Verificar stock origen | admin HG-001 | Stock reducido en 10 |
| 7 | Ver transferencia en destino | admin HRAE-002 | Aparece en "En Tránsito" |
| 8 | Marcar como recibida | admin HRAE-002 | Estado = "Received" |
| 9 | Confirmar cantidad | admin HRAE-002 | Cantidad = 10 (igual a enviada) |
| 10 | Verificar movimiento entrada | admin HRAE-002 | Movimiento creado |
| 11 | Verificar stock destino | admin HRAE-002 | Stock aumentado en 10 |
| 12 | Estado final | Cualquiera | Estado = "Completed" |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 7: Seguridad y Permisos

#### CP-060: Restricción por Rol - Read Only

**Prioridad:** CRÍTICA
**Prerequisito:** Login como readonly1@sigimed.test

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Login | readonly1@sigimed.test | Dashboard cargado |
| 2 | Navegar a Inventario | - | Puede ver lista |
| 3 | Buscar botón "Agregar" | - | Botón NO visible o deshabilitado |
| 4 | Navegar a Movimientos | - | Puede ver lista |
| 5 | Buscar botón "Registrar Salida" | - | Botón NO visible o deshabilitado |
| 6 | Intentar acceder a URL directa | /admin/users | Error o redirección |
| 7 | Verificar exportaciones | - | Puede exportar reportes |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-061: Restricción por Centro

**Prioridad:** CRÍTICA
**Prerequisito:** Login como admin.hgm@sigimed.test (solo HG-001)

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Login | admin.hgm@sigimed.test | Dashboard cargado |
| 2 | Navegar a Inventario | - | Solo muestra medicamentos de HG-001 |
| 3 | Verificar contador | - | Solo cuenta items de HG-001 |
| 4 | Navegar a Alertas | - | Solo alertas de HG-001 |
| 5 | Navegar a Movimientos | - | Solo movimientos de HG-001 |
| 6 | Intentar crear requisición | - | Solo puede para HG-001 |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 8: Reportes y Exportaciones

#### CP-070: Exportar Inventario a Excel

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a Inventario | - | Lista cargada |
| 2 | Clic en "Exportar" | - | Modal/menú se abre |
| 3 | Seleccionar formato "Excel" | - | Opción seleccionada |
| 4 | Clic en "Descargar" | - | Archivo .xlsx se descarga |
| 5 | Abrir archivo en Excel | - | Archivo se abre sin errores |
| 6 | Verificar columnas | - | Todas las columnas relevantes presentes |
| 7 | Verificar datos | - | Datos coinciden con los del sistema |
| 8 | Verificar formato | - | Fechas, números formateados correctamente |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-071: Exportar a PDF

**Prioridad:** ALTA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a Reportes | - | Vista de reportes |
| 2 | Seleccionar "Reporte de Inventario" | - | Parámetros se muestran |
| 3 | Aplicar filtros | Centro actual, Estado: Todos | Filtros aplicados |
| 4 | Clic en "Exportar PDF" | - | PDF se genera |
| 5 | Abrir PDF | - | Documento se abre |
| 6 | Verificar formato | - | Layout profesional |
| 7 | Verificar encabezado | - | Logo, nombre institución, fecha |
| 8 | Verificar datos | - | Coinciden con filtros |
| 9 | Verificar pie de página | - | Número de página, fecha generación |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 9: Auditoría y Trazabilidad

#### CP-080: Ver Log de Auditoría

**Prioridad:** ALTA
**Prerequisito:** Login como superadmin

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a "Auditoría" | - | Lista de eventos cargada |
| 2 | Verificar columnas | - | Fecha, Usuario, Acción, Entidad, Resultado |
| 3 | Verificar orden | - | Más recientes primero |
| 4 | Filtrar por usuario | admin.hgm@sigimed.test | Solo eventos de ese usuario |
| 5 | Filtrar por acción | CREATE | Solo eventos de creación |
| 6 | Ver detalles de un evento | - | Modal con valores antes/después |
| 7 | Verificar IP y User Agent | - | Información de sesión visible |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-081: Trazabilidad de Medicamento

**Prioridad:** CRÍTICA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | En Inventario, seleccionar medicamento | Uno con varios movimientos | Detalles se muestran |
| 2 | Clic en "Ver Trazabilidad" | - | Timeline de movimientos |
| 3 | Verificar movimiento inicial | - | Entrada al inventario |
| 4 | Verificar movimientos intermedios | - | Salidas, ajustes, etc. |
| 5 | Verificar datos de cada movimiento | - | Fecha, usuario, cantidad, motivo |
| 6 | Verificar cantidades | - | Cantidad anterior y posterior |
| 7 | Exportar trazabilidad | - | PDF se genera |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

### Categoría 10: Rendimiento y UX

#### CP-090: Tiempo de Carga del Dashboard

**Prioridad:** MEDIA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Limpiar caché del navegador | - | Caché limpio |
| 2 | Login | superadmin | - |
| 3 | Medir tiempo de carga Dashboard | Cronómetro | < 3 segundos |
| 4 | Verificar que KPIs cargan | - | Números visibles |
| 5 | Verificar que gráficos cargan | - | Gráficos renderizados |

**Resultado:** [ ] PASA [ ] FALLA
**Tiempo medido:** _____ segundos
**Observaciones:** _______________________________________________

---

#### CP-091: Búsqueda Responsiva

**Prioridad:** MEDIA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Navegar a Inventario | - | Lista cargada |
| 2 | Usar búsqueda | Escribir "Para" | Filtra mientras se escribe |
| 3 | Medir tiempo de respuesta | - | < 500ms |
| 4 | Continuar escribiendo | "Paracetamol" | Actualiza continuamente |
| 5 | Borrar búsqueda | - | Lista completa vuelve |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

#### CP-092: Navegación Entre Módulos

**Prioridad:** MEDIA

| Paso | Acción | Datos de Prueba | Resultado Esperado |
|------|--------|-----------------|-------------------|
| 1 | Dashboard → Inventario | - | Transición suave, < 1s |
| 2 | Inventario → Movimientos | - | Transición suave |
| 3 | Movimientos → Alertas | - | Transición suave |
| 4 | Verificar breadcrumbs | - | Muestra ruta actual |
| 5 | Usar botón "Atrás" navegador | - | Vuelve correctamente |

**Resultado:** [ ] PASA [ ] FALLA
**Observaciones:** _______________________________________________

---

## 9. Criterios de Aceptación

### 9.1 Criterios Funcionales

El sistema será aceptado si cumple:

| Criterio | Requisito | Estado |
|----------|-----------|--------|
| **Casos Críticos** | 100% de casos CRÍTICOS pasan | [ ] |
| **Casos Altos** | >= 95% de casos ALTOS pasan | [ ] |
| **Casos Medios** | >= 90% de casos MEDIOS pasan | [ ] |
| **Defectos Críticos** | 0 defectos críticos abiertos | [ ] |
| **Defectos Altos** | <= 2 defectos altos abiertos | [ ] |

### 9.2 Criterios No Funcionales

| Aspecto | Requisito | Estado |
|---------|-----------|--------|
| **Rendimiento** | Tiempo de carga inicial < 3s | [ ] |
| **Rendimiento** | Tiempo de respuesta operaciones < 2s | [ ] |
| **Usabilidad** | Calificación SUS >= 70 | [ ] |
| **Compatibilidad** | Funciona en 4 navegadores principales | [ ] |
| **Seguridad** | Permisos funcionan correctamente | [ ] |

### 9.3 Clasificación de Defectos

**CRÍTICO:**
- Pérdida de datos
- Sistema no arranca o se cae
- Funcionalidad crítica no funciona
- Vulnerabilidad de seguridad

**ALTO:**
- Funcionalidad importante no funciona
- Workaround difícil o no existe
- Afecta a muchos usuarios

**MEDIO:**
- Funcionalidad menor afectada
- Existe workaround razonable
- Afecta a pocos usuarios

**BAJO:**
- Cosmético
- No afecta funcionalidad
- Mejora de usabilidad

---

## 10. Reporte de Defectos

### 10.1 Formato de Reporte

Para cada defecto encontrado, favor de reportar con el siguiente formato:

**ID del Defecto:** [Auto-generado o secuencial: DEF-001, DEF-002, etc.]

**Título:** [Descripción breve del problema]

**Severidad:** [ ] Crítico [ ] Alto [ ] Medio [ ] Bajo

**Módulo:** [Módulo afectado]

**Ambiente:** [URL y versión]

**Usuario de Prueba:** [Usuario con el que se encontró]

**Pasos para Reproducir:**
1. [Paso 1]
2. [Paso 2]
3. [...]

**Resultado Esperado:** [Qué debería pasar]

**Resultado Actual:** [Qué pasó realmente]

**Evidencia:** [Screenshots, videos, logs]

**Información Adicional:**
- Navegador y versión:
- Sistema Operativo:
- Fecha y hora:
- ¿Es reproducible siempre?: [ ] Sí [ ] No [ ] A veces

---

### 10.2 Plantilla de Reporte (Ejemplo)

**ID:** DEF-001

**Título:** Error al guardar medicamento con fecha de caducidad en el pasado

**Severidad:** [X] Alto [ ] Medio [ ] Bajo [ ] Crítico

**Módulo:** Inventario

**Ambiente:** https://staging.sigimed.test - v2.0

**Usuario:** admin.hgm@sigimed.test

**Pasos para Reproducir:**
1. Login como admin_center
2. Navegar a Inventario
3. Clic en "Agregar Medicamento"
4. Llenar todos los campos correctamente
5. Ingresar fecha de caducidad en el pasado (ej: 2023-01-01)
6. Clic en "Guardar"

**Resultado Esperado:**
Sistema muestra error de validación "La fecha de caducidad debe ser futura"

**Resultado Actual:**
Sistema permite guardar el medicamento con fecha en el pasado

**Evidencia:**
[Adjuntar screenshot del medicamento guardado con fecha incorrecta]

**Información Adicional:**
- Navegador: Chrome 120
- SO: Windows 11
- Fecha: 2025-11-19 14:30
- Reproducible: Sí, siempre

---

### 10.3 Herramienta de Reporte

Los defectos pueden reportarse mediante:

1. **Formato Excel:** Usar plantilla adjunta "Reporte_Defectos_SIGIMED.xlsx"
2. **Herramienta de Gestión:** [Si tienen Jira, Azure DevOps, etc.]
3. **Email:** [Dirección de contacto del equipo de desarrollo]

**Contacto para Dudas:**
- Email: [email-del-equipo@dominio.com]
- Slack/Teams: [Canal de comunicación]
- Horario de soporte: [Lunes a Viernes 9:00-18:00]

---

## 11. Anexos

### Anexo A: Glosario de Términos

| Término | Definición |
|---------|------------|
| **Lote** | Número único asignado por el fabricante a un conjunto de medicamentos producidos en las mismas condiciones |
| **Catálogo** | Base de datos maestra de medicamentos aprobados para uso en el sistema |
| **Trazabilidad** | Capacidad de seguir el historial completo de un medicamento desde su entrada hasta su salida |
| **Alerta de Caducidad** | Notificación automática cuando un medicamento está próximo a vencer |
| **Requisición** | Solicitud interna de medicamentos de un servicio a la farmacia/almacén |
| **Transferencia** | Movimiento de medicamentos entre diferentes centros de salud |
| **Ajuste** | Corrección manual del inventario por merma, error de conteo, etc. |
| **RLS** | Row Level Security - Seguridad a nivel de fila en base de datos |
| **CRUD** | Create, Read, Update, Delete - Operaciones básicas de datos |

---

### Anexo B: Datos de Prueba Disponibles

**Centros de Salud:**
- HG-001: Hospital General Dr. Manuel Gea González
- HRAE-002: Hospital Regional de Alta Especialidad de Ixtapaluca
- CS-003: Centro de Salud T-III Balbuena
- HMI-004: Hospital Materno Infantil de Tlaxcala
- HC-005: Hospital Comunitario de Tepoztlán
- UNEME-006: UNEME Enfermedades Crónicas Guadalajara

**Medicamentos en Catálogo (30+):**
- Antibióticos: Amoxicilina, Ciprofloxacino, Azitromicina, Ceftriaxona
- Analgésicos: Paracetamol, Ibuprofeno, Ketorolaco, Diclofenaco
- Antihipertensivos: Losartán, Enalapril, Amlodipino
- Antidiabéticos: Metformina, Glibenclamida
- Y más...

**Proveedores (5):**
- Distribuidora Farmacéutica Nacional S.A. de C.V.
- Farmacéuticos Mayoristas Unidos
- Grupo Comercial de Medicamentos
- Insumos Médicos del Centro S.A.
- Proveedora Hospitalaria Integral

---

### Anexo C: Checklist de Navegadores

| Navegador | Versión | Sistema Operativo | Estado |
|-----------|---------|-------------------|--------|
| Chrome | | Windows 11 | [ ] Probado |
| Chrome | | macOS | [ ] Probado |
| Edge | | Windows 11 | [ ] Probado |
| Firefox | | Windows 11 | [ ] Probado |
| Firefox | | macOS | [ ] Probado |
| Safari | | macOS | [ ] Probado |

---

### Anexo D: Matriz de Trazabilidad

| ID Requisito | Descripción | Casos de Prueba | Estado |
|--------------|-------------|-----------------|--------|
| REQ-001 | Autenticación de usuarios | CP-001, CP-002, CP-003 | |
| REQ-002 | Gestión de inventario | CP-010, CP-011, CP-012, CP-013, CP-014 | |
| REQ-003 | Movimientos de stock | CP-020, CP-021 | |
| REQ-004 | Sistema de alertas | CP-030, CP-031, CP-032 | |
| REQ-005 | Requisiciones internas | CP-040, CP-041 | |
| REQ-006 | Transferencias | CP-050, CP-051 | |
| REQ-007 | Control de permisos | CP-060, CP-061 | |
| REQ-008 | Reportes | CP-070, CP-071 | |
| REQ-009 | Auditoría | CP-080, CP-081 | |
| REQ-010 | Rendimiento | CP-090, CP-091, CP-092 | |

---

### Anexo E: Resumen de Ejecución de Pruebas

**Fecha de Inicio de Pruebas:** _______________
**Fecha de Fin de Pruebas:** _______________
**Ejecutado por:** _______________
**Horas invertidas:** _______________

**Resultados Finales:**

| Categoría | Total | Pasados | Fallados | Bloqueados | % Éxito |
|-----------|-------|---------|----------|------------|---------|
| Críticos | | | | | |
| Altos | | | | | |
| Medios | | | | | |
| **TOTAL** | | | | | |

**Defectos Encontrados:**

| Severidad | Total | Resueltos | Pendientes |
|-----------|-------|-----------|------------|
| Críticos | | | |
| Altos | | | |
| Medios | | | |
| Bajos | | | |
| **TOTAL** | | | |

**Recomendación Final:**

[ ] **APROBADO** - El sistema cumple con los criterios de aceptación y está listo para producción

[ ] **APROBADO CON CONDICIONES** - El sistema puede pasar a producción pero requiere correcciones menores en paralelo

[ ] **RECHAZADO** - El sistema requiere correcciones mayores antes de pasar a producción

**Comentarios y Observaciones:**

_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

**Firma del Responsable de QA:**

Nombre: _______________________________________________
Firma: _______________________________________________
Fecha: _______________________________________________

---

**FIN DEL DOCUMENTO**

