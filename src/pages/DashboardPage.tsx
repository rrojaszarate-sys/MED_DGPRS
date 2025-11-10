import { Package, AlertCircle, Clock, TrendingUp, Activity, BarChart3, PieChart } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useMedicamentos } from '../hooks/useMedicamentos'
import { useBatches } from '../hooks/useBatches'
import { useMovements } from '../hooks/useMovements'
import { useAlertas } from '../hooks/useAlertas'
import { useAuth } from '../context/AuthContext'
import { Card } from '../components/ui/Card'
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  AreaChart,
  Area,
  PieChart as RePieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts'
import { useMemo } from 'react'

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899']

export function DashboardPage() {
  const { user } = useAuth()
  const { centroSeleccionado } = useCentro()
  const { medicamentos, loading: loadingMeds } = useMedicamentos(centroSeleccionado?.id)
  const { batches, loading: loadingBatches } = useBatches(centroSeleccionado?.id)
  const { movements, loading: loadingMovements } = useMovements(centroSeleccionado?.id)
  const { alertas, alertasCriticas, alertasUrgentes, alertasPreventivas } = useAlertas(centroSeleccionado?.id)

  const totalStock = batches.reduce((sum, batch) => sum + (batch.cantidad_actual || 0), 0)
  const lotes_activos = batches.filter(batch => batch.cantidad_actual > 0 && batch.estado === 'disponible').length
  const proximosCaducar30 = batches.filter(batch => {
    if (!batch.fecha_caducidad || batch.cantidad_actual === 0) return false
    const dias = Math.ceil((new Date(batch.fecha_caducidad).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    return dias <= 30 && dias > 0
  }).length

  // Data processing for charts
  const stockPorMedicamento = useMemo(() => {
    const grouped = batches.reduce((acc, batch) => {
      const medName = batch.medication?.nombre || 'Sin nombre'
      if (!acc[medName]) acc[medName] = 0
      acc[medName] += batch.cantidad_actual
      return acc
    }, {} as Record<string, number>)

    return Object.entries(grouped)
      .map(([name, stock]) => ({ name, stock }))
      .sort((a, b) => b.stock - a.stock)
      .slice(0, 10)
  }, [batches])

  const stockPorEstado = useMemo(() => {
    const estados = batches.reduce((acc, batch) => {
      const estado = batch.estado
      if (!acc[estado]) acc[estado] = 0
      acc[estado] += batch.cantidad_actual
      return acc
    }, {} as Record<string, number>)

    return Object.entries(estados).map(([name, value]) => ({ name, value }))
  }, [batches])

  const movimientosPorDia = useMemo(() => {
    const last7Days = Array.from({ length: 7 }, (_, i) => {
      const date = new Date()
      date.setDate(date.getDate() - (6 - i))
      return date.toISOString().split('T')[0]
    })

    return last7Days.map(date => {
      const dayMovements = movements.filter(m => m.created_at.startsWith(date))
      const entradas = dayMovements.filter(m => ['entrada', 'transferencia_entrada', 'devolucion'].includes(m.tipo_movimiento)).length
      const salidas = dayMovements.filter(m => ['salida', 'transferencia_salida', 'vencimiento', 'merma', 'destruccion'].includes(m.tipo_movimiento)).length

      return {
        fecha: new Date(date).toLocaleDateString('es-MX', { month: 'short', day: 'numeric' }),
        entradas,
        salidas,
        total: entradas + salidas
      }
    })
  }, [movements])

  const stockPorCategoria = useMemo(() => {
    const grouped = batches.reduce((acc, batch) => {
      const categoria = batch.medication?.categoria || 'Sin categoría'
      if (!acc[categoria]) acc[categoria] = 0
      acc[categoria] += batch.cantidad_actual
      return acc
    }, {} as Record<string, number>)

    return Object.entries(grouped)
      .map(([name, cantidad]) => ({ name, cantidad }))
      .sort((a, b) => b.cantidad - a.cantidad)
      .slice(0, 6)
  }, [batches])

  const isLoading = loadingMeds || loadingBatches || loadingMovements

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver el dashboard</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-primary to-secondary text-white rounded-2xl p-8">
        <h2 className="text-3xl font-bold mb-2">
          ¡Bienvenido de vuelta, {user?.full_name || 'Usuario'}!
        </h2>
        <p className="text-primary-100">
          {centroSeleccionado.name} - Sistema de Gestión de Inventario de Medicamentos v2.0
        </p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Medicamentos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {isLoading ? '...' : medicamentos.length}
              </p>
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
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {isLoading ? '...' : totalStock.toLocaleString()}
              </p>
              <p className="text-xs text-gray-500 mt-1">{lotes_activos} lotes activos</p>
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
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {isLoading ? '...' : proximosCaducar30}
              </p>
            </div>
            <div className="h-12 w-12 bg-red-100 rounded-full flex items-center justify-center">
              <Clock className="h-6 w-6 text-red-600" />
            </div>
          </div>
        </Card>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top 10 Medicamentos por Stock */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <BarChart3 className="h-5 w-5 text-primary" />
            <h3 className="text-lg font-semibold text-gray-900">Top 10 Medicamentos por Stock</h3>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={stockPorMedicamento}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="name"
                tick={{ fontSize: 12 }}
                angle={-45}
                textAnchor="end"
                height={100}
              />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="stock" fill="#3b82f6" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </Card>

        {/* Movimientos por Día (Última Semana) */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <Activity className="h-5 w-5 text-primary" />
            <h3 className="text-lg font-semibold text-gray-900">Movimientos (Última Semana)</h3>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={movimientosPorDia}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="fecha" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="entradas" stroke="#10b981" strokeWidth={2} dot={{ r: 4 }} />
              <Line type="monotone" dataKey="salidas" stroke="#ef4444" strokeWidth={2} dot={{ r: 4 }} />
              <Line type="monotone" dataKey="total" stroke="#3b82f6" strokeWidth={2} strokeDasharray="5 5" />
            </LineChart>
          </ResponsiveContainer>
        </Card>

        {/* Stock por Estado */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <PieChart className="h-5 w-5 text-primary" />
            <h3 className="text-lg font-semibold text-gray-900">Distribución por Estado</h3>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <RePieChart>
              <Pie
                data={stockPorEstado}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {stockPorEstado.map((_, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </RePieChart>
          </ResponsiveContainer>
        </Card>

        {/* Stock por Categoría */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp className="h-5 w-5 text-primary" />
            <h3 className="text-lg font-semibold text-gray-900">Stock por Categoría</h3>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={stockPorCategoria}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="name"
                tick={{ fontSize: 12 }}
                angle={-45}
                textAnchor="end"
                height={80}
              />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Area
                type="monotone"
                dataKey="cantidad"
                stroke="#8b5cf6"
                fill="#8b5cf6"
                fillOpacity={0.3}
              />
            </AreaChart>
          </ResponsiveContainer>
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
