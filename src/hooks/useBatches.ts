import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { Batch } from '../types'

export function useBatches(centroId?: string) {
  const [batches, setBatches] = useState<Batch[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (centroId) {
      fetchBatches()
    }
  }, [centroId])

  // Real-time subscriptions
  useRealtime({
    table: 'batches',
    filter: centroId ? `center_id=eq.${centroId}` : undefined,
    onInsert: (newBatch: Batch) => {
      if (!centroId || newBatch.center_id === centroId) {
        setBatches((prev) => [newBatch, ...prev])
      }
    },
    onUpdate: (updatedBatch: Batch) => {
      if (!centroId || updatedBatch.center_id === centroId) {
        setBatches((prev) =>
          prev.map((batch) => (batch.id === updatedBatch.id ? updatedBatch : batch))
        )
      }
    },
    onDelete: (deletedBatch: Batch) => {
      setBatches((prev) => prev.filter((batch) => batch.id !== deletedBatch.id))
    }
  })

  async function fetchBatches() {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('batches')
        .select(`
          *,
          medication:medications(id, nombre, categoria, unidad_medida),
          health_center:health_centers(id, name, code),
          supplier:suppliers(id, nombre)
        `)
        .order('created_at', { ascending: false })

      if (centroId) {
        query = query.eq('center_id', centroId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError
      setBatches(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching batches:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createBatch(batch: Omit<Batch, 'id' | 'created_at' | 'updated_at'>) {
    try {
      console.log('📦 Intentando crear lote:', {
        medication_id: batch.medication_id,
        numero_lote: batch.numero_lote,
        center_id: batch.center_id
      })

      const { data, error: createError } = await supabase
        .from('batches')
        .insert([batch])
        .select()
        .single()

      if (createError) {
        console.error('❌ Error de Supabase al crear lote:', {
          message: createError.message,
          code: createError.code,
          details: createError.details,
          hint: createError.hint
        })
        throw createError
      }

      console.log('✅ Lote creado exitosamente:', data)
      setBatches((prev) => [data, ...prev])
      return { data, error: null }
    } catch (err: any) {
      console.error('❌ Error capturado en catch:', err)
      return { data: null, error: err.message || 'Error desconocido al crear lote' }
    }
  }

  async function updateBatch(id: string, updates: Partial<Batch>) {
    try {
      const { data, error: updateError } = await supabase
        .from('batches')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      setBatches((prev) =>
        prev.map((batch) => (batch.id === id ? data : batch))
      )
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteBatch(id: string) {
    try {
      const { error: deleteError } = await supabase
        .from('batches')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setBatches((prev) => prev.filter((batch) => batch.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    batches,
    loading,
    error,
    refresh: fetchBatches,
    createBatch,
    updateBatch,
    deleteBatch
  }
}
