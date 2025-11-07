import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { HealthCenter } from '../types'

export function useCentros() {
  const [centros, setCentros] = useState<HealthCenter[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchCentros()
  }, [])

  async function fetchCentros() {
    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('health_centers')
        .select('*')
        .eq('is_active', true)
        .order('name')

      if (fetchError) throw fetchError
      setCentros(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching centros:', err)
    } finally {
      setLoading(false)
    }
  }

  return {
    centros,
    loading,
    error,
    refresh: fetchCentros
  }
}
