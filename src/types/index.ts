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

export interface Medication {
  id: string
  center_id: string
  catalog_id?: string
  nombre: string
  formula_activa: string
  lote: string
  cantidad: number
  fecha_caducidad: string
  fecha_ingreso: string
  estado: 'Disponible' | 'No Disponible' | 'Cuarentena'
  created_at: string
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

export interface AuthContextType {
  user: User | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}
