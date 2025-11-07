import { createContext, useContext, useState, ReactNode, useEffect } from 'react'
import type { HealthCenter } from '../types'

interface CentroContextType {
  centroSeleccionado: HealthCenter | null
  setCentroSeleccionado: (centro: HealthCenter | null) => void
}

const CentroContext = createContext<CentroContextType | undefined>(undefined)

export function CentroProvider({ children }: { children: ReactNode }) {
  const [centroSeleccionado, setCentroSeleccionado] = useState<HealthCenter | null>(null)

  // Guardar en localStorage
  useEffect(() => {
    if (centroSeleccionado) {
      localStorage.setItem('centroSeleccionado', JSON.stringify(centroSeleccionado))
    }
  }, [centroSeleccionado])

  // Cargar de localStorage al iniciar
  useEffect(() => {
    const stored = localStorage.getItem('centroSeleccionado')
    if (stored) {
      try {
        setCentroSeleccionado(JSON.parse(stored))
      } catch (err) {
        console.error('Error loading centro from localStorage:', err)
      }
    }
  }, [])

  return (
    <CentroContext.Provider value={{ centroSeleccionado, setCentroSeleccionado }}>
      {children}
    </CentroContext.Provider>
  )
}

export function useCentro() {
  const context = useContext(CentroContext)
  if (context === undefined) {
    throw new Error('useCentro must be used within a CentroProvider')
  }
  return context
}
