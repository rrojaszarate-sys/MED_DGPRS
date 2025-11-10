import { useState, useEffect } from 'react'
import { X, FileText } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Badge } from '../ui/Badge'
import { ContractItemsTable } from './ContractItemsTable'
import type { Contract, ContractItem } from '../../types'
import { useSuppliers } from '../../hooks/useSuppliers'
import { useCatalogo } from '../../hooks/useCatalogo'
import { useCentro } from '../../context/CentroContext'

interface ContractFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (
    contract: Omit<Contract, 'id' | 'created_at'>,
    items: Omit<ContractItem, 'contract_id' | 'created_at'>[]
  ) => Promise<void>
  contract?: Contract | null
}

export function ContractFormModal({ isOpen, onClose, onSubmit, contract }: ContractFormModalProps) {
  const { suppliers } = useSuppliers()
  const { catalogos } = useCatalogo()
  const { centros } = useCentro()

  const [formData, setFormData] = useState({
    codigo_contrato: '',
    supplier_id: '',
    fecha_inicio: '',
    fecha_fin: '',
    monto_total: 0,
    estado: 'borrador' as Contract['estado'],
    observaciones: ''
  })

  const [items, setItems] = useState<Omit<ContractItem, 'contract_id' | 'created_at'>[]>([])
  const [submitting, setSubmitting] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Populate form when editing
  useEffect(() => {
    if (contract) {
      setFormData({
        codigo_contrato: contract.codigo_contrato,
        supplier_id: contract.supplier_id,
        fecha_inicio: contract.fecha_inicio.split('T')[0],
        fecha_fin: contract.fecha_fin.split('T')[0],
        monto_total: contract.monto_total || 0,
        estado: contract.estado,
        observaciones: contract.observaciones || ''
      })

      // Set items (keep id for existing items)
      if (contract.items) {
        setItems(contract.items.map(item => ({
          id: item.id,
          medication_catalog_id: item.medication_catalog_id,
          cantidad_comprometida: item.cantidad_comprometida,
          precio_unitario: item.precio_unitario,
          center_destino_id: item.center_destino_id,
          fecha_estimada_entrega: item.fecha_estimada_entrega?.split('T')[0]
        })))
      }
    } else {
      // Reset for new contract
      setFormData({
        codigo_contrato: '',
        supplier_id: '',
        fecha_inicio: '',
        fecha_fin: '',
        monto_total: 0,
        estado: 'borrador',
        observaciones: ''
      })
      setItems([])
    }
  }, [contract])

  // Reset form when closed
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        codigo_contrato: '',
        supplier_id: '',
        fecha_inicio: '',
        fecha_fin: '',
        monto_total: 0,
        estado: 'borrador',
        observaciones: ''
      })
      setItems([])
      setErrors({})
      setSubmitting(false)
    }
  }, [isOpen])

  // Auto-calculate monto_total from items
  useEffect(() => {
    const total = items.reduce((sum, item) => {
      return sum + (item.cantidad_comprometida * (item.precio_unitario || 0))
    }, 0)
    setFormData(prev => ({ ...prev, monto_total: total }))
  }, [items])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.codigo_contrato.trim()) newErrors.codigo_contrato = 'Código de contrato es requerido'
    if (!formData.supplier_id) newErrors.supplier_id = 'Proveedor es requerido'
    if (!formData.fecha_inicio) newErrors.fecha_inicio = 'Fecha de inicio es requerida'
    if (!formData.fecha_fin) newErrors.fecha_fin = 'Fecha de fin es requerida'
    if (formData.fecha_fin && formData.fecha_inicio && formData.fecha_fin < formData.fecha_inicio) {
      newErrors.fecha_fin = 'Fecha de fin debe ser posterior a fecha de inicio'
    }
    if (items.length === 0) {
      newErrors.items = 'Debe agregar al menos un item al contrato'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return

    setSubmitting(true)
    try {
      await onSubmit(formData, items)
      onClose()
    } catch (error) {
      console.error('Error submitting contract:', error)
    } finally {
      setSubmitting(false)
    }
  }

  if (!isOpen) return null

  const activeSuppliers = suppliers.filter(s => s.is_active)

  const estadoColors: Record<Contract['estado'], string> = {
    borrador: 'bg-gray-100 text-gray-800',
    activo: 'bg-green-100 text-green-800',
    vencido: 'bg-red-100 text-red-800',
    cancelado: 'bg-yellow-100 text-yellow-800'
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-5xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between z-10">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 bg-primary-100 rounded-full flex items-center justify-center">
              <FileText className="h-5 w-5 text-primary-600" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                {contract ? 'Editar Contrato' : 'Nuevo Contrato'}
              </h2>
              {contract && (
                <p className="text-sm text-gray-600">
                  Código: {contract.codigo_contrato}
                </p>
              )}
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Sección 1: Información General */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Información General
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Código de Contrato <span className="text-red-500">*</span>
                </label>
                <Input
                  value={formData.codigo_contrato}
                  onChange={(e) => setFormData({ ...formData, codigo_contrato: e.target.value.toUpperCase() })}
                  placeholder="Ej: CONT-2024-001"
                  className={errors.codigo_contrato ? 'border-red-500' : ''}
                  disabled={!!contract}
                />
                {errors.codigo_contrato && (
                  <p className="text-red-500 text-xs mt-1">{errors.codigo_contrato}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Proveedor <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.supplier_id}
                  onChange={(e) => setFormData({ ...formData, supplier_id: e.target.value })}
                  className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent ${
                    errors.supplier_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Seleccionar proveedor...</option>
                  {activeSuppliers.map((sup) => (
                    <option key={sup.id} value={sup.id}>
                      {sup.nombre} - {sup.rfc || 'Sin RFC'}
                    </option>
                  ))}
                </select>
                {errors.supplier_id && (
                  <p className="text-red-500 text-xs mt-1">{errors.supplier_id}</p>
                )}
              </div>
            </div>
          </div>

          {/* Sección 2: Fechas y Estado */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Vigencia y Estado
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha de Inicio <span className="text-red-500">*</span>
                </label>
                <Input
                  type="date"
                  value={formData.fecha_inicio}
                  onChange={(e) => setFormData({ ...formData, fecha_inicio: e.target.value })}
                  className={errors.fecha_inicio ? 'border-red-500' : ''}
                />
                {errors.fecha_inicio && (
                  <p className="text-red-500 text-xs mt-1">{errors.fecha_inicio}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha de Fin <span className="text-red-500">*</span>
                </label>
                <Input
                  type="date"
                  value={formData.fecha_fin}
                  onChange={(e) => setFormData({ ...formData, fecha_fin: e.target.value })}
                  className={errors.fecha_fin ? 'border-red-500' : ''}
                />
                {errors.fecha_fin && (
                  <p className="text-red-500 text-xs mt-1">{errors.fecha_fin}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Estado
                </label>
                <select
                  value={formData.estado}
                  onChange={(e) => setFormData({ ...formData, estado: e.target.value as Contract['estado'] })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="borrador">Borrador</option>
                  <option value="activo">Activo</option>
                  <option value="vencido">Vencido</option>
                  <option value="cancelado">Cancelado</option>
                </select>
                <div className="mt-2">
                  <Badge className={estadoColors[formData.estado]}>
                    {formData.estado}
                  </Badge>
                </div>
              </div>
            </div>
          </div>

          {/* Sección 3: Items del Contrato */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Medicamentos Comprometidos
            </h3>

            <ContractItemsTable
              items={items}
              onItemsChange={(newItems) => setItems(newItems as Omit<ContractItem, 'contract_id' | 'created_at'>[])}
              medications={catalogos}
              centers={centros}
            />

            {errors.items && (
              <p className="text-red-500 text-sm">{errors.items}</p>
            )}
          </div>

          {/* Sección 4: Monto Total */}
          <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-700">Monto Total del Contrato</p>
                <p className="text-xs text-gray-500 mt-1">Calculado automáticamente de los items</p>
              </div>
              <div className="text-right">
                <p className="text-3xl font-bold text-primary">${formData.monto_total.toLocaleString('es-MX', { minimumFractionDigits: 2 })}</p>
                <p className="text-xs text-gray-500 mt-1">{items.length} item{items.length !== 1 ? 's' : ''}</p>
              </div>
            </div>
          </div>

          {/* Sección 5: Observaciones */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Observaciones
            </h3>
            <textarea
              value={formData.observaciones}
              onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
              rows={3}
              placeholder="Notas adicionales sobre el contrato..."
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent resize-none"
            />
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button type="submit" disabled={submitting}>
              {submitting ? 'Guardando...' : contract ? 'Actualizar Contrato' : 'Crear Contrato'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
