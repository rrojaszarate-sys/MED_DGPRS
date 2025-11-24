import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { Medication } from '../types'

export function useMedicamentos(centroId?: string) {
  const [medicamentos, setMedicamentos] = useState<Medication[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (centroId) {
      fetchMedicamentos()
    }
  }, [centroId])

  // Real-time subscriptions
  useRealtime({
    table: 'medicamentos',
    filter: centroId ? `centro_id=eq.${centroId}` : undefined,
    onInsert: (newMed: Medication) => {
      if (!centroId || newMed.centro_id === centroId) {
        setMedicamentos((prev) => [newMed, ...prev])
      }
    },
    onUpdate: (updatedMed: Medication) => {
      if (!centroId || updatedMed.centro_id === centroId) {
        setMedicamentos((prev) =>
          prev.map((med) => (med.id === updatedMed.id ? updatedMed : med))
        )
      }
    },
    onDelete: (deletedMed: Medication) => {
      setMedicamentos((prev) => prev.filter((med) => med.id !== deletedMed.id))
    }
  })

  async function fetchMedicamentos() {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('medicamentos')
        .select('*')
        .order('created_at', { ascending: false })

      if (centroId) {
        query = query.eq('centro_id', centroId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError
      setMedicamentos(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching medicamentos:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createMedicamento(medicamento: Omit<Medication, 'id' | 'created_at'>) {
    try {
      const { data, error: createError } = await supabase
        .from('medicamentos')
        .insert([medicamento])
        .select()
        .single()

      if (createError) throw createError

      setMedicamentos((prev) => [data, ...prev])
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function updateMedicamento(id: string, updates: Partial<Medication>) {
    try {
      const { data, error: updateError } = await supabase
        .from('medicamentos')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      setMedicamentos((prev) =>
        prev.map((med) => (med.id === id ? data : med))
      )
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteMedicamento(id: string) {
    try {
      const { error: deleteError } = await supabase
        .from('medicamentos')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setMedicamentos((prev) => prev.filter((med) => med.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    medicamentos,
    loading,
    error,
    refresh: fetchMedicamentos,
    createMedicamento,
    updateMedicamento,
    deleteMedicamento
  }
}
