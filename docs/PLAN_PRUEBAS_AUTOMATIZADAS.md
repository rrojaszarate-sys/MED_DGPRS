# Plan de Pruebas Automatizadas - SIGIMED v2.0

## 1. Instalación de Herramientas

### Instalar dependencias de testing:

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event @vitest/ui jsdom
```

### Actualizar package.json con scripts de testing:

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## 2. Configuración de Vitest

Crear archivo `vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/mockData',
      ],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

Crear archivo `src/test/setup.ts`:

```typescript
import { expect, afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';
import * as matchers from '@testing-library/jest-dom/matchers';

expect.extend(matchers);

afterEach(() => {
  cleanup();
});
```

---

## 3. Suite de Pruebas por Módulo

### 3.1 Pruebas de Autenticación

**Archivo:** `src/hooks/__tests__/useAuth.test.ts`

**Casos de prueba:**
- ✅ Login exitoso con credenciales válidas
- ✅ Login fallido con credenciales inválidas
- ✅ Logout exitoso
- ✅ Persistencia de sesión
- ✅ Redirección después de login
- ✅ Manejo de errores de red

### 3.2 Pruebas de Instituciones

**Archivo:** `src/pages/__tests__/Instituciones.test.tsx`

**Casos de prueba:**
- ✅ Renderizado de lista de instituciones
- ✅ Creación de nueva institución
- ✅ Edición de institución existente
- ✅ Eliminación de institución (soft delete)
- ✅ Búsqueda y filtrado
- ✅ Validación de campos requeridos
- ✅ Validación de RFC único

### 3.3 Pruebas de Centros de Salud

**Archivo:** `src/pages/__tests__/CentrosSalud.test.tsx`

**Casos de prueba:**
- ✅ Renderizado de lista de centros
- ✅ Filtrado por institución
- ✅ Creación de nuevo centro
- ✅ Edición de centro existente
- ✅ Validación de código único
- ✅ Asignación a institución

### 3.4 Pruebas de Catálogos

**Archivo:** `src/pages/__tests__/CatalogosAdministrables.test.tsx`

**Casos de prueba:**
- ✅ CRUD de formas farmacéuticas
- ✅ CRUD de vías de administración
- ✅ CRUD de unidades de medida
- ✅ CRUD de tipos de medicamento
- ✅ CRUD de colores
- ✅ CRUD de olores
- ✅ Validación de nombres únicos
- ✅ Activación/desactivación de registros

### 3.5 Pruebas de Catálogo de Medicamentos

**Archivo:** `src/hooks/__tests__/useCatalogoMedicamentos.test.ts`

**Casos de prueba:**
- ✅ Carga de lista de medicamentos
- ✅ Creación de medicamento con datos completos
- ✅ Edición de medicamento
- ✅ Búsqueda por nombre
- ✅ Filtrado por forma farmacéutica
- ✅ Filtrado por tipo
- ✅ Validación de campos requeridos

### 3.6 Pruebas de Inventario

**Archivo:** `src/hooks/__tests__/useMedicamentos.test.ts`

**Casos de prueba:**
- ✅ Carga de inventario por centro
- ✅ Filtrado por centro de salud
- ✅ Búsqueda por nombre de medicamento
- ✅ Detección de medicamentos próximos a vencer
- ✅ Detección de stock bajo
- ✅ Actualización de cantidades

### 3.7 Pruebas de Lotes

**Archivo:** `src/hooks/__tests__/useLotes.test.ts`

**Casos de prueba:**
- ✅ Carga de lotes por medicamento
- ✅ Creación de nuevo lote
- ✅ Validación de número de lote único
- ✅ Validación de fecha de caducidad
- ✅ Cambio de estado (disponible, cuarentena, vencido)
- ✅ Cálculo de disponibilidad

### 3.8 Pruebas de Movimientos

**Archivo:** `src/hooks/__tests__/useMovimientos.test.ts`

**Casos de prueba:**
- ✅ Registro de entrada
- ✅ Registro de salida
- ✅ Registro de ajuste
- ✅ Transferencia entre centros
- ✅ Validación de cantidad disponible
- ✅ Actualización automática de stock
- ✅ Historial de movimientos

### 3.9 Pruebas de Proveedores

**Archivo:** `src/hooks/__tests__/useProveedores.test.ts`

**Casos de prueba:**
- ✅ CRUD de proveedores
- ✅ Validación de RFC
- ✅ Validación de email
- ✅ Búsqueda por nombre
- ✅ Filtrado por estado activo

### 3.10 Pruebas de Reportes

**Archivo:** `src/pages/__tests__/Reportes.test.tsx`

