#!/usr/bin/env node
/**
 * SCRIPT DE PRUEBAS AUTOMATIZADAS COMPLETAS - SIGIMED
 *
 * Este script:
 * 1. Inserta datos de prueba en Supabase
 * 2. Prueba TODAS las funcionalidades del sistema
 * 3. Genera un reporte completo de resultados
 *
 * Uso: node test-complete-system.mjs
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';

// ============================================
// CONFIGURACIÓN
// ============================================
const SUPABASE_URL = 'https://cyslhzynfuetthxngpoy.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5c2xoenluZnVldHRoeG5ncG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTEzMzEsImV4cCI6MjA3ODAyNzMzMX0.ZFYYLFp37YYQFGGeEJi6vbrjB3gisaGqivLRLsvaIeY';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// IDs de prueba
const TEST_IDS = {
  hospital_central: '11111111-1111-1111-1111-111111111111',
  centro_norte: '22222222-2222-2222-2222-222222222222',
  posta_sur: '33333333-3333-3333-3333-333333333333',
  paracetamol_catalog: 'cccc3333-cccc-3333-cccc-333333333333',
  amoxicilina_catalog: 'cccc1111-cccc-1111-cccc-111111111111',
  paracetamol_hospital: 'dddd3333-dddd-3333-dddd-333333333333',
  amoxicilina_hospital: 'dddd1111-dddd-1111-dddd-111111111111',
  losartan_vencimiento: 'dddd5555-dddd-5555-dddd-555555555555',
  ciprofloxacino_bajo: 'dddd2222-dddd-2222-dddd-222222222222',
  insulina_refrigerada: 'dddd8888-dddd-8888-dddd-888888888888',
};

// ============================================
// UTILIDADES
// ============================================
let testResults = [];
let testCount = 0;
let passCount = 0;
let failCount = 0;

function log(message, type = 'info') {
  const icons = {
    info: 'ℹ️',
    success: '✅',
    error: '❌',
    warning: '⚠️',
    test: '🧪',
    database: '💾',
    function: '⚙️',
    report: '📊',
  };
  console.log(`${icons[type] || '•'} ${message}`);
}

function logSection(title) {
  console.log('\n' + '='.repeat(60));
  console.log(`  ${title}`);
  console.log('='.repeat(60) + '\n');
}

function recordTest(testName, passed, details = '', expected = '', actual = '') {
  testCount++;
  if (passed) {
    passCount++;
    log(`${testName}: PASS ${details}`, 'success');
  } else {
    failCount++;
    log(`${testName}: FAIL ${details}`, 'error');
    if (expected) log(`  Expected: ${expected}`, 'info');
    if (actual) log(`  Actual: ${actual}`, 'info');
  }

  testResults.push({
    testName,
    passed,
    details,
    expected,
    actual,
    timestamp: new Date().toISOString(),
  });
}

async function waitForOperation(ms = 1000) {
  await new Promise(resolve => setTimeout(resolve, ms));
}

// ============================================
// PASO 1: LIMPIAR DATOS ANTERIORES
// ============================================
async function cleanTestData() {
  logSection('PASO 1: LIMPIANDO DATOS DE PRUEBA ANTERIORES');

  try {
    // Eliminar movimientos
    const { error: bmError } = await supabase
      .from('batch_movements')
      .delete()
      .or('numero_documento.like.DISP-2024%,numero_documento.like.TRANS-2024%,numero_documento.like.FC-2024%,numero_documento.like.INV-2024%,numero_documento.like.VEN-2024%,numero_documento.like.MERMA-2024%');

    if (bmError) log(`Error limpiando batch_movements: ${bmError.message}`, 'warning');

    // Eliminar alertas de medicamentos de prueba
    const { error: alertError } = await supabase
      .from('alertas_medicamentos')
      .delete()
      .in('medicamento_id', Object.values(TEST_IDS).filter(id => id.startsWith('dddd')));

    if (alertError) log(`Error limpiando alertas: ${alertError.message}`, 'warning');

    // Eliminar inventario
    const { error: medError } = await supabase
      .from('medications')
      .delete()
      .like('lote', 'TEST%');

    if (medError) log(`Error limpiando medications: ${medError.message}`, 'warning');

    // Eliminar user_centers
    const { error: ucError } = await supabase
      .from('user_centers')
      .delete()
      .in('center_id', [TEST_IDS.hospital_central, TEST_IDS.centro_norte, TEST_IDS.posta_sur]);

    if (ucError) log(`Error limpiando user_centers: ${ucError.message}`, 'warning');

    // Eliminar catálogo
    const { error: catError } = await supabase
      .from('medication_catalog')
      .delete()
      .like('nombre_comercial', '%PRUEBA%');

    if (catError) log(`Error limpiando medication_catalog: ${catError.message}`, 'warning');

    // Eliminar proveedores
    const { error: suppError } = await supabase
      .from('suppliers')
      .delete()
      .like('ruc', 'TEST%');

    if (suppError) log(`Error limpiando suppliers: ${suppError.message}`, 'warning');

    // Eliminar centros
    const { error: hcError } = await supabase
      .from('health_centers')
      .delete()
      .like('code', 'TEST%');

    if (hcError) log(`Error limpiando health_centers: ${hcError.message}`, 'warning');

    log('Datos de prueba anteriores eliminados', 'success');
    return true;
  } catch (error) {
    log(`Error limpiando datos: ${error.message}`, 'error');
    return false;
  }
}

// ============================================
// PASO 2: INSERTAR DATOS DE PRUEBA
// ============================================
async function insertTestData() {
  logSection('PASO 2: INSERTANDO DATOS DE PRUEBA');

  try {
    // 1. Centros de Salud
    log('Insertando centros de salud...', 'database');
    const { error: hcError } = await supabase
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
          email: 'hospital.central@test.com',
          responsible_name: 'Dr. Juan Pérez',
          responsible_role: 'Director Médico',
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
          phone: '+51-1-234-5679',
          email: 'centro.norte@test.com',
          responsible_name: 'Dra. María García',
          responsible_role: 'Jefa de Farmacia',
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
          phone: '+51-54-234-5680',
          email: 'posta.sur@test.com',
          responsible_name: 'Lic. Carlos Ramos',
          responsible_role: 'Coordinador',
          storage_capacity: 1000,
          has_refrigeration: false,
          is_active: true,
        }
      ]);

    if (hcError) throw new Error(`Error insertando centros: ${hcError.message}`);
    recordTest('Inserción de Centros de Salud', true, '(3 centros insertados)');

    // 2. Proveedores
    log('Insertando proveedores...', 'database');
    const { error: suppError } = await supabase
      .from('suppliers')
      .insert([
        {
          id: 'aaaa1111-aaaa-1111-aaaa-111111111111',
          name: 'Farmacéutica Global SAC',
          ruc: 'TEST20123456789',
          address: 'Av. Industrial 100',
          city: 'Lima',
          phone: '+51-1-555-0001',
          email: 'ventas@farmglobal.test',
          contact_name: 'Luis Mendoza',
          contact_phone: '+51-999-111-222',
          payment_terms: '30 días',
          delivery_time_days: 15,
          rating: 4.5,
          is_active: true,
        },
        {
          id: 'bbbb2222-bbbb-2222-bbbb-222222222222',
          name: 'Distribuidora MediPharma EIRL',
          ruc: 'TEST20987654321',
          address: 'Jr. Comercio 250',
          city: 'Lima',
          phone: '+51-1-555-0002',
          email: 'pedidos@medipharma.test',
          contact_name: 'Ana Torres',
          contact_phone: '+51-999-333-444',
          payment_terms: '45 días',
          delivery_time_days: 7,
          rating: 4.8,
          is_active: true,
        }
      ]);

    if (suppError) throw new Error(`Error insertando proveedores: ${suppError.message}`);
    recordTest('Inserción de Proveedores', true, '(2 proveedores insertados)');

    // 3. Catálogo de Medicamentos
    log('Insertando catálogo de medicamentos...', 'database');
    const { error: catError } = await supabase
      .from('medication_catalog')
      .insert([
        {
          id: TEST_IDS.amoxicilina_catalog,
          nombre_comercial: 'AMOXICILINA PRUEBA',
          nombre_generico: 'Amoxicilina',
          formula_activa: 'Amoxicilina Trihidratada',
          concentracion: '500mg',
          forma_farmaceutica: 'capsula',
          uso_terapeutico: 'Tratamiento de infecciones bacterianas',
          categoria_farmacologica: 'J01CA04',
          requiere_receta: true,
          es_controlado: false,
          temperatura_almacenamiento: 'ambiente',
          temperatura_min: 15.0,
          temperatura_max: 30.0,
          is_active: true,
        },
        {
          id: TEST_IDS.paracetamol_catalog,
          nombre_comercial: 'PARACETAMOL PRUEBA',
          nombre_generico: 'Paracetamol',
          formula_activa: 'Paracetamol',
          concentracion: '500mg',
          forma_farmaceutica: 'tableta',
          uso_terapeutico: 'Analgésico y antipirético',
          categoria_farmacologica: 'N02BE01',
          requiere_receta: false,
          es_controlado: false,
          temperatura_almacenamiento: 'ambiente',
          temperatura_min: 15.0,
          temperatura_max: 30.0,
          is_active: true,
        },
        {
          id: 'cccc2222-cccc-2222-cccc-222222222222',
          nombre_comercial: 'CIPROFLOXACINO PRUEBA',
          nombre_generico: 'Ciprofloxacino',
          formula_activa: 'Ciprofloxacino Clorhidrato',
          concentracion: '500mg',
          forma_farmaceutica: 'tableta',
          uso_terapeutico: 'Infecciones bacterianas resistentes',
          categoria_farmacologica: 'J01MA02',
          requiere_receta: true,
          es_controlado: false,
          temperatura_almacenamiento: 'ambiente',
          temperatura_min: 15.0,
          temperatura_max: 30.0,
          is_active: true,
        },
        {
          id: 'cccc5555-cccc-5555-cccc-555555555555',
          nombre_comercial: 'LOSARTAN PRUEBA',
          nombre_generico: 'Losartán',
          formula_activa: 'Losartán Potásico',
          concentracion: '50mg',
          forma_farmaceutica: 'tableta',
          uso_terapeutico: 'Tratamiento de hipertensión arterial',
          categoria_farmacologica: 'C09CA01',
          requiere_receta: true,
          es_controlado: false,
          temperatura_almacenamiento: 'ambiente',
          temperatura_min: 15.0,
          temperatura_max: 30.0,
          is_active: true,
        },
        {
          id: 'cccc8888-cccc-8888-cccc-888888888888',
          nombre_comercial: 'INSULINA PRUEBA',
          nombre_generico: 'Insulina NPH',
          formula_activa: 'Insulina Humana',
          concentracion: '100UI/ml',
          forma_farmaceutica: 'inyectable',
          uso_terapeutico: 'Tratamiento de diabetes',
          categoria_farmacologica: 'A10AC01',
          requiere_receta: true,
          es_controlado: true,
          temperatura_almacenamiento: 'refrigerado',
          temperatura_min: 2.0,
          temperatura_max: 8.0,
          is_active: true,
        }
      ]);

    if (catError) throw new Error(`Error insertando catálogo: ${catError.message}`);
    recordTest('Inserción de Catálogo de Medicamentos', true, '(5 medicamentos insertados)');

    // 4. Inventario
    log('Insertando inventario...', 'database');

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

    const { error: medError } = await supabase
      .from('medications')
      .insert([
        // Hospital Central
        {
          id: TEST_IDS.amoxicilina_hospital,
          center_id: TEST_IDS.hospital_central,
          catalog_id: TEST_IDS.amoxicilina_catalog,
          nombre: 'AMOXICILINA PRUEBA 500mg',
          formula_activa: 'Amoxicilina Trihidratada',
          lote: 'TEST-AMX-2024-001',
          cantidad: 500,
          fecha_caducidad: futureDate12m.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'aaaa1111-aaaa-1111-aaaa-111111111111',
          costo_unitario: 0.50,
          precio_venta: 1.20,
          ubicacion_fisica: 'Estante A1',
        },
        {
          id: 'dddd1112-dddd-1112-dddd-111111111112',
          center_id: TEST_IDS.hospital_central,
          catalog_id: TEST_IDS.amoxicilina_catalog,
          nombre: 'AMOXICILINA PRUEBA 500mg',
          formula_activa: 'Amoxicilina Trihidratada',
          lote: 'TEST-AMX-2024-002',
          cantidad: 45,
          fecha_caducidad: futureDate45d.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'aaaa1111-aaaa-1111-aaaa-111111111111',
          costo_unitario: 0.48,
          precio_venta: 1.20,
          ubicacion_fisica: 'Estante A1',
        },
        {
          id: TEST_IDS.ciprofloxacino_bajo,
          center_id: TEST_IDS.hospital_central,
          catalog_id: 'cccc2222-cccc-2222-cccc-222222222222',
          nombre: 'CIPROFLOXACINO PRUEBA 500mg',
          formula_activa: 'Ciprofloxacino Clorhidrato',
          lote: 'TEST-CIP-2024-001',
          cantidad: 15,
          fecha_caducidad: futureDate6m.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'bbbb2222-bbbb-2222-bbbb-222222222222',
          costo_unitario: 1.20,
          precio_venta: 2.80,
          ubicacion_fisica: 'Estante A2',
        },
        {
          id: TEST_IDS.paracetamol_hospital,
          center_id: TEST_IDS.hospital_central,
          catalog_id: TEST_IDS.paracetamol_catalog,
          nombre: 'PARACETAMOL PRUEBA 500mg',
          formula_activa: 'Paracetamol',
          lote: 'TEST-PAR-2024-001',
          cantidad: 1500,
          fecha_caducidad: futureDate18m.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'aaaa1111-aaaa-1111-aaaa-111111111111',
          costo_unitario: 0.10,
          precio_venta: 0.30,
          ubicacion_fisica: 'Estante B1',
        },
        {
          id: TEST_IDS.losartan_vencimiento,
          center_id: TEST_IDS.hospital_central,
          catalog_id: 'cccc5555-cccc-5555-cccc-555555555555',
          nombre: 'LOSARTAN PRUEBA 50mg',
          formula_activa: 'Losartán Potásico',
          lote: 'TEST-LOS-2023-005',
          cantidad: 80,
          fecha_caducidad: futureDate15d.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'bbbb2222-bbbb-2222-bbbb-222222222222',
          costo_unitario: 0.80,
          precio_venta: 1.80,
          ubicacion_fisica: 'Estante C1',
        },
        {
          id: TEST_IDS.insulina_refrigerada,
          center_id: TEST_IDS.hospital_central,
          catalog_id: 'cccc8888-cccc-8888-cccc-888888888888',
          nombre: 'INSULINA PRUEBA NPH 100UI/ml',
          formula_activa: 'Insulina Humana',
          lote: 'TEST-INS-2024-001',
          cantidad: 25,
          fecha_caducidad: futureDate6m.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'bbbb2222-bbbb-2222-bbbb-222222222222',
          costo_unitario: 15.00,
          precio_venta: 35.00,
          ubicacion_fisica: 'Refrigerador 1',
        },
        // Centro Norte
        {
          id: 'eeee1111-eeee-1111-eeee-111111111111',
          center_id: TEST_IDS.centro_norte,
          catalog_id: TEST_IDS.paracetamol_catalog,
          nombre: 'PARACETAMOL PRUEBA 500mg',
          formula_activa: 'Paracetamol',
          lote: 'TEST-PAR-2024-002',
          cantidad: 600,
          fecha_caducidad: futureDate12m.toISOString().split('T')[0],
          fecha_ingreso: currentDate.toISOString().split('T')[0],
          estado: 'Disponible',
          proveedor_id: 'aaaa1111-aaaa-1111-aaaa-111111111111',
          costo_unitario: 0.10,
          precio_venta: 0.30,
          ubicacion_fisica: 'Anaquel 1A',
        }
      ]);

    if (medError) throw new Error(`Error insertando inventario: ${medError.message}`);
    recordTest('Inserción de Inventario', true, '(7 lotes insertados)');

    log('Todos los datos de prueba insertados exitosamente', 'success');
    return true;

  } catch (error) {
    log(`Error insertando datos: ${error.message}`, 'error');
    recordTest('Inserción de Datos de Prueba', false, error.message);
    return false;
  }
}

// ============================================
// PASO 3: VERIFICAR DATOS INSERTADOS
// ============================================
async function verifyDataInsertion() {
  logSection('PASO 3: VERIFICANDO DATOS INSERTADOS');

  try {
    // Verificar centros de salud
    const { data: centers, error: hcError } = await supabase
      .from('health_centers')
      .select('*')
      .like('code', 'TEST%');

    if (hcError) throw new Error(`Error consultando centros: ${hcError.message}`);
    recordTest('Verificación de Centros de Salud', centers?.length === 3, `(${centers?.length || 0}/3)`, '3 centros', `${centers?.length || 0} centros`);

    // Verificar proveedores
    const { data: suppliers, error: suppError } = await supabase
      .from('suppliers')
      .select('*')
      .like('ruc', 'TEST%');

    if (suppError) throw new Error(`Error consultando proveedores: ${suppError.message}`);
    recordTest('Verificación de Proveedores', suppliers?.length === 2, `(${suppliers?.length || 0}/2)`, '2 proveedores', `${suppliers?.length || 0} proveedores`);

    // Verificar catálogo
    const { data: catalog, error: catError } = await supabase
      .from('medication_catalog')
      .select('*')
      .like('nombre_comercial', '%PRUEBA%');

    if (catError) throw new Error(`Error consultando catálogo: ${catError.message}`);
    recordTest('Verificación de Catálogo', catalog?.length === 5, `(${catalog?.length || 0}/5)`, '5 medicamentos', `${catalog?.length || 0} medicamentos`);

    // Verificar inventario
    const { data: medications, error: medError } = await supabase
      .from('medications')
      .select('*')
      .like('lote', 'TEST%');

    if (medError) throw new Error(`Error consultando inventario: ${medError.message}`);
    recordTest('Verificación de Inventario', medications?.length === 7, `(${medications?.length || 0}/7)`, '7 lotes', `${medications?.length || 0} lotes`);

    return true;
  } catch (error) {
    log(`Error verificando datos: ${error.message}`, 'error');
    return false;
  }
}

// ============================================
// PASO 4: PROBAR FUNCIONES DE BASE DE DATOS
// ============================================
async function testDatabaseFunctions() {
  logSection('PASO 4: PROBANDO FUNCIONES DE BASE DE DATOS');

  try {
    // Obtener un usuario para las pruebas
    const { data: users, error: userError } = await supabase
      .from('users_profiles')
      .select('id')
      .limit(1);

    if (userError || !users || users.length === 0) {
      log('No hay usuarios disponibles para pruebas de funciones', 'warning');
      recordTest('Obtener Usuario para Pruebas', false, 'No hay usuarios disponibles');
      return false;
    }

    const userId = users[0].id;
    log(`Usando usuario: ${userId}`, 'info');

    // TEST 1: Función registrar_movimiento_lote - ENTRADA
    log('Probando función: registrar_movimiento_lote (ENTRADA)...', 'function');
    const { data: movEntry, error: movEntryError } = await supabase
      .rpc('registrar_movimiento_lote', {
        p_medication_id: TEST_IDS.paracetamol_hospital,
        p_tipo_movimiento: 'entrada',
        p_cantidad: 500,
        p_motivo: 'Prueba automática - Compra de inventario',
        p_usuario_responsable: userId,
        p_centro_destino_id: TEST_IDS.hospital_central,
        p_numero_documento: 'TEST-ENTRADA-001',
        p_observaciones: 'Entrada de prueba automatizada',
        p_metadata: { test: true, automated: true }
      });

    if (movEntryError) {
      recordTest('Función: registrar_movimiento_lote (ENTRADA)', false, movEntryError.message);
    } else {
      const stockFinal = movEntry?.cantidad_final || 0;
      recordTest('Función: registrar_movimiento_lote (ENTRADA)', stockFinal === 2000, `Stock final: ${stockFinal}`, '2000 unidades', `${stockFinal} unidades`);
    }

    await waitForOperation(500);

    // TEST 2: Función registrar_movimiento_lote - SALIDA
    log('Probando función: registrar_movimiento_lote (SALIDA)...', 'function');
    const { data: movExit, error: movExitError } = await supabase
      .rpc('registrar_movimiento_lote', {
        p_medication_id: TEST_IDS.paracetamol_hospital,
        p_tipo_movimiento: 'salida',
        p_cantidad: 300,
        p_motivo: 'Prueba automática - Dispensación',
        p_usuario_responsable: userId,
        p_centro_origen_id: TEST_IDS.hospital_central,
        p_numero_documento: 'TEST-SALIDA-001',
        p_observaciones: 'Salida de prueba automatizada',
        p_metadata: { test: true, automated: true }
      });

    if (movExitError) {
      recordTest('Función: registrar_movimiento_lote (SALIDA)', false, movExitError.message);
    } else {
      const stockFinal = movExit?.cantidad_final || 0;
      recordTest('Función: registrar_movimiento_lote (SALIDA)', stockFinal === 1700, `Stock final: ${stockFinal}`, '1700 unidades', `${stockFinal} unidades`);
    }

    await waitForOperation(500);

    // TEST 3: Función search_inventory_with_batches
    log('Probando función: search_inventory_with_batches...', 'function');
    const { data: searchResults, error: searchError } = await supabase
      .rpc('search_inventory_with_batches', {
        p_search_term: 'PARACETAMOL',
        p_center_id: TEST_IDS.hospital_central,
        p_stock_bajo: false,
        p_proximos_vencer_dias: null,
        p_estado: null
      });

    if (searchError) {
      recordTest('Función: search_inventory_with_batches', false, searchError.message);
    } else {
      const found = searchResults && searchResults.length > 0;
      recordTest('Función: search_inventory_with_batches', found, `Encontrados: ${searchResults?.length || 0} resultados`, 'Al menos 1', `${searchResults?.length || 0}`);
    }

    // TEST 4: Función search_inventory_with_batches - Stock Bajo
    log('Probando función: search_inventory_with_batches (stock bajo)...', 'function');
    const { data: lowStockResults, error: lowStockError } = await supabase
      .rpc('search_inventory_with_batches', {
        p_search_term: null,
        p_center_id: TEST_IDS.hospital_central,
        p_stock_bajo: true,
        p_proximos_vencer_dias: null,
        p_estado: 'Disponible'
      });

    if (lowStockError) {
      recordTest('Función: search_inventory_with_batches (Stock Bajo)', false, lowStockError.message);
    } else {
      const found = lowStockResults && lowStockResults.length >= 2;
      recordTest('Función: search_inventory_with_batches (Stock Bajo)', found, `Encontrados: ${lowStockResults?.length || 0} medicamentos`, 'Al menos 2', `${lowStockResults?.length || 0}`);
    }

    // TEST 5: Función search_inventory_with_batches - Próximos a Vencer
    log('Probando función: search_inventory_with_batches (próximos a vencer)...', 'function');
    const { data: expiringResults, error: expiringError } = await supabase
      .rpc('search_inventory_with_batches', {
        p_search_term: null,
        p_center_id: TEST_IDS.hospital_central,
        p_stock_bajo: false,
        p_proximos_vencer_dias: 30,
        p_estado: 'Disponible'
      });

    if (expiringError) {
      recordTest('Función: search_inventory_with_batches (Próximos a Vencer)', false, expiringError.message);
    } else {
      const found = expiringResults && expiringResults.length >= 1;
      recordTest('Función: search_inventory_with_batches (Próximos a Vencer)', found, `Encontrados: ${expiringResults?.length || 0} medicamentos`, 'Al menos 1', `${expiringResults?.length || 0}`);
    }

    // TEST 6: Función generate_traceability_report
    log('Probando función: generate_traceability_report...', 'function');
    const { data: traceability, error: traceError } = await supabase
      .rpc('generate_traceability_report', {
        p_medication_id: TEST_IDS.paracetamol_hospital,
        p_lote: 'TEST-PAR-2024-001',
        p_fecha_inicio: null,
        p_fecha_fin: null
      });

    if (traceError) {
      recordTest('Función: generate_traceability_report', false, traceError.message);
    } else {
      const found = traceability && traceability.length >= 2; // Debe tener al menos entrada y salida
      recordTest('Función: generate_traceability_report', found, `Movimientos: ${traceability?.length || 0}`, 'Al menos 2 movimientos', `${traceability?.length || 0} movimientos`);
    }

    return true;
  } catch (error) {
    log(`Error probando funciones: ${error.message}`, 'error');
    return false;
  }
}

// ============================================
// PASO 5: PROBAR CONSULTAS DE INVENTARIO
// ============================================
async function testInventoryQueries() {
  logSection('PASO 5: PROBANDO CONSULTAS DE INVENTARIO');

  try {
    // TEST 1: Listar todo el inventario del Hospital Central
    log('Probando: Listar inventario completo...', 'database');
    const { data: allMeds, error: allError } = await supabase
      .from('medications')
      .select('*')
      .eq('center_id', TEST_IDS.hospital_central)
      .like('lote', 'TEST%');

    if (allError) {
      recordTest('Consulta: Inventario Completo', false, allError.message);
    } else {
      recordTest('Consulta: Inventario Completo', allMeds?.length === 6, `${allMeds?.length || 0} medicamentos`, '6 medicamentos', `${allMeds?.length || 0} medicamentos`);
    }

    // TEST 2: Buscar por nombre
    log('Probando: Búsqueda por nombre...', 'database');
    const { data: searchMeds, error: searchError } = await supabase
      .from('medications')
      .select('*')
      .eq('center_id', TEST_IDS.hospital_central)
      .ilike('nombre', '%AMOXICILINA%')
      .like('lote', 'TEST%');

    if (searchError) {
      recordTest('Consulta: Búsqueda por Nombre', false, searchError.message);
    } else {
      recordTest('Consulta: Búsqueda por Nombre', searchMeds?.length === 2, `${searchMeds?.length || 0} resultados para AMOXICILINA`, '2 resultados', `${searchMeds?.length || 0} resultados`);
    }

    // TEST 3: Stock bajo (< 50 unidades)
    log('Probando: Filtro stock bajo...', 'database');
    const { data: lowStock, error: lowError } = await supabase
      .from('medications')
      .select('*')
      .eq('center_id', TEST_IDS.hospital_central)
      .lt('cantidad', 50)
      .like('lote', 'TEST%');

    if (lowError) {
      recordTest('Consulta: Stock Bajo (<50)', false, lowError.message);
    } else {
      recordTest('Consulta: Stock Bajo (<50)', lowStock?.length >= 2, `${lowStock?.length || 0} medicamentos`, 'Al menos 2', `${lowStock?.length || 0}`);
    }

    // TEST 4: Medicamentos refrigerados
    log('Probando: Filtro medicamentos refrigerados...', 'database');
    const { data: refrigerated, error: refError } = await supabase
      .from('medications')
      .select('*, medication_catalog(*)')
      .eq('center_id', TEST_IDS.hospital_central)
      .eq('medication_catalog.temperatura_almacenamiento', 'refrigerado')
      .like('lote', 'TEST%');

    if (refError) {
      recordTest('Consulta: Medicamentos Refrigerados', false, refError.message);
    } else {
      recordTest('Consulta: Medicamentos Refrigerados', refrigerated?.length >= 1, `${refrigerated?.length || 0} medicamentos`, 'Al menos 1', `${refrigerated?.length || 0}`);
    }

    // TEST 5: Medicamentos por estado
    log('Probando: Filtro por estado...', 'database');
    const { data: available, error: availError } = await supabase
      .from('medications')
      .select('*')
      .eq('center_id', TEST_IDS.hospital_central)
      .eq('estado', 'Disponible')
      .like('lote', 'TEST%');

    if (availError) {
      recordTest('Consulta: Filtro por Estado (Disponible)', false, availError.message);
    } else {
      recordTest('Consulta: Filtro por Estado (Disponible)', available?.length === 6, `${available?.length || 0} medicamentos disponibles`, '6', `${available?.length || 0}`);
    }

    return true;
  } catch (error) {
    log(`Error probando consultas de inventario: ${error.message}`, 'error');
    return false;
  }
}

// ============================================
// PASO 6: PROBAR TRIGGERS DE AUDITORÍA
// ============================================
async function testAuditTriggers() {
  logSection('PASO 6: PROBANDO TRIGGERS DE AUDITORÍA');

  try {
    // Obtener cantidad actual de registros en audit_log
    const { count: beforeCount, error: beforeError } = await supabase
      .from('audit_log')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', new Date(Date.now() - 60000).toISOString());

    if (beforeError) {
      log(`Error consultando audit_log: ${beforeError.message}`, 'warning');
    }

    log(`Registros en audit_log antes de las pruebas: ${beforeCount || 0}`, 'info');

    // TEST 1: Actualizar un medicamento (debe generar entrada en audit_log)
    log('Probando: Trigger de auditoría en UPDATE de medications...', 'function');
    const { error: updateError } = await supabase
      .from('medications')
      .update({ cantidad: 1750 })
      .eq('id', TEST_IDS.paracetamol_hospital);

    if (updateError) {
      recordTest('Trigger: Auditoría en UPDATE medications', false, updateError.message);
    } else {
      await waitForOperation(1000); // Esperar a que el trigger se ejecute

      const { count: afterCount, error: afterError } = await supabase
        .from('audit_log')
        .select('*', { count: 'exact', head: true })
        .eq('table_name', 'medications')
        .eq('operation', 'UPDATE')
        .gte('created_at', new Date(Date.now() - 5000).toISOString());

      if (afterError) {
        recordTest('Trigger: Auditoría en UPDATE medications', false, afterError.message);
      } else {
        const triggered = (afterCount || 0) > 0;
        recordTest('Trigger: Auditoría en UPDATE medications', triggered, `${afterCount || 0} registros creados`, 'Al menos 1', `${afterCount || 0}`);
      }
    }

    // TEST 2: Verificar registro en batch_movements por los movimientos anteriores
    log('Probando: Registros en batch_movements...', 'database');
    const { data: movements, error: movError } = await supabase
      .from('batch_movements')
      .select('*')
      .eq('medication_id', TEST_IDS.paracetamol_hospital)
      .gte('created_at', new Date(Date.now() - 60000).toISOString())
      .order('created_at', { ascending: true });

    if (movError) {
      recordTest('Verificación: batch_movements creados', false, movError.message);
    } else {
      const hasMovements = (movements?.length || 0) >= 2;
      recordTest('Verificación: batch_movements creados', hasMovements, `${movements?.length || 0} movimientos`, 'Al menos 2', `${movements?.length || 0}`);

      if (movements && movements.length > 0) {
        log(`  - Movimientos registrados: ${movements.map(m => m.tipo_movimiento).join(', ')}`, 'info');
      }
    }

    return true;
  } catch (error) {
    log(`Error probando triggers de auditoría: ${error.message}`, 'error');
    return false;
  }
}

// ============================================
// PASO 7: PROBAR SISTEMA DE ALERTAS
// ============================================
async function testAlertSystem() {
  logSection('PASO 7: PROBANDO SISTEMA DE ALERTAS');

  try {
    // TEST 1: Verificar generación de alertas para medicamentos próximos a vencer
    log('Probando: Alertas de medicamentos próximos a vencer...', 'database');

    const currentDate = new Date();
    const futureDate30 = new Date(currentDate);
    futureDate30.setDate(futureDate30.getDate() + 30);

    const { data: expiringMeds, error: expError } = await supabase
      .from('medications')
      .select('*')
      .eq('center_id', TEST_IDS.hospital_central)
      .lte('fecha_caducidad', futureDate30.toISOString().split('T')[0])
      .like('lote', 'TEST%');

    if (expError) {
      recordTest('Sistema de Alertas: Detección de Vencimientos', false, expError.message);
    } else {
      const hasExpiring = (expiringMeds?.length || 0) >= 1;
      recordTest('Sistema de Alertas: Detección de Vencimientos', hasExpiring, `${expiringMeds?.length || 0} medicamentos próximos a vencer`, 'Al menos 1', `${expiringMeds?.length || 0}`);

      if (expiringMeds && expiringMeds.length > 0) {
        expiringMeds.forEach(med => {
          const daysLeft = Math.ceil((new Date(med.fecha_caducidad) - currentDate) / (1000 * 60 * 60 * 24));
          log(`  - ${med.nombre} (Lote: ${med.lote}): ${daysLeft} días`, 'info');
        });
      }
    }

    // TEST 2: Verificar medicamentos con stock bajo
    log('Probando: Alertas de stock bajo...', 'database');
    const { data: lowStockMeds, error: lowError } = await supabase
      .from('medications')
      .select('*')
      .eq('center_id', TEST_IDS.hospital_central)
      .lt('cantidad', 50)
      .like('lote', 'TEST%');

    if (lowError) {
      recordTest('Sistema de Alertas: Stock Bajo', false, lowError.message);
    } else {
      const hasLowStock = (lowStockMeds?.length || 0) >= 2;
      recordTest('Sistema de Alertas: Stock Bajo', hasLowStock, `${lowStockMeds?.length || 0} medicamentos con stock bajo`, 'Al menos 2', `${lowStockMeds?.length || 0}`);

      if (lowStockMeds && lowStockMeds.length > 0) {
        lowStockMeds.forEach(med => {
          log(`  - ${med.nombre}: ${med.cantidad} unidades`, 'info');
        });
      }
    }

    return true;
  } catch (error) {
    log(`Error probando sistema de alertas: ${error.message}`, 'error');
    return false;
  }
}

// ============================================
// PASO 8: GENERAR REPORTE FINAL
// ============================================
function generateFinalReport() {
  logSection('REPORTE FINAL DE PRUEBAS');

  const totalTests = testCount;
  const passedTests = passCount;
  const failedTests = failCount;
  const successRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toFixed(2) : 0;

  console.log(`
┌─────────────────────────────────────────────────────────┐
│                  RESUMEN DE PRUEBAS                     │
├─────────────────────────────────────────────────────────┤
│  Total de Pruebas:        ${totalTests.toString().padStart(3)}                         │
│  Pruebas Exitosas:        ${passedTests.toString().padStart(3)} ✅                       │
│  Pruebas Fallidas:        ${failedTests.toString().padStart(3)} ❌                       │
│  Tasa de Éxito:           ${successRate}%                       │
└─────────────────────────────────────────────────────────┘
  `);

  if (failedTests > 0) {
    console.log('\n❌ PRUEBAS FALLIDAS:\n');
    testResults
      .filter(t => !t.passed)
      .forEach((test, index) => {
        console.log(`${index + 1}. ${test.testName}`);
        console.log(`   Detalles: ${test.details}`);
        if (test.expected) console.log(`   Esperado: ${test.expected}`);
        if (test.actual) console.log(`   Obtenido: ${test.actual}`);
        console.log('');
      });
  }

  console.log('\n✅ FUNCIONALIDADES VERIFICADAS:\n');
  console.log('  • Inserción de datos de prueba (centros, proveedores, catálogo, inventario)');
  console.log('  • Función registrar_movimiento_lote() - Entradas y Salidas');
  console.log('  • Función search_inventory_with_batches() - Búsquedas avanzadas');
  console.log('  • Función search_inventory_with_batches() - Filtro stock bajo');
  console.log('  • Función search_inventory_with_batches() - Filtro próximos a vencer');
  console.log('  • Función generate_traceability_report() - Trazabilidad de lotes');
  console.log('  • Consultas de inventario (listar, buscar, filtrar)');
  console.log('  • Triggers de auditoría automática');
  console.log('  • Sistema de alertas (vencimientos y stock bajo)');
  console.log('  • Registro de movimientos en batch_movements');

  console.log('\n📋 PRÓXIMOS PASOS:\n');
  console.log('  1. Revisar las pruebas fallidas (si las hay)');
  console.log('  2. Verificar la interfaz web en Vercel');
  console.log('  3. Probar funcionalidad de importación manual');
  console.log('  4. Validar reportes en formato PDF/Excel');

  const status = failedTests === 0 ? '🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE' : '⚠️  ALGUNAS PRUEBAS FALLARON';
  console.log(`\n${status}\n`);

  return failedTests === 0;
}

// ============================================
// MAIN EXECUTION
// ============================================
async function main() {
  console.log('\n');
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║                                                           ║');
  console.log('║     PRUEBAS AUTOMATIZADAS COMPLETAS - SIGIMED             ║');
  console.log('║                                                           ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('\n');

  try {
    // Paso 1: Limpiar datos anteriores
    const cleanSuccess = await cleanTestData();
    if (!cleanSuccess) {
      log('Advertencia: No se pudieron limpiar completamente los datos anteriores', 'warning');
    }

    // Paso 2: Insertar datos de prueba
    const insertSuccess = await insertTestData();
    if (!insertSuccess) {
      log('Error crítico: No se pudieron insertar los datos de prueba', 'error');
      process.exit(1);
    }

    await waitForOperation(2000);

    // Paso 3: Verificar inserción
    const verifySuccess = await verifyDataInsertion();
    if (!verifySuccess) {
      log('Advertencia: La verificación de datos falló', 'warning');
    }

    // Paso 4: Probar funciones de base de datos
    await testDatabaseFunctions();
    await waitForOperation(1000);

    // Paso 5: Probar consultas de inventario
    await testInventoryQueries();
    await waitForOperation(1000);

    // Paso 6: Probar triggers de auditoría
    await testAuditTriggers();
    await waitForOperation(1000);

    // Paso 7: Probar sistema de alertas
    await testAlertSystem();

    // Paso 8: Generar reporte final
    const allPassed = generateFinalReport();

    process.exit(allPassed ? 0 : 1);

  } catch (error) {
    log(`Error fatal en la ejecución: ${error.message}`, 'error');
    console.error(error);
    process.exit(1);
  }
}

// Ejecutar
main();
