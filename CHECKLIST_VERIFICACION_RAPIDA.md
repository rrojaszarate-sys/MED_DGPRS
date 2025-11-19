# ✅ CHECKLIST DE VERIFICACIÓN RÁPIDA
## Sistema de Catálogos - SIGIMED v2.0

**Uso:** Ejecutar ANTES de pruebas externas para asegurar que todo está funcionando.

---

## 🚀 PRE-REQUISITOS (5 minutos)

### 1. Base de Datos

```bash
# Verificar que las tablas existen y tienen datos
```

**En Supabase SQL Editor:**

```sql
-- Verificar existencia de tablas
SELECT COUNT(*) as total_colores FROM catalogo_colores;
-- Esperado: 15

SELECT COUNT(*) as total_estados FROM catalogo_estados;
-- Esperado: 20

SELECT COUNT(*) as total_tipos FROM catalogo_tipos_movimiento;
-- Esperado: 15

SELECT COUNT(*) as total_formas FROM catalogo_formas_farmaceuticas;
-- Esperado: 12

SELECT COUNT(*) as total_prioridades FROM catalogo_prioridades;
-- Esperado: 9

SELECT COUNT(*) as total_configs FROM catalogo_configuraciones;
-- Esperado: 10
```

**✅ Checklist BD:**
- [ ] Todas las tablas existen
- [ ] Todas las tablas tienen datos
- [ ] Cantidades coinciden con lo esperado

---

### 2. Build y Servidor

```bash
# Verificar build sin errores
npm run build

# Resultado esperado: "✓ built in X.XXs"
```

**✅ Checklist Build:**
- [ ] Build exitoso sin errores TypeScript
- [ ] Solo warnings menores (si los hay)
- [ ] Archivo dist/index.html generado

```bash
# Iniciar servidor
npm run dev

# Resultado esperado: "Local: http://localhost:5173/"
```

**✅ Checklist Servidor:**
- [ ] Servidor inicia sin errores
- [ ] Puerto accesible (por defecto 5173)
- [ ] Sin errores en terminal

---

### 3. Consola del Navegador

**Abrir navegador y presionar F12**

**✅ Checklist Consola:**
- [ ] Sin errores en consola al cargar
- [ ] Sin errores 404 (archivos faltantes)
- [ ] Sin errores de CORS
- [ ] Conexión a Supabase exitosa

---

## 🔍 VERIFICACIÓN RÁPIDA POR CATÁLOGO (10 minutos)

### 1. Acceso al Módulo

1. Login como `superadmin@sigimed.test`
2. Navegar a `/catalogos`

**✅ Checklist:**
- [ ] Página carga sin errores
- [ ] 6 tabs visibles
- [ ] Tab "Colores" activo por defecto

---

### 2. Catálogo de Colores (2 min)

**Verificaciones Mínimas:**

1. **Datos visibles:**
   - [ ] Tabla muestra ~15 colores
   - [ ] Preview de color visible
   - [ ] Código HEX visible

2. **Funcionalidad básica:**
   - [ ] Búsqueda filtra resultados
   - [ ] Botón "Crear" abre modal
   - [ ] Botón "Editar" abre modal con datos
   - [ ] Modal se cierra al cancelar

**❌ Errores Comunes:**
- Color picker no funciona → Verificar import de componente
- Colores no visibles → Verificar datos en BD
- Modal no se cierra → Verificar handlers onCancel

---

### 3. Catálogo de Estados (2 min)

**Verificaciones Mínimas:**

1. **Datos visibles:**
   - [ ] Tabla muestra ~20 estados
   - [ ] Módulos visibles (medicamentos, requisiciones, etc.)

2. **Funcionalidad básica:**
   - [ ] Filtro por módulo funciona
   - [ ] Dropdown de colores en formulario funciona
   - [ ] Estados se agrupan correctamente

