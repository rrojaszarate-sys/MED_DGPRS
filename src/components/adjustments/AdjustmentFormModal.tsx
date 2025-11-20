import { useState, useEffect } from 'react'
import { X, Upload, Image as ImageIcon, Trash2, AlertCircle } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import type { InventoryAdjustment } from '../../types'
import { useCatalogo } from '../../hooks/useCatalogo'
import { useCentro } from '../../context/CentroContext'

interface AdjustmentFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (adjustment: Partial<InventoryAdjustment>, photos: File[]) => Promise<void>
}

export function AdjustmentFormModal({ isOpen, onClose, onSubmit }: AdjustmentFormModalProps) {
  const { catalogos } = useCatalogo()
  const { centroSeleccionado } = useCentro()

  const [formData, setFormData] = useState({
    medication_id: '',
    adjustment_type: 'merma' as 'merma' | 'correccion' | 'devolucion' | 'reclasificacion',
    cantidad_sistema: 0,
    cantidad_fisica: 0,
    motivo: '',
    justificacion: ''
  })

  const [photos, setPhotos] = useState<File[]>([])
  const [photosPreviews, setPhotosPreviews] = useState<string[]>([])
  const [submitting, setSubmitting] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Calculate difference
  const diferencia = formData.cantidad_fisica - formData.cantidad_sistema

  // Reset form when closed
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        medication_id: '',
        adjustment_type: 'merma',
        cantidad_sistema: 0,
        cantidad_fisica: 0,
        motivo: '',
        justificacion: ''
      })
      setPhotos([])
      setPhotosPreviews([])
      setErrors({})
      setSubmitting(false)
    }
  }, [isOpen])

  // Clean up previews when component unmounts
  useEffect(() => {
    return () => {
      photosPreviews.forEach(url => URL.revokeObjectURL(url))
    }
  }, [photosPreviews])

  const handlePhotoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    if (files.length === 0) return

    // Validate file types
    const validFiles = files.filter(file => file.type.startsWith('image/'))
    if (validFiles.length !== files.length) {
      setErrors({ ...errors, photos: 'Solo se permiten archivos de imagen' })
      return
    }

    // Validate file sizes (max 5MB each)
    const oversizedFiles = validFiles.filter(file => file.size > 5 * 1024 * 1024)
    if (oversizedFiles.length > 0) {
      setErrors({ ...errors, photos: 'Las imágenes no deben exceder 5MB cada una' })
      return
    }

    // Create previews
    const newPreviews = validFiles.map(file => URL.createObjectURL(file))

    setPhotos([...photos, ...validFiles])
    setPhotosPreviews([...photosPreviews, ...newPreviews])
    setErrors({ ...errors, photos: '' })
  }

  const removePhoto = (index: number) => {
    const newPhotos = photos.filter((_, i) => i !== index)
    const newPreviews = photosPreviews.filter((_, i) => i !== index)

    // Revoke the removed preview URL
    URL.revokeObjectURL(photosPreviews[index])

    setPhotos(newPhotos)
    setPhotosPreviews(newPreviews)
  }

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.medication_id) {
      newErrors.medication_id = 'Medicamento es requerido'
    }
    if (formData.cantidad_sistema < 0) {
      newErrors.cantidad_sistema = 'Cantidad en sistema no puede ser negativa'
    }
    if (formData.cantidad_fisica < 0) {
      newErrors.cantidad_fisica = 'Cantidad física no puede ser negativa'
    }
    if (!formData.motivo.trim()) {
      newErrors.motivo = 'Motivo es requerido'
    }
    if (!formData.justificacion.trim()) {
      newErrors.justificacion = 'Justificación es requerida'
    }
    if (formData.adjustment_type === 'merma' && photos.length === 0) {
      newErrors.photos = 'Se requiere al menos una foto de evidencia para mermas'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return

    setSubmitting(true)
    try {
      const adjustmentData = {
        ...formData,
        center_id: centroSeleccionado?.id,
        diferencia
      }

      await onSubmit(adjustmentData, photos)
      onClose()
    } catch (error) {
      console.error('Error submitting adjustment:', error)
    } finally {
      setSubmitting(false)
    }
  }

  if (!isOpen) return null

  const activeCatalogos = catalogos.filter(c => c.is_active)

  const getTypeBadge = (type: string) => {
    const config: Record<string, { color: string; label: string }> = {
      merma: { color: 'bg-red-100 text-red-800 border-red-200', label: '📉 Merma' },
      correccion: { color: 'bg-blue-100 text-blue-800 border-blue-200', label: '🔧 Corrección' },
      devolucion: { color: 'bg-yellow-100 text-yellow-800 border-yellow-200', label: '↩️ Devolución' },
      reclasificacion: { color: 'bg-purple-100 text-purple-800 border-purple-200', label: '🔄 Reclasificación' }
    }
    return config[type] || config.correccion
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-2xl font-bold text-gray-900">
            Nuevo Ajuste de Inventario
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
          {/* Section 1: Basic Info */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Información Básica
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
                {errors.medication_id && (
                  <p className="text-red-500 text-xs mt-1">{errors.medication_id}</p>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo de Ajuste
                </label>
                <select
                  value={formData.adjustment_type}
                  onChange={(e) => setFormData({ ...formData, adjustment_type: e.target.value as any })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="merma">📉 Merma - Pérdidas por deterioro, rotura, vencimiento</option>
                  <option value="correccion">🔧 Corrección - Ajuste entre cantidad física vs. sistema</option>
                  <option value="devolucion">↩️ Devolución - Retorno de productos a proveedor</option>
                  <option value="reclasificacion">🔄 Reclasificación - Cambio de categorización</option>
                </select>
              </div>
            </div>
          </div>

          {/* Section 2: Quantities */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Cantidades
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cantidad en Sistema <span className="text-red-500">*</span>
                </label>
                <Input
                  type="number"
                  min="0"
                  value={formData.cantidad_sistema}
                  onChange={(e) => setFormData({ ...formData, cantidad_sistema: parseInt(e.target.value) || 0 })}
                  className={errors.cantidad_sistema ? 'border-red-500' : ''}
                />
                <p className="text-xs text-gray-500 mt-1">Cantidad actual en el sistema</p>
                {errors.cantidad_sistema && (
                  <p className="text-red-500 text-xs mt-1">{errors.cantidad_sistema}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cantidad Física <span className="text-red-500">*</span>
                </label>
                <Input
                  type="number"
                  min="0"
                  value={formData.cantidad_fisica}
                  onChange={(e) => setFormData({ ...formData, cantidad_fisica: parseInt(e.target.value) || 0 })}
                  className={errors.cantidad_fisica ? 'border-red-500' : ''}
                />
                <p className="text-xs text-gray-500 mt-1">Cantidad contada físicamente</p>
                {errors.cantidad_fisica && (
                  <p className="text-red-500 text-xs mt-1">{errors.cantidad_fisica}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Diferencia
                </label>
                <div className={`px-3 py-2 border rounded-lg ${
                  diferencia === 0 ? 'bg-gray-50 border-gray-300' :
                  diferencia > 0 ? 'bg-green-50 border-green-300' :
                  'bg-red-50 border-red-300'
                }`}>
                  <div className="text-2xl font-bold">
                    {diferencia > 0 ? '+' : ''}{diferencia}
                  </div>
                </div>
                <p className="text-xs text-gray-500 mt-1">Física - Sistema</p>
              </div>
            </div>
          </div>

          {/* Section 3: Justification */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Justificación
            </h3>
            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Motivo <span className="text-red-500">*</span>
                </label>
                <Input
                  value={formData.motivo}
                  onChange={(e) => setFormData({ ...formData, motivo: e.target.value })}
                  placeholder="Ej: Producto vencido, Error de conteo, Daño en embalaje..."
                  className={errors.motivo ? 'border-red-500' : ''}
                />
                {errors.motivo && (
                  <p className="text-red-500 text-xs mt-1">{errors.motivo}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Justificación Detallada <span className="text-red-500">*</span>
                </label>
                <textarea
                  value={formData.justificacion}
                  onChange={(e) => setFormData({ ...formData, justificacion: e.target.value })}
                  rows={4}
                  placeholder="Describa detalladamente el motivo del ajuste, qué sucedió, cuándo, cómo se detectó, etc..."
                  className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent resize-none ${
                    errors.justificacion ? 'border-red-500' : 'border-gray-300'
                  }`}
                />
                {errors.justificacion && (
                  <p className="text-red-500 text-xs mt-1">{errors.justificacion}</p>
                )}
              </div>
            </div>
          </div>

          {/* Section 4: Photo Evidence */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Evidencia Fotográfica
              {formData.adjustment_type === 'merma' && (
                <span className="text-red-500 text-sm ml-2">* Requerido</span>
              )}
            </h3>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Subir Fotos
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-primary transition-colors">
                <input
                  type="file"
                  multiple
                  accept="image/*"
                  onChange={handlePhotoChange}
                  className="hidden"
                  id="photo-upload"
                />
                <label htmlFor="photo-upload" className="cursor-pointer">
                  <Upload className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                  <p className="text-sm text-gray-600">
                    Click para seleccionar fotos o arrastra aquí
                  </p>
                  <p className="text-xs text-gray-500 mt-1">
                    JPG, PNG, GIF - Máx. 5MB por foto
                  </p>
                </label>
              </div>
              {errors.photos && (
                <p className="text-red-500 text-sm mt-2 flex items-center gap-2">
                  <AlertCircle className="h-4 w-4" />
                  {errors.photos}
                </p>
              )}
            </div>

            {photosPreviews.length > 0 && (
              <div>
                <p className="text-sm font-medium text-gray-700 mb-2">
                  Fotos Seleccionadas ({photosPreviews.length})
                </p>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {photosPreviews.map((preview, index) => (
                    <div key={index} className="relative group">
                      <img
                        src={preview}
                        alt={`Evidencia ${index + 1}`}
                        className="w-full h-32 object-cover rounded-lg border border-gray-200"
                      />
                      <button
                        type="button"
                        onClick={() => removePhoto(index)}
                        className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                      <div className="absolute bottom-2 left-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded">
                        {(photos[index].size / 1024).toFixed(0)} KB
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button type="submit" disabled={submitting}>
              {submitting ? 'Creando...' : 'Crear Ajuste'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
