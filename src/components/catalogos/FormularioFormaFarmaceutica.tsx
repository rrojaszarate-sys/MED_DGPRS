/**
 * Formulario para Catálogo de Formas Farmacéuticas
 * Sistema: SIGIMED v2.0
 */

import React, { useState, useEffect } from 'react'
import { X, Info } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { CatalogoFormaFarmaceutica } from '../../types'

interface FormularioFormaFarmaceuticaProps {
  formaFarmaceutica?: CatalogoFormaFarmaceutica | null
  onSubmit: (data: Partial<CatalogoFormaFarmaceutica>) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function FormularioFormaFarmaceutica({
  formaFarmaceutica,
  onSubmit,
  onCancel,
  loading
}: FormularioFormaFarmaceuticaProps) {
  const [formData, setFormData] = useState<Partial<CatalogoFormaFarmaceutica>>({
    codigo: '',
    nombre: '',
    descripcion: '',
    categoria: 'solida',
    requiere_refrigeracion: false,
    requiere_cadena_frio: false,
    via_administracion: '',
    unidad_medida_default: '',
    orden: 0,
    es_activo: true
  })

  useEffect(() => {
    if (formaFarmaceutica) {
      setFormData(formaFarmaceutica)
    }
  }, [formaFarmaceutica])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await onSubmit(formData)
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            {formaFarmaceutica ? 'Editar Forma Farmacéutica' : 'Nueva Forma Farmacéutica'}
          </h3>
          <button onClick={onCancel} className="text-gray-400 hover:text-gray-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Advertencia cadena de frío */}
          {(formData.requiere_refrigeracion || formData.requiere_cadena_frio) && (
            <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg flex items-start gap-2">
              <Info className="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-blue-800">
                <p className="font-medium">Almacenamiento especial requerido</p>
                <p>Esta forma farmacéutica requiere condiciones especiales de almacenamiento y transporte.</p>
              </div>
            </div>
          )}

          <div className="grid grid-cols-2 gap-4">
            {/* Código */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Código <span className="text-red-500">*</span>
              </label>
              <Input
                required
                value={formData.codigo}
                onChange={(e) => setFormData({ ...formData, codigo: e.target.value })}
                placeholder="tableta, capsula, solucion"
                disabled={!!formaFarmaceutica}
              />
              {formaFarmaceutica && (
                <p className="mt-1 text-xs text-gray-500">
                  El código no se puede modificar una vez creado
                </p>
              )}
            </div>

            {/* Categoría */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Categoría <span className="text-red-500">*</span>
              </label>
              <Select
                required
                value={formData.categoria}
                onChange={(e) => setFormData({ ...formData, categoria: e.target.value as any })}
              >
                <option value="solida">Sólida</option>
                <option value="liquida">Líquida</option>
                <option value="semisólida">Semisólida</option>
                <option value="gaseosa">Gaseosa</option>
                <option value="parental">Parental</option>
              </Select>
            </div>
          </div>

          {/* Nombre */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Nombre <span className="text-red-500">*</span>
            </label>
            <Input
              required
              value={formData.nombre}
              onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
              placeholder="Tableta, Cápsula, Solución Inyectable"
            />
          </div>

          {/* Descripción */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Descripción
            </label>
            <textarea
              value={formData.descripcion}
              onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows={2}
              placeholder="Descripción de la forma farmacéutica..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* Vía de administración */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Vía de administración
              </label>
              <Input
                value={formData.via_administracion}
                onChange={(e) => setFormData({ ...formData, via_administracion: e.target.value })}
                placeholder="oral, parenteral, tópica"
              />
            </div>

            {/* Unidad de medida default */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Unidad de medida por defecto
              </label>
              <Input
                value={formData.unidad_medida_default}
                onChange={(e) => setFormData({ ...formData, unidad_medida_default: e.target.value })}
                placeholder="mg, mL, g, unidades"
              />
            </div>
          </div>

          {/* Opciones de almacenamiento */}
          <div className="space-y-2 p-4 bg-gray-50 rounded-lg">
            <h4 className="text-sm font-medium text-gray-900 mb-3">
              Requisitos de Almacenamiento
            </h4>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="requiere_refrigeracion"
                checked={formData.requiere_refrigeracion}
                onChange={(e) => setFormData({ ...formData, requiere_refrigeracion: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="requiere_refrigeracion" className="ml-2 block text-sm text-gray-900">
                Requiere refrigeración (2-8°C)
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="requiere_cadena_frio"
                checked={formData.requiere_cadena_frio}
                onChange={(e) => setFormData({ ...formData, requiere_cadena_frio: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="requiere_cadena_frio" className="ml-2 block text-sm text-gray-900">
                Requiere cadena de frío estricta (transporte)
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="es_activo"
                checked={formData.es_activo}
                onChange={(e) => setFormData({ ...formData, es_activo: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="es_activo" className="ml-2 block text-sm text-gray-900">
                Forma farmacéutica activa
              </label>
            </div>
          </div>

          {/* Orden */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Orden de visualización
            </label>
            <Input
              type="number"
              value={formData.orden}
              onChange={(e) => setFormData({ ...formData, orden: parseInt(e.target.value) })}
              min="0"
            />
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button type="button" variant="outline" onClick={onCancel} disabled={loading}>
              Cancelar
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Guardando...' : formaFarmaceutica ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
