import { useEffect, useState } from 'react'
import { Modal, ModalFooter } from '../ui/Modal'
import { Input } from '../ui/Input'
import { Textarea } from '../ui/Textarea'
import { Select } from '../ui/Select'
import { Button } from '../ui/Button'
import type { MedicationCatalog } from '../../types'

interface CatalogoFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: Partial<MedicationCatalog>) => void
  catalogo?: MedicationCatalog | null
}

export function CatalogoFormModal({
  isOpen,
  onClose,
  onSubmit,
  catalogo
}: CatalogoFormModalProps) {
  const [formData, setFormData] = useState({
    codigo_medicamento: '',
    nombre_generico: '',
    nombre_comercial: '',
    principio_activo: '',
    forma_farmaceutica: '',
    via_administracion: '',
    concentracion: '',
    unidad_medida: '',
    categoria: '',
    requiere_receta: false,
    controlado: false,
    temperatura_almacenamiento: '',
    observaciones: '',
    is_active: true
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (catalogo) {
      setFormData({
        codigo_medicamento: catalogo.codigo_medicamento,
        nombre_generico: catalogo.nombre_generico,
        nombre_comercial: catalogo.nombre_comercial || '',
        principio_activo: catalogo.principio_activo || '',
        forma_farmaceutica: catalogo.forma_farmaceutica || '',
        via_administracion: catalogo.via_administracion || '',
        concentracion: catalogo.concentracion || '',
        unidad_medida: catalogo.unidad_medida || '',
        categoria: catalogo.categoria || '',
        requiere_receta: catalogo.requiere_receta,
        controlado: catalogo.controlado,
        temperatura_almacenamiento: catalogo.temperatura_almacenamiento || '',
        observaciones: catalogo.observaciones || '',
        is_active: catalogo.is_active
      })
    } else {
      setFormData({
        codigo_medicamento: '',
        nombre_generico: '',
        nombre_comercial: '',
        principio_activo: '',
        forma_farmaceutica: '',
        via_administracion: '',
        concentracion: '',
        unidad_medida: '',
        categoria: '',
        requiere_receta: false,
        controlado: false,
        temperatura_almacenamiento: '',
        observaciones: '',
        is_active: true
      })
    }
    setErrors({})
  }, [catalogo, isOpen])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.codigo_medicamento.trim()) {
      newErrors.codigo_medicamento = 'El código es requerido'
    }
    if (!formData.nombre_generico.trim()) {
      newErrors.nombre_generico = 'El nombre genérico es requerido'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    if (!validate()) return

    onSubmit(formData)
  }

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={catalogo ? 'Editar Medicamento en Catálogo' : 'Agregar Medicamento al Catálogo'}
      size="xl"
    >
      <form onSubmit={handleSubmit}>
        <div className="space-y-4">
          {/* Identificación */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Código de Medicamento"
              value={formData.codigo_medicamento}
              onChange={(e) => setFormData({ ...formData, codigo_medicamento: e.target.value })}
              error={errors.codigo_medicamento}
              required
              placeholder="MED-PAR-500"
            />

            <Input
              label="Categoría"
              value={formData.categoria}
              onChange={(e) => setFormData({ ...formData, categoria: e.target.value })}
              placeholder="Analgésico, Antibiótico, etc."
            />
          </div>

          {/* Nombres */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Nombre Genérico"
              value={formData.nombre_generico}
              onChange={(e) => setFormData({ ...formData, nombre_generico: e.target.value })}
              error={errors.nombre_generico}
              required
              placeholder="Paracetamol"
            />

            <Input
              label="Nombre Comercial"
              value={formData.nombre_comercial}
              onChange={(e) => setFormData({ ...formData, nombre_comercial: e.target.value })}
              placeholder="Tempra, Tylenol, etc."
            />
          </div>

          {/* Composición */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Principio Activo"
              value={formData.principio_activo}
              onChange={(e) => setFormData({ ...formData, principio_activo: e.target.value })}
              placeholder="Acetaminofén"
            />

            <Input
              label="Concentración"
              value={formData.concentracion}
              onChange={(e) => setFormData({ ...formData, concentracion: e.target.value })}
              placeholder="500mg, 100 UI/mL, etc."
            />
          </div>

          {/* Presentación */}
          <div className="grid grid-cols-3 gap-4">
            <Select
              label="Forma Farmacéutica"
              value={formData.forma_farmaceutica}
              onChange={(e) => setFormData({ ...formData, forma_farmaceutica: e.target.value })}
            >
              <option value="">Seleccionar...</option>
              <option value="Tableta">Tableta</option>
              <option value="Cápsula">Cápsula</option>
              <option value="Jarabe">Jarabe</option>
              <option value="Suspensión">Suspensión</option>
              <option value="Solución inyectable">Solución inyectable</option>
              <option value="Crema">Crema</option>
              <option value="Pomada">Pomada</option>
              <option value="Gotas">Gotas</option>
              <option value="Supositorio">Supositorio</option>
              <option value="Parche">Parche</option>
            </Select>

            <Select
              label="Vía de Administración"
              value={formData.via_administracion}
              onChange={(e) => setFormData({ ...formData, via_administracion: e.target.value })}
            >
              <option value="">Seleccionar...</option>
              <option value="Oral">Oral</option>
              <option value="Intravenosa">Intravenosa</option>
              <option value="Intramuscular">Intramuscular</option>
              <option value="Subcutánea">Subcutánea</option>
              <option value="Tópica">Tópica</option>
              <option value="Oftálmica">Oftálmica</option>
              <option value="Ótica">Ótica</option>
              <option value="Rectal">Rectal</option>
              <option value="Inhalatoria">Inhalatoria</option>
            </Select>

            <Input
              label="Unidad de Medida"
              value={formData.unidad_medida}
              onChange={(e) => setFormData({ ...formData, unidad_medida: e.target.value })}
              placeholder="tableta, frasco, ampolleta"
            />
          </div>

          {/* Almacenamiento */}
          <Input
            label="Temperatura de Almacenamiento"
            value={formData.temperatura_almacenamiento}
            onChange={(e) => setFormData({ ...formData, temperatura_almacenamiento: e.target.value })}
            placeholder="15-25°C, 2-8°C (Refrigeración), etc."
          />

          {/* Controles */}
          <div className="grid grid-cols-3 gap-4">
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="requiere_receta"
                checked={formData.requiere_receta}
                onChange={(e) => setFormData({ ...formData, requiere_receta: e.target.checked })}
                className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
              />
              <label htmlFor="requiere_receta" className="text-sm font-medium text-gray-700">
                Requiere Receta
              </label>
            </div>

            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="controlado"
                checked={formData.controlado}
                onChange={(e) => setFormData({ ...formData, controlado: e.target.checked })}
                className="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
              />
              <label htmlFor="controlado" className="text-sm font-medium text-gray-700">
                Medicamento Controlado
              </label>
            </div>

            <Select
              label="Estado"
              value={formData.is_active ? 'active' : 'inactive'}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.value === 'active' })}
              required
            >
              <option value="active">Activo</option>
              <option value="inactive">Inactivo</option>
            </Select>
          </div>

          {/* Observaciones */}
          <Textarea
            label="Observaciones"
            value={formData.observaciones}
            onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
            placeholder="Información adicional, advertencias, contraindicaciones, etc."
            rows={3}
          />
        </div>

        <ModalFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button type="submit">
            {catalogo ? 'Actualizar' : 'Agregar'} Medicamento
          </Button>
        </ModalFooter>
      </form>
    </Modal>
  )
}
