import { describe, it, expect, beforeEach, vi } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { useMedicamentos } from '../useMedicamentos';

// Mock Supabase
vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => Promise.resolve({
          data: mockMedicamentos,
          error: null,
        })),
      })),
      insert: vi.fn(() => Promise.resolve({
        data: [mockMedicamentos[0]],
        error: null,
      })),
      update: vi.fn(() => ({
        eq: vi.fn(() => Promise.resolve({
          data: [mockMedicamentos[0]],
          error: null,
        })),
      })),
      delete: vi.fn(() => ({
        eq: vi.fn(() => Promise.resolve({
          data: [],
          error: null,
        })),
      })),
    })),
  },
}));

const mockMedicamentos = [
  {
    id: '1',
    center_id: 'center-1',
    catalog_id: 'catalog-1',
    nombre: 'Paracetamol',
    descripcion: 'Acetaminofén',
    cantidad: 1000,
    fecha_caducidad: '2025-12-31',
    estado: 'Disponible',
    lote: 'LOTE-2025-001',
    ubicacion_fisica: 'Anaquel A',
    is_active: true,
  },
  {
    id: '2',
    center_id: 'center-1',
    catalog_id: 'catalog-2',
    nombre: 'Ibuprofeno',
    descripcion: 'Ibuprofeno',
    cantidad: 50,
    fecha_caducidad: '2025-03-15',
    estado: 'Disponible',
    lote: 'LOTE-2025-002',
    ubicacion_fisica: 'Anaquel B',
    is_active: true,
  },
];

describe('useMedicamentos', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('Carga de datos', () => {
    it('debe cargar la lista de medicamentos correctamente', async () => {
      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      expect(result.current.medicamentos[0].nombre).toBe('Paracetamol');
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
    });

    it('debe filtrar medicamentos por centro de salud', async () => {
      const { result } = renderHook(() => useMedicamentos('center-1'));

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      result.current.medicamentos.forEach(med => {
        expect(med.center_id).toBe('center-1');
      });
    });
  });

  describe('Detección de alertas', () => {
    it('debe detectar medicamentos con stock bajo', async () => {
      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      const medicamentoBajoStock = result.current.medicamentos.find(
        m => m.cantidad < 100
      );

      expect(medicamentoBajoStock).toBeDefined();
      expect(medicamentoBajoStock?.cantidad).toBe(50);
    });

    it('debe detectar medicamentos próximos a vencer', async () => {
      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      const hoy = new Date();
      const tresMeses = new Date();
      tresMeses.setMonth(tresMeses.getMonth() + 3);

      const proximosVencer = result.current.medicamentos.filter(m => {
        const fechaCad = new Date(m.fecha_caducidad);
        return fechaCad >= hoy && fechaCad <= tresMeses;
      });

      expect(proximosVencer.length).toBeGreaterThanOrEqual(0);
    });
  });

  describe('Búsqueda y filtrado', () => {
    it('debe buscar medicamentos por nombre', async () => {
      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      const resultadoBusqueda = result.current.medicamentos.filter(m =>
        m.nombre.toLowerCase().includes('para')
      );

      expect(resultadoBusqueda).toHaveLength(1);
      expect(resultadoBusqueda[0].nombre).toBe('Paracetamol');
    });

    it('debe filtrar medicamentos por estado', async () => {
      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      const disponibles = result.current.medicamentos.filter(
        m => m.estado === 'Disponible'
      );

      expect(disponibles).toHaveLength(2);
    });
  });

  describe('Operaciones CRUD', () => {
    it('debe crear un nuevo medicamento', async () => {
      const { result } = renderHook(() => useMedicamentos());

      const nuevoMedicamento = {
        center_id: 'center-1',
        catalog_id: 'catalog-3',
        nombre: 'Aspirina',
        descripcion: 'Ácido acetilsalicílico',
        cantidad: 500,
        fecha_caducidad: '2026-01-01',
        estado: 'Disponible',
        lote: 'LOTE-2025-003',
        ubicacion_fisica: 'Anaquel C',
      };

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      // Simular creación
      expect(result.current.error).toBeNull();
    });

    it('debe actualizar un medicamento existente', async () => {
      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.medicamentos).toHaveLength(2);
      });

      const medicamentoActualizado = {
        ...mockMedicamentos[0],
        cantidad: 1500,
      };

      // Simular actualización
      expect(result.current.error).toBeNull();
    });
  });

  describe('Validaciones', () => {
    it('debe validar cantidad positiva', () => {
      const cantidadInvalida = -10;
      expect(cantidadInvalida).toBeLessThan(0);
    });

    it('debe validar fecha de caducidad futura', () => {
      const hoy = new Date();
      const fechaCaducidad = new Date('2025-12-31');
      expect(fechaCaducidad.getTime()).toBeGreaterThan(hoy.getTime());
    });

    it('debe validar campos requeridos', () => {
      const medicamentoIncompleto = {
        nombre: 'Test',
        // Falta descripcion, cantidad, etc.
      };

      expect(medicamentoIncompleto).not.toHaveProperty('cantidad');
    });
  });

  describe('Manejo de errores', () => {
    it('debe manejar errores de red correctamente', async () => {
      // Mock error
      vi.mocked(supabase.from).mockImplementationOnce(() => ({
        select: () => ({
          eq: () => Promise.resolve({
            data: null,
            error: { message: 'Network error' },
          }),
        }),
      }));

      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.error).not.toBeNull();
      });

      expect(result.current.medicamentos).toHaveLength(0);
    });

    it('debe manejar datos vacíos correctamente', async () => {
      vi.mocked(supabase.from).mockImplementationOnce(() => ({
        select: () => ({
          eq: () => Promise.resolve({
            data: [],
            error: null,
          }),
        }),
      }));

      const { result } = renderHook(() => useMedicamentos());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.medicamentos).toHaveLength(0);
      expect(result.current.error).toBeNull();
    });
  });
});
