/**
 * Formulario para Catálogo de Colores
 * Sistema: SIGIMED v2.0
 */

import React, { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { CatalogoColor } from '../../types'

interface FormularioColorProps {
  color?: CatalogoColor | null
  onSubmit: (data: Partial<CatalogoColor>) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function FormularioColor({ color, onSubmit, onCancel, loading }: FormularioColorProps) {
  const [formData, setFormData] = useState<Partial<CatalogoColor>>({
    nombre: '',
    codigo_hex: '#000000',
    codigo_rgb: '',
    codigo_hsl: '',
    uso: '',
    categoria: 'general',
    orden: 0,
    es_activo: true
  })

  useEffect(() => {
    if (color) {
      setFormData(color)
    }
  }, [color])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await onSubmit(formData)
  }

  // Convertir HEX a RGB
  const hexToRgb = (hex: string) => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    return result
      ? `rgb(${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)})`
      : ''
  }

  const handleHexChange = (hex: string) => {
    setFormData(prev => ({
      ...prev,
      codigo_hex: hex,
      codigo_rgb: hexToRgb(hex)
    }))
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            {color ? 'Editar Color' : 'Nuevo Color'}
          </h3>
          <button
            onClick={onCancel}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Nombre */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Nombre <span className="text-red-500">*</span>
            </label>
            <Input
              required
              value={formData.nombre}
              onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
              placeholder="Ej: Primario, Éxito, Peligro"
            />
          </div>

          {/* Código Hexadecimal con preview */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Código Hexadecimal <span className="text-red-500">*</span>
            </label>
            <div className="flex gap-3">
              <div className="flex-1">
                <Input
                  type="color"
                  required
                  value={formData.codigo_hex}
                  onChange={(e) => handleHexChange(e.target.value)}
                  className="h-10"
                />
              </div>
              <Input
                required
                value={formData.codigo_hex}
                onChange={(e) => handleHexChange(e.target.value)}
                placeholder="#000000"
                pattern="^#[0-9A-Fa-f]{6}$"
                className="flex-1"
              />
              <div
                className="w-16 h-10 rounded border-2 border-gray-300"
                style={{ backgroundColor: formData.codigo_hex }}
              />
            </div>
          </div>

          {/* Código RGB (auto-generado) */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Código RGB (Auto-generado)
            </label>
            <Input
              value={formData.codigo_rgb}
              readOnly
              className="bg-gray-50"
              placeholder="Se genera automáticamente"
            />
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
              <option value="principal">Principal</option>
              <option value="estados">Estados</option>
              <option value="graficos">Gráficos</option>
              <option value="alertas">Alertas</option>
              <option value="general">General</option>
            </Select>
          </div>

          {/* Uso */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Uso / Descripción
            </label>
            <textarea
              value={formData.uso}
              onChange={(e) => setFormData({ ...formData, uso: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows={3}
              placeholder="Describe dónde se usa este color..."
            />
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

          {/* Activo */}
          <div className="flex items-center">
            <input
              type="checkbox"
              id="es_activo"
              checked={formData.es_activo}
              onChange={(e) => setFormData({ ...formData, es_activo: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label htmlFor="es_activo" className="ml-2 block text-sm text-gray-900">
              Color activo
            </label>
          </div>

          {/* Botones */}
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button type="button" variant="outline" onClick={onCancel} disabled={loading}>
              Cancelar
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Guardando...' : color ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
