/**
 * Formulario para Catálogo de Configuraciones
 * Sistema: SIGIMED v2.0
 */

import React, { useState, useEffect } from 'react'
import { X, AlertTriangle } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Select } from '../ui/Select'
import { CatalogoConfiguracion } from '../../types'

interface FormularioConfiguracionProps {
  configuracion?: CatalogoConfiguracion | null
  onSubmit: (data: Partial<CatalogoConfiguracion>) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function FormularioConfiguracion({
  configuracion,
  onSubmit,
  onCancel,
  loading
}: FormularioConfiguracionProps) {
  const [formData, setFormData] = useState<Partial<CatalogoConfiguracion>>({
    clave: '',
    valor: '',
    tipo_dato: 'texto',
    nombre: '',
    descripcion: '',
    categoria: 'general',
    valor_por_defecto: '',
    es_requerido: false,
    es_sensible: false,
    orden: 0,
    es_activo: true
  })

  useEffect(() => {
    if (configuracion) {
      setFormData(configuracion)
    }
  }, [configuracion])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await onSubmit(formData)
  }

  // Renderizar input según tipo de dato
  const renderInputValor = () => {
    switch (formData.tipo_dato) {
      case 'numero':
        return (
          <Input
            type="number"
            required
            value={formData.valor}
            onChange={(e) => setFormData({ ...formData, valor: e.target.value })}
            placeholder="Ej: 30"
          />
        )

      case 'booleano':
        return (
          <Select
            required
            value={formData.valor}
            onChange={(e) => setFormData({ ...formData, valor: e.target.value })}
          >
            <option value="true">Verdadero</option>
            <option value="false">Falso</option>
          </Select>
        )

      case 'json':
        return (
          <textarea
            required
            value={formData.valor}
            onChange={(e) => setFormData({ ...formData, valor: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono text-sm"
            rows={4}
            placeholder='{"clave": "valor"}'
          />
        )

      case 'fecha':
        return (
          <Input
            type="date"
            required
            value={formData.valor}
            onChange={(e) => setFormData({ ...formData, valor: e.target.value })}
          />
        )

      default:
        return (
          <Input
            type={formData.es_sensible ? 'password' : 'text'}
            required
            value={formData.valor}
            onChange={(e) => setFormData({ ...formData, valor: e.target.value })}
            placeholder="Valor de la configuración"
          />
        )
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            {configuracion ? 'Editar Configuración' : 'Nueva Configuración'}
          </h3>
          <button onClick={onCancel} className="text-gray-400 hover:text-gray-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Advertencia de configuración sensible */}
          {formData.es_sensible && (
            <div className="p-3 bg-yellow-50 border border-yellow-200 rounded-lg flex items-start gap-2">
              <AlertTriangle className="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-yellow-800">
                <p className="font-medium">Configuración sensible</p>
                <p>Esta configuración contiene información sensible que se ocultará en la interfaz.</p>
              </div>
            </div>
          )}

          {/* Clave */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Clave <span className="text-red-500">*</span>
            </label>
            <Input
              required
              value={formData.clave}
              onChange={(e) => setFormData({ ...formData, clave: e.target.value })}
              placeholder="dias_alerta_critica, email_notificaciones"
              disabled={!!configuracion} // No permitir editar clave en modo edición
            />
            {configuracion && (
              <p className="mt-1 text-xs text-gray-500">
                La clave no se puede modificar una vez creada
              </p>
            )}
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
              placeholder="Nombre legible de la configuración"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* Tipo de dato */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de dato <span className="text-red-500">*</span>
              </label>
              <Select
                required
                value={formData.tipo_dato}
                onChange={(e) => setFormData({ ...formData, tipo_dato: e.target.value as any })}
              >
                <option value="texto">Texto</option>
                <option value="numero">Número</option>
                <option value="booleano">Booleano</option>
                <option value="json">JSON</option>
                <option value="fecha">Fecha</option>
              </Select>
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
                <option value="sistema">Sistema</option>
                <option value="alertas">Alertas</option>
                <option value="notificaciones">Notificaciones</option>
                <option value="seguridad">Seguridad</option>
                <option value="general">General</option>
              </Select>
            </div>
          </div>

          {/* Valor */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Valor <span className="text-red-500">*</span>
            </label>
            {renderInputValor()}
          </div>

          {/* Valor por defecto */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Valor por defecto
            </label>
            <Input
              type={formData.es_sensible ? 'password' : 'text'}
              value={formData.valor_por_defecto}
              onChange={(e) => setFormData({ ...formData, valor_por_defecto: e.target.value })}
              placeholder="Valor a usar si no se especifica uno"
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
              placeholder="Descripción de la configuración..."
            />
          </div>

          {/* Opciones */}
          <div className="space-y-2 p-4 bg-gray-50 rounded-lg">
            <div className="flex items-center">
              <input
                type="checkbox"
                id="es_requerido"
                checked={formData.es_requerido}
                onChange={(e) => setFormData({ ...formData, es_requerido: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="es_requerido" className="ml-2 block text-sm text-gray-900">
                Configuración requerida
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="es_sensible"
                checked={formData.es_sensible}
                onChange={(e) => setFormData({ ...formData, es_sensible: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="es_sensible" className="ml-2 block text-sm text-gray-900">
                Información sensible (se ocultará en UI)
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
                Configuración activa
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
              {loading ? 'Guardando...' : configuracion ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
