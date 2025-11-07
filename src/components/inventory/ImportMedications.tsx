import { useState } from 'react';
import { Upload, Download, AlertCircle, CheckCircle, X } from 'lucide-react';
import { useImport } from '../../hooks/useImport';
import { downloadImportTemplate } from '../../utils/importUtils';
import { useAuth } from '../../context/AuthContext';
import { useCentro } from '../../context/CentroContext';

export function ImportMedications() {
  const [file, setFile] = useState<File | null>(null);
  const [showResults, setShowResults] = useState(false);
  const { user } = useAuth();
  const { centroSeleccionado } = useCentro();

  const {
    loading,
    importing,
    progress,
    importResult,
    parseFile,
    importMedications,
    setImportResult
  } = useImport(centroSeleccionado?.id || '', user?.id || '');

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) {
      setFile(selectedFile);
      await parseFile(selectedFile);
      setShowResults(true);
    }
  };

  const handleImport = async () => {
    if (importResult && importResult.data.length > 0) {
      await importMedications(importResult.data);
      setShowResults(false);
      setFile(null);
      setImportResult(null);
    }
  };

  const handleCancel = () => {
    setFile(null);
    setImportResult(null);
    setShowResults(false);
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">Importación Masiva de Medicamentos</h2>

      {/* Botón para descargar plantilla */}
      <div className="mb-6">
        <button
          onClick={downloadImportTemplate}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          <Download size={20} />
          Descargar Plantilla CSV
        </button>
        <p className="text-sm text-gray-600 mt-2">
          Descarga la plantilla, complétala con tus datos y luego importa el archivo.
        </p>
      </div>

      {/* Selector de archivo */}
      {!showResults && (
        <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
          <Upload className="mx-auto mb-4 text-gray-400" size={48} />
          <label className="cursor-pointer">
            <span className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700">
              Seleccionar Archivo CSV o Excel
            </span>
            <input
              type="file"
              accept=".csv,.xlsx,.xls"
              onChange={handleFileChange}
              className="hidden"
              disabled={loading || importing}
            />
          </label>
          {file && (
            <p className="mt-4 text-sm text-gray-600">
              Archivo seleccionado: <strong>{file.name}</strong>
            </p>
          )}
        </div>
      )}

      {/* Resultados de validación */}
      {showResults && importResult && (
        <div className="space-y-4">
          {/* Resumen */}
          <div className="bg-gray-50 p-4 rounded-md">
            <h3 className="font-semibold mb-2">Resumen de Validación</h3>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <p className="text-sm text-gray-600">Total de filas</p>
                <p className="text-2xl font-bold">{importResult.totalRows}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Filas válidas</p>
                <p className="text-2xl font-bold text-green-600">{importResult.validRows}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Errores</p>
                <p className="text-2xl font-bold text-red-600">{importResult.errors.length}</p>
              </div>
            </div>
          </div>

          {/* Errores */}
          {importResult.errors.length > 0 && (
            <div className="bg-red-50 border border-red-200 rounded-md p-4">
              <div className="flex items-center gap-2 mb-2">
                <AlertCircle className="text-red-600" size={20} />
                <h4 className="font-semibold text-red-800">Errores encontrados</h4>
              </div>
              <ul className="text-sm text-red-700 space-y-1 max-h-40 overflow-y-auto">
                {importResult.errors.slice(0, 10).map((error, idx) => (
                  <li key={idx}>
                    Fila {error.row}, campo "{error.field}": {error.message}
                  </li>
                ))}
                {importResult.errors.length > 10 && (
                  <li className="font-semibold">
                    ... y {importResult.errors.length - 10} errores más
                  </li>
                )}
              </ul>
            </div>
          )}

          {/* Advertencias */}
          {importResult.warnings.length > 0 && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
              <div className="flex items-center gap-2 mb-2">
                <AlertCircle className="text-yellow-600" size={20} />
                <h4 className="font-semibold text-yellow-800">Advertencias</h4>
              </div>
              <ul className="text-sm text-yellow-700 space-y-1 max-h-40 overflow-y-auto">
                {importResult.warnings.slice(0, 10).map((warning, idx) => (
                  <li key={idx}>
                    Fila {warning.row}, campo "{warning.field}": {warning.message}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Barra de progreso durante importación */}
          {importing && (
            <div className="bg-blue-50 p-4 rounded-md">
              <p className="text-sm font-semibold mb-2">Importando... {progress}%</p>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-blue-600 h-2 rounded-full transition-all"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          )}

          {/* Acciones */}
          <div className="flex gap-4">
            <button
              onClick={handleImport}
              disabled={importResult.validRows === 0 || importing}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <CheckCircle size={20} />
              Importar {importResult.validRows} medicamentos
            </button>
            <button
              onClick={handleCancel}
              disabled={importing}
              className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 disabled:opacity-50"
            >
              <X size={20} />
              Cancelar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
