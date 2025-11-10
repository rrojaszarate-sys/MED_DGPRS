import { useState } from 'react'
import { Plus, Search, Building2, Edit, Trash2, X } from 'lucide-react'
import { useInstituciones } from '../hooks/useInstituciones'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Card } from '../components/ui/Card'
import { useToast } from '../components/ui/Toast'
import type { Institucion } from '../types'

export function InstitutionsPage() {
  const { instituciones, loading, createInstitucion, updateInstitucion, deleteInstitucion } = useInstituciones()
  const toast = useToast()

  const [searchTerm, setSearchTerm] = useState('')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedInst, setSelectedInst] = useState<Institucion | null>(null)

  const [formData, setFormData] = useState({
    nombre: '',
    clave: '',
    tipo: ''
  })

  const filteredInstituciones = instituciones.filter((inst) =>
    inst.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
    inst.clave?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    inst.tipo?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const handleCreate = () => {
    setSelectedInst(null)
    setFormData({ nombre: '', clave: '', tipo: '' })
    setIsModalOpen(true)
  }

  const handleEdit = (inst: Institucion) => {
    setSelectedInst(inst)
    setFormData({
      nombre: inst.nombre,
      clave: inst.clave || '',
      tipo: inst.tipo || ''
    })
    setIsModalOpen(true)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.nombre.trim()) {
      toast.error('El nombre es requerido')
      return
    }

    if (selectedInst) {
      const { error } = await updateInstitucion(selectedInst.id, formData)
      if (error) {
        toast.error('Error al actualizar institución')
      } else {
        toast.success('Institución actualizada exitosamente')
        setIsModalOpen(false)
      }
    } else {
      const { error } = await createInstitucion(formData)
      if (error) {
        toast.error('Error al crear institución')
      } else {
        toast.success('Institución creada exitosamente')
        setIsModalOpen(false)
      }
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('¿Eliminar esta institución?')) return

    const { error } = await deleteInstitucion(id)
    if (error) {
      toast.error('Error al eliminar institución')
    } else {
      toast.success('Institución eliminada correctamente')
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Instituciones</h1>
          <p className="text-gray-600 mt-1">Gestión de instituciones del sector salud</p>
        </div>
        <Button onClick={handleCreate} icon={<Plus className="h-5 w-5" />}>
          Nueva Institución
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{instituciones.length}</p>
            </div>
            <Building2 className="h-12 w-12 text-blue-600 opacity-50" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div>
            <p className="text-sm font-medium text-green-600">Con Clave</p>
            <p className="text-3xl font-bold text-green-900 mt-2">
              {instituciones.filter(i => i.clave).length}
            </p>
          </div>
        </Card>

        <Card className="bg-purple-50 border-l-4 border-l-purple-500">
          <div>
            <p className="text-sm font-medium text-purple-600">Tipos Únicos</p>
            <p className="text-3xl font-bold text-purple-900 mt-2">
              {new Set(instituciones.map(i => i.tipo).filter(Boolean)).size}
            </p>
          </div>
        </Card>
      </div>

      {/* Search */}
      <Card>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
          <Input
            placeholder="Buscar por nombre, clave o tipo..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10"
          />
        </div>
      </Card>

      {/* Table */}
      <Card>
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
          </div>
        ) : filteredInstituciones.length === 0 ? (
          <div className="text-center py-12 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
            <Building2 className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-500 text-lg">No hay instituciones registradas</p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nombre</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Clave</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Creado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredInstituciones.map((inst) => (
                <tr key={inst.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <Building2 className="h-5 w-5 text-gray-400" />
                      <span className="font-medium text-gray-900">{inst.nombre}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="font-mono text-gray-700">{inst.clave || '-'}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-gray-700">{inst.tipo || '-'}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-sm text-gray-500">
                      {new Date(inst.created_at).toLocaleDateString()}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleEdit(inst)}
                        className="text-primary hover:text-primary-dark p-1"
                        title="Editar"
                      >
                        <Edit className="h-5 w-5" />
                      </button>
                      <button
                        onClick={() => handleDelete(inst.id)}
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
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full">
            <div className="px-6 py-4 border-b flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900">
                {selectedInst ? 'Editar Institución' : 'Nueva Institución'}
              </h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="h-6 w-6" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nombre <span className="text-red-500">*</span>
                </label>
                <Input
                  value={formData.nombre}
                  onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
                  placeholder="Ej: IMSS"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Clave</label>
                <Input
                  value={formData.clave}
                  onChange={(e) => setFormData({ ...formData, clave: e.target.value.toUpperCase() })}
                  placeholder="Ej: IMSS001"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Tipo</label>
                <select
                  value={formData.tipo}
                  onChange={(e) => setFormData({ ...formData, tipo: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="">Seleccionar...</option>
                  <option value="IMSS">IMSS</option>
                  <option value="ISSSTE">ISSSTE</option>
                  <option value="SSA">Secretaría de Salud</option>
                  <option value="SEDENA">SEDENA</option>
                  <option value="SEMAR">SEMAR</option>
                  <option value="PEMEX">PEMEX</option>
                  <option value="PRIVADO">Privado</option>
                  <option value="OTRO">Otro</option>
                </select>
              </div>

              <div className="flex gap-3 pt-4">
                <Button type="button" variant="outline" onClick={() => setIsModalOpen(false)} className="flex-1">
                  Cancelar
                </Button>
                <Button type="submit" className="flex-1">
                  {selectedInst ? 'Actualizar' : 'Crear'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
