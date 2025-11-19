/**
 * Formulario para Catálogo de Tipos de Movimiento
 * Sistema: SIGIMED v2.0
 */

import React, { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { CatalogoTipoMovimiento } from '../../types'
import { useCatalogoColores } from '../../hooks/useCatalogos'

interface FormularioTipoMovimientoProps {
  tipoMovimiento?: CatalogoTipoMovimiento | null
  onSubmit: (data: Partial<CatalogoTipoMovimiento>) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function FormularioTipoMovimiento({
  tipoMovimiento,
  onSubmit,
  onCancel,
  loading
}: FormularioTipoMovimientoProps) {
  const { items: colores } = useCatalogoColores()

  const [formData, setFormData] = useState<Partial<CatalogoTipoMovimiento>>({
    codigo: '',
    nombre: '',
    descripcion: '',
    tipo: 'entrada',
    afecta_stock: true,
    requiere_documento: false,
    requiere_aprobacion: false,
    color_id: undefined,
    icono: '',
    orden: 0,
    es_activo: true
  })

  useEffect(() => {
    if (tipoMovimiento) {
      setFormData(tipoMovimiento)
    }
  }, [tipoMovimiento])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await onSubmit(formData)
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            {tipoMovimiento ? 'Editar Tipo de Movimiento' : 'Nuevo Tipo de Movimiento'}
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
                placeholder="compra, donacion, ajuste_entrada"
                disabled={!!tipoMovimiento} // No permitir editar código en modo edición
              />
              {tipoMovimiento && (
                <p className="mt-1 text-xs text-gray-500">
                  El código no se puede modificar una vez creado
                </p>
              )}
            </div>

            {/* Tipo */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo <span className="text-red-500">*</span>
              </label>
              <Select
                required
                value={formData.tipo}
                onChange={(e) => setFormData({ ...formData, tipo: e.target.value as any })}
              >
                <option value="entrada">Entrada</option>
                <option value="salida">Salida</option>
                <option value="ajuste">Ajuste</option>
                <option value="transferencia">Transferencia</option>
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
              placeholder="Compra a Proveedor, Donación, Salida por Prescripción"
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
              placeholder="Descripción del tipo de movimiento..."
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
                placeholder="ShoppingCart, Gift, FileText"
              />
            </div>
          </div>

          {/* Opciones de Comportamiento */}
          <div className="space-y-2 p-4 bg-gray-50 rounded-lg">
            <h4 className="text-sm font-medium text-gray-900 mb-3">
              Configuración del Movimiento
            </h4>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="afecta_stock"
                checked={formData.afecta_stock}
                onChange={(e) => setFormData({ ...formData, afecta_stock: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="afecta_stock" className="ml-2 block text-sm text-gray-900">
                Afecta el stock del inventario
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="requiere_documento"
                checked={formData.requiere_documento}
                onChange={(e) => setFormData({ ...formData, requiere_documento: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="requiere_documento" className="ml-2 block text-sm text-gray-900">
                Requiere documento de respaldo
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="requiere_aprobacion"
                checked={formData.requiere_aprobacion}
                onChange={(e) => setFormData({ ...formData, requiere_aprobacion: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="requiere_aprobacion" className="ml-2 block text-sm text-gray-900">
                Requiere aprobación previa
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
                Tipo de movimiento activo
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
              {loading ? 'Guardando...' : tipoMovimiento ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
