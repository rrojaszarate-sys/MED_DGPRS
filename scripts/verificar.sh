#!/bin/bash

# ================================================
# Script de Verificación de Datos de Prueba
# Sistema: SIGIMED v2.0 - Catálogos
# ================================================

echo "╔════════════════════════════════════════════════╗"
echo "║   VERIFICACIÓN DE DATOS DE PRUEBA - SIGIMED    ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Verificar si psql está instalado
if ! command -v psql &> /dev/null; then
    echo "❌ ERROR: psql no está instalado"
    echo ""
    echo "Por favor usa una de estas alternativas:"
    echo "1. Supabase Dashboard (SQL Editor)"
    echo "2. DBeaver / TablePlus / pgAdmin"
    echo ""
    echo "Ver scripts/README_VERIFICACION.md para instrucciones"
    exit 1
fi

# Verificar DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
    echo "⚠️  WARNING: DATABASE_URL no está configurada"
    echo ""
    echo "Por favor configura DATABASE_URL o proporciona conexión manualmente"
    echo ""
    echo "Uso:"
    echo "  export DATABASE_URL='postgresql://user:pass@host:port/db'"
    echo "  ./scripts/verificar.sh"
    echo ""
    echo "O ejecuta directamente:"
    echo "  psql 'tu-connection-string' -f scripts/verificar_datos_prueba.sql"
    exit 1
fi

echo "📊 Ejecutando verificación de datos..."
echo "🔗 Conectando a base de datos..."
echo ""

# Ejecutar script SQL
psql "$DATABASE_URL" -f "$(dirname "$0")/verificar_datos_prueba.sql"

RESULT=$?

echo ""
echo "════════════════════════════════════════════════"

if [ $RESULT -eq 0 ]; then
    echo "✅ Verificación completada"
    echo ""
    echo "📋 Copia TODOS los resultados de arriba y pégalos"
    echo "   en la conversación para análisis."
else
    echo "❌ Error al ejecutar verificación"
    echo ""
    echo "Verifica:"
    echo "  - Conexión a base de datos"
    echo "  - DATABASE_URL correcta"
    echo "  - Permisos de usuario"
fi

echo "════════════════════════════════════════════════"
echo ""
