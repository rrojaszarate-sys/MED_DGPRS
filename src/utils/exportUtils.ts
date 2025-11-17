import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import type { Batch, MedicationCatalog, Alert } from '../types'

// ============================================
// EXPORTACIÓN DE INVENTARIO (LOTES)
// ============================================

export function exportInventoryPDF(batches: Batch[], centerName: string) {
  const doc = new jsPDF()

  // Header
  doc.setFontSize(18)
  doc.text('Reporte de Inventario de Medicamentos', 14, 20)
  doc.setFontSize(11)
  doc.text(`Centro: ${centerName}`, 14, 28)
  doc.text(`Fecha: ${new Date().toLocaleDateString('es-MX')}`, 14, 34)
  doc.text(`Total de lotes: ${batches.length}`, 14, 40)

  // Table
  const tableData = batches.map(batch => [
    batch.medication?.nombre || 'N/A',
    batch.numero_lote,
    batch.cantidad_actual.toString(),
    batch.medication?.unidad_medida || 'unidades',
    new Date(batch.fecha_caducidad).toLocaleDateString('es-MX'),
    batch.estado,
    batch.supplier?.nombre || 'N/A'
  ])

  autoTable(doc, {
    startY: 45,
    head: [['Medicamento', 'Lote', 'Stock', 'Unidad', 'Caducidad', 'Estado', 'Proveedor']],
    body: tableData,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [59, 130, 246] }
  })

  // Footer
  const pageCount = (doc as any).internal.getNumberOfPages()
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    doc.setFontSize(9)
    doc.text(
      `Página ${i} de ${pageCount}`,
      doc.internal.pageSize.width / 2,
      doc.internal.pageSize.height - 10,
      { align: 'center' }
    )
  }

  doc.save(`Inventario_${centerName}_${new Date().toISOString().split('T')[0]}.pdf`)
}

export function exportInventoryExcel(batches: Batch[], centerName: string) {
  const data = batches.map(batch => ({
    'Medicamento': batch.medication?.nombre || 'N/A',
    'Categoría': batch.medication?.categoria || 'N/A',
    'Número de Lote': batch.numero_lote,
    'Cantidad Actual': batch.cantidad_actual,
    'Cantidad Inicial': batch.cantidad_inicial,
    'Unidad de Medida': batch.medication?.unidad_medida || 'unidades',
    'Fecha Fabricación': batch.fecha_fabricacion || 'N/A',
    'Fecha Caducidad': new Date(batch.fecha_caducidad).toLocaleDateString('es-MX'),
    'Fecha Ingreso': new Date(batch.fecha_ingreso).toLocaleDateString('es-MX'),
    'Estado': batch.estado,
    'Ubicación': batch.ubicacion_fisica || 'N/A',
    'Proveedor': batch.supplier?.nombre || 'N/A',
    'Stock Mínimo': batch.stock_minimo,
    'Stock Máximo': batch.stock_maximo || 'N/A',
    'Observaciones': batch.observaciones || ''
  }))

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Inventario')

  // Ajustar ancho de columnas
  const colWidths = [
    { wch: 30 }, // Medicamento
    { wch: 15 }, // Categoría
    { wch: 15 }, // Lote
    { wch: 10 }, // Cantidad Actual
    { wch: 10 }, // Cantidad Inicial
    { wch: 12 }, // Unidad
    { wch: 15 }, // Fecha Fab
    { wch: 15 }, // Fecha Cad
    { wch: 15 }, // Fecha Ingreso
    { wch: 12 }, // Estado
    { wch: 15 }, // Ubicación
    { wch: 25 }, // Proveedor
    { wch: 12 }, // Stock Min
    { wch: 12 }, // Stock Max
    { wch: 30 }  // Observaciones
  ]
  ws['!cols'] = colWidths

  XLSX.writeFile(wb, `Inventario_${centerName}_${new Date().toISOString().split('T')[0]}.xlsx`)
}

// ============================================
// EXPORTACIÓN DE MEDICAMENTOS (DEPRECATED - usar exportInventoryPDF)
// ============================================

export function exportMedicationsPDF() {
  console.warn('Usar exportInventoryPDF() en su lugar')
  alert('Por favor use la función de exportación desde la página de Inventario')
}

export function exportMedicationsExcel() {
  console.warn('Usar exportInventoryExcel() en su lugar')
  alert('Por favor use la función de exportación desde la página de Inventario')
}

// ============================================
// EXPORTACIÓN DE CATÁLOGO
// ============================================

