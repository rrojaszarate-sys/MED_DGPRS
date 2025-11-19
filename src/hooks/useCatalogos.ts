/**
 * Hook genérico para gestión de catálogos administrables
 * Sistema: SIGIMED v2.0
 * Proporciona funcionalidad CRUD completa con manejo de estados y errores
 */

import { useState, useEffect, useCallback } from 'react'
import { supabase } from '../lib/supabase'
import {
  CatalogoColor,
  CatalogoEstado,
  CatalogoTipoMovimiento,
  CatalogoFormaFarmaceutica,
  CatalogoPrioridad,
  CatalogoConfiguracion,
  CatalogoFiltros
} from '../types'

// ============================================
// TIPO GENÉRICO PARA CATÁLOGOS
// ============================================

type CatalogoType =
  | CatalogoColor
  | CatalogoEstado
  | CatalogoTipoMovimiento
  | CatalogoFormaFarmaceutica
  | CatalogoPrioridad
  | CatalogoConfiguracion

interface UseCatalogoResult<T extends CatalogoType> {
  items: T[]
  loading: boolean
  error: string | null
  // Operaciones CRUD
  create: (data: Partial<T>) => Promise<T | null>
  update: (id: string, data: Partial<T>) => Promise<T | null>
  remove: (id: string) => Promise<boolean>
  getById: (id: string) => Promise<T | null>
  // Utilidades
  refresh: () => Promise<void>
  filter: (filtros: CatalogoFiltros) => void
  clearFilters: () => void
  // Estado de filtros
  filtrosActivos: CatalogoFiltros
}

// ============================================
// HOOK GENÉRICO PARA CATÁLOGOS
// ============================================

