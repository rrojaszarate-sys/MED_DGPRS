import { useState } from 'react'
import { Plus, Search, Building2, Star, Pencil, Trash2 } from 'lucide-react'
import { useSuppliers } from '../hooks/useSuppliers'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { Badge } from '../components/ui/Badge'
import { SupplierFormModal } from '../components/suppliers/SupplierFormModal'
import { useToast } from '../components/ui/Toast'
import type { Supplier } from '../types'

export function SuppliersPage() {
  const {
    suppliers,
    loading,
    createSupplier,
    updateSupplier,
    deleteSupplier
  } = useSuppliers()
  const toast = useToast()

  const [searchTerm, setSearchTerm] = useState('')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedSupplier, setSelectedSupplier] = useState<Supplier | null>(null)
  const [filterStatus, setFilterStatus] = useState<string>('all')

  const filteredSuppliers = suppliers.filter((supplier) => {
    const searchLower = searchTerm.toLowerCase()
    const matchesSearch =
      supplier.nombre.toLowerCase().includes(searchLower) ||
      (supplier.rfc && supplier.rfc.toLowerCase().includes(searchLower)) ||
      (supplier.ciudad && supplier.ciudad.toLowerCase().includes(searchLower))

    const matchesFilter =
      filterStatus === 'all' ||
      (filterStatus === 'active' && supplier.is_active) ||
      (filterStatus === 'inactive' && !supplier.is_active)

    return matchesSearch && matchesFilter
  })

  const handleCreate = () => {
    setSelectedSupplier(null)
    setIsModalOpen(true)
  }

  const handleEdit = (supplier: Supplier) => {
    setSelectedSupplier(supplier)
    setIsModalOpen(true)
  }

  const handleSubmit = async (data: Partial<Supplier>) => {
    if (selectedSupplier) {
      const { error } = await updateSupplier(selectedSupplier.id, data)
      if (error) {
        toast.error('Error al actualizar proveedor')
      } else {
        toast.success('Proveedor actualizado exitosamente')
        setIsModalOpen(false)
      }
    } else {
      const { error } = await createSupplier(data as Omit<Supplier, 'id' | 'created_at' | 'updated_at'>)
      if (error) {
        toast.error('Error al crear proveedor')
      } else {
        toast.success('Proveedor agregado exitosamente')
        setIsModalOpen(false)
      }
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('¿Estás seguro de eliminar este proveedor?')) return

    const { error } = await deleteSupplier(id)
    if (error) {
      toast.error('Error al eliminar proveedor')
    } else {
      toast.success('Proveedor eliminado correctamente')
    }
  }

  const suppliersActive = suppliers.filter(s => s.is_active).length
  const avgRating = suppliers.reduce((sum, s) => sum + (s.calificacion || 0), 0) / suppliers.length

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Proveedores</h1>
          <p className="text-gray-600 mt-1">Gestión de proveedores de medicamentos</p>
        </div>
        <Button onClick={handleCreate} icon={<Plus className="h-5 w-5" />}>
          Agregar Proveedor
        </Button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Proveedores</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{suppliers.length}</p>
            </div>
            <Building2 className="h-12 w-12 text-blue-500" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Proveedores Activos</p>
              <p className="text-3xl font-bold text-green-900 mt-2">{suppliersActive}</p>
            </div>
          </div>
        </Card>

        <Card className="bg-yellow-50 border-l-4 border-l-yellow-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-yellow-600">Calificación Promedio</p>
              <div className="flex items-center gap-2 mt-2">
                <p className="text-3xl font-bold text-yellow-900">
                  {avgRating > 0 ? avgRating.toFixed(1) : 'N/A'}
                </p>
                {avgRating > 0 && <Star className="h-6 w-6 text-yellow-400 fill-yellow-400" />}
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              placeholder="Buscar por nombre, RFC o ciudad..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">Todos</option>
            <option value="active">Activos</option>
            <option value="inactive">Inactivos</option>
          </select>
        </div>
      </Card>

      {/* Table */}
      <Card>
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
          </div>
        ) : filteredSuppliers.length === 0 ? (
          <div className="text-center py-12">
            <Building2 className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-500 text-lg">No hay proveedores registrados</p>
            <p className="text-gray-400 text-sm mt-2">Agrega el primer proveedor para comenzar</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Proveedor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contacto</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ubicación</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Términos</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Calificación</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredSuppliers.map((supplier) => (
                  <tr key={supplier.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div>
                        <div className="font-medium text-gray-900">{supplier.nombre}</div>
                        {supplier.rfc && (
                          <div className="text-sm text-gray-500">RFC: {supplier.rfc}</div>
                        )}
                        {supplier.razon_social && (
                          <div className="text-xs text-gray-400 mt-1">{supplier.razon_social}</div>
                        )}
                      </div>
                    </td>

                    <td className="px-6 py-4">
                      <div className="text-sm">
                        {supplier.contacto_nombre && (
                          <div className="font-medium text-gray-700">{supplier.contacto_nombre}</div>
                        )}
                        {supplier.telefono && (
                          <div className="text-gray-500">{supplier.telefono}</div>
                        )}
                        {supplier.email && (
                          <div className="text-gray-400">{supplier.email}</div>
                        )}
                      </div>
                    </td>

                    <td className="px-6 py-4">
                      <div className="text-sm">
                        {supplier.ciudad && (
                          <div className="text-gray-700">{supplier.ciudad}</div>
                        )}
                        {supplier.estado && (
                          <div className="text-gray-500">{supplier.estado}</div>
                        )}
                      </div>
                    </td>

                    <td className="px-6 py-4">
                      <div className="text-sm">
                        {supplier.terminos_pago && (
                          <div className="text-gray-700">{supplier.terminos_pago}</div>
                        )}
                        {supplier.dias_credito > 0 && (
                          <Badge variant="info" size="sm">
                            {supplier.dias_credito} días
                          </Badge>
                        )}
                      </div>
                    </td>

                    <td className="px-6 py-4">
                      {supplier.calificacion ? (
                        <div className="flex items-center gap-1">
                          <Star className="h-4 w-4 text-yellow-400 fill-yellow-400" />
                          <span className="text-sm font-medium">{supplier.calificacion.toFixed(1)}</span>
                        </div>
                      ) : (
                        <span className="text-sm text-gray-400">Sin calificar</span>
                      )}
                    </td>

                    <td className="px-6 py-4">
                      {supplier.is_active ? (
                        <Badge variant="success">Activo</Badge>
                      ) : (
                        <Badge variant="default">Inactivo</Badge>
                      )}
                    </td>

                    <td className="px-6 py-4">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleEdit(supplier)}
                          icon={<Pencil className="h-4 w-4" />}
                        >
                          Editar
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleDelete(supplier.id)}
                          icon={<Trash2 className="h-4 w-4" />}
                        >
                          Eliminar
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* Modal */}
      <SupplierFormModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmit}
        supplier={selectedSupplier}
      />
    </div>
  )
}
