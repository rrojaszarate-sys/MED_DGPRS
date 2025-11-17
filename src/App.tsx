import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { LoginPage } from './pages/LoginPage'
import { DashboardPage } from './pages/DashboardPage'
import { InventoryPage } from './pages/InventoryPage'
import { AlertasPage } from './pages/AlertasPage'
import { AdminPage } from './pages/AdminPage'
import { ReportsPage } from './pages/ReportsPage'
import { SuppliersPage } from './pages/SuppliersPage'
import { MovementsPage } from './pages/MovementsPage'
import { ContractsPage } from './pages/ContractsPage'
import { InstitutionsPage } from './pages/InstitutionsPage'
import { HealthCentersPage } from './pages/HealthCentersPage'
import { WarehouseMapPage } from './pages/WarehouseMapPage'
import { TemperatureMonitoringPage } from './pages/TemperatureMonitoringPage'
import { UsersManagementPage } from './pages/UsersManagementPage'
import { AuditLogPage } from './pages/AuditLogPage'
import { AuthProvider } from './context/AuthContext'
import { CentroProvider } from './context/CentroContext'
import { ToastProvider } from './components/ui/Toast'
import { ProtectedRoute } from './components/auth/ProtectedRoute'
import { RoleGuard } from './components/auth/RoleGuard'
import { MainLayout } from './components/layout/MainLayout'

function App() {
  return (
    <AuthProvider>
      <CentroProvider>
        <ToastProvider>
          <BrowserRouter>
            <Routes>
              <Route path="/login" element={<LoginPage />} />

              {/* Protected Routes */}
              <Route path="/dashboard" element={
                <ProtectedRoute>
                  <MainLayout>
                    <DashboardPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/inventario" element={
                <ProtectedRoute>
                  <MainLayout>
                    <InventoryPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/alertas" element={
                <ProtectedRoute>
                  <MainLayout>
                    <AlertasPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/reportes" element={
                <ProtectedRoute>
                  <MainLayout>
                    <ReportsPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/proveedores" element={
                <ProtectedRoute>
                  <MainLayout>
                    <SuppliersPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/movimientos" element={
                <ProtectedRoute>
                  <MainLayout>
                    <MovementsPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/contratos" element={
                <ProtectedRoute>
                  <MainLayout>
                    <ContractsPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/admin" element={
                <ProtectedRoute>
                  <RoleGuard allowedRoles={['super_admin', 'admin_center']}>
                    <MainLayout>
                      <AdminPage />
                    </MainLayout>
                  </RoleGuard>
                </ProtectedRoute>
              } />

              <Route path="/instituciones" element={
                <ProtectedRoute>
                  <RoleGuard allowedRoles={['super_admin', 'admin_center']}>
                    <MainLayout>
                      <InstitutionsPage />
                    </MainLayout>
                  </RoleGuard>
                </ProtectedRoute>
              } />

              <Route path="/centros" element={
                <ProtectedRoute>
                  <RoleGuard allowedRoles={['super_admin', 'admin_center']}>
                    <MainLayout>
                      <HealthCentersPage />
                    </MainLayout>
                  </RoleGuard>
                </ProtectedRoute>
              } />

              <Route path="/mapa-almacen" element={
                <ProtectedRoute>
                  <MainLayout>
                    <WarehouseMapPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/temperatura" element={
                <ProtectedRoute>
                  <MainLayout>
                    <TemperatureMonitoringPage />
                  </MainLayout>
                </ProtectedRoute>
              } />

              <Route path="/usuarios" element={
                <ProtectedRoute>
                  <RoleGuard allowedRoles={['super_admin', 'admin_center']}>
                    <MainLayout>
                      <UsersManagementPage />
                    </MainLayout>
                  </RoleGuard>
                </ProtectedRoute>
              } />

              <Route path="/auditoria" element={
                <ProtectedRoute>
                  <RoleGuard allowedRoles={['super_admin', 'admin_center']}>
                    <MainLayout>
                      <AuditLogPage />
                    </MainLayout>
                  </RoleGuard>
                </ProtectedRoute>
              } />

              <Route path="/" element={<Navigate to="/dashboard" replace />} />
            </Routes>
          </BrowserRouter>
        </ToastProvider>
      </CentroProvider>
    </AuthProvider>
  )
}

export default App
