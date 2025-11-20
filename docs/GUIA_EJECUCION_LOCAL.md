# 🚀 Guía de Ejecución Local - SIGIMED v2.0

Esta guía te ayudará a ejecutar el proyecto localmente para desarrollo y pruebas.

## 📋 Requisitos Previos

- Node.js 18+ instalado
- Git instalado
- Acceso al repositorio de SIGIMED
- Variables de entorno configuradas

## 🔧 Configuración Inicial

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd MED_DGPRS
```

### 2. Cambiar a la Rama de Desarrollo

```bash
git checkout claude/generate-inventory-data-01AJCkKct8r1m3aC2iVnqXdV
```

### 3. Instalar Dependencias

```bash
npm install
```

Este comando instalará todas las dependencias necesarias, incluyendo:
- React 18
- Vite
- Supabase
- Tailwind CSS
- Vitest (testing)
- Y todas las demás librerías

### 4. Configurar Variables de Entorno

Crea un archivo `.env.local` en la raíz del proyecto:

```env
VITE_SUPABASE_URL=tu_url_de_supabase
VITE_SUPABASE_ANON_KEY=tu_key_de_supabase
```

> **Nota**: Obtén estas credenciales del panel de Supabase o de tu configuración en Vercel.

## 🏃 Ejecutar el Proyecto

### Modo Desarrollo

```bash
npm run dev
```

Esto iniciará el servidor de desarrollo en `http://localhost:5173`

**Características del modo desarrollo:**
- ✅ **Banner amarillo** visible indicando "MODO DESARROLLO"
- ✅ Hot Module Replacement (HMR) - cambios instantáneos
- ✅ Console logs habilitados
- ✅ Modo sin minificar para debugging

### Modo Producción Local

```bash
# 1. Construir el proyecto
npm run build

# 2. Previsualizar la build
npm run preview
```

Esto te mostrará cómo se verá en producción (sin el banner de desarrollo).

## 🧪 Ejecutar Pruebas

### Pruebas en Modo Watch

```bash
npm run test
```

Esto ejecutará las pruebas y se mantendrá observando cambios.

### Ejecutar Pruebas Una Sola Vez

```bash
npm run test:run
```

### Interfaz Visual de Pruebas

```bash
npm run test:ui
```

Abre una interfaz web en `http://localhost:51204/__vitest__/` donde puedes:
- Ver todas las pruebas
- Ejecutar pruebas individuales
- Ver cobertura de código
- Debugging visual

### Cobertura de Código

```bash
npm run test:coverage
```

Genera un reporte de cobertura en la carpeta `coverage/`

## 📊 Estado Actual de las Pruebas

**Resultado**: 4 de 13 tests pasando ✅

### Tests que Funcionan ✅

1. ✓ debe filtrar medicamentos por centro de salud
2. ✓ debe validar cantidad positiva
3. ✓ debe validar fecha de caducidad futura
4. ✓ debe validar campos requeridos

### Tests Pendientes ⚠️

Los siguientes 9 tests necesitan ajustes en los mocks de Supabase:

1. ❌ debe cargar la lista de medicamentos correctamente
2. ❌ debe detectar medicamentos con stock bajo
3. ❌ debe detectar medicamentos próximos a vencer
4. ❌ debe buscar medicamentos por nombre
5. ❌ debe filtrar medicamentos por estado
6. ❌ debe crear un nuevo medicamento
7. ❌ debe actualizar un medicamento existente
8. ❌ debe manejar errores de red correctamente
9. ❌ debe manejar datos vacíos correctamente

## 🔍 Verificar Cambios Realizados

### 1. Verificar Banner de Modo Desarrollo

**Ubicación**: Todas las páginas, parte superior

**Cómo verificar**:
1. Ejecuta `npm run dev`
2. Abre `http://localhost:5173`
3. Deberías ver un **banner amarillo** en la parte superior que dice:
   ```
   ⚙️ MODO DESARROLLO - Los cambios se guardan automáticamente
   ```

