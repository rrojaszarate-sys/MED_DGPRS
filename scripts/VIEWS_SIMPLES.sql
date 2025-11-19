-- ================================================
-- VIEWS SIMPLES - MAPEO DIRECTO
-- ================================================

-- medications
DROP VIEW IF EXISTS medications CASCADE;
CREATE VIEW medications AS SELECT * FROM medicamentos;

-- health_centers
DROP VIEW IF EXISTS health_centers CASCADE;
CREATE VIEW health_centers AS SELECT * FROM centros_salud;

-- batches
DROP VIEW IF EXISTS batches CASCADE;
CREATE VIEW batches AS SELECT * FROM lotes;

-- batch_movements
DROP VIEW IF EXISTS batch_movements CASCADE;
CREATE VIEW batch_movements AS SELECT * FROM movimientos_lotes;

-- suppliers
DROP VIEW IF EXISTS suppliers CASCADE;
CREATE VIEW suppliers AS SELECT * FROM proveedores;

-- VERIFICAR
SELECT 'medications' as tabla, COUNT(*) FROM medications
UNION ALL
SELECT 'health_centers', COUNT(*) FROM health_centers
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers;
