import { Edit, Trash2, Calendar, Package } from 'lucide-react'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../ui/Table'
import { Badge } from '../ui/Badge'
import { Button } from '../ui/Button'
import type { Medication } from '../../types'

interface MedicamentoTableProps {
  medicamentos: Medication[]
  loading: boolean
  onEdit: (medicamento: Medication) => void
  onDelete: (id: string) => void
}

export function MedicamentoTable({ medicamentos, loading, onEdit, onDelete }: MedicamentoTableProps) {
  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
          <p className="mt-4 text-gray-600">Cargando medicamentos...</p>
        </div>
      </div>
    )
  }

  if (medicamentos.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow-md p-12 text-center">
        <Package className="h-16 w-16 text-gray-300 mx-auto mb-4" />
        <h3 className="text-lg font-medium text-gray-900 mb-2">
          No hay medicamentos registrados
        </h3>
        <p className="text-gray-600">
          Comienza agregando medicamentos a tu inventario
        </p>
      </div>
    )
  }

  const getEstadoBadge = (estado: string) => {
    switch (estado) {
      case 'Disponible':
        return <Badge variant="success">Disponible</Badge>
      case 'No Disponible':
        return <Badge variant="danger">No Disponible</Badge>
      case 'Cuarentena':
        return <Badge variant="warning">Cuarentena</Badge>
      default:
        return <Badge>{estado}</Badge>
    }
  }

  const getDaysUntilExpiry = (fechaCaducidad: string) => {
    const today = new Date()
    const expiry = new Date(fechaCaducidad)
    const diffTime = expiry.getTime() - today.getTime()
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
    return diffDays
  }

  const getExpiryBadge = (fechaCaducidad: string) => {
    const days = getDaysUntilExpiry(fechaCaducidad)

    if (days < 0) {
      return <Badge variant="danger">Caducado</Badge>
    } else if (days <= 7) {
      return <Badge variant="danger">{days} días</Badge>
    } else if (days <= 30) {
      return <Badge variant="warning">{days} días</Badge>
    } else if (days <= 90) {
      return <Badge variant="info">{days} días</Badge>
    } else {
      return <Badge variant="success">{days} días</Badge>
    }
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Medicamento</TableHead>
          <TableHead>Lote</TableHead>
          <TableHead>Cantidad</TableHead>
          <TableHead>Caducidad</TableHead>
          <TableHead>Estado</TableHead>
          <TableHead>Acciones</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {medicamentos.map((medicamento) => (
          <TableRow key={medicamento.id}>
            <TableCell>
              <div>
                <div className="font-medium text-gray-900">{medicamento.nombre}</div>
                <div className="text-sm text-gray-500">{medicamento.formula_activa}</div>
              </div>
            </TableCell>
            <TableCell>
              <span className="font-mono text-sm">{medicamento.lote}</span>
            </TableCell>
            <TableCell>
              <div className="flex items-center gap-2">
                <Package className="h-4 w-4 text-gray-400" />
                <span className="font-semibold">{medicamento.cantidad}</span>
              </div>
            </TableCell>
            <TableCell>
              <div className="space-y-1">
                <div className="flex items-center gap-2 text-sm">
                  <Calendar className="h-4 w-4 text-gray-400" />
                  {format(new Date(medicamento.fecha_caducidad), 'dd/MM/yyyy', { locale: es })}
                </div>
                {getExpiryBadge(medicamento.fecha_caducidad)}
              </div>
            </TableCell>
            <TableCell>
              {getEstadoBadge(medicamento.estado)}
            </TableCell>
            <TableCell>
              <div className="flex items-center gap-2">
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => onEdit(medicamento)}
                  icon={<Edit className="h-4 w-4" />}
                >
                  Editar
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => onDelete(medicamento.id)}
                  icon={<Trash2 className="h-4 w-4 text-red-600" />}
                  className="text-red-600 hover:bg-red-50"
                />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