**Casos de prueba:**
- ✅ Generación de reporte de inventario
- ✅ Generación de reporte de movimientos
- ✅ Filtrado por fechas
- ✅ Filtrado por centro
- ✅ Exportación a Excel
- ✅ Exportación a PDF

---

## 4. Pruebas de Integración

### 4.1 Flujo Completo de Entrada de Medicamento

**Archivo:** `src/test/integration/entradaMedicamento.test.tsx`

**Escenario:**
1. Login como almacenista
2. Navegar a Inventario
3. Crear nuevo lote
4. Registrar movimiento de entrada
5. Verificar actualización de stock
6. Verificar historial de movimientos

### 4.2 Flujo Completo de Dispensación

**Archivo:** `src/test/integration/dispensacion.test.tsx`

**Escenario:**
1. Login como farmacéutico
2. Buscar medicamento
3. Verificar stock disponible
4. Registrar salida por dispensación
5. Verificar reducción de stock
6. Generar reporte de dispensación

### 4.3 Flujo de Transferencia entre Centros

**Archivo:** `src/test/integration/transferencia.test.tsx`

**Escenario:**
1. Login como administrador
2. Seleccionar centro origen
3. Seleccionar medicamento
4. Registrar transferencia a centro destino
5. Verificar reducción en origen
6. Verificar incremento en destino

---

## 5. Pruebas de Validación

### 5.1 Validaciones de Formularios

**Archivo:** `src/test/validation/forms.test.tsx`

**Casos de prueba:**
- ✅ Campos requeridos
- ✅ Formato de email
- ✅ Formato de RFC
- ✅ Formato de teléfono
- ✅ Fechas válidas
- ✅ Cantidades positivas
- ✅ Valores numéricos

### 5.2 Validaciones de Negocio

**Archivo:** `src/test/validation/business.test.ts`

**Casos de prueba:**
- ✅ No permitir salidas mayores al stock
- ✅ No permitir lotes duplicados
- ✅ No permitir medicamentos vencidos en dispensación
- ✅ Alertar stock bajo mínimo
- ✅ Alertar próximo a vencer (3 meses)

---

## 6. Pruebas de Seguridad

### 6.1 Control de Acceso por Roles

**Archivo:** `src/test/security/permissions.test.tsx`

**Casos de prueba:**
- ✅ Administrador: acceso total
- ✅ Almacenista: solo inventario y lotes
- ✅ Farmacéutico: solo dispensación
- ✅ Consulta: solo lectura
- ✅ Bloqueo de rutas no autorizadas
- ✅ Redirección si no autenticado

---

## 7. Pruebas de Performance

### 7.1 Carga de Datos Masivos

**Archivo:** `src/test/performance/dataLoading.test.ts`

**Casos de prueba:**
- ✅ Carga de 1000+ medicamentos
- ✅ Carga de 5000+ lotes
- ✅ Búsqueda en grandes volúmenes
- ✅ Paginación eficiente
- ✅ Tiempo de respuesta < 3s

---

## 8. Ejecución de Pruebas

### Comandos:

```bash
# Ejecutar todas las pruebas
npm run test

# Ejecutar con interfaz visual
npm run test:ui

# Ejecutar solo una vez (CI/CD)
npm run test:run

# Ejecutar con coverage
npm run test:coverage

# Ejecutar pruebas específicas
npm run test -- src/hooks/__tests__/useAuth.test.ts

# Modo watch (re-ejecutar al cambiar archivos)
npm run test -- --watch
```

---

## 9. Métricas de Éxito

### Objetivos de Cobertura:

- ✅ **Cobertura de código:** ≥ 80%
- ✅ **Cobertura de hooks:** ≥ 90%
- ✅ **Cobertura de componentes críticos:** 100%
- ✅ **Todas las pruebas pasan:** 100%

### Criterios de Aceptación:

- ✅ Todas las pruebas unitarias pasan
- ✅ Todas las pruebas de integración pasan
- ✅ Cobertura mínima alcanzada
- ✅ Sin errores de lint
- ✅ Build exitoso

---

## 10. Integración con CI/CD

### GitHub Actions (`.github/workflows/test.yml`):

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:run
      - run: npm run build
```

---

## 11. Próximos Pasos

1. ✅ Instalar dependencias
2. ✅ Configurar Vitest
3. ✅ Crear archivo de setup
4. ✅ Implementar pruebas unitarias
5. ✅ Implementar pruebas de integración
6. ✅ Ejecutar y verificar cobertura
7. ✅ Configurar CI/CD
8. ✅ Documentar resultados

---

**Fecha de creación:** 2025-01-19
**Sistema:** SIGIMED v2.0
**Responsable:** Equipo de Desarrollo
