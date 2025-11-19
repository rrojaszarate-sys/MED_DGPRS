import { ReactNode, useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import {
  LayoutDashboard,
  Package,
  Bell,
  LogOut,
  Settings,
  FileText,
  Truck,
  TrendingUp,
  FileCheck,
  Building2,
  MapPin,
  Sliders,
  ChevronDown,
  ChevronRight,
  Menu,
  X,
  Pill,
  ClipboardList
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { CentroSelector } from '../dashboard/CentroSelector'

interface MainLayoutProps {
  children: ReactNode
}

interface NavSection {
  title: string
  items: NavItem[]
}

interface NavItem {
  name: string
  href: string
  icon: any
  adminOnly?: boolean
}

export function MainLayout({ children }: MainLayoutProps) {
  const { user, signOut } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [expandedSections, setExpandedSections] = useState<string[]>(['general', 'inventario', 'administracion'])

  const navigationSections: NavSection[] = [
    {
      title: 'General',
      items: [
        { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
        { name: 'Alertas', href: '/alertas', icon: Bell },
        { name: 'Reportes', href: '/reportes', icon: FileText },
      ]
    },
    {
      title: 'Inventario',
      items: [
        { name: 'Inventario', href: '/inventario', icon: Package },
        { name: 'Lotes', href: '/lotes', icon: ClipboardList },
        { name: 'Movimientos', href: '/movimientos', icon: TrendingUp },
      ]
    },
    {
      title: 'Gestión',
      items: [
        { name: 'Proveedores', href: '/proveedores', icon: Truck },
        { name: 'Contratos', href: '/contratos', icon: FileCheck },
      ]
    },
    {
      title: 'Administración',
      items: [
        { name: 'Catálogo Medicamentos', href: '/admin', icon: Pill, adminOnly: true },
        { name: 'Instituciones', href: '/instituciones', icon: Building2, adminOnly: true },
        { name: 'Centros de Salud', href: '/centros', icon: MapPin, adminOnly: true },
        { name: 'Catálogos', href: '/catalogos', icon: Sliders, adminOnly: true },
      ]
    }
  ]

  const isActive = (path: string) => location.pathname === path

  const toggleSection = (title: string) => {
    setExpandedSections(prev =>
      prev.includes(title)
        ? prev.filter(s => s !== title)
        : [...prev, title]
    )
  }

  const handleSignOut = async () => {
    await signOut()
    navigate('/login')
  }

  const isAdmin = user?.role === 'super_admin' || user?.role === 'admin_center'

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <aside
        className={`bg-white border-r border-gray-200 transition-all duration-300 ${
          sidebarOpen ? 'w-64' : 'w-20'
        } flex flex-col fixed h-full z-20`}
      >
        {/* Logo */}
        <div className="p-4 border-b border-gray-200 flex items-center justify-between">
          {sidebarOpen && (
            <div className="flex items-center space-x-3">
              <div className="h-10 w-10 bg-primary rounded-full flex items-center justify-center flex-shrink-0">
                <svg
                  className="h-6 w-6 text-white"
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
              <div>
                <h1 className="text-lg font-bold text-gray-900">SIGIMED</h1>
                <p className="text-xs text-gray-500">v2.0</p>
              </div>
            </div>
          )}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
          >
            {sidebarOpen ? (
              <X className="h-5 w-5 text-gray-600" />
            ) : (
              <Menu className="h-5 w-5 text-gray-600" />
            )}
          </button>
        </div>

        {/* Navigation Sections */}
        <nav className="flex-1 overflow-y-auto py-4">
          {navigationSections.map((section) => {
            // Filtrar items de admin si el usuario no es admin
            const visibleItems = section.items.filter(item =>
              !item.adminOnly || isAdmin
            )

            if (visibleItems.length === 0) return null

            const isExpanded = expandedSections.includes(section.title.toLowerCase())

            return (
              <div key={section.title} className="mb-2">
                {/* Section Header */}
                <button
                  onClick={() => toggleSection(section.title.toLowerCase())}
                  className={`w-full flex items-center justify-between px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors ${
                    !sidebarOpen && 'justify-center'
                  }`}
                >
                  {sidebarOpen && <span>{section.title}</span>}
                  {sidebarOpen &&
                    (isExpanded ? (
                      <ChevronDown className="h-4 w-4" />
                    ) : (
                      <ChevronRight className="h-4 w-4" />
                    ))}
                </button>

                {/* Section Items */}
                {(isExpanded || !sidebarOpen) && (
                  <div className={sidebarOpen ? 'ml-2' : ''}>
                    {visibleItems.map((item) => {
                      const Icon = item.icon
                      const active = isActive(item.href)
                      return (
                        <button
                          key={item.name}
                          onClick={() => navigate(item.href)}
                          className={`w-full flex items-center gap-3 px-4 py-2.5 text-sm transition-colors ${
                            active
                              ? 'bg-primary-50 text-primary font-medium border-r-2 border-primary'
                              : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                          } ${!sidebarOpen && 'justify-center'}`}
                          title={!sidebarOpen ? item.name : undefined}
                        >
                          <Icon className={`h-5 w-5 flex-shrink-0 ${!sidebarOpen && 'mx-auto'}`} />
                          {sidebarOpen && <span>{item.name}</span>}
                        </button>
                      )
                    })}
                  </div>
                )}
              </div>
            )
          })}
        </nav>

        {/* User Info */}
        <div className="border-t border-gray-200 p-4">
          {sidebarOpen ? (
            <div className="flex items-center justify-between">
              <div className="min-w-0 flex-1">
                <p className="text-sm font-medium text-gray-900 truncate">
                  {user?.full_name || user?.email}
                </p>
                <p className="text-xs text-gray-500 capitalize truncate">
                  {user?.role.replace('_', ' ')}
                </p>
              </div>
              <button
                onClick={handleSignOut}
                className="p-2 text-gray-400 hover:text-red-600 transition-colors rounded-lg hover:bg-gray-100"
                title="Cerrar sesión"
              >
                <LogOut className="h-5 w-5" />
              </button>
            </div>
          ) : (
            <button
              onClick={handleSignOut}
              className="w-full p-2 text-gray-400 hover:text-red-600 transition-colors rounded-lg hover:bg-gray-100 flex justify-center"
              title="Cerrar sesión"
            >
              <LogOut className="h-5 w-5" />
            </button>
          )}
        </div>
      </aside>

      {/* Main Content Area */}
      <div className={`flex-1 flex flex-col transition-all duration-300 ${sidebarOpen ? 'ml-64' : 'ml-20'}`}>
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10">
          <div className="px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16">
              <div className="flex-1 max-w-xl">
                <CentroSelector />
              </div>
            </div>
          </div>
        </header>

        {/* Main Content */}
        <main className="flex-1 overflow-auto px-4 sm:px-6 lg:px-8 py-8">
          {children}
        </main>

        {/* Footer */}
        <footer className="bg-white border-t border-gray-200 mt-auto">
          <div className="px-4 sm:px-6 lg:px-8 py-4">
            <p className="text-center text-sm text-gray-500">
              SIGIMED v2.0 - Sistema de Gestión de Inventario de Medicamentos - {new Date().getFullYear()}
            </p>
          </div>
        </footer>
      </div>
    </div>
  )
}
