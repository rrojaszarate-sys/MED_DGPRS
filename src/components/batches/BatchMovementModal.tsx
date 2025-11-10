import { useState, useEffect } from 'react'
import { X, TrendingUp, TrendingDown, RefreshCw, AlertTriangle, Trash2, ArrowRightLeft } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Badge } from '../ui/Badge'
import type { Batch, BatchMovement } from '../../types'
import { useAuth } from '../../context/AuthContext'
import { useCentro } from '../../context/CentroContext'

interface BatchMovementModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: Partial<BatchMovement>) => Promise<void>
  batch: Batch | null
}

export function BatchMovementModal({ isOpen, onClose, onSubmit, batch }: BatchMovementModalProps) {
  const { user } = useAuth()
  const { centroSeleccionado, centros } = useCentro()

  const [formData, setFormData] = useState({
    tipo_movimiento: '' as BatchMovement['tipo_movimiento'] | '',
    cantidad: 0,
    centro_destino_id: '',
    motivo: '',
    observaciones: ''
  })

  const [submitting, setSubmitting] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Reset form when closed
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        tipo_movimiento: '',
        cantidad: 0,
        centro_destino_id: '',
        motivo: '',
        observaciones: ''
      })
      setErrors({})
      setSubmitting(false)
    }
  }, [isOpen])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.tipo_movimiento) newErrors.tipo_movimiento = 'Tipo de movimiento es requerido'
    if (formData.cantidad <= 0) newErrors.cantidad = 'Cantidad debe ser mayor a 0'
    if (!batch) newErrors.batch = 'No hay lote seleccionado'

    // Validate quantity doesn't exceed current stock for salida/ajuste/etc
    if (batch && ['salida', 'ajuste', 'merma', 'transferencia_salida', 'destruccion'].includes(formData.tipo_movimiento)) {
      if (formData.cantidad > batch.cantidad_actual) {
        newErrors.cantidad = `Cantidad excede stock disponible (${batch.cantidad_actual})`
      }
    }

    if (formData.tipo_movimiento === 'transferencia_salida' && !formData.centro_destino_id) {
      newErrors.centro_destino_id = 'Centro destino es requerido para transferencias'
    }

    if (!formData.motivo.trim()) newErrors.motivo = 'Motivo es requerido'

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate() || !batch || !user) return

    setSubmitting(true)
    try {
      const submitData: Partial<BatchMovement> = {
        medication_id: batch.medication_id,
        tipo_movimiento: formData.tipo_movimiento as BatchMovement['tipo_movimiento'],
        cantidad: formData.cantidad,
        cantidad_anterior: batch.cantidad_actual,
        cantidad_posterior: calculateNewQuantity(),
        centro_origen_id: centroSeleccionado?.id,
        centro_destino_id: formData.centro_destino_id || null,
        motivo: formData.motivo,
        observaciones: formData.observaciones || null,
        usuario_responsable: user.id,
        metadata: {
          batch_id: batch.id,
          numero_lote: batch.numero_lote,
          user_name: user.full_name || user.email
        }
      }

      await onSubmit(submitData)
      onClose()
    } catch (error) {
      console.error('Error submitting movement:', error)
    } finally {
      setSubmitting(false)
    }
  }

  const calculateNewQuantity = () => {
    if (!batch) return 0

    const cantidad = formData.cantidad
    const current = batch.cantidad_actual

    switch (formData.tipo_movimiento) {
      case 'entrada':
      case 'transferencia_entrada':
      case 'devolucion':
        return current + cantidad
      case 'salida':
      case 'transferencia_salida':
      case 'vencimiento':
      case 'merma':
      case 'destruccion':
        return Math.max(0, current - cantidad)
      case 'ajuste':
        // For ajuste, the user specifies the new quantity
        return cantidad
      default:
        return current
    }
  }

  if (!isOpen || !batch) return null

  const movementTypes = [
    { value: 'entrada', label: 'Entrada', icon: TrendingUp, color: 'text-green-600', description: 'Recepción de nuevo stock' },
    { value: 'salida', label: 'Salida', icon: TrendingDown, color: 'text-blue-600', description: 'Dispensación o uso normal' },
    { value: 'ajuste', label: 'Ajuste de Inventario', icon: RefreshCw, color: 'text-yellow-600', description: 'Corrección de stock' },
    { value: 'transferencia_salida', label: 'Transferencia (Salida)', icon: ArrowRightLeft, color: 'text-purple-600', description: 'Envío a otro centro' },
    { value: 'transferencia_entrada', label: 'Transferencia (Entrada)', icon: ArrowRightLeft, color: 'text-purple-600', description: 'Recepción de otro centro' },
    { value: 'vencimiento', label: 'Vencimiento', icon: AlertTriangle, color: 'text-orange-600', description: 'Producto caducado' },
    { value: 'merma', label: 'Merma', icon: TrendingDown, color: 'text-red-600', description: 'Pérdida o deterioro' },
    { value: 'devolucion', label: 'Devolución', icon: TrendingUp, color: 'text-indigo-600', description: 'Retorno de producto' },
    { value: 'destruccion', label: 'Destrucción', icon: Trash2, color: 'text-red-700', description: 'Eliminación de producto' }
  ]

  const selectedType = movementTypes.find(t => t.value === formData.tipo_movimiento)
  const newQuantity = calculateNewQuantity()

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Registrar Movimiento</h2>
            <p className="text-sm text-gray-600 mt-1">
              Lote: <span className="font-mono font-semibold">{batch.numero_lote}</span>
            </p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        {/* Batch Info Card */}
        <div className="mx-6 mt-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
          <div className="grid grid-cols-3 gap-4 text-sm">
            <div>
              <p className="text-gray-500">Medicamento</p>
              <p className="font-semibold text-gray-900">{batch.medication?.nombre || 'N/A'}</p>
            </div>
            <div>
              <p className="text-gray-500">Stock Actual</p>
              <p className="font-semibold text-gray-900">{batch.cantidad_actual} unidades</p>
            </div>
            <div>
              <p className="text-gray-500">Estado</p>
              <Badge variant={batch.estado === 'disponible' ? 'success' : 'warning'}>
                {batch.estado}
              </Badge>
            </div>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Tipo de Movimiento */}
          <div className="space-y-3">
            <label className="block text-sm font-medium text-gray-700">
              Tipo de Movimiento <span className="text-red-500">*</span>
            </label>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {movementTypes.map((type) => {
                const Icon = type.icon
                const isSelected = formData.tipo_movimiento === type.value
                return (
                  <button
                    key={type.value}
                    type="button"
                    onClick={() => setFormData({ ...formData, tipo_movimiento: type.value as any })}
                    className={`p-3 border-2 rounded-lg text-left transition-all ${
                      isSelected
                        ? 'border-primary bg-primary-50'
                        : 'border-gray-200 hover:border-gray-300 bg-white'
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <Icon className={`h-5 w-5 mt-0.5 ${isSelected ? 'text-primary' : type.color}`} />
                      <div className="flex-1">
                        <p className={`font-medium ${isSelected ? 'text-primary' : 'text-gray-900'}`}>
                          {type.label}
                        </p>
                        <p className="text-xs text-gray-500 mt-0.5">{type.description}</p>
                      </div>
                    </div>
                  </button>
                )
              })}
            </div>
            {errors.tipo_movimiento && (
              <p className="text-red-500 text-xs">{errors.tipo_movimiento}</p>
            )}
          </div>

          {/* Cantidad */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cantidad <span className="text-red-500">*</span>
            </label>
            <Input
              type="number"
              min="1"
              value={formData.cantidad || ''}
              onChange={(e) => setFormData({ ...formData, cantidad: parseInt(e.target.value) || 0 })}
              placeholder={formData.tipo_movimiento === 'ajuste' ? 'Nueva cantidad total' : 'Cantidad a mover'}
              className={errors.cantidad ? 'border-red-500' : ''}
            />
            {errors.cantidad && (
              <p className="text-red-500 text-xs mt-1">{errors.cantidad}</p>
            )}
            {formData.cantidad > 0 && formData.tipo_movimiento && (
              <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                <p className="text-sm text-blue-900">
                  {formData.tipo_movimiento === 'ajuste' ? (
                    <>Nuevo stock: <span className="font-semibold">{newQuantity} unidades</span></>
                  ) : (
                    <>
                      Stock actual: {batch.cantidad_actual} → Nuevo stock: <span className="font-semibold">{newQuantity} unidades</span>
                    </>
                  )}
                </p>
              </div>
            )}
          </div>

          {/* Centro Destino (solo para transferencias) */}
          {formData.tipo_movimiento === 'transferencia_salida' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Centro de Destino <span className="text-red-500">*</span>
              </label>
              <select
                value={formData.centro_destino_id}
                onChange={(e) => setFormData({ ...formData, centro_destino_id: e.target.value })}
                className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent ${
                  errors.centro_destino_id ? 'border-red-500' : 'border-gray-300'
                }`}
              >
                <option value="">Seleccionar centro...</option>
                {centros
                  .filter(c => c.id !== centroSeleccionado?.id && c.is_active)
                  .map((centro) => (
                    <option key={centro.id} value={centro.id}>
                      {centro.name} - {centro.code}
                    </option>
                  ))}
              </select>
              {errors.centro_destino_id && (
                <p className="text-red-500 text-xs mt-1">{errors.centro_destino_id}</p>
              )}
            </div>
          )}

          {/* Motivo */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Motivo <span className="text-red-500">*</span>
            </label>
            <Input
              value={formData.motivo}
              onChange={(e) => setFormData({ ...formData, motivo: e.target.value })}
              placeholder={`Ej: ${selectedType?.description || 'Describir el motivo del movimiento'}`}
              className={errors.motivo ? 'border-red-500' : ''}
            />
            {errors.motivo && (
              <p className="text-red-500 text-xs mt-1">{errors.motivo}</p>
            )}
          </div>

          {/* Observaciones */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Observaciones
            </label>
            <textarea
              value={formData.observaciones}
              onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
              rows={3}
              placeholder="Información adicional sobre el movimiento..."
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent resize-none"
            />
          </div>

          {/* Info Footer */}
          <div className="p-3 bg-gray-50 border border-gray-200 rounded-lg text-xs text-gray-600">
            <p><strong>Usuario:</strong> {user?.full_name || user?.email}</p>
            <p className="mt-1"><strong>Centro:</strong> {centroSeleccionado?.name}</p>
            <p className="mt-1"><strong>Fecha:</strong> {new Date().toLocaleString('es-MX')}</p>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button type="submit" disabled={submitting}>
              {submitting ? 'Registrando...' : 'Registrar Movimiento'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
