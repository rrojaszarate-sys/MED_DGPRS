# 🔍 ANÁLISIS DE INTEGRACIÓN FRONTEND-BACKEND - SIGIMED v2.0

## 📅 Fecha de análisis: 18 de Noviembre de 2025

---

## ✅ RESUMEN EJECUTIVO

### Estado General: ⚠️ **CRÍTICO - REQUIERE ACTUALIZACIÓN URGENTE**

**Problema principal identificado:**
El frontend fue desarrollado con nombres de tablas en INGLÉS, pero la base de datos fue implementada con nombres en ESPAÑOL (siguiendo los nuevos estándares del proyecto).

**Impacto:**
- ❌ **0% de funcionalidad operativa** - Ningún hook puede conectarse a la BD actual
- ❌ Todas las páginas administrativas no funcionan
- ❌ CRUD operations están rotas
- ❌ Realtime subscriptions no funcionan

---

## 📊 INVENTARIO DE COMPONENTES EXISTENTES

### **Frontend Implementado:**

#### **✅ Páginas (18 páginas):**
1. `LoginPage` - Autenticación
2. `DashboardPage` - Panel principal
3. `InventoryPage` - Gestión de inventario
4. `MovementsPage` - Movimientos de lotes
5. `SuppliersPage` - Proveedores
6. `ContractsPage` - Contratos (⚠️ tabla no existe en BD)
7. `AdminPage` - Administración general
8. `ReportsPage` - Reportes
9. `AlertasPage` - Alertas
10. `InstitutionsPage` - Instituciones
11. `HealthCentersPage` - Centros de salud
12. `TemperatureMonitoringPage` - Monitoreo de temperatura
13. `WarehouseMapPage` - Mapa de almacén
14. `AuditLogPage` - Log de auditoría
15. `UsersManagementPage` - Gestión de usuarios

#### **✅ Hooks (17 hooks):**
1. `useAlertas` - Alertas de medicamentos
2. `useAuditLog` - Log de auditoría
3. `useBatchMovements` - Movimientos de lotes
4. `useBatches` - Lotes
5. `useCatalogo` - Catálogo de medicamentos
6. `useCentros` - Centros de salud
7. `useContracts` - Contratos
8. `useImport` - Importación de datos
9. `useInstituciones` - Instituciones
10. `useMedicamentos` - Medicamentos
11. `useMovements` - Movimientos
12. `useRealtime` - Subscripciones en tiempo real
13. `useSuppliers` - Proveedores
14. `useTemperatureMonitoring` - Monitoreo de temperatura
15. `useUsers` - Usuarios
16. `useWarehouseLocations` - Ubicaciones de almacén

#### **✅ Contextos:**
- `AuthContext` - Contexto de autenticación
- `CentroContext` - Contexto de centro seleccionado

---

## 🚨 DISCREPANCIAS CRÍTICAS IDENTIFICADAS

### **Mapeo de Tablas Incorrectas:**

| Hook | Tabla Actual (Inglés) | Tabla Correcta (Español) | Estado |
|------|----------------------|-------------------------|---------|
| `useAlertas` | `alertas_medicamentos` | `alertas_interacciones` | ❌ ROTO |
| `useAuditLog` | `audit_log` | `registro_auditoria` | ❌ ROTO |
| `useBatchMovements` | `batch_movements` | `movimientos_lotes` | ❌ ROTO |
| `useBatches` | `batches` | `lotes` | ❌ ROTO |
| `useCatalogo` | `medication_catalog` | `catalogo_medicamentos` | ❌ ROTO |
| `useCentros` | `health_centers` | `centros_salud` | ❌ ROTO |
| `useContracts` | `contracts` | ❌ **NO EXISTE** | ❌ ROTO |
| `useContracts` | `contract_items` | ❌ **NO EXISTE** | ❌ ROTO |
| `useMedicamentos` | `medications` | `medicamentos` | ❌ ROTO |
| `useSuppliers` | `suppliers` | `proveedores` | ❌ ROTO |
| `useUsers` | `users_profiles` | `perfiles_usuario` | ❌ ROTO |
| `useInstituciones` | `instituciones` | `instituciones` | ✅ OK |
| `useTemperatureMonitoring` | `excursiones_termicas` | `excursiones_termicas` | ✅ OK |
| `useWarehouseLocations` | `ubicaciones_almacen` | `ubicaciones_almacen` | ✅ OK |

