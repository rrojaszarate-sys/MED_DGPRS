import { useState, useEffect } from 'react'
import { Search, Download, Eye, AlertCircle } from 'lucide-react'
import { supabase } from '../lib/supabase'
import { Button } from '../components/ui/Button'
import { useToast } from '../components/ui/Toast'
import type { AuditLog } from '../types'
import { exportReportPDF, exportReportExcel } from '../utils/exportUtils'

export function AuditLogPage() {
  const [logs, setLogs] = useState<AuditLog[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterAction, setFilterAction] = useState<string>('all')
  const [filterEntity, setFilterEntity] = useState<string>('all')
  const [filterSeverity, setFilterSeverity] = useState<string>('all')
  const [dateFrom, setDateFrom] = useState('')
  const [dateTo, setDateTo] = useState('')
  const toast = useToast()

  useEffect(() => {
    fetchLogs()

    // Real-time subscription
    const subscription = supabase
      .channel('audit_logs_changes')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'audit_logs'
      }, fetchLogs)
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const fetchLogs = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('audit_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(500)

      if (error) throw error
      setLogs(data || [])
    } catch (err) {
      console.error('Error fetching audit logs:', err)
      toast.error('Error al cargar registros de auditoría')
    } finally {
      setLoading(false)
    }
  }

  // Filtrar logs
  const filteredLogs = logs.filter((log) => {
    const matchesSearch = (
      (log.user_email && log.user_email.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (log.user_name && log.user_name.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (log.entity_name && log.entity_name.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (log.changes_summary && log.changes_summary.toLowerCase().includes(searchTerm.toLowerCase()))
    )

    const matchesAction = filterAction === 'all' || log.action_type === filterAction
    const matchesEntity = filterEntity === 'all' || log.entity_type === filterEntity
    const matchesSeverity = filterSeverity === 'all' || log.severity === filterSeverity

    let matchesDate = true
    if (dateFrom) {
      matchesDate = matchesDate && new Date(log.created_at) >= new Date(dateFrom)
    }
    if (dateTo) {
      const endDate = new Date(dateTo)
      endDate.setHours(23, 59, 59, 999)
      matchesDate = matchesDate && new Date(log.created_at) <= endDate
    }

    return matchesSearch && matchesAction && matchesEntity && matchesSeverity && matchesDate
  })

  const getActionColor = (action: string) => {
    switch (action) {
      case 'CREATE': return 'bg-green-100 text-green-800'
      case 'UPDATE': return 'bg-blue-100 text-blue-800'
      case 'DELETE': return 'bg-red-100 text-red-800'
      case 'LOGIN': return 'bg-purple-100 text-purple-800'
      case 'LOGOUT': return 'bg-gray-100 text-gray-800'
      case 'EXPORT': return 'bg-cyan-100 text-cyan-800'
      case 'IMPORT': return 'bg-indigo-100 text-indigo-800'
      case 'ADJUST': return 'bg-yellow-100 text-yellow-800'
      case 'TRANSFER': return 'bg-orange-100 text-orange-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getSeverityColor = (severity: string | undefined) => {
    switch (severity) {
      case 'critical': return 'bg-red-100 text-red-800'
      case 'high': return 'bg-orange-100 text-orange-800'
      case 'medium': return 'bg-yellow-100 text-yellow-800'
      case 'low': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getResultIcon = (result: string | undefined) => {
    switch (result) {
      case 'success': return '✓'
      case 'failed': return '✗'
      case 'partial': return '⚠'
      default: return '•'
    }
  }

  const handleExportPDF = () => {
    const exportData = filteredLogs.map(log => ({
      'Fecha': new Date(log.created_at).toLocaleString('es-MX'),
      'Usuario': log.user_name || log.user_email || 'Sistema',
      'Acción': log.action_type,
      'Entidad': log.entity_type,
      'Nombre': log.entity_name || 'N/A',
      'Resultado': log.result || 'N/A',
      'Severidad': log.severity || 'N/A',
      'Resumen': log.changes_summary || ''
    }))
    exportReportPDF(exportData, 'Auditoría', 'Sistema')
    toast.success('Reporte PDF generado')
  }

  const handleExportExcel = () => {
    const exportData = filteredLogs.map(log => ({
      'Fecha': new Date(log.created_at).toLocaleString('es-MX'),
      'Usuario': log.user_name || log.user_email || 'Sistema',
      'Acción': log.action_type,
      'Entidad': log.entity_type,
      'Nombre Entidad': log.entity_name || '',
      'Resultado': log.result || '',
      'Severidad': log.severity || '',
      'Resumen de Cambios': log.changes_summary || '',
      'Valores Anteriores': log.old_values ? JSON.stringify(log.old_values) : '',
      'Valores Nuevos': log.new_values ? JSON.stringify(log.new_values) : ''
    }))
    exportReportExcel(exportData, 'Auditoria', 'Sistema')
    toast.success('Reporte Excel generado')
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Registro de Auditoría</h1>
          <p className="text-gray-600 mt-1">Historial de acciones del sistema</p>
        </div>
        <div className="flex gap-2">
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
        </div>
      </div>

      {/* Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Registros</p>
              <p className="text-2xl font-bold text-gray-900">{logs.length}</p>
            </div>
            <Eye className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Creaciones</p>
              <p className="text-2xl font-bold text-green-600">
                {logs.filter(l => l.action_type === 'CREATE').length}
              </p>
            </div>
            <AlertCircle className="h-8 w-8 text-green-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Modificaciones</p>
              <p className="text-2xl font-bold text-blue-600">
                {logs.filter(l => l.action_type === 'UPDATE').length}
              </p>
            </div>
            <AlertCircle className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Eliminaciones</p>
              <p className="text-2xl font-bold text-red-600">
                {logs.filter(l => l.action_type === 'DELETE').length}
              </p>
            </div>
            <AlertCircle className="h-8 w-8 text-red-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Críticos</p>
              <p className="text-2xl font-bold text-red-600">
                {logs.filter(l => l.severity === 'critical').length}
              </p>
            </div>
            <AlertCircle className="h-8 w-8 text-red-600" />
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow-md space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
          <div className="lg:col-span-2">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por usuario, entidad..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          <div>
            <select
              value={filterAction}
              onChange={(e) => setFilterAction(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todas las acciones</option>
              <option value="CREATE">Crear</option>
              <option value="READ">Leer</option>
              <option value="UPDATE">Actualizar</option>
              <option value="DELETE">Eliminar</option>
              <option value="LOGIN">Login</option>
              <option value="LOGOUT">Logout</option>
              <option value="EXPORT">Exportar</option>
              <option value="IMPORT">Importar</option>
              <option value="ADJUST">Ajustar</option>
              <option value="TRANSFER">Transferir</option>
            </select>
          </div>

          <div>
            <select
              value={filterEntity}
              onChange={(e) => setFilterEntity(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todas las entidades</option>
              <option value="medication">Medicamento</option>
              <option value="user">Usuario</option>
              <option value="center">Centro</option>
              <option value="transfer">Transferencia</option>
              <option value="batch">Lote</option>
              <option value="catalog">Catálogo</option>
            </select>
          </div>

          <div>
            <select
              value={filterSeverity}
              onChange={(e) => setFilterSeverity(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todas las severidades</option>
              <option value="low">Baja</option>
              <option value="medium">Media</option>
              <option value="high">Alta</option>
              <option value="critical">Crítica</option>
            </select>
          </div>

          <div className="lg:col-span-2 grid grid-cols-2 gap-2">
            <input
              type="date"
              value={dateFrom}
              onChange={(e) => setDateFrom(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="Fecha desde"
            />
            <input
              type="date"
              value={dateTo}
              onChange={(e) => setDateTo(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="Fecha hasta"
            />
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="ml-auto text-sm text-gray-600">
            {filteredLogs.length} de {logs.length} registros
          </div>
          {(searchTerm || filterAction !== 'all' || filterEntity !== 'all' || filterSeverity !== 'all' || dateFrom || dateTo) && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                setSearchTerm('')
                setFilterAction('all')
                setFilterEntity('all')
                setFilterSeverity('all')
                setDateFrom('')
                setDateTo('')
              }}
            >
              Limpiar Filtros
            </Button>
          )}
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-500">Cargando...</p>
          </div>
        ) : filteredLogs.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64">
            <p className="text-gray-500 mb-2">No hay registros de auditoría</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha/Hora</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Usuario</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acción</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Entidad</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Descripción</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Resultado</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Severidad</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        {new Date(log.created_at).toLocaleDateString('es-MX')}
                      </div>
                      <div className="text-xs text-gray-500">
                        {new Date(log.created_at).toLocaleTimeString('es-MX')}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm font-medium text-gray-900">
                        {log.user_name || 'Sistema'}
                      </div>
                      <div className="text-xs text-gray-500">{log.user_email || '-'}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-semibold rounded ${getActionColor(log.action_type)}`}>
                        {log.action_type}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">{log.entity_type}</div>
                      <div className="text-xs text-gray-500">{log.entity_name || '-'}</div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900 max-w-md truncate">
                        {log.changes_summary || 'Sin descripción'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="text-lg">{getResultIcon(log.result)}</span>
                      <span className="ml-1 text-sm text-gray-600">{log.result || '-'}</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {log.severity ? (
                        <span className={`px-2 py-1 text-xs font-semibold rounded ${getSeverityColor(log.severity)}`}>
                          {log.severity}
                        </span>
                      ) : (
                        <span className="text-sm text-gray-400">-</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