function useCatalogo<T extends CatalogoType>(
  tableName: string,
  includes?: string[]
): UseCatalogoResult<T> {
  const [items, setItems] = useState<T[]>([])
  const [itemsFiltrados, setItemsFiltrados] = useState<T[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [filtrosActivos, setFiltrosActivos] = useState<CatalogoFiltros>({})

  // Cargar datos iniciales
  const fetchItems = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from(tableName)
        .select(includes ? `*, ${includes.join(', ')}` : '*')
        .order('orden', { ascending: true })

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      setItems((data as unknown) as T[])
      setItemsFiltrados((data as unknown) as T[])
    } catch (err) {
      console.error(`Error al cargar ${tableName}:`, err)
      setError(err instanceof Error ? err.message : 'Error desconocido')
    } finally {
      setLoading(false)
    }
  }, [tableName, includes])

  // Crear nuevo registro
  const create = useCallback(
    async (data: Partial<T>): Promise<T | null> => {
      try {
        setError(null)

        // Agregar metadatos de auditoría
        const dataWithAudit = {
          ...data,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }

        const { data: newItem, error: createError } = await supabase
          .from(tableName)
          .insert(dataWithAudit)
          .select()
          .single()

        if (createError) throw createError

        // Actualizar estado local
        setItems(prev => [...prev, newItem as T])
        await fetchItems() // Refrescar para obtener relaciones

        return newItem as T
      } catch (err) {
        console.error(`Error al crear en ${tableName}:`, err)
        setError(err instanceof Error ? err.message : 'Error al crear registro')
        return null
      }
    },
    [tableName, fetchItems]
  )

  // Actualizar registro existente
  const update = useCallback(
    async (id: string, data: Partial<T>): Promise<T | null> => {
      try {
        setError(null)

        // Agregar metadatos de auditoría
        const dataWithAudit = {
          ...data,
          updated_at: new Date().toISOString()
        }

        const { data: updatedItem, error: updateError } = await supabase
          .from(tableName)
          .update(dataWithAudit)
          .eq('id', id)
          .select()
          .single()

        if (updateError) throw updateError

        // Actualizar estado local
        setItems(prev => prev.map(item => (item.id === id ? updatedItem as T : item)))
        await fetchItems() // Refrescar para obtener relaciones

        return updatedItem as T
      } catch (err) {
        console.error(`Error al actualizar en ${tableName}:`, err)
        setError(err instanceof Error ? err.message : 'Error al actualizar registro')
        return null
      }
    },
    [tableName, fetchItems]
  )

  // Eliminar registro (soft delete si es posible)
  const remove = useCallback(
    async (id: string): Promise<boolean> => {
      try {
        setError(null)

        // Intentar soft delete primero (cambiar es_activo a false)
        const { error: updateError } = await supabase
          .from(tableName)
          .update({ es_activo: false, updated_at: new Date().toISOString() })
          .eq('id', id)

        if (updateError) {
          // Si falla el soft delete, intentar delete físico
          const { error: deleteError } = await supabase
            .from(tableName)
            .delete()
            .eq('id', id)

          if (deleteError) throw deleteError
        }

        // Actualizar estado local
        setItems(prev => prev.filter(item => item.id !== id))
        await fetchItems()

        return true
      } catch (err) {
        console.error(`Error al eliminar en ${tableName}:`, err)
        setError(err instanceof Error ? err.message : 'Error al eliminar registro')
        return false
      }
    },
    [tableName, fetchItems]
  )

  // Obtener registro por ID
  const getById = useCallback(
    async (id: string): Promise<T | null> => {
      try {
        setError(null)

        const { data, error: fetchError } = await supabase
          .from(tableName)
          .select(includes ? `*, ${includes.join(', ')}` : '*')
          .eq('id', id)
          .single()

        if (fetchError) throw fetchError

        return (data as unknown) as T
      } catch (err) {
        console.error(`Error al obtener registro de ${tableName}:`, err)
        setError(err instanceof Error ? err.message : 'Error al obtener registro')
        return null
      }
    },
    [tableName, includes]
  )

  // Refrescar datos
  const refresh = useCallback(async () => {
    await fetchItems()
  }, [fetchItems])

  // Aplicar filtros
  const filter = useCallback(
    (filtros: CatalogoFiltros) => {
      setFiltrosActivos(filtros)

      let resultados = [...items]

      // Filtro por activo/inactivo
      if (filtros.es_activo !== undefined) {
        resultados = resultados.filter(item => {
          if ('es_activo' in item) {
            return item.es_activo === filtros.es_activo
          }
          return true
        })
      }

      // Filtro por categoría
      if (filtros.categoria) {
        resultados = resultados.filter(item => {
          if ('categoria' in item) {
            return item.categoria === filtros.categoria
          }
          return true
        })
      }

      // Filtro por módulo
      if (filtros.modulo) {
        resultados = resultados.filter(item => {
          if ('modulo' in item) {
            return item.modulo === filtros.modulo
          }
          return true
        })
      }

      // Filtro por búsqueda de texto
      if (filtros.busqueda) {
        const busqueda = filtros.busqueda.toLowerCase()
        resultados = resultados.filter(item => {
          const nombre = 'nombre' in item ? (item.nombre as string).toLowerCase() : ''
          const codigo = 'codigo' in item ? (item.codigo as string).toLowerCase() : ''
          const descripcion = 'descripcion' in item ? ((item.descripcion as string) || '').toLowerCase() : ''

          return nombre.includes(busqueda) || codigo.includes(busqueda) || descripcion.includes(busqueda)
        })
      }

      setItemsFiltrados(resultados)
    },
    [items]
  )

  // Limpiar filtros
  const clearFilters = useCallback(() => {
    setFiltrosActivos({})
    setItemsFiltrados(items)
  }, [items])

  // Cargar datos al montar
  useEffect(() => {
    fetchItems()
  }, [fetchItems])

  // Re-aplicar filtros cuando cambien los items
  useEffect(() => {
    if (Object.keys(filtrosActivos).length > 0) {
      filter(filtrosActivos)
    } else {
      setItemsFiltrados(items)
    }
  }, [items, filtrosActivos, filter])

  return {
    items: itemsFiltrados,
    loading,
    error,
    create,
    update,
    remove,
    getById,
    refresh,
    filter,
    clearFilters,
    filtrosActivos
  }
}