**Resumen de discrepancias:**
- ❌ **10 hooks rotos** (usan nombres en inglés)
- ✅ **3 hooks funcionando** (ya usan español)
- ❌ **2 tablas no existen** (`contracts`, `contract_items` - no implementadas en BD)

---

## 📋 TABLAS EN BASE DE DATOS (51 tablas)

### **Nivel 1-2: Tablas Base**
- ✅ `instituciones` - Hook: ✅ OK
- ✅ `perfiles_usuario` - Hook: ❌ usa `users_profiles`
- ✅ `centros_salud` - Hook: ❌ usa `health_centers`
- ✅ `proveedores` - Hook: ❌ usa `suppliers`
- ✅ `catalogo_medicamentos` - Hook: ❌ usa `medication_catalog`

### **Nivel 3-4: Inventario**
- ✅ `medicamentos` - Hook: ❌ usa `medications`
- ✅ `lotes` - Hook: ❌ usa `batches`
- ✅ `movimientos_lotes` - Hook: ❌ usa `batch_movements`
- ✅ `ubicaciones_almacen` - Hook: ✅ OK
- ✅ `lotes_ubicaciones` - Hook: ❌ NO IMPLEMENTADO
- ✅ `permisos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `roles_usuario` - Hook: ❌ NO IMPLEMENTADO
- ✅ `centros_usuario` - Hook: ❌ NO IMPLEMENTADO

### **Nivel 5-7: Trazabilidad**
- ✅ `gs1_configuracion_empresa` - Hook: ❌ NO IMPLEMENTADO
- ✅ `gs1_gtins` - Hook: ❌ NO IMPLEMENTADO
- ✅ `etiquetas_codigo_barras` - Hook: ❌ NO IMPLEMENTADO
- ✅ `escaneos_codigo_barras` - Hook: ❌ NO IMPLEMENTADO
- ✅ `serializaciones_medicamentos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `dscsa_historial_transacciones` - Hook: ❌ NO IMPLEMENTADO
- ✅ `dscsa_solicitudes_verificacion` - Hook: ❌ NO IMPLEMENTADO
- ✅ `eventos_epcis` - Hook: ❌ NO IMPLEMENTADO
- ✅ `monitoreo_temperatura` - Hook: ⚠️ IMPLEMENTADO (verificar nombre)
- ✅ `excursiones_termicas` - Hook: ✅ OK
- ✅ `ingredientes_activos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `medicamentos_ingredientes_activos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `interacciones_medicamentos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `contraindicaciones_medicamentos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `alertas_interacciones` - Hook: ❌ usa `alertas_medicamentos`
- ✅ `codigos_qr` - Hook: ❌ NO IMPLEMENTADO
- ✅ `escaneos_codigos_qr` - Hook: ❌ NO IMPLEMENTADO
- ✅ `exportaciones_avanzadas` - Hook: ❌ NO IMPLEMENTADO

### **Nivel 8-10: Integración y Analytics**
- ✅ `fhir_puntos_conexion` - Hook: ❌ NO IMPLEMENTADO
- ✅ `fhir_mapeos_recursos` - Hook: ❌ NO IMPLEMENTADO
- ✅ `fhir_transacciones` - Hook: ❌ NO IMPLEMENTADO
- ✅ `fhir_identificadores` - Hook: ❌ NO IMPLEMENTADO
- ✅ `plantillas_notificacion` - Hook: ❌ NO IMPLEMENTADO
- ✅ `preferencias_notificacion_usuario` - Hook: ❌ NO IMPLEMENTADO
- ✅ `cola_notificaciones` - Hook: ❌ NO IMPLEMENTADO
- ✅ `registro_entrega_notificaciones` - Hook: ❌ NO IMPLEMENTADO
- ✅ `notificaciones_app` - Hook: ❌ NO IMPLEMENTADO
- ✅ `definiciones_kpi` - Hook: ❌ NO IMPLEMENTADO
- ✅ `instantaneas_kpi` - Hook: ❌ NO IMPLEMENTADO
- ✅ `widgets_tablero` - Hook: ❌ NO IMPLEMENTADO
- ✅ `tableros_usuario` - Hook: ❌ NO IMPLEMENTADO
- ✅ `eventos_analitica` - Hook: ❌ NO IMPLEMENTADO
- ✅ `registro_auditoria` - Hook: ❌ usa `audit_log`