export function exportCatalogPDF(catalogos: MedicationCatalog[]) {
  const doc = new jsPDF()

  // Header
  doc.setFontSize(18)
  doc.text('Catálogo de Medicamentos', 14, 20)
  doc.setFontSize(11)
  doc.text(`Fecha: ${new Date().toLocaleDateString('es-MX')}`, 14, 28)
  doc.text(`Total de medicamentos: ${catalogos.length}`, 14, 34)

  // Table
  const tableData = catalogos.map(cat => [
    cat.codigo_medicamento,
    cat.nombre_generico,
    cat.nombre_comercial || 'N/A',
    cat.principio_activo || 'N/A',
    cat.forma_farmaceutica || 'N/A',
    cat.concentracion || 'N/A',
    cat.categoria || 'N/A',
    cat.is_active ? 'Activo' : 'Inactivo'
  ])

  autoTable(doc, {
    startY: 40,
    head: [['Código', 'Nombre Genérico', 'Nombre Comercial', 'Principio Activo', 'Forma', 'Concentración', 'Categoría', 'Estado']],
    body: tableData,
    styles: { fontSize: 7 },
    headStyles: { fillColor: [59, 130, 246] },
    columnStyles: {
      0: { cellWidth: 20 },
      1: { cellWidth: 30 },
      2: { cellWidth: 25 }
    }
  })

  // Footer
  const pageCount = (doc as any).internal.getNumberOfPages()
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    doc.setFontSize(9)
    doc.text(
      `Página ${i} de ${pageCount}`,
      doc.internal.pageSize.width / 2,
      doc.internal.pageSize.height - 10,
      { align: 'center' }
    )
  }

  doc.save(`Catalogo_Medicamentos_${new Date().toISOString().split('T')[0]}.pdf`)
}

export function exportCatalogExcel(catalogos: MedicationCatalog[]) {
  const data = catalogos.map(cat => ({
    'Código': cat.codigo_medicamento,
    'Nombre Genérico': cat.nombre_generico,
    'Nombre Comercial': cat.nombre_comercial || '',
    'Principio Activo': cat.principio_activo || '',
    'Forma Farmacéutica': cat.forma_farmaceutica || '',
    'Vía Administración': cat.via_administracion || '',
    'Concentración': cat.concentracion || '',
    'Unidad de Medida': cat.unidad_medida || '',
    'Categoría': cat.categoria || '',
    'Requiere Receta': cat.requiere_receta ? 'Sí' : 'No',
    'Controlado': cat.controlado ? 'Sí' : 'No',
    'Temperatura Almacenamiento': cat.temperatura_almacenamiento || '',
    'Estado': cat.is_active ? 'Activo' : 'Inactivo',
    'Observaciones': cat.observaciones || ''
  }))

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Catálogo')

  // Ajustar ancho de columnas
  const colWidths = [
    { wch: 15 }, // Código
    { wch: 30 }, // Nombre Genérico
    { wch: 25 }, // Nombre Comercial
    { wch: 25 }, // Principio Activo
    { wch: 20 }, // Forma
    { wch: 20 }, // Vía
    { wch: 15 }, // Concentración
    { wch: 12 }, // Unidad
    { wch: 15 }, // Categoría
    { wch: 12 }, // Requiere Receta
    { wch: 12 }, // Controlado
    { wch: 20 }, // Temperatura
    { wch: 10 }, // Estado
    { wch: 30 }  // Observaciones
  ]
  ws['!cols'] = colWidths

  XLSX.writeFile(wb, `Catalogo_Medicamentos_${new Date().toISOString().split('T')[0]}.xlsx`)
}

// ============================================
// EXPORTACIÓN DE ALERTAS
// ============================================

export function exportAlertsPDF(alertas: Alert[], centerName: string) {
  const doc = new jsPDF()

  // Header
  doc.setFontSize(18)
  doc.text('Reporte de Alertas de Medicamentos', 14, 20)
  doc.setFontSize(11)
  doc.text(`Centro: ${centerName}`, 14, 28)
  doc.text(`Fecha: ${new Date().toLocaleDateString('es-MX')}`, 14, 34)
  doc.text(`Total de alertas: ${alertas.length}`, 14, 40)

  // Resumen por nivel
  const criticas = alertas.filter(a => a.nivel_alerta === 'critico').length
  const urgentes = alertas.filter(a => a.nivel_alerta === 'urgente').length
  const preventivas = alertas.filter(a => a.nivel_alerta === 'preventivo').length

  doc.setFontSize(10)
  doc.setTextColor(220, 38, 38) // Red
  doc.text(`Críticas: ${criticas}`, 14, 48)
  doc.setTextColor(251, 146, 60) // Orange
  doc.text(`Urgentes: ${urgentes}`, 50, 48)
  doc.setTextColor(234, 179, 8) // Yellow
  doc.text(`Preventivas: ${preventivas}`, 90, 48)
  doc.setTextColor(0, 0, 0) // Reset to black

  // Table
  const tableData = alertas.map(alerta => [
    alerta.medicamento?.nombre || 'N/A',
    alerta.nivel_alerta.toUpperCase(),
    alerta.dias_restantes.toString() + ' días',
    alerta.visto ? 'Sí' : 'No',
    alerta.resuelta ? 'Sí' : 'No',
    new Date(alerta.created_at).toLocaleDateString('es-MX')
  ])

  autoTable(doc, {
    startY: 55,
    head: [['Medicamento', 'Nivel', 'Días Restantes', 'Visto', 'Resuelta', 'Fecha Creación']],
    body: tableData,
    styles: { fontSize: 9 },
    headStyles: { fillColor: [59, 130, 246] },
    didParseCell: function (data) {
      // Colorear según nivel de alerta
      if (data.section === 'body' && data.column.index === 1) {
        const nivel = data.cell.raw as string
        if (nivel === 'CRITICO') {
          data.cell.styles.textColor = [220, 38, 38]
          data.cell.styles.fontStyle = 'bold'
        } else if (nivel === 'URGENTE') {
          data.cell.styles.textColor = [251, 146, 60]
          data.cell.styles.fontStyle = 'bold'
        } else if (nivel === 'PREVENTIVO') {
          data.cell.styles.textColor = [234, 179, 8]
        }
      }
    }
  })

  // Footer
  const pageCount = (doc as any).internal.getNumberOfPages()
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    doc.setFontSize(9)
    doc.text(
      `Página ${i} de ${pageCount}`,
      doc.internal.pageSize.width / 2,
      doc.internal.pageSize.height - 10,
      { align: 'center' }
    )
  }

  doc.save(`Alertas_${centerName}_${new Date().toISOString().split('T')[0]}.pdf`)
}

