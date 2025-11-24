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
    clave_cuadro: '',
    codigo_atc: '',
    nombre_generico: '',
    nombre_comercial: '',
    laboratorio: '',
    forma_farmaceutica: '',
    dosis: '',
    unidad_medida: '',
    categoria_farmacologica: '',
    requiere_receta: false,
    es_controlado: false,
    temperatura_almacenamiento: '',
    uso_terapeutico: '',
    contraindicaciones: '',
    is_active: true
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (catalogo) {
      setFormData({
        clave_cuadro: catalogo.clave_cuadro || '',
        codigo_atc: catalogo.codigo_atc || '',
        nombre_generico: catalogo.nombre_generico,
        nombre_comercial: catalogo.nombre_comercial || '',
        laboratorio: catalogo.laboratorio || '',
        forma_farmaceutica: catalogo.forma_farmaceutica || '',
        dosis: catalogo.dosis || '',
        unidad_medida: catalogo.unidad_medida || '',
        categoria_farmacologica: catalogo.categoria_farmacologica || '',
        requiere_receta: catalogo.requiere_receta,
        es_controlado: catalogo.es_controlado,
        temperatura_almacenamiento: catalogo.temperatura_almacenamiento || '',
        uso_terapeutico: catalogo.uso_terapeutico || '',
        contraindicaciones: catalogo.contraindicaciones || '',
        is_active: catalogo.is_active
      })
    } else {
      setFormData({
        clave_cuadro: '',
        codigo_atc: '',
        nombre_generico: '',
        nombre_comercial: '',
        laboratorio: '',
        forma_farmaceutica: '',
        dosis: '',
        unidad_medida: '',
        categoria_farmacologica: '',
        requiere_receta: false,
        es_controlado: false,
        temperatura_almacenamiento: '',
        uso_terapeutico: '',
        contraindicaciones: '',
        is_active: true
      })
    }
    setErrors({})
  }, [catalogo, isOpen])

  const validate = () => {
    const newErrors: Record<string, string> = {}

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
              label="Clave Cuadro Básico"
              value={formData.clave_cuadro}
              onChange={(e) => setFormData({ ...formData, clave_cuadro: e.target.value })}
              placeholder="010.000.0001.00"
            />

            <Input
              label="Código ATC"
              value={formData.codigo_atc}
              onChange={(e) => setFormData({ ...formData, codigo_atc: e.target.value })}
              placeholder="N02BE01"
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

          {/* Laboratorio y Categoría */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Laboratorio"
              value={formData.laboratorio}
              onChange={(e) => setFormData({ ...formData, laboratorio: e.target.value })}
              placeholder="Bayer, Pfizer, etc."
            />

            <Input
              label="Categoría Farmacológica"
              value={formData.categoria_farmacologica}
              onChange={(e) => setFormData({ ...formData, categoria_farmacologica: e.target.value })}
              placeholder="Analgésico, Antibiótico, etc."
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
              <option value="Aerosol">Aerosol</option>
            </Select>

            <Input
              label="Dosis"
              value={formData.dosis}
              onChange={(e) => setFormData({ ...formData, dosis: e.target.value })}
              placeholder="500mg, 100 UI/mL, etc."
            />

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
                id="es_controlado"
                checked={formData.es_controlado}
                onChange={(e) => setFormData({ ...formData, es_controlado: e.target.checked })}
                className="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
              />
              <label htmlFor="es_controlado" className="text-sm font-medium text-gray-700">
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

          {/* Uso Terapéutico */}
          <Textarea
            label="Uso Terapéutico"
            value={formData.uso_terapeutico}
            onChange={(e) => setFormData({ ...formData, uso_terapeutico: e.target.value })}
            placeholder="Indicaciones de uso..."
            rows={2}
          />

          {/* Contraindicaciones */}
          <Textarea
            label="Contraindicaciones"
            value={formData.contraindicaciones}
            onChange={(e) => setFormData({ ...formData, contraindicaciones: e.target.value })}
            placeholder="Contraindicaciones y advertencias..."
            rows={2}
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
