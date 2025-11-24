import {
  TrendingUp,
  TrendingDown,
  RefreshCw,
  AlertTriangle,
  Trash2,
  ArrowRightLeft,
  Package,
  User,
  Calendar,
  Hash
} from 'lucide-react'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { Badge } from '../ui/Badge'

interface Movement {
  id: string
  tipo_movimiento: string
  cantidad: number
  cantidad_anterior: number
  cantidad_posterior: number
  motivo: string
  observaciones?: string
  usuario_responsable: string
  created_at: string
  centro_origen?: { name?: string; nombre?: string; code?: string; codigo?: string }
  centro_destino?: { name?: string; nombre?: string; code?: string; codigo?: string }
  medication?: { nombre: string; categoria?: string }
  medicamento?: { nombre: string; categoria?: string }
  batch?: { numero_lote: string }
  lote?: { numero_lote: string }
  metadata?: any
}

interface MovementTimelineProps {
  movements: Movement[]
  loading?: boolean
}

export function MovementTimeline({ movements, loading }: MovementTimelineProps) {
  const getMovementIcon = (tipo: string) => {
    switch (tipo) {
      case 'entrada':
      case 'transferencia_entrada':
      case 'devolucion':
        return TrendingUp
      case 'salida':
      case 'transferencia_salida':
        return TrendingDown
      case 'ajuste':
        return RefreshCw
      case 'vencimiento':
        return AlertTriangle
      case 'merma':
        return TrendingDown
      case 'destruccion':
        return Trash2
      default:
        return Package
    }
  }

  const getMovementColor = (tipo: string) => {
    switch (tipo) {
      case 'entrada':
      case 'transferencia_entrada':
      case 'devolucion':
        return 'text-green-600 bg-green-100'
      case 'salida':
        return 'text-blue-600 bg-blue-100'
      case 'transferencia_salida':
        return 'text-purple-600 bg-purple-100'
      case 'ajuste':
        return 'text-yellow-600 bg-yellow-100'
      case 'vencimiento':
        return 'text-orange-600 bg-orange-100'
      case 'merma':
      case 'destruccion':
        return 'text-red-600 bg-red-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  const getMovementLabel = (tipo: string) => {
    const labels: Record<string, string> = {
      entrada: 'Entrada',
      salida: 'Salida',
      ajuste: 'Ajuste',
      transferencia_salida: 'Transferencia Salida',
      transferencia_entrada: 'Transferencia Entrada',
      vencimiento: 'Vencimiento',
      merma: 'Merma',
      devolucion: 'Devolución',
      destruccion: 'Destrucción'
    }
    return labels[tipo] || tipo
  }

  const getQuantityChange = (movement: Movement) => {
    const diff = movement.cantidad_posterior - movement.cantidad_anterior
    if (diff > 0) return `+${diff}`
    return diff.toString()
  }

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (movements.length === 0) {
    return (
      <div className="text-center py-12 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
        <Package className="mx-auto h-12 w-12 text-gray-400 mb-4" />
        <p className="text-gray-500 text-lg">No hay movimientos registrados</p>
        <p className="text-gray-400 text-sm mt-2">Los movimientos aparecerán aquí cuando se registren</p>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {movements.map((movement, index) => {
        const Icon = getMovementIcon(movement.tipo_movimiento)
        const colorClass = getMovementColor(movement.tipo_movimiento)
        const isLastItem = index === movements.length - 1

        return (
          <div key={movement.id} className="relative">
            {/* Timeline line */}
            {!isLastItem && (
              <div className="absolute left-6 top-14 bottom-0 w-0.5 bg-gray-200" style={{ marginBottom: '-1rem' }} />
            )}

            {/* Movement card */}
            <div className="flex gap-4">
              {/* Icon */}
              <div className={`flex-shrink-0 h-12 w-12 rounded-full ${colorClass} flex items-center justify-center z-10`}>
                <Icon className="h-6 w-6" />
              </div>

              {/* Content */}
              <div className="flex-1 bg-white rounded-lg shadow-md border border-gray-200 p-4 hover:shadow-lg transition-shadow">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="text-lg font-semibold text-gray-900">
                        {getMovementLabel(movement.tipo_movimiento)}
                      </h3>
                      <Badge
                        variant={
                          movement.tipo_movimiento.includes('entrada') || movement.tipo_movimiento === 'devolucion'
                            ? 'success'
                            : movement.tipo_movimiento.includes('salida') || movement.tipo_movimiento.includes('destruccion')
                            ? 'danger'
                            : 'default'
                        }
                        size="sm"
                      >
                        {getQuantityChange(movement)} unidades
                      </Badge>
                    </div>
                    <p className="text-sm text-gray-600">{movement.motivo}</p>
                  </div>

                  {/* Timestamp */}
                  <div className="text-right text-sm text-gray-500">
                    <div className="flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      {format(new Date(movement.created_at), "d 'de' MMMM, yyyy", { locale: es })}
                    </div>
                    <div className="text-xs mt-1">
                      {format(new Date(movement.created_at), 'HH:mm:ss')}
                    </div>
                  </div>
                </div>

                {/* Details Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-3">
                  {/* Medication */}
                  {movement.medication && (
                    <div>
                      <p className="text-xs text-gray-500 mb-1">Medicamento</p>
                      <div className="flex items-center gap-1">
                        <Package className="h-4 w-4 text-gray-400" />
                        <p className="text-sm font-medium text-gray-900">{movement.medication.nombre}</p>
                      </div>
                      {movement.medication.categoria && (
                        <p className="text-xs text-gray-500">{movement.medication.categoria}</p>
                      )}
                    </div>
                  )}

                  {/* Batch */}
                  {movement.batch && (
                    <div>
                      <p className="text-xs text-gray-500 mb-1">Lote</p>
                      <div className="flex items-center gap-1">
                        <Hash className="h-4 w-4 text-gray-400" />
                        <p className="text-sm font-mono font-medium text-gray-900">{movement.batch.numero_lote}</p>
                      </div>
                    </div>
                  )}

                  {/* Stock Change */}
                  <div>
                    <p className="text-xs text-gray-500 mb-1">Cambio de Stock</p>
                    <p className="text-sm font-medium text-gray-900">
                      {movement.cantidad_anterior} → {movement.cantidad_posterior}
                    </p>
                    <p className="text-xs text-gray-500">
                      {movement.tipo_movimiento === 'ajuste' ? 'Ajustado' : `${movement.cantidad} unidades`}
                    </p>
                  </div>

                  {/* User */}
                  <div>
                    <p className="text-xs text-gray-500 mb-1">Usuario</p>
                    <div className="flex items-center gap-1">
                      <User className="h-4 w-4 text-gray-400" />
                      <p className="text-sm font-medium text-gray-900">
                        {movement.metadata?.user_name || 'Sistema'}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Transfer Info */}
                {(movement.centro_origen || movement.centro_destino) && (
                  <div className="flex items-center gap-3 p-2 bg-purple-50 rounded border border-purple-200">
                    {movement.centro_origen && (
                      <div className="flex items-center gap-1">
                        <span className="text-xs text-purple-600">Origen:</span>
                        <span className="text-sm font-medium text-purple-900">
                          {movement.centro_origen.nombre || movement.centro_origen.name} ({movement.centro_origen.codigo || movement.centro_origen.code})
                        </span>
                      </div>
                    )}
                    {movement.centro_origen && movement.centro_destino && (
                      <ArrowRightLeft className="h-4 w-4 text-purple-600" />
                    )}
                    {movement.centro_destino && (
                      <div className="flex items-center gap-1">
                        <span className="text-xs text-purple-600">Destino:</span>
                        <span className="text-sm font-medium text-purple-900">
                          {movement.centro_destino.nombre || movement.centro_destino.name} ({movement.centro_destino.codigo || movement.centro_destino.code})
                        </span>
                      </div>
                    )}
                  </div>
                )}

                {/* Observaciones */}
                {movement.observaciones && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <p className="text-xs text-gray-500 mb-1">Observaciones</p>
                    <p className="text-sm text-gray-700">{movement.observaciones}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )
      })}
    </div>
  )
}
