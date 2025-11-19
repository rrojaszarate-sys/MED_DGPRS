# PLAN DE VALIDACIÓN EXTERNA - EQUIPO QA
## SIGIMED v2.0

---

## 📋 INFORMACIÓN DEL DOCUMENTO

**Sistema:** SIGIMED v2.0 - Sistema Integrado de Gestión de Inventario de Medicamentos
**Versión:** 2.0.0
**Fecha de Emisión:** 2025-11-19
**Responsable:** Equipo de Desarrollo
**Destinatario:** Equipo de Calidad (QA)
**Ambiente de Pruebas:** [URL de Vercel]

---

## 🎯 OBJETIVO

Validar que el sistema SIGIMED v2.0 cumple con todos los requerimientos funcionales y no funcionales antes de su paso a producción.

---

## 📦 ALCANCE

Este plan cubre:
- ✅ Funcionalidades principales (13 módulos)
- ✅ Flujos de trabajo completos (end-to-end)
- ✅ Seguridad y permisos por rol
- ✅ Rendimiento y usabilidad
- ✅ Compatibilidad con dispositivos y navegadores

**Fuera de alcance:**
- ❌ Pruebas de carga masiva (se realizarán en fase posterior)
- ❌ Pruebas de penetración (se realizarán por equipo especializado)

---

## 👥 ROLES Y RESPONSABILIDADES

| Rol | Responsable | Responsabilidades |
|-----|-------------|-------------------|
| QA Lead | [Nombre] | Coordinar equipo QA, aprobar resultados |
| QA Tester 1 | [Nombre] | Módulos 1-5 |
| QA Tester 2 | [Nombre] | Módulos 6-10 |
| QA Tester 3 | [Nombre] | Módulos 11-13 |
| Product Owner | [Nombre] | Validar que cumple requisitos de negocio |
| Dev Lead | [Nombre] | Soporte técnico, correcciones |

---

## 🔑 CREDENCIALES DE ACCESO

**IMPORTANTE:** Estas credenciales son solo para ambiente de pruebas.

| Rol | Email | Contraseña | Permisos |
|-----|-------|------------|----------|
| Super Admin | admin@sigimed.com | [Proporcionada por separado] | Acceso total |
| Admin Centro | admin_centro@sigimed.com | [Proporcionada por separado] | Su centro asignado |
| Inventario | inventario@sigimed.com | [Proporcionada por separado] | Operaciones de inventario |
| Solo Lectura | lectura@sigimed.com | [Proporcionada por separado] | Ver información |

---

## 📊 DATOS DE PRUEBA DISPONIBLES

El sistema cuenta con datos de prueba precargados:

- **23 Centros de Salud** activos
- **99 Medicamentos** en catálogo maestro
- **2,277 Medicamentos** en inventario (distribuidos en centros)
- **2,277 Lotes** de medicamentos
- **2,277+ Movimientos** de inventario
- **3 Proveedores** activos
- **81 Registros** en catálogos administrables
- **Casos especiales:**
  - 50 lotes vencidos
  - 100 lotes con stock bajo
  - Medicamentos en cuarentena
  - Movimientos de todos los tipos

---

## 🧪 METODOLOGÍA DE PRUEBAS

### Tipos de Pruebas

1. **Pruebas Funcionales** - Verificar que cada función hace lo esperado
2. **Pruebas de Integración** - Verificar flujos completos end-to-end
3. **Pruebas de Usabilidad** - Verificar experiencia de usuario
4. **Pruebas de Seguridad** - Verificar permisos y validaciones
5. **Pruebas de Compatibilidad** - Verificar en diferentes dispositivos/navegadores

### Niveles de Severidad

| Nivel | Descripción | Acción |
|-------|-------------|--------|
| 🔴 **CRÍTICO** | Sistema no funciona o pérdida de datos | Bloquea release |
| 🟠 **ALTO** | Funcionalidad principal no funciona | Debe corregirse antes de release |
| 🟡 **MEDIO** | Funcionalidad secundaria afectada | Evaluar si bloquea release |
| 🟢 **BAJO** | Mejora cosmética o UX menor | Puede pasar a backlog |

### Criterios de Aceptación

✅ **APROBADO** si:
- 0 errores críticos
- ≤ 2 errores altos (con plan de corrección)
- ≤ 5 errores medios
- Errores bajos documentados

❌ **RECHAZADO** si:
- ≥ 1 error crítico
- ≥ 3 errores altos
- Funcionalidad core no opera

