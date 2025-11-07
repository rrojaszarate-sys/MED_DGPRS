import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { Alert } from '../types'

export function useAlertas(centroId?: string) {
  const [alertas, setAlertas] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (centroId) {
      fetchAlertas()
    }
  }, [centroId])

  async function fetchAlertas() {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('alertas_medicamentos')
        .select(`
          *,
          medicamento:medications(*)
        `)
        .eq('resuelta', false)
        .order('nivel_alerta', { ascending: false })
        .order('dias_restantes', { ascending: true })

      if (centroId) {
        query = query.eq('centro_id', centroId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError
      setAlertas(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching alertas:', err)
    } finally {
      setLoading(false)
    }
  }

  async function marcarComoVisto(alertaId: string, userId: string) {
    try {
      const { error: updateError } = await supabase
        .from('alertas_medicamentos')
        .update({
          visto: true,
          visto_por: userId,
          visto_en: new Date().toISOString()
        })
        .eq('id', alertaId)

      if (updateError) throw updateError

      setAlertas((prev) =>
        prev.map((alerta) =>
          alerta.id === alertaId ? { ...alerta, visto: true } : alerta
        )
      )
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  async function resolverAlerta(alertaId: string, userId: string) {
    try {
      const { error: updateError } = await supabase
        .from('alertas_medicamentos')
        .update({
          resuelta: true,
          resuelta_por: userId,
          resuelta_en: new Date().toISOString()
        })
        .eq('id', alertaId)

      if (updateError) throw updateError

      setAlertas((prev) => prev.filter((alerta) => alerta.id !== alertaId))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  async function generarAlertas() {
    try {
      const { error: genError } = await supabase.rpc('generar_alertas_caducidad')
      if (genError) throw genError

      await fetchAlertas()
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  const alertasCriticas = alertas.filter((a) => a.nivel_alerta === 'critico')
  const alertasUrgentes = alertas.filter((a) => a.nivel_alerta === 'urgente')
  const alertasPreventivas = alertas.filter((a) => a.nivel_alerta === 'preventivo')

  return {
    alertas,
    alertasCriticas,
    alertasUrgentes,
    alertasPreventivas,
    loading,
    error,
    refresh: fetchAlertas,
    marcarComoVisto,
    resolverAlerta,
    generarAlertas
  }
}
