import { useState } from 'react'
import {
  ArrowRightLeft,
  Search,
  Plus,
  CheckCircle,
  XCircle,
  Truck,
  Clock,
  Package
} from 'lucide-react'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { Button } from '../components/ui/Button'
import { useTransfers } from '../hooks/useTransfers'
import { useCentro } from '../context/CentroContext'
import type { Transfer } from '../types'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'

export function TransfersPage() {
  const { centroSeleccionado } = useCentro()
  const { transfers, loading, approveTransfer, rejectTransfer, shipTransfer, receiveTransfer } = useTransfers(centroSeleccionado?.id)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState<Transfer['status'] | 'all'>('all')
  const [showCreateModal, setShowCreateModal] = useState(false)

  const filteredTransfers = transfers.filter((transfer) => {
    const searchLower = searchTerm.toLowerCase()
    const matchesSearch =
      transfer.transfer_number.toLowerCase().includes(searchLower) ||
      transfer.origin_center?.name.toLowerCase().includes(searchLower) ||
      transfer.destination_center?.name.toLowerCase().includes(searchLower)

    const matchesStatus = selectedStatus === 'all' || transfer.status === selectedStatus

    return matchesSearch && matchesStatus
  })

  const getStatusBadge = (status: Transfer['status']) => {
    const statusConfig: Record<Transfer['status'], { color: string; icon: any; label: string }> = {
      pending: { color: 'bg-yellow-100 text-yellow-800 border-yellow-200', icon: Clock, label: 'Pendiente' },
      approved: { color: 'bg-blue-100 text-blue-800 border-blue-200', icon: CheckCircle, label: 'Aprobada' },
      rejected: { color: 'bg-red-100 text-red-800 border-red-200', icon: XCircle, label: 'Rechazada' },
      in_transit: { color: 'bg-purple-100 text-purple-800 border-purple-200', icon: Truck, label: 'En tránsito' },
      received: { color: 'bg-green-100 text-green-800 border-green-200', icon: Package, label: 'Recibida' },
      completed: { color: 'bg-gray-100 text-gray-800 border-gray-200', icon: CheckCircle, label: 'Completada' },
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

  const formatDate = (date: string | null | undefined) => {
    if (!date) return 'N/A'
    try {
      return format(new Date(date), 'dd MMM yyyy HH:mm', { locale: es })
    } catch {
      return 'Fecha inválida'
    }
  }

  const handleApprove = async (transferId: string, items: any[]) => {
    const approvedItems = items.map(item => ({
      id: item.id,
      cantidad_aprobada: item.cantidad_solicitada
    }))
    await approveTransfer(transferId, approvedItems)
  }

  const handleReject = async (transferId: string) => {
    const reason = window.prompt('¿Por qué se rechaza esta transferencia?')
    if (reason) {
      await rejectTransfer(transferId, reason)
    }
  }

  const handleShip = async (transferId: string, items: any[]) => {
    const shippedItems = items.map(item => ({
      id: item.id,
      cantidad_enviada: item.cantidad_aprobada || item.cantidad_solicitada
    }))
    await shipTransfer(transferId, shippedItems)
  }

  const handleReceive = async (transferId: string, items: any[]) => {
    const receivedItems = items.map(item => ({
      id: item.id,
      cantidad_recibida: item.cantidad_enviada || item.cantidad_aprobada || item.cantidad_solicitada
    }))
    await receiveTransfer(transferId, receivedItems)
  }

  const stats = {
    total: transfers.length,
    pending: transfers.filter(t => t.status === 'pending').length,
    inTransit: transfers.filter(t => t.status === 'in_transit').length,
    completed: transfers.filter(t => t.status === 'completed').length,
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Transferencias entre Centros</h1>
          <p className="text-gray-600 mt-1">
            Gestión de transferencias de medicamentos entre centros de salud
          </p>
        </div>
        <Button onClick={() => setShowCreateModal(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Nueva Transferencia
        </Button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Transferencias</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{stats.total}</p>
            </div>
            <ArrowRightLeft className="h-10 w-10 text-blue-500" />
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

        <Card className="bg-purple-50 border-l-4 border-l-purple-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-purple-600">En Tránsito</p>
              <p className="text-3xl font-bold text-purple-900 mt-2">{stats.inTransit}</p>
            </div>
            <Truck className="h-10 w-10 text-purple-500" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Completadas</p>
              <p className="text-3xl font-bold text-green-900 mt-2">{stats.completed}</p>
            </div>
            <CheckCircle className="h-10 w-10 text-green-500" />
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
              placeholder="Buscar por número, centro origen o destino..."
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
            <option value="pending">Pendientes</option>
            <option value="approved">Aprobadas</option>
            <option value="in_transit">En tránsito</option>
            <option value="received">Recibidas</option>
            <option value="completed">Completadas</option>
            <option value="rejected">Rechazadas</option>
          </select>
        </div>
      </Card>

      {/* Transfers List */}
      {loading ? (
        <Card>
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="text-gray-600 mt-4">Cargando transferencias...</p>
          </div>
        </Card>
      ) : filteredTransfers.length === 0 ? (
        <Card>
          <div className="text-center py-12">
            <ArrowRightLeft className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600">No se encontraron transferencias</p>
          </div>
        </Card>
      ) : (
        <div className="space-y-4">
          {filteredTransfers.map((transfer) => (
            <Card key={transfer.id} className="hover:shadow-lg transition-shadow">
              <div className="space-y-4">
                {/* Header */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="bg-blue-100 p-3 rounded-lg">
                      <ArrowRightLeft className="h-6 w-6 text-blue-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-lg text-gray-900">
                        {transfer.transfer_number}
                      </h3>
                      <p className="text-sm text-gray-600">
                        Solicitado: {formatDate(transfer.requested_at)}
                      </p>
                    </div>
                  </div>
                  {getStatusBadge(transfer.status)}
                </div>

                {/* Route */}
                <div className="flex items-center gap-4 bg-gray-50 p-4 rounded-lg">
                  <div className="flex-1">
                    <p className="text-xs text-gray-500 mb-1">Origen</p>
                    <p className="font-medium text-gray-900">
                      {transfer.origin_center?.name || 'N/A'}
                    </p>
                    <p className="text-sm text-gray-600">
                      {transfer.origin_center?.code}
                    </p>
                  </div>
                  <ArrowRightLeft className="h-6 w-6 text-gray-400 flex-shrink-0" />
                  <div className="flex-1 text-right">
                    <p className="text-xs text-gray-500 mb-1">Destino</p>
                    <p className="font-medium text-gray-900">
                      {transfer.destination_center?.name || 'N/A'}
                    </p>
                    <p className="text-sm text-gray-600">
                      {transfer.destination_center?.code}
                    </p>
                  </div>
                </div>

                {/* Items */}
                {transfer.items && transfer.items.length > 0 && (
                  <div className="border-t pt-4">
                    <p className="text-sm font-medium text-gray-700 mb-2">
                      Medicamentos ({transfer.items.length})
                    </p>
                    <div className="space-y-2">
                      {transfer.items.slice(0, 3).map((item) => (
                        <div key={item.id} className="flex items-center justify-between text-sm bg-gray-50 p-2 rounded">
                          <span className="text-gray-900">
                            {item.medication?.nombre || 'N/A'}
                          </span>
                          <div className="flex gap-4 text-gray-600">
                            <span>Solicitado: {item.cantidad_solicitada}</span>
                            {item.cantidad_aprobada && (
                              <span>Aprobado: {item.cantidad_aprobada}</span>
                            )}
                            {item.cantidad_enviada && (
                              <span>Enviado: {item.cantidad_enviada}</span>
                            )}
                            {item.cantidad_recibida && (
                              <span>Recibido: {item.cantidad_recibida}</span>
                            )}
                          </div>
                        </div>
                      ))}
                      {transfer.items.length > 3 && (
                        <p className="text-xs text-gray-500 text-center">
                          Y {transfer.items.length - 3} más...
                        </p>
                      )}
                    </div>
                  </div>
                )}

                {/* Notes */}
                {transfer.notes && (
                  <div className="text-sm text-gray-600 bg-blue-50 p-3 rounded">
                    <span className="font-medium">Notas:</span> {transfer.notes}
                  </div>
                )}

                {/* Rejection Reason */}
                {transfer.rejection_reason && (
                  <div className="text-sm text-red-600 bg-red-50 p-3 rounded">
                    <span className="font-medium">Motivo de rechazo:</span> {transfer.rejection_reason}
                  </div>
                )}

                {/* Actions */}
                <div className="flex gap-2 border-t pt-4">
                  {transfer.status === 'pending' && (
                    <>
                      <Button
                        onClick={() => handleApprove(transfer.id, transfer.items || [])}
                        className="flex-1 bg-green-600 hover:bg-green-700"
                      >
                        <CheckCircle className="h-4 w-4 mr-2" />
                        Aprobar
                      </Button>
                      <Button
                        onClick={() => handleReject(transfer.id)}
                        variant="outline"
                        className="flex-1 border-red-300 text-red-600 hover:bg-red-50"
                      >
                        <XCircle className="h-4 w-4 mr-2" />
                        Rechazar
                      </Button>
                    </>
                  )}

                  {transfer.status === 'approved' && (
                    <Button
                      onClick={() => handleShip(transfer.id, transfer.items || [])}
                      className="flex-1 bg-purple-600 hover:bg-purple-700"
                    >
                      <Truck className="h-4 w-4 mr-2" />
                      Marcar como Enviada
                    </Button>
                  )}

                  {transfer.status === 'in_transit' && (
                    <Button
                      onClick={() => handleReceive(transfer.id, transfer.items || [])}
                      className="flex-1 bg-blue-600 hover:bg-blue-700"
                    >
                      <Package className="h-4 w-4 mr-2" />
                      Confirmar Recepción
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* TODO: Create Transfer Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="max-w-2xl w-full mx-4">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Nueva Transferencia</h2>
              <button
                onClick={() => setShowCreateModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <XCircle className="h-6 w-6" />
              </button>
            </div>
            <p className="text-gray-600 text-center py-8">
              Formulario de creación de transferencia en construcción...
            </p>
          </Card>
        </div>
      )}
    </div>
  )
}
