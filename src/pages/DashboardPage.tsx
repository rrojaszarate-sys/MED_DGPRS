import { Package, AlertCircle, Clock, TrendingUp } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useMedicamentos } from '../hooks/useMedicamentos'
import { useAlertas } from '../hooks/useAlertas'
import { useAuth } from '../context/AuthContext'
import { Card } from '../components/ui/Card'

export function DashboardPage() {
  const { user } = useAuth()
  const { centroSeleccionado } = useCentro()
  const { medicamentos, loading: loadingMeds } = useMedicamentos(centroSeleccionado?.id)
  const { alertas, alertasCriticas, alertasUrgentes, alertasPreventivas } = useAlertas(centroSeleccionado?.id)

  const totalStock = medicamentos.reduce((sum, med) => sum + med.cantidad, 0)
  const proximosCaducar30 = medicamentos.filter(med => {
    const dias = Math.ceil((new Date(med.fecha_caducidad).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    return dias <= 30 && dias > 0
  }).length

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-primary to-secondary text-white rounded-2xl p-8">
        <h2 className="text-3xl font-bold mb-2">
          ¡Bienvenido de vuelta, {user?.full_name || 'Usuario'}!
        </h2>
        <p className="text-primary-100">
          {centroSeleccionado ? `${centroSeleccionado.name} - ` : ''}Sistema de Gestión de Inventario de Medicamentos v2.0
        </p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Medicamentos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{loadingMeds ? '...' : medicamentos.length}</p>
            </div>
            <div className="h-12 w-12 bg-blue-100 rounded-full flex items-center justify-center">
              <Package className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Stock Total</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{loadingMeds ? '...' : totalStock.toLocaleString()}</p>
            </div>
            <div className="h-12 w-12 bg-green-100 rounded-full flex items-center justify-center">
              <TrendingUp className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Alertas Activas</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{alertas.length}</p>
              <div className="flex gap-1 mt-1">
                {alertasCriticas.length > 0 && <span className="text-xs text-red-600">🔴 {alertasCriticas.length}</span>}
                {alertasUrgentes.length > 0 && <span className="text-xs text-orange-600">🟠 {alertasUrgentes.length}</span>}
                {alertasPreventivas.length > 0 && <span className="text-xs text-yellow-600">🟡 {alertasPreventivas.length}</span>}
              </div>
            </div>
            <div className="h-12 w-12 bg-orange-100 rounded-full flex items-center justify-center">
              <AlertCircle className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Próximos a Caducar (30d)</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{proximosCaducar30}</p>
            </div>
            <div className="h-12 w-12 bg-red-100 rounded-full flex items-center justify-center">
              <Clock className="h-6 w-6 text-red-600" />
            </div>
          </div>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card hover className="border-l-4 border-l-primary cursor-pointer">
          <h4 className="font-semibold text-gray-900 mb-2">📦 Gestión de Inventario</h4>
          <p className="text-sm text-gray-600">
            Administra medicamentos, lotes y fechas de caducidad de forma eficiente.
          </p>
        </Card>

        <Card hover className="border-l-4 border-l-secondary cursor-pointer">
          <h4 className="font-semibold text-gray-900 mb-2">🎮 Sistema Gamificado</h4>
          <p className="text-sm text-gray-600">
            Alertas interactivas con niveles crítico, urgente y preventivo.
          </p>
        </Card>

        <Card hover className="border-l-4 border-l-accent cursor-pointer">
          <h4 className="font-semibold text-gray-900 mb-2">📊 Análisis en Tiempo Real</h4>
          <p className="text-sm text-gray-600">
            Métricas y reportes actualizados automáticamente con Supabase Realtime.
          </p>
        </Card>
      </div>
    </div>
  )
}
