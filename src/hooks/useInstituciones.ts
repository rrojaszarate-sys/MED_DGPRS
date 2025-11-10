import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { Institucion } from '../types'

export function useInstituciones() {
  const [instituciones, setInstituciones] = useState<Institucion[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchInstituciones()
  }, [])

  // Real-time subscriptions
  useRealtime({
    table: 'instituciones',
    onInsert: (newInst: Institucion) => {
      setInstituciones((prev) => [newInst, ...prev])
    },
    onUpdate: (updatedInst: Institucion) => {
      setInstituciones((prev) =>
        prev.map((i) => (i.id === updatedInst.id ? updatedInst : i))
      )
    },
    onDelete: (deletedInst: Institucion) => {
      setInstituciones((prev) => prev.filter((i) => i.id !== deletedInst.id))
    }
  })

  async function fetchInstituciones() {
    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('instituciones')
        .select('*')
        .order('nombre')

      if (fetchError) throw fetchError
      setInstituciones(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching instituciones:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createInstitucion(institucion: Omit<Institucion, 'id' | 'created_at'>) {
    try {
      const { data, error: createError } = await supabase
        .from('instituciones')
        .insert([institucion])
        .select()
        .single()

      if (createError) throw createError

      setInstituciones((prev) => [data, ...prev])
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function updateInstitucion(id: string, updates: Partial<Institucion>) {
    try {
      const { data, error: updateError } = await supabase
        .from('instituciones')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      setInstituciones((prev) =>
        prev.map((i) => (i.id === id ? data : i))
      )
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteInstitucion(id: string) {
    try {
      const { error: deleteError } = await supabase
        .from('instituciones')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setInstituciones((prev) => prev.filter((i) => i.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    instituciones,
    loading,
    error,
    refresh: fetchInstituciones,
    createInstitucion,
    updateInstitucion,
    deleteInstitucion
  }
}
