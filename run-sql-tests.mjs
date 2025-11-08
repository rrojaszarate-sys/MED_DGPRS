#!/usr/bin/env node
/**
 * Ejecutar pruebas SQL automatizadas en Supabase
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';

const SUPABASE_URL = 'https://cyslhzynfuetthxngpoy.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

console.log('\n🚀 Ejecutando pruebas SQL automatizadas...\n');

try {
  // Leer el script SQL
  const sqlScript = readFileSync('./TEST_COMPLETO_AUTOMATIZADO.sql', 'utf8');

  console.log('📄 Script SQL cargado:', sqlScript.length, 'caracteres');
  console.log('⏳ Ejecutando pruebas (esto puede tomar ~30 segundos)...\n');

  // Ejecutar el script completo
  const { data, error } = await supabase.rpc('exec_sql', { sql_query: sqlScript });

  if (error) {
    console.error('❌ Error ejecutando SQL:', error);

    // Si exec_sql no existe, intentar ejecutar por partes
    console.log('\n⚠️  La función exec_sql no está disponible.');
    console.log('📝 Intentando ejecutar las pruebas por partes...\n');

    await runTestsManually();
  } else {
    console.log('✅ Pruebas ejecutadas exitosamente');
    console.log('\n📊 Resultados:', data);
  }

} catch (error) {
  console.error('❌ Error:', error.message);
  console.log('\n💡 Ejecutando pruebas individuales...\n');
  await runTestsManually();
}

async function runTestsManually() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║     EJECUTANDO PRUEBAS INDIVIDUALES                       ║');
  console.log('╚═══════════════════════════════════════════════════════════╝\n');

  let passCount = 0;
  let failCount = 0;
  const testResults = [];

  // IDs de prueba
  const TEST_IDS = {
    hospital_central: '11111111-1111-1111-1111-111111111111',
    centro_norte: '22222222-2222-2222-2222-222222222222',
    posta_sur: '33333333-3333-3333-3333-333333333333',
    proveedor1: 'aaaa1111-aaaa-1111-aaaa-111111111111',
    proveedor2: 'bbbb2222-bbbb-2222-bbbb-222222222222',
    amoxicilina_cat: 'cccc1111-cccc-1111-cccc-111111111111',
    paracetamol_cat: 'cccc3333-cccc-3333-cccc-333333333333',
    ciprofloxacino_cat: 'cccc2222-cccc-2222-cccc-222222222222',
    losartan_cat: 'cccc5555-cccc-5555-cccc-555555555555',
    insulina_cat: 'cccc8888-cccc-8888-cccc-888888888888',
    paracetamol_hosp: 'dddd3333-dddd-3333-dddd-333333333333',
    amoxicilina_hosp: 'dddd1111-dddd-1111-dddd-111111111111',
  };

  console.log('🧹 PASO 1: Limpiando datos de prueba anteriores...\n');

  // Limpiar datos anteriores
  await supabase.from('batch_movements').delete().like('numero_documento', 'TEST-%');
  await supabase.from('medications').delete().like('lote', 'TEST-%');
  await supabase.from('medication_catalog').delete().like('nombre_comercial', '%PRUEBA%');
  await supabase.from('suppliers').delete().like('ruc', 'TEST%');
  await supabase.from('health_centers').delete().like('code', 'TEST-%');

  console.log('✅ Limpieza completada\n');

  console.log('📦 PASO 2: Insertando datos de prueba...\n');

  // TEST 1: Insertar centros de salud
  console.log('🧪 TEST 1: Inserción de Centros de Salud');
  const { data: centers, error: centerError } = await supabase
    .from('health_centers')
    .insert([
      {
        id: TEST_IDS.hospital_central,
        name: 'Hospital Central de Prueba',
        code: 'TEST-HCP-001',
        address: 'Av. Principal 123',
        city: 'Lima',
        region: 'Lima',
        phone: '+51-1-234-5678',
        storage_capacity: 5000,
        has_refrigeration: true,
        is_active: true,
      },
      {
        id: TEST_IDS.centro_norte,
        name: 'Centro de Salud Norte',
        code: 'TEST-CSN-002',
        address: 'Jr. Los Olivos 456',
        city: 'Lima',
        region: 'Lima',
        storage_capacity: 2000,
        has_refrigeration: true,
        is_active: true,
      },
      {
        id: TEST_IDS.posta_sur,
        name: 'Posta Médica Sur',
        code: 'TEST-PMS-003',
        address: 'Calle Las Flores 789',
        city: 'Arequipa',
        region: 'Arequipa',
        storage_capacity: 1000,
        has_refrigeration: false,
        is_active: true,
      }
    ])
    .select();

  if (centerError) {
    console.log(`  ❌ FAIL: ${centerError.message}`);
    failCount++;
    testResults.push({ test: 1, name: 'Centros de Salud', result: 'FAIL', error: centerError.message });
  } else {
    console.log(`  ✅ PASS (3 centros insertados)`);
    passCount++;
    testResults.push({ test: 1, name: 'Centros de Salud', result: 'PASS', count: centers.length });
  }

  // TEST 2: Insertar proveedores
  console.log('🧪 TEST 2: Inserción de Proveedores');
  const { data: suppliers, error: supplierError } = await supabase
    .from('suppliers')
    .insert([
      {
        id: TEST_IDS.proveedor1,
        name: 'Farmacéutica Global SAC',
        ruc: 'TEST20123456789',
        is_active: true,
      },
      {
        id: TEST_IDS.proveedor2,
        name: 'Distribuidora MediPharma EIRL',
        ruc: 'TEST20987654321',
        is_active: true,
      }
    ])
    .select();

  if (supplierError) {
    console.log(`  ❌ FAIL: ${supplierError.message}`);
    failCount++;
    testResults.push({ test: 2, name: 'Proveedores', result: 'FAIL', error: supplierError.message });
  } else {
    console.log(`  ✅ PASS (2 proveedores insertados)`);
    passCount++;
    testResults.push({ test: 2, name: 'Proveedores', result: 'PASS', count: suppliers.length });
  }

  // TEST 3: Insertar catálogo
  console.log('🧪 TEST 3: Inserción de Catálogo');
  const { data: catalog, error: catalogError } = await supabase
    .from('medication_catalog')
    .insert([
      {
        id: TEST_IDS.amoxicilina_cat,
        nombre_comercial: 'AMOXICILINA PRUEBA',
        nombre_generico: 'Amoxicilina',
        formula_activa: 'Amoxicilina Trihidratada',
        concentracion: '500mg',
        forma_farmaceutica: 'capsula',
        temperatura_almacenamiento: 'ambiente',
        is_active: true,
      },
      {
        id: TEST_IDS.paracetamol_cat,
        nombre_comercial: 'PARACETAMOL PRUEBA',
        nombre_generico: 'Paracetamol',
        formula_activa: 'Paracetamol',
        concentracion: '500mg',
        forma_farmaceutica: 'tableta',
        temperatura_almacenamiento: 'ambiente',
        is_active: true,
      },
      {
        id: TEST_IDS.ciprofloxacino_cat,
        nombre_comercial: 'CIPROFLOXACINO PRUEBA',
        nombre_generico: 'Ciprofloxacino',
        formula_activa: 'Ciprofloxacino Clorhidrato',
        concentracion: '500mg',
        forma_farmaceutica: 'tableta',
        temperatura_almacenamiento: 'ambiente',
        is_active: true,
      },
      {
        id: TEST_IDS.losartan_cat,
        nombre_comercial: 'LOSARTAN PRUEBA',
        nombre_generico: 'Losartán',
        formula_activa: 'Losartán Potásico',
        concentracion: '50mg',
        forma_farmaceutica: 'tableta',
        temperatura_almacenamiento: 'ambiente',
        is_active: true,
      },
      {
        id: TEST_IDS.insulina_cat,
        nombre_comercial: 'INSULINA PRUEBA',
        nombre_generico: 'Insulina NPH',
        formula_activa: 'Insulina Humana',
        concentracion: '100UI/ml',
        forma_farmaceutica: 'inyectable',
        temperatura_almacenamiento: 'refrigerado',
        is_active: true,
      }
    ])
    .select();

  if (catalogError) {
    console.log(`  ❌ FAIL: ${catalogError.message}`);
    failCount++;
    testResults.push({ test: 3, name: 'Catálogo', result: 'FAIL', error: catalogError.message });
  } else {
    console.log(`  ✅ PASS (5 medicamentos insertados)`);
    passCount++;
    testResults.push({ test: 3, name: 'Catálogo', result: 'PASS', count: catalog.length });
  }

  // TEST 4: Insertar inventario
  console.log('🧪 TEST 4: Inserción de Inventario');

  const currentDate = new Date();
  const futureDate12m = new Date(currentDate);
  futureDate12m.setMonth(futureDate12m.getMonth() + 12);
  const futureDate15d = new Date(currentDate);
  futureDate15d.setDate(futureDate15d.getDate() + 15);
  const futureDate45d = new Date(currentDate);
  futureDate45d.setDate(futureDate45d.getDate() + 45);
  const futureDate6m = new Date(currentDate);
  futureDate6m.setMonth(futureDate6m.getMonth() + 6);
  const futureDate18m = new Date(currentDate);
  futureDate18m.setMonth(futureDate18m.getMonth() + 18);

  const { data: inventory, error: inventoryError } = await supabase
    .from('medications')
    .insert([
      {
        id: TEST_IDS.paracetamol_hosp,
        center_id: TEST_IDS.hospital_central,
        catalog_id: TEST_IDS.paracetamol_cat,
        nombre: 'PARACETAMOL PRUEBA 500mg',
        formula_activa: 'Paracetamol',
        lote: 'TEST-PAR-2024-001',
        cantidad: 1500,
        fecha_caducidad: futureDate18m.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Estante B1',
      },
      {
        id: TEST_IDS.amoxicilina_hosp,
        center_id: TEST_IDS.hospital_central,
        catalog_id: TEST_IDS.amoxicilina_cat,
        nombre: 'AMOXICILINA PRUEBA 500mg',
        formula_activa: 'Amoxicilina Trihidratada',
        lote: 'TEST-AMX-2024-001',
        cantidad: 500,
        fecha_caducidad: futureDate12m.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Estante A1',
      },
      {
        id: 'dddd1112-dddd-1112-dddd-111111111112',
        center_id: TEST_IDS.hospital_central,
        catalog_id: TEST_IDS.amoxicilina_cat,
        nombre: 'AMOXICILINA PRUEBA 500mg',
        formula_activa: 'Amoxicilina Trihidratada',
        lote: 'TEST-AMX-2024-002',
        cantidad: 45,
        fecha_caducidad: futureDate45d.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Estante A1',
      },
      {
        id: 'dddd2222-dddd-2222-dddd-222222222222',
        center_id: TEST_IDS.hospital_central,
        catalog_id: TEST_IDS.ciprofloxacino_cat,
        nombre: 'CIPROFLOXACINO PRUEBA 500mg',
        formula_activa: 'Ciprofloxacino Clorhidrato',
        lote: 'TEST-CIP-2024-001',
        cantidad: 15,
        fecha_caducidad: futureDate6m.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Estante A2',
      },
      {
        id: 'dddd5555-dddd-5555-dddd-555555555555',
        center_id: TEST_IDS.hospital_central,
        catalog_id: TEST_IDS.losartan_cat,
        nombre: 'LOSARTAN PRUEBA 50mg',
        formula_activa: 'Losartán Potásico',
        lote: 'TEST-LOS-2023-005',
        cantidad: 80,
        fecha_caducidad: futureDate15d.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Estante C1',
      },
      {
        id: 'dddd8888-dddd-8888-dddd-888888888888',
        center_id: TEST_IDS.hospital_central,
        catalog_id: TEST_IDS.insulina_cat,
        nombre: 'INSULINA PRUEBA NPH',
        formula_activa: 'Insulina Humana',
        lote: 'TEST-INS-2024-001',
        cantidad: 25,
        fecha_caducidad: futureDate6m.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Refrigerador 1',
      },
      {
        id: 'eeee1111-eeee-1111-eeee-111111111111',
        center_id: TEST_IDS.centro_norte,
        catalog_id: TEST_IDS.paracetamol_cat,
        nombre: 'PARACETAMOL PRUEBA 500mg',
        formula_activa: 'Paracetamol',
        lote: 'TEST-PAR-2024-002',
        cantidad: 600,
        fecha_caducidad: futureDate12m.toISOString().split('T')[0],
        estado: 'Disponible',
        ubicacion_fisica: 'Anaquel 1A',
      }
    ])
    .select();

  if (inventoryError) {
    console.log(`  ❌ FAIL: ${inventoryError.message}`);
    failCount++;
    testResults.push({ test: 4, name: 'Inventario', result: 'FAIL', error: inventoryError.message });
  } else {
    console.log(`  ✅ PASS (7 lotes insertados)`);
    passCount++;
    testResults.push({ test: 4, name: 'Inventario', result: 'PASS', count: inventory.length });
  }

  console.log('\n⚙️ PASO 3: Probando funciones de base de datos...\n');

  // Obtener usuario
  const { data: users } = await supabase.from('users_profiles').select('id').limit(1);
  const userId = users && users.length > 0 ? users[0].id : null;

  if (userId) {
    console.log(`✓ Usuario encontrado: ${userId}\n`);

    // TEST 5: Registrar movimiento ENTRADA
    console.log('🧪 TEST 5: registrar_movimiento_lote (ENTRADA)');
    const { data: beforeEntry } = await supabase
      .from('medications')
      .select('cantidad')
      .eq('id', TEST_IDS.paracetamol_hosp)
      .single();

    const stockBefore = beforeEntry?.cantidad || 0;

    const { data: entryResult, error: entryError } = await supabase.rpc('registrar_movimiento_lote', {
      p_medication_id: TEST_IDS.paracetamol_hosp,
      p_tipo_movimiento: 'entrada',
      p_cantidad: 500,
      p_motivo: 'Prueba automática - Compra',
      p_usuario_responsable: userId,
      p_centro_destino_id: TEST_IDS.hospital_central,
      p_numero_documento: 'TEST-ENTRADA-001',
    });

    if (entryError) {
      console.log(`  ❌ FAIL: ${entryError.message}`);
      failCount++;
      testResults.push({ test: 5, name: 'registrar_movimiento_lote ENTRADA', result: 'FAIL', error: entryError.message });
    } else {
      const expectedStock = stockBefore + 500;
      const actualStock = entryResult?.cantidad_final || 0;
      if (actualStock === expectedStock) {
        console.log(`  ✅ PASS (Stock: ${stockBefore} → ${actualStock})`);
        passCount++;
        testResults.push({ test: 5, name: 'registrar_movimiento_lote ENTRADA', result: 'PASS', stockBefore, stockAfter: actualStock });
      } else {
        console.log(`  ❌ FAIL (Esperado: ${expectedStock}, Obtenido: ${actualStock})`);
        failCount++;
        testResults.push({ test: 5, name: 'registrar_movimiento_lote ENTRADA', result: 'FAIL', expected: expectedStock, actual: actualStock });
      }
    }

    // TEST 6: Registrar movimiento SALIDA
    console.log('🧪 TEST 6: registrar_movimiento_lote (SALIDA)');
    const { data: beforeExit } = await supabase
      .from('medications')
      .select('cantidad')
      .eq('id', TEST_IDS.paracetamol_hosp)
      .single();

    const stockBeforeExit = beforeExit?.cantidad || 0;

    const { data: exitResult, error: exitError } = await supabase.rpc('registrar_movimiento_lote', {
      p_medication_id: TEST_IDS.paracetamol_hosp,
      p_tipo_movimiento: 'salida',
      p_cantidad: 300,
      p_motivo: 'Prueba automática - Dispensación',
      p_usuario_responsable: userId,
      p_centro_origen_id: TEST_IDS.hospital_central,
      p_numero_documento: 'TEST-SALIDA-001',
    });

    if (exitError) {
      console.log(`  ❌ FAIL: ${exitError.message}`);
      failCount++;
      testResults.push({ test: 6, name: 'registrar_movimiento_lote SALIDA', result: 'FAIL', error: exitError.message });
    } else {
      const expectedStock = stockBeforeExit - 300;
      const actualStock = exitResult?.cantidad_final || 0;
      if (actualStock === expectedStock) {
        console.log(`  ✅ PASS (Stock: ${stockBeforeExit} → ${actualStock})`);
        passCount++;
        testResults.push({ test: 6, name: 'registrar_movimiento_lote SALIDA', result: 'PASS', stockBefore: stockBeforeExit, stockAfter: actualStock });
      } else {
        console.log(`  ❌ FAIL (Esperado: ${expectedStock}, Obtenido: ${actualStock})`);
        failCount++;
        testResults.push({ test: 6, name: 'registrar_movimiento_lote SALIDA', result: 'FAIL', expected: expectedStock, actual: actualStock });
      }
    }

  } else {
    console.log('⚠️  No hay usuarios disponibles. Tests 5-6 omitidos.\n');
  }

  // TEST 7: search_inventory_with_batches
  console.log('🧪 TEST 7: search_inventory_with_batches (búsqueda)');
  const { data: searchResults, error: searchError } = await supabase.rpc('search_inventory_with_batches', {
    p_search_term: 'PARACETAMOL',
    p_center_id: TEST_IDS.hospital_central,
    p_stock_bajo: false,
    p_proximos_vencer_dias: null,
    p_estado: null,
  });

  if (searchError) {
    console.log(`  ❌ FAIL: ${searchError.message}`);
    failCount++;
    testResults.push({ test: 7, name: 'search_inventory_with_batches', result: 'FAIL', error: searchError.message });
  } else {
    const count = searchResults?.length || 0;
    if (count >= 1) {
      console.log(`  ✅ PASS (${count} resultados)`);
      passCount++;
      testResults.push({ test: 7, name: 'search_inventory_with_batches', result: 'PASS', count });
    } else {
      console.log(`  ❌ FAIL (0 resultados)`);
      failCount++;
      testResults.push({ test: 7, name: 'search_inventory_with_batches', result: 'FAIL', count });
    }
  }

  // TEST 8: Stock bajo
  console.log('🧪 TEST 8: search_inventory_with_batches (stock bajo)');
  const { data: lowStockResults, error: lowStockError } = await supabase.rpc('search_inventory_with_batches', {
    p_search_term: null,
    p_center_id: TEST_IDS.hospital_central,
    p_stock_bajo: true,
    p_proximos_vencer_dias: null,
    p_estado: 'Disponible',
  });

  if (lowStockError) {
    console.log(`  ❌ FAIL: ${lowStockError.message}`);
    failCount++;
    testResults.push({ test: 8, name: 'search_inventory_with_batches Stock Bajo', result: 'FAIL', error: lowStockError.message });
  } else {
    const count = lowStockResults?.length || 0;
    if (count >= 2) {
      console.log(`  ✅ PASS (${count} medicamentos con stock bajo)`);
      passCount++;
      testResults.push({ test: 8, name: 'search_inventory_with_batches Stock Bajo', result: 'PASS', count });
    } else {
      console.log(`  ❌ FAIL (${count} medicamentos - esperado al menos 2)`);
      failCount++;
      testResults.push({ test: 8, name: 'search_inventory_with_batches Stock Bajo', result: 'FAIL', count });
    }
  }

  // TEST 9: Próximos a vencer
  console.log('🧪 TEST 9: search_inventory_with_batches (próximos a vencer)');
  const { data: expiringResults, error: expiringError } = await supabase.rpc('search_inventory_with_batches', {
    p_search_term: null,
    p_center_id: TEST_IDS.hospital_central,
    p_stock_bajo: false,
    p_proximos_vencer_dias: 30,
    p_estado: 'Disponible',
  });

  if (expiringError) {
    console.log(`  ❌ FAIL: ${expiringError.message}`);
    failCount++;
    testResults.push({ test: 9, name: 'search_inventory_with_batches Vencimiento', result: 'FAIL', error: expiringError.message });
  } else {
    const count = expiringResults?.length || 0;
    if (count >= 1) {
      console.log(`  ✅ PASS (${count} medicamentos próximos a vencer)`);
      passCount++;
      testResults.push({ test: 9, name: 'search_inventory_with_batches Vencimiento', result: 'PASS', count });
    } else {
      console.log(`  ❌ FAIL (${count} medicamentos - esperado al menos 1)`);
      failCount++;
      testResults.push({ test: 9, name: 'search_inventory_with_batches Vencimiento', result: 'FAIL', count });
    }
  }

  // TEST 10: generate_traceability_report
  if (userId) {
    console.log('🧪 TEST 10: generate_traceability_report');
    const { data: traceResults, error: traceError } = await supabase.rpc('generate_traceability_report', {
      p_medication_id: TEST_IDS.paracetamol_hosp,
      p_lote: 'TEST-PAR-2024-001',
      p_fecha_inicio: null,
      p_fecha_fin: null,
    });

    if (traceError) {
      console.log(`  ❌ FAIL: ${traceError.message}`);
      failCount++;
      testResults.push({ test: 10, name: 'generate_traceability_report', result: 'FAIL', error: traceError.message });
    } else {
      const count = traceResults?.length || 0;
      if (count >= 2) {
        console.log(`  ✅ PASS (${count} movimientos)`);
        passCount++;
        testResults.push({ test: 10, name: 'generate_traceability_report', result: 'PASS', count });
      } else {
        console.log(`  ❌ FAIL (${count} movimientos - esperado al menos 2)`);
        failCount++;
        testResults.push({ test: 10, name: 'generate_traceability_report', result: 'FAIL', count });
      }
    }
  }

  console.log('\n📊 PASO 4: Probando consultas de inventario...\n');

  // TEST 11: Inventario completo
  console.log('🧪 TEST 11: Inventario completo');
  const { data: allMeds, error: allError } = await supabase
    .from('medications')
    .select('*')
    .eq('center_id', TEST_IDS.hospital_central)
    .like('lote', 'TEST-%');

  if (allError) {
    console.log(`  ❌ FAIL: ${allError.message}`);
    failCount++;
  } else {
    const count = allMeds?.length || 0;
    if (count === 6) {
      console.log(`  ✅ PASS (6 medicamentos)`);
      passCount++;
    } else {
      console.log(`  ❌ FAIL (${count} medicamentos - esperado 6)`);
      failCount++;
    }
  }

  // TEST 12: Búsqueda por nombre
  console.log('🧪 TEST 12: Búsqueda por nombre');
  const { data: searchByName } = await supabase
    .from('medications')
    .select('*')
    .eq('center_id', TEST_IDS.hospital_central)
    .ilike('nombre', '%AMOXICILINA%')
    .like('lote', 'TEST-%');

  const count12 = searchByName?.length || 0;
  if (count12 === 2) {
    console.log(`  ✅ PASS (2 resultados)`);
    passCount++;
  } else {
    console.log(`  ❌ FAIL (${count12} resultados - esperado 2)`);
    failCount++;
  }

  // TEST 13: Stock bajo
  console.log('🧪 TEST 13: Stock bajo (<50)');
  const { data: lowStock } = await supabase
    .from('medications')
    .select('*')
    .eq('center_id', TEST_IDS.hospital_central)
    .lt('cantidad', 50)
    .like('lote', 'TEST-%');

  const count13 = lowStock?.length || 0;
  if (count13 >= 2) {
    console.log(`  ✅ PASS (${count13} medicamentos)`);
    passCount++;
  } else {
    console.log(`  ❌ FAIL (${count13} medicamentos - esperado al menos 2)`);
    failCount++;
  }

  // TEST 14: Por estado
  console.log('🧪 TEST 14: Filtro por estado');
  const { data: available } = await supabase
    .from('medications')
    .select('*')
    .eq('center_id', TEST_IDS.hospital_central)
    .eq('estado', 'Disponible')
    .like('lote', 'TEST-%');

  const count14 = available?.length || 0;
  if (count14 === 6) {
    console.log(`  ✅ PASS (6 medicamentos disponibles)`);
    passCount++;
  } else {
    console.log(`  ❌ FAIL (${count14} medicamentos - esperado 6)`);
    failCount++;
  }

  console.log('\n🚨 PASO 5: Probando sistema de alertas...\n');

  // TEST 15: Vencimientos
  console.log('🧪 TEST 15: Detección de vencimientos');
  const futureDate30 = new Date();
  futureDate30.setDate(futureDate30.getDate() + 30);

  const { data: expiring } = await supabase
    .from('medications')
    .select('*')
    .eq('center_id', TEST_IDS.hospital_central)
    .lte('fecha_caducidad', futureDate30.toISOString().split('T')[0])
    .like('lote', 'TEST-%');

  const count15 = expiring?.length || 0;
  if (count15 >= 1) {
    console.log(`  ✅ PASS (${count15} medicamentos próximos a vencer)`);
    passCount++;
  } else {
    console.log(`  ❌ FAIL (${count15} medicamentos - esperado al menos 1)`);
    failCount++;
  }

  // TEST 16: batch_movements
  if (userId) {
    console.log('🧪 TEST 16: Registro en batch_movements');
    const { data: movements } = await supabase
      .from('batch_movements')
      .select('*')
      .eq('medication_id', TEST_IDS.paracetamol_hosp)
      .like('numero_documento', 'TEST-%');

    const count16 = movements?.length || 0;
    if (count16 >= 2) {
      console.log(`  ✅ PASS (${count16} movimientos registrados)`);
      passCount++;
    } else {
      console.log(`  ❌ FAIL (${count16} movimientos - esperado al menos 2)`);
      failCount++;
    }
  }

  // REPORTE FINAL
  const totalTests = passCount + failCount;
  const successRate = totalTests > 0 ? ((passCount / totalTests) * 100).toFixed(2) : 0;

  console.log('\n' + '='.repeat(60));
  console.log('  REPORTE FINAL DE PRUEBAS');
  console.log('='.repeat(60) + '\n');

  console.log('┌─────────────────────────────────────────────────────────┐');
  console.log('│                  RESUMEN DE PRUEBAS                     │');
  console.log('├─────────────────────────────────────────────────────────┤');
  console.log(`│  Total de Pruebas:        ${totalTests.toString().padStart(3)}                         │`);
  console.log(`│  Pruebas Exitosas:        ${passCount.toString().padStart(3)} ✅                       │`);
  console.log(`│  Pruebas Fallidas:        ${failCount.toString().padStart(3)} ❌                       │`);
  console.log(`│  Tasa de Éxito:           ${successRate.toString().padStart(6)}%                      │`);
  console.log('└─────────────────────────────────────────────────────────┘\n');

  if (failCount > 0) {
    console.log('❌ PRUEBAS FALLIDAS:\n');
    testResults
      .filter(t => t.result === 'FAIL')
      .forEach((test, index) => {
        console.log(`${index + 1}. TEST ${test.test}: ${test.name}`);
        if (test.error) console.log(`   Error: ${test.error}`);
        console.log('');
      });
  }

  console.log('✅ FUNCIONALIDADES VERIFICADAS:');
  console.log('  • Inserción de datos de prueba');
  console.log('  • Función registrar_movimiento_lote()');
  console.log('  • Función search_inventory_with_batches()');
  console.log('  • Función generate_traceability_report()');
  console.log('  • Consultas de inventario');
  console.log('  • Sistema de alertas');
  console.log('  • Registro de movimientos');
  console.log('');

  if (failCount === 0) {
    console.log('🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE\n');
  } else {
    console.log('⚠️  ALGUNAS PRUEBAS FALLARON - Revisar detalles arriba\n');
  }

  // Verificación adicional
  console.log('📊 VERIFICACIÓN DE DATOS INSERTADOS:\n');

  const { count: centerCount } = await supabase
    .from('health_centers')
    .select('*', { count: 'exact', head: true })
    .like('code', 'TEST-%');

  const { count: supplierCount } = await supabase
    .from('suppliers')
    .select('*', { count: 'exact', head: true })
    .like('ruc', 'TEST%');

  const { count: catalogCount } = await supabase
    .from('medication_catalog')
    .select('*', { count: 'exact', head: true })
    .like('nombre_comercial', '%PRUEBA%');

  const { count: medCount } = await supabase
    .from('medications')
    .select('*', { count: 'exact', head: true })
    .like('lote', 'TEST-%');

  console.log(`  Centros de Salud:       ${centerCount || 0}/3`);
  console.log(`  Proveedores:            ${supplierCount || 0}/2`);
  console.log(`  Catálogo:               ${catalogCount || 0}/5`);
  console.log(`  Inventario:             ${medCount || 0}/7`);
  console.log('');

  process.exit(failCount === 0 ? 0 : 1);
}
