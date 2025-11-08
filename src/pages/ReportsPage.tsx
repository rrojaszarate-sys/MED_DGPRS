import { useState } from 'react';
import { FileText, Download, Calendar, Search } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useCentro } from '../context/CentroContext';
import { Button } from '../components/ui/Button';
import { exportMedicationsPDF, exportMedicationsExcel } from '../utils/exportUtils';

interface ReportFilters {
  lote: string;
  fecha_inicio: string;
  fecha_fin: string;
  estado: string;
  search_term: string;
  stock_bajo: number | null;
  proximos_vencer_dias: number | null;
}

export function ReportsPage() {
  const { centroSeleccionado } = useCentro();
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState<any[]>([]);
  const [reportType, setReportType] = useState<'traceability' | 'search'>('search');

  const [filters, setFilters] = useState<ReportFilters>({
    lote: '',
    fecha_inicio: '',
    fecha_fin: '',
    estado: '',
    search_term: '',
    stock_bajo: null,
    proximos_vencer_dias: 90
  });

  const handleGenerateReport = async () => {
    if (!centroSeleccionado) return;

    setLoading(true);
    try {
      let data, error;

      if (reportType === 'traceability') {
        // Reporte de trazabilidad
        const result = await supabase.rpc('generate_traceability_report', {
          p_medication_id: null,
          p_lote: filters.lote || null,
          p_center_id: centroSeleccionado.id,
          p_fecha_inicio: filters.fecha_inicio || null,
          p_fecha_fin: filters.fecha_fin || null,
          p_estado: filters.estado || null,
          p_include_history: false
        });
        data = result.data;
        error = result.error;
      } else {
        // Búsqueda avanzada
        const result = await supabase.rpc('search_inventory_with_batches', {
          p_search_term: filters.search_term || null,
          p_center_id: centroSeleccionado.id,
          p_stock_bajo: filters.stock_bajo,
          p_vencidos: false,
          p_proximos_vencer_dias: filters.proximos_vencer_dias,
          p_estado: filters.estado || null
        });
        data = result.data;
        error = result.error;
      }

      if (error) {
        console.error('Error al generar reporte:', error);
        alert('Error al generar reporte: ' + error.message);
      } else {
        setReportData(data || []);
      }
    } catch (err: any) {
      console.error('Error:', err);
      alert('Error al generar reporte: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleExportPDF = () => {
    exportMedicationsPDF(reportData, `Reporte - ${centroSeleccionado?.name}`);
  };

  const handleExportExcel = () => {
    exportMedicationsExcel(reportData, `Reporte - ${centroSeleccionado?.name}`);
  };

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver reportes</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Reportes Avanzados</h1>
        <p className="text-gray-600 mt-1">Búsqueda y trazabilidad de inventario - {centroSeleccionado.name}</p>
      </div>

      {/* Tipo de Reporte */}
      <div className="bg-white p-4 rounded-lg shadow-md">
        <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Reporte</label>
        <div className="flex gap-4">
          <label className="flex items-center">
            <input
              type="radio"
              name="reportType"
              value="search"
              checked={reportType === 'search'}
              onChange={(e) => setReportType(e.target.value as any)}
              className="mr-2"
            />
            Búsqueda Avanzada (con alertas)
          </label>
          <label className="flex items-center">
            <input
              type="radio"
              name="reportType"
              value="traceability"
              checked={reportType === 'traceability'}
              onChange={(e) => setReportType(e.target.value as any)}
              className="mr-2"
            />
            Reporte de Trazabilidad
          </label>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white p-6 rounded-lg shadow-md space-y-4">
        <h2 className="text-lg font-semibold">Filtros</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {/* Búsqueda por texto */}
          {reportType === 'search' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Search className="inline h-4 w-4 mr-1" />
                Buscar por nombre, fórmula o lote
              </label>
              <input
                type="text"
                value={filters.search_term}
                onChange={(e) => setFilters({ ...filters, search_term: e.target.value })}
                placeholder="Buscar..."
                className="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
          )}

          {/* Lote */}
          {reportType === 'traceability' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Número de Lote</label>
              <input
                type="text"
                value={filters.lote}
                onChange={(e) => setFilters({ ...filters, lote: e.target.value })}
                placeholder="Ej: LOT2024001"
                className="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
          )}

          {/* Estado */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Estado</label>
            <select
              value={filters.estado}
              onChange={(e) => setFilters({ ...filters, estado: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md"
            >
              <option value="">Todos</option>
              <option value="Disponible">Disponible</option>
              <option value="No Disponible">No Disponible</option>
              <option value="Cuarentena">Cuarentena</option>
            </select>
          </div>

          {/* Fecha inicio */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Calendar className="inline h-4 w-4 mr-1" />
              Fecha Inicio
            </label>
            <input
              type="date"
              value={filters.fecha_inicio}
              onChange={(e) => setFilters({ ...filters, fecha_inicio: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md"
            />
          </div>

          {/* Fecha fin */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Calendar className="inline h-4 w-4 mr-1" />
              Fecha Fin
            </label>
            <input
              type="date"
              value={filters.fecha_fin}
              onChange={(e) => setFilters({ ...filters, fecha_fin: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md"
            />
          </div>

          {/* Próximos a vencer */}
          {reportType === 'search' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Próximos a vencer (días)
              </label>
              <input
                type="number"
                value={filters.proximos_vencer_dias || ''}
                onChange={(e) => setFilters({ ...filters, proximos_vencer_dias: e.target.value ? parseInt(e.target.value) : null })}
                placeholder="Ej: 90"
                className="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
          )}

          {/* Stock bajo */}
          {reportType === 'search' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Stock bajo (cantidad)
              </label>
              <input
                type="number"
                value={filters.stock_bajo || ''}
                onChange={(e) => setFilters({ ...filters, stock_bajo: e.target.value ? parseInt(e.target.value) : null })}
                placeholder="Ej: 10"
                className="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
          )}
        </div>

        <div className="flex gap-2">
          <Button
            onClick={handleGenerateReport}
            icon={<FileText className="h-5 w-5" />}
            disabled={loading}
          >
            {loading ? 'Generando...' : 'Generar Reporte'}
          </Button>

          {reportData.length > 0 && (
            <>
              <Button
                onClick={handleExportPDF}
                icon={<Download className="h-5 w-5" />}
                variant="outline"
              >
                Exportar PDF
              </Button>
              <Button
                onClick={handleExportExcel}
                icon={<Download className="h-5 w-5" />}
                variant="outline"
              >
                Exportar Excel
              </Button>
            </>
          )}
        </div>
      </div>

      {/* Resultados */}
      {reportData.length > 0 && (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
            <h2 className="text-lg font-semibold">
              Resultados ({reportData.length} registros)
            </h2>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Medicamento</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lote</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cantidad</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha Cad.</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                  {reportType === 'search' && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Alertas</th>
                  )}
                  {reportType === 'traceability' && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Movimientos</th>
                  )}
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {reportData.map((item, idx) => (
                  <tr key={idx} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {item.medication_nombre || item.nombre}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {item.medication_lote || item.lote}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {item.medication_cantidad || item.cantidad}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {item.medication_fecha_caducidad || item.fecha_caducidad}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs rounded-full ${
                        (item.medication_estado || item.estado) === 'Disponible'
                          ? 'bg-green-100 text-green-800'
                          : (item.medication_estado || item.estado) === 'Cuarentena'
                          ? 'bg-yellow-100 text-yellow-800'
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {item.medication_estado || item.estado}
                      </span>
                    </td>
                    {reportType === 'search' && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        {item.expired_alert && <span className="px-2 py-1 text-xs bg-red-100 text-red-800 rounded-full mr-1">Vencido</span>}
                        {item.expiring_soon_alert && <span className="px-2 py-1 text-xs bg-yellow-100 text-yellow-800 rounded-full mr-1">Por vencer</span>}
                        {item.stock_alert && <span className="px-2 py-1 text-xs bg-orange-100 text-orange-800 rounded-full">Stock bajo</span>}
                        {!item.expired_alert && !item.expiring_soon_alert && !item.stock_alert && (
                          <span className="text-gray-400">-</span>
                        )}
                      </td>
                    )}
                    {reportType === 'traceability' && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.total_movimientos || 0}
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {reportData.length === 0 && !loading && (
        <div className="bg-white rounded-lg shadow-md p-12 text-center">
          <FileText className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600">
            Configura los filtros y haz clic en "Generar Reporte" para ver los resultados
          </p>
        </div>
      )}
    </div>
  );
}