---

## 📝 CASOS DE PRUEBA

### MÓDULO 1: AUTENTICACIÓN Y USUARIOS

#### TC-001: Login Exitoso
**Precondiciones:** Usuario existe en BD
**Pasos:**
1. Ir a `/login`
2. Ingresar email: `admin@sigimed.com`
3. Ingresar contraseña correcta
4. Click en "Iniciar Sesión"

**Resultado Esperado:**
- Redirige a dashboard
- Muestra nombre de usuario en header
- Token guardado en localStorage

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-002: Login con Credenciales Incorrectas
**Precondiciones:** -
**Pasos:**
1. Ir a `/login`
2. Ingresar email: `test@test.com`
3. Ingresar contraseña: `wrongpassword`
4. Click en "Iniciar Sesión"

**Resultado Esperado:**
- Muestra mensaje de error
- No redirige
- No guarda token

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-003: Cierre de Sesión
**Precondiciones:** Usuario logueado
**Pasos:**
1. Estando logueado, click en icono de usuario
2. Click en "Cerrar Sesión"

**Resultado Esperado:**
- Limpia token de localStorage
- Redirige a `/login`
- Intentar volver a rutas protegidas redirige a login

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 2: INSTITUCIONES

#### TC-004: Ver Listado de Instituciones
**Precondiciones:** Logueado como Super Admin
**Pasos:**
1. Navegar a `/instituciones`
2. Observar tabla

**Resultado Esperado:**
- Muestra 2 instituciones iniciales (IMSS, ISSSTE)
- Tabla muestra: nombre, clave, tipo, estado
- Tiene botón "Nueva Institución"

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-005: Crear Nueva Institución
**Precondiciones:** Logueado como Super Admin
**Pasos:**
1. En `/instituciones`, click "Nueva Institución"
2. Llenar formulario:
   - Nombre: "Institución de Prueba QA"
   - Clave: "IQA-001"
   - Tipo: "Público"
   - Descripción: "Creada por equipo QA para pruebas"
3. Click en "Guardar"

**Resultado Esperado:**
- Se crea la institución
- Aparece en el listado
- Muestra mensaje de éxito

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-006: Validación de Campos Requeridos
**Precondiciones:** Logueado como Super Admin
**Pasos:**
1. Click "Nueva Institución"
2. Dejar campos vacíos
3. Click "Guardar"

**Resultado Esperado:**
- Muestra errores de validación
- No guarda el registro
- Resalta campos requeridos en rojo

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 3: CENTROS DE SALUD

#### TC-007: Filtrar Centros por Institución
**Precondiciones:** Logueado, existen centros
**Pasos:**
1. Ir a `/centros`
2. Seleccionar filtro "Institución" → IMSS
3. Aplicar filtro

**Resultado Esperado:**
- Solo muestra centros de IMSS
- Contador actualizado
- Otros centros no visibles

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-008: Búsqueda de Centro por Código
**Precondiciones:** Conocer código de un centro (ej: HGZ1)
**Pasos:**
1. En `/centros`, en buscador ingresar: "HGZ1"
2. Presionar Enter o click en buscar

**Resultado Esperado:**
- Muestra solo el centro con código HGZ1
- Búsqueda insensible a mayúsculas/minúsculas

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 4: CATÁLOGOS ADMINISTRABLES

#### TC-009: Crear Nuevo Color
**Precondiciones:** Logueado como Super Admin
**Pasos:**
1. Ir a `/catalogos`, tab "Colores"
2. Click "Nuevo Color"
3. Llenar:
   - Nombre: "Color Prueba QA"
   - Código HEX: #FF5733
   - Categoría: "Alertas"
4. Guardar

**Resultado Esperado:**
- Color se crea
- Preview muestra el color correcto
- Aparece en listado

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-010: Validar Código HEX Inválido
**Precondiciones:** En formulario de color
**Pasos:**
1. Ingresar código HEX inválido: "GGGGGG"
2. Intentar guardar

