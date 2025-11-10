import { useEffect, useState } from 'react'
import { AlertCircle, CheckCircle, Clock, TrendingUp, Award, Download, FileText, FileSpreadsheet } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useAlertas } from '../hooks/useAlertas'
import { useAuth } from '../context/AuthContext'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { useToast } from '../components/ui/Toast'
import { exportAlertsPDF, exportAlertsExcel } from '../utils/exportUtils'

export function AlertasPage() {
  const { centroSeleccionado } = useCentro()
  const { user } = useAuth()
  const {
    alertas,
    alertasCriticas,
    alertasUrgentes,
    alertasPreventivas,
    loading,
    marcarComoVisto,
    resolverAlerta,
    generarAlertas
  } = useAlertas(centroSeleccionado?.id)
  const toast = useToast()
  const [showExportMenu, setShowExportMenu] = useState(false)

  useEffect(() => {
    if (centroSeleccionado) {
      generarAlertas()
    }
  }, [centroSeleccionado])

  const handleMarcarVisto = async (alertaId: string) => {
    const { error } = await marcarComoVisto(alertaId, user!.id)
    if (error) {
      toast.error('Error al marcar alerta')
    }
  }

  const handleResolver = async (alertaId: string) => {
    const { error } = await resolverAlerta(alertaId, user!.id)
    if (error) {
      toast.error('Error al resolver alerta')
    } else {
      toast.success('¡Alerta resuelta! +100 puntos 🎉')
    }
  }

  const handleExportPDF = () => {
    // TODO: Pass alertas and center name when export function is implemented
    exportAlertsPDF()
    toast.success('Reporte de alertas PDF pendiente de implementación')
    setShowExportMenu(false)
  }

  const handleExportExcel = () => {
    // TODO: Pass alertas and center name when export function is implemented
    exportAlertsExcel()
    toast.success('Reporte de alertas Excel pendiente de implementación')
    setShowExportMenu(false)
  }

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver las alertas</p>
      </div>
    )
  }

  const totalPuntos = (alertasCriticas.length * 100) + (alertasUrgentes.length * 50) + (alertasPreventivas.length * 20)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Sistema de Alertas Gamificado 🎮</h1>
          <p className="text-gray-600 mt-1">{centroSeleccionado.name}</p>
        </div>
        <div className="flex gap-2">
          <div className="relative">
            <Button
              variant="outline"
              icon={<Download className="h-5 w-5" />}
              onClick={() => setShowExportMenu(!showExportMenu)}
            >
              Exportar
            </Button>
            {showExportMenu && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-10">
                <button
                  onClick={handleExportPDF}
                  className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-t-lg"
                >
                  <FileText className="h-4 w-4" />
                  Exportar como PDF
                </button>
                <button
                  onClick={handleExportExcel}
                  className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-b-lg"
                >
                  <FileSpreadsheet className="h-4 w-4" />
                  Exportar como Excel
                </button>
              </div>
            )}
          </div>
          <Button onClick={() => generarAlertas()} variant="outline">
            Actualizar Alertas
          </Button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="bg-red-50 border-l-4 border-l-red-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-red-600">CRÍTICAS (0-7 días)</p>
              <p className="text-3xl font-bold text-red-900 mt-2">{alertasCriticas.length}</p>
              <p className="text-xs text-red-700 mt-1">{alertasCriticas.length * 100} puntos</p>
            </div>
            <div className="h-16 w-16 bg-red-500 rounded-full flex items-center justify-center animate-shake">
              <AlertCircle className="h-8 w-8 text-white" />
            </div>
          </div>
        </Card>

        <Card className="bg-orange-50 border-l-4 border-l-orange-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-orange-600">URGENTES (8-30 días)</p>
              <p className="text-3xl font-bold text-orange-900 mt-2">{alertasUrgentes.length}</p>
              <p className="text-xs text-orange-700 mt-1">{alertasUrgentes.length * 50} puntos</p>
            </div>
            <div className="h-16 w-16 bg-orange-500 rounded-full flex items-center justify-center animate-pulse">
              <Clock className="h-8 w-8 text-white" />
            </div>
          </div>
        </Card>

        <Card className="bg-yellow-50 border-l-4 border-l-yellow-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-yellow-600">PREVENTIVAS (31-90 días)</p>
              <p className="text-3xl font-bold text-yellow-900 mt-2">{alertasPreventivas.length}</p>
              <p className="text-xs text-yellow-700 mt-1">{alertasPreventivas.length * 20} puntos</p>
            </div>
            <div className="h-16 w-16 bg-yellow-500 rounded-full flex items-center justify-center">
              <TrendingUp className="h-8 w-8 text-white" />
            </div>
          </div>
        </Card>

        <Card className="bg-primary-50 border-l-4 border-l-primary">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-primary-600">PUNTOS TOTALES</p>
              <p className="text-3xl font-bold text-primary-900 mt-2">{totalPuntos}</p>
              <p className="text-xs text-primary-700 mt-1">Urgencia acumulada</p>
            </div>
            <div className="h-16 w-16 bg-primary rounded-full flex items-center justify-center">
              <Award className="h-8 w-8 text-white" />
            </div>
          </div>
        </Card>
      </div>

      {/* Alertas por Nivel */}
      {loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      ) : alertas.length === 0 ? (
        <Card className="text-center py-12">
          <CheckCircle className="h-16 w-16 text-green-500 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-gray-900 mb-2">
            ¡Excelente! No hay alertas pendientes 🎉
          </h3>
          <p className="text-gray-600">
            Todos los medicamentos están dentro de los plazos de seguridad
          </p>
        </Card>
      ) : (
        <div className="space-y-6">
          {/* Alertas Críticas */}
          {alertasCriticas.length > 0 && (
            <div>
              <h2 className="text-xl font-bold text-red-900 mb-4 flex items-center gap-2">
                <AlertCircle className="h-6 w-6" />
                Alertas Críticas - ACCIÓN INMEDIATA
              </h2>
              <div className="grid gap-4">
                {alertasCriticas.map((alerta) => (
                  <Card key={alerta.id} className="bg-red-50 border-l-4 border-l-red-500 hover:shadow-lg transition-shadow">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <Badge variant="danger" className="animate-pulse">
                            {alerta.dias_restantes} DÍAS RESTANTES
                          </Badge>
                          {!alerta.visto && (
                            <Badge variant="info">NUEVO</Badge>
                          )}
                        </div>
                        <h3 className="font-bold text-gray-900 text-lg">{alerta.medicamento?.nombre}</h3>
                        <p className="text-sm text-gray-600">
                          Días restantes: {alerta.dias_restantes} días
                        </p>
                        <p className="text-sm text-gray-600">
                          {/* TODO: Refactor alerts to work with Batch instead of Medication */}
                          Ver detalles en inventario
                        </p>
                      </div>
                      <div className="flex gap-2">
                        {!alerta.visto && (
                          <Button size="sm" variant="outline" onClick={() => handleMarcarVisto(alerta.id)}>
                            Marcar Visto
                          </Button>
                        )}
                        <Button size="sm" variant="danger" onClick={() => handleResolver(alerta.id)}>
                          Resolver (+100pts)
                        </Button>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {/* Alertas Urgentes */}
          {alertasUrgentes.length > 0 && (
            <div>
              <h2 className="text-xl font-bold text-orange-900 mb-4 flex items-center gap-2">
                <Clock className="h-6 w-6" />
                Alertas Urgentes - ATENCIÓN REQUERIDA
              </h2>
              <div className="grid gap-4">
                {alertasUrgentes.map((alerta) => (
                  <Card key={alerta.id} className="bg-orange-50 border-l-4 border-l-orange-500">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <Badge variant="warning">
                            {alerta.dias_restantes} días restantes
                          </Badge>
                        </div>
                        <h3 className="font-bold text-gray-900">{alerta.medicamento?.nombre}</h3>
                        <p className="text-sm text-gray-600">
                          Días restantes: {alerta.dias_restantes} días
                        </p>
                      </div>
                      <Button size="sm" onClick={() => handleResolver(alerta.id)}>
                        Resolver (+50pts)
                      </Button>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {/* Alertas Preventivas */}
          {alertasPreventivas.length > 0 && (
            <div>
              <h2 className="text-xl font-bold text-yellow-900 mb-4 flex items-center gap-2">
                <TrendingUp className="h-6 w-6" />
                Alertas Preventivas - PLANIFICAR
              </h2>
              <div className="grid gap-4 md:grid-cols-2">
                {alertasPreventivas.slice(0, 6).map((alerta) => (
                  <Card key={alerta.id} className="bg-yellow-50 border-l-4 border-l-yellow-500">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <Badge variant="warning" size="sm">
                          {alerta.dias_restantes} días
                        </Badge>
                        <h3 className="font-medium text-gray-900 mt-2">{alerta.medicamento?.nombre}</h3>
                        <p className="text-xs text-gray-600">Categoría: {alerta.medicamento?.categoria || 'N/A'}</p>
                      </div>
                      <Button size="sm" variant="ghost" onClick={() => handleResolver(alerta.id)}>
                        +20pts
                      </Button>
                    </div>
                  </Card>
                ))}
              </div>
              {alertasPreventivas.length > 6 && (
                <p className="text-center text-sm text-gray-600 mt-4">
                  Y {alertasPreventivas.length - 6} alertas preventivas más...
                </p>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
