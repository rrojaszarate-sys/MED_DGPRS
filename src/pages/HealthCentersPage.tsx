import { useState } from 'react'
import { Plus, Search, MapPin, Edit, Trash2, X, CheckCircle, XCircle } from 'lucide-react'
import { useCentros } from '../hooks/useCentros'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Card } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { useToast } from '../components/ui/Toast'
import type { HealthCenter } from '../types'

export function HealthCentersPage() {
  const { centros, loading, createCentro, updateCentro, deleteCentro } = useCentros(true)
  const toast = useToast()

  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedCenter, setSelectedCenter] = useState<HealthCenter | null>(null)

  const [formData, setFormData] = useState({
    name: '',
    code: '',
    address: '',
    city: '',
    phone: '',
    is_active: true
  })

  const filteredCentros = centros.filter((centro) => {
    const matchesSearch =
      centro.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      centro.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
      centro.city?.toLowerCase().includes(searchTerm.toLowerCase())

    const matchesStatus =
      filterStatus === 'all' ||
      (filterStatus === 'active' && centro.is_active) ||
      (filterStatus === 'inactive' && !centro.is_active)

    return matchesSearch && matchesStatus
  })

  const stats = {
    total: centros.length,
    active: centros.filter(c => c.is_active).length,
    inactive: centros.filter(c => !c.is_active).length
  }

  const handleCreate = () => {
    setSelectedCenter(null)
    setFormData({ name: '', code: '', address: '', city: '', phone: '', is_active: true })
    setIsModalOpen(true)
  }

  const handleEdit = (centro: HealthCenter) => {
    setSelectedCenter(centro)
    setFormData({
      name: centro.name,
      code: centro.code,
      address: centro.address || '',
      city: centro.city || '',
      phone: centro.phone || '',
      is_active: centro.is_active
    })
    setIsModalOpen(true)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.name.trim() || !formData.code.trim()) {
      toast.error('Nombre y código son requeridos')
      return
    }

    if (selectedCenter) {
      const { error } = await updateCentro(selectedCenter.id, formData)
      if (error) {
        toast.error('Error al actualizar centro')
      } else {
        toast.success('Centro actualizado exitosamente')
        setIsModalOpen(false)
      }
    } else {
      const { error } = await createCentro(formData)
      if (error) {
        toast.error('Error al crear centro')
      } else {
        toast.success('Centro creado exitosamente')
        setIsModalOpen(false)
      }
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('¿Eliminar este centro de salud?')) return

    const { error } = await deleteCentro(id)
    if (error) {
      toast.error('Error al eliminar centro')
    } else {
      toast.success('Centro eliminado correctamente')
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Centros de Salud</h1>
          <p className="text-gray-600 mt-1">Gestión de unidades médicas y hospitales</p>
        </div>
        <Button onClick={handleCreate} icon={<Plus className="h-5 w-5" />}>
          Nuevo Centro
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Centros</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{stats.total}</p>
            </div>
            <MapPin className="h-12 w-12 text-blue-600 opacity-50" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Activos</p>
              <p className="text-3xl font-bold text-green-900 mt-2">{stats.active}</p>
            </div>
            <CheckCircle className="h-12 w-12 text-green-600 opacity-50" />
          </div>
        </Card>

        <Card className="bg-gray-50 border-l-4 border-l-gray-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Inactivos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stats.inactive}</p>
            </div>
            <XCircle className="h-12 w-12 text-gray-600 opacity-50" />
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <Input
                placeholder="Nombre, código o ciudad..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Estado</label>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
            >
              <option value="all">Todos</option>
              <option value="active">Activos</option>
              <option value="inactive">Inactivos</option>
            </select>
          </div>
        </div>
      </Card>

      {/* Table */}
      <Card>
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
          </div>
        ) : filteredCentros.length === 0 ? (
          <div className="text-center py-12 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
            <MapPin className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-500 text-lg">No hay centros registrados</p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Centro</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Código</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ubicación</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Teléfono</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredCentros.map((centro) => (
                <tr key={centro.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <MapPin className="h-5 w-5 text-gray-400" />
                      <div>
                        <div className="font-medium text-gray-900">{centro.name}</div>
                        {centro.address && <div className="text-sm text-gray-500">{centro.address}</div>}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="font-mono text-gray-700">{centro.code}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-gray-700">{centro.city || '-'}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-gray-700">{centro.phone || '-'}</span>
                  </td>
                  <td className="px-6 py-4">
                    <Badge variant={centro.is_active ? 'success' : 'default'}>
                      {centro.is_active ? 'Activo' : 'Inactivo'}
                    </Badge>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleEdit(centro)}
                        className="text-primary hover:text-primary-dark p-1"
                        title="Editar"
                      >
                        <Edit className="h-5 w-5" />
                      </button>
                      <button
                        onClick={() => handleDelete(centro.id)}
                        className="text-red-600 hover:text-red-800 p-1"
                        title="Eliminar"
                      >
                        <Trash2 className="h-5 w-5" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-2xl max-w-lg w-full">
            <div className="px-6 py-4 border-b flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">
                {selectedCenter ? 'Editar Centro' : 'Nuevo Centro'}
              </h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="h-6 w-6" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Nombre <span className="text-red-500">*</span>
                  </label>
                  <Input
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder="Ej: Hospital General de Zona No. 1"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Código <span className="text-red-500">*</span>
                  </label>
                  <Input
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                    placeholder="Ej: HGZ001"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Ciudad</label>
                  <Input
                    value={formData.city}
                    onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                    placeholder="Ej: Guadalajara"
                  />
                </div>

                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Dirección</label>
                  <Input
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    placeholder="Calle, número, colonia"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
                  <Input
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    placeholder="Ej: 3312345678"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Estado</label>
                  <select
                    value={formData.is_active ? 'active' : 'inactive'}
                    onChange={(e) => setFormData({ ...formData, is_active: e.target.value === 'active' })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                  >
                    <option value="active">Activo</option>
                    <option value="inactive">Inactivo</option>
                  </select>
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <Button type="button" variant="outline" onClick={() => setIsModalOpen(false)} className="flex-1">
                  Cancelar
                </Button>
                <Button type="submit" className="flex-1">
                  {selectedCenter ? 'Actualizar' : 'Crear'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
