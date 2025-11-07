import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { importFromCSV, importFromExcel, ImportResult } from '../utils/importUtils';
import toast from 'react-hot-toast';

export function useImport(centroId: string, userId: string) {
  const [loading, setLoading] = useState(false);
  const [importing, setImporting] = useState(false);
  const [progress, setProgress] = useState(0);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);

  /**
   * Valida el archivo antes de procesar
   */
  function validateFile(file: File): { valid: boolean; message?: string } {
    const maxSize = 5 * 1024 * 1024; // 5MB
    const validExtensions = ['.csv', '.xlsx', '.xls'];

    if (file.size > maxSize) {
      return { valid: false, message: 'El archivo excede el tamaño máximo de 5MB' };
    }

    const extension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
    if (!validExtensions.includes(extension)) {
      return { valid: false, message: 'Formato de archivo no válido. Use CSV o Excel' };
    }

    return { valid: true };
  }

  /**
   * Procesa y valida el archivo (CSV o Excel)
   */
  async function parseFile(file: File): Promise<ImportResult> {
    setLoading(true);

    try {
      const validation = validateFile(file);
      if (!validation.valid) {
        throw new Error(validation.message);
      }

      const extension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();

      let result: ImportResult;
      if (extension === '.csv') {
        result = await importFromCSV(file);
      } else {
        result = await importFromExcel(file);
      }

      setImportResult(result);

      if (result.errors.length > 0) {
        toast.error(`Se encontraron ${result.errors.length} errores en el archivo`);
      } else if (result.warnings.length > 0) {
        toast(`Se encontraron ${result.warnings.length} advertencias`, { icon: '⚠️' });
      } else {
        toast.success(`Archivo validado: ${result.validRows} filas listas para importar`);
      }

      return result;
    } catch (err: any) {
      const errorMessage = err.message || 'Error al procesar el archivo';
      toast.error(errorMessage);
      throw err;
    } finally {
      setLoading(false);
    }
  }

  /**
   * Importa los medicamentos validados a la base de datos
   */
  async function importMedications(validatedData: any[]) {
    setImporting(true);
    setProgress(0);

    const results = {
      successful: 0,
      failed: 0,
      errors: [] as Array<{ row: number; error: string }>
    };

    try {
      // Verificar que exista el catálogo para cada medicamento
      const catalogNames = [...new Set(validatedData.map(item => item.nombre))];
      const { data: catalogItems } = await supabase
        .from('medication_catalog')
        .select('id, nombre_comercial, nombre_generico')
        .in('nombre_comercial', catalogNames);

      const catalogMap = new Map(
        (catalogItems || []).map(item => [item.nombre_comercial, item.id])
      );

      // Importar uno por uno para tener mejor control
      for (let i = 0; i < validatedData.length; i++) {
        const item = validatedData[i];

        try {
          // Buscar en el catálogo
          const catalogId = catalogMap.get(item.nombre);

          if (!catalogId) {
            results.errors.push({
              row: i + 1,
              error: `Medicamento "${item.nombre}" no existe en el catálogo`
            });
            results.failed++;
            continue;
          }

          // Verificar si ya existe un lote con el mismo número
          const { data: existingBatch } = await supabase
            .from('medications')
            .select('id')
            .eq('center_id', centroId)
            .eq('lote', item.lote)
            .eq('catalog_id', catalogId)
            .maybeSingle();

          if (existingBatch) {
            results.errors.push({
              row: i + 1,
              error: `Ya existe un lote "${item.lote}" para este medicamento en el centro`
            });
            results.failed++;
            continue;
          }

          // Insertar medicamento
          const { error: insertError } = await supabase
            .from('medications')
            .insert({
              center_id: centroId,
              catalog_id: catalogId,
              nombre: item.nombre,
              formula_activa: item.formula_activa,
              lote: item.lote,
              cantidad: item.cantidad,
              fecha_caducidad: item.fecha_caducidad,
              fecha_ingreso: item.fecha_ingreso || new Date().toISOString().split('T')[0],
              estado: item.estado || 'Disponible',
              ubicacion_fisica: item.ubicacion_fisica,
              costo_unitario: item.costo_unitario,
              precio_venta: item.precio_venta,
              created_by: userId
            });

          if (insertError) {
            results.errors.push({
              row: i + 1,
              error: insertError.message
            });
            results.failed++;
          } else {
            results.successful++;
          }
        } catch (err: any) {
          results.errors.push({
            row: i + 1,
            error: err.message || 'Error desconocido'
          });
          results.failed++;
        }

        // Actualizar progreso
        setProgress(Math.round(((i + 1) / validatedData.length) * 100));
      }

      // Mostrar resultado final
      if (results.successful > 0) {
        toast.success(`Importación completada: ${results.successful} medicamentos importados`);
      }

      if (results.failed > 0) {
        toast.error(`${results.failed} filas fallaron al importar`);
      }

      // Registrar en audit_log
      await supabase.from('audit_log').insert({
        user_id: userId,
        action_type: 'IMPORT',
        entity_type: 'medication',
        result: results.failed === 0 ? 'success' : 'partial',
        severity: 'medium',
        metadata: {
          total: validatedData.length,
          successful: results.successful,
          failed: results.failed,
          errors: results.errors
        }
      });

      return results;
    } catch (err: any) {
      toast.error('Error durante la importación: ' + err.message);
      throw err;
    } finally {
      setImporting(false);
      setProgress(0);
    }
  }

  return {
    loading,
    importing,
    progress,
    importResult,
    parseFile,
    importMedications,
    setImportResult
  };
}
