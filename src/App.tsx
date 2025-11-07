import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { LoginPage } from './pages/LoginPage'
import { DashboardPage } from './pages/DashboardPage'
import { InventoryPage } from './pages/InventoryPage'
import { AlertasPage } from './pages/AlertasPage'
import { AuthProvider } from './context/AuthContext'
import { CentroProvider } from './context/CentroContext'
import { ToastProvider } from './components/ui/Toast'
import { ProtectedRoute } from './components/auth/ProtectedRoute'
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

              <Route path="/" element={<Navigate to="/dashboard" replace />} />
            </Routes>
          </BrowserRouter>
        </ToastProvider>
      </CentroProvider>
    </AuthProvider>
  )
}

export default App
