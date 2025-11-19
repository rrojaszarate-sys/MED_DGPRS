# 📋 MANUAL DE PRUEBAS - SISTEMA DE CATÁLOGOS ADMINISTRABLES
## SIGIMED v2.0

**Versión:** 1.0
**Fecha:** 19 de Noviembre 2025
**Módulo:** Catálogos Administrables
**Usuario de Prueba:** superadmin@sigimed.test / admin_center@sigimed.test

---

## 📑 ÍNDICE

1. [Requisitos Previos](#requisitos-previos)
2. [Acceso al Sistema](#acceso-al-sistema)
3. [Pruebas por Catálogo](#pruebas-por-catálogo)
   - [3.1 Catálogo de Colores](#31-catálogo-de-colores)
   - [3.2 Catálogo de Estados](#32-catálogo-de-estados)
   - [3.3 Catálogo de Tipos de Movimiento](#33-catálogo-de-tipos-de-movimiento)
   - [3.4 Catálogo de Formas Farmacéuticas](#34-catálogo-de-formas-farmacéuticas)
   - [3.5 Catálogo de Prioridades](#35-catálogo-de-prioridades)
   - [3.6 Catálogo de Configuraciones](#36-catálogo-de-configuraciones)
4. [Pruebas de Seguridad](#pruebas-de-seguridad)
5. [Pruebas de Validación](#pruebas-de-validación)
6. [Checklist Final](#checklist-final)
7. [Reporte de Errores](#reporte-de-errores)

---

## 1. REQUISITOS PREVIOS

### ✅ Verificaciones Iniciales

- [ ] Base de datos poblada con migración `09_catalogos_administrables.sql`
- [ ] Servidor de desarrollo corriendo (`npm run dev`)
- [ ] Navegador moderno (Chrome 90+, Firefox 88+, Safari 14+)
- [ ] Consola del navegador abierta (F12) para monitorear errores
- [ ] Usuario con permisos de administrador (super_admin o admin_center)

### 🔧 Comandos Preparatorios

```bash
# 1. Verificar build
npm run build

# 2. Iniciar servidor de desarrollo
npm run dev

# 3. En otra terminal, verificar que las tablas existen
# (Requiere acceso a la base de datos)
# SELECT COUNT(*) FROM catalogo_colores;
# SELECT COUNT(*) FROM catalogo_estados;
# etc.
```

### 📊 Datos Esperados (Post-Migración)

| Tabla | Registros Esperados |
|-------|---------------------|
| `catalogo_colores` | 15 |
| `catalogo_estados` | 20 |
| `catalogo_tipos_movimiento` | 15 |
| `catalogo_formas_farmaceuticas` | 12 |
| `catalogo_prioridades` | 9 |
| `catalogo_configuraciones` | 10 |

---

## 2. ACCESO AL SISTEMA

### 2.1 Login

1. **Abrir navegador** en `http://localhost:5173` (o puerto configurado)
2. **Ingresar credenciales:**
   - Email: `superadmin@sigimed.test`
   - Password: `Admin123!`
3. **Verificar login exitoso:**
   - ✅ Redirección al Dashboard
   - ✅ Nombre de usuario visible en header
   - ✅ Rol mostrado como "Super Admin"

### 2.2 Navegación a Catálogos

1. **Localizar menú de administración** (parte superior derecha de la barra de navegación)
2. **Verificar opción "Catálogos":**
   - ✅ Visible solo para usuarios admin (super_admin, admin_center)
   - ✅ Icono de sliders (⚙️) visible
3. **Hacer clic en "Catálogos"**
4. **Verificar redirección a `/catalogos`:**
   - ✅ URL cambia a `/catalogos`
   - ✅ Página carga sin errores en consola
   - ✅ Título "Catálogos del Sistema" visible

### 2.3 Interfaz Principal

**Elementos Esperados:**

- ✅ **Header:** "Catálogos del Sistema" con icono de engranaje
- ✅ **Descripción:** "Gestiona los catálogos administrables del sistema"
- ✅ **Navegación por pestañas (tabs):**
  1. Colores (icono de paleta)
  2. Estados (icono de etiqueta)
  3. Tipos de Movimiento (icono de tendencia)
  4. Formas Farmacéuticas (icono de documento)
  5. Prioridades (icono de alerta)
  6. Configuraciones (icono de sliders)

---

## 3. PRUEBAS POR CATÁLOGO

---

## 3.1 CATÁLOGO DE COLORES

### 🎨 Objetivo
Gestionar la paleta de colores del sistema para uso en UI, gráficos y estados.

### 📋 Pasos de Prueba

#### A. VISUALIZACIÓN DE DATOS

1. **Hacer clic en tab "Colores"**
2. **Verificar tabla visible con columnas:**
   - Nombre
   - Color (preview visual + código HEX)
   - Categoría
   - Uso
   - Estado (Activo/Inactivo)
   - Acciones (Editar/Eliminar)

3. **Verificar datos de prueba visibles:**
   - ✅ **Primario** (#3B82F6) - Categoría: principal
   - ✅ **Éxito** (#10B981) - Categoría: estados
   - ✅ **Peligro** (#EF4444) - Categoría: alertas
   - ✅ **Gráfico 1** (#8B5CF6) - Categoría: graficos
   - ✅ Mínimo 15 colores visibles

4. **Verificar previews de color:**
   - ✅ Cuadrado de color visible junto al código HEX
   - ✅ Colores coinciden con código HEX

#### B. BÚSQUEDA Y FILTRADO

1. **Usar campo de búsqueda:**
   - Escribir "Primario"
   - ✅ Tabla filtra y muestra solo "Primario"
   - Limpiar búsqueda
   - ✅ Todos los colores reaparecen

2. **Filtrar por Categoría:**
   - Seleccionar filtro "Categoría" → "Principal"
   - ✅ Solo colores de categoría "Principal" visibles
   - Hacer clic en "Limpiar Filtros"
   - ✅ Todos los colores reaparecen

3. **Filtrar por Estado:**
   - Seleccionar filtro "Estado" → "Activos"
   - ✅ Solo colores activos visibles
   - Cambiar a "Inactivos"
   - ✅ Solo colores inactivos visibles (si los hay)

#### C. CREAR NUEVO COLOR

1. **Hacer clic en botón "Crear" (esquina superior derecha)**
2. **Verificar modal se abre:**
   - ✅ Título: "Nuevo Color"
   - ✅ Formulario visible con campos:
     - Nombre (requerido)
     - Código HEX (requerido, con color picker)
     - Categoría (select con opciones)
     - Uso (textarea)
     - Orden (número)
     - Es Activo (checkbox)

3. **Llenar formulario:**
   ```
   Nombre: "Color de Prueba"
   Código HEX: #FF6B6B (usar color picker)
   Categoría: "general"
   Uso: "Color creado para pruebas del sistema"
   Orden: 100
   Es Activo: ✓ (marcado)
   ```

4. **Verificar conversión automática HEX → RGB:**
   - ✅ Al cambiar color, campo RGB se actualiza automáticamente
   - ✅ Preview de color visible en formulario

5. **Hacer clic en "Crear"**

6. **Verificar creación exitosa:**
   - ✅ Modal se cierra
   - ✅ Nuevo color aparece en la tabla
   - ✅ Sin errores en consola
   - ✅ Mensaje de éxito visible (si implementado)

#### D. EDITAR COLOR

1. **Localizar el color recién creado "Color de Prueba"**
2. **Hacer clic en botón "Editar" (icono de lápiz)**
3. **Verificar modal de edición:**
   - ✅ Título: "Editar Color"
   - ✅ Campos pre-llenados con datos actuales
   - ✅ Color picker muestra color actual

4. **Modificar datos:**
   ```
   Nombre: "Color de Prueba Editado"
   Código HEX: #4ECDC4
   Uso: "Color modificado durante pruebas"
   ```

5. **Hacer clic en "Actualizar"**

6. **Verificar actualización:**
   - ✅ Modal se cierra
   - ✅ Cambios reflejados en tabla
   - ✅ Color visual actualizado

#### E. ELIMINAR COLOR (SOFT DELETE)

1. **Hacer clic en botón "Eliminar" del color de prueba**
2. **Verificar confirmación:**
   - ✅ Diálogo de confirmación aparece
   - ✅ Mensaje: "¿Estás seguro de eliminar el color...?"

3. **Confirmar eliminación**
4. **Verificar soft delete:**
   - ✅ Color desaparece de lista activa
   - ✅ Verificar con filtro "Inactivos" que el color sigue existiendo

#### F. REFRESCAR DATOS

1. **Hacer clic en botón "Refrescar" (icono de refresh)**
2. **Verificar:**
   - ✅ Tabla se recarga
   - ✅ Datos actualizados visibles
   - ✅ Indicador de carga visible durante refresh

### ✅ Checklist - Catálogo de Colores

- [ ] Visualización de datos completa
- [ ] Búsqueda funciona correctamente
- [ ] Filtros funcionan (Categoría, Estado)
- [ ] Crear nuevo color exitoso
- [ ] Color picker funcional
- [ ] Conversión HEX → RGB automática
- [ ] Editar color exitoso
- [ ] Eliminar color (soft delete) exitoso
- [ ] Refrescar datos funcional
- [ ] Sin errores en consola

---

## 3.2 CATÁLOGO DE ESTADOS

### 🏷️ Objetivo
Gestionar estados por módulo (medicamentos, requisiciones, transferencias, contratos).

### 📋 Pasos de Prueba

#### A. VISUALIZACIÓN DE DATOS

1. **Hacer clic en tab "Estados"**
2. **Verificar tabla con columnas:**
   - Código
   - Nombre
   - Módulo
   - Descripción
   - Estado (Activo/Inactivo)
   - Acciones

3. **Verificar datos de prueba visibles:**
   - ✅ **disponible** - Medicamentos
   - ✅ **pendiente** - Requisiciones
   - ✅ **en_transito** - Transferencias
   - ✅ **activo** - Contratos
   - ✅ Mínimo 20 estados visibles

#### B. FILTRADO POR MÓDULO

1. **Seleccionar filtro "Módulo" → "Medicamentos"**
2. **Verificar:**
   - ✅ Solo estados de módulo "medicamentos" visibles
   - ✅ Estados esperados: disponible, reservado, vencido, cuarentena

3. **Cambiar a "Requisiciones"**
4. **Verificar estados esperados:**
   - ✅ pendiente, aprobada, rechazada, en_proceso, completada, cancelada

5. **Limpiar filtros**

#### C. CREAR NUEVO ESTADO

1. **Hacer clic en "Crear"**
2. **Llenar formulario:**
   ```
   Código: "prueba_estado"
   Nombre: "Estado de Prueba"
   Descripción: "Estado creado para pruebas"
   Módulo: "general"
   Color: Seleccionar "Primario" del dropdown
   Icono: "TestTube" (nombre de icono lucide-react)
   Orden: 100
   Es estado inicial: ☐ (no marcado)
   Es estado final: ☐ (no marcado)
   Permite edición: ☑ (marcado)
   Es activo: ☑ (marcado)
   ```

3. **Verificar dropdown de colores:**
   - ✅ Lista de colores disponibles cargada
   - ✅ Colores del catálogo visible

4. **Crear estado**
5. **Verificar:**
   - ✅ Estado creado exitosamente
   - ✅ Visible en tabla

#### D. EDITAR ESTADO

1. **Editar estado de prueba**
2. **Modificar:**
   ```
   Nombre: "Estado de Prueba Modificado"
   Es estado final: ☑ (marcar)
   ```
3. **Actualizar**
4. **Verificar cambios aplicados**

#### E. ELIMINAR ESTADO

1. **Eliminar estado de prueba**
2. **Confirmar eliminación**
3. **Verificar soft delete exitoso**

### ✅ Checklist - Catálogo de Estados

- [ ] Visualización de datos completa
- [ ] Filtro por módulo funcional
- [ ] Asociación con colores funciona
- [ ] Crear estado con todas las opciones
- [ ] Editar estado exitoso
- [ ] Eliminar estado exitoso
- [ ] Sin errores en consola

---

## 3.3 CATÁLOGO DE TIPOS DE MOVIMIENTO

### 📈 Objetivo
Gestionar tipos de movimientos de inventario (entradas, salidas, ajustes, transferencias).

### 📋 Pasos de Prueba

#### A. VISUALIZACIÓN DE DATOS

1. **Hacer clic en tab "Tipos de Movimiento"**
2. **Verificar tabla con columnas:**
   - Código
   - Nombre
   - Tipo
   - Descripción
   - Opciones (badges de configuración)
   - Acciones

3. **Verificar datos de prueba:**
   - ✅ **compra** - Tipo: entrada
   - ✅ **donacion** - Tipo: entrada
   - ✅ **salida_paciente** - Tipo: salida
   - ✅ **ajuste_positivo** - Tipo: ajuste
   - ✅ **transferencia_envio** - Tipo: transferencia

#### B. VERIFICAR BADGES DE OPCIONES

1. **Observar columna "Opciones"**
2. **Verificar badges visibles:**
   - ✅ "Afecta stock" (azul)
   - ✅ "Req. documento" (morado)
   - ✅ "Req. aprobación" (naranja)

3. **Verificar que badges se muestran solo cuando aplican**

#### C. FILTRAR POR TIPO

1. **Seleccionar filtro "Tipo" → "Entrada"**
2. **Verificar:**
   - ✅ Solo tipos de entrada visibles (compra, donacion, etc.)

3. **Cambiar a "Salida"**
4. **Verificar:**
   - ✅ Solo tipos de salida visibles

#### D. CREAR NUEVO TIPO DE MOVIMIENTO

1. **Hacer clic en "Crear"**
2. **Llenar formulario:**
   ```
   Código: "prueba_movimiento"
   Nombre: "Movimiento de Prueba"
   Descripción: "Tipo de movimiento para pruebas"
   Tipo: "entrada"
   Afecta el stock: ☑ (marcado)
   Requiere documento: ☑ (marcado)
   Requiere aprobación: ☐ (no marcado)
   Color: Seleccionar uno del dropdown
   Icono: "Package"
   Orden: 100
   Tipo de movimiento activo: ☑ (marcado)
   ```

3. **Verificar advertencia si no afecta stock:**
   - (Dependerá de la selección)

4. **Crear**
5. **Verificar:**
   - ✅ Creado exitosamente
   - ✅ Badges visibles según configuración

#### E. EDITAR TIPO DE MOVIMIENTO

1. **Editar tipo de prueba**
2. **Cambiar configuración:**
   ```
   Requiere aprobación: ☑ (marcar)
   ```
3. **Verificar que código NO se puede editar**
   - ✅ Campo "Código" deshabilitado
   - ✅ Mensaje visible: "El código no se puede modificar..."

4. **Actualizar**
5. **Verificar badge "Req. aprobación" ahora visible**

#### F. ELIMINAR TIPO DE MOVIMIENTO

1. **Eliminar tipo de prueba**
2. **Confirmar**
3. **Verificar eliminación exitosa**

### ✅ Checklist - Tipos de Movimiento

- [ ] Visualización completa
- [ ] Badges de opciones visibles
- [ ] Filtro por tipo funcional
- [ ] Crear con todas las opciones
- [ ] Código no editable en modo edición
- [ ] Editar exitoso
- [ ] Eliminar exitoso
- [ ] Sin errores en consola

---

## 3.4 CATÁLOGO DE FORMAS FARMACÉUTICAS

### 💊 Objetivo
Gestionar formas farmacéuticas con requisitos de almacenamiento.

### 📋 Pasos de Prueba

#### A. VISUALIZACIÓN DE DATOS

1. **Hacer clic en tab "Formas Farmacéuticas"**
2. **Verificar tabla con columnas:**
   - Código
   - Nombre
   - Categoría
   - Vía
   - Unidad
   - Almacenamiento
   - Estado
   - Acciones

3. **Verificar datos de prueba:**
   - ✅ **tableta** - Categoría: solida
   - ✅ **capsula** - Categoría: solida
   - ✅ **jarabe** - Categoría: liquida
   - ✅ **inyectable** - Categoría: parental

#### B. VERIFICAR BADGES DE ALMACENAMIENTO

1. **Observar columna "Almacenamiento"**
2. **Verificar badges:**
   - ✅ "Refrigeración" (azul) - para formas que requieren refrigeración
   - ✅ "Cadena de frío" (cian) - para formas que requieren cadena de frío
   - ✅ "Normal" (gris) - para formas sin requisitos especiales

#### C. FILTRAR POR CATEGORÍA

1. **Seleccionar filtro "Categoría" → "Sólida"**
2. **Verificar:**
   - ✅ Solo formas sólidas visibles (tableta, capsula, etc.)

3. **Cambiar a "Líquida"**
4. **Verificar:**
   - ✅ Solo formas líquidas visibles

#### D. CREAR NUEVA FORMA FARMACÉUTICA

1. **Hacer clic en "Crear"**
2. **Llenar formulario:**
   ```
   Código: "prueba_forma"
   Nombre: "Forma de Prueba"
   Descripción: "Forma farmacéutica para pruebas"
   Categoría: "liquida"
   Vía de administración: "oral"
   Unidad de medida por defecto: "mL"
   Requiere refrigeración (2-8°C): ☑ (marcar)
   Requiere cadena de frío estricta: ☑ (marcar)
   Forma farmacéutica activa: ☑ (marcado)
   Orden: 100
   ```

3. **Verificar advertencia de almacenamiento especial:**
   - ✅ Banner informativo azul visible
   - ✅ Icono de información
   - ✅ Texto: "Esta forma farmacéutica requiere condiciones especiales..."

4. **Crear**
5. **Verificar:**
   - ✅ Creada exitosamente
   - ✅ Badges "Refrigeración" y "Cadena de frío" visibles en tabla

#### E. EDITAR FORMA FARMACÉUTICA

1. **Editar forma de prueba**
2. **Desmarcar "Requiere cadena de frío"**
3. **Actualizar**
4. **Verificar:**
   - ✅ Solo badge "Refrigeración" visible
   - ✅ Badge "Cadena de frío" removido

#### F. ELIMINAR FORMA FARMACÉUTICA

1. **Eliminar forma de prueba**
2. **Confirmar**
3. **Verificar eliminación exitosa**

### ✅ Checklist - Formas Farmacéuticas

- [ ] Visualización completa
- [ ] Badges de almacenamiento correctos
- [ ] Filtro por categoría funcional
- [ ] Advertencia de almacenamiento visible
- [ ] Crear con requisitos especiales
- [ ] Código no editable
- [ ] Editar exitoso
- [ ] Eliminar exitoso
- [ ] Sin errores en consola

---

## 3.5 CATÁLOGO DE PRIORIDADES

### ⚡ Objetivo
Gestionar niveles de prioridad con tiempos de respuesta.

### 📋 Pasos de Prueba

#### A. VISUALIZACIÓN DE DATOS

1. **Hacer clic en tab "Prioridades"**
2. **Verificar tabla con columnas:**
   - Código
   - Nivel (número grande y destacado)
   - Nombre
   - Módulo
   - Días respuesta
   - Opciones
   - Estado
   - Acciones

3. **Verificar datos de prueba:**
   - ✅ **emergencia** - Nivel: 1
   - ✅ **urgente** - Nivel: 2
   - ✅ **alta** - Nivel: 3
   - ✅ **normal** - Nivel: 5
   - ✅ **baja** - Nivel: 8

#### B. VERIFICAR BADGES DE OPCIONES

1. **Observar columna "Opciones"**
2. **Verificar badges:**
   - ✅ "Notifica" (amarillo) - para prioridades con notificación
   - ✅ "Alta prioridad" (rojo) - para nivel ≤ 2

#### C. VERIFICAR ORDEN POR NIVEL

1. **Observar que prioridades están ordenadas por nivel**
2. **Verificar:**
   - ✅ Nivel 1 arriba
   - ✅ Niveles mayores abajo

#### D. FILTRAR POR MÓDULO

1. **Seleccionar filtro "Módulo" → "Requisiciones"**
2. **Verificar:**
   - ✅ Solo prioridades de requisiciones visibles

3. **Cambiar a "Transferencias"**

#### E. CREAR NUEVA PRIORIDAD

1. **Hacer clic en "Crear"**
2. **Llenar formulario con nivel alto (≤ 2):**
   ```
   Código: "prueba_prioridad"
   Nombre: "Prioridad de Prueba"
   Descripción: "Prioridad para pruebas"
   Módulo: "general"
   Nivel: 2
   Días de respuesta esperado: 1
   Color: Seleccionar uno
   Icono: "Zap"
   Requiere notificación automática: ☑ (marcar)
   Prioridad activa: ☑ (marcado)
   Orden: 100
   ```

3. **Verificar advertencia de alta prioridad:**
   - ✅ Banner naranja visible
   - ✅ Icono de alerta
   - ✅ Texto: "Esta prioridad generará alertas..."

4. **Crear**
5. **Verificar:**
   - ✅ Creada exitosamente
   - ✅ Badges "Notifica" y "Alta prioridad" visibles

#### F. CREAR PRIORIDAD NORMAL (sin alertas)

1. **Crear otra prioridad:**
   ```
   Código: "prueba_normal"
   Nivel: 7
   Requiere notificación: ☐ (no marcar)
   ```
2. **Verificar:**
   - ✅ Sin advertencia naranja
   - ✅ Sin badges especiales

#### G. EDITAR Y ELIMINAR

1. **Editar prioridad de prueba**
2. **Cambiar nivel a 10**
3. **Verificar badge "Alta prioridad" desaparece**
4. **Eliminar ambas prioridades de prueba**

### ✅ Checklist - Prioridades

- [ ] Visualización completa
- [ ] Nivel destacado visualmente
- [ ] Badges según configuración
- [ ] Advertencia para alta prioridad (nivel ≤ 2)
- [ ] Filtro por módulo funcional
- [ ] Crear prioridad alta con advertencia
- [ ] Crear prioridad normal sin advertencia
- [ ] Editar y eliminar exitoso
- [ ] Sin errores en consola

---

## 3.6 CATÁLOGO DE CONFIGURACIONES

### ⚙️ Objetivo
Gestionar configuraciones del sistema con datos sensibles.

### 📋 Pasos de Prueba

#### A. VISUALIZACIÓN DE DATOS

1. **Hacer clic en tab "Configuraciones"**
2. **Verificar tabla con columnas:**
   - Nombre
   - Clave
   - Valor (con blur para sensibles)
   - Categoría
   - Estado (con badge "Sensible" si aplica)
   - Acciones

3. **Verificar datos de prueba:**
   - ✅ **Días Alerta Crítica** - sistema
   - ✅ **Email Notificaciones** - notificaciones
   - ✅ **API Key Externa** - seguridad (SENSIBLE)
   - ✅ **Umbral Stock Mínimo** - alertas

#### B. VERIFICAR DATOS SENSIBLES

1. **Localizar configuraciones sensibles (badge amarillo "Sensible")**
2. **Verificar:**
   - ✅ Valor con efecto blur: `••••••••`
   - ✅ No se puede leer el valor directamente

#### C. FILTRAR POR CATEGORÍA

1. **Seleccionar filtro "Categoría" → "Sistema"**
2. **Verificar:**
   - ✅ Solo configuraciones de sistema visibles

3. **Cambiar a "Seguridad"**
4. **Verificar:**
   - ✅ Configuraciones de seguridad visibles
   - ✅ Generalmente marcadas como sensibles

#### D. CREAR NUEVA CONFIGURACIÓN (NO SENSIBLE)

1. **Hacer clic en "Crear"**
2. **Llenar formulario:**
   ```
   Nombre: "Config de Prueba"
   Clave: "prueba_config"
   Valor: "123"
   Tipo de dato: "numero"
   Descripción: "Configuración para pruebas"
   Categoría: "general"
   Valor por defecto: "100"
   Es requerido: ☐ (no marcar)
   Es sensible: ☐ (no marcar)
   Es activo: ☑ (marcado)
   Orden: 100
   ```

3. **Verificar input dinámico:**
   - ✅ Al seleccionar "numero", input cambia a type="number"

4. **Probar otros tipos de dato:**
   - Cambiar a "booleano"
   - ✅ Aparece select con true/false
   - Cambiar a "json"
   - ✅ Aparece textarea con font monospace
   - Cambiar a "fecha"
   - ✅ Aparece date picker

5. **Crear con tipo "numero"**

#### E. CREAR CONFIGURACIÓN SENSIBLE

1. **Crear otra configuración:**
   ```
   Nombre: "Configuración Sensible de Prueba"
   Clave: "prueba_sensible"
   Valor: "secreto123"
   Tipo de dato: "texto"
   Es sensible: ☑ (MARCAR)
   ```

2. **Verificar advertencia de datos sensibles:**
   - ✅ Banner amarillo visible
   - ✅ Icono de candado
   - ✅ Texto de advertencia visible

3. **Verificar input cambia a type="password":**
   - ✅ Valor no visible mientras se escribe

4. **Crear**

5. **Verificar en tabla:**
   - ✅ Badge "Sensible" visible
   - ✅ Valor con blur: `••••••••`

#### F. EDITAR CONFIGURACIÓN

1. **Editar config sensible de prueba**
2. **Verificar:**
   - ✅ Campo "Clave" deshabilitado
   - ✅ Mensaje: "La clave no se puede modificar..."
   - ✅ Input de valor en modo password

3. **Modificar valor**
4. **Actualizar**

#### G. ELIMINAR CONFIGURACIONES

1. **Intentar eliminar configuración marcada como "requerido"**
2. **Verificar:**
   - ✅ Botón "Eliminar" NO visible (prop `show` funciona)

3. **Eliminar configuraciones de prueba no requeridas**
4. **Confirmar**
5. **Verificar eliminación exitosa**

### ✅ Checklist - Configuraciones

- [ ] Visualización completa
- [ ] Blur en valores sensibles
- [ ] Badge "Sensible" visible
- [ ] Filtro por categoría funcional
- [ ] Input dinámico según tipo de dato
- [ ] Advertencia para configuraciones sensibles
- [ ] Password input para sensibles
- [ ] Clave no editable en modo edición
- [ ] No se puede eliminar configuraciones requeridas
- [ ] Crear, editar y eliminar exitoso
- [ ] Sin errores en consola

---

## 4. PRUEBAS DE SEGURIDAD

### 🔒 Control de Acceso

#### A. VERIFICAR PERMISOS DE ROL

1. **Logout como superadmin**
2. **Login como usuario operador:**
   - Email: `operador@sigimed.test`
   - Password: `Operador123!`

3. **Verificar restricciones:**
   - ✅ Opción "Catálogos" NO visible en menú
   - ✅ Al intentar acceder a `/catalogos` directamente → Redirige o muestra "No autorizado"

4. **Logout y login nuevamente como admin_center**

5. **Verificar acceso:**
   - ✅ Opción "Catálogos" visible
   - ✅ Puede acceder y modificar catálogos

#### B. VERIFICAR RLS (Row Level Security)

**NOTA:** Esto requiere acceso a la base de datos para verificar.

1. **En Supabase Dashboard o cliente SQL:**
   ```sql
   -- Como usuario no admin
   SELECT * FROM catalogo_colores WHERE es_activo = false;
   -- Debería retornar 0 filas (política RLS)

   -- Como usuario admin
   SELECT * FROM catalogo_colores WHERE es_activo = false;
   -- Debería retornar filas inactivas
   ```

### ✅ Checklist - Seguridad

- [ ] Usuarios sin permisos no ven opción "Catálogos"
- [ ] RoleGuard bloquea acceso a URL directa
- [ ] Solo super_admin y admin_center tienen acceso
- [ ] RLS funciona correctamente en base de datos

---

## 5. PRUEBAS DE VALIDACIÓN

### ✏️ Validaciones de Formulario

#### A. VALIDAR CAMPOS REQUERIDOS

1. **Abrir formulario de crear color**
2. **Dejar campo "Nombre" vacío**
3. **Intentar crear**
4. **Verificar:**
   - ✅ Formulario no se envía
   - ✅ Mensaje de validación HTML5 visible
   - ✅ Campo marcado como inválido (borde rojo)

5. **Llenar nombre y crear**
6. **Verificar creación exitosa**

#### B. VALIDAR UNICIDAD DE CÓDIGOS

1. **Intentar crear un color con código existente**
   ```
   Código: "primario" (ya existe)
   ```
2. **Verificar:**
   - ✅ Error de base de datos visible
   - ✅ Mensaje descriptivo del error

#### C. VALIDAR FORMATO DE DATOS

1. **En formulario de configuración:**
   - Tipo: "numero"
   - Valor: "abc" (texto en lugar de número)

2. **Verificar:**
   - ✅ Input no permite ingresar letras
   - ✅ Validación HTML5 funciona

### ✅ Checklist - Validación

- [ ] Campos requeridos validados
- [ ] Códigos únicos validados
- [ ] Formato de datos validado
- [ ] Mensajes de error claros

---

## 6. CHECKLIST FINAL

### 📊 General

- [ ] Todos los 6 catálogos cargan datos correctamente
- [ ] Sin errores en consola del navegador
- [ ] Build exitoso (`npm run build`)
- [ ] UI responsiva (probar en móvil/tablet)

### 🎨 Interfaz

- [ ] Navegación por tabs funciona
- [ ] Botones claramente visibles
- [ ] Colores y estilos consistentes
- [ ] Iconos visibles y apropiados
- [ ] Loading states visibles durante operaciones
- [ ] Mensajes de error/éxito claros

### 🔧 Funcionalidad

- [ ] CRUD completo en los 6 catálogos
- [ ] Búsqueda funciona
- [ ] Filtros funcionan
- [ ] Soft delete funciona
- [ ] Refresh de datos funciona
- [ ] Validaciones funcionan
- [ ] Datos persisten correctamente

### 🔒 Seguridad

- [ ] Control de acceso por rol
- [ ] RLS configurado
- [ ] Datos sensibles protegidos
- [ ] Códigos no editables
- [ ] Configuraciones requeridas no eliminables

### 📱 Performance

- [ ] Carga inicial rápida (< 3 segundos)
- [ ] Operaciones CRUD rápidas (< 1 segundo)
- [ ] Sin memory leaks (verificar con DevTools)
- [ ] Queries optimizadas

---

## 7. REPORTE DE ERRORES

### 📝 Template para Reportar Errores

```markdown
## Error Encontrado

**Catálogo:** [Colores/Estados/etc.]
**Operación:** [Crear/Editar/Eliminar/Filtrar/etc.]
**Severidad:** [Crítico/Alto/Medio/Bajo]

**Descripción:**
[Descripción clara del error]

**Pasos para Reproducir:**
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

**Resultado Esperado:**
[Qué debería suceder]

**Resultado Actual:**
[Qué sucede realmente]

**Errores en Consola:**
```
[Copiar errores de consola]
```

**Screenshots:**
[Adjuntar capturas de pantalla]

**Navegador:**
[Chrome 90, Firefox 88, etc.]

**Fecha:** [DD/MM/YYYY]
**Reportado por:** [Nombre]
```

### 📧 Dónde Reportar

- **GitHub Issues:** [URL del repositorio]/issues
- **Email:** dev@sigimed.com
- **Slack:** #sigimed-bugs

---

## 📋 RESUMEN DE PRUEBAS

### Tiempo Estimado Total: **2-3 horas**

| Módulo | Tiempo Estimado | Prioridad |
|--------|-----------------|-----------|
| Colores | 20 min | Alta |
| Estados | 25 min | Alta |
| Tipos Movimiento | 25 min | Alta |
| Formas Farmacéuticas | 20 min | Media |
| Prioridades | 20 min | Media |
| Configuraciones | 30 min | Alta |
| Seguridad | 15 min | Crítica |
| Validaciones | 15 min | Alta |

### Criterios de Aceptación

**MÍNIMOS PARA APROBAR:**
- ✅ 0 errores críticos
- ✅ CRUD completo funciona en todos los catálogos
- ✅ Control de acceso funciona
- ✅ Datos persisten correctamente
- ✅ Sin errores en consola (excepto warnings menores)

**IDEALES:**
- ✅ Todo lo anterior +
- ✅ Performance óptimo (< 1s operaciones)
- ✅ UI pulida sin bugs visuales
- ✅ Validaciones completas
- ✅ Mensajes de usuario claros

---

## 🎯 PRÓXIMOS PASOS

Después de completar estas pruebas:

1. **Documentar resultados** en formato de checklist
2. **Reportar errores** encontrados usando template
3. **Priorizar fixes** según severidad
4. **Regression testing** después de cada fix
5. **Sign-off** cuando todo esté verde ✅

---

**¡Buenas pruebas! 🚀**

---

*Documento generado para SIGIMED v2.0*
*Última actualización: 19 de Noviembre 2025*
