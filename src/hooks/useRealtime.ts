import { useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { RealtimeChannel } from '@supabase/supabase-js'

type RealtimeEvent = 'INSERT' | 'UPDATE' | 'DELETE' | '*'

interface UseRealtimeOptions {
  table: string
  event?: RealtimeEvent
  filter?: string
  onInsert?: (payload: any) => void
  onUpdate?: (payload: any) => void
  onDelete?: (payload: any) => void
  onChange?: (payload: any) => void
}

export function useRealtime({
  table,
  event = '*',
  filter,
  onInsert,
  onUpdate,
  onDelete,
  onChange
}: UseRealtimeOptions) {
  useEffect(() => {
    let channel: RealtimeChannel

    const setupSubscription = () => {
      const channelName = `realtime:${table}:${Date.now()}`

      channel = supabase.channel(channelName)

      // Subscribe to specific events
      if (event === '*' || event === 'INSERT') {
        channel = channel.on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table,
            filter
          },
          (payload) => {
            onInsert?.(payload.new)
            onChange?.(payload)
          }
        )
      }

      if (event === '*' || event === 'UPDATE') {
        channel = channel.on(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table,
            filter
          },
          (payload) => {
            onUpdate?.(payload.new)
            onChange?.(payload)
          }
        )
      }

      if (event === '*' || event === 'DELETE') {
        channel = channel.on(
          'postgres_changes',
          {
            event: 'DELETE',
            schema: 'public',
            table,
            filter
          },
          (payload) => {
            onDelete?.(payload.old)
            onChange?.(payload)
          }
        )
      }

      channel.subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log(`Subscribed to ${table} changes`)
        }
      })
    }

    setupSubscription()

    return () => {
      if (channel) {
        supabase.removeChannel(channel)
      }
    }
  }, [table, event, filter])
}
