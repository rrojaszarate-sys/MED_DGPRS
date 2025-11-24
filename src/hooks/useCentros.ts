import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { HealthCenter } from '../types'

export function useCentros(includeInactive = false) {
  const [centros, setCentros] = useState<HealthCenter[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchCentros()
  }, [includeInactive])

  // Real-time subscriptions
  useRealtime({
    table: 'centros_salud',
    onInsert: (newCenter: HealthCenter) => {
      if (includeInactive || newCenter.is_active) {
        setCentros((prev) => [newCenter, ...prev])
      }
    },
    onUpdate: (updatedCenter: HealthCenter) => {
      setCentros((prev) =>
        prev.map((c) => (c.id === updatedCenter.id ? updatedCenter : c))
      )
    },
    onDelete: (deletedCenter: HealthCenter) => {
      setCentros((prev) => prev.filter((c) => c.id !== deletedCenter.id))
    }
  })

  async function fetchCentros() {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('centros_salud')
        .select('*')
        .order('name')

      if (!includeInactive) {
        query = query.eq('is_active', true)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError
      setCentros(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching centros:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createCentro(centro: Omit<HealthCenter, 'id'>) {
    try {
      const { data, error: createError } = await supabase
        .from('centros_salud')
        .insert([centro])
        .select()
        .single()

      if (createError) throw createError

      setCentros((prev) => [data, ...prev])
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function updateCentro(id: string, updates: Partial<HealthCenter>) {
    try {
      const { data, error: updateError } = await supabase
        .from('centros_salud')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      setCentros((prev) =>
        prev.map((c) => (c.id === id ? data : c))
      )
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteCentro(id: string) {
    try {
      const { error: deleteError } = await supabase
        .from('centros_salud')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setCentros((prev) => prev.filter((c) => c.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    centros,
    loading,
    error,
    refresh: fetchCentros,
    createCentro,
    updateCentro,
    deleteCentro
  }
}
