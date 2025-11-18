import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import type { User } from '../types'

export function useUsers() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    fetchUsers()

    // Real-time subscription
    const subscription = supabase
      .channel('users_changes')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'perfiles_usuario'
      }, fetchUsers)
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const fetchUsers = async () => {
    try {
      setLoading(true)
      const { data, error: fetchError } = await supabase
        .from('perfiles_usuario')
        .select(`
          *,
          health_center:centros_salud(id, name, code)
        `)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError
      setUsers(data || [])
      setError(null)
    } catch (err) {
      setError(err as Error)
      console.error('Error fetching users:', err)
    } finally {
      setLoading(false)
    }
  }

  const createUser = async (email: string, password: string, userData: Partial<User>) => {
    try {
      // Crear usuario en Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: userData.full_name,
            role: userData.role
          }
        }
      })

      if (authError) throw authError

      // Crear perfil de usuario
      if (authData.user) {
        const { error: profileError } = await supabase
          .from('perfiles_usuario')
          .insert([{
            id: authData.user.id,
            email,
            full_name: userData.full_name,
            role: userData.role,
            center_id: userData.center_id,
            is_active: userData.is_active ?? true
          }])

        if (profileError) throw profileError

        await fetchUsers()
        return { data: authData.user, error: null }
      }

      return { data: null, error: new Error('Failed to create user') }
    } catch (err) {
      console.error('Error creating user:', err)
      return { data: null, error: err as Error }
    }
  }

  const updateUser = async (id: string, data: Partial<User>) => {
    try {
      const result = await supabase
        .from('perfiles_usuario')
        .update(data)
        .eq('id', id)
        .select()

      if (!result.error) {
        await fetchUsers()
      }

      return result
    } catch (err) {
      console.error('Error updating user:', err)
      return { data: null, error: err as Error }
    }
  }

  const deleteUser = async (id: string) => {
    try {
      // Desactivar usuario en lugar de eliminar
      const result = await supabase
        .from('perfiles_usuario')
        .update({ is_active: false })
        .eq('id', id)

      if (!result.error) {
        await fetchUsers()
      }

      return result
    } catch (err) {
      console.error('Error deleting user:', err)
      return { data: null, error: err as Error }
    }
  }

  const resetPassword = async (email: string) => {
    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`
      })

      if (error) throw error
      return { error: null }
    } catch (err) {
      console.error('Error resetting password:', err)
      return { error: err as Error }
    }
  }

  return {
    users,
    loading,
    error,
    createUser,
    updateUser,
    deleteUser,
    resetPassword,
    refresh: fetchUsers
  }
}
