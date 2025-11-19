/**
 * Página Principal de Catálogos Administrables
 * Sistema: SIGIMED v2.0
 * Permite gestionar todos los catálogos del sistema desde una interfaz unificada
 */

import { useState } from 'react'
import { Settings, Palette, Tag, FileText, TrendingUp, AlertCircle, Sliders } from 'lucide-react'
import { TablaCatalogo, accionesComunes } from '../components/catalogos/TablaCatalogo'
import { FormularioColor } from '../components/catalogos/FormularioColor'
import { FormularioEstado } from '../components/catalogos/FormularioEstado'
import { FormularioConfiguracion } from '../components/catalogos/FormularioConfiguracion'
import { FormularioTipoMovimiento } from '../components/catalogos/FormularioTipoMovimiento'
import { FormularioFormaFarmaceutica } from '../components/catalogos/FormularioFormaFarmaceutica'
import { FormularioPrioridad } from '../components/catalogos/FormularioPrioridad'
import {
  useCatalogoColores,
  useCatalogoEstados,
  useCatalogoTiposMovimiento,
  useCatalogoFormasFarmaceuticas,
  useCatalogoPrioridades,
  useCatalogoConfiguraciones
} from '../hooks/useCatalogos'
import {
  CatalogoColor,
  CatalogoEstado,
  CatalogoTipoMovimiento,
  CatalogoFormaFarmaceutica,
  CatalogoPrioridad,
  CatalogoConfiguracion
} from '../types'

type CatalogoTipo =
  | 'colores'
  | 'estados'
  | 'tipos_movimiento'
  | 'formas_farmaceuticas'
  | 'prioridades'
  | 'configuraciones'

