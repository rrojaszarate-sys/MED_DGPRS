/**
 * Componente Genérico de Tabla para Catálogos Administrables
 * Sistema: SIGIMED v2.0
 * Proporciona funcionalidad completa de visualización, filtrado y acciones CRUD
 */

import React, { useState } from 'react'
import { Search, Plus, Edit2, Trash2, RefreshCw, Filter, X } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'

interface Columna<T> {
  key: keyof T | string
  label: string
  render?: (item: T) => React.ReactNode
  sortable?: boolean
  width?: string
}

interface AccionTabla<T> {
  icon: React.ReactNode
  label: string
  onClick: (item: T) => void
  variant?: 'default' | 'danger' | 'success' | 'warning'
  show?: (item: T) => boolean
}

interface FiltroSelect {
  key: string
  label: string
  opciones: { value: string; label: string }[]
}

interface TablaCatalogoProps<T> {
  // Datos
  items: T[]
  loading: boolean
  error: string | null

  // Configuración de columnas
  columnas: Columna<T>[]

  // Acciones
  acciones?: AccionTabla<T>[]
  onCrear?: () => void
  onRefrescar?: () => void

  // Filtros
  filtrosSelect?: FiltroSelect[]
  onFiltrar?: (filtros: Record<string, any>) => void
  onLimpiarFiltros?: () => void

  // UI
  titulo: string
  descripcion?: string
  textoVacio?: string
  mostrarBusqueda?: boolean
  mostrarBotonCrear?: boolean
  mostrarBotonRefrescar?: boolean
}

