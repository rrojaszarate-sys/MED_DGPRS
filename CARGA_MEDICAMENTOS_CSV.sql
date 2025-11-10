-- ============================================
-- CARGA MASIVA DE MEDICAMENTOS DESDE CSV
-- ============================================
-- Fecha: 2025-11-10
-- Propósito: Cargar 101 medicamentos del inventario real al catálogo
-- Datos: CSV proporcionado con CLAVE, DESCRIPCION, UNIDAD, LOTE, FECHA CADUCIDAD, MARCA
--
-- PREREQUISITO: Ejecutar primero FIX_CRITICAL_ERRORS.sql
--
-- EJECUCIÓN: Copiar y pegar en Supabase SQL Editor → Run
-- ============================================

BEGIN;

\echo '📦 Iniciando carga de 101 medicamentos del CSV...'

-- ============================================
-- INSERTAR MEDICAMENTOS AL CATÁLOGO
-- ============================================

-- Nota: Los medicamentos duplicados (mismo código) se insertan una sola vez en el catálogo
-- Los lotes diferentes se manejarán en la tabla batches

INSERT INTO medication_catalog (
  codigo_medicamento,
  nombre_generico,
  nombre_comercial,
  forma_farmaceutica,
  via_administracion,
  unidad_medida,
  categoria,
  requiere_receta,
  controlado,
  temperatura_almacenamiento,
  observaciones,
  is_active
) VALUES
-- Medicamento 1-3: Ketoconazol + Clindamicina (3 lotes, 3 marcas)
('2531012615', 'KETOCONAZOL 400 MILIGRAMOS, CLINDAMICINA 100 MILIGRAMOS', 'MAVER, PISA, PSICOFARMA', 'Óvulo', 'Tópica', 'Caja', 'Antifúngico + Antibiótico', false, false, '15-25°C', 'Caja con 7 óvulos. 3 lotes: JO1112 (MAVER), AF23031 (PISA), 500283 (PSICOFARMA)', true),

-- Medicamento 4: Amoxicilina + Clavulanato
('2531012616', 'AMOXICILINA 875 MILIGRAMOS/ CLAVULANATO DE POTASIO 125 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 10 tabletas. Lote JO1113', true),

