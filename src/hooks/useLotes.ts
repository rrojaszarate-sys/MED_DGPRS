import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { Batch } from '../types'

interface LoteWithMedicationName extends Batch {
  medication_name?: string
  fecha_vencimiento: string
}

export function useLotes(centroId?: string) {
  const [lotes, setLotes] = useState<LoteWithMedicationName[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchLotes()
  }, [centroId])

  const fetchLotes = async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('lotes')
        .select(`
          *,
          medication:medicamentos(nombre)
        `)
        .order('fecha_vencimiento', { ascending: true })

      if (centroId) {
        query = query.eq('centro_id', centroId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      // Transform data to include medication name
      const transformedData = data?.map((lote: any) => ({
        ...lote,
        medication_name: lote.medication?.nombre,
        fecha_vencimiento: lote.fecha_caducidad, // Map fecha_caducidad to fecha_vencimiento for compatibility
      })) || []

      setLotes(transformedData)
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching lotes:', err)
    } finally {
      setLoading(false)
    }
  }

  return {
    lotes,
    loading,
    error,
    refetch: fetchLotes,
  }
}
