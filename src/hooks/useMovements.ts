import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { BatchMovement } from '../types'

interface MovementWithRelations extends BatchMovement {
  medicamento?: {
    id: string
    nombre: string
  }
  lote?: {
    id: string
    numero_lote: string
  }
  centro_origen?: {
    id: string
    name: string
    code: string
  }
  centro_destino?: {
    id: string
    name: string
    code: string
  }
}

export function useMovements(centroId?: string) {
  const [movements, setMovements] = useState<MovementWithRelations[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchMovements()
  }, [centroId])

  // Real-time subscriptions
  useRealtime({
    table: 'movimientos_lotes',
    onInsert: (newMovement: MovementWithRelations) => {
      // Only add if it belongs to the selected center
      if (!centroId || newMovement.centro_origen_id === centroId || newMovement.centro_destino_id === centroId) {
        setMovements((prev) => [newMovement, ...prev])
      }
    },
    onUpdate: (updatedMovement: MovementWithRelations) => {
      setMovements((prev) =>
        prev.map((m) => (m.id === updatedMovement.id ? updatedMovement : m))
      )
    },
    onDelete: (deletedMovement: MovementWithRelations) => {
      setMovements((prev) => prev.filter((m) => m.id !== deletedMovement.id))
    }
  })

  async function fetchMovements() {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('movimientos_lotes')
        .select(`
          *,
          medicamento:medicamentos(id, nombre),
          centro_origen:centros_salud!movimientos_lotes_centro_origen_id_fkey(id, name, code),
          centro_destino:centros_salud!movimientos_lotes_centro_destino_id_fkey(id, name, code)
        `)
        .order('created_at', { ascending: false })

      // Filter by centro if specified
      if (centroId) {
        query = query.or(`centro_origen_id.eq.${centroId},centro_destino_id.eq.${centroId}`)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      // Fetch batch info separately and merge (since we don't have batch_id in movements table currently)
      const movementsWithBatches = await Promise.all(
        (data || []).map(async (movement) => {
          // Try to get batch from metadata
          const batchId = movement.metadata?.batch_id
          if (batchId) {
            const { data: batchData } = await supabase
              .from('lotes')
              .select('id, numero_lote')
              .eq('id', batchId)
              .single()

            return {
              ...movement,
              lote: batchData
            }
          }
          return movement
        })
      )

      setMovements(movementsWithBatches)
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching movements:', err)
    } finally {
      setLoading(false)
    }
  }

  return {
    movements,
    loading,
    error,
    refresh: fetchMovements
  }
}
