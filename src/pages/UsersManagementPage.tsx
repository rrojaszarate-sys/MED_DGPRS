import { useState } from 'react'
import { Plus, Search, Edit, Trash2, Key, UserCheck, UserX } from 'lucide-react'
import { useUsers } from '../hooks/useUsers'
import { Button } from '../components/ui/Button'
import { useToast } from '../components/ui/Toast'
import type { User } from '../types'

export function UsersManagementPage() {
  const { users, loading, deleteUser, resetPassword, updateUser } = useUsers()
  const [searchTerm, setSearchTerm] = useState('')
  const [filterRole, setFilterRole] = useState<string>('all')
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const toast = useToast()

  // Filtrar usuarios
  const filteredUsers = users.filter((user) => {
    const matchesSearch = user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (user.full_name && user.full_name.toLowerCase().includes(searchTerm.toLowerCase()))
    const matchesRole = filterRole === 'all' || user.role === filterRole
    const matchesStatus = filterStatus === 'all' ||
                         (filterStatus === 'active' && user.is_active) ||
                         (filterStatus === 'inactive' && !user.is_active)
    return matchesSearch && matchesRole && matchesStatus
  })

  const handleDelete = async (id: string, email: string) => {
    if (!confirm(`¿Estás seguro de desactivar el usuario ${email}?`)) return

    const { error } = await deleteUser(id)
    if (error) {
      toast.error('Error al desactivar usuario')
    } else {
      toast.success('Usuario desactivado correctamente')
    }
  }

  const handleToggleStatus = async (user: User) => {
    const newStatus = !user.is_active
    const { error } = await updateUser(user.id, { is_active: newStatus })
    if (error) {
      toast.error('Error al cambiar estado del usuario')
    } else {
      toast.success(`Usuario ${newStatus ? 'activado' : 'desactivado'} correctamente`)
    }
  }

  const handleResetPassword = async (email: string) => {
    if (!confirm(`¿Enviar correo de recuperación a ${email}?`)) return

    const { error } = await resetPassword(email)
    if (error) {
      toast.error('Error al enviar correo de recuperación')
    } else {
      toast.success('Correo de recuperación enviado')
    }
  }

  const getRoleLabel = (role: string) => {
    const roleLabels: Record<string, string> = {
      super_admin: 'Super Administrador',
      admin_center: 'Administrador de Centro',
      inventory_user: 'Usuario de Inventario',
      read_only: 'Solo Lectura'
    }
    return roleLabels[role] || role
  }

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'super_admin': return 'bg-purple-100 text-purple-800'
      case 'admin_center': return 'bg-blue-100 text-blue-800'
      case 'inventory_user': return 'bg-green-100 text-green-800'
      case 'read_only': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Gestión de Usuarios</h1>
          <p className="text-gray-600 mt-1">Administra los usuarios del sistema</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => toast.info('Formulario de usuario próximamente')}
            icon={<Plus className="h-5 w-5" />}
          >
            Nuevo Usuario
          </Button>
        </div>
      </div>

      {/* Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Usuarios</p>
              <p className="text-2xl font-bold text-gray-900">{users.length}</p>
            </div>
            <UserCheck className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Activos</p>
              <p className="text-2xl font-bold text-green-600">
                {users.filter(u => u.is_active).length}
              </p>
            </div>
            <UserCheck className="h-8 w-8 text-green-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Inactivos</p>
              <p className="text-2xl font-bold text-red-600">
                {users.filter(u => !u.is_active).length}
              </p>
            </div>
            <UserX className="h-8 w-8 text-red-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Administradores</p>
              <p className="text-2xl font-bold text-gray-900">
                {users.filter(u => u.role === 'super_admin' || u.role === 'admin_center').length}
              </p>
            </div>
            <UserCheck className="h-8 w-8 text-purple-500" />
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-lg shadow-md space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por email o nombre..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          <div>
            <select
              value={filterRole}
              onChange={(e) => setFilterRole(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todos los roles</option>
              <option value="super_admin">Super Administrador</option>
              <option value="admin_center">Admin de Centro</option>
              <option value="inventory_user">Usuario de Inventario</option>
              <option value="read_only">Solo Lectura</option>
            </select>
          </div>

          <div>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">Todos los estados</option>
              <option value="active">Activos</option>
              <option value="inactive">Inactivos</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="ml-auto text-sm text-gray-600">
            {filteredUsers.length} de {users.length} usuarios
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-500">Cargando...</p>
          </div>
        ) : filteredUsers.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64">
            <p className="text-gray-500 mb-2">No hay usuarios registrados</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Usuario</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rol</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha Creación</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10">
                          <div className="h-10 w-10 rounded-full bg-primary flex items-center justify-center text-white font-bold">
                            {user.full_name?.[0]?.toUpperCase() || user.email[0].toUpperCase()}
                          </div>
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {user.full_name || 'Sin nombre'}
                          </div>
                          <div className="text-sm text-gray-500">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 text-xs font-semibold rounded-full ${getRoleColor(user.role)}`}>
                        {getRoleLabel(user.role)}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      {user.is_active ? (
                        <span className="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                          Activo
                        </span>
                      ) : (
                        <span className="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                          Inactivo
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">
                        {new Date(user.created_at).toLocaleDateString('es-MX')}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex gap-2">
                        <button
                          onClick={() => handleToggleStatus(user)}
                          className={`inline-flex items-center gap-1 text-sm font-medium ${
                            user.is_active
                              ? 'text-orange-600 hover:text-orange-800'
                              : 'text-green-600 hover:text-green-800'
                          }`}
                          title={user.is_active ? 'Desactivar' : 'Activar'}
                        >
                          {user.is_active ? (
                            <>
                              <UserX className="h-4 w-4" />
                              Desactivar
                            </>
                          ) : (
                            <>
                              <UserCheck className="h-4 w-4" />
                              Activar
                            </>
                          )}
                        </button>
                        <button
                          onClick={() => handleResetPassword(user.email)}
                          className="inline-flex items-center gap-1 text-blue-600 hover:text-blue-800 text-sm font-medium"
                          title="Resetear contraseña"
                        >
                          <Key className="h-4 w-4" />
                          Reset
                        </button>
                        <button
                          onClick={() => toast.info('Editar usuario próximamente')}
                          className="inline-flex items-center gap-1 text-primary hover:text-primary-dark text-sm font-medium"
                          title="Editar usuario"
                        >
                          <Edit className="h-4 w-4" />
                          Editar
                        </button>
                        <button
                          onClick={() => handleDelete(user.id, user.email)}
                          className="inline-flex items-center gap-1 text-red-600 hover:text-red-800 text-sm font-medium"
                          title="Eliminar usuario"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Role Permissions Info */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-lg font-bold text-gray-900 mb-4">Permisos por Rol</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="border border-purple-200 rounded-lg p-4">
            <h3 className="font-bold text-purple-800 mb-2">Super Administrador</h3>
            <ul className="text-sm text-gray-600 space-y-1">
              <li>✓ Acceso total al sistema</li>
              <li>✓ Gestión de usuarios</li>
              <li>✓ Gestión de centros</li>
              <li>✓ Configuración global</li>
            </ul>
          </div>
          <div className="border border-blue-200 rounded-lg p-4">
            <h3 className="font-bold text-blue-800 mb-2">Admin de Centro</h3>
            <ul className="text-sm text-gray-600 space-y-1">
              <li>✓ Gestión de inventario</li>
              <li>✓ Ver reportes</li>
              <li>✓ Gestión de usuarios del centro</li>
              <li>✗ Configuración global</li>
            </ul>
          </div>
          <div className="border border-green-200 rounded-lg p-4">
            <h3 className="font-bold text-green-800 mb-2">Usuario de Inventario</h3>
            <ul className="text-sm text-gray-600 space-y-1">
              <li>✓ Registrar movimientos</li>
              <li>✓ Ver inventario</li>
              <li>✗ Eliminar registros</li>
              <li>✗ Gestión de usuarios</li>
            </ul>
          </div>
          <div className="border border-gray-200 rounded-lg p-4">
            <h3 className="font-bold text-gray-800 mb-2">Solo Lectura</h3>
            <ul className="text-sm text-gray-600 space-y-1">
              <li>✓ Ver inventario</li>
              <li>✓ Ver reportes</li>
              <li>✗ Modificar datos</li>
              <li>✗ Exportar datos</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}
