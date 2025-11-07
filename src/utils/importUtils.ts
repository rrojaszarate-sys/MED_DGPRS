import Papa from 'papaparse';
import * as XLSX from 'xlsx';

export interface ImportError {
  row: number;
  field: string;
  value: any;
  message: string;
  type: 'error' | 'warning';
}

export interface ImportResult {
  success: boolean;
  totalRows: number;
  validRows: number;
  errors: ImportError[];
  warnings: ImportError[];
  data: any[];
}

export interface MedicationImportRow {
  nombre: string;
  formula_activa: string;
  lote: string;
  cantidad: number;
  fecha_caducidad: string;
  fecha_ingreso?: string;
  estado: 'Disponible' | 'No Disponible' | 'Cuarentena';
  ubicacion_fisica?: string;
  costo_unitario?: number;
  precio_venta?: number;
}

const REQUIRED_FIELDS = ['nombre', 'formula_activa', 'lote', 'cantidad', 'fecha_caducidad'];
const VALID_ESTADOS = ['Disponible', 'No Disponible', 'Cuarentena'];

/**
 * Valida una fila de medicamento importado
 */
function validateMedicationRow(row: any, index: number): ImportError[] {
  const errors: ImportError[] = [];

  // Validar campos requeridos
  REQUIRED_FIELDS.forEach(field => {
    if (!row[field] || row[field].toString().trim() === '') {
      errors.push({
        row: index + 1,
        field,
        value: row[field],
        message: `Campo requerido "${field}" está vacío`,
        type: 'error'
      });
    }
  });

  // Validar cantidad es número positivo
  if (row.cantidad !== undefined && row.cantidad !== null) {
    const cantidad = Number(row.cantidad);
    if (isNaN(cantidad) || cantidad < 0) {
      errors.push({
        row: index + 1,
        field: 'cantidad',
        value: row.cantidad,
        message: 'La cantidad debe ser un número positivo',
        type: 'error'
      });
    }
  }

  // Validar formato de fecha
  if (row.fecha_caducidad) {
    const dateStr = row.fecha_caducidad.toString();
    const dateFormats = [
      /^\d{4}-\d{2}-\d{2}$/,  // YYYY-MM-DD
      /^\d{2}\/\d{2}\/\d{4}$/  // DD/MM/YYYY
    ];

    const isValidFormat = dateFormats.some(format => format.test(dateStr));

    if (!isValidFormat) {
      errors.push({
        row: index + 1,
        field: 'fecha_caducidad',
        value: row.fecha_caducidad,
        message: 'Formato de fecha inválido. Use YYYY-MM-DD o DD/MM/YYYY',
        type: 'error'
      });
    } else {
      // Validar que la fecha no esté vencida
      const fecha = parseDateString(dateStr);
      if (fecha < new Date()) {
        errors.push({
          row: index + 1,
          field: 'fecha_caducidad',
          value: row.fecha_caducidad,
          message: 'La fecha de caducidad ya pasó',
          type: 'warning'
        });
      }
    }
  }

  // Validar estado
  if (row.estado && !VALID_ESTADOS.includes(row.estado)) {
    errors.push({
      row: index + 1,
      field: 'estado',
      value: row.estado,
      message: `Estado inválido. Valores permitidos: ${VALID_ESTADOS.join(', ')}`,
      type: 'error'
    });
  }

  // Validar costos si están presentes
  if (row.costo_unitario !== undefined && row.costo_unitario !== null) {
    const costo = Number(row.costo_unitario);
    if (isNaN(costo) || costo < 0) {
      errors.push({
        row: index + 1,
        field: 'costo_unitario',
        value: row.costo_unitario,
        message: 'El costo unitario debe ser un número positivo',
        type: 'error'
      });
    }
  }

  if (row.precio_venta !== undefined && row.precio_venta !== null) {
    const precio = Number(row.precio_venta);
    if (isNaN(precio) || precio < 0) {
      errors.push({
        row: index + 1,
        field: 'precio_venta',
        value: row.precio_venta,
        message: 'El precio de venta debe ser un número positivo',
        type: 'error'
      });
    }
  }

  return errors;
}

/**
 * Convierte string de fecha a objeto Date
 */
function parseDateString(dateStr: string): Date {
  // YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
    return new Date(dateStr);
  }

  // DD/MM/YYYY
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateStr)) {
    const [day, month, year] = dateStr.split('/');
    return new Date(`${year}-${month}-${day}`);
  }

  return new Date(dateStr);
}

/**
 * Normaliza los datos importados
 */
