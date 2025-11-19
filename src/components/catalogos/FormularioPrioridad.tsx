/**
 * Formulario para Catálogo de Prioridades
 * Sistema: SIGIMED v2.0
 */

import React, { useState, useEffect } from 'react'
import { X, AlertCircle } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { CatalogoPrioridad } from '../../types'
import { useCatalogoColores } from '../../hooks/useCatalogos'

interface FormularioPrioridadProps {
  prioridad?: CatalogoPrioridad | null
  onSubmit: (data: Partial<CatalogoPrioridad>) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function FormularioPrioridad({
  prioridad,
  onSubmit,
  onCancel,
  loading
}: FormularioPrioridadProps) {
  const { items: colores } = useCatalogoColores()

  const [formData, setFormData] = useState<Partial<CatalogoPrioridad>>({
    codigo: '',
    nombre: '',
    descripcion: '',
    nivel: 3,
    modulo: 'general',
    color_id: undefined,
    icono: '',
    dias_respuesta_esperado: undefined,
    requiere_notificacion: false,
    orden: 0,
    es_activo: true
  })

  useEffect(() => {
    if (prioridad) {
      setFormData(prioridad)
    }
  }, [prioridad])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await onSubmit(formData)
  }

  // Helper para mostrar advertencia en prioridades altas
  const esAltaPrioridad = formData.nivel && formData.nivel <= 2

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            {prioridad ? 'Editar Prioridad' : 'Nueva Prioridad'}
          </h3>
          <button onClick={onCancel} className="text-gray-400 hover:text-gray-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Advertencia de alta prioridad */}
          {esAltaPrioridad && (
            <div className="p-3 bg-orange-50 border border-orange-200 rounded-lg flex items-start gap-2">
              <AlertCircle className="h-5 w-5 text-orange-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-orange-800">
                <p className="font-medium">Prioridad alta</p>
                <p>Esta prioridad generará alertas y notificaciones para garantizar atención inmediata.</p>
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
                placeholder="urgente, normal, baja"
                disabled={!!prioridad}
              />
              {prioridad && (
                <p className="mt-1 text-xs text-gray-500">
                  El código no se puede modificar una vez creado
                </p>
              )}
            </div>

            {/* Nivel */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nivel (1=más alta) <span className="text-red-500">*</span>
              </label>
              <Input
                type="number"
                required
                min="1"
                max="10"
                value={formData.nivel}
                onChange={(e) => setFormData({ ...formData, nivel: parseInt(e.target.value) })}
                placeholder="1, 2, 3..."
              />
              <p className="mt-1 text-xs text-gray-500">
                1 = Máxima prioridad, 10 = Mínima prioridad
              </p>
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
              placeholder="Urgente, Normal, Baja"
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
              placeholder="Descripción de la prioridad..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
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
                <option value="requisiciones">Requisiciones</option>
                <option value="transferencias">Transferencias</option>
                <option value="alertas">Alertas</option>
                <option value="notificaciones">Notificaciones</option>
                <option value="general">General</option>
              </Select>
            </div>

            {/* Días de respuesta esperado */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Días de respuesta esperado
              </label>
              <Input
                type="number"
                min="0"
                value={formData.dias_respuesta_esperado || ''}
                onChange={(e) => setFormData({
                  ...formData,
                  dias_respuesta_esperado: e.target.value ? parseInt(e.target.value) : undefined
                })}
                placeholder="1, 3, 7, 15..."
              />
            </div>
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
                placeholder="AlertTriangle, Clock, Info"
              />
            </div>
          </div>

          {/* Opciones */}
          <div className="space-y-2 p-4 bg-gray-50 rounded-lg">
            <div className="flex items-center">
              <input
                type="checkbox"
                id="requiere_notificacion"
                checked={formData.requiere_notificacion}
                onChange={(e) => setFormData({ ...formData, requiere_notificacion: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="requiere_notificacion" className="ml-2 block text-sm text-gray-900">
                Requiere notificación automática
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
                Prioridad activa
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
              {loading ? 'Guardando...' : prioridad ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
