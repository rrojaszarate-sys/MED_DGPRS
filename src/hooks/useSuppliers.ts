import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useRealtime } from './useRealtime'
import type { Supplier } from '../types'

export function useSuppliers() {
  const [suppliers, setSuppliers] = useState<Supplier[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchSuppliers()
  }, [])

  // Real-time subscriptions
  useRealtime({
    table: 'suppliers',
    onInsert: (newSupplier: Supplier) => {
      setSuppliers((prev) => [newSupplier, ...prev])
    },
    onUpdate: (updatedSupplier: Supplier) => {
      setSuppliers((prev) =>
        prev.map((s) => (s.id === updatedSupplier.id ? updatedSupplier : s))
      )
    },
    onDelete: (deletedSupplier: Supplier) => {
      setSuppliers((prev) => prev.filter((s) => s.id !== deletedSupplier.id))
    }
  })

  async function fetchSuppliers() {
    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('suppliers')
        .select('*')
        .order('nombre', { ascending: true })

      if (fetchError) throw fetchError
      setSuppliers(data || [])
    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching suppliers:', err)
    } finally {
      setLoading(false)
    }
  }

  async function createSupplier(supplier: Omit<Supplier, 'id' | 'created_at' | 'updated_at'>) {
    try {
      const { data, error: createError } = await supabase
        .from('suppliers')
        .insert([supplier])
        .select()
        .single()

      if (createError) throw createError

      setSuppliers((prev) => [data, ...prev])
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function updateSupplier(id: string, updates: Partial<Supplier>) {
    try {
      const { data, error: updateError } = await supabase
        .from('suppliers')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      setSuppliers((prev) =>
        prev.map((s) => (s.id === id ? data : s))
      )
      return { data, error: null }
    } catch (err: any) {
      return { data: null, error: err.message }
    }
  }

  async function deleteSupplier(id: string) {
    try {
      const { error: deleteError } = await supabase
        .from('suppliers')
        .delete()
        .eq('id', id)

      if (deleteError) throw deleteError

      setSuppliers((prev) => prev.filter((s) => s.id !== id))
      return { error: null }
    } catch (err: any) {
      return { error: err.message }
    }
  }

  return {
    suppliers,
    loading,
    error,
    refresh: fetchSuppliers,
    createSupplier,
    updateSupplier,
    deleteSupplier
  }
}
