import { useState, useEffect } from 'react'
import { X, Plus, Trash2, AlertCircle } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import type { Requisition, RequisitionItem } from '../../types'
import { useCatalogo } from '../../hooks/useCatalogo'
import { useCentro } from '../../context/CentroContext'

interface RequisitionFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (requisition: Partial<Requisition>, items: Partial<RequisitionItem>[]) => Promise<void>
}

interface FormItem {
  tempId: string
  medication_id: string
  medication_name?: string
  cantidad_solicitada: number
  justificacion: string
}

export function RequisitionFormModal({ isOpen, onClose, onSubmit }: RequisitionFormModalProps) {
  const { catalogos } = useCatalogo()
  const { centroSeleccionado } = useCentro()

  const [formData, setFormData] = useState({
    requesting_service: '',
    fecha_necesaria: '',
    prioridad: 'normal' as 'normal' | 'urgente' | 'emergencia',
    observaciones: ''
  })

  const [items, setItems] = useState<FormItem[]>([])
  const [submitting, setSubmitting] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Reset form when closed
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        requesting_service: '',
        fecha_necesaria: '',
        prioridad: 'normal',
        observaciones: ''
      })
      setItems([])
      setErrors({})
      setSubmitting(false)
    }
  }, [isOpen])

  const addItem = () => {
    setItems([
      ...items,
      {
        tempId: `temp-${Date.now()}`,
        medication_id: '',
        cantidad_solicitada: 1,
        justificacion: ''
      }
    ])
  }

  const removeItem = (tempId: string) => {
    setItems(items.filter(item => item.tempId !== tempId))
  }

  const updateItem = (tempId: string, field: keyof FormItem, value: any) => {
    setItems(items.map(item => {
      if (item.tempId === tempId) {
        const updated = { ...item, [field]: value }

        // If changing medication, update medication name
        if (field === 'medication_id') {
          const catalog = catalogos.find(c => c.id === value)
          updated.medication_name = catalog?.nombre_generico || ''
        }

        return updated
      }
      return item
    }))
  }

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.requesting_service.trim()) {
      newErrors.requesting_service = 'Servicio solicitante es requerido'
    }
    if (items.length === 0) {
      newErrors.items = 'Debe agregar al menos un medicamento'
    }

    // Validate items
    items.forEach((item, index) => {
      if (!item.medication_id) {
        newErrors[`item_${index}_medication`] = 'Medicamento es requerido'
      }
      if (item.cantidad_solicitada <= 0) {
        newErrors[`item_${index}_cantidad`] = 'Cantidad debe ser mayor a 0'
      }
      if (!item.justificacion.trim()) {
        newErrors[`item_${index}_justificacion`] = 'Justificación es requerida'
      }
    })

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return

    setSubmitting(true)
    try {
      const requisitionItems = items.map(item => ({
        medication_id: item.medication_id,
        cantidad_solicitada: item.cantidad_solicitada,
        justificacion: item.justificacion
      }))

      await onSubmit(formData, requisitionItems)
      onClose()
    } catch (error) {
      console.error('Error submitting requisition:', error)
    } finally {
      setSubmitting(false)
    }
  }

  if (!isOpen) return null

  const activeCatalogos = catalogos.filter(c => c.is_active)

  const getPriorityBadge = (priority: string) => {
    const config: Record<string, { color: string; label: string }> = {
      normal: { color: 'bg-green-100 text-green-800 border-green-200', label: 'Normal' },
      urgente: { color: 'bg-yellow-100 text-yellow-800 border-yellow-200', label: 'Urgente' },
      emergencia: { color: 'bg-red-100 text-red-800 border-red-200', label: 'Emergencia' }
    }
    return config[priority] || config.normal
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-2xl font-bold text-gray-900">
            Nueva Requisición Interna
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Section 1: General Info */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Información General
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Servicio/Departamento Solicitante <span className="text-red-500">*</span>
                </label>
                <Input
                  value={formData.requesting_service}
                  onChange={(e) => setFormData({ ...formData, requesting_service: e.target.value })}
                  placeholder="Ej: Urgencias, Consulta Externa, Hospitalización..."
                  className={errors.requesting_service ? 'border-red-500' : ''}
                />
                {errors.requesting_service && (
                  <p className="text-red-500 text-xs mt-1">{errors.requesting_service}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Prioridad
                </label>
                <select
                  value={formData.prioridad}
                  onChange={(e) => setFormData({ ...formData, prioridad: e.target.value as any })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="normal">🟢 Normal</option>
                  <option value="urgente">🟡 Urgente</option>
                  <option value="emergencia">🔴 Emergencia</option>
                </select>
              </div>

              <div className="md:col-span-3">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha Necesaria
                </label>
                <Input
                  type="date"
                  value={formData.fecha_necesaria}
                  onChange={(e) => setFormData({ ...formData, fecha_necesaria: e.target.value })}
                />
                <p className="text-xs text-gray-500 mt-1">
                  Opcional: Fecha en la que se necesitan los medicamentos
                </p>
              </div>
            </div>
          </div>

          {/* Section 2: Items */}
          <div className="space-y-4">
            <div className="flex items-center justify-between border-b pb-2">
              <h3 className="text-lg font-semibold text-gray-900">
                Medicamentos Solicitados
              </h3>
              <Button type="button" onClick={addItem} size="sm">
                <Plus className="h-4 w-4 mr-2" />
                Agregar Medicamento
              </Button>
            </div>

            {errors.items && (
              <p className="text-red-500 text-sm flex items-center gap-2">
                <AlertCircle className="h-4 w-4" />
                {errors.items}
              </p>
            )}

            <div className="space-y-3">
              {items.length === 0 ? (
                <div className="text-center py-8 bg-gray-50 rounded-lg">
                  <p className="text-gray-500 mb-2">No hay medicamentos agregados</p>
                  <p className="text-sm text-gray-400">Haz clic en "Agregar Medicamento" para comenzar</p>
                </div>
              ) : (
                items.map((item, index) => (
                  <div key={item.tempId} className="bg-gray-50 p-4 rounded-lg space-y-3">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm font-medium text-gray-700">
                        Medicamento #{index + 1}
                      </span>
                      <button
                        type="button"
                        onClick={() => removeItem(item.tempId)}
                        className="text-red-600 hover:text-red-800"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <div className="md:col-span-2">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Medicamento <span className="text-red-500">*</span>
                        </label>
                        <select
                          value={item.medication_id}
                          onChange={(e) => updateItem(item.tempId, 'medication_id', e.target.value)}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent ${
                            errors[`item_${index}_medication`] ? 'border-red-500' : 'border-gray-300'
                          }`}
                        >
                          <option value="">Seleccionar medicamento...</option>
                          {activeCatalogos.map((cat) => (
                            <option key={cat.id} value={cat.id}>
                              {cat.nombre_generico}
                              {cat.concentracion ? ` - ${cat.concentracion}` : ''}
                              {cat.forma_farmaceutica ? ` (${cat.forma_farmaceutica})` : ''}
                            </option>
                          ))}
                        </select>
                        {errors[`item_${index}_medication`] && (
                          <p className="text-red-500 text-xs mt-1">{errors[`item_${index}_medication`]}</p>
                        )}
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Cantidad Solicitada <span className="text-red-500">*</span>
                        </label>
                        <Input
                          type="number"
                          min="1"
                          value={item.cantidad_solicitada}
                          onChange={(e) => updateItem(item.tempId, 'cantidad_solicitada', parseInt(e.target.value) || 0)}
                          className={errors[`item_${index}_cantidad`] ? 'border-red-500' : ''}
                        />
                        {errors[`item_${index}_cantidad`] && (
                          <p className="text-red-500 text-xs mt-1">{errors[`item_${index}_cantidad`]}</p>
                        )}
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Justificación <span className="text-red-500">*</span>
                        </label>
                        <Input
                          value={item.justificacion}
                          onChange={(e) => updateItem(item.tempId, 'justificacion', e.target.value)}
                          placeholder="Motivo de la solicitud..."
                          className={errors[`item_${index}_justificacion`] ? 'border-red-500' : ''}
                        />
                        {errors[`item_${index}_justificacion`] && (
                          <p className="text-red-500 text-xs mt-1">{errors[`item_${index}_justificacion`]}</p>
                        )}
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Section 3: Observations */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Observaciones Adicionales
            </h3>
            <div>
              <textarea
                value={formData.observaciones}
                onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
                rows={3}
                placeholder="Notas adicionales sobre la requisición..."
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent resize-none"
              />
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button type="submit" disabled={submitting}>
              {submitting ? 'Creando...' : 'Crear Requisición'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
