#!/bin/bash

SUPABASE_URL="https://cyslhzynfuetthxngpoy.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQ1MTMzMSwiZXhwIjoyMDc4MDI3MzMxfQ.SAeM-AoJLCN5vTryASDVqGpEDiKEmkckYeZTvpybdAk"

echo "🔍 Verificando estructura actual de la base de datos..."

# Obtener lista de tablas
curl -s -X GET "${SUPABASE_URL}/rest/v1/rpc/exec" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"SELECT tablename FROM pg_tables WHERE schemaname = '\''public'\'' ORDER BY tablename"}' \
  2>&1 | head -20