export default function CatalogosPage() {
  // Estado para el catálogo seleccionado
  const [catalogoActivo, setCatalogoActivo] = useState<CatalogoTipo>('colores')

  // Estados para los formularios
  const [mostrarFormularioColor, setMostrarFormularioColor] = useState(false)
  const [colorSeleccionado, setColorSeleccionado] = useState<CatalogoColor | null>(null)

  const [mostrarFormularioEstado, setMostrarFormularioEstado] = useState(false)
  const [estadoSeleccionado, setEstadoSeleccionado] = useState<CatalogoEstado | null>(null)

  const [mostrarFormularioConfiguracion, setMostrarFormularioConfiguracion] = useState(false)
  const [configuracionSeleccionada, setConfiguracionSeleccionada] = useState<CatalogoConfiguracion | null>(null)

  const [mostrarFormularioTipoMovimiento, setMostrarFormularioTipoMovimiento] = useState(false)
  const [tipoMovimientoSeleccionado, setTipoMovimientoSeleccionado] = useState<CatalogoTipoMovimiento | null>(null)

  const [mostrarFormularioFormaFarmaceutica, setMostrarFormularioFormaFarmaceutica] = useState(false)
  const [formaFarmaceuticaSeleccionada, setFormaFarmaceuticaSeleccionada] = useState<CatalogoFormaFarmaceutica | null>(null)

  const [mostrarFormularioPrioridad, setMostrarFormularioPrioridad] = useState(false)
  const [prioridadSeleccionada, setPrioridadSeleccionada] = useState<CatalogoPrioridad | null>(null)

  // Hooks de catálogos
  const catalogoColores = useCatalogoColores()
  const catalogoEstados = useCatalogoEstados()
  const catalogoTiposMovimiento = useCatalogoTiposMovimiento()
  const catalogoFormasFarmaceuticas = useCatalogoFormasFarmaceuticas()
  const catalogoPrioridades = useCatalogoPrioridades()
  const catalogoConfiguraciones = useCatalogoConfiguraciones()

  // Definición de catálogos con sus configuraciones
  const catalogos = [
    {
      id: 'colores' as CatalogoTipo,
      nombre: 'Colores',
      icon: <Palette className="h-5 w-5" />,
      descripcion: 'Paleta de colores del sistema'
    },
    {
      id: 'estados' as CatalogoTipo,
      nombre: 'Estados',
      icon: <Tag className="h-5 w-5" />,
      descripcion: 'Estados por módulo'
    },
    {
      id: 'tipos_movimiento' as CatalogoTipo,
      nombre: 'Tipos de Movimiento',
      icon: <TrendingUp className="h-5 w-5" />,
      descripcion: 'Tipos de movimientos de inventario'
    },
    {
      id: 'formas_farmaceuticas' as CatalogoTipo,
      nombre: 'Formas Farmacéuticas',
      icon: <FileText className="h-5 w-5" />,
      descripcion: 'Formas farmacéuticas de medicamentos'
    },
    {
      id: 'prioridades' as CatalogoTipo,
      nombre: 'Prioridades',
      icon: <AlertCircle className="h-5 w-5" />,
      descripcion: 'Niveles de prioridad'
    },
    {
      id: 'configuraciones' as CatalogoTipo,
      nombre: 'Configuraciones',
      icon: <Sliders className="h-5 w-5" />,
      descripcion: 'Configuraciones generales del sistema'
    }
  ]

  // HANDLERS PARA COLORES
  const handleCrearColor = () => {
    setColorSeleccionado(null)
    setMostrarFormularioColor(true)
  }

  const handleEditarColor = (color: CatalogoColor) => {
    setColorSeleccionado(color)
    setMostrarFormularioColor(true)
  }

  const handleEliminarColor = async (color: CatalogoColor) => {
    if (confirm(`¿Estás seguro de eliminar el color "${color.nombre}"?`)) {
      const success = await catalogoColores.remove(color.id)
      if (success) {
        alert('Color eliminado correctamente')
      }
    }
  }

  const handleSubmitColor = async (data: Partial<CatalogoColor>) => {
    if (colorSeleccionado) {
      await catalogoColores.update(colorSeleccionado.id, data)
    } else {
      await catalogoColores.create(data)
    }
    setMostrarFormularioColor(false)
    setColorSeleccionado(null)
  }

  // HANDLERS PARA ESTADOS
  const handleCrearEstado = () => {
    setEstadoSeleccionado(null)
    setMostrarFormularioEstado(true)
  }

  const handleEditarEstado = (estado: CatalogoEstado) => {
    setEstadoSeleccionado(estado)
    setMostrarFormularioEstado(true)
  }

  const handleEliminarEstado = async (estado: CatalogoEstado) => {
    if (confirm(`¿Estás seguro de eliminar el estado "${estado.nombre}"?`)) {
      const success = await catalogoEstados.remove(estado.id)
      if (success) {
        alert('Estado eliminado correctamente')
      }
    }
  }

  const handleSubmitEstado = async (data: Partial<CatalogoEstado>) => {
    if (estadoSeleccionado) {
      await catalogoEstados.update(estadoSeleccionado.id, data)
    } else {
      await catalogoEstados.create(data)
    }
    setMostrarFormularioEstado(false)
    setEstadoSeleccionado(null)
  }

  // HANDLERS PARA CONFIGURACIONES
  const handleCrearConfiguracion = () => {
    setConfiguracionSeleccionada(null)
    setMostrarFormularioConfiguracion(true)
  }

  const handleEditarConfiguracion = (config: CatalogoConfiguracion) => {
    setConfiguracionSeleccionada(config)
    setMostrarFormularioConfiguracion(true)
  }

  const handleEliminarConfiguracion = async (config: CatalogoConfiguracion) => {
    if (confirm(`¿Estás seguro de eliminar la configuración "${config.nombre}"?`)) {
      const success = await catalogoConfiguraciones.remove(config.id)
      if (success) {
        alert('Configuración eliminada correctamente')
      }
    }
  }

  const handleSubmitConfiguracion = async (data: Partial<CatalogoConfiguracion>) => {
    if (configuracionSeleccionada) {
      await catalogoConfiguraciones.update(configuracionSeleccionada.id, data)
    } else {
      await catalogoConfiguraciones.create(data)
    }
    setMostrarFormularioConfiguracion(false)
    setConfiguracionSeleccionada(null)
  }

  // HANDLERS PARA TIPOS DE MOVIMIENTO
  const handleCrearTipoMovimiento = () => {
    setTipoMovimientoSeleccionado(null)
    setMostrarFormularioTipoMovimiento(true)
  }

  const handleEditarTipoMovimiento = (tipo: CatalogoTipoMovimiento) => {
    setTipoMovimientoSeleccionado(tipo)
    setMostrarFormularioTipoMovimiento(true)
  }

  const handleEliminarTipoMovimiento = async (tipo: CatalogoTipoMovimiento) => {
    if (confirm(`¿Estás seguro de eliminar el tipo de movimiento "${tipo.nombre}"?`)) {
      const success = await catalogoTiposMovimiento.remove(tipo.id)
      if (success) {
        alert('Tipo de movimiento eliminado correctamente')
      }
    }
  }

  const handleSubmitTipoMovimiento = async (data: Partial<CatalogoTipoMovimiento>) => {
    if (tipoMovimientoSeleccionado) {
      await catalogoTiposMovimiento.update(tipoMovimientoSeleccionado.id, data)
    } else {
      await catalogoTiposMovimiento.create(data)
    }
    setMostrarFormularioTipoMovimiento(false)
    setTipoMovimientoSeleccionado(null)
  }

  // HANDLERS PARA FORMAS FARMACÉUTICAS
  const handleCrearFormaFarmaceutica = () => {
    setFormaFarmaceuticaSeleccionada(null)
    setMostrarFormularioFormaFarmaceutica(true)
  }

  const handleEditarFormaFarmaceutica = (forma: CatalogoFormaFarmaceutica) => {
    setFormaFarmaceuticaSeleccionada(forma)
    setMostrarFormularioFormaFarmaceutica(true)
  }

  const handleEliminarFormaFarmaceutica = async (forma: CatalogoFormaFarmaceutica) => {
    if (confirm(`¿Estás seguro de eliminar la forma farmacéutica "${forma.nombre}"?`)) {
      const success = await catalogoFormasFarmaceuticas.remove(forma.id)
      if (success) {
        alert('Forma farmacéutica eliminada correctamente')
      }
    }
  }

  const handleSubmitFormaFarmaceutica = async (data: Partial<CatalogoFormaFarmaceutica>) => {
    if (formaFarmaceuticaSeleccionada) {
      await catalogoFormasFarmaceuticas.update(formaFarmaceuticaSeleccionada.id, data)
    } else {
      await catalogoFormasFarmaceuticas.create(data)
    }
    setMostrarFormularioFormaFarmaceutica(false)
    setFormaFarmaceuticaSeleccionada(null)
  }

  // HANDLERS PARA PRIORIDADES
  const handleCrearPrioridad = () => {
    setPrioridadSeleccionada(null)
    setMostrarFormularioPrioridad(true)
  }

  const handleEditarPrioridad = (prioridad: CatalogoPrioridad) => {
    setPrioridadSeleccionada(prioridad)
    setMostrarFormularioPrioridad(true)
  }

  const handleEliminarPrioridad = async (prioridad: CatalogoPrioridad) => {
    if (confirm(`¿Estás seguro de eliminar la prioridad "${prioridad.nombre}"?`)) {
      const success = await catalogoPrioridades.remove(prioridad.id)
      if (success) {
        alert('Prioridad eliminada correctamente')
      }
    }
  }

  const handleSubmitPrioridad = async (data: Partial<CatalogoPrioridad>) => {
    if (prioridadSeleccionada) {
      await catalogoPrioridades.update(prioridadSeleccionada.id, data)
    } else {
      await catalogoPrioridades.create(data)
    }
    setMostrarFormularioPrioridad(false)
    setPrioridadSeleccionada(null)
  }

  // Renderizar contenido según catálogo activo
  const renderCatalogoActivo = () => {
    switch (catalogoActivo) {
      case 'colores':
        return (
          <>
            <TablaCatalogo
              titulo="Catálogo de Colores"
              descripcion="Gestiona la paleta de colores del sistema"
              items={catalogoColores.items}
              loading={catalogoColores.loading}
              error={catalogoColores.error}
              columnas={[
                { key: 'nombre', label: 'Nombre', width: '20%' },
                {
                  key: 'codigo_hex',
                  label: 'Color',
                  width: '15%',
                  render: (item) => (
                    <div className="flex items-center gap-2">
                      <div
                        className="w-8 h-8 rounded border-2 border-gray-300"
                        style={{ backgroundColor: item.codigo_hex }}
                      />
                      <span className="text-xs font-mono">{item.codigo_hex}</span>
                    </div>
                  )
                },
                { key: 'categoria', label: 'Categoría', width: '15%' },
                { key: 'uso', label: 'Uso', width: '35%' },
                {
                  key: 'es_activo',
                  label: 'Estado',
                  width: '15%',
                  render: (item) => (
                    <span
                      className={`px-2 py-1 text-xs rounded-full ${
                        item.es_activo ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {item.es_activo ? 'Activo' : 'Inactivo'}
                    </span>
                  )
                }
              ]}
              acciones={[
                {
                  icon: accionesComunes.editar,
                  label: 'Editar',
                  onClick: handleEditarColor
                },
                {
                  icon: accionesComunes.eliminar,
                  label: 'Eliminar',
                  onClick: handleEliminarColor,
                  variant: 'danger'
                }
              ]}
              onCrear={handleCrearColor}
              onRefrescar={catalogoColores.refresh}
              filtrosSelect={[
                {
                  key: 'categoria',
                  label: 'Categoría',
                  opciones: [
                    { value: 'principal', label: 'Principal' },
                    { value: 'estados', label: 'Estados' },
                    { value: 'graficos', label: 'Gráficos' },
                    { value: 'alertas', label: 'Alertas' },
                    { value: 'general', label: 'General' }
                  ]
                },
                {
                  key: 'es_activo',
                  label: 'Estado',
                  opciones: [
                    { value: 'true', label: 'Activos' },
                    { value: 'false', label: 'Inactivos' }
                  ]
                }
              ]}
              onFiltrar={(filtros) => catalogoColores.filter(filtros)}
              onLimpiarFiltros={catalogoColores.clearFilters}
            />
            {mostrarFormularioColor && (
              <FormularioColor
                color={colorSeleccionado}
                onSubmit={handleSubmitColor}
                onCancel={() => {
                  setMostrarFormularioColor(false)
                  setColorSeleccionado(null)
                }}
                loading={catalogoColores.loading}
              />
            )}
          </>
        )

      case 'estados':
        return (
          <>
            <TablaCatalogo
              titulo="Catálogo de Estados"
              descripcion="Gestiona los estados de cada módulo del sistema"
              items={catalogoEstados.items}
              loading={catalogoEstados.loading}
              error={catalogoEstados.error}
              columnas={[
                { key: 'codigo', label: 'Código', width: '15%' },
                { key: 'nombre', label: 'Nombre', width: '20%' },
                { key: 'modulo', label: 'Módulo', width: '15%' },
                { key: 'descripcion', label: 'Descripción', width: '35%' },
                {
                  key: 'es_activo',
                  label: 'Estado',
                  width: '15%',
                  render: (item) => (
                    <span
                      className={`px-2 py-1 text-xs rounded-full ${
                        item.es_activo ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {item.es_activo ? 'Activo' : 'Inactivo'}
                    </span>
                  )
                }
              ]}
              acciones={[
                {
                  icon: accionesComunes.editar,
                  label: 'Editar',
                  onClick: handleEditarEstado
                },
                {
                  icon: accionesComunes.eliminar,
                  label: 'Eliminar',
                  onClick: handleEliminarEstado,
                  variant: 'danger'
                }
              ]}
              onCrear={handleCrearEstado}
              onRefrescar={catalogoEstados.refresh}
              filtrosSelect={[
                {
                  key: 'modulo',
                  label: 'Módulo',
                  opciones: [
                    { value: 'medicamentos', label: 'Medicamentos' },
                    { value: 'requisiciones', label: 'Requisiciones' },
                    { value: 'transferencias', label: 'Transferencias' },
                    { value: 'contratos', label: 'Contratos' },
                    { value: 'general', label: 'General' }
                  ]
                }
              ]}
              onFiltrar={(filtros) => catalogoEstados.filter(filtros)}
              onLimpiarFiltros={catalogoEstados.clearFilters}
            />
            {mostrarFormularioEstado && (
              <FormularioEstado
                estado={estadoSeleccionado}
                onSubmit={handleSubmitEstado}
                onCancel={() => {
                  setMostrarFormularioEstado(false)
                  setEstadoSeleccionado(null)
                }}
                loading={catalogoEstados.loading}
              />
            )}
          </>
        )

      case 'configuraciones':
        return (
          <>
            <TablaCatalogo
              titulo="Catálogo de Configuraciones"
              descripcion="Gestiona las configuraciones generales del sistema"
              items={catalogoConfiguraciones.items}
              loading={catalogoConfiguraciones.loading}
              error={catalogoConfiguraciones.error}
              columnas={[
                { key: 'nombre', label: 'Nombre', width: '25%' },
                { key: 'clave', label: 'Clave', width: '20%' },
                {
                  key: 'valor',
                  label: 'Valor',
                  width: '20%',
                  render: (item) => (
                    <span className={item.es_sensible ? 'blur-sm select-none' : ''}>
                      {item.es_sensible ? '••••••••' : item.valor}
                    </span>
                  )
                },
                { key: 'categoria', label: 'Categoría', width: '15%' },
                {
                  key: 'es_activo',
                  label: 'Estado',
                  width: '20%',
                  render: (item) => (
                    <div className="flex flex-col gap-1">
                      <span
                        className={`px-2 py-1 text-xs rounded-full w-fit ${
                          item.es_activo ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                        }`}
                      >
                        {item.es_activo ? 'Activo' : 'Inactivo'}
                      </span>
                      {item.es_sensible && (
                        <span className="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800 w-fit">
                          Sensible
                        </span>
                      )}
                    </div>
                  )
                }
              ]}
              acciones={[
                {
                  icon: accionesComunes.editar,
                  label: 'Editar',
                  onClick: handleEditarConfiguracion
                },
                {
                  icon: accionesComunes.eliminar,
                  label: 'Eliminar',
                  onClick: handleEliminarConfiguracion,
                  variant: 'danger',
                  show: (item) => !item.es_requerido
                }
              ]}
              onCrear={handleCrearConfiguracion}
              onRefrescar={catalogoConfiguraciones.refresh}
              filtrosSelect={[
                {
                  key: 'categoria',
                  label: 'Categoría',
                  opciones: [
                    { value: 'sistema', label: 'Sistema' },
                    { value: 'alertas', label: 'Alertas' },
                    { value: 'notificaciones', label: 'Notificaciones' },
                    { value: 'seguridad', label: 'Seguridad' },
                    { value: 'general', label: 'General' }
                  ]
                }
              ]}
              onFiltrar={(filtros) => catalogoConfiguraciones.filter(filtros)}
              onLimpiarFiltros={catalogoConfiguraciones.clearFilters}
            />
            {mostrarFormularioConfiguracion && (
              <FormularioConfiguracion
                configuracion={configuracionSeleccionada}
                onSubmit={handleSubmitConfiguracion}
                onCancel={() => {
                  setMostrarFormularioConfiguracion(false)
                  setConfiguracionSeleccionada(null)
                }}
                loading={catalogoConfiguraciones.loading}
              />
            )}
          </>
        )

      case 'tipos_movimiento':
        return (
          <>
            <TablaCatalogo
              titulo="Catálogo de Tipos de Movimiento"
              descripcion="Gestiona los tipos de movimientos de inventario"
              items={catalogoTiposMovimiento.items}
              loading={catalogoTiposMovimiento.loading}
              error={catalogoTiposMovimiento.error}
              columnas={[
                { key: 'codigo', label: 'Código', width: '15%' },
                { key: 'nombre', label: 'Nombre', width: '20%' },
                { key: 'tipo', label: 'Tipo', width: '10%' },
                { key: 'descripcion', label: 'Descripción', width: '30%' },
                {
                  key: 'afecta_stock',
                  label: 'Opciones',
                  width: '25%',
                  render: (item) => (
                    <div className="flex flex-wrap gap-1">
                      {item.afecta_stock && (
                        <span className="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">
                          Afecta stock
                        </span>
                      )}
                      {item.requiere_documento && (
                        <span className="px-2 py-1 text-xs rounded-full bg-purple-100 text-purple-800">
                          Req. documento
                        </span>
                      )}
                      {item.requiere_aprobacion && (
                        <span className="px-2 py-1 text-xs rounded-full bg-orange-100 text-orange-800">
                          Req. aprobación
                        </span>
                      )}
                    </div>
                  )
                }
              ]}
              acciones={[
                {
                  icon: accionesComunes.editar,
                  label: 'Editar',
                  onClick: handleEditarTipoMovimiento
                },
                {
                  icon: accionesComunes.eliminar,
                  label: 'Eliminar',
                  onClick: handleEliminarTipoMovimiento,
                  variant: 'danger'
                }
              ]}
              onCrear={handleCrearTipoMovimiento}
              onRefrescar={catalogoTiposMovimiento.refresh}
              filtrosSelect={[
                {
                  key: 'tipo',
                  label: 'Tipo',
                  opciones: [
                    { value: 'entrada', label: 'Entrada' },
                    { value: 'salida', label: 'Salida' },
                    { value: 'ajuste', label: 'Ajuste' },
                    { value: 'transferencia', label: 'Transferencia' }
                  ]
                }
              ]}
              onFiltrar={(filtros) => catalogoTiposMovimiento.filter(filtros)}
              onLimpiarFiltros={catalogoTiposMovimiento.clearFilters}
            />
            {mostrarFormularioTipoMovimiento && (
              <FormularioTipoMovimiento
                tipoMovimiento={tipoMovimientoSeleccionado}
                onSubmit={handleSubmitTipoMovimiento}
                onCancel={() => {
                  setMostrarFormularioTipoMovimiento(false)
                  setTipoMovimientoSeleccionado(null)
                }}
                loading={catalogoTiposMovimiento.loading}
              />
            )}
          </>
        )

      case 'formas_farmaceuticas':
        return (
          <>
            <TablaCatalogo
              titulo="Catálogo de Formas Farmacéuticas"
              descripcion="Gestiona las formas farmacéuticas de los medicamentos"
              items={catalogoFormasFarmaceuticas.items}
              loading={catalogoFormasFarmaceuticas.loading}
              error={catalogoFormasFarmaceuticas.error}
              columnas={[
                { key: 'codigo', label: 'Código', width: '10%' },
                { key: 'nombre', label: 'Nombre', width: '20%' },
                { key: 'categoria', label: 'Categoría', width: '10%' },
                { key: 'via_administracion', label: 'Vía', width: '15%' },
                { key: 'unidad_medida_default', label: 'Unidad', width: '10%' },
                {
                  key: 'requiere_refrigeracion',
                  label: 'Almacenamiento',
                  width: '20%',
                  render: (item) => (
                    <div className="flex flex-col gap-1">
                      {item.requiere_refrigeracion && (
                        <span className="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800 w-fit">
                          Refrigeración
                        </span>
                      )}
                      {item.requiere_cadena_frio && (
                        <span className="px-2 py-1 text-xs rounded-full bg-cyan-100 text-cyan-800 w-fit">
                          Cadena de frío
                        </span>
                      )}
                      {!item.requiere_refrigeracion && !item.requiere_cadena_frio && (
                        <span className="text-xs text-gray-500">Normal</span>
                      )}
                    </div>
                  )
                },
                {
                  key: 'es_activo',
                  label: 'Estado',
                  width: '15%',
                  render: (item) => (
                    <span
                      className={`px-2 py-1 text-xs rounded-full ${
                        item.es_activo ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {item.es_activo ? 'Activo' : 'Inactivo'}
                    </span>
                  )
                }
              ]}
              acciones={[
                {
                  icon: accionesComunes.editar,
                  label: 'Editar',
                  onClick: handleEditarFormaFarmaceutica
                },
                {
                  icon: accionesComunes.eliminar,
                  label: 'Eliminar',
                  onClick: handleEliminarFormaFarmaceutica,
                  variant: 'danger'
                }
              ]}
              onCrear={handleCrearFormaFarmaceutica}
              onRefrescar={catalogoFormasFarmaceuticas.refresh}
              filtrosSelect={[
                {
                  key: 'categoria',
                  label: 'Categoría',
                  opciones: [
                    { value: 'solida', label: 'Sólida' },
                    { value: 'liquida', label: 'Líquida' },
                    { value: 'semisólida', label: 'Semisólida' },
                    { value: 'gaseosa', label: 'Gaseosa' },
                    { value: 'parental', label: 'Parental' }
                  ]
                }
              ]}
              onFiltrar={(filtros) => catalogoFormasFarmaceuticas.filter(filtros)}
              onLimpiarFiltros={catalogoFormasFarmaceuticas.clearFilters}
            />
            {mostrarFormularioFormaFarmaceutica && (
              <FormularioFormaFarmaceutica
                formaFarmaceutica={formaFarmaceuticaSeleccionada}
                onSubmit={handleSubmitFormaFarmaceutica}
                onCancel={() => {
                  setMostrarFormularioFormaFarmaceutica(false)
                  setFormaFarmaceuticaSeleccionada(null)
                }}
                loading={catalogoFormasFarmaceuticas.loading}
              />
            )}
          </>
        )

      case 'prioridades':
        return (
          <>
            <TablaCatalogo
              titulo="Catálogo de Prioridades"
              descripcion="Gestiona los niveles de prioridad del sistema"
              items={catalogoPrioridades.items}
              loading={catalogoPrioridades.loading}
              error={catalogoPrioridades.error}
              columnas={[
                { key: 'codigo', label: 'Código', width: '10%' },
                {
                  key: 'nivel',
                  label: 'Nivel',
                  width: '8%',
                  render: (item) => (
                    <span className="font-semibold text-lg">{item.nivel}</span>
                  )
                },
                { key: 'nombre', label: 'Nombre', width: '15%' },
                { key: 'modulo', label: 'Módulo', width: '12%' },
                {
                  key: 'dias_respuesta_esperado',
                  label: 'Días respuesta',
                  width: '12%',
                  render: (item) => item.dias_respuesta_esperado || '-'
                },
                {
                  key: 'requiere_notificacion',
                  label: 'Opciones',
                  width: '23%',
                  render: (item) => (
                    <div className="flex flex-wrap gap-1">
                      {item.requiere_notificacion && (
                        <span className="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                          Notifica
                        </span>
                      )}
                      {item.nivel && item.nivel <= 2 && (
                        <span className="px-2 py-1 text-xs rounded-full bg-red-100 text-red-800">
                          Alta prioridad
                        </span>
                      )}
                    </div>
                  )
                },
                {
                  key: 'es_activo',
                  label: 'Estado',
                  width: '20%',
                  render: (item) => (
                    <span
                      className={`px-2 py-1 text-xs rounded-full ${
                        item.es_activo ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {item.es_activo ? 'Activo' : 'Inactivo'}
                    </span>
                  )
                }
              ]}
              acciones={[
                {
                  icon: accionesComunes.editar,
                  label: 'Editar',
                  onClick: handleEditarPrioridad
                },
                {
                  icon: accionesComunes.eliminar,
                  label: 'Eliminar',
                  onClick: handleEliminarPrioridad,
                  variant: 'danger'
                }
              ]}
              onCrear={handleCrearPrioridad}
              onRefrescar={catalogoPrioridades.refresh}
              filtrosSelect={[
                {
                  key: 'modulo',
                  label: 'Módulo',
                  opciones: [
                    { value: 'requisiciones', label: 'Requisiciones' },
                    { value: 'transferencias', label: 'Transferencias' },
                    { value: 'alertas', label: 'Alertas' },
                    { value: 'notificaciones', label: 'Notificaciones' },
                    { value: 'general', label: 'General' }
                  ]
                }
              ]}
              onFiltrar={(filtros) => catalogoPrioridades.filter(filtros)}
              onLimpiarFiltros={catalogoPrioridades.clearFilters}
            />
            {mostrarFormularioPrioridad && (
              <FormularioPrioridad
                prioridad={prioridadSeleccionada}
                onSubmit={handleSubmitPrioridad}
                onCancel={() => {
                  setMostrarFormularioPrioridad(false)
                  setPrioridadSeleccionada(null)
                }}
                loading={catalogoPrioridades.loading}
              />
            )}
          </>
        )

      default:
        return (
          <div className="bg-white rounded-lg shadow-lg p-12 text-center">
            <p className="text-gray-500">Selecciona un catálogo del menú superior</p>
          </div>
        )
    }
  }

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      {/* Encabezado */}
      <div className="flex items-center gap-3">
        <Settings className="h-8 w-8 text-blue-600" />
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Catálogos del Sistema</h1>
          <p className="text-gray-600">Gestiona los catálogos administrables del sistema</p>
        </div>
      </div>

      {/* Tabs de catálogos */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="border-b border-gray-200">
          <nav className="flex -mb-px overflow-x-auto">
            {catalogos.map((catalogo) => (
              <button
                key={catalogo.id}
                onClick={() => setCatalogoActivo(catalogo.id)}
                className={`flex items-center gap-2 px-6 py-4 text-sm font-medium border-b-2 transition-colors whitespace-nowrap ${
                  catalogoActivo === catalogo.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {catalogo.icon}
                {catalogo.nombre}
              </button>
            ))}
          </nav>
        </div>
      </div>

      {/* Contenido del catálogo activo */}
      {renderCatalogoActivo()}
    </div>
  )
}
