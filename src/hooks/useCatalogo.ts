import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { MedicationCatalog } from '../types'

export function useCatalogo() {
  const [catalogos, setCatalogos] = useState<MedicationCatalog[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchCatalogos()
  }, [])

  // Real-time subscriptions
  useRealtime({
    table: 'catalogo_medicamentos',
    onInsert: (newCatalog: MedicationCatalog) => {
      setCatalogos((prev) => [newCatalog, ...prev])
    },
    onUpdate: (updatedCatalog: MedicationCatalog) => {
      setCatalogos((prev) =>
        prev.map((cat) => (cat.id === updatedCatalog.id ? updatedCatalog : cat))
      )
    },
    onDelete: (deletedCatalog: MedicationCatalog) => {
      setCatalogos((prev) => prev.filter((cat) => cat.id !== deletedCatalog.id))
    }
  })

  async function fetchCatalogos() {
    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('catalogo_medicamentos')
        .select('*')
        .order('nombre', { ascending: true })

      if (fetchError) throw fetchError
      setCatalogos(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching catalogo:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createCatalogo(catalogo: Omit<MedicationCatalog, 'id' | 'created_at'>) {
    try {
      const { data, error: createError } = await supabase
        .from('catalogo_medicamentos')
        .insert([catalogo])
        .select()
        .single()

      if (createError) throw createError

      setCatalogos((prev) => [data, ...prev])
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function updateCatalogo(id: string, updates: Partial<MedicationCatalog>) {
    try {
      const { data, error: updateError } = await supabase
        .from('catalogo_medicamentos')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      setCatalogos((prev) =>
        prev.map((cat) => (cat.id === id ? data : cat))
      )
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteCatalogo(id: string) {
    try {
      const { error: deleteError } = await supabase
        .from('catalogo_medicamentos')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setCatalogos((prev) => prev.filter((cat) => cat.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    catalogos,
    loading,
    error,
    refresh: fetchCatalogos,
    createCatalogo,
    updateCatalogo,
    deleteCatalogo
  }
}
