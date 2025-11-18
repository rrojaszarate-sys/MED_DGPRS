import { useState } from 'react';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';

export interface AuditLogEntry {
  id: string;
  user_id?: string;
  user_email?: string;
  user_name?: string;
  user_role?: string;
  action_type: string;
  entity_type: string;
  entity_id?: string;
  entity_name?: string;
  old_values?: Record<string, any>;
  new_values?: Record<string, any>;
  changes_summary?: string;
  ip_address?: string;
  user_agent?: string;
  session_id?: string;
  result?: string;
  error_message?: string;
  severity?: string;
  metadata?: Record<string, any>;
  created_at: string;
}

export interface AuditFilters {
  user_id?: string;
  action_type?: string;
  entity_type?: string;
  severity?: string;
  result?: string;
  date_from?: string;
  date_to?: string;
}

export function useAuditLog() {
  const [logs, setLogs] = useState<AuditLogEntry[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [totalCount, setTotalCount] = useState(0);

  /**
   * Obtiene registros del audit log con filtros
   */
  async function fetchAuditLogs(filters?: AuditFilters, page = 1, pageSize = 50) {
    try {
      setLoading(true);
      setError(null);

      let query = supabase
        .from('registro_auditoria')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false });

      // Aplicar filtros
      if (filters?.user_id) {
        query = query.eq('user_id', filters.user_id);
      }

      if (filters?.action_type) {
        query = query.eq('action_type', filters.action_type);
      }

      if (filters?.entity_type) {
        query = query.eq('entity_type', filters.entity_type);
      }

      if (filters?.severity) {
        query = query.eq('severity', filters.severity);
      }

      if (filters?.result) {
        query = query.eq('result', filters.result);
      }

      if (filters?.date_from) {
        query = query.gte('created_at', filters.date_from);
      }

      if (filters?.date_to) {
        query = query.lte('created_at', filters.date_to);
      }

      // Paginación
      const from = (page - 1) * pageSize;
      const to = from + pageSize - 1;
      query = query.range(from, to);

      const { data, error: queryError, count } = await query;

      if (queryError) {
        throw queryError;
      }

      setLogs(data || []);
      setTotalCount(count || 0);

      return { data: data || [], count: count || 0 };
    } catch (err: any) {
      const errorMessage = err.message || 'Error al obtener logs de auditoría';
      setError(errorMessage);
      toast.error(errorMessage);
      return { data: [], count: 0 };
    } finally {
      setLoading(false);
    }
  }

  /**
   * Obtiene el historial completo de una entidad específica
   */
  async function fetchEntityHistory(entityType: string, entityId: string) {
    try {
      setLoading(true);
      setError(null);

      const { data, error: queryError } = await supabase
        .from('registro_auditoria')
        .select('*')
        .eq('entity_type', entityType)
        .eq('entity_id', entityId)
        .order('created_at', { ascending: false });

      if (queryError) {
        throw queryError;
      }

      return data || [];
    } catch (err: any) {
      const errorMessage = err.message || 'Error al obtener historial de la entidad';
      setError(errorMessage);
      toast.error(errorMessage);
      return [];
    } finally {
      setLoading(false);
    }
  }

  /**
   * Obtiene estadísticas de auditoría
   */
  async function fetchAuditStats(dateFrom?: string, dateTo?: string) {
    try {
      setLoading(true);
      setError(null);

      let query = supabase
        .from('registro_auditoria')
        .select('action_type, entity_type, severity, result, created_at');

      if (dateFrom) {
        query = query.gte('created_at', dateFrom);
      }

      if (dateTo) {
        query = query.lte('created_at', dateTo);
      }

      const { data, error: queryError } = await query;

      if (queryError) {
        throw queryError;
      }

      // Calcular estadísticas
      const stats = {
        total: data?.length || 0,
        by_action: {} as Record<string, number>,
        by_entity: {} as Record<string, number>,
        by_severity: {} as Record<string, number>,
        by_result: {} as Record<string, number>,
        recent_errors: data?.filter(log => log.result === 'failed').slice(0, 10) || []
      };

      data?.forEach(log => {
        stats.by_action[log.action_type] = (stats.by_action[log.action_type] || 0) + 1;
        stats.by_entity[log.entity_type] = (stats.by_entity[log.entity_type] || 0) + 1;
        if (log.severity) {
          stats.by_severity[log.severity] = (stats.by_severity[log.severity] || 0) + 1;
        }
        if (log.result) {
          stats.by_result[log.result] = (stats.by_result[log.result] || 0) + 1;
        }
      });

      return stats;
    } catch (err: any) {
      const errorMessage = err.message || 'Error al obtener estadísticas de auditoría';
      setError(errorMessage);
      toast.error(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  }

  /**
   * Obtiene actividad reciente de un usuario
   */
  async function fetchUserActivity(userId: string, limit = 20) {
    try {
      setLoading(true);
      setError(null);

      const { data, error: queryError } = await supabase
        .from('registro_auditoria')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (queryError) {
        throw queryError;
      }

      return data || [];
    } catch (err: any) {
      const errorMessage = err.message || 'Error al obtener actividad del usuario';
      setError(errorMessage);
      toast.error(errorMessage);
      return [];
    } finally {
      setLoading(false);
    }
  }

  return {
    logs,
    loading,
    error,
    totalCount,
    fetchAuditLogs,
    fetchEntityHistory,
    fetchAuditStats,
    fetchUserActivity
  };
}