---

## 🎯 PLAN DE CORRECCIÓN

### **FASE 1: CORRECCIÓN URGENTE (Prioridad 🔴 ALTA)**

#### **1.1. Actualizar Hooks Existentes (10 hooks)**
Cambiar nombres de tablas de inglés a español:

- [ ] `useAlertas.ts` → `alertas_medicamentos` → `alertas_interacciones`
- [ ] `useAuditLog.ts` → `audit_log` → `registro_auditoria`
- [ ] `useBatchMovements.ts` → `batch_movements` → `movimientos_lotes`
- [ ] `useBatches.ts` → `batches` → `lotes`
- [ ] `useCatalogo.ts` → `medication_catalog` → `catalogo_medicamentos`
- [ ] `useCentros.ts` → `health_centers` → `centros_salud`
- [ ] `useMedicamentos.ts` → `medications` → `medicamentos`
- [ ] `useSuppliers.ts` → `suppliers` → `proveedores`
- [ ] `useUsers.ts` → `users_profiles` → `perfiles_usuario`
- [ ] `useTemperatureMonitoring.ts` → Verificar si usa `monitoreo_temperatura`

**Tiempo estimado:** 2-3 horas

#### **1.2. Eliminar/Actualizar Hooks de Contratos**
Opciones:
- **Opción A:** Eliminar `useContracts.ts` y `ContractsPage.tsx` (las tablas no existen)
- **Opción B:** Implementar tablas `contratos` y `contratos_items` en la BD

**Recomendación:** Opción A (eliminar) por ahora, implementar después si se requiere.

**Tiempo estimado:** 30 minutos

---

### **FASE 2: IMPLEMENTACIÓN DE HOOKS FALTANTES (Prioridad 🟡 MEDIA)**

#### **2.1. Hooks Críticos para Funcionalidad Completa**
- [ ] `useLotesUbicaciones.ts` - Gestión de ubicaciones de lotes
- [ ] `usePermisos.ts` - Sistema de permisos
- [ ] `useRolesUsuario.ts` - Roles personalizados
- [ ] `useCentrosUsuario.ts` - Asignación centros-usuarios
- [ ] `useMonitoreoTemperatura.ts` - Monitoreo activo (si no existe)

**Tiempo estimado:** 3-4 horas

#### **2.2. Hooks de Trazabilidad GS1/DSCSA**
- [ ] `useGS1Configuracion.ts` - Configuración GS1
- [ ] `useGS1GTINs.ts` - Códigos GTIN
- [ ] `useEtiquetasCodigoBarras.ts` - Etiquetas
- [ ] `useEscaneosCodigoBarras.ts` - Escaneos
- [ ] `useSerializaciones.ts` - Serialización DSCSA
- [ ] `useDSCSAHistorial.ts` - Historial transacciones
- [ ] `useEventosEPCIS.ts` - Eventos EPCIS
- [ ] `useCodigosQR.ts` - QR codes
- [ ] `useEscaneosQR.ts` - Escaneos QR

**Tiempo estimado:** 5-6 horas

#### **2.3. Hooks de Seguridad del Paciente**
- [ ] `useIngredientesActivos.ts` - Ingredientes
- [ ] `useInteracciones.ts` - Interacciones medicamentosas
- [ ] `useContraindicaciones.ts` - Contraindicaciones

**Tiempo estimado:** 2-3 horas

#### **2.4. Hooks de Notificaciones**
- [ ] `usePlantillasNotificacion.ts` - Templates
- [ ] `usePreferenciasNotificacion.ts` - Preferencias usuario
- [ ] `useColaNotificaciones.ts` - Cola de envío
- [ ] `useNotificacionesApp.ts` - Notificaciones in-app

**Tiempo estimado:** 3-4 horas

#### **2.5. Hooks de Analytics/KPIs**
- [ ] `useDefinicionesKPI.ts` - Definiciones KPI
- [ ] `useInstantaneasKPI.ts` - Snapshots históricos
- [ ] `useWidgets.ts` - Widgets de dashboards
- [ ] `useTableros.ts` - Dashboards usuario
- [ ] `useEventosAnalitica.ts` - Tracking eventos

