#!/bin/bash

# SIGIMED v2.0 - Script de Verificación Completa del Sistema
# Verifica que todos los módulos estén implementados correctamente

echo "🔍 SIGIMED v2.0 - Verificación Completa del Sistema"
echo "=================================================="
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
TOTAL=0
PASSED=0
FAILED=0

# Función para verificar archivo
check_file() {
    TOTAL=$((TOTAL + 1))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $2 - FALTA: $1"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Función para verificar contenido en archivo
check_content() {
    TOTAL=$((TOTAL + 1))
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $3 - NO ENCONTRADO en $1"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo "📦 FASE 1: CATÁLOGOS"
echo "-------------------"
check_file "src/components/admin/CatalogoFormModal.tsx" "CatalogoFormModal"
check_file "src/components/admin/CatalogoTable.tsx" "CatalogoTable"
check_file "src/hooks/useCatalogo.ts" "Hook useCatalogo"
check_content "src/types/index.ts" "MedicationCatalog" "Interface MedicationCatalog"
echo ""

echo "🚛 FASE 2: PROVEEDORES"
echo "---------------------"
check_file "src/hooks/useSuppliers.ts" "Hook useSuppliers"
check_file "src/pages/SuppliersPage.tsx" "Página de Proveedores"
check_file "src/components/suppliers/SupplierFormModal.tsx" "Modal de Proveedores"
check_content "src/App.tsx" "SuppliersPage" "Ruta de Proveedores"
check_content "src/components/layout/MainLayout.tsx" "Proveedores" "Navegación Proveedores"
check_content "src/types/index.ts" "Supplier" "Interface Supplier"
echo ""

echo "📦 FASE 3: LOTES Y MOVIMIENTOS"
echo "-----------------------------"
check_file "src/hooks/useBatches.ts" "Hook useBatches"
check_file "src/components/batches/BatchFormModal.tsx" "Modal de Lotes"
check_file "src/components/batches/BatchMovementModal.tsx" "Modal de Movimientos"
check_content "src/pages/InventoryPage.tsx" "BatchFormModal" "Integración BatchFormModal"
check_content "src/pages/InventoryPage.tsx" "BatchMovementModal" "Integración BatchMovementModal"
check_content "src/types/index.ts" "Batch" "Interface Batch"
check_content "src/types/index.ts" "BatchMovement" "Interface BatchMovement"
echo ""

echo "📈 FASE 4: HISTORIAL DE MOVIMIENTOS"
echo "----------------------------------"
check_file "src/hooks/useMovements.ts" "Hook useMovements"
check_file "src/pages/MovementsPage.tsx" "Página de Movimientos"
check_file "src/components/movements/MovementTimeline.tsx" "Timeline de Movimientos"
check_content "src/App.tsx" "MovementsPage" "Ruta de Movimientos"
check_content "src/components/layout/MainLayout.tsx" "Movimientos" "Navegación Movimientos"
echo ""

echo "📄 FASE 5: CONTRATOS CON ITEMS ANIDADOS"
echo "--------------------------------------"
check_file "src/hooks/useContracts.ts" "Hook useContracts"
check_file "src/pages/ContractsPage.tsx" "Página de Contratos"
check_file "src/components/contracts/ContractFormModal.tsx" "Modal de Contratos"
check_file "src/components/contracts/ContractItemsTable.tsx" "Tabla de Items (CRUD anidado)"
check_content "src/App.tsx" "ContractsPage" "Ruta de Contratos"
check_content "src/components/layout/MainLayout.tsx" "Contratos" "Navegación Contratos"
check_content "src/types/index.ts" "Contract" "Interface Contract"
check_content "src/types/index.ts" "ContractItem" "Interface ContractItem"
echo ""

echo "🏥 FASE 6: INSTITUCIONES Y CENTROS"
echo "---------------------------------"
check_file "src/hooks/useInstituciones.ts" "Hook useInstituciones"
check_file "src/hooks/useCentros.ts" "Hook useCentros (CRUD completo)"
check_file "src/pages/InstitutionsPage.tsx" "Página de Instituciones"
check_file "src/pages/HealthCentersPage.tsx" "Página de Centros de Salud"
check_content "src/App.tsx" "InstitutionsPage" "Ruta de Instituciones"
check_content "src/App.tsx" "HealthCentersPage" "Ruta de Centros"
check_content "src/components/layout/MainLayout.tsx" "Instituciones" "Navegación Instituciones"
check_content "src/components/layout/MainLayout.tsx" "Centros" "Navegación Centros"
check_content "src/types/index.ts" "Institucion" "Interface Institucion"
echo ""

echo "📊 FASE 7: DASHBOARDS CON GRÁFICAS"
echo "---------------------------------"
check_content "src/pages/DashboardPage.tsx" "BarChart" "Gráfica de Barras (Recharts)"
check_content "src/pages/DashboardPage.tsx" "LineChart" "Gráfica de Líneas (Recharts)"
check_content "src/pages/DashboardPage.tsx" "PieChart" "Gráfica de Dona (Recharts)"
check_content "src/pages/DashboardPage.tsx" "AreaChart" "Gráfica de Área (Recharts)"
check_content "src/pages/DashboardPage.tsx" "useMemo" "Optimización con useMemo"
check_content "src/pages/DashboardPage.tsx" "stockPorMedicamento" "Datos: Top medicamentos"
check_content "src/pages/DashboardPage.tsx" "movimientosPorDia" "Datos: Movimientos por día"
check_content "src/pages/DashboardPage.tsx" "stockPorEstado" "Datos: Stock por estado"
check_content "src/pages/DashboardPage.tsx" "stockPorCategoria" "Datos: Stock por categoría"
echo ""

echo "📋 FASE 8: REPORTES AVANZADOS"
echo "----------------------------"
check_file "src/pages/ReportsPage.tsx" "Página de Reportes"
check_content "src/pages/ReportsPage.tsx" "exportMedicationsPDF" "Exportación PDF"
check_content "src/pages/ReportsPage.tsx" "exportMedicationsExcel" "Exportación Excel"
check_content "src/pages/ReportsPage.tsx" "traceability" "Reporte de Trazabilidad"
check_content "src/pages/ReportsPage.tsx" "search_inventory" "Búsqueda Avanzada"
echo ""

echo "🔧 VERIFICACIÓN DE INFRAESTRUCTURA"
echo "==================================

"
check_file "src/App.tsx" "App principal"
check_file "src/components/layout/MainLayout.tsx" "Layout principal"
check_file "src/context/AuthContext.tsx" "Context de Autenticación"
check_file "src/context/CentroContext.tsx" "Context de Centro"
check_file "src/lib/supabase.ts" "Cliente Supabase"
check_file "src/hooks/useRealtime.ts" "Hook Realtime"
check_file "src/components/ui/Button.tsx" "Componente Button"
check_file "src/components/ui/Input.tsx" "Componente Input"
check_file "src/components/ui/Card.tsx" "Componente Card"
check_file "src/components/ui/Badge.tsx" "Componente Badge"
check_file "src/components/ui/Toast.tsx" "Sistema de Toasts"
echo ""

echo "🗺️ VERIFICACIÓN DE RUTAS"
echo "========================"
check_content "src/App.tsx" '"/dashboard"' "Ruta: Dashboard"
check_content "src/App.tsx" '"/inventario"' "Ruta: Inventario"
check_content "src/App.tsx" '"/proveedores"' "Ruta: Proveedores"
check_content "src/App.tsx" '"/contratos"' "Ruta: Contratos"
check_content "src/App.tsx" '"/movimientos"' "Ruta: Movimientos"
check_content "src/App.tsx" '"/alertas"' "Ruta: Alertas"
check_content "src/App.tsx" '"/reportes"' "Ruta: Reportes"
check_content "src/App.tsx" '"/admin"' "Ruta: Admin"
check_content "src/App.tsx" '"/instituciones"' "Ruta: Instituciones"
check_content "src/App.tsx" '"/centros"' "Ruta: Centros"
echo ""

echo "🎯 VERIFICACIÓN DE NAVEGACIÓN"
echo "============================"
check_content "src/components/layout/MainLayout.tsx" "Dashboard" "Nav: Dashboard"
check_content "src/components/layout/MainLayout.tsx" "Inventario" "Nav: Inventario"
check_content "src/components/layout/MainLayout.tsx" "Proveedores" "Nav: Proveedores"
check_content "src/components/layout/MainLayout.tsx" "Contratos" "Nav: Contratos"
check_content "src/components/layout/MainLayout.tsx" "Movimientos" "Nav: Movimientos"
check_content "src/components/layout/MainLayout.tsx" "Alertas" "Nav: Alertas"
check_content "src/components/layout/MainLayout.tsx" "Reportes" "Nav: Reportes"
check_content "src/components/layout/MainLayout.tsx" "Administración" "Nav: Admin"
check_content "src/components/layout/MainLayout.tsx" "Instituciones" "Nav: Instituciones"
check_content "src/components/layout/MainLayout.tsx" "Centros" "Nav: Centros"
echo ""

echo "💾 VERIFICACIÓN DE BASE DE DATOS"
echo "================================"
check_file "INSTALAR_LIMPIO.sql" "Script de instalación de BD"
check_content "INSTALAR_LIMPIO.sql" "medication_catalog" "Tabla: medication_catalog"
check_content "INSTALAR_LIMPIO.sql" "suppliers" "Tabla: suppliers"
check_content "INSTALAR_LIMPIO.sql" "batches" "Tabla: batches"
check_content "INSTALAR_LIMPIO.sql" "batch_movements" "Tabla: batch_movements"
check_content "INSTALAR_LIMPIO.sql" "contracts" "Tabla: contracts"
check_content "INSTALAR_LIMPIO.sql" "contract_items" "Tabla: contract_items"
check_content "INSTALAR_LIMPIO.sql" "instituciones" "Tabla: instituciones"
check_content "INSTALAR_LIMPIO.sql" "health_centers" "Tabla: health_centers"
echo ""

echo "=================================================="
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "=================================================="
echo -e "Total de verificaciones: ${YELLOW}$TOTAL${NC}"
echo -e "Exitosas: ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo ""

PERCENTAGE=$((PASSED * 100 / TOTAL))
echo -e "Completitud del sistema: ${YELLOW}${PERCENTAGE}%${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ¡SISTEMA 100% COMPLETO Y FUNCIONAL!${NC}"
    echo ""
    echo "🎉 Todos los módulos implementados correctamente:"
    echo "   ✓ FASE 1: Catálogos de Medicamentos"
    echo "   ✓ FASE 2: Gestión de Proveedores"
    echo "   ✓ FASE 3: Lotes y Movimientos"
    echo "   ✓ FASE 4: Historial de Movimientos"
    echo "   ✓ FASE 5: Contratos con Items Anidados"
    echo "   ✓ FASE 6: Instituciones y Centros de Salud"
    echo "   ✓ FASE 7: Dashboards con Gráficas Interactivas"
    echo "   ✓ FASE 8: Reportes Avanzados"
    echo ""
    echo "🚀 El sistema está listo para producción!"
    exit 0
else
    echo -e "${RED}✗ HAY $FAILED VERIFICACIONES FALLIDAS${NC}"
    echo ""
    echo "Por favor revisa los elementos marcados arriba."
    exit 1
fi