**❌ Errores Comunes:**
- Dropdown de colores vacío → Verificar useCatalogoColores() en formulario
- Filtros no funcionan → Verificar prop onFiltrar

---

### 4. Catálogo de Tipos de Movimiento (2 min)

**Verificaciones Mínimas:**

1. **Datos visibles:**
   - [ ] Tabla muestra ~15 tipos
   - [ ] Badges de opciones visibles (Afecta stock, Req. documento, etc.)

2. **Funcionalidad básica:**
   - [ ] Filtro por tipo funciona
   - [ ] Checkboxes en formulario funcionan
   - [ ] Código no editable en modo edición

**❌ Errores Comunes:**
- Badges no visibles → Verificar columna render
- Código editable → Verificar prop disabled

---

### 5. Catálogo de Formas Farmacéuticas (1 min)

**Verificaciones Mínimas:**

1. **Datos visibles:**
   - [ ] Tabla muestra ~12 formas
   - [ ] Badges de almacenamiento visibles

2. **Funcionalidad básica:**
   - [ ] Filtro por categoría funciona
   - [ ] Advertencia de almacenamiento especial visible cuando aplica

**❌ Errores Comunes:**
- Categorías no definidas en tipos → Verificar interface CatalogoFormaFarmaceutica

---

### 6. Catálogo de Prioridades (1 min)

**Verificaciones Mínimas:**

1. **Datos visibles:**
   - [ ] Tabla muestra ~9 prioridades
   - [ ] Nivel destacado (número grande)
   - [ ] Badge "Alta prioridad" visible para nivel ≤ 2

2. **Funcionalidad básica:**
   - [ ] Filtro por módulo funciona
   - [ ] Advertencia para nivel ≤ 2 funciona

**❌ Errores Comunes:**
- Nivel no destacado → Verificar columna render
- Advertencia no aparece → Verificar lógica `nivel <= 2`

---

### 7. Catálogo de Configuraciones (2 min)

**Verificaciones Mínimas:**

1. **Datos visibles:**
   - [ ] Tabla muestra ~10 configuraciones
   - [ ] Valores sensibles con blur
   - [ ] Badge "Sensible" visible

2. **Funcionalidad básica:**
   - [ ] Input cambia según tipo de dato
   - [ ] Clave no editable en modo edición
   - [ ] No se puede eliminar configuraciones requeridas

**❌ Errores Comunes:**
- Blur no funciona → Verificar className "blur-sm"
- Input no dinámico → Verificar switch renderInputValor()
- Botón eliminar visible en requeridos → Verificar prop show

---

## 🐛 ERRORES MÁS COMUNES Y SOLUCIONES

### Error 1: "Cannot read property 'map' of undefined"

**Causa:** Hook no ha cargado datos aún
**Solución:** Verificar estado de loading

```typescript
{loading ? (
  <div>Cargando...</div>
) : (
  items.map(item => ...)
)}
```

---

### Error 2: Tabla vacía pero sin errores

**Causa:** Política RLS bloqueando lectura
**Solución:** Verificar políticas en Supabase

```sql
-- En Supabase SQL Editor
SELECT * FROM catalogo_colores;
-- Si no retorna nada, verificar RLS
```

---

### Error 3: "relation 'catalogo_colores' does not exist"

**Causa:** Migración no ejecutada
**Solución:** Ejecutar migración

```bash
# En Supabase SQL Editor, ejecutar:
migrations/09_catalogos_administrables.sql
```

---

### Error 4: Modal no se cierra

**Causa:** Handler onCancel no conectado
**Solución:** Verificar prop onCancel

```typescript
<FormularioColor
  onCancel={() => {
    setMostrarFormulario(false)
    setItemSeleccionado(null)
  }}
/>
```

---

### Error 5: Filtros no funcionan

**Causa:** Props onFiltrar no conectada
**Solución:** Verificar conexión

```typescript
<TablaCatalogo
  onFiltrar={(filtros) => catalogo.filter(filtros)}
  onLimpiarFiltros={catalogo.clearFilters}
/>
```