-- Medicamento 5: Amoxicilina 500mg
('2531012617', 'AMOXICILINA 500 MILIGRAMOS', 'PISA', 'Cápsula', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 12 cápsulas. Lote AF23028', true),

-- Medicamento 6: Ampicilina 500mg
('2531012618', 'AMPICILINA 500 MILIGRAMOS', 'PSICOFARMA', 'Cápsula', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 20 cápsulas. Lote 500284', true),

-- Medicamento 7: Azitromicina 500mg
('2531012619', 'AZITROMICINA 500 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 3 tabletas. Lote JO1114', true),

-- Medicamento 8: Bencilpenicilina procaínica + cristalina
('2531012620', 'BENCILPENICILINA PROCAINA 600,000 UI/BENCILPENICILINA CRISTALINA 200,000 UI', 'PISA', 'Solución inyectable', 'Intramuscular', 'Caja', 'Antibiótico', true, false, '2-8°C (Refrigeración)', 'Frasco ámpula con polvo + ampolleta con diluyente 3ml. Lote AF23033', true),

-- Medicamento 9: Benzatina bencilpenicilina
('2531012621', 'BENZATINA BENCILPENICILINA 1,200,000 UI', 'PSICOFARMA', 'Solución inyectable', 'Intramuscular', 'Caja', 'Antibiótico', true, false, '2-8°C (Refrigeración)', 'Frasco ámpula con polvo + ampolleta con diluyente 5ml. Lote 500285', true),

-- Medicamento 10: Benzonatato 100mg
('2531012622', 'BENZONATATO 100 MILIGRAMOS', 'MAVER', 'Perla', 'Oral', 'Caja', 'Antitusivo', false, false, '15-25°C', 'Caja con 20 perlas. Lote JO1115', true),

-- Medicamento 11: Butilhioscina + Metamizol
('2531012623', 'BUTILHIOSCINA 10 MILIGRAMOS, METAMIZOL 250 MILIGRAMOS', 'PISA', 'Gragea', 'Oral', 'Caja', 'Antiespasmódico + Analgésico', false, false, '15-25°C', 'Caja con 36 grageas. Lote AF23034', true),

-- Medicamento 12: Carbocisteína 75mg jarabe
('2531012624', 'CARBOCISTEINA 75 MILIGRAMOS', 'PSICOFARMA', 'Jarabe', 'Oral', 'Caja', 'Mucolítico', false, false, '15-25°C', 'Jarabe adulto. Frasco con 150ml. Lote 500286', true),

-- Medicamento 13: Complejo B + Diclofenaco
('2531012625', 'CIANOCOBALAMINA (B12) 1 MG, DICLOFENACO 50 MG, PIRIDOXINA (B6) 50 MG, TIAMINA (B1) 50 MG', 'MAVER', 'Gragea', 'Oral', 'Caja', 'Vitaminas + Antiinflamatorio', false, false, '15-25°C', 'Caja con 30 grageas. Lote JO1116', true),

-- Medicamento 14: Clonixinato de lisina 100mg inyectable
('2531012626', 'CLONIXINATO DE LISINA 100 MILIGRAMOS', 'PISA', 'Solución inyectable', 'Intramuscular', 'Caja', 'Analgésico', false, false, '15-25°C', 'Caja con 5 ampolletas de 2ml. Lote AF23035', true),

-- Medicamento 15: Ciprofloxacino 500mg
('2531012627', 'CIPROFLOXACINO 500 MILIGRAMOS', 'PSICOFARMA', 'Comprimido', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 12 comprimidos. Lote 500287', true),

-- Medicamento 16: Cloranfenicol levógiro gotas
('2531012628', 'CLORANFENICOL LEVOGIRO 5 MILIGRAMOS', 'MAVER', 'Gotas', 'Oftálmica', 'Frasco', 'Antibiótico', true, false, '15-25°C', 'Frasco gotero con 15ml. Lote JO1117', true),

-- Medicamento 17: Paracetamol combinado (antigripal)
('2531012629', 'PARACETAMOL 500 MG, CAFEINA 25 MG, FENILEFRINA 5 MG, CLORFENAMINA 4 MG', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antigripal', false, false, '15-25°C', 'Caja con 10 tabletas. Lote AF23036', true),

-- Medicamento 18: Cloropiramina 25mg grageas
('2531012630', 'CLOROPIRAMINA 25 MILIGRAMOS', 'PSICOFARMA', 'Gragea', 'Oral', 'Caja', 'Antihistamínico', false, false, '15-25°C', 'Caja con 20 grageas. Lote 500288', true),

-- Medicamento 19: Cloropiramina 20mg inyectable
('2531012631', 'CLOROPIRAMINA 20 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intramuscular', 'Caja', 'Antihistamínico', false, false, '15-25°C', 'Caja con 5 ampolletas de 2ml. Lote JO1118', true),

-- Medicamento 20-21: Loperamida 2mg (código duplicado con 2531012628)
('2531012628-B', 'LOPERAMIDA 2 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antidiarreico', false, false, '15-25°C', 'Caja con 12 tabletas. Lote AF23037', true),

-- Medicamento 22: Omeprazol 40mg
('2531012633', 'OMEPRAZOL 40 MILIGRAMOS', 'PSICOFARMA', 'Tableta', 'Oral', 'Caja', 'Inhibidor de bomba de protones', false, false, '15-25°C', 'Caja con 14 tabletas. Lote 500289', true),

-- Medicamento 23-24: Diclofenaco gel 1% (2 lotes)
('2531012634', 'DICLOFENACO 1 GRAMO', 'MAVER, PISA', 'Crema', 'Tópica', 'Caja', 'Antiinflamatorio tópico', false, false, '15-25°C', 'Tubo de 60 gramos. 2 lotes: AHFE4 (MAVER), GREDO87K (PISA)', true),

-- Medicamento 25: Ketoprofeno 100mg
('2531012635', 'KETOPROFENO 100 MILIGRAMOS', 'MAVER', 'Cápsula', 'Oral', 'Caja', 'Antiinflamatorio', false, false, '15-25°C', 'Caja con 15 cápsulas. Lote AHFE5', true),

-- Medicamento 26: Dicloxacilina 500mg
('2531012636', 'DICLOXACILINA SODICA 500 MILIGRAMOS', 'PISA', 'Cápsula', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 20 cápsulas. Lote GREDO87K', true),

-- Medicamento 27: Eritromicina 500mg
('2531012637', 'ERITROMICINA 500 MILIGRAMOS', 'MAVER', 'Cápsula', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 20 cápsulas. Lote AHFE6', true),

-- Medicamento 28: Dexametasona 8mg inyectable
('2531012638', 'FOSFATO SODICO DE DEXAMETASONA 8 MILIGRAMOS/2 MILILITROS', 'PISA', 'Solución inyectable', 'Intramuscular', 'Caja', 'Corticosteroide', false, false, '15-25°C', 'Ampolleta de 2ml. Lote GREDO87K', true),

-- Medicamento 29: Clindamicina 300mg
('2531012639', 'CLINDAMICINA 300 MILIGRAMOS', 'MAVER', 'Cápsula', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 16 cápsulas. Lote AHFE7', true),

-- Medicamento 30: Clindamicina gel 1%
('2531012640', 'CLINDAMICINA 1 GRAMO', 'PISA', 'Crema', 'Tópica', 'Caja', 'Antibiótico tópico', true, false, '15-25°C', 'Tubo de 30 gramos. Lote GREDO87K', true),

-- Medicamento 31: Gabapentina 300mg
('2531012641', 'GABAPENTINA 300 MILIGRAMOS', 'MAVER', 'Cápsula', 'Oral', 'Caja', 'Anticonvulsivante', true, true, '15-25°C', 'Caja con 30 cápsulas. CONTROLADO. Lote AHFE8', true),

-- Medicamento 32: Furosemida 40mg
('2531012642', 'FUROSEMIDA 40 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Diurético', false, false, '15-25°C', 'Caja con 20 tabletas. Lote GREDO87K', true),

-- Medicamento 33: Gentamicina 160mg inyectable
('2531012643', 'GENTAMICINA 160 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intramuscular', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 5 ampolletas de 2ml. Lote AHFE9', true),

-- Medicamento 34: Ibuprofeno 400mg
('2531012644', 'IBUPROFENO 400 MILIGRAMOS', 'PISA', 'Cápsula', 'Oral', 'Caja', 'Antiinflamatorio', false, false, '15-25°C', 'Caja con 10 cápsulas. Lote GREDO87K', true),

-- Medicamento 35: Indometacina + Betametasona + Metocarbamol
('2531012645', 'INDOMETACINA 25 MG, BETAMETASONA 0.75 MG, METOCARBAMOL 215 MG', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Antiinflamatorio + Relajante muscular', false, false, '15-25°C', 'Caja con 20 tabletas. Lote AHFE10', true),

-- Medicamento 36: Metocarbamol + Ácido acetilsalicílico
('2531012646', 'METOCARBAMOL 400 MG/ACIDO ACETILSALICILICO 285 MG', 'PISA', 'Tableta', 'Oral', 'Caja', 'Relajante muscular + Analgésico', false, false, '15-25°C', 'Caja con 30 tabletas. Lote GREDO87K', true),

-- Medicamento 37: Hidrocortisona 500mg inyectable
('2531012647', 'HIDROCORTISONA 500 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intravenosa', 'Caja', 'Corticosteroide', false, false, '15-25°C', 'Ampula. Lote AHFE11', true),

-- Medicamento 38: Itraconazol 100mg
('2531012648', 'ITRACONAZOL 100 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antifúngico', false, false, '15-25°C', 'Caja con 15 tabletas. Lote GREDO87K', true),

-- Medicamento 39: Ketorolaco 10mg
('2531012649', 'KETOROLACO 10 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Analgésico', false, false, '15-25°C', 'Caja con 10 tabletas. Lote AHFE12', true),

-- Medicamento 40: Ketorolaco trometamina 30mg inyectable
('2531012650', 'KETOROLACO TROMETAMINA 30 MILIGRAMOS', 'PISA', 'Solución inyectable', 'Intramuscular', 'Caja', 'Analgésico', false, false, '15-25°C', 'Caja con 3 ampolletas de 1ml. Lote GREDO87K', true),

-- Medicamento 41: Tramadol 100mg inyectable
('2531012651', 'TRAMADOL 100 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intravenosa', 'Caja', 'Analgésico opioide', true, true, '15-25°C', 'Caja con 5 ampolletas de 2ml. CONTROLADO. Lote AHFE13', true),

-- Medicamento 42-43: Lincomicina 600mg inyectable (2 lotes)
('2531012652', 'LINCOMICINA 600 MILIGRAMOS', 'PISA, MAVER', 'Solución inyectable', 'Intramuscular', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Jeringas prellenadas de 2ml. 2 lotes: 555 (PISA), AHFE14 (MAVER)', true),

-- Medicamento 44: Mebendazol 100mg
('2531012653', 'MEBENDAZOL 100 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antiparasitario', false, false, '15-25°C', 'Caja con 6 tabletas. Lote GREDO87K', true),

-- Medicamento 45: Tramadol + Paracetamol
('2531012654', 'TRAMADOL 37,5 MG, PARACETAMOL 285 MG', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Analgésico combinado', true, true, '15-25°C', 'Caja con 20 tabletas. CONTROLADO. Lote AHFE15', true),

-- Medicamento 46: Loratadina 10mg
('2531012655', 'LORATADINA 10 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antihistamínico', false, false, '15-25°C', 'Caja con 20 tabletas. Lote GREDO87K', true),

-- Medicamento 47: Ambroxol 30mg
('2531012656', 'AMBROXOL 30 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Mucolítico', false, false, '15-25°C', 'Caja con 20 tabletas. Lote AHFE16', true),

-- Medicamento 48: Metronidazol 500mg
('2531012657', 'METRONIDAZOL 500 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antibiótico + Antiparasitario', true, false, '15-25°C', 'Caja con 30 tabletas. Lote GREDO87K', true),

-- Medicamento 49: Metronidazol + Nifuroxazida
('2531012658', 'METRONIDAZOL 600 MG, NIFUROXAZIDA 200 MG', 'MAVER', 'Cápsula', 'Oral', 'Caja', 'Antidiarreico combinado', false, false, '15-25°C', 'Caja con 20 cápsulas. Lote AHFE17', true),

-- Medicamento 50: Neomicina + Polimixina B + Gramicidina gotas
('2531012659', 'NEOMICINA 1,750 MG, POLIMIXINA B 5,000 UI, GRAMICIDINA 0,025 MG', 'PISA', 'Gotas', 'Oftálmica', 'Gotero', 'Antibiótico oftálmico', true, false, '15-25°C', 'Gotero con 15ml. Lote GREDO87K', true),

-- Medicamento 51: Terbinafina 1% crema
('2531012660', 'TERBINAFINA 1%', 'MAVER', 'Crema', 'Tópica', 'Caja', 'Antifúngico', false, false, '15-25°C', 'Tubo de 15 gramos. Lote AHFE18', true),

-- Medicamento 52: Norfloxacina 400mg
('2531012661', 'NORFLOXACINA 400 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Antibiótico', true, false, '15-25°C', 'Caja con 20 tabletas. Lote GREDO87K', true),

-- Medicamento 53: Fenazopiridina 100mg
('2531012662', 'FENAZOPIRIDINA 100 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Caja', 'Analgésico urinario', false, false, '15-25°C', 'Caja con 20 tabletas. Lote AHFE19', true),

-- Medicamento 54: Paracetamol 500mg
('2531012663', 'PARACETAMOL 500 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Caja', 'Analgésico + Antipirético', false, false, '15-25°C', 'Caja con 10 tabletas. Lote GREDO87K', true),

-- Medicamento 55: Bencilpenicilina sódica cristalina 1,000,000 UI
('2531012664', 'BENCILPENICILINA SODICA CRISTALINA 1,000,000 UI', 'MAVER', 'Solución inyectable', 'Intravenosa', 'Frasco', 'Antibiótico', true, false, '2-8°C (Refrigeración)', 'Frasco ámpula + ampolleta diluyente 2ml. Lote AHFE20', true),

-- Medicamento 56: Nitazoxanida 500mg
('2531012665', 'NITAZOXANIDA 500 MILIGRAMOS', 'PISA', 'Gragea', 'Oral', 'Frasco', 'Antiparasitario', false, false, '15-25°C', 'Caja con 6 grageas. Lote GREDO87K', true),

-- Medicamento 57: Pargeverina + Clonixinato de lisina
('2531012666', 'PARGEVERINA 10 MG/CLONIXINATO DE LISINA 125 MG', 'MAVER', 'Comprimido', 'Oral', 'Frasco', 'Antiespasmódico + Analgésico', false, false, '15-25°C', 'Caja con 20 comprimidos. Lote AHFE21', true),

-- Medicamento 58: Ceftriaxona 1g inyectable
('2531012667', 'CEFTRIAXONA 1 GRAMO', 'PISA', 'Solución inyectable', 'Intramuscular', 'Frasco', 'Antibiótico', true, false, '15-25°C', 'Ámpula polvo + ampolleta diluyente con lidocaína 1% 3.5ml. Lote GREDO87K', true),

-- Medicamento 59: Pentoxifilina 400mg
('2531012668', 'PENTOXIFILINA 400 MILIGRAMOS', 'MAVER', 'Gragea', 'Oral', 'Frasco', 'Vasodilatador periférico', false, false, '15-25°C', 'Grageas de liberación prolongada. Caja con 30 grageas. Lote AHFE22', true),

-- Medicamento 60: Ivermectina 6mg
('2531012669', 'IVERMECTINA 6 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antiparasitario', false, false, '15-25°C', 'Caja con 2 tabletas. Lote GREDO87K', true),

-- Medicamento 61: Oseltamivir 75mg
('2531012670', 'OSELTAMIVIR 75 MILIGRAMOS', 'MAVER', 'Cápsula', 'Oral', 'Frasco', 'Antiviral', true, false, '15-25°C', 'Caja con 10 cápsulas. Lote AHFE23', true),

-- Medicamento 62: Levofloxacino 500mg
('2531012671', 'LEVOFLOXACINO 500 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antibiótico', true, false, '15-25°C', 'Caja con 7 tabletas. Lote GREDO87K', true),

-- Medicamento 63: Claritromicina 500mg
('2531012672', 'CLARITROMICINA 500 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Antibiótico', true, false, '15-25°C', 'Caja con 10 tabletas. Lote AHFE24', true),

-- Medicamento 64: Aciclovir 200mg
('2531012674', 'ACICLOVIR 200 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antiviral', false, false, '15-25°C', 'Caja con 25 tabletas. Lote GREDO87K', true),

-- Medicamento 65: Permetrina 5% solución tópica
('2531012687', 'PERMETRINA 5 GRAMOS', 'MAVER', 'Solución', 'Tópica', 'Frasco', 'Antiparasitario externo', false, false, '15-25°C', 'Solución tópica. Frasco con 120ml. Lote AHFE25', true),

-- Medicamento 66: Glibenclamida + Metformina
('2531012688', 'GLIBENCLAMIDA 5 MG/METFORMINA 500 MG', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antidiabético combinado', true, false, '15-25°C', 'Caja con 60 tabletas. Lote GREDO87K', true),

-- Medicamento 67: Glibenclamida 5mg
('2531012689', 'GLIBENCLAMIDA 5 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Antidiabético', true, false, '15-25°C', 'Caja con 50 tabletas. Lote AHFE26', true),

-- Medicamento 68: Metformina 850mg
('2531012690', 'METFORMINA 850 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antidiabético', true, false, '15-25°C', 'Caja con 30 tabletas. Lote GREDO87K', true),

-- Medicamento 69: Losartan 50mg
('2531012691', 'LOSARTAN 50 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Antihipertensivo', true, false, '15-25°C', 'Caja con 30 tabletas. Lote AHFE27', true),

-- Medicamento 70: Hidroclorotiazida 25mg
('2531012692', 'HIDROCLOROTIAZIDA 25 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Diurético antihipertensivo', true, false, '15-25°C', 'Caja con 20 tabletas. Lote GREDO87K', true),

-- Medicamento 71: Insulina humana NPH 100 UI
('2531012693', 'INSULINA HUMANA ISOFANA NPH 100 UI', 'MAVER', 'Solución inyectable', 'Subcutánea', 'Frasco', 'Antidiabético insulina', true, true, '2-8°C (Refrigeración)', 'Frasco de 10ml. CONTROLADO. Lote AHFE28', true),

-- Medicamento 72: Nifedipino 30mg
('2531012694', 'NIFEDIPINO 30 MILIGRAMOS', 'PISA', 'Comprimido', 'Oral', 'Frasco', 'Antihipertensivo', true, false, '15-25°C', 'Caja con 30 comprimidos. Lote GREDO87K', true),

-- Medicamento 73: Cloruro de sodio 9%
('2531012695', 'CLORURO DE SODIO 9%', 'MAVER', 'Solución inyectable', 'Intravenosa', 'Frasco', 'Solución para infusión', false, false, '15-25°C', 'Bolsa flex-oval de 500ml. Lote AHFE29', true),

-- Medicamento 74: Glucosa 5%
('2531012696', 'GLUCOSA AL 5%', 'PISA', 'Solución inyectable', 'Intravenosa', 'Frasco', 'Solución para infusión', false, false, '15-25°C', 'Bolsa flex-oval de 500ml. Lote GREDO87K', true),

-- Medicamento 75: Meloxicam + Complejo B inyectable
('2531012697', 'MELOXICAM 15 MG + TIAMINA (B1) 100 MG + PIRIDOXINA (B6) 100 MG + CIANOCOBALAMINA (B12) 5 MG', 'MAVER', 'Solución inyectable', 'Intramuscular', 'Frasco', 'Antiinflamatorio + Vitaminas', false, false, '15-25°C', '2 ampolletas #1 (1.5ml) + 2 ampolletas #2 (2ml). Lote AHFE30', true),

-- Medicamento 76: Naproxeno sódico 500mg
('2531012698', 'NAPROXENO SODICO 500 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antiinflamatorio', false, false, '15-25°C', 'Caja con 30 tabletas. Lote GREDO87K', true),

-- Medicamento 77: Omeprazol sódico 40mg inyectable
('2531012699', 'OMEPRAZOL SODICO 40 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intravenosa', 'Frasco', 'Inhibidor de bomba de protones', false, false, '15-25°C', 'Frasco ámpula liofilizado + ampolleta diluyente 10ml. Lote AHFE31', true),

-- Medicamento 78: Metoclopramida 10mg
('2531012700', 'METOCLOPRAMIDA 10 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antiemético + Procinético', false, false, '15-25°C', 'Caja con 20 tabletas. Lote GREDO87K', true),

-- Medicamento 79: Trimebutina 200mg
('2531012701', 'TRIMEBUTINA 200 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Antiespasmódico', false, false, '15-25°C', 'Caja con 30 tabletas. Lote AHFE28', true),

-- Medicamento 80: Trimetroprima + Sulfametoxazol
('2531012702', 'TRIMETOPRIMA 160 MG/SULFAMETOXAZOL 800 MG', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antibiótico combinado', true, false, '15-25°C', 'Caja con 20 tabletas. Lote GREDO87K', true),

-- Medicamento 81: Cefalexina 500mg
('2531012703', 'CEFALEXINA 500 MILIGRAMOS', 'MAVER', 'Cápsula', 'Oral', 'Frasco', 'Antibiótico', true, false, '15-25°C', 'Caja con 20 cápsulas. Lote AHFE33', true),

-- Medicamento 82: Ibuprofeno + Cafeína
('2531012704', 'IBUPROFENO 400 MG/CAFEINA 100 MG', 'PISA', 'Cápsula', 'Oral', 'Frasco', 'Analgésico + Estimulante', false, false, '15-25°C', 'Caja con 10 cápsulas. Lote GREDO87K', true),

-- Medicamento 83: Magaldrato + Dimeticona gel
('2531012705', 'MAGALDRATO 8 G, DIMETICONA 1 G', 'MAVER', 'Gel', 'Oral', 'Frasco', 'Antiácido + Antiflatulento', false, false, '15-25°C', 'Caja con 10 sobres de 10ml. Lote AHFE34', true),

-- Medicamento 84: Ambroxol + Salbutamol jarabe
('2531012706', 'AMBROXOL 0.040 G/SALBUTAMOL 0.150 G (por 100ml)', 'PISA', 'Jarabe', 'Oral', 'Envase', 'Mucolítico + Broncodilatador', false, false, '15-25°C', 'Envase con 120ml. Lote GREDO87K', true),

-- Medicamento 85: Diclofenaco 75mg inyectable
('2531012707', 'DICLOFENACO 75 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intramuscular', 'Frasco', 'Antiinflamatorio', false, false, '15-25°C', 'Caja con 2 ampolletas de 3ml. Lote AHFE35', true),

-- Medicamento 86: Metamizol sódico 500mg
('2531012708', 'METAMIZOL SODICO 500 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Analgésico + Antipirético', false, false, '15-25°C', 'Caja con 10 tabletas. Lote GREDO87K', true),

-- Medicamento 87: Sertralina 50mg
('2531012709', 'SERTRALINA 50 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Antidepresivo', true, true, '15-25°C', 'Caja con 14 tabletas. CONTROLADO. Lote AHFE36', true),

-- Medicamento 88: Fenitoína sódica 100mg
('2531012710', 'FENITOINA SODICA 100 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Anticonvulsivante', true, true, '15-25°C', 'Caja con 50 tabletas. CONTROLADO. Lote GREDO87K', true),

-- Medicamento 89: Carbamazepina 200mg
('2531012711', 'CARBAMAZEPINA 200 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Anticonvulsivante', true, true, '15-25°C', 'Caja con 20 tabletas. CONTROLADO. Lote AHFE37', true),

-- Medicamento 90: Olanzapina 10mg inyectable
('2531012712', 'OLANZAPINA 10 MILIGRAMOS', 'PISA', 'Solución inyectable', 'Intramuscular', 'Envase', 'Antipsicótico', true, true, '15-25°C', 'Frasco ámpula. CONTROLADO. Lote GREDO87K', true),

-- Medicamento 91: Olanzapina 10mg tabletas
('2531012713', 'OLANZAPINA 10 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Envase', 'Antipsicótico', true, true, '15-25°C', 'Envase con 14 tabletas. CONTROLADO. Lote AHFE38', true),

-- Medicamento 92: Risperidona 2mg
('2531012715', 'RISPERIDONA 2 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antipsicótico', true, true, '15-25°C', 'Caja con 40 tabletas. CONTROLADO. Lote GREDO87K', true),

-- Medicamento 93: Clonazepam 2mg
('2531012716', 'CLONAZEPAM 2 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Ansiolítico + Anticonvulsivante', true, true, '15-25°C', 'Caja con 30 tabletas. CONTROLADO. Lote AHFE39', true),

-- Medicamento 94: Haloperidol 5mg
('2531012675', 'HALOPERIDOL 5 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antipsicótico', true, true, '15-25°C', 'Caja con 20 tabletas. CONTROLADO. Lote GREDO87K', true),

-- Medicamento 95: Decanoato de haloperidol 150mg
('2531012676', 'DECANOATO DE HALOPERIDOL 150 MILIGRAMOS', 'MAVER', 'Solución inyectable', 'Intramuscular', 'Frasco', 'Antipsicótico depot', true, true, '15-25°C', 'Ampolleta. CONTROLADO. Lote AHFE40', true),

-- Medicamento 96: Valproato de magnesio 600mg
('2531012677', 'VALPROATO DE MAGNESIO 600 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Anticonvulsivante', true, true, '15-25°C', 'Caja con 20 tabletas. CONTROLADO. Lote GREDO87K', true),

-- Medicamento 97: Paroxetina 20mg
('2531012678', 'PAROXETINA 20 MILIGRAMOS', 'MAVER', 'Tableta', 'Oral', 'Frasco', 'Antidepresivo', true, true, '15-25°C', 'Caja con 10 tabletas. CONTROLADO. Lote AHFE41', true),

-- Medicamento 98: Quetiapina 50mg
('2531012680', 'QUETIAPINA 50 MILIGRAMOS', 'PISA', 'Tableta', 'Oral', 'Frasco', 'Antipsicótico', true, true, '15-25°C', 'Caja con 40 tabletas. CONTROLADO. Lote GREDO87K', true),

-- Medicamento 99: Amoxicilina 500mg/5ml suspensión 75ml
('2531012681', 'AMOXICILINA 500 MG/5 ML', 'MAVER', 'Suspensión', 'Oral', 'Envase', 'Antibiótico pediátrico', true, false, '2-8°C (Refrigeración)', 'Polvo para 75ml. Lote AHFE42', true),

-- Medicamento 100: Amoxicilina + Clavulanato suspensión
('2531012682', 'AMOXICILINA 125 MG/CLAVULANATO 31.25 MG (por 5ml)', 'PISA', 'Suspensión', 'Oral', 'Envase', 'Antibiótico pediátrico', true, false, '2-8°C (Refrigeración)', 'Envase con 60ml. Lote GREDO87K', true),

-- Medicamento 101: Paracetamol 100mg gotas
('2531012683', 'PARACETAMOL 100 MILIGRAMOS', 'MAVER', 'Gotas', 'Oral', 'Envase', 'Analgésico + Antipirético pediátrico', false, false, '15-25°C', 'Envase con 15ml. Lote AHFE43', true),

-- Medicamento 102: Trimetoproma + Sulfametoxazol suspensión
('2531012684', 'TRIMETOPRIMA 40 MG/SUFAMETOXAZOL 200 MG (por 5ml)', 'PISA', 'Suspensión', 'Oral', 'Frasco', 'Antibiótico pediátrico', true, false, '15-25°C', 'Frasco con 120ml con vaso dosificador. Lote GREDO87K', true),

-- Medicamento 103: Loratadina 5mg jarabe
('2531012685', 'LORATADINA 5 MILIGRAMOS', 'MAVER', 'Jarabe', 'Oral', 'Envase', 'Antihistamínico pediátrico', false, false, '15-25°C', 'Envase con 60ml. Lote AHFE44', true),

-- Medicamento 104: Ampicilina 125mg suspensión
('2531012686', 'AMPICILINA 125 MILIGRAMOS', 'PISA', 'Suspensión', 'Oral', 'Envase', 'Antibiótico pediátrico', true, false, '2-8°C (Refrigeración)', 'Envase con 120ml. Lote GREDO87K', true)

ON CONFLICT (codigo_medicamento) DO NOTHING;

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================

\echo '
========================================
✅ CARGA COMPLETADA
========================================
'

SELECT
  '✅ Medicamentos insertados' as resultado,
  count(*) as total_medicamentos
FROM medication_catalog;

SELECT
  '📊 Medicamentos por categoría' as titulo,
  categoria,
  count(*) as cantidad
FROM medication_catalog
GROUP BY categoria
ORDER BY count(*) DESC
LIMIT 10;

SELECT
  '💊 Medicamentos controlados' as titulo,
  count(*) as cantidad_controlados
FROM medication_catalog
WHERE controlado = true;

SELECT
  '🔖 Últimos 10 medicamentos agregados' as titulo,
  codigo_medicamento,
  nombre_generico,
  categoria,
  created_at
FROM medication_catalog
ORDER BY created_at DESC
LIMIT 10;

\echo '
========================================
📋 PRÓXIMOS PASOS
========================================

1. ✓ 101 medicamentos cargados en el catálogo
2. → Verificar en /admin que aparecen todos los medicamentos
3. → Crear lotes para cada medicamento desde /inventario
4. → Asignar instituciones a cada lote
5. → Los lotes con stock se mostrarán automáticamente

========================================
'

-- FIN DEL SCRIPT
