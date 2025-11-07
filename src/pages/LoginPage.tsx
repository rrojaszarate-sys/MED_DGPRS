import { useState, FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import type { User } from '../types'

// Perfiles mock para modo desarrollo
const DEV_PROFILES: User[] = [
  {
    id: 'dev-super-admin',
    email: 'superadmin@dev.local',
    full_name: 'Super Admin (Desarrollo)',
    role: 'super_admin',
    is_active: true,
    created_at: new Date().toISOString()
  },
  {
    id: 'dev-admin-center',
    email: 'admin@dev.local',
    full_name: 'Administrador Centro (Desarrollo)',
    role: 'admin_center',
    is_active: true,
    created_at: new Date().toISOString()
  },
  {
    id: 'dev-inventory-user',
    email: 'inventario@dev.local',
    full_name: 'Usuario Inventario (Desarrollo)',
    role: 'inventory_user',
    is_active: true,
    created_at: new Date().toISOString()
  },
  {
    id: 'dev-read-only',
    email: 'readonly@dev.local',
    full_name: 'Solo Lectura (Desarrollo)',
    role: 'read_only',
    is_active: true,
    created_at: new Date().toISOString()
  }
]

export function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [selectedProfile, setSelectedProfile] = useState<string>('')
  const { signIn, devModeLogin } = useAuth()
  const navigate = useNavigate()

  // Detectar si estamos en modo desarrollo
  const isDevMode = import.meta.env.VITE_DEV_MODE === 'true'

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      await signIn(email, password)
      navigate('/dashboard')
    } catch (err: any) {
      setError(err.message || 'Error al iniciar sesión')
    } finally {
      setLoading(false)
    }
  }

  // Login con perfil de desarrollo (sin autenticación real)
  async function handleDevLogin() {
    if (!selectedProfile || !devModeLogin) return

    setLoading(true)
    const profile = DEV_PROFILES.find(p => p.id === selectedProfile)

    if (profile) {
      try {
        await devModeLogin(profile)
        navigate('/dashboard')
      } catch (err: any) {
        setError('Error al iniciar sesión en modo desarrollo')
      }
    }
    setLoading(false)
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-2xl shadow-2xl">
        {/* Logo y Título */}
        <div className="text-center">
          <div className="mx-auto h-16 w-16 bg-primary rounded-full flex items-center justify-center mb-4">
            <svg
              className="h-10 w-10 text-white"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
          </div>
          <h2 className="text-3xl font-bold text-gray-900">SIGIMED</h2>
          <p className="mt-2 text-sm text-gray-600">
            Sistema de Gestión de Inventario de Medicamentos
          </p>
          {isDevMode && (
            <div className="mt-2 inline-block px-3 py-1 bg-yellow-100 text-yellow-800 text-xs font-semibold rounded-full">
              🔧 MODO DESARROLLO
            </div>
          )}
        </div>

        {/* Modo Desarrollo: Selector de Perfiles */}
        {isDevMode && (
          <div className="bg-yellow-50 border-2 border-yellow-200 rounded-lg p-4">
            <h3 className="text-sm font-semibold text-yellow-900 mb-3">
              🚀 Acceso Rápido - Desarrollo
            </h3>
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-yellow-800 mb-2">
                  Selecciona un perfil:
                </label>
                <select
                  value={selectedProfile}
                  onChange={(e) => setSelectedProfile(e.target.value)}
                  className="w-full px-3 py-2 border border-yellow-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-yellow-500 bg-white text-sm"
                >
                  <option value="">-- Elige un perfil --</option>
                  {DEV_PROFILES.map((profile) => (
                    <option key={profile.id} value={profile.id}>
                      {profile.full_name} ({profile.role})
                    </option>
                  ))}
                </select>
              </div>
              <button
                onClick={handleDevLogin}
                disabled={!selectedProfile || loading}
                className="w-full bg-yellow-500 hover:bg-yellow-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? 'Entrando...' : '⚡ Entrar Sin Login'}
              </button>
              <p className="text-xs text-yellow-700 text-center">
                Sin autenticación real - Solo para desarrollo
              </p>
            </div>
          </div>
        )}

        {/* Divisor */}
        {isDevMode && (
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-300"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">O usa login normal</span>
            </div>
          </div>
        )}

        {/* Formulario de Login Normal */}
        <form className={`space-y-6 ${isDevMode ? 'mt-6' : 'mt-8'}`} onSubmit={handleSubmit}>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="correo@ejemplo.com"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                Contraseña
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="••••••••"
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-primary hover:bg-primary-600 text-white font-semibold py-3 px-4 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
            </button>
          </div>

          {/* Usuarios de prueba - solo si NO es modo dev */}
          {!isDevMode && (
            <div className="mt-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
              <p className="text-xs font-medium text-gray-700 mb-2">Usuarios de prueba:</p>
              <div className="space-y-1 text-xs text-gray-600">
                <p>• Admin: admin@sigimed.com / Admin123!</p>
                <p>• Usuario: user@sigimed.com / User123!</p>
              </div>
            </div>
          )}
        </form>

        {/* Footer */}
        <div className="text-center text-xs text-gray-500 mt-4">
          SIGIMED v2.0 - {new Date().getFullYear()}
          {isDevMode && (
            <div className="mt-1 text-yellow-600 font-semibold">
              🔧 Modo Desarrollo Activado
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
