import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { Contract, ContractItem } from '../types'

export function useContracts() {
  const [contracts, setContracts] = useState<Contract[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchContracts()
  }, [])

  // Real-time subscriptions
  useRealtime({
    table: 'contracts',
    onInsert: (newContract: Contract) => {
      setContracts((prev) => [newContract, ...prev])
    },
    onUpdate: (updatedContract: Contract) => {
      setContracts((prev) =>
        prev.map((c) => (c.id === updatedContract.id ? updatedContract : c))
      )
    },
    onDelete: (deletedContract: Contract) => {
      setContracts((prev) => prev.filter((c) => c.id !== deletedContract.id))
    }
  })

  async function fetchContracts() {
    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('contracts')
        .select(`
          *,
          supplier:suppliers(id, nombre, rfc),
          items:contract_items(
            *,
            medication_catalog:medication_catalog(id, nombre_generico, codigo_medicamento, concentracion),
            center_destino:health_centers(id, name, code)
          )
        `)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError
      setContracts(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching contracts:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createContract(
    contract: Omit<Contract, 'id' | 'created_at'>,
    items: Omit<ContractItem, 'id' | 'contract_id' | 'created_at'>[]
  ) {
    try {
      // Create contract first
      const { data: contractData, error: contractError } = await supabase
        .from('contracts')
        .insert([contract])
        .select()
        .single()

      if (contractError) throw contractError

      // Create items if any
      if (items.length > 0) {
        const itemsWithContractId = items.map(item => ({
          ...item,
          contract_id: contractData.id
        }))

        const { error: itemsError } = await supabase
          .from('contract_items')
          .insert(itemsWithContractId)

        if (itemsError) throw itemsError
      }

      // Fetch the complete contract with relations
      await fetchContracts()

      return { data: contractData, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function updateContract(
    id: string,
    updates: Partial<Contract>,
    items?: Omit<ContractItem, 'contract_id' | 'created_at'>[]
  ) {
    try {
      // Update contract
      const { data: contractData, error: updateError } = await supabase
        .from('contracts')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      // If items are provided, replace all items
      if (items) {
        // Delete existing items
        const { error: deleteError } = await supabase
          .from('contract_items')
          .delete()
          .eq('contract_id', id)

        if (deleteError) throw deleteError

        // Insert new items if any
        if (items.length > 0) {
          const itemsWithContractId = items.map(item => ({
            ...item,
            contract_id: id
          }))

          const { error: insertError } = await supabase
            .from('contract_items')
            .insert(itemsWithContractId)

          if (insertError) throw insertError
        }
      }

      // Fetch the complete updated contract
      await fetchContracts()

      return { data: contractData, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteContract(id: string) {
    try {
      // Items will be deleted automatically due to ON DELETE CASCADE
      const { error: deleteError } = await supabase
        .from('contracts')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setContracts((prev) => prev.filter((c) => c.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  async function updateContractStatus(id: string, estado: Contract['estado']) {
    try {
      const { error: updateError } = await supabase
        .from('contracts')
        .update({ estado })
        .eq('id', id)

      if (updateError) throw updateError

      setContracts((prev) =>
        prev.map((c) => (c.id === id ? { ...c, estado } : c))
      )
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    contracts,
    loading,
    error,
    refresh: fetchContracts,
    createContract,
    updateContract,
    deleteContract,
    updateContractStatus
  }
}
