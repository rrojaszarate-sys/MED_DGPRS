import { useEffect, useState } from 'react'
import { Modal, ModalFooter } from '../ui/Modal'
import { Input } from '../ui/Input'
import { Textarea } from '../ui/Textarea'
import { Select } from '../ui/Select'
import { Button } from '../ui/Button'
import type { Supplier } from '../../types'

interface SupplierFormModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: Partial<Supplier>) => void
  supplier?: Supplier | null
}

export function SupplierFormModal({
  isOpen,
  onClose,
  onSubmit,
  supplier
}: SupplierFormModalProps) {
  const [formData, setFormData] = useState({
    nombre: '',
    rfc: '',
    razon_social: '',
    direccion: '',
    ciudad: '',
    estado: '',
    telefono: '',
    email: '',
    contacto_nombre: '',
    contacto_telefono: '',
    terminos_pago: '',
    dias_credito: 0,
    calificacion: 0,
    notas: '',
    is_active: true
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (supplier) {
      setFormData({
        nombre: supplier.nombre,
        rfc: supplier.rfc || '',
        razon_social: supplier.razon_social || '',
        direccion: supplier.direccion || '',
        ciudad: supplier.ciudad || '',
        estado: supplier.estado || '',
        telefono: supplier.telefono || '',
        email: supplier.email || '',
        contacto_nombre: supplier.contacto_nombre || '',
        contacto_telefono: supplier.contacto_telefono || '',
        terminos_pago: supplier.terminos_pago || '',
        dias_credito: supplier.dias_credito || 0,
        calificacion: supplier.calificacion || 0,
        notas: supplier.notas || '',
        is_active: supplier.is_active
      })
    } else {
      setFormData({
        nombre: '',
        rfc: '',
        razon_social: '',
        direccion: '',
        ciudad: '',
        estado: '',
        telefono: '',
        email: '',
        contacto_nombre: '',
        contacto_telefono: '',
        terminos_pago: '',
        dias_credito: 0,
        calificacion: 0,
        notas: '',
        is_active: true
      })
    }
    setErrors({})
  }, [supplier, isOpen])

  const validate = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.nombre.trim()) {
      newErrors.nombre = 'El nombre es requerido'
    }

    if (formData.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Email inválido'
    }

    if (formData.calificacion && (formData.calificacion < 0 || formData.calificacion > 5)) {
      newErrors.calificacion = 'La calificación debe estar entre 0 y 5'
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
      title={supplier ? 'Editar Proveedor' : 'Agregar Proveedor'}
      size="xl"
    >
      <form onSubmit={handleSubmit}>
        <div className="space-y-4">
          {/* Información General */}
          <div className="border-b pb-3 mb-3">
            <h3 className="text-sm font-semibold text-gray-700 uppercase">Información General</h3>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Nombre del Proveedor"
              value={formData.nombre}
              onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
              error={errors.nombre}
              required
              placeholder="Farmacéutica Nacional S.A."
            />

            <Input
              label="RFC"
              value={formData.rfc}
              onChange={(e) => setFormData({ ...formData, rfc: e.target.value.toUpperCase() })}
              placeholder="ABC123456XYZ"
              maxLength={13}
            />
          </div>

          <Input
            label="Razón Social"
            value={formData.razon_social}
            onChange={(e) => setFormData({ ...formData, razon_social: e.target.value })}
            placeholder="Farmacéutica Nacional Sociedad Anónima de Capital Variable"
          />

          {/* Dirección */}
          <div className="border-b pb-3 mb-3 mt-6">
            <h3 className="text-sm font-semibold text-gray-700 uppercase">Dirección</h3>
          </div>

          <Input
            label="Dirección"
            value={formData.direccion}
            onChange={(e) => setFormData({ ...formData, direccion: e.target.value })}
            placeholder="Av. Insurgentes Sur 1234, Col. Del Valle"
          />

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Ciudad"
              value={formData.ciudad}
              onChange={(e) => setFormData({ ...formData, ciudad: e.target.value })}
              placeholder="Ciudad de México"
            />

            <Select
              label="Estado"
              value={formData.estado}
              onChange={(e) => setFormData({ ...formData, estado: e.target.value })}
            >
              <option value="">Seleccionar...</option>
              <option value="Aguascalientes">Aguascalientes</option>
              <option value="Baja California">Baja California</option>
              <option value="Baja California Sur">Baja California Sur</option>
              <option value="Campeche">Campeche</option>
              <option value="Chiapas">Chiapas</option>
              <option value="Chihuahua">Chihuahua</option>
              <option value="CDMX">Ciudad de México</option>
              <option value="Coahuila">Coahuila</option>
              <option value="Colima">Colima</option>
              <option value="Durango">Durango</option>
              <option value="Guanajuato">Guanajuato</option>
              <option value="Guerrero">Guerrero</option>
              <option value="Hidalgo">Hidalgo</option>
              <option value="Jalisco">Jalisco</option>
              <option value="México">México</option>
              <option value="Michoacán">Michoacán</option>
              <option value="Morelos">Morelos</option>
              <option value="Nayarit">Nayarit</option>
              <option value="Nuevo León">Nuevo León</option>
              <option value="Oaxaca">Oaxaca</option>
              <option value="Puebla">Puebla</option>
              <option value="Querétaro">Querétaro</option>
              <option value="Quintana Roo">Quintana Roo</option>
              <option value="San Luis Potosí">San Luis Potosí</option>
              <option value="Sinaloa">Sinaloa</option>
              <option value="Sonora">Sonora</option>
              <option value="Tabasco">Tabasco</option>
              <option value="Tamaulipas">Tamaulipas</option>
              <option value="Tlaxcala">Tlaxcala</option>
              <option value="Veracruz">Veracruz</option>
              <option value="Yucatán">Yucatán</option>
              <option value="Zacatecas">Zacatecas</option>
            </Select>
          </div>

          {/* Contacto */}
          <div className="border-b pb-3 mb-3 mt-6">
            <h3 className="text-sm font-semibold text-gray-700 uppercase">Contacto</h3>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Teléfono"
              value={formData.telefono}
              onChange={(e) => setFormData({ ...formData, telefono: e.target.value })}
              placeholder="55-1234-5678"
            />

            <Input
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              error={errors.email}
              placeholder="contacto@proveedor.com"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Nombre de Contacto"
              value={formData.contacto_nombre}
              onChange={(e) => setFormData({ ...formData, contacto_nombre: e.target.value })}
              placeholder="Lic. Juan Pérez"
            />

            <Input
              label="Teléfono de Contacto"
              value={formData.contacto_telefono}
              onChange={(e) => setFormData({ ...formData, contacto_telefono: e.target.value })}
              placeholder="55-9876-5432"
            />
          </div>

          {/* Términos Comerciales */}
          <div className="border-b pb-3 mb-3 mt-6">
            <h3 className="text-sm font-semibold text-gray-700 uppercase">Términos Comerciales</h3>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Términos de Pago"
              value={formData.terminos_pago}
              onChange={(e) => setFormData({ ...formData, terminos_pago: e.target.value })}
              placeholder="Crédito 30 días, Contado, etc."
            />

            <Input
              label="Días de Crédito"
              type="number"
              value={formData.dias_credito}
              onChange={(e) => setFormData({ ...formData, dias_credito: parseInt(e.target.value) || 0 })}
              min="0"
              placeholder="30"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Calificación (0-5)
              </label>
              <div className="flex items-center gap-2">
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    key={star}
                    type="button"
                    onClick={() => setFormData({ ...formData, calificacion: star })}
                    className={`text-2xl ${
                      star <= formData.calificacion ? 'text-yellow-400' : 'text-gray-300'
                    }`}
                  >
                    ★
                  </button>
                ))}
                <span className="text-sm text-gray-600 ml-2">
                  {formData.calificacion > 0 ? formData.calificacion.toFixed(1) : 'Sin calificar'}
                </span>
              </div>
              {errors.calificacion && (
                <p className="text-red-500 text-sm mt-1">{errors.calificacion}</p>
              )}
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

          <Textarea
            label="Notas"
            value={formData.notas}
            onChange={(e) => setFormData({ ...formData, notas: e.target.value })}
            placeholder="Información adicional sobre el proveedor..."
            rows={3}
          />
        </div>

        <ModalFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button type="submit">
            {supplier ? 'Actualizar' : 'Agregar'} Proveedor
          </Button>
        </ModalFooter>
      </form>
    </Modal>
  )
}
