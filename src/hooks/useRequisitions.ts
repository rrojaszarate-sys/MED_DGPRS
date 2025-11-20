import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { Requisition, RequisitionItem } from '../types'

interface UseRequisitionsResult {
  requisitions: Requisition[]
  loading: boolean
  error: string | null
  createRequisition: (requisition: Partial<Requisition>, items: Partial<RequisitionItem>[]) => Promise<Requisition | null>
  submitRequisition: (id: string) => Promise<boolean>
  approveRequisition: (id: string, approvedItems: { id: string; cantidad_aprobada: number }[]) => Promise<boolean>
  rejectRequisition: (id: string, reason: string) => Promise<boolean>
  fulfillRequisition: (id: string, fulfilledItems: { id: string; cantidad_surtida: number }[]) => Promise<boolean>
  completeRequisition: (id: string) => Promise<boolean>
  refetch: () => void
}

export function useRequisitions(centerId?: string, status?: Requisition['status']): UseRequisitionsResult {
  const [requisitions, setRequisitions] = useState<Requisition[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchRequisitions = async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('requisitions')
        .select(`
          *,
          requesting_user:users_profiles!requesting_user_id(id, full_name, email),
          center:health_centers(id, name, code),
          approver:users_profiles!aprobada_por(id, full_name, email),
          items:requisition_items(
            *,
            medication:medications(id, nombre, formula_activa)
          )
        `)
        .order('created_at', { ascending: false })

      if (centerId) {
        query = query.eq('center_id', centerId)
      }

      if (status) {
        query = query.eq('status', status)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      setRequisitions(data || [])
    } catch (err: any) {
      console.error('Error fetching requisitions:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchRequisitions()
  }, [centerId, status])

  const createRequisition = async (
    requisition: Partial<Requisition>,
    items: Partial<RequisitionItem>[]
  ): Promise<Requisition | null> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Generar número de requisición
      const requisitionNumber = `REQ-${Date.now()}-${Math.random().toString(36).substring(2, 7).toUpperCase()}`

      // Crear requisición en borrador
      const { data: newRequisition, error: requisitionError } = await supabase
        .from('requisitions')
        .insert({
          requisition_number: requisitionNumber,
          requesting_service: requisition.requesting_service!,
          requesting_user_id: user.id,
          center_id: requisition.center_id!,
          status: 'borrador',
          prioridad: requisition.prioridad || 'normal',
          fecha_necesaria: requisition.fecha_necesaria,
          observaciones: requisition.observaciones,
        })
        .select()
        .single()

      if (requisitionError) throw requisitionError

      // Crear items
      const itemsToInsert = items.map(item => ({
        requisition_id: newRequisition.id,
        medication_id: item.medication_id!,
        cantidad_solicitada: item.cantidad_solicitada!,
        justificacion: item.justificacion,
      }))

      const { error: itemsError } = await supabase
        .from('requisition_items')
        .insert(itemsToInsert)

      if (itemsError) throw itemsError

      await fetchRequisitions()
      return newRequisition
    } catch (err: any) {
      console.error('Error creating requisition:', err)
      setError(err.message)
      return null
    }
  }

  const submitRequisition = async (id: string): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('requisitions')
        .update({
          status: 'solicitada',
          fecha_solicitud: new Date().toISOString(),
        })
        .eq('id', id)

      if (error) throw error

      await fetchRequisitions()
      return true
    } catch (err: any) {
      console.error('Error submitting requisition:', err)
      setError(err.message)
      return false
    }
  }

  const approveRequisition = async (
    id: string,
    approvedItems: { id: string; cantidad_aprobada: number }[]
  ): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Actualizar requisición
      const { error: requisitionError } = await supabase
        .from('requisitions')
        .update({
          status: 'aprobada',
          aprobada_por: user.id,
          aprobada_en: new Date().toISOString(),
        })
        .eq('id', id)

      if (requisitionError) throw requisitionError

      // Actualizar cantidades aprobadas en items
      for (const item of approvedItems) {
        const { error: itemError } = await supabase
          .from('requisition_items')
          .update({ cantidad_aprobada: item.cantidad_aprobada })
          .eq('id', item.id)

        if (itemError) throw itemError
      }

      await fetchRequisitions()
      return true
    } catch (err: any) {
      console.error('Error approving requisition:', err)
      setError(err.message)
      return false
    }
  }

  const rejectRequisition = async (id: string, reason: string): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      const { error } = await supabase
        .from('requisitions')
        .update({
          status: 'rechazada',
          motivo_rechazo: reason,
          aprobada_por: user.id,
          aprobada_en: new Date().toISOString(),
        })
        .eq('id', id)

      if (error) throw error

      await fetchRequisitions()
      return true
    } catch (err: any) {
      console.error('Error rejecting requisition:', err)
      setError(err.message)
      return false
    }
  }

  const fulfillRequisition = async (
    id: string,
    fulfilledItems: { id: string; cantidad_surtida: number }[]
  ): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Actualizar requisición
      const { error: requisitionError } = await supabase
        .from('requisitions')
        .update({
          status: 'surtida',
          surtida_por: user.id,
          surtida_en: new Date().toISOString(),
        })
        .eq('id', id)

      if (requisitionError) throw requisitionError

      // Actualizar cantidades surtidas
      for (const item of fulfilledItems) {
        const { error: itemError } = await supabase
          .from('requisition_items')
          .update({ cantidad_surtida: item.cantidad_surtida })
          .eq('id', item.id)

        if (itemError) throw itemError

        // TODO: Crear movimiento de salida en batch_movements
        // Esto requiere información del lote de donde se está surtiendo
      }

      await fetchRequisitions()
      return true
    } catch (err: any) {
      console.error('Error fulfilling requisition:', err)
      setError(err.message)
      return false
    }
  }

  const completeRequisition = async (id: string): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('requisitions')
        .update({ status: 'completada' })
        .eq('id', id)

      if (error) throw error

      await fetchRequisitions()
      return true
    } catch (err: any) {
      console.error('Error completing requisition:', err)
      setError(err.message)
      return false
    }
  }

  return {
    requisitions,
    loading,
    error,
    createRequisition,
    submitRequisition,
    approveRequisition,
    rejectRequisition,
    fulfillRequisition,
    completeRequisition,
    refetch: fetchRequisitions,
  }
}