---

### Error 6: Datos no persisten

**Causa:** Supabase client no configurado o RLS bloqueando escritura
**Solución:**
1. Verificar variables de entorno (.env)
2. Verificar políticas RLS para INSERT/UPDATE

---

### Error 7: TypeScript errors en build

**Causa:** Tipos no coinciden con datos
**Solución:** Verificar interfaces en src/types/index.ts coinciden con esquema de BD

---

## 🔧 COMANDOS DE DIAGNÓSTICO

### Verificar Estado del Sistema

```bash
# 1. Verificar variables de entorno
cat .env | grep VITE_SUPABASE

# 2. Verificar dependencias
npm list react react-dom @supabase/supabase-js

# 3. Limpiar y rebuild
rm -rf node_modules dist
npm install
npm run build

# 4. Verificar TypeScript
npx tsc --noEmit

# 5. Verificar linter
npm run lint
```

---

## 📊 DATOS DE PRUEBA MÍNIMOS

### Colores (15 registros)
- Primario (#3B82F6)
- Éxito (#10B981)
- Peligro (#EF4444)
- Advertencia (#F59E0B)
- Info (#3B82F6)
- + 10 más

### Estados (20 registros)
**Medicamentos:** disponible, reservado, vencido, cuarentena
**Requisiciones:** pendiente, aprobada, rechazada, en_proceso, completada, cancelada
**Transferencias:** pendiente, en_transito, recibida, rechazada, cancelada
**Contratos:** borrador, activo, suspendido, vencido, cancelado

### Tipos Movimiento (15 registros)
**Entrada:** compra, donacion, devolucion, transferencia_recepcion
**Salida:** prescripcion, perdida, vencimiento, transferencia_envio
**Ajuste:** ajuste_positivo, ajuste_negativo

### Formas Farmacéuticas (12 registros)
tableta, capsula, jarabe, suspension, solucion_oral, inyectable, crema, ungüento, gel, parche, supositorio, aerosol

### Prioridades (9 registros)
emergencia(1), urgente(2), alta(3), media_alta(4), normal(5), media_baja(6), baja(7), muy_baja(8), minima(9)

### Configuraciones (10 registros)
dias_alerta_critica, dias_alerta_media, email_notificaciones, api_key_externa, etc.

---

## ✅ CHECKLIST FINAL PRE-PRUEBAS

**Marcar TODOS antes de iniciar pruebas externas:**

### Base de Datos
- [ ] 6 tablas creadas
- [ ] Datos de prueba cargados
- [ ] RLS configurado
- [ ] Triggers funcionando

### Frontend
- [ ] Build exitoso
- [ ] Servidor corriendo
- [ ] Sin errores en consola
- [ ] Ruta /catalogos accesible

### Funcionalidad Básica
- [ ] Login funciona
- [ ] Navegación a catálogos funciona
- [ ] 6 tabs visibles
- [ ] Al menos un catálogo muestra datos

### Permisos
- [ ] Solo admins pueden acceder
- [ ] RoleGuard funciona
- [ ] Usuarios normales bloqueados

---

## 🎯 CRITERIO DE APROBACIÓN

**PASA si:**
✅ Todos los checklist están completos
✅ 0 errores críticos
✅ Al menos 4 de 6 catálogos funcionan completamente

**FALLA si:**
❌ Errores en consola al cargar página
❌ Ningún catálogo muestra datos
❌ Build falla
❌ Control de acceso no funciona

---

## 📞 SOPORTE

**Si encuentras errores:**

1. **Verificar consola del navegador** (F12)
2. **Verificar terminal del servidor**
3. **Revisar este checklist**
4. **Consultar MANUAL_PRUEBAS_CATALOGOS.md**
5. **Reportar usando template en manual**

---

**¡Listo para pruebas! 🚀**

*Tiempo total de verificación: ~15 minutos*
