import { useState } from 'react'
import { Plus, Search, Filter, Download, FileText, FileSpreadsheet, Upload } from 'lucide-react'
import { useCentro } from '../context/CentroContext'
import { useMedicamentos } from '../hooks/useMedicamentos'
import { Button } from '../components/ui/Button'
import { MedicamentoTable } from '../components/inventory/MedicamentoTable'
import { MedicamentoFormModal } from '../components/inventory/MedicamentoFormModal'
import { ImportMedications } from '../components/inventory/ImportMedications'
import { useToast } from '../components/ui/Toast'
import { exportMedicationsPDF, exportMedicationsExcel } from '../utils/exportUtils'
import type { Medication } from '../types'

export function InventoryPage() {
  const { centroSeleccionado } = useCentro()
  const { medicamentos, loading, createMedicamento, updateMedicamento, deleteMedicamento } = useMedicamentos(centroSeleccionado?.id)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [showImportModal, setShowImportModal] = useState(false)
  const [editingMedicamento, setEditingMedicamento] = useState<Medication | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterEstado, setFilterEstado] = useState<string>('all')
  const [showExportMenu, setShowExportMenu] = useState(false)
  const toast = useToast()

  // Filtrar medicamentos
  const filteredMedicamentos = medicamentos.filter((med) => {
    const matchesSearch = med.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         med.formula_activa.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         med.lote.toLowerCase().includes(searchTerm.toLowerCase())

    const matchesFilter = filterEstado === 'all' || med.estado === filterEstado

    return matchesSearch && matchesFilter
  })

  const handleCreate = () => {
    setEditingMedicamento(null)
    setIsModalOpen(true)
  }

  const handleEdit = (medicamento: Medication) => {
    setEditingMedicamento(medicamento)
    setIsModalOpen(true)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('¿Estás seguro de eliminar este medicamento?')) return

    const { error } = await deleteMedicamento(id)
    if (error) {
      toast.error('Error al eliminar medicamento')
    } else {
      toast.success('Medicamento eliminado correctamente')
    }
  }

  const handleSubmit = async (data: any) => {
    if (editingMedicamento) {
      const { error } = await updateMedicamento(editingMedicamento.id, data)
      if (error) {
        toast.error('Error al actualizar medicamento')
      } else {
        toast.success('Medicamento actualizado correctamente')
        setIsModalOpen(false)
      }
    } else {
      const { error } = await createMedicamento({
        ...data,
        center_id: centroSeleccionado?.id
      })
      if (error) {
        toast.error('Error al crear medicamento')
      } else {
        toast.success('Medicamento creado correctamente')
        setIsModalOpen(false)
      }
    }
  }

  const handleExportPDF = () => {
    exportMedicationsPDF(filteredMedicamentos, centroSeleccionado?.name)
    toast.success('Reporte PDF generado exitosamente')
    setShowExportMenu(false)
  }

  const handleExportExcel = () => {
    exportMedicationsExcel(filteredMedicamentos, centroSeleccionado?.name)
    toast.success('Reporte Excel generado exitosamente')
    setShowExportMenu(false)
  }

  if (!centroSeleccionado) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Selecciona un centro de salud para ver el inventario</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Inventario de Medicamentos</h1>
          <p className="text-gray-600 mt-1">{centroSeleccionado.name}</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => setShowImportModal(true)}
            icon={<Upload className="h-5 w-5" />}
            variant="outline"
          >
            Importar
          </Button>
          <Button onClick={handleCreate} icon={<Plus className="h-5 w-5" />}>
            Agregar Medicamento
          </Button>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-lg shadow-md space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por nombre, fórmula o lote..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          <div>
            <select
              value={filterEstado}
              onChange={(e) => setFilterEstado(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todos los estados</option>
              <option value="Disponible">Disponible</option>
              <option value="No Disponible">No Disponible</option>
              <option value="Cuarentena">Cuarentena</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <Button variant="outline" size="sm" icon={<Filter className="h-4 w-4" />}>
            Más Filtros
          </Button>
          <div className="relative">
            <Button
              variant="outline"
              size="sm"
              icon={<Download className="h-4 w-4" />}
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
          <div className="ml-auto text-sm text-gray-600">
            {filteredMedicamentos.length} de {medicamentos.length} medicamentos
          </div>
        </div>
      </div>

      {/* Table */}
      <MedicamentoTable
        medicamentos={filteredMedicamentos}
        loading={loading}
        onEdit={handleEdit}
        onDelete={handleDelete}
      />

      {/* Modal de Formulario */}
      <MedicamentoFormModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmit}
        medicamento={editingMedicamento}
      />

      {/* Modal de Importación */}
      {showImportModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
              <h2 className="text-xl font-bold">Importación Masiva de Medicamentos</h2>
              <button
                onClick={() => setShowImportModal(false)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <span className="text-2xl">&times;</span>
              </button>
            </div>
            <div className="p-6">
              <ImportMedications />
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