**Resultado Esperado:**
- Muestra error de validación
- No guarda
- Indica formato correcto (#RRGGBB)

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 5: INVENTARIO

#### TC-011: Ver Inventario de un Centro Específico
**Precondiciones:** Logueado
**Pasos:**
1. Ir a `/inventario`
2. Filtrar por centro: "Hospital General de Zona No. 1"
3. Aplicar

**Resultado Esperado:**
- Solo muestra medicamentos de ese centro
- Muestra cantidades actuales
- Muestra estado de cada medicamento

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-012: Alerta de Stock Bajo
**Precondiciones:** Existen medicamentos con cantidad < stock mínimo
**Pasos:**
1. Ir a dashboard o sección de alertas
2. Filtrar por "Stock Bajo"

**Resultado Esperado:**
- Muestra lista de medicamentos con stock < mínimo
- Indica cantidad actual y mínima
- Tiene acción para reordenar/reabastecer

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 6: LOTES

#### TC-013: Ver Detalle Completo de un Lote
**Precondiciones:** Existe lote en BD
**Pasos:**
1. Ir a sección de lotes
2. Click en un lote específico

**Resultado Esperado:**
- Muestra toda la información:
  - Número de lote
  - Medicamento
  - Cantidades
  - Fechas
  - Ubicación
  - Proveedor
  - Historial de movimientos
- Información completa y legible

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-014: No Permitir Número de Lote Duplicado en Mismo Centro
**Precondiciones:** Existe lote "L-001" en Centro X
**Pasos:**
1. Crear nuevo lote
2. Mismo centro
3. Mismo número: "L-001"
4. Intentar guardar

**Resultado Esperado:**
- Muestra error: "Número de lote ya existe en este centro"
- No guarda
- Sugiere cambiar número

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 7: MOVIMIENTOS

#### TC-015: Registrar Entrada de Medicamento
**Precondiciones:** Existe lote activo
**Pasos:**
1. Ir a movimientos
2. Click "Nuevo Movimiento" → "Entrada"
3. Seleccionar lote
4. Cantidad: 500
5. Motivo: "Compra programada"
6. Documento: "OC-2025-001"
7. Guardar

**Resultado Esperado:**
- Movimiento registrado
- Stock del lote aumenta en 500
- Aparece en historial
- Muestra usuario y fecha

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-016: No Permitir Salida Mayor al Stock
**Precondiciones:** Lote tiene 100 unidades
**Pasos:**
1. Registrar salida
2. Ingresar cantidad: 150
3. Intentar guardar

**Resultado Esperado:**
- Muestra error: "Cantidad excede stock disponible"
- No guarda el movimiento
- Stock no cambia

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-017: Transferencia Entre Centros
**Precondiciones:** 2 centros activos, lote en centro A
**Pasos:**
1. Registrar transferencia
2. Origen: Centro A
3. Destino: Centro B
4. Lote del Centro A
5. Cantidad: 200
6. Guardar

**Resultado Esperado:**
- Se crean 2 movimientos:
  - Salida en Centro A
  - Entrada en Centro B
- Stock disminuye en A
- Stock aumenta en B
- Trazabilidad completa

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 8: PROVEEDORES

#### TC-018: Validar Formato de RFC
**Precondiciones:** Crear/editar proveedor
**Pasos:**
1. Ingresar RFC inválido: "ABC123"
2. Intentar guardar

**Resultado Esperado:**
- Muestra error de validación
- Indica formato correcto (XXX######XXX)
- No guarda

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-019: Calificación de Proveedor
**Precondiciones:** Proveedor existe
**Pasos:**
1. Editar proveedor
2. Cambiar calificación a 4.5 estrellas
3. Guardar

**Resultado Esperado:**
- Calificación actualizada
- Se muestra en listado
- Valor entre 0 y 5

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 9: REPORTES

#### TC-020: Generar Reporte de Inventario
**Precondiciones:** Logueado, hay datos
**Pasos:**
1. Ir a sección de reportes
2. Seleccionar "Reporte de Inventario"
3. Filtrar: Último mes, Todos los centros
4. Click "Generar"

**Resultado Esperado:**
- Se genera reporte
- Muestra datos correctos
- Tiene opción de exportar (Excel/PDF)
- Datos coinciden con BD

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-021: Exportar Reporte a Excel
**Precondiciones:** Reporte generado
**Pasos:**
1. Con reporte en pantalla
2. Click "Exportar a Excel"

**Resultado Esperado:**
- Descarga archivo .xlsx
- Archivo se abre correctamente
- Datos completos y formateados
- Nombre de archivo descriptivo

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 10: SEGURIDAD Y PERMISOS

#### TC-022: Usuario Sin Permiso No Puede Acceder a Catálogos
**Precondiciones:** Logueado como "Solo Lectura"
**Pasos:**
1. Intentar ir a `/catalogos`
2. O buscar opción en menú

**Resultado Esperado:**
- Opción no aparece en menú
- Si ingresa URL manualmente, redirige a error 403
- Muestra mensaje "No tienes permisos"

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-023: Admin Centro Solo Ve Su Centro
**Precondiciones:** Logueado como Admin Centro asignado a HGZ1
**Pasos:**
1. Ir a cualquier módulo de inventario/lotes
2. Ver filtros de centro

**Resultado Esperado:**
- Solo aparece su centro (HGZ1) en filtros
- No puede cambiar a otro centro
- Solo ve datos de su centro

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-024: Protección Contra SQL Injection
**Precondiciones:** En cualquier buscador
**Pasos:**
1. Ingresar: `'; DROP TABLE medicamentos; --`
2. Buscar

**Resultado Esperado:**
- Trata como texto normal
- No ejecuta SQL
- Sistema sigue funcionando
- Tablas intactas

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-025: Protección Contra XSS
**Precondiciones:** Formulario de texto
**Pasos:**
1. Ingresar: `<script>alert('XSS')</script>`
2. Guardar
3. Ver el registro guardado

**Resultado Esperado:**
- Script no se ejecuta
- Se muestra como texto plano escapado
- No aparece alert

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 11: RESPONSIVE Y COMPATIBILIDAD

#### TC-026: Navegación en Tablet (iPad)
**Precondiciones:** Abrir en tablet o usar DevTools (768x1024)
**Pasos:**
1. Navegar por todos los módulos
2. Probar menú
3. Usar formularios
4. Ver tablas

**Resultado Esperado:**
- Todo es accesible
- Menú funciona correctamente
- Tablas son scrollables
- Botones no se solapan

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-027: Uso en Móvil (iPhone)
**Precondiciones:** Abrir en móvil o DevTools (375x667)
**Pasos:**
1. Login en móvil
2. Navegar módulos principales
3. Probar formulario de movimiento

**Resultado Esperado:**
- Menú hamburguesa funciona
- Formularios en 1 columna
- Botones accesibles con pulgar
- Texto legible

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

#### TC-028: Compatibilidad Firefox
**Precondiciones:** Navegador Firefox actualizado
**Pasos:**
1. Abrir sistema
2. Usar todas las funcionalidades principales

**Resultado Esperado:**
- Funciona igual que en Chrome
- Sin errores en consola
- Gráficas se renderizan
- Estilos correctos

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### MÓDULO 12: RENDIMIENTO

#### TC-029: Carga Inicial de Dashboard
**Precondiciones:** Navegador limpio, sin caché
**Pasos:**
1. Limpiar caché
2. Login
3. Medir tiempo de carga de dashboard

**Resultado Esperado:**
- Carga en < 3 segundos
- Sin errores en consola
- Datos visibles

**Estado:** ⬜ Pass / ⬜ Fail
**Tiempo:** ___ segundos
**Observaciones:**

---

#### TC-030: Búsqueda en Tabla Grande (2000+ registros)
**Precondiciones:** Tabla de medicamentos con 2277 registros
**Pasos:**
1. Ir a listado de medicamentos
2. En buscador ingresar: "Paracetamol"
3. Presionar Enter
4. Medir tiempo de respuesta

**Resultado Esperado:**
- Resultados en < 1 segundo
- Filtrado correcto
- Sin congelamiento de UI

**Estado:** ⬜ Pass / ⬜ Fail
**Tiempo:** ___ ms
**Observaciones:**

---

## 📊 FLUJOS END-TO-END

### E2E-001: Flujo Completo de Ingreso de Medicamento

**Escenario:** Llega compra de medicamento nuevo, se registra en el sistema

**Pasos:**
1. Login como Admin Centro
2. Verificar que el medicamento existe en catálogo (si no, crearlo como Super Admin)
3. Ir a sección de inventario
4. Crear nuevo registro de medicamento para el centro
5. Crear lote asociado:
   - Número de lote del proveedor
   - Cantidad recibida
   - Fechas de fabricación y caducidad
   - Ubicación física
6. Registrar movimiento de entrada:
   - Tipo: Entrada
   - Motivo: Compra programada
   - Documento: Orden de compra
7. Verificar que:
   - Stock se actualizó correctamente
   - Movimiento aparece en historial
   - Lote está activo y disponible
8. Generar reporte de ingreso

**Resultado Esperado:**
✅ Medicamento queda registrado en inventario
✅ Stock refleja cantidad correcta
✅ Trazabilidad completa desde entrada
✅ Reporte generado correctamente

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### E2E-002: Flujo de Dispensación a Paciente

**Escenario:** Paciente solicita medicamento, se dispensa y registra salida

**Pasos:**
1. Login como Usuario Inventario
2. Buscar medicamento solicitado
3. Verificar stock disponible
4. Seleccionar lote con fecha de caducidad más próxima (FEFO)
5. Registrar salida:
   - Tipo: Salida
   - Cantidad dispensada
   - Motivo: Dispensación a paciente
   - Receta médica (número)
6. Verificar:
   - Stock disminuye correctamente
   - Si stock < mínimo, genera alerta
   - Movimiento registrado
7. Imprimir comprobante de dispensación

**Resultado Esperado:**
✅ Stock actualizado
✅ Alerta generada si es necesario
✅ Trazabilidad completa
✅ Comprobante impreso

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### E2E-003: Transferencia Entre Centros

**Escenario:** Centro A tiene exceso de medicamento, Centro B lo necesita

**Pasos:**
1. Login como Admin o Super Admin
2. Verificar stock en ambos centros
3. Desde Centro A, registrar transferencia:
   - Destino: Centro B
   - Medicamento y lote específico
   - Cantidad a transferir
   - Motivo y documento de transferencia
4. Verificar en Centro A:
   - Stock disminuye
   - Movimiento de salida registrado
5. Verificar en Centro B:
   - Stock aumenta
   - Movimiento de entrada registrado
   - Lote asociado al nuevo centro
6. Verificar trazabilidad:
   - Ambos movimientos vinculados
   - Mismo número de documento
7. Generar reporte de transferencia

**Resultado Esperado:**
✅ Stock correcto en ambos centros
✅ Doble asiento contable (salida + entrada)
✅ Trazabilidad completa
✅ Reporte de transferencia

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### E2E-004: Gestión de Medicamento Vencido

**Escenario:** Se detecta lote vencido, se da de baja

**Pasos:**
1. Login como Admin Centro
2. Ir a alertas o filtrar lotes vencidos
3. Seleccionar lote vencido
4. Verificar información:
   - Fecha de caducidad pasada
   - Cantidad restante
5. Registrar movimiento de baja:
   - Tipo: Vencimiento
   - Cantidad total del lote
   - Motivo: Caducidad
   - Acta de baja (documento)
6. Cambiar estado del lote a "Vencido"
7. Stock debe quedar en 0
8. Lote marcado como inactivo
9. Generar reporte de bajas del mes

**Resultado Esperado:**
✅ Lote marcado como vencido
✅ Stock en 0
✅ Movimiento de baja registrado
✅ No aparece en inventario activo
✅ Sí aparece en histórico

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

### E2E-005: Inventario Físico y Ajuste

**Escenario:** Se realiza inventario físico mensual, hay discrepancias

**Pasos:**
1. Login como Admin Centro
2. Generar reporte de inventario actual (pre-conteo)
3. Realizar conteo físico (simulado con números diferentes)
4. Detectar discrepancias:
   - Sistema: 1000 unidades
   - Físico: 980 unidades
   - Diferencia: -20
5. Registrar ajuste:
   - Tipo: Ajuste
   - Cantidad: -20
   - Motivo: Inventario físico - merma detectada
   - Acta de inventario
6. Stock se actualiza a 980
7. Generar reporte post-ajuste
8. Comparar reportes pre y post

**Resultado Esperado:**
✅ Discrepancia identificada
✅ Ajuste registrado con justificación
✅ Stock actualizado
✅ Reportes muestran diferencia
✅ Trazabilidad de ajuste

**Estado:** ⬜ Pass / ⬜ Fail
**Observaciones:**

---

## 📋 CHECKLIST DE VALIDACIÓN RÁPIDA

Esta checklist es para una validación rápida (30 minutos) antes de pruebas detalladas.

- [ ] Login funciona con todos los roles
- [ ] Dashboard carga sin errores
- [ ] Al menos 1 módulo CRUD funciona completamente (crear, leer, actualizar, eliminar)
- [ ] Búsqueda funciona en al menos 1 módulo
- [ ] Filtros funcionan
- [ ] Permisos básicos funcionan (Super Admin ve todo, Solo Lectura no puede editar)
- [ ] Responsive básico funciona (móvil y desktop)
- [ ] No hay errores en consola del navegador
- [ ] Datos se persisten correctamente en BD
- [ ] Logout funciona

---

## 🐛 REPORTE DE ERRORES

Para cada error encontrado, llenar la siguiente plantilla:

### BUG-[Número]

**Título:** [Descripción corta del error]

**Severidad:** 🔴 Crítico / 🟠 Alto / 🟡 Medio / 🟢 Bajo

**Módulo:** [Nombre del módulo]

**Ambiente:** [URL de pruebas]

**Usuario/Rol:** [Con qué usuario se encontró]

**Navegador:** [Chrome/Firefox/Safari + versión]

**Descripción:**
[Descripción detallada del error]

**Pasos para Reproducir:**
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

**Resultado Actual:**
[Qué pasa actualmente]

**Resultado Esperado:**
[Qué debería pasar]

**Evidencia:**
[Screenshots, videos, logs de consola]

**Workaround:**
[Si existe alguna forma de evitar el error temporalmente]

**Reportado por:** [Nombre]
**Fecha:** [Fecha]

---

## 📊 PLANTILLA DE REPORTE FINAL

Al finalizar todas las pruebas, llenar:

### Resumen Ejecutivo

**Total de Casos de Prueba:** [X]
**Casos Ejecutados:** [X]
**Casos Pasados:** [X]
**Casos Fallidos:** [X]
**Casos Bloqueados:** [X]
**% de Éxito:** [X%]

### Errores por Severidad

| Severidad | Cantidad | % del Total |
|-----------|----------|-------------|
| 🔴 Crítico | [X] | [X%] |
| 🟠 Alto | [X] | [X%] |
| 🟡 Medio | [X] | [X%] |
| 🟢 Bajo | [X] | [X%] |
| **TOTAL** | **[X]** | **100%** |

### Top 5 Errores Críticos

1. [Descripción breve]
2. [Descripción breve]
3. [Descripción breve]
4. [Descripción breve]
5. [Descripción breve]

### Recomendación Final

⬜ **APROBADO PARA PRODUCCIÓN**
⬜ **APROBADO CON OBSERVACIONES** (listar qué debe corregirse en próximo sprint)
⬜ **RECHAZADO** (requiere nueva ronda de pruebas después de correcciones)

**Justificación:**
[Explicar el porqué de la recomendación]

### Riesgos Identificados

1. [Riesgo 1 y su impacto]
2. [Riesgo 2 y su impacto]

### Mejoras Sugeridas

1. [Mejora 1]
2. [Mejora 2]

---

## 📞 CONTACTO Y SOPORTE

**Equipo de Desarrollo:**
- Dev Lead: [Nombre] - [Email]
- Backend Developer: [Nombre] - [Email]
- Frontend Developer: [Nombre] - [Email]

**Horario de Soporte durante QA:**
- Lunes a Viernes: 9:00 AM - 6:00 PM
- Canal: Slack #sigimed-qa o email

**Escalación:**
- Si error crítico bloquea pruebas: Notificar inmediatamente a Dev Lead
- Si error crítico requiere decisión de negocio: Notificar a Product Owner

---

## 📅 CRONOGRAMA SUGERIDO

| Día | Actividad | Responsable |
|-----|-----------|-------------|
| Día 1 | Setup, familiarización, checklist rápida | Todo el equipo |
| Día 2-3 | Casos de prueba funcionales (TC-001 a TC-030) | QA Testers |
| Día 4 | Flujos E2E (E2E-001 a E2E-005) | QA Testers |
| Día 5 | Pruebas de seguridad y rendimiento | QA Tester 3 |
| Día 6 | Pruebas de compatibilidad (navegadores/dispositivos) | Todo el equipo |
| Día 7 | Regresión de bugs corregidos | QA Testers |
| Día 8 | Reporte final y recomendación | QA Lead |

---

## ✅ FIRMA Y APROBACIÓN

**Preparado por:**
- Nombre: ___________________________
- Rol: Equipo de Desarrollo
- Fecha: 2025-11-19
- Firma: ___________________________

**Revisado y Aprobado por:**
- Nombre: ___________________________
- Rol: QA Lead
- Fecha: ___________________________
- Firma: ___________________________

**Aprobación Final:**
- Nombre: ___________________________
- Rol: Product Owner
- Fecha: ___________________________
- Firma: ___________________________

---

**CONFIDENCIAL** - Este documento es propiedad de [Organización] y no debe ser compartido fuera del equipo del proyecto sin autorización.
