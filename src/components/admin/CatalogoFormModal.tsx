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
    nombre: '',
    formula_activa: '',
    descripcion: '',
    categoria: '',
    is_active: true
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (catalogo) {
      setFormData({
        nombre: catalogo.nombre,
        formula_activa: catalogo.formula_activa,
        descripcion: catalogo.descripcion || '',
        categoria: catalogo.categoria || '',
        is_active: catalogo.is_active
      })
    } else {
      setFormData({
        nombre: '',
        formula_activa: '',
        descripcion: '',
        categoria: '',
        is_active: true
      })
    }
    setErrors({})
  }, [catalogo, isOpen])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.nombre.trim()) {
      newErrors.nombre = 'El nombre es requerido'
    }
    if (!formData.formula_activa.trim()) {
      newErrors.formula_activa = 'La fórmula activa es requerida'
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
      size="lg"
    >
      <form onSubmit={handleSubmit}>
        <div className="space-y-4">
          <Input
            label="Nombre del Medicamento"
            value={formData.nombre}
            onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
            error={errors.nombre}
            required
            placeholder="ej: Paracetamol 500mg"
          />

          <Input
            label="Fórmula Activa"
            value={formData.formula_activa}
            onChange={(e) => setFormData({ ...formData, formula_activa: e.target.value })}
            error={errors.formula_activa}
            required
            placeholder="ej: Paracetamol"
          />

          <Input
            label="Categoría"
            value={formData.categoria}
            onChange={(e) => setFormData({ ...formData, categoria: e.target.value })}
            placeholder="ej: Analgésico, Antibiótico, etc."
          />

          <Textarea
            label="Descripción"
            value={formData.descripcion}
            onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
            placeholder="Descripción opcional del medicamento..."
            rows={3}
          />

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

        <ModalFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button type="submit">
            {catalogo ? 'Actualizar' : 'Crear'} en Catálogo
          </Button>
        </ModalFooter>
      </form>
    </Modal>
  )
}
