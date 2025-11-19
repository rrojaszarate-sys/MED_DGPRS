# Plan de Pruebas de Escritorio - SIGIMED v2.0

**Sistema:** SIGIMED v2.0 (Sistema Integrado de Gestión de Inventario de Medicamentos)
**Versión:** 2.0
**Fecha:** 2025-11-19
**Responsable:** Equipo de Desarrollo
**Estado:** Para Ejecución Interna

---

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Objetivo](#objetivo)
3. [Alcance](#alcance)
4. [Prerequisitos](#prerequisitos)
5. [Casos de Prueba por Módulo](#casos-de-prueba-por-módulo)
6. [Registro de Resultados](#registro-de-resultados)
7. [Criterios de Aceptación](#criterios-de-aceptación)

---

## Introducción

Este documento describe el plan de pruebas de escritorio internas que deben realizarse antes de la validación externa por el equipo de calidad.

Las pruebas de escritorio verifican manualmente la funcionalidad de cada módulo del sistema desde la interfaz de usuario.

---

## Objetivo

Validar que todos los módulos del sistema funcionan correctamente de forma integrada, asegurando:

- Correcta visualización de datos
- Funcionalidad CRUD completa
- Navegación entre módulos
- Integridad de datos después de operaciones
- Comportamiento esperado de alertas y notificaciones
- Exportación e importación de datos

---

## Alcance

### Módulos a Probar

1. **Autenticación y Gestión de Usuarios**
2. **Dashboard Principal**
3. **Gestión de Centros de Salud**
4. **Catálogo de Medicamentos**
5. **Inventario de Medicamentos**
6. **Gestión de Lotes**
7. **Movimientos de Stock**
8. **Alertas de Caducidad**
9. **Requisiciones Internas**
10. **Transferencias entre Centros**
11. **Proveedores**
12. **Contratos**
13. **Ajustes de Inventario**
14. **Auditoría y Trazabilidad**
15. **Reportes y Exportaciones**

---

## Prerequisitos

### Datos de Prueba

Ejecutar los siguientes scripts en orden:

```bash
# 1. Generar inventario aleatorio
psql $DATABASE_URL -f scripts/01_generar_inventario_aleatorio.sql

# 2. Generar datos completos
psql $DATABASE_URL -f scripts/02_generar_datos_completos.sql

# 3. Ejecutar pruebas automatizadas
psql $DATABASE_URL -f scripts/03_pruebas_automatizadas.sql
```

### Usuarios de Prueba

| Email                      | Contraseña | Rol              | Centro Asignado |
|----------------------------|------------|------------------|-----------------|
| superadmin@sigimed.test    | Test123!   | super_admin      | Todos           |
| admin.hgm@sigimed.test     | Test123!   | admin_center     | HG-001          |
| admin.hraei@sigimed.test   | Test123!   | admin_center     | HRAE-002        |
| inventario1@sigimed.test   | Test123!   | inventory_user   | Aleatorio       |
| readonly1@sigimed.test     | Test123!   | read_only        | Aleatorio       |

### Navegadores Soportados

- ✅ Chrome/Edge (Chromium) versión 90+
- ✅ Firefox versión 88+
- ✅ Safari versión 14+

---

## Casos de Prueba por Módulo

---

### MÓDULO 1: Autenticación y Gestión de Usuarios

#### Prueba 1.1: Login Exitoso

**Pasos:**
1. Navegar a la página de login
2. Ingresar email: `superadmin@sigimed.test`
3. Ingresar contraseña: `Test123!`
4. Hacer clic en "Iniciar Sesión"

**Resultado Esperado:**
- ✅ Redirige al Dashboard
- ✅ Muestra nombre del usuario en la barra superior
- ✅ Muestra rol del usuario

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 1.2: Login con Credenciales Incorrectas

**Pasos:**
1. Navegar a la página de login
2. Ingresar email: `test@test.com`
3. Ingresar contraseña: `wrongpassword`
4. Hacer clic en "Iniciar Sesión"

**Resultado Esperado:**
- ✅ Muestra mensaje de error
- ✅ No redirige a ninguna página
- ✅ Campos permanecen con los valores ingresados

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 1.3: Gestión de Usuarios (Super Admin)

**Prerequisito:** Iniciar sesión como superadmin

**Pasos:**
1. Navegar a "Administración" → "Usuarios"
2. Verificar que se muestra la lista de usuarios
3. Filtrar usuarios por rol "inventory_user"
4. Hacer clic en "Agregar Usuario"
5. Llenar formulario:
   - Nombre: "Usuario Prueba Escritorio"
   - Email: "escritorio@test.local"
   - Rol: "inventory_user"
   - Centro: Seleccionar cualquiera
6. Guardar

**Resultado Esperado:**
- ✅ Lista muestra todos los usuarios
- ✅ Filtro funciona correctamente
- ✅ Formulario se abre correctamente
- ✅ Usuario se crea exitosamente
- ✅ Aparece mensaje de confirmación
- ✅ Nuevo usuario aparece en la lista

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 2: Dashboard Principal

#### Prueba 2.1: Visualización de KPIs

**Prerequisito:** Iniciar sesión como admin_center

**Pasos:**
1. Navegar al Dashboard
2. Observar las tarjetas de KPIs principales

**Resultado Esperado:**
- ✅ Muestra "Total Medicamentos"
- ✅ Muestra "Stock Total"
- ✅ Muestra "Alertas Activas"
- ✅ Muestra "Movimientos del Mes"
- ✅ Números son > 0 (si hay datos)
- ✅ Animación de carga funciona

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 2.2: Gráfico de Alertas por Nivel

**Pasos:**
1. En el Dashboard, ubicar el gráfico de "Alertas por Nivel"
2. Verificar que muestra:
   - Críticas (rojo)
   - Urgentes (amarillo)
   - Preventivas (azul)

**Resultado Esperado:**
- ✅ Gráfico se renderiza correctamente
- ✅ Muestra datos de alertas
- ✅ Colores corresponden a niveles
- ✅ Tooltip funciona al hacer hover

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 2.3: Medicamentos Próximos a Vencer

**Pasos:**
1. En el Dashboard, ubicar sección "Medicamentos Próximos a Vencer"
2. Verificar lista de medicamentos

**Resultado Esperado:**
- ✅ Muestra lista de medicamentos
- ✅ Ordenados por fecha de caducidad (más próxima primero)
- ✅ Muestra días restantes
- ✅ Colores de alerta apropiados
- ✅ Se puede hacer clic para ver detalles

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 3: Gestión de Centros de Salud

#### Prueba 3.1: Listar Centros de Salud

**Prerequisito:** Iniciar sesión como superadmin

**Pasos:**
1. Navegar a "Centros de Salud"
2. Observar la lista de centros

**Resultado Esperado:**
- ✅ Muestra tabla con centros
- ✅ Columnas: Código, Nombre, Ciudad, Capacidad, Estado
- ✅ Muestra al menos 3 centros (datos de prueba)
- ✅ Paginación funciona si hay más de 10

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 3.2: Crear Nuevo Centro

**Pasos:**
1. En "Centros de Salud", hacer clic en "Nuevo Centro"
2. Llenar formulario:
   - Código: "TEST-099"
   - Nombre: "Centro de Prueba Escritorio"
   - Ciudad: "Ciudad de Prueba"
   - Dirección: "Calle Falsa 123"
   - Teléfono: "5551234567"
   - Email: "prueba@test.local"
   - Capacidad: 1000
   - ¿Tiene refrigeración?: Sí
3. Guardar

**Resultado Esperado:**
- ✅ Formulario se abre correctamente
- ✅ Validaciones funcionan (campos requeridos)
- ✅ Centro se crea exitosamente
- ✅ Mensaje de confirmación aparece
- ✅ Nuevo centro aparece en la lista

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 3.3: Editar Centro Existente

**Pasos:**
1. En la lista de centros, hacer clic en "Editar" del centro "HG-001"
2. Modificar campo "Capacidad" a 6000
3. Guardar

**Resultado Esperado:**
- ✅ Formulario se abre con datos actuales
- ✅ Se puede modificar el campo
- ✅ Guardar actualiza correctamente
- ✅ Cambio se refleja en la lista

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 4: Catálogo de Medicamentos

#### Prueba 4.1: Visualizar Catálogo

**Prerequisito:** Iniciar sesión como superadmin o admin_center

**Pasos:**
1. Navegar a "Administración" → "Catálogo de Medicamentos"
2. Observar la lista

**Resultado Esperado:**
- ✅ Muestra tabla de medicamentos del catálogo
- ✅ Al menos 20 medicamentos visibles
- ✅ Columnas: Nombre Comercial, Genérico, Forma, Concentración
- ✅ Búsqueda funciona

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 4.2: Buscar Medicamento en Catálogo

**Pasos:**
1. En el catálogo, usar la búsqueda
2. Escribir: "Paracetamol"
3. Observar resultados

**Resultado Esperado:**
- ✅ Filtra resultados mientras se escribe
- ✅ Muestra medicamentos que contienen "Paracetamol"
- ✅ Búsqueda no distingue mayúsculas/minúsculas

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 4.3: Ver Detalles de Medicamento

**Pasos:**
1. En el catálogo, hacer clic en un medicamento
2. Observar modal o página de detalles

**Resultado Esperado:**
- ✅ Muestra información completa:
  - Nombre comercial y genérico
  - Fórmula activa
  - Concentración
  - Forma farmacéutica
  - Uso terapéutico
  - Contraindicaciones
  - Efectos secundarios
  - Dosis usual
  - Condiciones de almacenamiento

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 5: Inventario de Medicamentos

#### Prueba 5.1: Visualizar Inventario del Centro

**Prerequisito:** Iniciar sesión como admin_center (HG-001)

**Pasos:**
1. Navegar a "Inventario"
2. Observar lista de medicamentos

**Resultado Esperado:**
- ✅ Muestra medicamentos del centro actual
- ✅ Columnas: Nombre, Lote, Cantidad, Caducidad, Estado
- ✅ Solo muestra medicamentos del centro HG-001
- ✅ Cantidad total visible en la parte superior

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 5.2: Filtrar Inventario por Estado

**Pasos:**
1. En Inventario, usar filtro de "Estado"
2. Seleccionar "Disponible"
3. Observar resultados

**Resultado Esperado:**
- ✅ Filtra correctamente por estado
- ✅ Solo muestra medicamentos disponibles
- ✅ Contador se actualiza

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 5.3: Agregar Medicamento al Inventario

**Prerequisito:** Iniciar sesión como admin_center

**Pasos:**
1. En Inventario, hacer clic en "Agregar Medicamento"
2. Llenar formulario:
   - Medicamento (del catálogo): Seleccionar "Ibuprofeno"
   - Lote: "LOTE-TEST-2025-001"
   - Cantidad: 100
   - Fecha de Caducidad: (1 año en el futuro)
   - Proveedor: Seleccionar cualquiera
   - Ubicación: "Estante A-1"
3. Guardar

**Resultado Esperado:**
- ✅ Formulario valida campos requeridos
- ✅ Selector de catálogo funciona
- ✅ Medicamento se agrega exitosamente
- ✅ Aparece en la lista de inventario
- ✅ Se genera movimiento de entrada automático

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 6: Gestión de Lotes

#### Prueba 6.1: Ver Lotes de un Medicamento

**Pasos:**
1. En Inventario, hacer clic en un medicamento
2. Ver sección de "Lotes" o "Detalles"

**Resultado Esperado:**
- ✅ Muestra todos los lotes del medicamento
- ✅ Para cada lote: número, cantidad, caducidad, estado
- ✅ Diferencia visualmente lotes próximos a vencer

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 6.2: Historial de Movimientos de Lote

**Pasos:**
1. Seleccionar un lote específico
2. Ver "Historial de Movimientos"

**Resultado Esperado:**
- ✅ Muestra timeline de movimientos
- ✅ Para cada movimiento: tipo, cantidad, fecha, usuario
- ✅ Ordenado cronológicamente (más reciente primero)
- ✅ Iconos apropiados por tipo de movimiento

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 7: Movimientos de Stock

#### Prueba 7.1: Registrar Salida de Medicamento

**Prerequisito:** Iniciar sesión como inventory_user

**Pasos:**
1. Navegar a "Movimientos"
2. Hacer clic en "Registrar Salida"
3. Llenar formulario:
   - Medicamento: Seleccionar uno con cantidad > 10
   - Cantidad: 5
   - Motivo: "Dispensación a urgencias"
   - Observaciones: "Prueba de escritorio"
4. Guardar

**Resultado Esperado:**
- ✅ Valida que hay stock suficiente
- ✅ Movimiento se registra correctamente
- ✅ Cantidad del medicamento se reduce en 5
- ✅ Aparece en historial de movimientos
- ✅ Se registra en auditoría

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 7.2: Registrar Entrada de Medicamento

**Pasos:**
1. En "Movimientos", hacer clic en "Registrar Entrada"
2. Llenar formulario:
   - Medicamento: Seleccionar cualquiera
   - Cantidad: 50
   - Motivo: "Compra a proveedor"
   - Número de Documento: "FACT-2025-001"
3. Guardar

**Resultado Esperado:**
- ✅ Entrada se registra correctamente
- ✅ Cantidad del medicamento aumenta en 50
- ✅ Movimiento aparece en historial

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 7.3: Filtrar Movimientos por Tipo

**Pasos:**
1. En "Movimientos", ver lista completa
2. Usar filtro "Tipo de Movimiento"
3. Seleccionar "Salida"

**Resultado Esperado:**
- ✅ Filtra solo movimientos de tipo "salida"
- ✅ Contador se actualiza
- ✅ Se puede limpiar filtro

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 8: Alertas de Caducidad

#### Prueba 8.1: Visualizar Alertas Activas

**Pasos:**
1. Navegar a "Alertas"
2. Observar lista de alertas

**Resultado Esperado:**
- ✅ Muestra alertas no resueltas
- ✅ Agrupa por nivel: Crítico, Urgente, Preventivo
- ✅ Muestra: medicamento, lote, días restantes, centro
- ✅ Colores apropiados por nivel

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 8.2: Marcar Alerta como Vista

**Pasos:**
1. En lista de alertas, seleccionar una
2. Hacer clic en "Marcar como Vista"

**Resultado Esperado:**
- ✅ Alerta se marca como vista
- ✅ Cambia visualmente (ej: opacidad reducida)
- ✅ Se registra usuario y fecha

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 8.3: Resolver Alerta

**Pasos:**
1. Seleccionar una alerta crítica
2. Hacer clic en "Resolver"
3. Ingresar motivo: "Medicamento retirado del inventario"
4. Confirmar

**Resultado Esperado:**
- ✅ Solicita confirmación
- ✅ Alerta se marca como resuelta
- ✅ Desaparece de lista de activas
- ✅ Se registra en auditoría

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 9: Requisiciones Internas

#### Prueba 9.1: Crear Requisición

**Prerequisito:** Iniciar sesión como inventory_user

**Pasos:**
1. Navegar a "Requisiciones"
2. Hacer clic en "Nueva Requisición"
3. Llenar formulario:
   - Servicio Solicitante: "Urgencias"
   - Prioridad: "Normal"
   - Fecha Necesaria: (7 días en el futuro)
4. Agregar items:
   - Medicamento 1: Paracetamol, Cantidad: 50
   - Medicamento 2: Ibuprofeno, Cantidad: 30
5. Guardar

**Resultado Esperado:**
- ✅ Formulario valida campos
- ✅ Se pueden agregar múltiples items
- ✅ Requisición se crea con estado "solicitada"
- ✅ Se genera número de requisición automático
- ✅ Aparece en lista de requisiciones

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 9.2: Aprobar Requisición

**Prerequisito:** Iniciar sesión como admin_center

**Pasos:**
1. En "Requisiciones", filtrar por "Solicitadas"
2. Seleccionar una requisición
3. Hacer clic en "Aprobar"
4. Revisar items y ajustar cantidades aprobadas si es necesario
5. Confirmar aprobación

**Resultado Esperado:**
- ✅ Muestra detalles de la requisición
- ✅ Permite modificar cantidades aprobadas
- ✅ Estado cambia a "aprobada"
- ✅ Se registra usuario y fecha de aprobación

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 9.3: Surtir Requisición

**Pasos:**
1. Seleccionar requisición aprobada
2. Hacer clic en "Surtir"
3. Para cada item, confirmar cantidad surtida
4. Finalizar surtido

**Resultado Esperado:**
- ✅ Valida que hay stock suficiente
- ✅ Genera movimientos de salida por cada item
- ✅ Reduce cantidades en inventario
- ✅ Estado cambia a "surtida"
- ✅ Se puede imprimir comprobante

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 10: Transferencias entre Centros

#### Prueba 10.1: Crear Transferencia

**Prerequisito:** Iniciar sesión como admin_center (HG-001)

**Pasos:**
1. Navegar a "Transferencias"
2. Hacer clic en "Nueva Transferencia"
3. Llenar formulario:
   - Centro Destino: Seleccionar "HRAE-002"
   - Motivo: "Redistribución de stock"
4. Agregar items:
   - Medicamento 1: Seleccionar uno con cantidad > 20, Cantidad: 10
5. Crear transferencia

**Resultado Esperado:**
- ✅ Solo muestra centros diferentes al origen
- ✅ Valida stock disponible
- ✅ Transferencia se crea con estado "pending"
- ✅ Se genera número de transferencia

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 10.2: Aprobar Transferencia

**Prerequisito:** Iniciar sesión como superadmin

**Pasos:**
1. En "Transferencias", filtrar por "Pendientes"
2. Seleccionar transferencia creada anteriormente
3. Revisar detalles
4. Hacer clic en "Aprobar"

**Resultado Esperado:**
- ✅ Muestra detalles completos
- ✅ Estado cambia a "approved"
- ✅ Se registra usuario aprobador
- ✅ Notifica a centro origen

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 10.3: Marcar como Enviada

**Prerequisito:** Iniciar sesión como admin del centro origen

**Pasos:**
1. Seleccionar transferencia aprobada
2. Hacer clic en "Marcar como Enviada"
3. Ingresar número de guía/tracking
4. Confirmar

**Resultado Esperado:**
- ✅ Solicita número de tracking
- ✅ Estado cambia a "in_transit"
- ✅ Genera movimientos de salida en centro origen
- ✅ Reduce inventario del centro origen

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 10.4: Recibir Transferencia

**Prerequisito:** Iniciar sesión como admin del centro destino

**Pasos:**
1. En "Transferencias", ver "En Tránsito"
2. Seleccionar transferencia enviada
3. Hacer clic en "Recibir"
4. Confirmar cantidades recibidas
5. Finalizar recepción

**Resultado Esperado:**
- ✅ Permite confirmar/modificar cantidades
- ✅ Estado cambia a "received"
- ✅ Genera movimientos de entrada en centro destino
- ✅ Aumenta inventario del centro destino
- ✅ Si hay diferencias, las registra

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 11: Proveedores

#### Prueba 11.1: Listar Proveedores

**Pasos:**
1. Navegar a "Proveedores"
2. Observar lista

**Resultado Esperado:**
- ✅ Muestra tabla de proveedores
- ✅ Columnas: Nombre, RUC, Ciudad, Teléfono, Rating, Estado
- ✅ Al menos 3 proveedores (datos de prueba)

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 11.2: Crear Proveedor

**Prerequisito:** Iniciar sesión como admin_center o superadmin

**Pasos:**
1. Hacer clic en "Nuevo Proveedor"
2. Llenar formulario:
   - Nombre: "Proveedor de Prueba S.A."
   - RUC: "TEST123456789"
   - Dirección: "Av. Test 123"
   - Ciudad: "Ciudad de Prueba"
   - Teléfono: "5559998888"
   - Email: "proveedortest@test.com"
   - Términos de Pago: "30 días"
3. Guardar

**Resultado Esperado:**
- ✅ Validaciones funcionan
- ✅ RUC debe ser único
- ✅ Proveedor se crea correctamente
- ✅ Aparece en la lista

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 11.3: Calificar Proveedor

**Pasos:**
1. Seleccionar un proveedor
2. Ver opción "Calificar"
3. Asignar rating: 4.5 estrellas
4. Agregar comentario
5. Guardar

**Resultado Esperado:**
- ✅ Permite asignar rating (0-5 estrellas)
- ✅ Rating se actualiza
- ✅ Comentario se guarda
- ✅ Se muestra en historial

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 12: Contratos

#### Prueba 12.1: Ver Lista de Contratos

**Prerequisito:** Iniciar sesión como superadmin

**Pasos:**
1. Navegar a "Contratos"
2. Observar lista

**Resultado Esperado:**
- ✅ Muestra contratos existentes
- ✅ Columnas: Código, Proveedor, Estado, Vigencia, Monto
- ✅ Indica contratos activos vs vencidos

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 12.2: Ver Detalles de Contrato

**Pasos:**
1. Hacer clic en un contrato activo
2. Observar detalles

**Resultado Esperado:**
- ✅ Muestra información completa del contrato
- ✅ Lista de items incluidos
- ✅ Montos y términos
- ✅ Estado y fechas
- ✅ Documentos adjuntos (si los hay)

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 13: Ajustes de Inventario

#### Prueba 13.1: Crear Ajuste por Merma

**Prerequisito:** Iniciar sesión como admin_center

**Pasos:**
1. Navegar a "Ajustes de Inventario"
2. Hacer clic en "Nuevo Ajuste"
3. Llenar formulario:
   - Tipo: "Merma"
   - Medicamento: Seleccionar uno
   - Cantidad en Sistema: (Se llena automáticamente)
   - Cantidad Física: (Menor a la del sistema)
   - Motivo: "Daño durante almacenamiento"
   - Justificación: "Frasco roto encontrado en inventario físico"
4. Guardar

**Resultado Esperado:**
- ✅ Muestra cantidad actual del sistema
- ✅ Calcula diferencia automáticamente
- ✅ Requiere motivo y justificación
- ✅ Ajuste se registra correctamente
- ✅ Actualiza cantidad en inventario
- ✅ Genera movimiento de ajuste

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 13.2: Crear Ajuste por Corrección

**Pasos:**
1. Crear nuevo ajuste tipo "Corrección"
2. Seleccionar medicamento
3. Ingresar cantidad física diferente a la del sistema
4. Justificar
5. Guardar

**Resultado Esperado:**
- ✅ Permite cantidad mayor o menor
- ✅ Registra diferencia
- ✅ Actualiza inventario
- ✅ Se puede requerir autorización

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 14: Auditoría y Trazabilidad

#### Prueba 14.1: Ver Log de Auditoría

**Prerequisito:** Iniciar sesión como superadmin

**Pasos:**
1. Navegar a "Auditoría"
2. Ver lista de eventos

**Resultado Esperado:**
- ✅ Muestra eventos recientes
- ✅ Columnas: Fecha, Usuario, Acción, Entidad, Resultado
- ✅ Se puede filtrar por:
  - Usuario
  - Tipo de acción
  - Fecha
  - Entidad

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 14.2: Ver Trazabilidad de Medicamento

**Pasos:**
1. En Inventario, seleccionar un medicamento
2. Hacer clic en "Ver Trazabilidad"

**Resultado Esperado:**
- ✅ Muestra historial completo del medicamento
- ✅ Desde entrada hasta estado actual
- ✅ Todos los movimientos registrados
- ✅ Fechas, usuarios, cantidades
- ✅ Se puede exportar

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

### MÓDULO 15: Reportes y Exportaciones

#### Prueba 15.1: Exportar Inventario a Excel

**Pasos:**
1. En "Inventario", hacer clic en "Exportar"
2. Seleccionar formato "Excel (.xlsx)"
3. Descargar

**Resultado Esperado:**
- ✅ Genera archivo Excel
- ✅ Contiene todos los campos relevantes
- ✅ Formato correcto (columnas, encabezados)
- ✅ Se puede abrir sin errores

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 15.2: Exportar a PDF

**Pasos:**
1. Seleccionar cualquier reporte
2. Hacer clic en "Exportar a PDF"
3. Descargar

**Resultado Esperado:**
- ✅ Genera archivo PDF
- ✅ Formato profesional
- ✅ Incluye encabezados y pie de página
- ✅ Logo y datos de la institución
- ✅ Fecha de generación

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

#### Prueba 15.3: Generar Reporte de Movimientos

**Pasos:**
1. Navegar a "Reportes"
2. Seleccionar "Reporte de Movimientos"
3. Configurar parámetros:
   - Fecha Inicio: (30 días atrás)
   - Fecha Fin: (Hoy)
   - Centro: (Actual)
   - Tipo de Movimiento: (Todos)
4. Generar

**Resultado Esperado:**
- ✅ Genera reporte con filtros aplicados
- ✅ Muestra todos los movimientos del periodo
- ✅ Incluye totales y resumen
- ✅ Se puede exportar

**Estado:** [ ] Pasó [ ] Falló [ ] No Ejecutado
**Notas:** _______________________________________________

---

## Registro de Resultados

### Resumen de Ejecución

**Fecha de Inicio:** _______________
**Fecha de Fin:** _______________
**Ejecutado por:** _______________
**Ambiente:** [ ] Desarrollo [ ] Staging [ ] Producción

### Resultados por Módulo

| Módulo | Total Pruebas | Pasadas | Fallidas | Bloqueadas | % Éxito |
|--------|---------------|---------|----------|------------|---------|
| 1. Autenticación | 3 | | | | |
| 2. Dashboard | 3 | | | | |
| 3. Centros | 3 | | | | |
| 4. Catálogo | 3 | | | | |
| 5. Inventario | 3 | | | | |
| 6. Lotes | 2 | | | | |
| 7. Movimientos | 3 | | | | |
| 8. Alertas | 3 | | | | |
| 9. Requisiciones | 3 | | | | |
| 10. Transferencias | 4 | | | | |
| 11. Proveedores | 3 | | | | |
| 12. Contratos | 2 | | | | |
| 13. Ajustes | 2 | | | | |
| 14. Auditoría | 2 | | | | |
| 15. Reportes | 3 | | | | |
| **TOTAL** | **42** | | | | |

---

## Criterios de Aceptación

### Para Pasar a Validación Externa

El sistema debe cumplir:

- ✅ **Mínimo 90% de pruebas pasadas** (38/42)
- ✅ **Cero pruebas bloqueadas** por errores críticos
- ✅ **Módulos críticos al 100%:**
  - Autenticación
  - Inventario
  - Alertas
  - Auditoría

### Severidad de Defectos

**Crítico:** Bloquea funcionalidad principal, pérdida de datos
**Alto:** Funcionalidad importante no funciona, workaround difícil
**Medio:** Funcionalidad menor afectada, existe workaround
**Bajo:** Cosmético, no afecta funcionalidad

---

## Defectos Encontrados

| ID | Módulo | Prueba | Descripción | Severidad | Estado |
|----|--------|--------|-------------|-----------|--------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |

---

## Observaciones Generales

_Espacio para notas, observaciones y recomendaciones del equipo de pruebas:_

---

---

**Firma del Responsable de Pruebas:** _______________

**Fecha:** _______________

