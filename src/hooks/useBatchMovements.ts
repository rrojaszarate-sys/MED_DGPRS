import { useState } from 'react';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';

export interface BatchMovement {
  id: string;
  medication_id: string;
  tipo_movimiento: string;
  cantidad: number;
  cantidad_anterior: number;
  cantidad_posterior: number;
  centro_origen_id?: string;
  centro_destino_id?: string;
  transfer_id?: string;
  requisition_id?: string;
  adjustment_id?: string;
  numero_documento?: string;
  motivo: string;
  observaciones?: string;
  usuario_responsable: string;
  created_at: string;
  metadata?: Record<string, any>;
}

export interface MovementParams {
  medication_id: string;
  tipo_movimiento: 'entrada' | 'salida' | 'ajuste' | 'vencimiento' | 'merma' | 'transferencia_salida' | 'transferencia_entrada' | 'devolucion' | 'destruccion';
  cantidad: number;
  motivo: string;
  usuario_responsable: string;
  centro_origen_id?: string;
  centro_destino_id?: string;
  transfer_id?: string;
  requisition_id?: string;
  adjustment_id?: string;
  numero_documento?: string;
  observaciones?: string;
  metadata?: Record<string, any>;
}

export function useBatchMovements() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  /**
   * Registra un movimiento de lote
   */
  async function registrarMovimiento(params: MovementParams) {
    try {
      setLoading(true);
      setError(null);

      const { data, error: rpcError } = await supabase.rpc('registrar_movimiento_lote', {
        p_medication_id: params.medication_id,
        p_tipo_movimiento: params.tipo_movimiento,
        p_cantidad: params.cantidad,
        p_motivo: params.motivo,
        p_usuario_responsable: params.usuario_responsable,
        p_centro_origen_id: params.centro_origen_id || null,
        p_centro_destino_id: params.centro_destino_id || null,
        p_transfer_id: params.transfer_id || null,
        p_requisition_id: params.requisition_id || null,
        p_adjustment_id: params.adjustment_id || null,
        p_numero_documento: params.numero_documento || null,
        p_observaciones: params.observaciones || null,
        p_metadata: params.metadata || {}
      });

      if (rpcError) {
        throw rpcError;
      }

      // La función retorna JSONB con success, message, etc.
      if (data && !data.success) {
        throw new Error(data.message || 'Error al registrar movimiento');
      }

      toast.success(data?.message || 'Movimiento registrado exitosamente');
      return data;
    } catch (err: any) {
      const errorMessage = err.message || 'Error al registrar movimiento';
      setError(errorMessage);
      toast.error(errorMessage);
      throw err;
    } finally {
      setLoading(false);
    }
  }

  /**
   * Obtiene el historial de movimientos de un medicamento
   */
  async function fetchMovimientos(medicationId: string): Promise<BatchMovement[]> {
    try {
      setLoading(true);
      setError(null);

      const { data, error: queryError } = await supabase
        .from('movimientos_lotes')
        .select('*')
        .eq('medicamento_id', medicationId)
        .order('created_at', { ascending: false });

      if (queryError) {
        throw queryError;
      }

      return data || [];
    } catch (err: any) {
      const errorMessage = err.message || 'Error al obtener movimientos';
      setError(errorMessage);
      toast.error(errorMessage);
      return [];
    } finally {
      setLoading(false);
    }
  }

  /**
   * Obtiene todos los movimientos de un centro
   */
  async function fetchMovimientosByCentro(centroId: string, limit = 100): Promise<BatchMovement[]> {
    try {
      setLoading(true);
      setError(null);

      const { data, error: queryError } = await supabase
        .from('movimientos_lotes')
        .select(`
          *,
          medicamentos!inner(centro_id)
        `)
        .eq('medicamentos.centro_id', centroId)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (queryError) {
        throw queryError;
      }

      return data || [];
    } catch (err: any) {
      const errorMessage = err.message || 'Error al obtener movimientos del centro';
      setError(errorMessage);
      toast.error(errorMessage);
      return [];
    } finally {
      setLoading(false);
    }
  }

  return {
    loading,
    error,
    registrarMovimiento,
    fetchMovimientos,
    fetchMovimientosByCentro
  };
}
