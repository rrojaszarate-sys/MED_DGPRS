import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import type { Medication, Alert, MedicationCatalog } from '../types'

// PDF Export for Medications
export function exportMedicationsPDF(medications: Medication[], centerName?: string) {
  const doc = new jsPDF()

  // Header
  doc.setFontSize(18)
  doc.setTextColor(127, 33, 65) // Primary color
  doc.text('SIGIMED - Reporte de Inventario', 14, 20)

  if (centerName) {
    doc.setFontSize(12)
    doc.setTextColor(100, 100, 100)
    doc.text(`Centro: ${centerName}`, 14, 28)
  }

  doc.setFontSize(10)
  doc.text(`Fecha: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: es })}`, 14, centerName ? 34 : 28)
  doc.text(`Total de medicamentos: ${medications.length}`, 14, centerName ? 40 : 34)

  // Table
  const tableData = medications.map(med => {
    const dias = Math.ceil((new Date(med.fecha_caducidad).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    return [
      med.nombre,
      med.formula_activa,
      med.lote,
      med.cantidad.toString(),
      format(new Date(med.fecha_caducidad), 'dd/MM/yyyy', { locale: es }),
      `${dias} días`,
      med.estado
    ]
  })

  autoTable(doc, {
    head: [['Medicamento', 'Fórmula', 'Lote', 'Cantidad', 'Caducidad', 'Días Rest.', 'Estado']],
    body: tableData,
    startY: centerName ? 46 : 40,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [127, 33, 65] }
  })

  // Save
  const filename = `inventario_${format(new Date(), 'yyyyMMdd_HHmmss')}.pdf`
  doc.save(filename)
}

// Excel Export for Medications
export function exportMedicationsExcel(medications: Medication[], _centerName?: string) {
  const data = medications.map(med => {
    const dias = Math.ceil((new Date(med.fecha_caducidad).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    return {
      'Medicamento': med.nombre,
      'Fórmula Activa': med.formula_activa,
      'Lote': med.lote,
      'Cantidad': med.cantidad,
      'Fecha Caducidad': format(new Date(med.fecha_caducidad), 'dd/MM/yyyy', { locale: es }),
      'Días Restantes': dias,
      'Estado': med.estado,
      'Fecha Ingreso': format(new Date(med.fecha_ingreso), 'dd/MM/yyyy', { locale: es })
    }
  })

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Inventario')

  // Adjust column widths
  const colWidths = [
    { wch: 30 }, // Medicamento
    { wch: 20 }, // Fórmula
    { wch: 15 }, // Lote
    { wch: 10 }, // Cantidad
    { wch: 15 }, // Caducidad
    { wch: 15 }, // Días
    { wch: 15 }, // Estado
    { wch: 15 }  // Fecha Ingreso
  ]
  ws['!cols'] = colWidths

  const filename = `inventario_${format(new Date(), 'yyyyMMdd_HHmmss')}.xlsx`
  XLSX.writeFile(wb, filename)
}

// PDF Export for Alerts
export function exportAlertsPDF(alerts: Alert[], centerName?: string) {
  const doc = new jsPDF()

  // Header
  doc.setFontSize(18)
  doc.setTextColor(127, 33, 65)
  doc.text('SIGIMED - Reporte de Alertas', 14, 20)

  if (centerName) {
    doc.setFontSize(12)
    doc.setTextColor(100, 100, 100)
    doc.text(`Centro: ${centerName}`, 14, 28)
  }

  doc.setFontSize(10)
  doc.text(`Fecha: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: es })}`, 14, centerName ? 34 : 28)
  doc.text(`Total de alertas: ${alerts.length}`, 14, centerName ? 40 : 34)

  // Count by level
  const criticas = alerts.filter(a => a.nivel_alerta === 'critico').length
  const urgentes = alerts.filter(a => a.nivel_alerta === 'urgente').length
  const preventivas = alerts.filter(a => a.nivel_alerta === 'preventivo').length

  doc.text(`Críticas: ${criticas} | Urgentes: ${urgentes} | Preventivas: ${preventivas}`, 14, centerName ? 46 : 40)

  // Table
  const tableData = alerts.map(alert => [
    alert.medicamento?.nombre || 'N/A',
    alert.medicamento?.lote || 'N/A',
    alert.dias_restantes.toString(),
    alert.nivel_alerta.toUpperCase(),
    alert.visto ? 'Sí' : 'No'
  ])

  autoTable(doc, {
    head: [['Medicamento', 'Lote', 'Días Restantes', 'Nivel', 'Visto']],
    body: tableData,
    startY: centerName ? 52 : 46,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [127, 33, 65] }
  })

  const filename = `alertas_${format(new Date(), 'yyyyMMdd_HHmmss')}.pdf`
  doc.save(filename)
}

// Excel Export for Alerts
export function exportAlertsExcel(alerts: Alert[], _centerName?: string) {
  const data = alerts.map(alert => ({
    'Medicamento': alert.medicamento?.nombre || 'N/A',
    'Fórmula Activa': alert.medicamento?.formula_activa || 'N/A',
    'Lote': alert.medicamento?.lote || 'N/A',
    'Cantidad': alert.medicamento?.cantidad || 0,
    'Días Restantes': alert.dias_restantes,
    'Nivel Alerta': alert.nivel_alerta.toUpperCase(),
    'Visto': alert.visto ? 'Sí' : 'No',
    'Fecha Alerta': format(new Date(alert.created_at), 'dd/MM/yyyy HH:mm', { locale: es })
  }))

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Alertas')

  ws['!cols'] = [
    { wch: 30 },
    { wch: 20 },
    { wch: 15 },
    { wch: 10 },
    { wch: 15 },
    { wch: 15 },
    { wch: 10 },
    { wch: 20 }
  ]

  const filename = `alertas_${format(new Date(), 'yyyyMMdd_HHmmss')}.xlsx`
  XLSX.writeFile(wb, filename)
}

// PDF Export for Catalog
export function exportCatalogPDF(catalogos: MedicationCatalog[]) {
  const doc = new jsPDF()

  doc.setFontSize(18)
  doc.setTextColor(127, 33, 65)
  doc.text('SIGIMED - Catálogo de Medicamentos', 14, 20)

  doc.setFontSize(10)
  doc.text(`Fecha: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: es })}`, 14, 28)
  doc.text(`Total en catálogo: ${catalogos.length}`, 14, 34)

  const tableData = catalogos.map(cat => [
    cat.nombre,
    cat.formula_activa,
    cat.categoria || 'Sin categoría',
    cat.is_active ? 'Activo' : 'Inactivo',
    format(new Date(cat.created_at), 'dd/MM/yyyy', { locale: es })
  ])

  autoTable(doc, {
    head: [['Medicamento', 'Fórmula Activa', 'Categoría', 'Estado', 'Fecha Creación']],
    body: tableData,
    startY: 40,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [127, 33, 65] }
  })

  const filename = `catalogo_${format(new Date(), 'yyyyMMdd_HHmmss')}.pdf`
  doc.save(filename)
}

// Excel Export for Catalog
export function exportCatalogExcel(catalogos: MedicationCatalog[]) {
  const data = catalogos.map(cat => ({
    'Medicamento': cat.nombre,
    'Fórmula Activa': cat.formula_activa,
    'Categoría': cat.categoria || 'Sin categoría',
    'Descripción': cat.descripcion || '',
    'Estado': cat.is_active ? 'Activo' : 'Inactivo',
    'Fecha Creación': format(new Date(cat.created_at), 'dd/MM/yyyy', { locale: es })
  }))

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Catálogo')

  ws['!cols'] = [
    { wch: 30 },
    { wch: 20 },
    { wch: 15 },
    { wch: 40 },
    { wch: 10 },
    { wch: 15 }
  ]

  const filename = `catalogo_${format(new Date(), 'yyyyMMdd_HHmmss')}.xlsx`
  XLSX.writeFile(wb, filename)
}
