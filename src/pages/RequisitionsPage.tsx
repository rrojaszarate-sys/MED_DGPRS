import { useState } from 'react'
import {
  FileText,
  Search,
  Plus,
  CheckCircle,
  XCircle,
  Send,
  Package,
  Clock,
  AlertCircle
} from 'lucide-react'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { Button } from '../components/ui/Button'
import { useRequisitions } from '../hooks/useRequisitions'
import { useCentro } from '../context/CentroContext'
import { useToast } from '../components/ui/Toast'
import { RequisitionFormModal } from '../components/requisitions/RequisitionFormModal'
import type { Requisition, RequisitionItem } from '../types'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'

export function RequisitionsPage() {
  const { centroSeleccionado } = useCentro()
  const { requisitions, loading, createRequisition, submitRequisition, approveRequisition, rejectRequisition, fulfillRequisition } = useRequisitions(centroSeleccionado?.id)
  const toast = useToast()
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState<Requisition['status'] | 'all'>('all')
  const [showCreateModal, setShowCreateModal] = useState(false)

  const filteredRequisitions = requisitions.filter((req) => {
    const searchLower = searchTerm.toLowerCase()
    const matchesSearch =
      req.requisition_number.toLowerCase().includes(searchLower) ||
      req.requesting_service.toLowerCase().includes(searchLower) ||
      req.requesting_user?.full_name?.toLowerCase().includes(searchLower)

    const matchesStatus = selectedStatus === 'all' || req.status === selectedStatus

    return matchesSearch && matchesStatus
  })

  const getStatusBadge = (status: Requisition['status']) => {
    const statusConfig: Record<Requisition['status'], { color: string; icon: any; label: string }> = {
      borrador: { color: 'bg-gray-100 text-gray-800 border-gray-200', icon: FileText, label: 'Borrador' },
      solicitada: { color: 'bg-blue-100 text-blue-800 border-blue-200', icon: Send, label: 'Solicitada' },
      aprobada: { color: 'bg-green-100 text-green-800 border-green-200', icon: CheckCircle, label: 'Aprobada' },
      rechazada: { color: 'bg-red-100 text-red-800 border-red-200', icon: XCircle, label: 'Rechazada' },
      surtida: { color: 'bg-purple-100 text-purple-800 border-purple-200', icon: Package, label: 'Surtida' },
      completada: { color: 'bg-teal-100 text-teal-800 border-teal-200', icon: CheckCircle, label: 'Completada' },
    }

    const config = statusConfig[status]
    const Icon = config.icon

    return (
      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium border ${config.color}`}>
        <Icon className="h-3 w-3" />
        {config.label}
      </span>
    )
  }

  const getPriorityBadge = (priority: string | undefined) => {
    if (!priority) return null

    const priorityConfig: Record<string, { color: string; label: string }> = {
      normal: { color: 'bg-gray-100 text-gray-700', label: 'Normal' },
      urgente: { color: 'bg-orange-100 text-orange-700', label: 'Urgente' },
      emergencia: { color: 'bg-red-100 text-red-700', label: 'Emergencia' },
    }

    const config = priorityConfig[priority] || priorityConfig.normal

    return (
      <span className={`inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium ${config.color}`}>
        {config.label}
      </span>
    )
  }

  const formatDate = (date: string | null | undefined) => {
    if (!date) return 'N/A'
    try {
      return format(new Date(date), 'dd MMM yyyy HH:mm', { locale: es })
    } catch {
      return 'Fecha inválida'
    }
  }

  const handleCreateRequisition = async (requisition: Partial<Requisition>, items: Partial<RequisitionItem>[]) => {
    const result = await createRequisition(requisition, items)
    if (result) {
      toast.success('Requisición creada exitosamente')
      setShowCreateModal(false)
    } else {
      toast.error('Error al crear requisición')
    }
  }

  const handleSubmit = async (id: string) => {
    if (window.confirm('¿Enviar esta requisición para aprobación?')) {
      await submitRequisition(id)
    }
  }

  const handleApprove = async (reqId: string, items: any[]) => {
    const approvedItems = items.map(item => ({
      id: item.id,
      cantidad_aprobada: item.cantidad_solicitada
    }))
    await approveRequisition(reqId, approvedItems)
  }

  const handleReject = async (reqId: string) => {
    const reason = window.prompt('¿Por qué se rechaza esta requisición?')
    if (reason) {
      await rejectRequisition(reqId, reason)
    }
  }

  const handleFulfill = async (reqId: string, items: any[]) => {
    const fulfilledItems = items.map(item => ({
      id: item.id,
      cantidad_surtida: item.cantidad_aprobada || item.cantidad_solicitada
    }))
    await fulfillRequisition(reqId, fulfilledItems)
  }

  const stats = {
    total: requisitions.length,
    pending: requisitions.filter(r => r.status === 'solicitada').length,
    approved: requisitions.filter(r => r.status === 'aprobada').length,
    urgent: requisitions.filter(r => r.prioridad === 'urgente' || r.prioridad === 'emergencia').length,
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Requisiciones Internas</h1>
          <p className="text-gray-600 mt-1">
            Gestión de solicitudes de medicamentos entre departamentos
          </p>
        </div>
        <Button onClick={() => setShowCreateModal(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Nueva Requisición
        </Button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Requisiciones</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{stats.total}</p>
            </div>
            <FileText className="h-10 w-10 text-blue-500" />
          </div>
        </Card>

        <Card className="bg-yellow-50 border-l-4 border-l-yellow-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-yellow-600">Pendientes</p>
              <p className="text-3xl font-bold text-yellow-900 mt-2">{stats.pending}</p>
            </div>
            <Clock className="h-10 w-10 text-yellow-500" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Aprobadas</p>
              <p className="text-3xl font-bold text-green-900 mt-2">{stats.approved}</p>
            </div>
            <CheckCircle className="h-10 w-10 text-green-500" />
          </div>
        </Card>

        <Card className="bg-red-50 border-l-4 border-l-red-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-red-600">Urgentes</p>
              <p className="text-3xl font-bold text-red-900 mt-2">{stats.urgent}</p>
            </div>
            <AlertCircle className="h-10 w-10 text-red-500" />
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              type="text"
              placeholder="Buscar por número, servicio o solicitante..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value as any)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="all">Todos los estados</option>
            <option value="borrador">Borradores</option>
            <option value="solicitada">Solicitadas</option>
            <option value="aprobada">Aprobadas</option>
            <option value="rechazada">Rechazadas</option>
            <option value="surtida">Surtidas</option>
            <option value="completada">Completadas</option>
          </select>
        </div>
      </Card>

      {/* Requisitions List */}
      {loading ? (
        <Card>
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="text-gray-600 mt-4">Cargando requisiciones...</p>
          </div>
        </Card>
      ) : filteredRequisitions.length === 0 ? (
        <Card>
          <div className="text-center py-12">
            <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600">No se encontraron requisiciones</p>
          </div>
        </Card>
      ) : (
        <div className="space-y-4">
          {filteredRequisitions.map((req) => (
            <Card key={req.id} className="hover:shadow-lg transition-shadow">
              <div className="space-y-4">
                {/* Header */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="bg-blue-100 p-3 rounded-lg">
                      <FileText className="h-6 w-6 text-blue-600" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h3 className="font-semibold text-lg text-gray-900">
                          {req.requisition_number}
                        </h3>
                        {getPriorityBadge(req.prioridad)}
                      </div>
                      <p className="text-sm text-gray-600">
                        Creado: {formatDate(req.created_at)}
                      </p>
                    </div>
                  </div>
                  {getStatusBadge(req.status)}
                </div>

                {/* Service and Center */}
                <div className="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <p className="text-xs text-gray-500 mb-1">Servicio Solicitante</p>
                    <p className="font-medium text-gray-900">{req.requesting_service}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500 mb-1">Centro</p>
                    <p className="font-medium text-gray-900">
                      {req.center?.name || 'N/A'}
                    </p>
                  </div>
                </div>

                {/* Requesting User */}
                {req.requesting_user && (
                  <div className="text-sm text-gray-600">
                    <span className="font-medium">Solicitante:</span>{' '}
                    {req.requesting_user.full_name || req.requesting_user.email}
                  </div>
                )}

                {/* Dates */}
                {req.fecha_necesaria && (
                  <div className="text-sm">
                    <span className="font-medium text-gray-700">Fecha necesaria:</span>{' '}
                    <span className="text-gray-600">{formatDate(req.fecha_necesaria)}</span>
                  </div>
                )}

                {/* Items */}
                {req.items && req.items.length > 0 && (
                  <div className="border-t pt-4">
                    <p className="text-sm font-medium text-gray-700 mb-2">
                      Medicamentos ({req.items.length})
                    </p>
                    <div className="space-y-2">
                      {req.items.slice(0, 3).map((item) => (
                        <div key={item.id} className="flex items-center justify-between text-sm bg-gray-50 p-2 rounded">
                          <span className="text-gray-900">
                            {item.medication?.nombre || 'N/A'}
                          </span>
                          <div className="flex gap-4 text-gray-600">
                            <span>Solicitado: {item.cantidad_solicitada}</span>
                            {item.cantidad_aprobada && (
                              <span>Aprobado: {item.cantidad_aprobada}</span>
                            )}
                            {item.cantidad_surtida && (
                              <span>Surtido: {item.cantidad_surtida}</span>
                            )}
                          </div>
                        </div>
                      ))}
                      {req.items.length > 3 && (
                        <p className="text-xs text-gray-500 text-center">
                          Y {req.items.length - 3} más...
                        </p>
                      )}
                    </div>
                  </div>
                )}

                {/* Observations */}
                {req.observaciones && (
                  <div className="text-sm text-gray-600 bg-blue-50 p-3 rounded">
                    <span className="font-medium">Observaciones:</span> {req.observaciones}
                  </div>
                )}

                {/* Rejection Reason */}
                {req.motivo_rechazo && (
                  <div className="text-sm text-red-600 bg-red-50 p-3 rounded">
                    <span className="font-medium">Motivo de rechazo:</span> {req.motivo_rechazo}
                  </div>
                )}

                {/* Actions */}
                <div className="flex gap-2 border-t pt-4">
                  {req.status === 'borrador' && (
                    <Button
                      onClick={() => handleSubmit(req.id)}
                      className="flex-1 bg-blue-600 hover:bg-blue-700"
                    >
                      <Send className="h-4 w-4 mr-2" />
                      Enviar
                    </Button>
                  )}

                  {req.status === 'solicitada' && (
                    <>
                      <Button
                        onClick={() => handleApprove(req.id, req.items || [])}
                        className="flex-1 bg-green-600 hover:bg-green-700"
                      >
                        <CheckCircle className="h-4 w-4 mr-2" />
                        Aprobar
                      </Button>
                      <Button
                        onClick={() => handleReject(req.id)}
                        variant="outline"
                        className="flex-1 border-red-300 text-red-600 hover:bg-red-50"
                      >
                        <XCircle className="h-4 w-4 mr-2" />
                        Rechazar
                      </Button>
                    </>
                  )}

                  {req.status === 'aprobada' && (
                    <Button
                      onClick={() => handleFulfill(req.id, req.items || [])}
                      className="flex-1 bg-purple-600 hover:bg-purple-700"
                    >
                      <Package className="h-4 w-4 mr-2" />
                      Marcar como Surtida
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Create Requisition Modal */}
      <RequisitionFormModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        onSubmit={handleCreateRequisition}
      />
    </div>
  )
}
