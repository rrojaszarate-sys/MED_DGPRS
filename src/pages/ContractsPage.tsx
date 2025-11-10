import { useState, useMemo } from 'react'
import { Plus, Search, FileText, Edit, Trash2, CheckCircle2, XCircle, Clock, AlertCircle } from 'lucide-react'
import { useContracts } from '../hooks/useContracts'
import { ContractFormModal } from '../components/contracts/ContractFormModal'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Card } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { useToast } from '../components/ui/Toast'
import type { Contract, ContractItem } from '../types'

export function ContractsPage() {
  const { contracts, loading, createContract, updateContract, deleteContract } = useContracts()
  const toast = useToast()

  const [searchTerm, setSearchTerm] = useState('')
  const [filterEstado, setFilterEstado] = useState<string>('all')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedContract, setSelectedContract] = useState<Contract | null>(null)

  // Filter contracts
  const filteredContracts = useMemo(() => {
    return contracts.filter((contract) => {
      const searchLower = searchTerm.toLowerCase()
      const matchesSearch =
        contract.codigo_contrato.toLowerCase().includes(searchLower) ||
        contract.supplier?.nombre.toLowerCase().includes(searchLower) ||
        contract.observaciones?.toLowerCase().includes(searchLower)

      const matchesEstado = filterEstado === 'all' || contract.estado === filterEstado

      return matchesSearch && matchesEstado
    })
  }, [contracts, searchTerm, filterEstado])

  // Calculate statistics
  const stats = useMemo(() => {
    const total = contracts.length
    const activos = contracts.filter(c => c.estado === 'activo').length
    const borradores = contracts.filter(c => c.estado === 'borrador').length
    const vencidos = contracts.filter(c => c.estado === 'vencido').length

    const montoTotal = contracts
      .filter(c => c.estado === 'activo')
      .reduce((sum, c) => sum + (c.monto_total || 0), 0)

    return { total, activos, borradores, vencidos, montoTotal }
  }, [contracts])

  const handleCreate = () => {
    setSelectedContract(null)
    setIsModalOpen(true)
  }

  const handleEdit = (contract: Contract) => {
    setSelectedContract(contract)
    setIsModalOpen(true)
  }

  const handleSubmit = async (
    contractData: Omit<Contract, 'id' | 'created_at'>,
    items: Omit<ContractItem, 'contract_id' | 'created_at'>[]
  ) => {
    if (selectedContract) {
      const { error } = await updateContract(selectedContract.id, contractData, items)
      if (error) {
        toast.error('Error al actualizar contrato')
      } else {
        toast.success('Contrato actualizado exitosamente')
      }
    } else {
      // For create, strip ids if present since they'll be generated
      const itemsForCreate = items.map(({ id, ...item }) => item) as Omit<ContractItem, 'id' | 'contract_id' | 'created_at'>[]
      const { error } = await createContract(contractData, itemsForCreate)
      if (error) {
        toast.error('Error al crear contrato')
      } else {
        toast.success('Contrato creado exitosamente')
      }
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('¿Estás seguro de eliminar este contrato? Se eliminarán todos los items asociados.')) return

    const { error } = await deleteContract(id)
    if (error) {
      toast.error('Error al eliminar contrato')
    } else {
      toast.success('Contrato eliminado correctamente')
    }
  }

  const getEstadoBadge = (estado: Contract['estado']) => {
    const variants: Record<Contract['estado'], 'success' | 'warning' | 'danger' | 'default'> = {
      activo: 'success',
      borrador: 'default',
      vencido: 'danger',
      cancelado: 'warning'
    }
    return <Badge variant={variants[estado]}>{estado}</Badge>
  }

  const getEstadoIcon = (estado: Contract['estado']) => {
    switch (estado) {
      case 'activo':
        return <CheckCircle2 className="h-5 w-5 text-green-600" />
      case 'borrador':
        return <Clock className="h-5 w-5 text-gray-600" />
      case 'vencido':
        return <XCircle className="h-5 w-5 text-red-600" />
      case 'cancelado':
        return <AlertCircle className="h-5 w-5 text-yellow-600" />
    }
  }

  const getDaysRemaining = (fechaFin: string) => {
    const days = Math.ceil((new Date(fechaFin).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    return days
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Contratos</h1>
          <p className="text-gray-600 mt-1">Gestión de contratos con proveedores</p>
        </div>
        <Button onClick={handleCreate} icon={<Plus className="h-5 w-5" />}>
          Nuevo Contrato
        </Button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="bg-blue-50 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600">Total Contratos</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">{stats.total}</p>
            </div>
            <FileText className="h-12 w-12 text-blue-600 opacity-50" />
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Activos</p>
              <p className="text-3xl font-bold text-green-900 mt-2">{stats.activos}</p>
              <p className="text-xs text-green-700 mt-1">
                ${stats.montoTotal.toLocaleString('es-MX', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <CheckCircle2 className="h-12 w-12 text-green-600 opacity-50" />
          </div>
        </Card>

        <Card className="bg-gray-50 border-l-4 border-l-gray-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Borradores</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stats.borradores}</p>
            </div>
            <Clock className="h-12 w-12 text-gray-600 opacity-50" />
          </div>
        </Card>

        <Card className="bg-red-50 border-l-4 border-l-red-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-red-600">Vencidos</p>
              <p className="text-3xl font-bold text-red-900 mt-2">{stats.vencidos}</p>
            </div>
            <XCircle className="h-12 w-12 text-red-600 opacity-50" />
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <Input
                placeholder="Código, proveedor u observaciones..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Estado</label>
            <select
              value={filterEstado}
              onChange={(e) => setFilterEstado(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
            >
              <option value="all">Todos</option>
              <option value="borrador">Borrador</option>
              <option value="activo">Activo</option>
              <option value="vencido">Vencido</option>
              <option value="cancelado">Cancelado</option>
            </select>
          </div>
        </div>

        <div className="mt-4 flex items-center justify-between pt-2 border-t">
          <p className="text-sm text-gray-600">
            Mostrando {filteredContracts.length} de {contracts.length} contratos
          </p>
        </div>
      </Card>

      {/* Contracts Table */}
      <Card>
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
          </div>
        ) : filteredContracts.length === 0 ? (
          <div className="text-center py-12 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
            <FileText className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-500 text-lg">No hay contratos registrados</p>
            <p className="text-gray-400 text-sm mt-2">Crea el primer contrato para comenzar</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Código</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Proveedor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vigencia</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Items</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Monto Total</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredContracts.map((contract) => {
                  const daysRemaining = getDaysRemaining(contract.fecha_fin)

                  return (
                    <tr key={contract.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {getEstadoIcon(contract.estado)}
                          <span className="font-mono font-medium text-gray-900">
                            {contract.codigo_contrato}
                          </span>
                        </div>
                      </td>

                      <td className="px-6 py-4">
                        <div>
                          <div className="font-medium text-gray-900">
                            {contract.supplier?.nombre || 'N/A'}
                          </div>
                          {contract.supplier?.rfc && (
                            <div className="text-sm text-gray-500">{contract.supplier.rfc}</div>
                          )}
                        </div>
                      </td>

                      <td className="px-6 py-4">
                        <div className="text-sm">
                          <div className="text-gray-900">
                            {new Date(contract.fecha_inicio).toLocaleDateString()} -{' '}
                            {new Date(contract.fecha_fin).toLocaleDateString()}
                          </div>
                          {contract.estado === 'activo' && (
                            <div className={`text-xs mt-1 ${daysRemaining < 30 ? 'text-red-600' : 'text-gray-500'}`}>
                              {daysRemaining > 0 ? `${daysRemaining} días restantes` : 'Vencido'}
                            </div>
                          )}
                        </div>
                      </td>

                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900">
                          {contract.items?.length || 0} medicamento{contract.items?.length !== 1 ? 's' : ''}
                        </div>
                      </td>

                      <td className="px-6 py-4">
                        <div className="font-semibold text-gray-900">
                          ${(contract.monto_total || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                        </div>
                      </td>

                      <td className="px-6 py-4">
                        {getEstadoBadge(contract.estado)}
                      </td>

                      <td className="px-6 py-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => handleEdit(contract)}
                            className="text-primary hover:text-primary-dark p-1"
                            title="Editar"
                          >
                            <Edit className="h-5 w-5" />
                          </button>
                          <button
                            onClick={() => handleDelete(contract.id)}
                            className="text-red-600 hover:text-red-800 p-1"
                            title="Eliminar"
                          >
                            <Trash2 className="h-5 w-5" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* Modal */}
      <ContractFormModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmit}
        contract={selectedContract}
      />
    </div>
  )
}
