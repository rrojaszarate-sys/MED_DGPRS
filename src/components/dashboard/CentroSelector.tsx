import { useEffect } from 'react'
import { Building2 } from 'lucide-react'
import { useCentro } from '../../context/CentroContext'
import { useCentros } from '../../hooks/useCentros'
import { useAuth } from '../../context/AuthContext'

export function CentroSelector() {
  const { user } = useAuth()
  const { centroSeleccionado, setCentroSeleccionado } = useCentro()
  const { centros, loading } = useCentros()

  // Auto-seleccionar primer centro si no hay ninguno seleccionado
  useEffect(() => {
    if (!centroSeleccionado && centros.length > 0) {
      setCentroSeleccionado(centros[0])
    }
  }, [centros, centroSeleccionado, setCentroSeleccionado])

  // Filtrar centros según permisos del usuario
  const centrosDisponibles = user?.role === 'super_admin'
    ? centros
    : centros // TODO: Filtrar por centro_asignado del usuario

  if (loading) {
    return (
      <div className="flex items-center gap-2 px-4 py-2 bg-white rounded-lg border border-gray-300">
        <Building2 className="h-5 w-5 text-gray-400" />
        <span className="text-sm text-gray-500">Cargando centros...</span>
      </div>
    )
  }

  if (centrosDisponibles.length === 0) {
    return (
      <div className="flex items-center gap-2 px-4 py-2 bg-yellow-50 rounded-lg border border-yellow-300">
        <Building2 className="h-5 w-5 text-yellow-600" />
        <span className="text-sm text-yellow-800">No hay centros disponibles</span>
      </div>
    )
  }

  return (
    <div className="relative">
      <div className="flex items-center gap-2">
        <Building2 className="h-5 w-5 text-gray-500" />
        <select
          value={centroSeleccionado?.id || ''}
          onChange={(e) => {
            const centro = centrosDisponibles.find(c => c.id === e.target.value)
            setCentroSeleccionado(centro || null)
          }}
          className="px-4 py-2 pr-10 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary text-sm font-medium text-gray-900 cursor-pointer hover:bg-gray-50 transition-colors"
        >
          {centrosDisponibles.map((centro) => (
            <option key={centro.id} value={centro.id}>
              {centro.name}
            </option>
          ))}
        </select>
      </div>

      {centroSeleccionado && (
        <div className="mt-1 text-xs text-gray-500">
          {centroSeleccionado.code && `Código: ${centroSeleccionado.code}`}
          {centroSeleccionado.city && ` • ${centroSeleccionado.city}`}
        </div>
      )}
    </div>
  )
}
