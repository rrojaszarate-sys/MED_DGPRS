import { useState } from 'react'
import { Plus, Pencil, Trash2, Package, MapPin, Calendar, DollarSign } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import type { ContractItem, MedicationCatalog, HealthCenter } from '../../types'

interface ContractItemData extends Omit<ContractItem, 'id' | 'contract_id' | 'created_at'> {
  id?: string // Optional id for existing items
  tempId?: string // For tracking items before saving
}

interface ContractItemsTableProps {
  items: ContractItemData[]
  onItemsChange: (items: ContractItemData[]) => void
  medications: MedicationCatalog[]
  centers: HealthCenter[]
}

export function ContractItemsTable({
  items,
  onItemsChange,
  medications,
  centers
}: ContractItemsTableProps) {
  const [isAdding, setIsAdding] = useState(false)
  const [editingIndex, setEditingIndex] = useState<number | null>(null)

  const [formData, setFormData] = useState<ContractItemData>({
    medication_catalog_id: '',
    cantidad_comprometida: 0,
    precio_unitario: 0,
    center_destino_id: '',
    fecha_estimada_entrega: ''
  })

  const resetForm = () => {
    setFormData({
      medication_catalog_id: '',
      cantidad_comprometida: 0,
      precio_unitario: 0,
      center_destino_id: '',
      fecha_estimada_entrega: ''
    })
  }

  const handleAdd = () => {
    setIsAdding(true)
    setEditingIndex(null)
    resetForm()
  }

  const handleEdit = (index: number) => {
    setEditingIndex(index)
    setIsAdding(false)
    setFormData({ ...items[index] })
  }

  const handleSave = () => {
    if (!formData.medication_catalog_id || formData.cantidad_comprometida <= 0) {
      alert('Medicamento y cantidad son requeridos')
      return
    }

    const newItem: ContractItemData = {
      ...formData,
      tempId: editingIndex !== null ? items[editingIndex].tempId : `temp-${Date.now()}`
    }

    if (editingIndex !== null) {
      // Update existing item
      const updatedItems = [...items]
      updatedItems[editingIndex] = newItem
      onItemsChange(updatedItems)
    } else {
      // Add new item
      onItemsChange([...items, newItem])
    }

    setIsAdding(false)
    setEditingIndex(null)
    resetForm()
  }

  const handleCancel = () => {
    setIsAdding(false)
    setEditingIndex(null)
    resetForm()
  }

  const handleDelete = (index: number) => {
    if (confirm('¿Eliminar este item del contrato?')) {
      onItemsChange(items.filter((_, i) => i !== index))
    }
  }

  const getMedicationName = (id: string) => {
    const med = medications.find(m => m.id === id)
    return med ? `${med.nombre_generico} ${med.concentracion || ''}`.trim() : 'N/A'
  }

  const getCenterName = (id?: string) => {
    if (!id) return '-'
    const center = centers.find(c => c.id === id)
    return center ? `${center.name} (${center.code})` : '-'
  }

  const calculateSubtotal = (item: ContractItemData) => {
    return (item.cantidad_comprometida * (item.precio_unitario || 0)).toFixed(2)
  }

  const getTotalAmount = () => {
    return items.reduce((sum, item) => sum + (item.cantidad_comprometida * (item.precio_unitario || 0)), 0).toFixed(2)
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h4 className="text-sm font-semibold text-gray-900">Items del Contrato</h4>
          <p className="text-xs text-gray-500">
            {items.length} item{items.length !== 1 ? 's' : ''} - Total: ${getTotalAmount()}
          </p>
        </div>
        {!isAdding && editingIndex === null && (
          <Button
            type="button"
            size="sm"
            variant="outline"
            onClick={handleAdd}
            icon={<Plus className="h-4 w-4" />}
          >
            Agregar Item
          </Button>
        )}
      </div>

      {/* Table */}
      {items.length > 0 && (
        <div className="border border-gray-200 rounded-lg overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200 text-sm">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Medicamento</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Cantidad</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Precio Unit.</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Subtotal</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Centro Destino</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">F. Entrega</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {items.map((item, index) => (
                <tr key={item.tempId || index} className="hover:bg-gray-50">
                  <td className="px-3 py-2">
                    <div className="flex items-center gap-1">
                      <Package className="h-4 w-4 text-gray-400" />
                      <span className="text-gray-900">{getMedicationName(item.medication_catalog_id)}</span>
                    </div>
                  </td>
                  <td className="px-3 py-2 text-gray-900">{item.cantidad_comprometida.toLocaleString()}</td>
                  <td className="px-3 py-2 text-gray-900">${(item.precio_unitario || 0).toFixed(2)}</td>
                  <td className="px-3 py-2 font-medium text-gray-900">${calculateSubtotal(item)}</td>
                  <td className="px-3 py-2">
                    <div className="flex items-center gap-1">
                      <MapPin className="h-4 w-4 text-gray-400" />
                      <span className="text-gray-700 text-xs">{getCenterName(item.center_destino_id)}</span>
                    </div>
                  </td>
                  <td className="px-3 py-2 text-gray-700 text-xs">
                    {item.fecha_estimada_entrega ? new Date(item.fecha_estimada_entrega).toLocaleDateString() : '-'}
                  </td>
                  <td className="px-3 py-2">
                    <div className="flex gap-1">
                      <button
                        type="button"
                        onClick={() => handleEdit(index)}
                        className="text-blue-600 hover:text-blue-800 p-1"
                        title="Editar"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDelete(index)}
                        className="text-red-600 hover:text-red-800 p-1"
                        title="Eliminar"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Add/Edit Form */}
      {(isAdding || editingIndex !== null) && (
        <div className="border border-primary-200 bg-primary-50 rounded-lg p-4 space-y-3">
          <h5 className="font-medium text-gray-900">
            {editingIndex !== null ? 'Editar Item' : 'Nuevo Item'}
          </h5>

          <div className="grid grid-cols-2 gap-3">
            {/* Medicamento */}
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Medicamento <span className="text-red-500">*</span>
              </label>
              <select
                value={formData.medication_catalog_id}
                onChange={(e) => setFormData({ ...formData, medication_catalog_id: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent text-sm"
              >
                <option value="">Seleccionar medicamento...</option>
                {medications.filter(m => m.is_active).map((med) => (
                  <option key={med.id} value={med.id}>
                    {med.codigo_medicamento} - {med.nombre_generico} {med.concentracion}
                  </option>
                ))}
              </select>
            </div>

            {/* Cantidad */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cantidad Comprometida <span className="text-red-500">*</span>
              </label>
              <Input
                type="number"
                min="1"
                value={formData.cantidad_comprometida || ''}
                onChange={(e) => setFormData({ ...formData, cantidad_comprometida: parseInt(e.target.value) || 0 })}
                className="text-sm"
              />
            </div>

            {/* Precio Unitario */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Precio Unitario
              </label>
              <div className="relative">
                <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  type="number"
                  min="0"
                  step="0.01"
                  value={formData.precio_unitario || ''}
                  onChange={(e) => setFormData({ ...formData, precio_unitario: parseFloat(e.target.value) || 0 })}
                  className="pl-8 text-sm"
                />
              </div>
            </div>

            {/* Centro Destino */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Centro Destino
              </label>
              <select
                value={formData.center_destino_id || ''}
                onChange={(e) => setFormData({ ...formData, center_destino_id: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent text-sm"
              >
                <option value="">Sin especificar</option>
                {centers.filter(c => c.is_active).map((center) => (
                  <option key={center.id} value={center.id}>
                    {center.name} - {center.code}
                  </option>
                ))}
              </select>
            </div>

            {/* Fecha Estimada Entrega */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Fecha Estimada Entrega
              </label>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  type="date"
                  value={formData.fecha_estimada_entrega || ''}
                  onChange={(e) => setFormData({ ...formData, fecha_estimada_entrega: e.target.value })}
                  className="pl-8 text-sm"
                />
              </div>
            </div>
          </div>

          {/* Subtotal Preview */}
          {formData.cantidad_comprometida > 0 && formData.precio_unitario && (
            <div className="text-sm bg-white border border-gray-200 rounded p-2">
              <span className="text-gray-600">Subtotal: </span>
              <span className="font-semibold text-gray-900">
                ${(formData.cantidad_comprometida * formData.precio_unitario).toFixed(2)}
              </span>
            </div>
          )}

          {/* Actions */}
          <div className="flex gap-2">
            <Button type="button" size="sm" onClick={handleSave}>
              {editingIndex !== null ? 'Actualizar' : 'Agregar'}
            </Button>
            <Button type="button" size="sm" variant="outline" onClick={handleCancel}>
              Cancelar
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}
