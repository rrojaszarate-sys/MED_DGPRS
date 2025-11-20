import { useState } from 'react'
import { Package, Search, Calendar, AlertCircle, CheckCircle } from 'lucide-react'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { useLotes } from '../hooks/useLotes'
import { useCentro } from '../context/CentroContext'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'

export function LotesPage() {
  const { centroSeleccionado } = useCentro()
  const { lotes, loading } = useLotes(centroSeleccionado?.id)
  const [searchTerm, setSearchTerm] = useState('')

  const filteredLotes = lotes.filter((lote) => {
    const searchLower = searchTerm.toLowerCase()
    return (
      lote.numero_lote.toLowerCase().includes(searchLower) ||
      (lote.medication_name && lote.medication_name.toLowerCase().includes(searchLower))
    )
  })

  const getEstadoBadge = (estado: string) => {
    const estados: Record<string, { color: string; icon: any }> = {
      disponible: { color: 'bg-green-100 text-green-800 border-green-200', icon: CheckCircle },
      cuarentena: { color: 'bg-yellow-100 text-yellow-800 border-yellow-200', icon: AlertCircle },
      vencido: { color: 'bg-red-100 text-red-800 border-red-200', icon: AlertCircle },
      agotado: { color: 'bg-gray-100 text-gray-800 border-gray-200', icon: Package },
    }

    const config = estados[estado] || estados.disponible
    const Icon = config.icon

    return (
      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium border ${config.color}`}>
        <Icon className="h-3 w-3" />
        {estado.charAt(0).toUpperCase() + estado.slice(1)}
      </span>
    )
  }

  const formatDate = (date: string | null | undefined) => {
    if (!date) return 'N/A'
    try {
      return format(new Date(date), 'dd MMM yyyy', { locale: es })
    } catch {
      return 'Fecha inválida'
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Gestión de Lotes</h1>
        <p className="text-gray-600 mt-1">
          Control y seguimiento de lotes de medicamentos
        </p>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Lotes</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{lotes.length}</p>
            </div>
            <Package className="h-10 w-10 text-blue-500" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Disponibles</p>
              <p className="text-3xl font-bold text-green-900 mt-2">
                {lotes.filter((l) => l.estado === 'disponible').length}
              </p>
            </div>
            <CheckCircle className="h-10 w-10 text-green-500" />
          </div>
        </Card>

        <Card className="bg-yellow-50 border-l-4 border-l-yellow-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-yellow-600">En Cuarentena</p>
              <p className="text-3xl font-bold text-yellow-900 mt-2">
                {lotes.filter((l) => l.estado === 'cuarentena').length}
              </p>
            </div>
            <AlertCircle className="h-10 w-10 text-yellow-500" />
          </div>
        </Card>

        <Card className="bg-red-50 border-l-4 border-l-red-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-red-600">Vencidos</p>
              <p className="text-3xl font-bold text-red-900 mt-2">
                {lotes.filter((l) => l.estado === 'vencido').length}
              </p>
            </div>
            <Calendar className="h-10 w-10 text-red-500" />
          </div>
        </Card>
      </div>

      {/* Search */}
      <Card>
        <div className="flex items-center gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              placeholder="Buscar por número de lote o medicamento..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>
      </Card>

      {/* Lotes Table */}
      <Card>
        <div className="overflow-x-auto">
          {loading ? (
            <div className="flex justify-center items-center h-64">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
          ) : filteredLotes.length === 0 ? (
            <div className="text-center py-12">
              <Package className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No hay lotes</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchTerm
                  ? 'No se encontraron lotes con ese criterio de búsqueda.'
                  : 'No hay lotes registrados en este centro.'}
              </p>
            </div>
          ) : (
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Número de Lote
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Medicamento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cantidad
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Fecha Fabricación
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Fecha Vencimiento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Estado
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredLotes.map((lote) => (
                  <tr key={lote.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {lote.numero_lote}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {lote.medication_name || 'Sin nombre'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {lote.cantidad_actual} / {lote.cantidad_inicial}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatDate(lote.fecha_fabricacion)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatDate(lote.fecha_vencimiento)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {getEstadoBadge(lote.estado)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </Card>
    </div>
  )
}
