import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export interface WarehouseLocation {
  id: string
  centro_id: string
  codigo: string
  nombre?: string
  tipo: 'ambiente' | 'refrigerado' | 'congelado' | 'controlado'
  temperatura_min?: number
  temperatura_max?: number
  capacidad_max: number
  capacidad_actual: number
  es_cuarentena: boolean
  requiere_acceso_especial: boolean
  observaciones?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export function useWarehouseLocations(centerId?: string) {
  const [locations, setLocations] = useState<WarehouseLocation[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    if (!centerId) {
      setLocations([])
      setLoading(false)
      return
    }

    fetchLocations()

    // Real-time subscription
    const subscription = supabase
      .channel('ubicaciones_changes')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'ubicaciones_almacen',
        filter: `centro_id=eq.${centerId}`
      }, fetchLocations)
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [centerId])

  const fetchLocations = async () => {
    try {
      setLoading(true)
      const { data, error: fetchError } = await supabase
        .from('ubicaciones_almacen')
        .select('*')
        .eq('centro_id', centerId)
        .order('codigo')

      if (fetchError) throw fetchError
      setLocations(data || [])
      setError(null)
    } catch (err) {
      setError(err as Error)
      console.error('Error fetching warehouse locations:', err)
    } finally {
      setLoading(false)
    }
  }

  const createLocation = async (data: Omit<WarehouseLocation, 'id' | 'created_at' | 'updated_at'>) => {
    try {
      const result = await supabase
        .from('ubicaciones_almacen')
        .insert([data])
        .select()

      if (!result.error) {
        await fetchLocations()
      }

      return result
    } catch (err) {
      console.error('Error creating location:', err)
      return { data: null, error: err as Error }
    }
  }

  const updateLocation = async (id: string, data: Partial<WarehouseLocation>) => {
    try {
      const result = await supabase
        .from('ubicaciones_almacen')
        .update(data)
        .eq('id', id)
        .select()

      if (!result.error) {
        await fetchLocations()
      }

      return result
    } catch (err) {
      console.error('Error updating location:', err)
      return { data: null, error: err as Error }
    }
  }

  const deleteLocation = async (id: string) => {
    try {
      const result = await supabase
        .from('ubicaciones_almacen')
        .delete()
        .eq('id', id)

      if (!result.error) {
        await fetchLocations()
      }

      return result
    } catch (err) {
      console.error('Error deleting location:', err)
      return { data: null, error: err as Error }
    }
  }

  const getAvailableLocations = async (tipo?: string, cantidadRequerida: number = 1) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_ubicaciones_disponibles', {
        p_center_id: centerId,
        p_tipo: tipo || null,
        p_cantidad_requerida: cantidadRequerida
      })

      if (rpcError) throw rpcError
      return { data, error: null }
    } catch (err) {
      console.error('Error getting available locations:', err)
      return { data: null, error: err as Error }
    }
  }

  const getLotesPorUbicacion = async (ubicacionId: string) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_lotes_por_ubicacion', {
        p_ubicacion_id: ubicacionId
      })

      if (rpcError) throw rpcError
      return { data, error: null }
    } catch (err) {
      console.error('Error getting batches by location:', err)
      return { data: null, error: err as Error }
    }
  }

  return {
    locations,
    loading,
    error,
    createLocation,
    updateLocation,
    deleteLocation,
    getAvailableLocations,
    getLotesPorUbicacion,
    refresh: fetchLocations
  }
}
