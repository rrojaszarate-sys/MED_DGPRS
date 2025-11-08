import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';

const supabaseUrl = 'https://cyslhzynfuetthxngpoy.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY';

const supabase = createClient(supabaseUrl, supabaseKey);

async function executeMigration() {
  try {
    console.log('🚀 Iniciando ejecución de migración Fase 1.1...\n');
    
    // Leer el archivo SQL
    const sqlContent = readFileSync('./migrations/01_crear_tablas_core.sql', 'utf8');
    
    // Ejecutar el SQL completo
    const { data, error } = await supabase.rpc('exec_sql', { sql_query: sqlContent });
    
    if (error) {
      // Si no existe la función exec_sql, intentar ejecutar directamente
      console.log('⚠️  Función exec_sql no disponible, ejecutando con query directo...\n');
      
      const result = await fetch(`${supabaseUrl}/rest/v1/rpc/exec_sql`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`
        },
        body: JSON.stringify({ query: sqlContent })
      });
      
      if (!result.ok) {
        throw new Error(`HTTP error: ${result.status}`);
      }
      
      console.log('✅ Migración ejecutada exitosamente\n');
    } else {
      console.log('✅ Migración ejecutada exitosamente\n');
      console.log('Datos:', data);
    }
    
    // Verificar las tablas creadas
    console.log('🔍 Verificando tablas creadas...\n');
    
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .in('table_name', ['suppliers', 'batches', 'batch_movements'])
      .eq('table_schema', 'public');
    
    if (!tablesError && tables) {
      console.log('📊 Tablas encontradas:');
      tables.forEach(t => console.log(`   ✓ ${t.table_name}`));
    }
    
  } catch (err) {
    console.error('❌ Error ejecutando migración:', err.message);
    process.exit(1);
  }
}

executeMigration();
