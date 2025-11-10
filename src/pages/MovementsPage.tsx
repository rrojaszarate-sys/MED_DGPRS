import { useState, useMemo } from 'react'
import { Search, Filter, RefreshCw, TrendingUp } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useMovements } from '../hooks/useMovements'
import { MovementTimeline } from '../components/movements/MovementTimeline'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Card } from '../components/ui/Card'

export function MovementsPage() {
  const { centroSeleccionado } = useCentro()
  const { movements, loading, refresh } = useMovements(centroSeleccionado?.id)

  const [searchTerm, setSearchTerm] = useState('')
  const [filterTipo, setFilterTipo] = useState<string>('all')
  const [filterFechaDesde, setFilterFechaDesde] = useState('')
  const [filterFechaHasta, setFilterFechaHasta] = useState('')

  // Filter movements
  const filteredMovements = useMemo(() => {
    return movements.filter((movement) => {
      // Search filter
      const searchLower = searchTerm.toLowerCase()
      const matchesSearch =
        movement.motivo.toLowerCase().includes(searchLower) ||
        movement.medication?.nombre.toLowerCase().includes(searchLower) ||
        movement.batch?.numero_lote.toLowerCase().includes(searchLower) ||
        movement.metadata?.user_name?.toLowerCase().includes(searchLower)

      // Type filter
      const matchesTipo = filterTipo === 'all' || movement.tipo_movimiento === filterTipo

      // Date filter
      const movementDate = new Date(movement.created_at).toISOString().split('T')[0]
      const matchesFechaDesde = !filterFechaDesde || movementDate >= filterFechaDesde
      const matchesFechaHasta = !filterFechaHasta || movementDate <= filterFechaHasta

      return matchesSearch && matchesTipo && matchesFechaDesde && matchesFechaHasta
    })
  }, [movements, searchTerm, filterTipo, filterFechaDesde, filterFechaHasta])

  // Calculate statistics
  const stats = useMemo(() => {
    const totalMovimientos = filteredMovements.length
    const entradas = filteredMovements.filter((m) =>
      ['entrada', 'transferencia_entrada', 'devolucion'].includes(m.tipo_movimiento)
    ).length
    const salidas = filteredMovements.filter((m) =>
      ['salida', 'transferencia_salida', 'vencimiento', 'merma', 'destruccion'].includes(m.tipo_movimiento)
    ).length
    const ajustes = filteredMovements.filter((m) => m.tipo_movimiento === 'ajuste').length

    const totalUnidadesEntradas = filteredMovements
      .filter((m) => ['entrada', 'transferencia_entrada', 'devolucion'].includes(m.tipo_movimiento))
      .reduce((sum, m) => sum + m.cantidad, 0)

    const totalUnidadesSalidas = filteredMovements
      .filter((m) => ['salida', 'transferencia_salida', 'vencimiento', 'merma', 'destruccion'].includes(m.tipo_movimiento))
      .reduce((sum, m) => sum + m.cantidad, 0)

    return {
      totalMovimientos,
      entradas,
      salidas,
      ajustes,
      totalUnidadesEntradas,
      totalUnidadesSalidas
    }
  }, [filteredMovements])

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver los movimientos</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Historial de Movimientos</h1>
          <p className="text-gray-600 mt-1">{centroSeleccionado.name}</p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            onClick={refresh}
            icon={<RefreshCw className="h-5 w-5" />}
          >
            Actualizar
          </Button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div>
            <p className="text-sm font-medium text-blue-600">Total Movimientos</p>
            <p className="text-3xl font-bold text-blue-900 mt-2">{stats.totalMovimientos}</p>
            <p className="text-xs text-blue-700 mt-1">Registrados en el período</p>
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div>
            <p className="text-sm font-medium text-green-600">Entradas</p>
            <p className="text-3xl font-bold text-green-900 mt-2">{stats.entradas}</p>
            <p className="text-xs text-green-700 mt-1">{stats.totalUnidadesEntradas.toLocaleString()} unidades</p>
          </div>
        </Card>

        <Card className="bg-red-50 border-l-4 border-l-red-500">
          <div>
            <p className="text-sm font-medium text-red-600">Salidas</p>
            <p className="text-3xl font-bold text-red-900 mt-2">{stats.salidas}</p>
            <p className="text-xs text-red-700 mt-1">{stats.totalUnidadesSalidas.toLocaleString()} unidades</p>
          </div>
        </Card>

        <Card className="bg-yellow-50 border-l-4 border-l-yellow-500">
          <div>
            <p className="text-sm font-medium text-yellow-600">Ajustes</p>
            <p className="text-3xl font-bold text-yellow-900 mt-2">{stats.ajustes}</p>
            <p className="text-xs text-yellow-700 mt-1">Correcciones de inventario</p>
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="space-y-4">
          <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
            <Filter className="h-5 w-5" />
            Filtros
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Search */}
            <div className="lg:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <Input
                  placeholder="Medicamento, lote, usuario o motivo..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>

            {/* Type filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Tipo de Movimiento</label>
              <select
                value={filterTipo}
                onChange={(e) => setFilterTipo(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                <option value="all">Todos</option>
                <option value="entrada">Entrada</option>
                <option value="salida">Salida</option>
                <option value="ajuste">Ajuste</option>
                <option value="transferencia_salida">Transferencia Salida</option>
                <option value="transferencia_entrada">Transferencia Entrada</option>
                <option value="vencimiento">Vencimiento</option>
                <option value="merma">Merma</option>
                <option value="devolucion">Devolución</option>
                <option value="destruccion">Destrucción</option>
              </select>
            </div>

            {/* Date range */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Rango de Fechas</label>
              <div className="flex gap-2">
                <Input
                  type="date"
                  value={filterFechaDesde}
                  onChange={(e) => setFilterFechaDesde(e.target.value)}
                  placeholder="Desde"
                  className="flex-1"
                />
                <Input
                  type="date"
                  value={filterFechaHasta}
                  onChange={(e) => setFilterFechaHasta(e.target.value)}
                  placeholder="Hasta"
                  className="flex-1"
                />
              </div>
            </div>
          </div>

          {/* Active filters count */}
          <div className="flex items-center justify-between pt-2 border-t">
            <p className="text-sm text-gray-600">
              Mostrando {filteredMovements.length} de {movements.length} movimientos
            </p>
            {(searchTerm || filterTipo !== 'all' || filterFechaDesde || filterFechaHasta) && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setSearchTerm('')
                  setFilterTipo('all')
                  setFilterFechaDesde('')
                  setFilterFechaHasta('')
                }}
              >
                Limpiar filtros
              </Button>
            )}
          </div>
        </div>
      </Card>

      {/* Timeline */}
      <Card>
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <TrendingUp className="h-5 w-5" />
          Línea de Tiempo
        </h3>
        <MovementTimeline movements={filteredMovements} loading={loading} />
      </Card>
    </div>
  )
}
