import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { InventoryAdjustment } from '../types'

interface UseAdjustmentsResult {
  adjustments: InventoryAdjustment[]
  loading: boolean
  error: string | null
  createAdjustment: (adjustment: Partial<InventoryAdjustment>) => Promise<InventoryAdjustment | null>
  authorizeAdjustment: (id: string) => Promise<boolean>
  uploadEvidence: (files: File[]) => Promise<string[]>
  refetch: () => void
}

export function useAdjustments(centerId?: string): UseAdjustmentsResult {
  const [adjustments, setAdjustments] = useState<InventoryAdjustment[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchAdjustments = async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('inventory_adjustments')
        .select(`
          *,
          medication:medications(id, nombre, formula_activa),
          center:health_centers(id, name, code),
          creator:users_profiles!created_by(id, full_name, email),
          authorizer:users_profiles!autorizado_por(id, full_name, email)
        `)
        .order('created_at', { ascending: false })

      if (centerId) {
        query = query.eq('center_id', centerId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      // Calcular diferencia si no está calculada
      const adjustmentsWithDiff = (data || []).map(adj => ({
        ...adj,
        diferencia: adj.diferencia ?? (adj.cantidad_fisica - adj.cantidad_sistema)
      }))

      setAdjustments(adjustmentsWithDiff)
    } catch (err: any) {
      console.error('Error fetching adjustments:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchAdjustments()
  }, [centerId])

  const createAdjustment = async (
    adjustment: Partial<InventoryAdjustment>
  ): Promise<InventoryAdjustment | null> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Generar número de ajuste
      const adjustmentNumber = `ADJ-${Date.now()}-${Math.random().toString(36).substring(2, 7).toUpperCase()}`

      // Crear ajuste
      const { data: newAdjustment, error: adjustmentError } = await supabase
        .from('inventory_adjustments')
        .insert({
          adjustment_number: adjustmentNumber,
          medication_id: adjustment.medication_id,
          center_id: adjustment.center_id!,
          adjustment_type: adjustment.adjustment_type!,
          cantidad_sistema: adjustment.cantidad_sistema!,
          cantidad_fisica: adjustment.cantidad_fisica!,
          motivo: adjustment.motivo!,
          justificacion: adjustment.justificacion!,
          evidencia_fotografica: adjustment.evidencia_fotografica || [],
          created_by: user.id,
        })
        .select()
        .single()

      if (adjustmentError) throw adjustmentError

      // Si es una corrección aprobada automáticamente por el usuario actual
      // (dependiendo de permisos), crear movimiento en batch_movements
      // TODO: Integrar con batch_movements cuando sea aprobado

      await fetchAdjustments()
      return newAdjustment
    } catch (err: any) {
      console.error('Error creating adjustment:', err)
      setError(err.message)
      return null
    }
  }

  const authorizeAdjustment = async (id: string): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Obtener ajuste
      const { data: adjustment, error: fetchError } = await supabase
        .from('inventory_adjustments')
        .select('*')
        .eq('id', id)
        .single()

      if (fetchError) throw fetchError

      // Autorizar ajuste
      const { error: authorizeError } = await supabase
        .from('inventory_adjustments')
        .update({
          autorizado_por: user.id,
          autorizado_en: new Date().toISOString(),
        })
        .eq('id', id)

      if (authorizeError) throw authorizeError

      // Crear movimiento en batch_movements
      // TODO: Implementar creación de movimiento de ajuste
      // Esto requiere información del lote afectado

      await fetchAdjustments()
      return true
    } catch (err: any) {
      console.error('Error authorizing adjustment:', err)
      setError(err.message)
      return false
    }
  }

  const uploadEvidence = async (files: File[]): Promise<string[]> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      const uploadedUrls: string[] = []

      for (const file of files) {
        const fileName = `${user.id}/${Date.now()}-${file.name}`
        const { data, error } = await supabase.storage
          .from('evidence')
          .upload(fileName, file)

        if (error) throw error

        // Obtener URL pública
        const { data: { publicUrl } } = supabase.storage
          .from('evidence')
          .getPublicUrl(fileName)

        uploadedUrls.push(publicUrl)
      }

      return uploadedUrls
    } catch (err: any) {
      console.error('Error uploading evidence:', err)
      setError(err.message)
      return []
    }
  }

  return {
    adjustments,
    loading,
    error,
    createAdjustment,
    authorizeAdjustment,
    uploadEvidence,
    refetch: fetchAdjustments,
  }
}
