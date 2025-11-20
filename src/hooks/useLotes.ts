import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { Batch } from '../types'

interface LoteWithMedicationName extends Batch {
  medication_name?: string
  fecha_vencimiento: string
}

interface UseLotesResult {
  lotes: LoteWithMedicationName[]
  loading: boolean
  error: string | null
  createLote: (lote: Partial<Batch>) => Promise<Batch | null>
  updateLote: (id: string, lote: Partial<Batch>) => Promise<boolean>
  deleteLote: (id: string) => Promise<boolean>
  updateEstado: (id: string, estado: Batch['estado']) => Promise<boolean>
  refetch: () => void
}

export function useLotes(centroId?: string): UseLotesResult {
  const [lotes, setLotes] = useState<LoteWithMedicationName[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchLotes = async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('batches')
        .select(`
          *,
          medication:medications(id, nombre, formula_activa),
          health_center:health_centers(id, name, code),
          supplier:suppliers(id, nombre)
        `)
        .order('fecha_caducidad', { ascending: true })

      if (centroId) {
        query = query.eq('center_id', centroId)
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

  useEffect(() => {
    fetchLotes()
  }, [centroId])

  const createLote = async (lote: Partial<Batch>): Promise<Batch | null> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      const { data, error: createError } = await supabase
        .from('batches')
        .insert({
          medication_id: lote.medication_id!,
          center_id: lote.center_id!,
          supplier_id: lote.supplier_id,
          numero_lote: lote.numero_lote!,
          cantidad_inicial: lote.cantidad_inicial!,
          cantidad_actual: lote.cantidad_actual ?? lote.cantidad_inicial!,
          fecha_fabricacion: lote.fecha_fabricacion,
          fecha_caducidad: lote.fecha_caducidad!,
          fecha_ingreso: lote.fecha_ingreso || new Date().toISOString().split('T')[0],
          ubicacion_fisica: lote.ubicacion_fisica,
          temperatura_almacenamiento: lote.temperatura_almacenamiento,
          stock_minimo: lote.stock_minimo || 10,
          stock_maximo: lote.stock_maximo,
          estado: lote.estado || 'disponible',
          observaciones: lote.observaciones,
        })
        .select()
        .single()

      if (createError) throw createError

      await fetchLotes()
      return data
    } catch (err: any) {
      console.error('Error creating lote:', err)
      setError(err.message)
      return null
    }
  }

  const updateLote = async (id: string, lote: Partial<Batch>): Promise<boolean> => {
    try {
      const { error: updateError } = await supabase
        .from('batches')
        .update({
          numero_lote: lote.numero_lote,
          cantidad_actual: lote.cantidad_actual,
          fecha_fabricacion: lote.fecha_fabricacion,
          fecha_caducidad: lote.fecha_caducidad,
          ubicacion_fisica: lote.ubicacion_fisica,
          temperatura_almacenamiento: lote.temperatura_almacenamiento,
          stock_minimo: lote.stock_minimo,
          stock_maximo: lote.stock_maximo,
          estado: lote.estado,
          observaciones: lote.observaciones,
          updated_at: new Date().toISOString(),
        })
        .eq('id', id)

      if (updateError) throw updateError

      await fetchLotes()
      return true
    } catch (err: any) {
      console.error('Error updating lote:', err)
      setError(err.message)
      return false
    }
  }

  const deleteLote = async (id: string): Promise<boolean> => {
    try {
      const { error: deleteError } = await supabase
        .from('batches')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      await fetchLotes()
      return true
    } catch (err: any) {
      console.error('Error deleting lote:', err)
      setError(err.message)
      return false
    }
  }

  const updateEstado = async (id: string, estado: Batch['estado']): Promise<boolean> => {
    try {
      const { error: updateError } = await supabase
        .from('batches')
        .update({
          estado,
          updated_at: new Date().toISOString(),
        })
        .eq('id', id)

      if (updateError) throw updateError

      await fetchLotes()
      return true
    } catch (err: any) {
      console.error('Error updating estado:', err)
      setError(err.message)
      return false
    }
  }

  return {
    lotes,
    loading,
    error,
    createLote,
    updateLote,
    deleteLote,
    updateEstado,
    refetch: fetchLotes,
  }
}
