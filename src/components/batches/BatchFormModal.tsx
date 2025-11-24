import { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import type { Batch } from '../../types'
import { useCatalogo } from '../../hooks/useCatalogo'
import { useSuppliers } from '../../hooks/useSuppliers'
import { useCentro } from '../../context/CentroContext'

interface BatchFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: Partial<Batch>) => Promise<void>
  batch?: Batch | null
}

export function BatchFormModal({ isOpen, onClose, onSubmit, batch }: BatchFormModalProps) {
  const { catalogos } = useCatalogo()
  const { suppliers } = useSuppliers()
  const { centroSeleccionado } = useCentro()

  const [formData, setFormData] = useState({
    medication_id: '',
    center_id: '',
    supplier_id: '',
    numero_lote: '',
    cantidad_inicial: 0,
    cantidad_actual: 0,
    fecha_fabricacion: '',
    fecha_caducidad: '',
    fecha_ingreso: new Date().toISOString().split('T')[0],
    ubicacion_fisica: '',
    temperatura_almacenamiento: '',
    stock_minimo: 0,
    stock_maximo: 0,
    estado: 'disponible' as 'disponible' | 'cuarentena' | 'vencido' | 'agotado',
    observaciones: ''
  })

  const [submitting, setSubmitting] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Populate form when editing
  useEffect(() => {
    if (batch) {
      setFormData({
        medication_id: batch.medication_id,
        center_id: batch.center_id,
        supplier_id: batch.supplier_id || '',
        numero_lote: batch.numero_lote,
        cantidad_inicial: batch.cantidad_inicial,
        cantidad_actual: batch.cantidad_actual,
        fecha_fabricacion: batch.fecha_fabricacion?.split('T')[0] || '',
        fecha_caducidad: batch.fecha_caducidad.split('T')[0],
        fecha_ingreso: batch.fecha_ingreso.split('T')[0],
        ubicacion_fisica: batch.ubicacion_fisica || '',
        temperatura_almacenamiento: batch.temperatura_almacenamiento || '',
        stock_minimo: batch.stock_minimo,
        stock_maximo: batch.stock_maximo || 0,
        estado: batch.estado,
        observaciones: batch.observaciones || ''
      })
    } else if (centroSeleccionado) {
      setFormData(prev => ({
        ...prev,
        center_id: centroSeleccionado.id,
        fecha_ingreso: new Date().toISOString().split('T')[0]
      }))
    }
  }, [batch, centroSeleccionado])

  // Reset form when closed
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        medication_id: '',
        center_id: centroSeleccionado?.id || '',
        supplier_id: '',
        numero_lote: '',
        cantidad_inicial: 0,
        cantidad_actual: 0,
        fecha_fabricacion: '',
        fecha_caducidad: '',
        fecha_ingreso: new Date().toISOString().split('T')[0],
        ubicacion_fisica: '',
        temperatura_almacenamiento: '',
        stock_minimo: 0,
        stock_maximo: 0,
        estado: 'disponible',
        observaciones: ''
      })
      setErrors({})
      setSubmitting(false)
    }
  }, [isOpen, centroSeleccionado])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.medication_id) newErrors.medication_id = 'Medicamento es requerido'
    if (!formData.numero_lote.trim()) newErrors.numero_lote = 'Número de lote es requerido'
    if (formData.cantidad_inicial <= 0) newErrors.cantidad_inicial = 'Cantidad inicial debe ser mayor a 0'
    if (!batch && formData.cantidad_actual <= 0) newErrors.cantidad_actual = 'Cantidad actual debe ser mayor a 0'
    if (!formData.fecha_caducidad) newErrors.fecha_caducidad = 'Fecha de caducidad es requerida'
    if (formData.fecha_caducidad && formData.fecha_caducidad <= new Date().toISOString().split('T')[0]) {
      newErrors.fecha_caducidad = 'Fecha de caducidad debe ser futura'
    }
    if (formData.stock_minimo < 0) newErrors.stock_minimo = 'Stock mínimo no puede ser negativo'
    if (formData.stock_maximo && formData.stock_maximo < formData.stock_minimo) {
      newErrors.stock_maximo = 'Stock máximo debe ser mayor o igual al mínimo'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return

    setSubmitting(true)
    try {
      // If creating new batch, cantidad_actual should equal cantidad_inicial
      const submitData = {
        ...formData,
        cantidad_actual: batch ? formData.cantidad_actual : formData.cantidad_inicial,
        supplier_id: formData.supplier_id || undefined
      }
      await onSubmit(submitData)
      onClose()
    } catch (error) {
      console.error('Error submitting batch:', error)
    } finally {
      setSubmitting(false)
    }
  }

  if (!isOpen) return null

  const activeCatalogos = catalogos.filter(c => c.is_active)
  const activeSuppliers = suppliers.filter(s => s.is_active)

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-2xl font-bold text-gray-900">
            {batch ? 'Editar Lote' : 'Agregar Nuevo Lote'}
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
          {/* Sección 1: Información del Medicamento */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Información del Medicamento
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Medicamento <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.medication_id}
                  onChange={(e) => setFormData({ ...formData, medication_id: e.target.value })}
                  className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent ${
                    errors.medication_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                  disabled={!!batch}
                >
                  <option value="">Seleccionar medicamento...</option>
                  {activeCatalogos.map((cat) => (
                    <option key={cat.id} value={cat.id}>
                      {cat.nombre_generico} - {cat.clave_cuadro || cat.codigo_atc || ''}
                      {cat.dosis ? ` (${cat.dosis})` : ''}
                    </option>
                  ))}
                </select>
                {errors.medication_id && (
                  <p className="text-red-500 text-xs mt-1">{errors.medication_id}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Proveedor
                </label>
                <select
                  value={formData.supplier_id}
                  onChange={(e) => setFormData({ ...formData, supplier_id: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="">Sin proveedor</option>
                  {activeSuppliers.map((sup) => (
                    <option key={sup.id} value={sup.id}>
                      {sup.nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Número de Lote <span className="text-red-500">*</span>
                </label>
                <Input
                  value={formData.numero_lote}
                  onChange={(e) => setFormData({ ...formData, numero_lote: e.target.value.toUpperCase() })}
                  placeholder="Ej: LOTE-2024-001"
                  className={errors.numero_lote ? 'border-red-500' : ''}
                />
                {errors.numero_lote && (
                  <p className="text-red-500 text-xs mt-1">{errors.numero_lote}</p>
                )}
              </div>
            </div>
          </div>

          {/* Sección 2: Cantidades */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Cantidades y Stock
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cantidad Inicial <span className="text-red-500">*</span>
                </label>
                <Input
                  type="number"
                  min="1"
                  value={formData.cantidad_inicial}
                  onChange={(e) => setFormData({
                    ...formData,
                    cantidad_inicial: parseInt(e.target.value) || 0,
                    cantidad_actual: batch ? formData.cantidad_actual : parseInt(e.target.value) || 0
                  })}
                  disabled={!!batch}
                  className={errors.cantidad_inicial ? 'border-red-500' : ''}
                />
                {errors.cantidad_inicial && (
                  <p className="text-red-500 text-xs mt-1">{errors.cantidad_inicial}</p>
                )}
              </div>

              {batch && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cantidad Actual <span className="text-red-500">*</span>
                  </label>
                  <Input
                    type="number"
                    min="0"
                    value={formData.cantidad_actual}
                    onChange={(e) => setFormData({ ...formData, cantidad_actual: parseInt(e.target.value) || 0 })}
                    className={errors.cantidad_actual ? 'border-red-500' : ''}
                    disabled
                  />
                  <p className="text-xs text-gray-500 mt-1">
                    Use movimientos para cambiar el stock
                  </p>
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stock Mínimo <span className="text-red-500">*</span>
                </label>
                <Input
                  type="number"
                  min="0"
                  value={formData.stock_minimo}
                  onChange={(e) => setFormData({ ...formData, stock_minimo: parseInt(e.target.value) || 0 })}
                  className={errors.stock_minimo ? 'border-red-500' : ''}
                />
                {errors.stock_minimo && (
                  <p className="text-red-500 text-xs mt-1">{errors.stock_minimo}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stock Máximo
                </label>
                <Input
                  type="number"
                  min="0"
                  value={formData.stock_maximo}
                  onChange={(e) => setFormData({ ...formData, stock_maximo: parseInt(e.target.value) || 0 })}
                  className={errors.stock_maximo ? 'border-red-500' : ''}
                />
                {errors.stock_maximo && (
                  <p className="text-red-500 text-xs mt-1">{errors.stock_maximo}</p>
                )}
              </div>
            </div>
          </div>

          {/* Sección 3: Fechas */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Fechas
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha de Fabricación
                </label>
                <Input
                  type="date"
                  value={formData.fecha_fabricacion}
                  onChange={(e) => setFormData({ ...formData, fecha_fabricacion: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha de Caducidad <span className="text-red-500">*</span>
                </label>
                <Input
                  type="date"
                  value={formData.fecha_caducidad}
                  onChange={(e) => setFormData({ ...formData, fecha_caducidad: e.target.value })}
                  className={errors.fecha_caducidad ? 'border-red-500' : ''}
                />
                {errors.fecha_caducidad && (
                  <p className="text-red-500 text-xs mt-1">{errors.fecha_caducidad}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha de Ingreso
                </label>
                <Input
                  type="date"
                  value={formData.fecha_ingreso}
                  onChange={(e) => setFormData({ ...formData, fecha_ingreso: e.target.value })}
                  disabled={!!batch}
                />
              </div>
            </div>
          </div>

          {/* Sección 4: Almacenamiento */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Almacenamiento
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Ubicación Física
                </label>
                <Input
                  value={formData.ubicacion_fisica}
                  onChange={(e) => setFormData({ ...formData, ubicacion_fisica: e.target.value })}
                  placeholder="Ej: Estante A3, Nivel 2"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Temperatura de Almacenamiento
                </label>
                <select
                  value={formData.temperatura_almacenamiento}
                  onChange={(e) => setFormData({ ...formData, temperatura_almacenamiento: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="">Seleccionar...</option>
                  <option value="ambiente">Temperatura ambiente (15-25°C)</option>
                  <option value="refrigerado">Refrigerado (2-8°C)</option>
                  <option value="congelado">Congelado (-20°C)</option>
                  <option value="controlado">Controlado (especificar)</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Estado
                </label>
                <select
                  value={formData.estado}
                  onChange={(e) => setFormData({ ...formData, estado: e.target.value as any })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="disponible">Disponible</option>
                  <option value="cuarentena">Cuarentena</option>
                  <option value="vencido">Vencido</option>
                  <option value="agotado">Agotado</option>
                </select>
              </div>
            </div>
          </div>

          {/* Sección 5: Observaciones */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Observaciones
            </h3>
            <div>
              <textarea
                value={formData.observaciones}
                onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
                rows={3}
                placeholder="Notas adicionales sobre el lote..."
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
              {submitting ? 'Guardando...' : batch ? 'Actualizar Lote' : 'Crear Lote'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
