import { useState } from 'react'
import { Plus, Search, Edit, MapPin, Trash2, Package } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useWarehouseLocations } from '../hooks/useWarehouseLocations'
import { Button } from '../components/ui/Button'
import { useToast } from '../components/ui/Toast'

export function WarehouseMapPage() {
  const { centroSeleccionado } = useCentro()
  const { locations, loading, deleteLocation } = useWarehouseLocations(centroSeleccionado?.id)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterTipo, setFilterTipo] = useState<string>('all')
  const toast = useToast()

  // Filtrar ubicaciones
  const filteredLocations = locations.filter((location) => {
    const matchesSearch = location.codigo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (location.nombre && location.nombre.toLowerCase().includes(searchTerm.toLowerCase()))
    const matchesFilter = filterTipo === 'all' || location.tipo === filterTipo
    return matchesSearch && matchesFilter
  })

  const handleDelete = async (id: string) => {
    if (!confirm('¿Estás seguro de eliminar esta ubicación?')) return

    const { error } = await deleteLocation(id)
    if (error) {
      toast.error('Error al eliminar ubicación')
    } else {
      toast.success('Ubicación eliminada correctamente')
    }
  }

  const getTipoColor = (tipo: string) => {
    switch (tipo) {
      case 'ambiente': return 'bg-blue-100 text-blue-800'
      case 'refrigerado': return 'bg-cyan-100 text-cyan-800'
      case 'congelado': return 'bg-indigo-100 text-indigo-800'
      case 'controlado': return 'bg-purple-100 text-purple-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getCapacidadPercentage = (actual: number, max: number) => {
    return Math.round((actual / max) * 100)
  }

  const getCapacidadColor = (percentage: number) => {
    if (percentage >= 90) return 'bg-red-500'
    if (percentage >= 70) return 'bg-yellow-500'
    return 'bg-green-500'
  }

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver las ubicaciones</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Mapa de Almacén</h1>
          <p className="text-gray-600 mt-1">{centroSeleccionado.name}</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => toast.info('Formulario de ubicación próximamente')}
            icon={<Plus className="h-5 w-5" />}
          >
            Nueva Ubicación
          </Button>
        </div>
      </div>

      {/* Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Ubicaciones</p>
              <p className="text-2xl font-bold text-gray-900">{locations.length}</p>
            </div>
            <MapPin className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Ambiente</p>
              <p className="text-2xl font-bold text-gray-900">
                {locations.filter(l => l.tipo === 'ambiente').length}
              </p>
            </div>
            <Package className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Refrigerado</p>
              <p className="text-2xl font-bold text-gray-900">
                {locations.filter(l => l.tipo === 'refrigerado').length}
              </p>
            </div>
            <Package className="h-8 w-8 text-cyan-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Cuarentena</p>
              <p className="text-2xl font-bold text-gray-900">
                {locations.filter(l => l.es_cuarentena).length}
              </p>
            </div>
            <Package className="h-8 w-8 text-yellow-500" />
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-lg shadow-md space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por código o nombre..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          <div>
            <select
              value={filterTipo}
              onChange={(e) => setFilterTipo(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todos los tipos</option>
              <option value="ambiente">Ambiente</option>
              <option value="refrigerado">Refrigerado</option>
              <option value="congelado">Congelado</option>
              <option value="controlado">Controlado</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="ml-auto text-sm text-gray-600">
            {filteredLocations.length} de {locations.length} ubicaciones
          </div>
        </div>
      </div>

      {/* Grid de Ubicaciones */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading ? (
          <div className="col-span-full flex items-center justify-center h-64">
            <p className="text-gray-500">Cargando...</p>
          </div>
        ) : filteredLocations.length === 0 ? (
          <div className="col-span-full flex flex-col items-center justify-center h-64">
            <p className="text-gray-500 mb-2">No hay ubicaciones registradas</p>
          </div>
        ) : (
          filteredLocations.map((location) => {
            const percentage = getCapacidadPercentage(location.capacidad_actual, location.capacidad_max)

            return (
              <div key={location.id} className="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <MapPin className="h-5 w-5 text-primary" />
                    <div>
                      <h3 className="font-bold text-gray-900">{location.codigo}</h3>
                      {location.nombre && (
                        <p className="text-sm text-gray-600">{location.nombre}</p>
                      )}
                    </div>
                  </div>
                  <span className={`px-2 py-1 text-xs font-semibold rounded-full ${getTipoColor(location.tipo)}`}>
                    {location.tipo}
                  </span>
                </div>

                {/* Capacidad */}
                <div className="mb-3">
                  <div className="flex items-center justify-between text-sm mb-1">
                    <span className="text-gray-600">Capacidad</span>
                    <span className="font-medium text-gray-900">
                      {location.capacidad_actual} / {location.capacidad_max}
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className={`${getCapacidadColor(percentage)} h-2 rounded-full transition-all`}
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                  <p className="text-xs text-gray-500 mt-1">{percentage}% ocupado</p>
                </div>

                {/* Temperatura */}
                {location.temperatura_min && location.temperatura_max && (
                  <div className="mb-3 p-2 bg-gray-50 rounded">
                    <p className="text-xs text-gray-600">Rango de temperatura:</p>
                    <p className="text-sm font-medium text-gray-900">
                      {location.temperatura_min}°C - {location.temperatura_max}°C
                    </p>
                  </div>
                )}

                {/* Badges */}
                <div className="flex gap-2 mb-3">
                  {location.es_cuarentena && (
                    <span className="px-2 py-1 text-xs bg-yellow-100 text-yellow-800 rounded">
                      Cuarentena
                    </span>
                  )}
                  {location.requiere_acceso_especial && (
                    <span className="px-2 py-1 text-xs bg-purple-100 text-purple-800 rounded">
                      Acceso Especial
                    </span>
                  )}
                  {!location.is_active && (
                    <span className="px-2 py-1 text-xs bg-red-100 text-red-800 rounded">
                      Inactivo
                    </span>
                  )}
                </div>

                {/* Observaciones */}
                {location.observaciones && (
                  <p className="text-xs text-gray-600 mb-3 italic">
                    {location.observaciones}
                  </p>
                )}

                {/* Actions */}
                <div className="flex gap-2 pt-3 border-t border-gray-200">
                  <button
                    onClick={() => toast.info('Ver lotes próximamente')}
                    className="flex-1 inline-flex items-center justify-center gap-1 px-3 py-1 text-sm text-primary hover:bg-primary-light rounded"
                  >
                    <Package className="h-4 w-4" />
                    Ver Lotes
                  </button>
                  <button
                    onClick={() => toast.info('Editar ubicación próximamente')}
                    className="inline-flex items-center gap-1 px-3 py-1 text-sm text-gray-600 hover:bg-gray-100 rounded"
                  >
                    <Edit className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(location.id)}
                    className="inline-flex items-center gap-1 px-3 py-1 text-sm text-red-600 hover:bg-red-50 rounded"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            )
          })
        )}
      </div>
    </div>
  )
}
