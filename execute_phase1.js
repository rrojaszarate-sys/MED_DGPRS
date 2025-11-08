const https = require('https');

const SUPABASE_URL = 'https://cyslhzynfuetthxngpoy.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQ1MTMzMSwiZXhwIjoyMDc4MDI3MzMxfQ.SAeM-AoJLCN5vTryASDVqGpEDiKEmkckYeZTvpybdAk';

const fs = require('fs');

const sqlScript = fs.readFileSync('./EJECUTAR_FASE_1_COMPLETA.sql', 'utf8');

console.log('🚀 Iniciando ejecución de Fase 1 completa...\n');
console.log('📝 Script SQL cargado: ' + sqlScript.length + ' caracteres\n');

// Ejecutar vía API REST de Supabase
const url = new URL('/rest/v1/rpc/exec_sql', SUPABASE_URL);

const postData = JSON.stringify({
  query: sqlScript
});

const options = {
  hostname: url.hostname,
  port: 443,
  path: '/rest/v1/rpc/exec_sql',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': SERVICE_ROLE_KEY,
    'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
    'Content-Length': Buffer.byteLength(postData)
  }
};

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📊 Status Code:', res.statusCode);
    console.log('📄 Response:', data);
    
    if (res.statusCode === 200 || res.statusCode === 201) {
      console.log('\n✅ Script ejecutado exitosamente');
    } else {
      console.log('\n❌ Error en la ejecución');
    }
  });
});

req.on('error', (e) => {
  console.error('❌ Error de conexión:', e.message);
});

req.write(postData);
req.end();