**Tiempo estimado:** 4-5 horas

#### **2.6. Hooks de Integración FHIR**
- [ ] `useFHIREndpoints.ts` - Endpoints FHIR
- [ ] `useFHIRMapeos.ts` - Mapeo recursos
- [ ] `useFHIRTransacciones.ts` - Transacciones

**Tiempo estimado:** 3-4 horas

---

### **FASE 3: PÁGINAS ADMINISTRATIVAS FALTANTES (Prioridad 🟡 MEDIA)**

#### **3.1. Catálogos Administrables (CRÍTICO según estándares)**
- [ ] `CatalogoMedicamentosPage.tsx` - CRUD catálogo medicamentos (99 meds)
- [ ] `IngredientesActivosPage.tsx` - CRUD ingredientes activos
- [ ] `InteraccionesMedicamentosPage.tsx` - CRUD interacciones
- [ ] `ContraindicacionesPage.tsx` - CRUD contraindicaciones
- [ ] `PlantillasNotificacionPage.tsx` - CRUD templates notificaciones
- [ ] `DefinicionesKPIPage.tsx` - CRUD KPIs
- [ ] `WidgetsPage.tsx` - CRUD widgets dashboards

**Tiempo estimado:** 8-10 horas

#### **3.2. Módulos de Trazabilidad**
- [ ] `TrazabilidadGS1Page.tsx` - Gestión GTIN y códigos de barras
- [ ] `SerializacionDSCSAPage.tsx` - Gestión serialización FDA
- [ ] `EventosEPCISPage.tsx` - Visualización eventos cadena suministro
- [ ] `CodigosQRPage.tsx` - Generación y gestión QR

**Tiempo estimado:** 6-8 horas

#### **3.3. Módulos de Seguridad Clínica**
- [ ] `AlertasInteraccionesPage.tsx` - Alertas automáticas
- [ ] `VerificacionDSCSAPage.tsx` - Verificación productos

**Tiempo estimado:** 3-4 horas

#### **3.4. Integración y Comunicaciones**
- [ ] `FHIRConfigPage.tsx` - Configuración FHIR
- [ ] `NotificacionesConfigPage.tsx` - Configuración notificaciones
- [ ] `DashboardsConfigPage.tsx` - Configuración dashboards personalizados

**Tiempo estimado:** 5-6 horas

---

### **FASE 4: CONFIGURACIÓN Y PRUEBAS (Prioridad 🔴 ALTA)**

#### **4.1. Row Level Security (RLS)**
- [ ] Configurar políticas RLS en Supabase para todas las 51 tablas
- [ ] Implementar políticas por rol (super_admin, admin_center, pharmacist, etc.)
- [ ] Implementar políticas por centro (usuarios solo ven su centro)

**Tiempo estimado:** 4-5 horas

#### **4.2. Pruebas Funcionales**
- [ ] Probar CRUD de cada catálogo
- [ ] Probar movimientos de lotes
- [ ] Probar generación de códigos (GTIN, QR)
- [ ] Probar notificaciones
- [ ] Probar dashboards y KPIs
- [ ] Probar autenticación y autorización
- [ ] Probar restricciones por rol y centro

**Tiempo estimado:** 6-8 horas

#### **4.3. Pruebas de Integración**
- [ ] Flujo completo: Recepción → Almacenamiento → Dispensación
- [ ] Flujo de trazabilidad: Lote → Serialización → Eventos EPCIS
- [ ] Flujo de alertas: Interacción → Alerta → Notificación
- [ ] Flujo de reportes: Datos → KPI → Dashboard

**Tiempo estimado:** 4-5 horas

#### **4.4. Corrección de Errores**
- [ ] Corregir bugs encontrados en pruebas
- [ ] Optimizar consultas lentas
- [ ] Refactorizar código duplicado

**Tiempo estimado:** Variable (2-8 horas dependiendo de hallazgos)

---

## 📊 ESTIMACIONES TOTALES

