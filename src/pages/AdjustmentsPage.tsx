import { useState } from 'react'
import {
  Calculator,
  Search,
  Plus,
  CheckCircle,
  AlertTriangle,
  FileText,
  Image,
  TrendingDown,
  TrendingUp,
  Minus
} from 'lucide-react'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { Button } from '../components/ui/Button'
import { useAdjustments } from '../hooks/useAdjustments'
import { useCentro } from '../context/CentroContext'
import type { InventoryAdjustment } from '../types'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'

export function AdjustmentsPage() {
  const { centroSeleccionado } = useCentro()
  const { adjustments, loading, authorizeAdjustment } = useAdjustments(centroSeleccionado?.id)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedType, setSelectedType] = useState<InventoryAdjustment['adjustment_type'] | 'all'>('all')
  const [showCreateModal, setShowCreateModal] = useState(false)

  const filteredAdjustments = adjustments.filter((adj) => {
    const searchLower = searchTerm.toLowerCase()
    const matchesSearch =
      adj.adjustment_number.toLowerCase().includes(searchLower) ||
      adj.motivo.toLowerCase().includes(searchLower) ||
      adj.medication?.nombre?.toLowerCase().includes(searchLower)

    const matchesType = selectedType === 'all' || adj.adjustment_type === selectedType

    return matchesSearch && matchesType
  })

  const getTypeBadge = (type: InventoryAdjustment['adjustment_type']) => {
    const typeConfig: Record<InventoryAdjustment['adjustment_type'], { color: string; icon: any; label: string }> = {
      merma: { color: 'bg-red-100 text-red-800 border-red-200', icon: TrendingDown, label: 'Merma' },
      correccion: { color: 'bg-blue-100 text-blue-800 border-blue-200', icon: Calculator, label: 'Corrección' },
      devolucion: { color: 'bg-yellow-100 text-yellow-800 border-yellow-200', icon: Minus, label: 'Devolución' },
      reclasificacion: { color: 'bg-purple-100 text-purple-800 border-purple-200', icon: FileText, label: 'Reclasificación' },
    }

    const config = typeConfig[type]
    const Icon = config.icon

    return (
      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium border ${config.color}`}>
        <Icon className="h-3 w-3" />
        {config.label}
      </span>
    )
  }

  const getDifferenceDisplay = (diff: number) => {
    if (diff === 0) {
      return (
        <span className="inline-flex items-center gap-1 text-gray-600">
          <Minus className="h-4 w-4" />
          Sin diferencia
        </span>
      )
    } else if (diff > 0) {
      return (
        <span className="inline-flex items-center gap-1 text-green-600 font-medium">
          <TrendingUp className="h-4 w-4" />
          +{diff}
        </span>
      )
    } else {
      return (
        <span className="inline-flex items-center gap-1 text-red-600 font-medium">
          <TrendingDown className="h-4 w-4" />
          {diff}
        </span>
      )
    }
  }

  const formatDate = (date: string | null | undefined) => {
    if (!date) return 'N/A'
    try {
      return format(new Date(date), 'dd MMM yyyy HH:mm', { locale: es })
    } catch {
      return 'Fecha inválida'
    }
  }

  const handleAuthorize = async (id: string) => {
    if (window.confirm('¿Confirmar autorización de este ajuste?')) {
      await authorizeAdjustment(id)
    }
  }

  const stats = {
    total: adjustments.length,
    mermas: adjustments.filter(a => a.adjustment_type === 'merma').length,
    correcciones: adjustments.filter(a => a.adjustment_type === 'correccion').length,
    pendientes: adjustments.filter(a => !a.autorizado_por).length,
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Ajustes de Inventario</h1>
          <p className="text-gray-600 mt-1">
            Gestión de mermas, correcciones y ajustes de inventario
          </p>
        </div>
        <Button onClick={() => setShowCreateModal(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Nuevo Ajuste
        </Button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Ajustes</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{stats.total}</p>
            </div>
            <Calculator className="h-10 w-10 text-blue-500" />
          </div>
        </Card>

        <Card className="bg-red-50 border-l-4 border-l-red-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-red-600">Mermas</p>
              <p className="text-3xl font-bold text-red-900 mt-2">{stats.mermas}</p>
            </div>
            <TrendingDown className="h-10 w-10 text-red-500" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Correcciones</p>
              <p className="text-3xl font-bold text-green-900 mt-2">{stats.correcciones}</p>
            </div>
            <CheckCircle className="h-10 w-10 text-green-500" />
          </div>
        </Card>

        <Card className="bg-yellow-50 border-l-4 border-l-yellow-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-yellow-600">Pendientes Autorización</p>
              <p className="text-3xl font-bold text-yellow-900 mt-2">{stats.pendientes}</p>
            </div>
            <AlertTriangle className="h-10 w-10 text-yellow-500" />
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              type="text"
              placeholder="Buscar por número, motivo o medicamento..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
          <select
            value={selectedType}
            onChange={(e) => setSelectedType(e.target.value as any)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="all">Todos los tipos</option>
            <option value="merma">Mermas</option>
            <option value="correccion">Correcciones</option>
            <option value="devolucion">Devoluciones</option>
            <option value="reclasificacion">Reclasificaciones</option>
          </select>
        </div>
      </Card>

      {/* Adjustments List */}
      {loading ? (
        <Card>
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="text-gray-600 mt-4">Cargando ajustes...</p>
          </div>
        </Card>
      ) : filteredAdjustments.length === 0 ? (
        <Card>
          <div className="text-center py-12">
            <Calculator className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600">No se encontraron ajustes</p>
          </div>
        </Card>
      ) : (
        <div className="space-y-4">
          {filteredAdjustments.map((adjustment) => (
            <Card key={adjustment.id} className="hover:shadow-lg transition-shadow">
              <div className="space-y-4">
                {/* Header */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="bg-blue-100 p-3 rounded-lg">
                      <Calculator className="h-6 w-6 text-blue-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-lg text-gray-900">
                        {adjustment.adjustment_number}
                      </h3>
                      <p className="text-sm text-gray-600">
                        Creado: {formatDate(adjustment.created_at)}
                      </p>
                    </div>
                  </div>
                  {getTypeBadge(adjustment.adjustment_type)}
                </div>

                {/* Medication */}
                {adjustment.medication && (
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <p className="text-xs text-gray-500 mb-1">Medicamento</p>
                    <p className="font-medium text-gray-900">
                      {adjustment.medication.nombre}
                    </p>
                    <p className="text-sm text-gray-600">
                      {adjustment.medication.formula_activa}
                    </p>
                  </div>
                )}

                {/* Quantities */}
                <div className="grid grid-cols-3 gap-4 bg-blue-50 p-4 rounded-lg">
                  <div>
                    <p className="text-xs text-gray-600 mb-1">Cantidad Sistema</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {adjustment.cantidad_sistema}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 mb-1">Cantidad Física</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {adjustment.cantidad_fisica}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 mb-1">Diferencia</p>
                    <div className="text-2xl font-bold">
                      {getDifferenceDisplay(adjustment.diferencia || 0)}
                    </div>
                  </div>
                </div>

                {/* Motivo y Justificación */}
                <div className="space-y-2">
                  <div>
                    <p className="text-xs font-medium text-gray-500 mb-1">Motivo</p>
                    <p className="text-sm text-gray-900">{adjustment.motivo}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-gray-500 mb-1">Justificación</p>
                    <p className="text-sm text-gray-900">{adjustment.justificacion}</p>
                  </div>
                </div>

                {/* Evidence */}
                {adjustment.evidencia_fotografica && adjustment.evidencia_fotografica.length > 0 && (
                  <div className="border-t pt-4">
                    <p className="text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                      <Image className="h-4 w-4" />
                      Evidencia fotográfica ({adjustment.evidencia_fotografica.length})
                    </p>
                    <div className="grid grid-cols-3 gap-2">
                      {adjustment.evidencia_fotografica.map((url, idx) => (
                        <a
                          key={idx}
                          href={url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="aspect-square bg-gray-100 rounded-lg overflow-hidden hover:opacity-80 transition-opacity"
                        >
                          <img
                            src={url}
                            alt={`Evidencia ${idx + 1}`}
                            className="w-full h-full object-cover"
                          />
                        </a>
                      ))}
                    </div>
                  </div>
                )}

                {/* Authorization Status */}
                {adjustment.autorizado_por ? (
                  <div className="bg-green-50 p-3 rounded-lg">
                    <div className="flex items-center gap-2 text-green-700">
                      <CheckCircle className="h-4 w-4" />
                      <span className="text-sm font-medium">
                        Autorizado el {formatDate(adjustment.autorizado_en)}
                      </span>
                    </div>
                    {adjustment.authorizer && (
                      <p className="text-xs text-green-600 mt-1">
                        Por: {adjustment.authorizer.full_name || adjustment.authorizer.email}
                      </p>
                    )}
                  </div>
                ) : (
                  <div className="bg-yellow-50 p-3 rounded-lg flex items-center justify-between">
                    <div className="flex items-center gap-2 text-yellow-700">
                      <AlertTriangle className="h-4 w-4" />
                      <span className="text-sm font-medium">Pendiente de autorización</span>
                    </div>
                    <Button
                      onClick={() => handleAuthorize(adjustment.id)}
                      size="sm"
                      className="bg-green-600 hover:bg-green-700"
                    >
                      <CheckCircle className="h-4 w-4 mr-2" />
                      Autorizar
                    </Button>
                  </div>
                )}

                {/* Creator */}
                {adjustment.creator && (
                  <p className="text-xs text-gray-500">
                    Creado por: {adjustment.creator.full_name || adjustment.creator.email}
                  </p>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* TODO: Create Adjustment Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Nuevo Ajuste de Inventario</h2>
              <button
                onClick={() => setShowCreateModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <Plus className="h-6 w-6 transform rotate-45" />
              </button>
            </div>
            <p className="text-gray-600 text-center py-8">
              Formulario de creación de ajuste en construcción...
            </p>
          </Card>
        </div>
      )}
    </div>
  )
}
