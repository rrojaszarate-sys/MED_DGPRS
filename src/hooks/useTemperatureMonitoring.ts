import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export interface TemperatureReading {
  id: string
  centro_id: string
  ubicacion_id: string
  temperatura: number
  humedad?: number
  sensor_id?: string
  fuera_rango: boolean
  alerta_generada: boolean
  observaciones?: string
  created_at: string
}

export interface ExcursionTermica {
  id: string
  ubicacion_id: string
  temperatura_registrada: number
  temperatura_min_permitida?: number
  temperatura_max_permitida?: number
  duracion_minutos?: number
  inicio: string
  fin?: string
  severidad: 'leve' | 'moderada' | 'severa' | 'crítica'
  accion_correctiva?: string
  responsable_id?: string
  resuelta: boolean
  afecta_medicamentos: boolean
  created_at: string
  ubicacion?: any
}

export interface TemperaturaSummary {
  ubicacion_id: string
  codigo: string
  ubicacion_nombre: string
  tipo: string
  temperatura_min?: number
  temperatura_max?: number
  centro_nombre: string
  temperatura_actual?: number
  ultima_lectura?: string
  excursiones_pendientes: number
}

export function useTemperatureMonitoring(centerId?: string) {
  const [ubicaciones, setUbicaciones] = useState<TemperaturaSummary[]>([])
  const [excursionesPendientes, setExcursionesPendientes] = useState<ExcursionTermica[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    if (!centerId) {
      setUbicaciones([])
      setExcursionesPendientes([])
      setLoading(false)
      return
    }

    fetchTemperatureData()

    // Real-time subscription para nuevas mediciones
    const subscription = supabase
      .channel('temperature_changes')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'monitoreo_temperatura'
      }, fetchTemperatureData)
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'excursiones_termicas'
      }, fetchTemperatureData)
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [centerId])

  const fetchTemperatureData = async () => {
    try {
      setLoading(true)

      // Obtener vista de temperatura por ubicación
      const { data: ubicacionesData, error: ubicacionesError } = await supabase
        .from('v_temperatura_ubicaciones')
        .select('*')

      if (ubicacionesError) throw ubicacionesError

      // Obtener excursiones pendientes
      const { data: excursionesData, error: excursionesError } = await supabase
        .from('excursiones_termicas')
        .select(`
          *,
          ubicacion:ubicaciones_almacen(*)
        `)
        .eq('resuelta', false)
        .order('created_at', { ascending: false })

      if (excursionesError) throw excursionesError

      setUbicaciones(ubicacionesData || [])
      setExcursionesPendientes(excursionesData || [])
      setError(null)
    } catch (err) {
      setError(err as Error)
      console.error('Error fetching temperature data:', err)
    } finally {
      setLoading(false)
    }
  }

  const registrarTemperatura = async (
    ubicacionId: string,
    temperatura: number,
    humedad?: number,
    sensorId?: string
  ) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('registrar_temperatura', {
        p_centro_id: centerId,
        p_ubicacion_id: ubicacionId,
        p_temperatura: temperatura,
        p_humedad: humedad || null,
        p_sensor_id: sensorId || null
      })

      if (rpcError) throw rpcError

      await fetchTemperatureData()

      return { data, error: null }
    } catch (err) {
      console.error('Error registering temperature:', err)
      return { data: null, error: err as Error }
    }
  }

  const getTemperatureHistory = async (ubicacionId: string, horas: number = 24) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_temperature_history', {
        p_ubicacion_id: ubicacionId,
        p_horas: horas
      })

      if (rpcError) throw rpcError
      return { data, error: null }
    } catch (err) {
      console.error('Error getting temperature history:', err)
      return { data: null, error: err as Error }
    }
  }

  const getMedicamentosAfectados = async (excursionId: string) => {
    try {
      const { data, error: rpcError } = await supabase.rpc('get_medicamentos_afectados_excursion', {
        p_excursion_id: excursionId
      })

      if (rpcError) throw rpcError
      return { data, error: null }
    } catch (err) {
      console.error('Error getting affected medications:', err)
      return { data: null, error: err as Error }
    }
  }

  const resolverExcursion = async (excursionId: string, accionCorrectiva: string) => {
    try {
      const { data: userData } = await supabase.auth.getUser()

      const result = await supabase
        .from('excursiones_termicas')
        .update({
          resuelta: true,
          accion_correctiva: accionCorrectiva,
          responsable_id: userData.user?.id,
          fin: new Date().toISOString()
        })
        .eq('id', excursionId)
        .select()

      if (!result.error) {
        await fetchTemperatureData()
      }

      return result
    } catch (err) {
      console.error('Error resolving excursion:', err)
      return { data: null, error: err as Error }
    }
  }

  return {
    ubicaciones,
    excursionesPendientes,
    loading,
    error,
    registrarTemperatura,
    getTemperatureHistory,
    getMedicamentosAfectados,
    resolverExcursion,
    refresh: fetchTemperatureData
  }
}
