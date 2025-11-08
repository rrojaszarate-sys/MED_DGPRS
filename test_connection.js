import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://cyslhzynfuetthxngpoy.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testConnection() {
  console.log('🔍 Probando conexión a Supabase...\n');
  
  // Probar consulta simple
  const { data, error } = await supabase
    .from('health_centers')
    .select('count');
  
  if (error) {
    console.log('❌ Error de conexión:', error.message);
  } else {
    console.log('✅ Conexión exitosa');
    console.log('📊 Datos:', data);
  }
}

testConnection();
