export interface User {
  id: string
  email: string
  full_name?: string
  role: 'super_admin' | 'admin_center' | 'inventory_user' | 'read_only'
  avatar_url?: string
  is_active: boolean
  created_at: string
}

export interface HealthCenter {
  id: string
  name: string
  code: string
  address?: string
  city?: string
  phone?: string
  is_active: boolean
}

export interface MedicationCatalog {
  id: string
  nombre: string
  formula_activa: string
  descripcion?: string
  categoria?: string
  is_active: boolean
  created_at: string
}

export interface Medication {
  id: string
  center_id: string
  catalog_id?: string
  nombre: string
  descripcion?: string
  unidad_medida: string
  categoria?: string
  requiere_refrigeracion: boolean
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Batch {
  id: string
  medication_id: string
  center_id: string
  supplier_id?: string
  numero_lote: string
  cantidad_inicial: number
  cantidad_actual: number
  fecha_fabricacion?: string
  fecha_caducidad: string
  fecha_ingreso: string
  ubicacion_fisica?: string
  temperatura_almacenamiento?: string
  stock_minimo: number
  stock_maximo?: number
  estado: 'disponible' | 'cuarentena' | 'vencido' | 'agotado'
  observaciones?: string
  created_at: string
  updated_at: string
  // Relaciones
  medication?: Medication
  health_center?: HealthCenter
  supplier?: Supplier
}

export interface Supplier {
  id: string
  nombre: string
  rfc?: string
  razon_social?: string
  direccion?: string
  ciudad?: string
  estado?: string
  telefono?: string
  email?: string
  contacto_nombre?: string
  contacto_telefono?: string
  terminos_pago?: string
  dias_credito: number
  calificacion?: number
  notas?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Alert {
  id: string
  medicamento_id: string
  centro_id: string
  nivel_alerta: 'critico' | 'urgente' | 'preventivo'
  dias_restantes: number
  visto: boolean
  resuelta: boolean
  created_at: string
  medicamento?: Medication
}

export interface BatchMovement {
  id: string
  medication_id: string
  tipo_movimiento: 'entrada' | 'salida' | 'ajuste' | 'vencimiento' | 'merma' | 'transferencia_salida' | 'transferencia_entrada' | 'devolucion' | 'destruccion'
  cantidad: number
  cantidad_anterior: number
  cantidad_posterior: number
  centro_origen_id?: string
  centro_destino_id?: string
  motivo: string
  observaciones?: string
  usuario_responsable: string
  created_at: string
  metadata?: Record<string, any>
}

export interface AuditLog {
  id: string
  user_id?: string
  user_email?: string
  user_name?: string
  action_type: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE' | 'LOGIN' | 'LOGOUT' | 'EXPORT' | 'IMPORT' | 'ADJUST' | 'TRANSFER'
  entity_type: 'medication' | 'user' | 'center' | 'transfer' | 'batch' | 'catalog'
  entity_id?: string
  entity_name?: string
  old_values?: Record<string, any>
  new_values?: Record<string, any>
  changes_summary?: string
  result?: 'success' | 'failed' | 'partial'
  severity?: 'low' | 'medium' | 'high' | 'critical'
  metadata?: Record<string, any>
  created_at: string
}

export interface AuthContextType {
  user: User | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
  devModeLogin?: (mockUser: User) => Promise<void>
}
