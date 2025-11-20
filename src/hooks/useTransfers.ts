import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { Transfer, TransferItem } from '../types'

interface UseTransfersResult {
  transfers: Transfer[]
  loading: boolean
  error: string | null
  createTransfer: (transfer: Partial<Transfer>, items: Partial<TransferItem>[]) => Promise<Transfer | null>
  updateTransferStatus: (id: string, status: Transfer['status'], notes?: string) => Promise<boolean>
  approveTransfer: (id: string, approvedItems: { id: string; cantidad_aprobada: number }[]) => Promise<boolean>
  shipTransfer: (id: string, shippedItems: { id: string; cantidad_enviada: number }[]) => Promise<boolean>
  receiveTransfer: (id: string, receivedItems: { id: string; cantidad_recibida: number }[]) => Promise<boolean>
  rejectTransfer: (id: string, reason: string) => Promise<boolean>
  refetch: () => void
}

export function useTransfers(centerId?: string, status?: Transfer['status']): UseTransfersResult {
  const [transfers, setTransfers] = useState<Transfer[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchTransfers = async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('transfers')
        .select(`
          *,
          origin_center:health_centers!origin_center_id(id, name, code),
          destination_center:health_centers!destination_center_id(id, name, code),
          items:transfer_items(
            *,
            medication:medications(id, nombre, formula_activa)
          )
        `)
        .order('created_at', { ascending: false })

      if (centerId) {
        query = query.or(`origin_center_id.eq.${centerId},destination_center_id.eq.${centerId}`)
      }

      if (status) {
        query = query.eq('status', status)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      setTransfers(data || [])
    } catch (err: any) {
      console.error('Error fetching transfers:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTransfers()
  }, [centerId, status])

  const createTransfer = async (
    transfer: Partial<Transfer>,
    items: Partial<TransferItem>[]
  ): Promise<Transfer | null> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Generar número de transferencia
      const transferNumber = `TRF-${Date.now()}-${Math.random().toString(36).substring(2, 7).toUpperCase()}`

      // Crear transferencia
      const { data: newTransfer, error: transferError } = await supabase
        .from('transfers')
        .insert({
          transfer_number: transferNumber,
          origin_center_id: transfer.origin_center_id,
          destination_center_id: transfer.destination_center_id,
          status: 'pending',
          requested_by: user.id,
          requested_at: new Date().toISOString(),
          notes: transfer.notes,
        })
        .select()
        .single()

      if (transferError) throw transferError

      // Crear items
      const itemsToInsert = items.map(item => ({
        transfer_id: newTransfer.id,
        medication_id: item.medication_id!,
        cantidad_solicitada: item.cantidad_solicitada!,
        lote: item.lote,
        fecha_caducidad: item.fecha_caducidad,
      }))

      const { error: itemsError } = await supabase
        .from('transfer_items')
        .insert(itemsToInsert)

      if (itemsError) throw itemsError

      await fetchTransfers()
      return newTransfer
    } catch (err: any) {
      console.error('Error creating transfer:', err)
      setError(err.message)
      return null
    }
  }

  const updateTransferStatus = async (
    id: string,
    status: Transfer['status'],
    notes?: string
  ): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      const updates: any = { status }
      if (notes) updates.notes = notes

      const { error } = await supabase
        .from('transfers')
        .update(updates)
        .eq('id', id)

      if (error) throw error

      await fetchTransfers()
      return true
    } catch (err: any) {
      console.error('Error updating transfer:', err)
      setError(err.message)
      return false
    }
  }

  const approveTransfer = async (
    id: string,
    approvedItems: { id: string; cantidad_aprobada: number }[]
  ): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Actualizar transferencia
      const { error: transferError } = await supabase
        .from('transfers')
        .update({
          status: 'approved',
          approved_by: user.id,
          approved_at: new Date().toISOString(),
        })
        .eq('id', id)

      if (transferError) throw transferError

      // Actualizar cantidades aprobadas en items
      for (const item of approvedItems) {
        const { error: itemError } = await supabase
          .from('transfer_items')
          .update({ cantidad_aprobada: item.cantidad_aprobada })
          .eq('id', item.id)

        if (itemError) throw itemError
      }

      await fetchTransfers()
      return true
    } catch (err: any) {
      console.error('Error approving transfer:', err)
      setError(err.message)
      return false
    }
  }

  const shipTransfer = async (
    id: string,
    shippedItems: { id: string; cantidad_enviada: number }[]
  ): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Actualizar transferencia
      const { error: transferError } = await supabase
        .from('transfers')
        .update({
          status: 'in_transit',
          shipped_by: user.id,
          shipped_at: new Date().toISOString(),
        })
        .eq('id', id)

      if (transferError) throw transferError

      // Actualizar cantidades enviadas y crear movimientos de salida
      for (const item of shippedItems) {
        const { error: itemError } = await supabase
          .from('transfer_items')
          .update({ cantidad_enviada: item.cantidad_enviada })
          .eq('id', item.id)

        if (itemError) throw itemError

        // TODO: Crear registro en batch_movements (transferencia_salida)
        // Esto requiere información del lote que se está enviando
      }

      await fetchTransfers()
      return true
    } catch (err: any) {
      console.error('Error shipping transfer:', err)
      setError(err.message)
      return false
    }
  }

  const receiveTransfer = async (
    id: string,
    receivedItems: { id: string; cantidad_recibida: number }[]
  ): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      // Actualizar transferencia
      const { error: transferError } = await supabase
        .from('transfers')
        .update({
          status: 'received',
          received_by: user.id,
          received_at: new Date().toISOString(),
        })
        .eq('id', id)

      if (transferError) throw transferError

      // Actualizar cantidades recibidas
      for (const item of receivedItems) {
        const { error: itemError } = await supabase
          .from('transfer_items')
          .update({ cantidad_recibida: item.cantidad_recibida })
          .eq('id', item.id)

        if (itemError) throw itemError

        // TODO: Crear registro en batch_movements (transferencia_entrada)
        // Esto requiere información del lote que se está recibiendo
      }

      // Marcar como completada si todo se recibió
      const allReceived = receivedItems.every(item => item.cantidad_recibida > 0)
      if (allReceived) {
        await updateTransferStatus(id, 'completed')
      }

      await fetchTransfers()
      return true
    } catch (err: any) {
      console.error('Error receiving transfer:', err)
      setError(err.message)
      return false
    }
  }

  const rejectTransfer = async (id: string, reason: string): Promise<boolean> => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      const { error } = await supabase
        .from('transfers')
        .update({
          status: 'rejected',
          rejection_reason: reason,
          approved_by: user.id,
          approved_at: new Date().toISOString(),
        })
        .eq('id', id)

      if (error) throw error

      await fetchTransfers()
      return true
    } catch (err: any) {
      console.error('Error rejecting transfer:', err)
      setError(err.message)
      return false
    }
  }

  return {
    transfers,
    loading,
    error,
    createTransfer,
    updateTransferStatus,
    approveTransfer,
    shipTransfer,
    receiveTransfer,
    rejectTransfer,
    refetch: fetchTransfers,
  }
}