export function exportAlertsExcel(alertas: Alert[], centerName: string) {
  const data = alertas.map(alerta => ({
    'Medicamento': alerta.medicamento?.nombre || 'N/A',
    'Categoría': alerta.medicamento?.categoria || 'N/A',
    'Nivel de Alerta': alerta.nivel_alerta.toUpperCase(),
    'Días Restantes': alerta.dias_restantes,
    'Visto': alerta.visto ? 'Sí' : 'No',
    'Resuelta': alerta.resuelta ? 'Sí' : 'No',
    'Fecha Creación': new Date(alerta.created_at).toLocaleDateString('es-MX'),
    'Centro': centerName
  }))

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Alertas')

  // Ajustar ancho de columnas
  const colWidths = [
    { wch: 30 }, // Medicamento
    { wch: 15 }, // Categoría
    { wch: 15 }, // Nivel
    { wch: 15 }, // Días Restantes
    { wch: 10 }, // Visto
    { wch: 10 }, // Resuelta
    { wch: 15 }, // Fecha
    { wch: 30 }  // Centro
  ]
  ws['!cols'] = colWidths

  XLSX.writeFile(wb, `Alertas_${centerName}_${new Date().toISOString().split('T')[0]}.xlsx`)
}

// ============================================
// EXPORTACIÓN DE REPORTES
// ============================================

export function exportReportPDF(data: any[], reportType: string, centerName: string) {
  const doc = new jsPDF()

  // Header
  doc.setFontSize(18)
  doc.text(`Reporte: ${reportType}`, 14, 20)
  doc.setFontSize(11)
  doc.text(`Centro: ${centerName}`, 14, 28)
  doc.text(`Fecha: ${new Date().toLocaleDateString('es-MX')}`, 14, 34)
  doc.text(`Registros: ${data.length}`, 14, 40)

  if (data.length === 0) {
    doc.text('No hay datos para mostrar', 14, 50)
  } else {
    // Convertir datos a tabla
    const headers = Object.keys(data[0])
    const tableData = data.map(row => headers.map(header => String(row[header] || 'N/A')))

    autoTable(doc, {
      startY: 45,
      head: [headers],
      body: tableData,
      styles: { fontSize: 8 },
      headStyles: { fillColor: [59, 130, 246] }
    })
  }

  // Footer
  const pageCount = (doc as any).internal.getNumberOfPages()
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    doc.setFontSize(9)
    doc.text(
      `Página ${i} de ${pageCount}`,
      doc.internal.pageSize.width / 2,
      doc.internal.pageSize.height - 10,
      { align: 'center' }
    )
  }

  doc.save(`Reporte_${reportType}_${new Date().toISOString().split('T')[0]}.pdf`)
}

export function exportReportExcel(data: any[], reportType: string, centerName: string) {
  if (data.length === 0) {
    alert('No hay datos para exportar')
    return
  }

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, reportType)

  // Auto-ajustar ancho de columnas basado en contenido
  const maxWidth = 50
  const colWidths = Object.keys(data[0]).map(key => {
    const maxLen = Math.max(
      key.length,
      ...data.map(row => String(row[key] || '').length)
    )
    return { wch: Math.min(maxLen + 2, maxWidth) }
  })
  ws['!cols'] = colWidths

  XLSX.writeFile(wb, `Reporte_${reportType}_${centerName}_${new Date().toISOString().split('T')[0]}.xlsx`)
}
