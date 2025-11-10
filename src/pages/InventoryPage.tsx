import { useState } from 'react'
import { Plus, Search, Filter, Download, FileText, FileSpreadsheet } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useBatches } from '../hooks/useBatches'
import { Button } from '../components/ui/Button'
import { useToast } from '../components/ui/Toast'
import type { Batch } from '../types'

export function InventoryPage() {
  const { centroSeleccionado } = useCentro()
  const { batches, loading, deleteBatch } = useBatches(centroSeleccionado?.id)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterEstado, setFilterEstado] = useState<string>('all')
  const toast = useToast()

  // Filtrar lotes
  const filteredBatches = batches.filter((batch) => {
    const medicationName = batch.medication?.nombre || ''
    const matchesSearch = medicationName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         batch.numero_lote.toLowerCase().includes(searchTerm.toLowerCase())

    const matchesFilter = filterEstado === 'all' || batch.estado === filterEstado

    return matchesSearch && matchesFilter
  })

  const handleDelete = async (id: string) => {
    if (!confirm('¿Estás seguro de eliminar este lote?')) return

    const { error } = await deleteBatch(id)
    if (error) {
      toast.error('Error al eliminar lote')
    } else {
      toast.success('Lote eliminado correctamente')
    }
  }

  const getDiasRestantes = (fechaCaducidad: string) => {
    const dias = Math.ceil((new Date(fechaCaducidad).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    return dias
  }

  const getEstadoColor = (estado: string) => {
    switch (estado) {
      case 'disponible': return 'bg-green-100 text-green-800'
      case 'cuarentena': return 'bg-yellow-100 text-yellow-800'
      case 'vencido': return 'bg-red-100 text-red-800'
      case 'agotado': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getAlertaVencimiento = (diasRestantes: number) => {
    if (diasRestantes < 0) return '🔴 Vencido'
    if (diasRestantes <= 30) return '🔴 Crítico'
    if (diasRestantes <= 60) return '🟡 Urgente'
    if (diasRestantes <= 90) return '🟢 Preventivo'
    return ''
  }

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver el inventario</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Inventario de Lotes</h1>
          <p className="text-gray-600 mt-1">{centroSeleccionado.name}</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => toast.info('Función en desarrollo')}
            icon={<Plus className="h-5 w-5" />}
          >
            Agregar Lote
          </Button>
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
                placeholder="Buscar por medicamento o número de lote..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          <div>
            <select
              value={filterEstado}
              onChange={(e) => setFilterEstado(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todos los estados</option>
              <option value="disponible">Disponible</option>
              <option value="cuarentena">Cuarentena</option>
              <option value="vencido">Vencido</option>
              <option value="agotado">Agotado</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="ml-auto text-sm text-gray-600">
            {filteredBatches.length} de {batches.length} lotes
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-500">Cargando...</p>
          </div>
        ) : filteredBatches.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64">
            <p className="text-gray-500 mb-2">No hay lotes registrados</p>
            <p className="text-sm text-gray-400">Primero ejecuta las pruebas en Supabase SQL Editor</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Medicamento</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lote</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vencimiento</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Proveedor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredBatches.map((batch) => {
                  const diasRestantes = getDiasRestantes(batch.fecha_caducidad)
                  const alerta = getAlertaVencimiento(diasRestantes)

                  return (
                    <tr key={batch.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {batch.medication?.nombre || 'Sin nombre'}
                          </div>
                          <div className="text-sm text-gray-500">
                            {batch.medication?.categoria || 'Sin categoría'}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900">{batch.numero_lote}</div>
                      </td>
                      <td className="px-6 py-4">
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {batch.cantidad_actual} {batch.medication?.unidad_medida || 'unidades'}
                          </div>
                          <div className="text-xs text-gray-500">
                            Inicial: {batch.cantidad_inicial}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div>
                          <div className="text-sm text-gray-900">
                            {new Date(batch.fecha_caducidad).toLocaleDateString()}
                          </div>
                          <div className="text-xs">
                            {alerta && <span>{alerta}</span>}
                            {!alerta && <span className="text-gray-500">{diasRestantes} días</span>}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(batch.estado)}`}>
                          {batch.estado}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900">
                          {batch.supplier?.nombre || 'Sin proveedor'}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => toast.info('Función en desarrollo')}
                            className="text-primary hover:text-primary-dark text-sm font-medium"
                          >
                            Ver
                          </button>
                          <button
                            onClick={() => toast.info('Función en desarrollo')}
                            className="text-secondary hover:text-secondary-dark text-sm font-medium"
                          >
                            Editar
                          </button>
                          <button
                            onClick={() => handleDelete(batch.id)}
                            className="text-red-600 hover:text-red-800 text-sm font-medium"
                          >
                            Eliminar
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
    </div>
  )
}
