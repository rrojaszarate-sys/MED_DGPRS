/**
 * Formulario para Catálogo de Estados
 * Sistema: SIGIMED v2.0
 */

import React, { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { CatalogoEstado } from '../../types'
import { useCatalogoColores } from '../../hooks/useCatalogos'

interface FormularioEstadoProps {
  estado?: CatalogoEstado | null
  onSubmit: (data: Partial<CatalogoEstado>) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function FormularioEstado({ estado, onSubmit, onCancel, loading }: FormularioEstadoProps) {
  const { items: colores } = useCatalogoColores()

  const [formData, setFormData] = useState<Partial<CatalogoEstado>>({
    codigo: '',
    nombre: '',
    descripcion: '',
    modulo: 'general',
    color_id: undefined,
    icono: '',
    orden: 0,
    es_estado_inicial: false,
    es_estado_final: false,
    permite_edicion: true,
    es_activo: true
  })

  useEffect(() => {
    if (estado) {
      setFormData(estado)
    }
  }, [estado])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await onSubmit(formData)
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            {estado ? 'Editar Estado' : 'Nuevo Estado'}
          </h3>
          <button onClick={onCancel} className="text-gray-400 hover:text-gray-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
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
                placeholder="disponible, pendiente, aprobado"
              />
            </div>

            {/* Módulo */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Módulo <span className="text-red-500">*</span>
              </label>
              <Select
                required
                value={formData.modulo}
                onChange={(e) => setFormData({ ...formData, modulo: e.target.value as any })}
              >
                <option value="medicamentos">Medicamentos</option>
                <option value="requisiciones">Requisiciones</option>
                <option value="transferencias">Transferencias</option>
                <option value="contratos">Contratos</option>
                <option value="general">General</option>
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
              placeholder="Disponible, Pendiente de Aprobación"
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
              placeholder="Descripción del estado..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* Color */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Color
              </label>
              <Select
                value={formData.color_id || ''}
                onChange={(e) => setFormData({ ...formData, color_id: e.target.value || undefined })}
              >
                <option value="">Sin color</option>
                {colores.map(color => (
                  <option key={color.id} value={color.id}>
                    {color.nombre}
                  </option>
                ))}
              </Select>
            </div>

            {/* Icono */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Icono (lucide-react)
              </label>
              <Input
                value={formData.icono}
                onChange={(e) => setFormData({ ...formData, icono: e.target.value })}
                placeholder="CheckCircle, Clock, XCircle"
              />
            </div>
          </div>

          {/* Opciones */}
          <div className="space-y-2 p-4 bg-gray-50 rounded-lg">
            <div className="flex items-center">
              <input
                type="checkbox"
                id="es_estado_inicial"
                checked={formData.es_estado_inicial}
                onChange={(e) => setFormData({ ...formData, es_estado_inicial: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="es_estado_inicial" className="ml-2 block text-sm text-gray-900">
                Es estado inicial
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="es_estado_final"
                checked={formData.es_estado_final}
                onChange={(e) => setFormData({ ...formData, es_estado_final: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="es_estado_final" className="ml-2 block text-sm text-gray-900">
                Es estado final / terminal
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="permite_edicion"
                checked={formData.permite_edicion}
                onChange={(e) => setFormData({ ...formData, permite_edicion: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="permite_edicion" className="ml-2 block text-sm text-gray-900">
                Permite edición en este estado
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
                Estado activo
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
              {loading ? 'Guardando...' : estado ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
