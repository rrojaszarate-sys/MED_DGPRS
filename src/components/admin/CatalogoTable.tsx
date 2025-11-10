import { Pencil, Trash2, Pill, AlertCircle } from 'lucide-react'
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
        <Pill className="mx-auto h-12 w-12 text-gray-400 mb-4" />
        <p className="text-gray-500 text-lg">No hay medicamentos en el catálogo</p>
        <p className="text-gray-400 text-sm mt-2">Agrega el primer medicamento para comenzar</p>
      </div>
    )
  }

  return (
    <div className="overflow-x-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Código</TableHead>
            <TableHead>Medicamento</TableHead>
            <TableHead>Presentación</TableHead>
            <TableHead>Categoría</TableHead>
            <TableHead>Control</TableHead>
            <TableHead>Estado</TableHead>
            <TableHead className="text-right">Acciones</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {catalogos.map((catalogo) => (
            <TableRow key={catalogo.id} className="hover:bg-gray-50">
              <TableCell>
                <span className="font-mono text-sm text-gray-600">
                  {catalogo.codigo_medicamento}
                </span>
              </TableCell>

              <TableCell>
                <div>
                  <div className="font-medium text-gray-900">
                    {catalogo.nombre_generico}
                  </div>
                  {catalogo.nombre_comercial && (
                    <div className="text-sm text-gray-500">
                      {catalogo.nombre_comercial}
                    </div>
                  )}
                  {catalogo.principio_activo && (
                    <div className="text-xs text-gray-400 mt-1">
                      {catalogo.principio_activo}
                    </div>
                  )}
                </div>
              </TableCell>

              <TableCell>
                <div className="text-sm">
                  {catalogo.concentracion && (
                    <div className="font-medium text-gray-700">
                      {catalogo.concentracion}
                    </div>
                  )}
                  {catalogo.forma_farmaceutica && (
                    <div className="text-gray-500">
                      {catalogo.forma_farmaceutica}
                    </div>
                  )}
                  {catalogo.via_administracion && (
                    <div className="text-xs text-gray-400">
                      Vía: {catalogo.via_administracion}
                    </div>
                  )}
                </div>
              </TableCell>

              <TableCell>
                {catalogo.categoria ? (
                  <Badge variant="info" size="sm">{catalogo.categoria}</Badge>
                ) : (
                  <span className="text-gray-400 text-sm">-</span>
                )}
              </TableCell>

              <TableCell>
                <div className="flex flex-col gap-1">
                  {catalogo.controlado && (
                    <Badge variant="danger" size="sm">
                      <AlertCircle className="h-3 w-3 mr-1" />
                      Controlado
                    </Badge>
                  )}
                  {catalogo.requiere_receta && (
                    <Badge variant="warning" size="sm">
                      Receta
                    </Badge>
                  )}
                  {!catalogo.controlado && !catalogo.requiere_receta && (
                    <span className="text-gray-400 text-sm">Libre venta</span>
                  )}
                </div>
              </TableCell>

              <TableCell>
                {catalogo.is_active ? (
                  <Badge variant="success">Activo</Badge>
                ) : (
                  <Badge variant="default">Inactivo</Badge>
                )}
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
    </div>
  )
}