// ============================================
// HOOKS ESPECÍFICOS PARA CADA CATÁLOGO
// ============================================

/**
 * Hook para gestionar el catálogo de colores
 */
export function useCatalogoColores() {
  return useCatalogo<CatalogoColor>('catalogo_colores')
}

/**
 * Hook para gestionar el catálogo de estados
 */
export function useCatalogoEstados() {
  return useCatalogo<CatalogoEstado>('catalogo_estados', ['color:catalogo_colores(*)'])
}

/**
 * Hook para gestionar el catálogo de tipos de movimiento
 */
export function useCatalogoTiposMovimiento() {
  return useCatalogo<CatalogoTipoMovimiento>('catalogo_tipos_movimiento', ['color:catalogo_colores(*)'])
}

/**
 * Hook para gestionar el catálogo de formas farmacéuticas
 */
export function useCatalogoFormasFarmaceuticas() {
  return useCatalogo<CatalogoFormaFarmaceutica>('catalogo_formas_farmaceuticas')
}

/**
 * Hook para gestionar el catálogo de prioridades
 */
export function useCatalogoPrioridades() {
  return useCatalogo<CatalogoPrioridad>('catalogo_prioridades', ['color:catalogo_colores(*)'])
}

/**
 * Hook para gestionar el catálogo de configuraciones
 */
export function useCatalogoConfiguraciones() {
  return useCatalogo<CatalogoConfiguracion>('catalogo_configuraciones')
}

// ============================================
// HOOK PARA OBTENER CONFIGURACIÓN ESPECÍFICA
// ============================================

/**
 * Hook para obtener el valor de una configuración específica
 */
export function useConfiguracion(clave: string) {
  const [valor, setValor] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchConfiguracion = async () => {
      try {
        setLoading(true)
        setError(null)

        const { data, error: fetchError } = await supabase
          .from('catalogo_configuraciones')
          .select('valor, tipo_dato, valor_por_defecto')
          .eq('clave', clave)
          .eq('es_activo', true)
          .single()

        if (fetchError) throw fetchError

        setValor(data?.valor || data?.valor_por_defecto || null)
      } catch (err) {
        console.error(`Error al obtener configuración ${clave}:`, err)
        setError(err instanceof Error ? err.message : 'Error desconocido')
      } finally {
        setLoading(false)
      }
    }

    fetchConfiguracion()
  }, [clave])

  return { valor, loading, error }
}

// ============================================
// UTILIDADES PARA CONFIGURACIONES
// ============================================

/**
 * Obtener configuración como número
 */
export async function getConfigNumber(clave: string, defaultValue: number = 0): Promise<number> {
  try {
    const { data } = await supabase
      .from('catalogo_configuraciones')
      .select('valor, tipo_dato, valor_por_defecto')
      .eq('clave', clave)
      .eq('es_activo', true)
      .single()

    if (!data) return defaultValue

    const valor = data.valor || data.valor_por_defecto
    return valor ? parseFloat(valor) : defaultValue
  } catch {
    return defaultValue
  }
}

/**
 * Obtener configuración como booleano
 */
export async function getConfigBoolean(clave: string, defaultValue: boolean = false): Promise<boolean> {
  try {
    const { data } = await supabase
      .from('catalogo_configuraciones')
      .select('valor, tipo_dato, valor_por_defecto')
      .eq('clave', clave)
      .eq('es_activo', true)
      .single()

    if (!data) return defaultValue

    const valor = data.valor || data.valor_por_defecto
    return valor === 'true' || valor === '1'
  } catch {
    return defaultValue
  }
}

/**
 * Obtener configuración como texto
 */
export async function getConfigString(clave: string, defaultValue: string = ''): Promise<string> {
  try {
    const { data } = await supabase
      .from('catalogo_configuraciones')
      .select('valor, tipo_dato, valor_por_defecto')
      .eq('clave', clave)
      .eq('es_activo', true)
      .single()

    if (!data) return defaultValue

    return data.valor || data.valor_por_defecto || defaultValue
  } catch {
    return defaultValue
  }
}