**Archivo**: `src/components/layout/MainLayout.tsx:239-247`

### 2. Verificar Menú Lateral

**Ubicación**: Lado izquierdo de la pantalla

**Cómo verificar**:
1. El menú debe estar en el lado izquierdo (no horizontal arriba)
2. Debe tener secciones colapsables:
   - General (Dashboard, Alertas, Reportes)
   - Inventario (Inventario, Lotes, Movimientos)
   - Gestión (Proveedores, Contratos)
   - Administración (Catálogos, Instituciones, etc.)
3. Debe poder colapsarse con el botón de menú
4. Debe ser responsive en móvil

### 3. Verificar Responsividad

**Cómo verificar**:
1. Abre DevTools (F12)
2. Activa el modo responsive (Ctrl + Shift + M)
3. Prueba diferentes tamaños:
   - **Móvil**: 375px - debe verse en 1 columna
   - **Tablet**: 768px - debe verse en 2 columnas
   - **Desktop**: 1024px - debe verse en 4 columnas

**Páginas a verificar**:
- Dashboard
- Inventario
- Lotes
- Movimientos
- Proveedores
- Alertas
- Reportes
- Y todas las demás

## 🐛 Solución de Problemas

### Error: "Cannot find module"

```bash
# Borrar node_modules y reinstalar
rm -rf node_modules package-lock.json
npm install
```

### Error: "Supabase connection failed"

Verifica que tu archivo `.env.local` tenga las credenciales correctas:
```bash
cat .env.local
```

### El banner de desarrollo no aparece

Verifica que estés ejecutando en modo desarrollo:
```bash
# Debe ser este comando, NO npm run preview
npm run dev
```

### Las pruebas fallan

Los 9 tests que fallan son esperados por ahora. Solo 4 deben pasar:
```bash
npm run test:run
# Debería mostrar: "4 passed"
```

## 📁 Estructura de Archivos Importantes

```
MED_DGPRS/
├── src/
│   ├── components/
│   │   └── layout/
│   │       └── MainLayout.tsx          # Banner + Menú lateral
│   ├── hooks/
│   │   └── __tests__/
│   │       └── useMedicamentos.test.ts # Pruebas
│   └── pages/                           # Todas las páginas
├── docs/
│   ├── DOCUMENTACION_TECNICA.md         # Docs técnicas
│   ├── MANUAL_DE_USUARIO.md             # Manual de usuario
│   ├── GUIA_EJECUCION_LOCAL.md          # Esta guía
│   └── ...
├── package.json                         # Scripts y dependencias
├── vitest.config.ts                     # Config de tests
└── .env.local                           # Variables (NO en git)
```

## ✅ Checklist de Verificación

Antes de reportar que está funcionando, verifica:

- [ ] `npm run dev` inicia sin errores
- [ ] Banner amarillo visible en modo desarrollo
- [ ] Menú lateral funciona (colapsable, secciones)
- [ ] Todas las páginas se ven responsive
- [ ] `npm run test:run` muestra "4 passed"
- [ ] Puedes navegar entre todas las páginas
- [ ] Los datos de Supabase se cargan correctamente

## 🚀 Próximos Pasos

Una vez que hayas verificado todo localmente:

1. **Hacer merge a main** (cuando esté todo listo)
2. **Corregir los 9 tests pendientes**
3. **Ejecutar pruebas de escritorio internas** (ver `docs/PRUEBAS_ESCRITORIO_INTERNAS.md`)
4. **Ejecutar validación QA externa** (ver `docs/VALIDACION_EXTERNA_QA.md`)

## 📞 Soporte

Si encuentras algún problema:
1. Revisa esta guía
2. Consulta `docs/DOCUMENTACION_TECNICA.md`
3. Revisa los logs en la consola del navegador
4. Revisa los logs en la terminal donde ejecutaste `npm run dev`