function normalizeImportedData(rows: any[]): MedicationImportRow[] {
  return rows.map(row => ({
    nombre: row.nombre?.toString().trim() || '',
    formula_activa: row.formula_activa?.toString().trim() || '',
    lote: row.lote?.toString().trim() || '',
    cantidad: Number(row.cantidad) || 0,
    fecha_caducidad: row.fecha_caducidad?.toString().trim() || '',
    fecha_ingreso: row.fecha_ingreso?.toString().trim() || new Date().toISOString().split('T')[0],
    estado: (row.estado?.toString().trim() || 'Disponible') as 'Disponible' | 'No Disponible' | 'Cuarentena',
    ubicacion_fisica: row.ubicacion_fisica?.toString().trim(),
    costo_unitario: row.costo_unitario ? Number(row.costo_unitario) : undefined,
    precio_venta: row.precio_venta ? Number(row.precio_venta) : undefined,
  }));
}

/**
 * Importa medicamentos desde archivo CSV
 */
export async function importFromCSV(file: File): Promise<ImportResult> {
  return new Promise((resolve) => {
    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        const allErrors: ImportError[] = [];
        const allWarnings: ImportError[] = [];

        // Validar cada fila
        results.data.forEach((row: any, index: number) => {
          const validationErrors = validateMedicationRow(row, index);
          validationErrors.forEach(error => {
            if (error.type === 'error') {
              allErrors.push(error);
            } else {
              allWarnings.push(error);
            }
          });
        });

        // Normalizar datos
        const normalizedData = normalizeImportedData(results.data);

        // Filtrar solo filas válidas (sin errores críticos)
        const validData = normalizedData.filter((_, index) => {
          return !allErrors.some(error => error.row === index + 1);
        });

        resolve({
          success: allErrors.length === 0,
          totalRows: results.data.length,
          validRows: validData.length,
          errors: allErrors,
          warnings: allWarnings,
          data: validData
        });
      },
      error: (error) => {
        resolve({
          success: false,
          totalRows: 0,
          validRows: 0,
          errors: [{
            row: 0,
            field: 'file',
            value: file.name,
            message: `Error al leer archivo CSV: ${error.message}`,
            type: 'error'
          }],
          warnings: [],
          data: []
        });
      }
    });
  });
}

/**
 * Importa medicamentos desde archivo Excel
 */
export async function importFromExcel(file: File): Promise<ImportResult> {
  return new Promise((resolve) => {
    const reader = new FileReader();

    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target?.result as ArrayBuffer);
        const workbook = XLSX.read(data, { type: 'array' });

        // Leer primera hoja
        const firstSheet = workbook.Sheets[workbook.SheetNames[0]];
        const jsonData = XLSX.utils.sheet_to_json(firstSheet);

        const allErrors: ImportError[] = [];
        const allWarnings: ImportError[] = [];

        // Validar cada fila
        jsonData.forEach((row: any, index: number) => {
          const validationErrors = validateMedicationRow(row, index);
          validationErrors.forEach(error => {
            if (error.type === 'error') {
              allErrors.push(error);
            } else {
              allWarnings.push(error);
            }
          });
        });

        // Normalizar datos
        const normalizedData = normalizeImportedData(jsonData);

        // Filtrar solo filas válidas
        const validData = normalizedData.filter((_, index) => {
          return !allErrors.some(error => error.row === index + 1);
        });

        resolve({
          success: allErrors.length === 0,
          totalRows: jsonData.length,
          validRows: validData.length,
          errors: allErrors,
          warnings: allWarnings,
          data: validData
        });
      } catch (error: any) {
        resolve({
          success: false,
          totalRows: 0,
          validRows: 0,
          errors: [{
            row: 0,
            field: 'file',
            value: file.name,
            message: `Error al leer archivo Excel: ${error.message}`,
            type: 'error'
          }],
          warnings: [],
          data: []
        });
      }
    };

    reader.onerror = () => {
      resolve({
        success: false,
        totalRows: 0,
        validRows: 0,
        errors: [{
          row: 0,
          field: 'file',
          value: file.name,
          message: 'Error al leer el archivo',
          type: 'error'
        }],
        warnings: [],
        data: []
      });
    };

    reader.readAsArrayBuffer(file);
  });
}

/**
 * Genera plantilla CSV para importación
 */
export function generateImportTemplate(): string {
  const headers = [
    'nombre',
    'formula_activa',
    'lote',
    'cantidad',
    'fecha_caducidad',
    'fecha_ingreso',
    'estado',
    'ubicacion_fisica',
    'costo_unitario',
    'precio_venta'
  ];

  const example = [
    'Paracetamol 500mg',
    'Paracetamol',
    'LOT2024001',
    '1000',
    '2025-12-31',
    '2024-01-15',
    'Disponible',
    'Estante A-1',
    '0.50',
    '1.00'
  ];

  return `${headers.join(',')}\n${example.join(',')}`;
}

/**
 * Descarga plantilla CSV
 */
export function downloadImportTemplate(): void {
  const csv = generateImportTemplate();
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);

  link.setAttribute('href', url);
  link.setAttribute('download', 'plantilla_importacion_medicamentos.csv');
  link.style.visibility = 'hidden';

  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