export function TablaCatalogo<T extends { id: string; es_activo?: boolean }>({
  items,
  loading,
  error,
  columnas,
  acciones = [],
  onCrear,
  onRefrescar,
  filtrosSelect = [],
  onFiltrar,
  onLimpiarFiltros,
  titulo,
  descripcion,
  textoVacio = 'No hay registros para mostrar',
  mostrarBusqueda = true,
  mostrarBotonCrear = true,
  mostrarBotonRefrescar = true
}: TablaCatalogoProps<T>) {
  const [busqueda, setBusqueda] = useState('')
  const [filtrosActivos, setFiltrosActivos] = useState<Record<string, string>>({})
  const [mostrarFiltros, setMostrarFiltros] = useState(false)

  // Manejar cambio de búsqueda
  const handleBusqueda = (valor: string) => {
    setBusqueda(valor)
    if (onFiltrar) {
      onFiltrar({ ...filtrosActivos, busqueda: valor })
    }
  }

  // Manejar cambio de filtros
  const handleFiltroChange = (key: string, value: string) => {
    const nuevosFiltros = { ...filtrosActivos, [key]: value }
    setFiltrosActivos(nuevosFiltros)
    if (onFiltrar) {
      onFiltrar({ ...nuevosFiltros, busqueda })
    }
  }

  // Limpiar filtros
  const handleLimpiarFiltros = () => {
    setBusqueda('')
    setFiltrosActivos({})
    if (onLimpiarFiltros) {
      onLimpiarFiltros()
    }
  }

  // Hay filtros activos
  const hayFiltrosActivos = busqueda || Object.keys(filtrosActivos).some(k => filtrosActivos[k])

  return (
    <div className="space-y-4">
      {/* Encabezado */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">{titulo}</h2>
          {descripcion && <p className="mt-1 text-sm text-gray-500">{descripcion}</p>}
        </div>

        <div className="flex gap-2">
          {mostrarBotonRefrescar && onRefrescar && (
            <Button variant="outline" size="sm" onClick={onRefrescar} disabled={loading}>
              <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            </Button>
          )}

          {mostrarBotonCrear && onCrear && (
            <Button onClick={onCrear} size="sm">
              <Plus className="h-4 w-4 mr-2" />
              Nuevo
            </Button>
          )}
        </div>
      </div>

      {/* Barra de búsqueda y filtros */}
      <div className="space-y-3">
        <div className="flex gap-3">
          {/* Búsqueda */}
          {mostrarBusqueda && (
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  type="text"
                  placeholder="Buscar..."
                  value={busqueda}
                  onChange={(e) => handleBusqueda(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
          )}

          {/* Botón de filtros */}
          {filtrosSelect.length > 0 && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => setMostrarFiltros(!mostrarFiltros)}
              className={hayFiltrosActivos ? 'border-blue-500 text-blue-600' : ''}
            >
              <Filter className="h-4 w-4 mr-2" />
              Filtros
              {hayFiltrosActivos && (
                <span className="ml-2 px-2 py-0.5 text-xs bg-blue-100 text-blue-600 rounded-full">
                  {Object.keys(filtrosActivos).filter(k => filtrosActivos[k]).length + (busqueda ? 1 : 0)}
                </span>
              )}
            </Button>
          )}

          {/* Limpiar filtros */}
          {hayFiltrosActivos && (
            <Button variant="outline" size="sm" onClick={handleLimpiarFiltros}>
              <X className="h-4 w-4 mr-2" />
              Limpiar
            </Button>
          )}
        </div>

        {/* Panel de filtros */}
        {mostrarFiltros && filtrosSelect.length > 0 && (
          <div className="p-4 bg-gray-50 rounded-lg border border-gray-200 space-y-3">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              {filtrosSelect.map(filtro => (
                <div key={filtro.key}>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    {filtro.label}
                  </label>
                  <Select
                    value={filtrosActivos[filtro.key] || ''}
                    onChange={(e) => handleFiltroChange(filtro.key, e.target.value)}
                  >
                    <option value="">Todos</option>
                    {filtro.opciones.map(opcion => (
                      <option key={opcion.value} value={opcion.value}>
                        {opcion.label}
                      </option>
                    ))}
                  </Select>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Error */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-sm text-red-600">{error}</p>
        </div>
      )}

      {/* Tabla */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                {columnas.map((columna, index) => (
                  <th
                    key={index}
                    className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    style={{ width: columna.width }}
                  >
                    {columna.label}
                  </th>
                ))}
                {acciones.length > 0 && (
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Acciones
                  </th>
                )}
              </tr>
            </thead>

            <tbody className="bg-white divide-y divide-gray-200">
              {loading ? (
                <tr>
                  <td colSpan={columnas.length + (acciones.length > 0 ? 1 : 0)} className="px-6 py-12 text-center">
                    <div className="flex justify-center">
                      <RefreshCw className="h-6 w-6 animate-spin text-gray-400" />
                    </div>
                  </td>
                </tr>
              ) : items.length === 0 ? (
                <tr>
                  <td colSpan={columnas.length + (acciones.length > 0 ? 1 : 0)} className="px-6 py-12 text-center">
                    <p className="text-gray-500">{textoVacio}</p>
                  </td>
                </tr>
              ) : (
                items.map((item) => (
                  <tr
                    key={item.id}
                    className={`hover:bg-gray-50 transition-colors ${
                      item.es_activo === false ? 'opacity-50 bg-gray-50' : ''
                    }`}
                  >
                    {columnas.map((columna, index) => (
                      <td key={index} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {columna.render
                          ? columna.render(item)
                          : String(item[columna.key as keyof T] || '-')}
                      </td>
                    ))}

                    {acciones.length > 0 && (
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex justify-end gap-2">
                          {acciones.map((accion, index) => {
                            const mostrar = accion.show ? accion.show(item) : true
                            if (!mostrar) return null

                            return (
                              <button
                                key={index}
                                onClick={() => accion.onClick(item)}
                                className={`p-1.5 rounded hover:bg-gray-100 transition-colors ${
                                  accion.variant === 'danger'
                                    ? 'text-red-600 hover:bg-red-50'
                                    : accion.variant === 'success'
                                    ? 'text-green-600 hover:bg-green-50'
                                    : accion.variant === 'warning'
                                    ? 'text-yellow-600 hover:bg-yellow-50'
                                    : 'text-gray-600'
                                }`}
                                title={accion.label}
                              >
                                {accion.icon}
                              </button>
                            )
                          })}
                        </div>
                      </td>
                    )}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pie de tabla con contador */}
        {!loading && items.length > 0 && (
          <div className="px-6 py-3 bg-gray-50 border-t border-gray-200">
            <p className="text-sm text-gray-700">
              Mostrando <span className="font-medium">{items.length}</span> registro{items.length !== 1 ? 's' : ''}
              {hayFiltrosActivos && ' (filtrados)'}
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

// Componentes de acción predefinidos para reutilizar
export const accionesComunes = {
  editar: <Edit2 className="h-4 w-4" />,
  eliminar: <Trash2 className="h-4 w-4" />
}
