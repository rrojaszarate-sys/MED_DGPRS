# Instrucciones para Ejecutar Pruebas Automatizadas

## 📋 Requisitos Previos

- Node.js 18+ instalado
- npm o yarn
- Proyecto SIGIMED v2.0 clonado

---

## 🚀 Instalación Rápida

### Paso 1: Instalar dependencias de testing

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event @vitest/ui jsdom
```

### Paso 2: Actualizar package.json

Agregar estos scripts en la sección `"scripts"`:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

### Paso 3: Verificar archivos creados

Asegúrate de que existan estos archivos:
- ✅ `vitest.config.ts`
- ✅ `src/test/setup.ts`
- ✅ `src/hooks/__tests__/useMedicamentos.test.ts`

---

## ▶️ Ejecución de Pruebas

### Modo desarrollo (watch mode)

Ejecuta las pruebas y se re-ejecutan automáticamente al guardar cambios:

```bash
npm run test
```

### Ejecutar una sola vez

```bash
npm run test:run
```

### Con interfaz visual

Abre una interfaz web para ver los resultados:

```bash
npm run test:ui
```

Luego abre en el navegador: http://localhost:51204

### Con cobertura de código

```bash
npm run test:coverage
```

Esto generará un reporte HTML en `coverage/index.html`

---

## 📊 Interpretar Resultados

### Resultado exitoso:

```
✓ src/hooks/__tests__/useMedicamentos.test.ts (15)
  ✓ Carga de datos (2)
    ✓ debe cargar la lista de medicamentos correctamente
    ✓ debe filtrar medicamentos por centro de salud
  ✓ Detección de alertas (2)
    ✓ debe detectar medicamentos con stock bajo
    ✓ debe detectar medicamentos próximos a vencer
  ...

Test Files  1 passed (1)
     Tests  15 passed (15)
  Start at  10:30:00
  Duration  1.23s
```

### Si hay errores:

```
✗ src/hooks/__tests__/useMedicamentos.test.ts (1)
  ✗ debe cargar la lista de medicamentos correctamente
    Expected: 2
    Received: 0
```

---

## 🎯 Crear Nuevas Pruebas

### Ejemplo de test básico:

```typescript
import { describe, it, expect } from 'vitest';

describe('Mi Componente', () => {
  it('debe renderizar correctamente', () => {
    expect(true).toBe(true);
  });
});
```

### Ubicación de archivos de prueba:

```
src/
├── hooks/
│   ├── useMedicamentos.ts
│   └── __tests__/
│       └── useMedicamentos.test.ts
├── pages/
│   ├── Inventario.tsx
│   └── __tests__/
│       └── Inventario.test.tsx
└── test/
    └── setup.ts
```

---

## 🔧 Solución de Problemas

### Error: "Cannot find module 'vitest'"

```bash
npm install -D vitest
```

### Error: "jsdom is not defined"

```bash
npm install -D jsdom
```

### Error: "Module not found: @testing-library/react"

```bash
npm install -D @testing-library/react @testing-library/jest-dom
```

### Limpiar caché de Vitest

```bash
rm -rf node_modules/.vitest
npm run test
```

---

## ✅ Checklist de Pruebas

Antes de hacer commit/push:

- [ ] Todas las pruebas pasan (`npm run test:run`)
- [ ] Cobertura de código ≥ 80% (`npm run test:coverage`)
- [ ] No hay errores de lint (`npm run lint`)
- [ ] Build exitoso (`npm run build`)

---

## 📚 Recursos

- [Vitest Documentation](https://vitest.dev/)
- [Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Plan de Pruebas Automatizadas](./PLAN_PRUEBAS_AUTOMATIZADAS.md)

---

**Actualizado:** 2025-01-19
**Sistema:** SIGIMED v2.0
