import { Navigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import { ReactNode } from 'react'
import type { User } from '../../types'

interface RoleGuardProps {
  children: ReactNode
  allowedRoles: User['role'][]
  fallback?: string
}

export function RoleGuard({ children, allowedRoles, fallback = '/dashboard' }: RoleGuardProps) {
  const { user, loading } = useAuth()

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
          <p className="mt-4 text-gray-600">Verificando permisos...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return <Navigate to="/login" replace />
  }

  if (!allowedRoles.includes(user.role)) {
    return <Navigate to={fallback} replace />
  }

  return <>{children}</>
}
