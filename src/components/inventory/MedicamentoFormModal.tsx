import { useEffect, useState } from 'react'
import { Modal, ModalFooter } from '../ui/Modal'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { Button } from '../ui/Button'
import type { Medication } from '../../types'

interface MedicamentoFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: Partial<Medication>) => void
  medicamento?: Medication | null
}

export function MedicamentoFormModal({
  isOpen,
  onClose,
  onSubmit,
  medicamento
}: MedicamentoFormModalProps) {
  const [formData, setFormData] = useState({
    nombre: '',
    formula_activa: '',
    lote: '',
    cantidad: 0,
    fecha_caducidad: '',
    fecha_ingreso: new Date().toISOString().split('T')[0],
    estado: 'Disponible' as Medication['estado']
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (medicamento) {
      setFormData({
        nombre: medicamento.nombre,
        formula_activa: medicamento.formula_activa,
        lote: medicamento.lote,
        cantidad: medicamento.cantidad,
        fecha_caducidad: medicamento.fecha_caducidad,
        fecha_ingreso: medicamento.fecha_ingreso,
        estado: medicamento.estado
      })
    } else {
      setFormData({
        nombre: '',
        formula_activa: '',
        lote: '',
        cantidad: 0,
        fecha_caducidad: '',
        fecha_ingreso: new Date().toISOString().split('T')[0],
        estado: 'Disponible'
      })
    }
    setErrors({})
  }, [medicamento, isOpen])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.nombre.trim()) {
      newErrors.nombre = 'El nombre es requerido'
    }
    if (!formData.formula_activa.trim()) {
      newErrors.formula_activa = 'La fórmula activa es requerida'
    }
    if (!formData.lote.trim()) {
      newErrors.lote = 'El lote es requerido'
    }
    if (formData.cantidad < 0) {
      newErrors.cantidad = 'La cantidad debe ser mayor o igual a 0'
    }
    if (!formData.fecha_caducidad) {
      newErrors.fecha_caducidad = 'La fecha de caducidad es requerida'
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
      title={medicamento ? 'Editar Medicamento' : 'Agregar Medicamento'}
      size="lg"
    >
      <form onSubmit={handleSubmit}>
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Input
              label="Lote"
              value={formData.lote}
              onChange={(e) => setFormData({ ...formData, lote: e.target.value })}
              error={errors.lote}
              required
              placeholder="ej: LOTE-2025-001"
            />

            <Input
              label="Cantidad"
              type="number"
              value={formData.cantidad}
              onChange={(e) => setFormData({ ...formData, cantidad: parseInt(e.target.value) || 0 })}
              error={errors.cantidad}
              required
              min="0"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Input
              label="Fecha de Ingreso"
              type="date"
              value={formData.fecha_ingreso}
              onChange={(e) => setFormData({ ...formData, fecha_ingreso: e.target.value })}
              required
            />

            <Input
              label="Fecha de Caducidad"
              type="date"
              value={formData.fecha_caducidad}
              onChange={(e) => setFormData({ ...formData, fecha_caducidad: e.target.value })}
              error={errors.fecha_caducidad}
              required
              min={new Date().toISOString().split('T')[0]}
            />
          </div>

          <Select
            label="Estado"
            value={formData.estado}
            onChange={(e) => setFormData({ ...formData, estado: e.target.value as Medication['estado'] })}
            required
          >
            <option value="Disponible">Disponible</option>
            <option value="No Disponible">No Disponible</option>
            <option value="Cuarentena">Cuarentena</option>
          </Select>
        </div>

        <ModalFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button type="submit">
            {medicamento ? 'Actualizar' : 'Crear'} Medicamento
          </Button>
        </ModalFooter>
      </form>
    </Modal>
  )
}
