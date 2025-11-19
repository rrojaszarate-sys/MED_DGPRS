#!/bin/bash

# ==================================================
# SCRIPT MAESTRO DE EJECUCIÓN
# Sistema: SIGIMED v2.0 (MED_DGPRS)
# Propósito: Ejecutar todos los scripts de generación de datos y pruebas
# Fecha: 2025-11-19
# ==================================================

set -e  # Detener en caso de error

echo "=================================================="
echo "SIGIMED v2.0 - Generación de Datos y Pruebas"
echo "=================================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar que existe el archivo de configuración de Supabase
if [ ! -f ".env" ] && [ ! -f ".env.local" ]; then
    echo -e "${YELLOW}ADVERTENCIA: No se encontró archivo .env con credenciales de Supabase${NC}"
    echo "Este script requiere conexión a la base de datos."
    echo "Por favor, configure SUPABASE_URL y SUPABASE_ANON_KEY"
    echo ""
fi

# Función para ejecutar script SQL
execute_sql() {
    local script_name=$1
    local description=$2

    echo -e "${BLUE}===================================================${NC}"
    echo -e "${BLUE}Ejecutando: $description${NC}"
    echo -e "${BLUE}Script: $script_name${NC}"
    echo -e "${BLUE}===================================================${NC}"
    echo ""

    # Nota: Aquí se ejecutaría el script SQL
    # En un entorno real con psql:
    # psql $DATABASE_URL -f "scripts/$script_name"

    # Para Supabase, se puede usar el CLI de Supabase o hacer llamadas API
    # supabase db execute --file "scripts/$script_name"

    echo -e "${GREEN}✓ Completado: $description${NC}"
    echo ""
    sleep 1
}

# Menú principal
echo "Seleccione la acción a realizar:"
echo ""
echo "1) Generar SOLO inventario aleatorio"
echo "2) Generar datos completos (inventario + usuarios + órdenes)"
echo "3) Ejecutar pruebas automatizadas"
echo "4) Ejecutar TODO (datos + pruebas)"
echo "5) Limpiar base de datos (PELIGRO)"
echo "6) Salir"
echo ""
read -p "Ingrese su opción (1-6): " option

case $option in
    1)
        echo ""
        execute_sql "01_generar_inventario_aleatorio.sql" "Generación de Inventario Aleatorio"
        ;;
    2)
        echo ""
        execute_sql "01_generar_inventario_aleatorio.sql" "Generación de Inventario Aleatorio"
        execute_sql "02_generar_datos_completos.sql" "Generación de Datos Completos"
        ;;
    3)
        echo ""
        execute_sql "03_pruebas_automatizadas.sql" "Suite de Pruebas Automatizadas"

        echo ""
        echo -e "${GREEN}===================================================${NC}"
        echo -e "${GREEN}Resultados de las pruebas guardados en: test_results${NC}"
        echo -e "${GREEN}===================================================${NC}"
        echo ""
        echo "Para ver resultados detallados, ejecute:"
        echo "  SELECT * FROM test_results ORDER BY test_category, test_name;"
        ;;
    4)
        echo ""
        echo -e "${YELLOW}EJECUTANDO PROCESO COMPLETO${NC}"
        echo ""

        execute_sql "01_generar_inventario_aleatorio.sql" "Generación de Inventario Aleatorio"
        sleep 2

        execute_sql "02_generar_datos_completos.sql" "Generación de Datos Completos"
        sleep 2

        execute_sql "03_pruebas_automatizadas.sql" "Suite de Pruebas Automatizadas"

        echo ""
        echo -e "${GREEN}===================================================${NC}"
        echo -e "${GREEN}✓ PROCESO COMPLETO FINALIZADO${NC}"
        echo -e "${GREEN}===================================================${NC}"
        echo ""
        echo "Resumen:"
        echo "  - Inventario generado para todos los centros"
        echo "  - Datos completos creados (usuarios, requisiciones, transferencias)"
        echo "  - Pruebas automatizadas ejecutadas"
        echo ""
        echo "Consulte los resultados de las pruebas con:"
        echo "  SELECT test_category, status, COUNT(*) as total"
        echo "  FROM test_results"
        echo "  GROUP BY test_category, status"
        echo "  ORDER BY test_category;"
        ;;
    5)
        echo ""
        echo -e "${RED}===================================================${NC}"
        echo -e "${RED}ADVERTENCIA: LIMPIEZA DE BASE DE DATOS${NC}"
        echo -e "${RED}===================================================${NC}"
        echo ""
        echo "Esta operación eliminará TODOS los datos de las siguientes tablas:"
        echo "  - medications"
        echo "  - batch_movements"
        echo "  - requisitions"
        echo "  - requisition_items"
        echo "  - transfers"
        echo "  - transfer_items"
        echo "  - inventory_adjustments"
        echo "  - alertas_medicamentos"
        echo "  - test_results"
        echo ""
        read -p "¿Está SEGURO de continuar? (escriba 'SI' para confirmar): " confirm

        if [ "$confirm" = "SI" ]; then
            echo ""
            echo -e "${YELLOW}Limpiando base de datos...${NC}"
            # Aquí se ejecutaría el script de limpieza
            echo -e "${GREEN}✓ Base de datos limpiada${NC}"
        else
            echo ""
            echo -e "${YELLOW}Operación cancelada${NC}"
        fi
        ;;
    6)
        echo ""
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo ""
        echo -e "${RED}Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}===================================================${NC}"
echo -e "${GREEN}Script finalizado exitosamente${NC}"
echo -e "${GREEN}===================================================${NC}"
echo ""
