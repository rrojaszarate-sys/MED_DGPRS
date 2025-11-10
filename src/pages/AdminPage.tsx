import { useState } from 'react'
import { Plus, Search, Database, Download, FileText, FileSpreadsheet } from 'lucide-react'
import { useCatalogo } from '../hooks/useCatalogo'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import { Input } from '../components/ui/Input'
import { CatalogoTable } from '../components/admin/CatalogoTable'
import { CatalogoFormModal } from '../components/admin/CatalogoFormModal'
import { useToast } from '../components/ui/Toast'
import { exportCatalogPDF, exportCatalogExcel } from '../utils/exportUtils'
import type { MedicationCatalog } from '../types'

export function AdminPage() {
  const {
    catalogos,
    loading,
    createCatalogo,
    updateCatalogo,
    deleteCatalogo
  } = useCatalogo()
  const toast = useToast()

  const [searchTerm, setSearchTerm] = useState('')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedCatalogo, setSelectedCatalogo] = useState<MedicationCatalog | null>(null)
  const [showExportMenu, setShowExportMenu] = useState(false)

  const filteredCatalogos = catalogos.filter((cat) => {
    const searchLower = searchTerm.toLowerCase()
    return (
      cat.nombre_generico.toLowerCase().includes(searchLower) ||
      (cat.nombre_comercial && cat.nombre_comercial.toLowerCase().includes(searchLower)) ||
      (cat.principio_activo && cat.principio_activo.toLowerCase().includes(searchLower)) ||
      cat.codigo_medicamento.toLowerCase().includes(searchLower) ||
      (cat.categoria && cat.categoria.toLowerCase().includes(searchLower))
    )
  })

  const handleCreate = () => {
    setSelectedCatalogo(null)
    setIsModalOpen(true)
  }

  const handleEdit = (catalogo: MedicationCatalog) => {
    setSelectedCatalogo(catalogo)
    setIsModalOpen(true)
  }

  const handleSubmit = async (data: Partial<MedicationCatalog>) => {
    if (selectedCatalogo) {
      const { error } = await updateCatalogo(selectedCatalogo.id, data)
      if (error) {
        console.error('Error al actualizar medicamento:', error)
        toast.error(`Error al actualizar: ${error}`)
      } else {
        toast.success('Medicamento actualizado exitosamente')
        setIsModalOpen(false)
      }
    } else {
      const { error } = await createCatalogo(data as Omit<MedicationCatalog, 'id' | 'created_at'>)
      if (error) {
        console.error('Error al crear medicamento:', error)
        // Mensajes específicos según el error
        if (error.includes('23505') || error.includes('duplicate key')) {
          toast.error(`Error: Código de medicamento duplicado`)
        } else if (error.includes('RLS') || error.includes('policy')) {
          toast.error(`Error de permisos: Verifica políticas RLS en Supabase`)
        } else if (error.includes('connection') || error.includes('network')) {
          toast.error(`Error de conexión a base de datos`)
        } else {
          toast.error(`Error al crear medicamento: ${error}`)
        }
      } else {
        toast.success('Medicamento agregado al catálogo')
        setIsModalOpen(false)
      }
    }
  }

  const handleDelete = async (id: string) => {
    const { error } = await deleteCatalogo(id)
    if (error) {
      toast.error('Error al eliminar el medicamento')
    } else {
      toast.success('Medicamento eliminado del catálogo')
    }
  }

  const handleExportPDF = () => {
    // TODO: Pass filteredCatalogos when export function is implemented
    exportCatalogPDF()
    toast.success('Catálogo PDF pendiente de implementación')
    setShowExportMenu(false)
  }

  const handleExportExcel = () => {
    // TODO: Pass filteredCatalogos when export function is implemented
    exportCatalogExcel()
    toast.success('Catálogo Excel pendiente de implementación')
    setShowExportMenu(false)
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Panel de Administración</h1>
          <p className="text-gray-600 mt-1">Gestión del catálogo de medicamentos</p>
        </div>
        <div className="flex gap-2">
          <div className="relative">
            <Button
              variant="outline"
              icon={<Download className="h-5 w-5" />}
              onClick={() => setShowExportMenu(!showExportMenu)}
            >
              Exportar
            </Button>
            {showExportMenu && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-10">
                <button
                  onClick={handleExportPDF}
                  className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-t-lg"
                >
                  <FileText className="h-4 w-4" />
                  Exportar como PDF
                </button>
                <button
                  onClick={handleExportExcel}
                  className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-b-lg"
                >
                  <FileSpreadsheet className="h-4 w-4" />
                  Exportar como Excel
                </button>
              </div>
            )}
          </div>
          <Button onClick={handleCreate} icon={<Plus className="h-5 w-5" />}>
            Agregar al Catálogo
          </Button>
        </div>
      </div>

      {/* KPI Card */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-primary-50 border-l-4 border-l-primary">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-primary-600">Total en Catálogo</p>
              <p className="text-3xl font-bold text-primary-900 mt-2">{catalogos.length}</p>
              <p className="text-xs text-primary-700 mt-1">Medicamentos registrados</p>
            </div>
            <div className="h-16 w-16 bg-primary rounded-full flex items-center justify-center">
              <Database className="h-8 w-8 text-white" />
            </div>
          </div>
        </Card>

        <Card className="bg-green-50 border-l-4 border-l-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600">Activos</p>
              <p className="text-3xl font-bold text-green-900 mt-2">
                {catalogos.filter((c) => c.is_active).length}
              </p>
              <p className="text-xs text-green-700 mt-1">Disponibles para uso</p>
            </div>
          </div>
        </Card>

        <Card className="bg-gray-50 border-l-4 border-l-gray-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Inactivos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {catalogos.filter((c) => !c.is_active).length}
              </p>
              <p className="text-xs text-gray-700 mt-1">No disponibles</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Search */}
      <Card>
        <div className="flex items-center gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              placeholder="Buscar por nombre, fórmula activa o categoría..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>
      </Card>

      {/* Catalog Table */}
      <Card>
        <CatalogoTable
          catalogos={filteredCatalogos}
          loading={loading}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      </Card>

      {/* Form Modal */}
      <CatalogoFormModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmit}
        catalogo={selectedCatalogo}
      />
    </div>
  )
}
