import { useState, useEffect } from 'react'
import { X, Plus, Trash2 } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import type { Transfer, TransferItem } from '../../types'
import { useCatalogo } from '../../hooks/useCatalogo'
import { useCentros } from '../../hooks/useCentros'
import { useCentro } from '../../context/CentroContext'

interface TransferFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (transfer: Partial<Transfer>, items: Partial<TransferItem>[]) => Promise<void>
}

interface FormItem {
  tempId: string
  medication_id: string
  medication_name?: string
  cantidad_solicitada: number
  lote?: string
  fecha_caducidad?: string
}

export function TransferFormModal({ isOpen, onClose, onSubmit }: TransferFormModalProps) {
  const { catalogos } = useCatalogo()
  const { centros } = useCentros()
  const { centroSeleccionado } = useCentro()

  const [formData, setFormData] = useState({
    origin_center_id: '',
    destination_center_id: '',
    notes: ''
  })

  const [items, setItems] = useState<FormItem[]>([])
  const [submitting, setSubmitting] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Initialize with current center as origin
  useEffect(() => {
    if (centroSeleccionado && isOpen) {
      setFormData(prev => ({
        ...prev,
        origin_center_id: centroSeleccionado.id
      }))
    }
  }, [centroSeleccionado, isOpen])

  // Reset form when closed
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        origin_center_id: centroSeleccionado?.id || '',
        destination_center_id: '',
        notes: ''
      })
      setItems([])
      setErrors({})
      setSubmitting(false)
    }
  }, [isOpen, centroSeleccionado])

  const addItem = () => {
    setItems([
      ...items,
      {
        tempId: `temp-${Date.now()}`,
        medication_id: '',
        cantidad_solicitada: 1,
        lote: '',
        fecha_caducidad: ''
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

    if (!formData.origin_center_id) {
      newErrors.origin_center_id = 'Centro de origen es requerido'
    }
    if (!formData.destination_center_id) {
      newErrors.destination_center_id = 'Centro de destino es requerido'
    }
    if (formData.origin_center_id === formData.destination_center_id) {
      newErrors.destination_center_id = 'El centro de destino debe ser diferente al de origen'
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
    })

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return

    setSubmitting(true)
    try {
      const transferItems = items.map(item => ({
        medication_id: item.medication_id,
        cantidad_solicitada: item.cantidad_solicitada,
        lote: item.lote || undefined,
        fecha_caducidad: item.fecha_caducidad || undefined
      }))

      await onSubmit(formData, transferItems)
      onClose()
    } catch (error) {
      console.error('Error submitting transfer:', error)
    } finally {
      setSubmitting(false)
    }
  }

  if (!isOpen) return null

  const activeCatalogos = catalogos.filter(c => c.is_active)
  const availableCentros = centros.filter(c => c.is_active && c.id !== formData.origin_center_id)

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-2xl font-bold text-gray-900">
            Nueva Transferencia entre Centros
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
          {/* Section 1: Centers */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Centros de Salud
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Centro de Origen <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.origin_center_id}
                  onChange={(e) => setFormData({ ...formData, origin_center_id: e.target.value })}
                  className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent ${
                    errors.origin_center_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Seleccionar centro...</option>
                  {centros.filter(c => c.is_active).map((centro) => (
                    <option key={centro.id} value={centro.id}>
                      {centro.name} ({centro.code})
                    </option>
                  ))}
                </select>
                {errors.origin_center_id && (
                  <p className="text-red-500 text-xs mt-1">{errors.origin_center_id}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Centro de Destino <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.destination_center_id}
                  onChange={(e) => setFormData({ ...formData, destination_center_id: e.target.value })}
                  className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent ${
                    errors.destination_center_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Seleccionar centro...</option>
                  {availableCentros.map((centro) => (
                    <option key={centro.id} value={centro.id}>
                      {centro.name} ({centro.code})
                    </option>
                  ))}
                </select>
                {errors.destination_center_id && (
                  <p className="text-red-500 text-xs mt-1">{errors.destination_center_id}</p>
                )}
              </div>
            </div>
          </div>

          {/* Section 2: Items */}
          <div className="space-y-4">
            <div className="flex items-center justify-between border-b pb-2">
              <h3 className="text-lg font-semibold text-gray-900">
                Medicamentos a Transferir
              </h3>
              <Button type="button" onClick={addItem} size="sm">
                <Plus className="h-4 w-4 mr-2" />
                Agregar Medicamento
              </Button>
            </div>

            {errors.items && (
              <p className="text-red-500 text-sm">{errors.items}</p>
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
                          Lote (opcional)
                        </label>
                        <Input
                          value={item.lote || ''}
                          onChange={(e) => updateItem(item.tempId, 'lote', e.target.value)}
                          placeholder="Número de lote"
                        />
                      </div>

                      <div className="md:col-span-2">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Fecha de Caducidad (opcional)
                        </label>
                        <Input
                          type="date"
                          value={item.fecha_caducidad || ''}
                          onChange={(e) => updateItem(item.tempId, 'fecha_caducidad', e.target.value)}
                        />
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Section 3: Notes */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Notas Adicionales
            </h3>
            <div>
              <textarea
                value={formData.notes}
                onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                rows={3}
                placeholder="Notas sobre la transferencia, motivo, urgencia, etc..."
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
              {submitting ? 'Creando...' : 'Crear Transferencia'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
