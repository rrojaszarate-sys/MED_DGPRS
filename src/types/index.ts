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

export interface Institucion {
  id: string
  nombre: string
  clave?: string
  tipo?: string
  created_at: string
}

export interface MedicationCatalog {
  id: string
  codigo_medicamento: string
  nombre_generico: string
  nombre_comercial?: string
  principio_activo?: string
  forma_farmaceutica?: string
  via_administracion?: string
  concentracion?: string
  unidad_medida?: string
  categoria?: string
  requiere_receta: boolean
  controlado: boolean
  temperatura_almacenamiento?: string
  observaciones?: string
  is_active: boolean
  created_at: string
  updated_at: string
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

export interface Contract {
  id: string
  codigo_contrato: string
  supplier_id: string
  fecha_inicio: string
  fecha_fin: string
  monto_total?: number
  estado: 'borrador' | 'activo' | 'vencido' | 'cancelado'
  pdf_url?: string
  firmado_por?: string
  fecha_firma?: string
  observaciones?: string
  created_at: string
  // Relaciones
  supplier?: Supplier
  items?: ContractItem[]
}

export interface ContractItem {
  id: string
  contract_id: string
  medication_catalog_id: string
  cantidad_comprometida: number
  precio_unitario?: number
  center_destino_id?: string
  fecha_estimada_entrega?: string
  created_at: string
  // Relaciones
  medication_catalog?: MedicationCatalog
  center_destino?: HealthCenter
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

export interface CentroContextType {
  centroSeleccionado: HealthCenter | null
  setCentroSeleccionado: (centro: HealthCenter | null) => void
  centros: HealthCenter[]
  loading: boolean
  refresh: () => Promise<void>
}

// ============================================
// TIPOS PARA CATÁLOGOS ADMINISTRABLES
// ============================================

/**
 * Catálogo de Colores
 * Gestiona la paleta de colores del sistema
 */
export interface CatalogoColor {
  id: string
  nombre: string // "Primario", "Secundario", "Éxito", etc.
  codigo_hex: string // #3B82F6
  codigo_rgb?: string // rgb(59, 130, 246)
  codigo_hsl?: string // hsl(217, 91%, 60%)
  uso?: string // Descripción del uso del color
  categoria: 'principal' | 'estados' | 'graficos' | 'alertas' | 'general'
  orden: number
  es_activo: boolean
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
}

/**
 * Catálogo de Estados
 * Gestiona los estados de cada módulo del sistema
 */
export interface CatalogoEstado {
  id: string
  codigo: string // 'disponible', 'pendiente', 'aprobado'
  nombre: string // "Disponible", "Pendiente de Aprobación"
  descripcion?: string
  modulo: 'medicamentos' | 'requisiciones' | 'transferencias' | 'contratos' | 'general'
  color_id?: string
  icono?: string // Nombre del ícono de lucide-react
  orden: number
  es_estado_inicial: boolean
  es_estado_final: boolean
  permite_edicion: boolean
  es_activo: boolean
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
  // Relaciones
  color?: CatalogoColor
}

/**
 * Catálogo de Tipos de Movimiento
 * Gestiona los tipos de movimientos de inventario
 */
export interface CatalogoTipoMovimiento {
  id: string
  codigo: string // 'compra', 'donacion', 'salida_paciente'
  nombre: string // "Entrada por Compra", "Salida por Dispensación"
  descripcion?: string
  tipo: 'entrada' | 'salida' | 'ajuste' | 'transferencia'
  afecta_stock: boolean
  requiere_aprobacion: boolean
  requiere_documento: boolean
  color_id?: string
  icono?: string
  orden: number
  es_activo: boolean
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
  // Relaciones
  color?: CatalogoColor
}

/**
 * Catálogo de Formas Farmacéuticas
 * Gestiona las formas farmacéuticas de medicamentos
 */
export interface CatalogoFormaFarmaceutica {
  id: string
  codigo: string // 'tableta', 'capsula', 'jarabe'
  nombre: string // "Tableta", "Cápsula"
  descripcion?: string
  categoria: 'solida' | 'liquida' | 'semisólida' | 'gaseosa' | 'parental'
  via_administracion?: string // 'Oral', 'Parenteral', 'Tópica'
  requiere_refrigeracion: boolean
  requiere_cadena_frio: boolean
  unidad_medida_default?: string // 'unidad', 'ml', 'mg'
  icono?: string
  orden: number
  es_activo: boolean
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
}

/**
 * Catálogo de Prioridades
 * Gestiona los niveles de prioridad por módulo
 */
export interface CatalogoPrioridad {
  id: string
  codigo: string // 'baja', 'normal', 'alta', 'urgente', 'emergencia'
  nombre: string // "Baja", "Normal", "Alta"
  descripcion?: string
  modulo: 'requisiciones' | 'transferencias' | 'alertas' | 'notificaciones' | 'general'
  nivel: number // 1-10 (1=máxima prioridad)
  color_id?: string
  icono?: string
  dias_respuesta_esperado?: number
  requiere_notificacion: boolean
  orden: number
  es_activo: boolean
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
  // Relaciones
  color?: CatalogoColor
}

/**
 * Catálogo de Configuraciones
 * Gestiona las configuraciones generales del sistema
 */
export interface CatalogoConfiguracion {
  id: string
  clave: string // 'dias_alerta_critica', 'email_notificaciones'
  valor: string // Valor actual de la configuración
  tipo_dato: 'texto' | 'numero' | 'booleano' | 'json' | 'fecha'
  nombre: string // Nombre legible
  descripcion?: string
  categoria: 'sistema' | 'alertas' | 'notificaciones' | 'seguridad' | 'general'
  valor_por_defecto?: string
  es_requerido: boolean
  es_sensible: boolean // ¿Es información sensible?
  orden: number
  es_activo: boolean
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
}

/**
 * Tipo genérico para formularios de catálogos
 */
export type CatalogoFormData<T> = Omit<T, 'id' | 'created_at' | 'updated_at' | 'created_by' | 'updated_by'>

/**
 * Tipo para filtros de catálogos
 */
export interface CatalogoFiltros {
  es_activo?: boolean
  categoria?: string
  modulo?: string
  busqueda?: string
}