| Fase | Prioridad | Tiempo Estimado | Estado |
|------|-----------|----------------|--------|
| **Fase 1: Corrección Urgente** | 🔴 ALTA | 2.5 - 3.5 horas | Pendiente |
| **Fase 2: Hooks Faltantes** | 🟡 MEDIA | 20 - 26 horas | Pendiente |
| **Fase 3: Páginas Faltantes** | 🟡 MEDIA | 22 - 28 horas | Pendiente |
| **Fase 4: Config y Pruebas** | 🔴 ALTA | 16 - 26 horas | Pendiente |
| **TOTAL** | - | **60.5 - 83.5 horas** | **0% completo** |

**Estimación conservadora:** 10-11 días laborales (8 horas/día)

---

## 🎯 RECOMENDACIÓN DE EJECUCIÓN

### **Iteración 1 (Prioritaria - 1-2 días):**
1. ✅ Actualizar 10 hooks rotos (Fase 1.1)
2. ✅ Configurar RLS básico (Fase 4.1)
3. ✅ Probar funcionalidad básica (Fase 4.2 - parcial)

**Objetivo:** Sistema funcional para módulos básicos (inventario, centros, usuarios)

### **Iteración 2 (Importante - 2-3 días):**
1. ✅ Crear hooks críticos (Fase 2.1)
2. ✅ Implementar páginas de catálogos administrables (Fase 3.1)
3. ✅ Pruebas completas de catálogos (Fase 4.2)

**Objetivo:** Todos los catálogos administrables desde UI

### **Iteración 3 (Avanzada - 3-4 días):**
1. ✅ Implementar trazabilidad GS1/DSCSA (Fase 2.2 + Fase 3.2)
2. ✅ Implementar seguridad clínica (Fase 2.3 + Fase 3.3)
3. ✅ Pruebas de integración (Fase 4.3)

**Objetivo:** Trazabilidad completa y alertas de seguridad

### **Iteración 4 (Complementaria - 2-3 días):**
1. ✅ Implementar notificaciones (Fase 2.4)
2. ✅ Implementar analytics/KPIs (Fase 2.5 + Fase 3.4)
3. ✅ Implementar FHIR (Fase 2.6 + Fase 3.4)
4. ✅ Corrección final de errores (Fase 4.4)

**Objetivo:** Sistema 100% completo y funcional

---

## 📝 NOTAS IMPORTANTES

### **Decisiones Técnicas Pendientes:**

1. **Contratos (contracts):**
   - ❓ ¿Implementar o eliminar?
   - Si implementar: Crear tablas `contratos` y `contratos_items`
   - Si eliminar: Remover `useContracts.ts` y `ContractsPage.tsx`

2. **Vistas SQL:**
   - Hook usa `v_temperatura_ubicaciones` (vista)
   - ⚠️ Verificar si existe en BD o crear

3. **Nombres de campos:**
   - BD usa: `direccion`, `telefono`, `ciudad`
   - Frontend puede usar: `address`, `phone`, `city`
   - ⚠️ Verificar consistencia en interfaces TypeScript

### **Riesgos Identificados:**

1. 🔴 **ALTO:** Sin las correcciones de Fase 1, el sistema está 100% inoperativo
2. 🟡 **MEDIO:** Falta del 60% de funcionalidad prevista (hooks y páginas faltantes)
3. 🟡 **MEDIO:** Sin RLS, cualquier usuario puede ver/modificar todo
4. 🟢 **BAJO:** Rendimiento de queries (optimizable con índices ya existentes)

---

## ✅ PRÓXIMO PASO INMEDIATO

**Acción recomendada:** Iniciar **FASE 1: CORRECCIÓN URGENTE**

Comenzar actualizando los hooks rotos en el siguiente orden de prioridad:
1. `useCentros.ts` → `centros_salud`
2. `useUsers.ts` → `perfiles_usuario`
3. `useCatalogo.ts` → `catalogo_medicamentos`
4. `useBatches.ts` → `lotes`
5. `useBatchMovements.ts` → `movimientos_lotes`
6. `useSuppliers.ts` → `proveedores`
7. `useMedicamentos.ts` → `medicamentos`
8. `useAuditLog.ts` → `registro_auditoria`
9. `useAlertas.ts` → `alertas_interacciones`
10. `useTemperatureMonitoring.ts` → Verificar tabla actual

---

**Documento generado:** 18 de Noviembre de 2025
**Versión:** 1.0
**Próxima revisión:** Después de completar Fase 1
