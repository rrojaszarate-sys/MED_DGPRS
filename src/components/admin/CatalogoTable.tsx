import { Pencil, Trash2 } from 'lucide-react'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../ui/Table'
import { Button } from '../ui/Button'
import { Badge } from '../ui/Badge'
import type { MedicationCatalog } from '../../types'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'

interface CatalogoTableProps {
  catalogos: MedicationCatalog[]
  loading?: boolean
  onEdit: (catalogo: MedicationCatalog) => void
  onDelete: (id: string) => void
}

export function CatalogoTable({ catalogos, loading, onEdit, onDelete }: CatalogoTableProps) {
  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (catalogos.length === 0) {
    return (
      <div className="text-center py-12 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
        <p className="text-gray-500 text-lg">No hay medicamentos en el catálogo</p>
        <p className="text-gray-400 text-sm mt-2">Agrega el primer medicamento para comenzar</p>
      </div>
    )
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Nombre</TableHead>
          <TableHead>Fórmula Activa</TableHead>
          <TableHead>Categoría</TableHead>
          <TableHead>Estado</TableHead>
          <TableHead>Fecha Creación</TableHead>
          <TableHead className="text-right">Acciones</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {catalogos.map((catalogo) => (
          <TableRow key={catalogo.id}>
            <TableCell className="font-medium">{catalogo.nombre}</TableCell>
            <TableCell>{catalogo.formula_activa}</TableCell>
            <TableCell>
              {catalogo.categoria ? (
                <Badge variant="info" size="sm">{catalogo.categoria}</Badge>
              ) : (
                <span className="text-gray-400 text-sm">Sin categoría</span>
              )}
            </TableCell>
            <TableCell>
              {catalogo.is_active ? (
                <Badge variant="success">Activo</Badge>
              ) : (
                <Badge variant="default">Inactivo</Badge>
              )}
            </TableCell>
            <TableCell className="text-sm text-gray-600">
              {format(new Date(catalogo.created_at), 'dd/MM/yyyy', { locale: es })}
            </TableCell>
            <TableCell>
              <div className="flex items-center justify-end gap-2">
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => onEdit(catalogo)}
                  icon={<Pencil className="h-4 w-4" />}
                >
                  Editar
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => {
                    if (confirm('¿Estás seguro de eliminar este medicamento del catálogo?')) {
                      onDelete(catalogo.id)
                    }
                  }}
                  icon={<Trash2 className="h-4 w-4" />}
                >
                  Eliminar
                </Button>
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
