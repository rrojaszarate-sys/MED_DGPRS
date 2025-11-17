import { useState } from 'react'
import { Thermometer, AlertTriangle, CheckCircle, TrendingUp, RefreshCw } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useTemperatureMonitoring } from '../hooks/useTemperatureMonitoring'
import { Button } from '../components/ui/Button'
import { useToast } from '../components/ui/Toast'

export function TemperatureMonitoringPage() {
  const { centroSeleccionado } = useCentro()
  const {
    ubicaciones,
    excursionesPendientes,
    loading,
    registrarTemperatura,
    resolverExcursion,
    refresh
  } = useTemperatureMonitoring(centroSeleccionado?.id)
  const toast = useToast()
  const [showExcursionModal, setShowExcursionModal] = useState(false)
  const [selectedExcursion, setSelectedExcursion] = useState<any>(null)

  const getSeverityColor = (severidad: string) => {
    switch (severidad) {
      case 'crítica': return 'bg-red-100 text-red-800 border-red-300'
      case 'severa': return 'bg-orange-100 text-orange-800 border-orange-300'
      case 'moderada': return 'bg-yellow-100 text-yellow-800 border-yellow-300'
      case 'leve': return 'bg-blue-100 text-blue-800 border-blue-300'
      default: return 'bg-gray-100 text-gray-800 border-gray-300'
    }
  }

  const getTemperatureStatus = (
    temp: number | undefined,
    min: number | undefined,
    max: number | undefined
  ) => {
    if (!temp || min === undefined || max === undefined) return 'unknown'
    if (temp < min || temp > max) return 'alert'
    if (temp <= min + 1 || temp >= max - 1) return 'warning'
    return 'ok'
  }

  const getTemperatureStatusColor = (status: string) => {
    switch (status) {
      case 'ok': return 'text-green-600'
      case 'warning': return 'text-yellow-600'
      case 'alert': return 'text-red-600'
      default: return 'text-gray-600'
    }
  }

  const handleResolveExcursion = async (excursionId: string, accion: string) => {
    const { error } = await resolverExcursion(excursionId, accion)
    if (error) {
      toast.error('Error al resolver excursión')
    } else {
      toast.success('Excursión resuelta correctamente')
      setShowExcursionModal(false)
      setSelectedExcursion(null)
    }
  }

  const handleRegisterTemperature = async (ubicacionId: string) => {
    const temp = prompt('Ingrese la temperatura (°C):')
    const humidity = prompt('Ingrese la humedad relativa (%) [Opcional]:')

    if (!temp) return

    const { error } = await registrarTemperatura(
      ubicacionId,
      parseFloat(temp),
      humidity ? parseFloat(humidity) : undefined
    )

    if (error) {
      toast.error('Error al registrar temperatura')
    } else {
      toast.success('Temperatura registrada correctamente')
    }
  }

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver el monitoreo</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Monitoreo de Temperatura</h1>
          <p className="text-gray-600 mt-1">{centroSeleccionado.name}</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => refresh()}
            icon={<RefreshCw className="h-5 w-5" />}
            variant="outline"
          >
            Actualizar
          </Button>
        </div>
      </div>

      {/* Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Ubicaciones Monitoreadas</p>
              <p className="text-2xl font-bold text-gray-900">{ubicaciones.length}</p>
            </div>
            <Thermometer className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Excursiones Pendientes</p>
              <p className="text-2xl font-bold text-red-600">{excursionesPendientes.length}</p>
            </div>
            <AlertTriangle className="h-8 w-8 text-red-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Críticas</p>
              <p className="text-2xl font-bold text-red-600">
                {excursionesPendientes.filter(e => e.severidad === 'crítica').length}
              </p>
            </div>
            <AlertTriangle className="h-8 w-8 text-red-600" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">En Rango</p>
              <p className="text-2xl font-bold text-green-600">
                {ubicaciones.filter(u =>
                  getTemperatureStatus(u.temperatura_actual, u.temperatura_min, u.temperatura_max) === 'ok'
                ).length}
              </p>
            </div>
            <CheckCircle className="h-8 w-8 text-green-500" />
          </div>
        </div>
      </div>

      {/* Excursiones Térmicas Pendientes */}
      {excursionesPendientes.length > 0 && (
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">
            Excursiones Térmicas Pendientes
          </h2>
          <div className="space-y-3">
            {excursionesPendientes.map((excursion) => (
              <div
                key={excursion.id}
                className={`p-4 rounded-lg border-2 ${getSeverityColor(excursion.severidad)}`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <AlertTriangle className="h-5 w-5" />
                      <h3 className="font-bold">
                        Ubicación: {excursion.ubicacion?.codigo || 'N/A'}
                      </h3>
                      <span className="px-2 py-1 text-xs font-semibold rounded uppercase">
                        {excursion.severidad}
                      </span>
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                      <div>
                        <p className="text-gray-600">Temperatura Registrada</p>
                        <p className="font-bold text-lg">{excursion.temperatura_registrada}°C</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Rango Permitido</p>
                        <p className="font-medium">
                          {excursion.temperatura_min_permitida}°C - {excursion.temperatura_max_permitida}°C
                        </p>
                      </div>
                      <div>
                        <p className="text-gray-600">Duración</p>
                        <p className="font-medium">{excursion.duracion_minutos || 0} minutos</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Inicio</p>
                        <p className="font-medium">
                          {new Date(excursion.inicio).toLocaleString('es-MX')}
                        </p>
                      </div>
                    </div>
                    {excursion.afecta_medicamentos && (
                      <div className="mt-2 p-2 bg-red-50 border border-red-200 rounded">
                        <p className="text-sm text-red-800 font-medium">
                          ⚠️ Esta excursión afecta medicamentos almacenados
                        </p>
                      </div>
                    )}
                  </div>
                  <div className="ml-4">
                    <Button
                      onClick={() => {
                        setSelectedExcursion(excursion)
                        setShowExcursionModal(true)
                      }}
                      size="sm"
                    >
                      Resolver
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Estado de Ubicaciones */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-xl font-bold text-gray-900">Estado de Ubicaciones</h2>
        </div>
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-500">Cargando...</p>
          </div>
        ) : ubicaciones.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64">
            <p className="text-gray-500 mb-2">No hay ubicaciones con monitoreo de temperatura</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ubicación</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Temp. Actual</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rango</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Última Lectura</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Excursiones</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {ubicaciones.map((ubicacion) => {
                  const status = getTemperatureStatus(
                    ubicacion.temperatura_actual,
                    ubicacion.temperatura_min,
                    ubicacion.temperatura_max
                  )

                  return (
                    <tr key={ubicacion.ubicacion_id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">{ubicacion.codigo}</div>
                        <div className="text-sm text-gray-500">{ubicacion.ubicacion_nombre || 'Sin nombre'}</div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="px-2 py-1 text-xs font-semibold rounded bg-blue-100 text-blue-800">
                          {ubicacion.tipo}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className={`text-lg font-bold ${getTemperatureStatusColor(status)}`}>
                          {ubicacion.temperatura_actual !== undefined
                            ? `${ubicacion.temperatura_actual}°C`
                            : 'N/A'}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900">
                          {ubicacion.temperatura_min !== undefined && ubicacion.temperatura_max !== undefined
                            ? `${ubicacion.temperatura_min}°C - ${ubicacion.temperatura_max}°C`
                            : 'No definido'}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900">
                          {ubicacion.ultima_lectura
                            ? new Date(ubicacion.ultima_lectura).toLocaleString('es-MX')
                            : 'Sin lecturas'}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        {ubicacion.excursiones_pendientes > 0 ? (
                          <span className="px-2 py-1 text-xs font-semibold rounded bg-red-100 text-red-800">
                            {ubicacion.excursiones_pendientes} pendientes
                          </span>
                        ) : (
                          <span className="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">
                            Sin excursiones
                          </span>
                        )}
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => handleRegisterTemperature(ubicacion.ubicacion_id)}
                            className="inline-flex items-center gap-1 text-primary hover:text-primary-dark text-sm font-medium"
                          >
                            <Thermometer className="h-4 w-4" />
                            Registrar
                          </button>
                          <button
                            onClick={() => toast.info('Historial próximamente')}
                            className="inline-flex items-center gap-1 text-gray-600 hover:text-gray-800 text-sm font-medium"
                          >
                            <TrendingUp className="h-4 w-4" />
                            Historial
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal simple para resolver excursión */}
      {showExcursionModal && selectedExcursion && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full">
            <h3 className="text-lg font-bold mb-4">Resolver Excursión Térmica</h3>
            <p className="text-sm text-gray-600 mb-4">
              Ubicación: {selectedExcursion.ubicacion?.codigo || 'N/A'}
            </p>
            <textarea
              id="accion-correctiva"
              placeholder="Describa la acción correctiva tomada..."
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              rows={4}
            />
            <div className="flex gap-2 mt-4">
              <Button
                onClick={() => {
                  const accion = (document.getElementById('accion-correctiva') as HTMLTextAreaElement)?.value
                  if (accion) {
                    handleResolveExcursion(selectedExcursion.id, accion)
                  } else {
                    toast.error('Debe ingresar la acción correctiva')
                  }
                }}
              >
                Resolver
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  setShowExcursionModal(false)
                  setSelectedExcursion(null)
                }}
              >
                Cancelar
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
