#!/bin/bash
# ============================================
# EJECUTAR FASE 1 COMPLETA - Script Local
# ============================================
# Uso: ./ejecutar_fase1_local.sh
# Requiere: curl instalado
# ============================================

set -e  # Salir si hay error

echo "🚀 EJECUTANDO FASE 1 COMPLETA EN SUPABASE"
echo "=========================================="
echo ""

# Configuración
SUPABASE_URL="https://cyslhzynfuetthxngpoy.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQ1MTMzMSwiZXhwIjoyMDc4MDI3MzMxfQ.SAeM-AoJLCN5vTryASDVqGpEDiKEmkckYeZTvpybdAk"
SQL_FILE="FASE_1_COMPLETA_ALL_IN_ONE.sql"

# Verificar que existe el archivo SQL
if [ ! -f "$SQL_FILE" ]; then
  echo "❌ Error: No se encuentra el archivo $SQL_FILE"
  echo "   Asegúrate de estar en el directorio del proyecto"
  exit 1
fi

echo "📄 Archivo SQL encontrado: $SQL_FILE"
echo "📏 Tamaño: $(wc -l < "$SQL_FILE") líneas"
echo ""

# Método 1: Intentar via API REST (probablemente no funcione para DDL)
echo "⚠️  NOTA: La API REST de Supabase NO soporta comandos DDL (CREATE TABLE)"
echo "   Este script intentará, pero probablemente falle."
echo ""
echo "📌 RECOMENDACIÓN: Ejecutar manualmente en Supabase SQL Editor"
echo "   URL: ${SUPABASE_URL}/project/_/sql/new"
echo ""
read -p "¿Continuar de todos modos con el intento via API? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "✅ OPCIÓN RECOMENDADA:"
  echo "   1. Ve a: ${SUPABASE_URL}/project/_/sql/new"
  echo "   2. Copia el contenido de: $SQL_FILE"
  echo "   3. Pégalo en el editor"
  echo "   4. Click en 'Run' o Ctrl+Enter"
  echo ""
  echo "   Después ejecuta este script de nuevo para verificar."
  echo ""
  exit 0
fi

# Intentar ejecutar
echo "🔄 Intentando ejecutar SQL via API..."
echo ""

SQL_CONTENT=$(cat "$SQL_FILE")

# Escape JSON
SQL_JSON=$(jq -Rs . <<< "$SQL_CONTENT")

# Ejecutar
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${SUPABASE_URL}/rest/v1/rpc/exec_sql" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"query\": ${SQL_JSON}}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "📊 HTTP Status: $HTTP_CODE"
echo "📄 Response: $BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
  echo "✅ Script ejecutado exitosamente"
else
  echo "❌ Error al ejecutar el script"
  echo ""
  echo "💡 Esto es esperado - Supabase API REST no soporta DDL"
  echo ""
  echo "🔧 SOLUCIÓN:"
  echo "   Ejecuta el script manualmente en:"
  echo "   ${SUPABASE_URL}/project/_/sql/new"
  echo ""
fi

echo ""
echo "=========================================="
echo "🔍 VERIFICACIÓN"
echo "=========================================="
echo ""
echo "Verificando tablas creadas..."

# Verificar que las tablas existen
VERIFICATION=$(curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/suppliers?select=count&limit=0" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}")

if [[ $VERIFICATION == *"error"* ]] || [[ $VERIFICATION == *"does not exist"* ]]; then
  echo "❌ Tabla 'suppliers' NO existe aún"
  echo ""
  echo "📌 Por favor ejecuta el SQL manualmente en Supabase SQL Editor"
  exit 1
else
  echo "✅ Tabla 'suppliers' existe"
fi

# Verificar otras tablas
for table in batches batch_movements audit_log contracts suppliers; do
  RESULT=$(curl -s -X GET \
    "${SUPABASE_URL}/rest/v1/${table}?select=count&limit=0" \
    -H "apikey: ${SERVICE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_KEY}")

  if [[ $RESULT == *"error"* ]]; then
    echo "❌ Tabla '$table' NO existe"
  else
    echo "✅ Tabla '$table' existe"
  fi
done

echo ""
echo "=========================================="
echo "✅ EJECUCIÓN COMPLETADA"
echo "=========================================="
