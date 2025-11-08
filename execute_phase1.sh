#!/bin/bash

SUPABASE_URL="https://cyslhzynfuetthxngpoy.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQ1MTMzMSwiZXhwIjoyMDc4MDI3MzMxfQ.SAeM-AoJLCN5vTryASDVqGpEDiKEmkckYeZTvpybdAk"

echo "🚀 Ejecutando Fase 1 - Parte 1.1: TABLAS CORE"
echo "=============================================="
echo ""

# Leer el script SQL
SQL_SCRIPT=$(cat EJECUTAR_FASE_1_COMPLETA.sql)

# Ejecutar el script
curl -X POST "${SUPABASE_URL}/rest/v1/rpc/exec_sql" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(jq -Rs . < EJECUTAR_FASE_1_COMPLETA.sql)}" \
  2>&1

echo ""
echo "=============================================="
