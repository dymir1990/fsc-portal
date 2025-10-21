-- Check the last import run
SELECT * FROM import_runs ORDER BY started_at DESC LIMIT 1;

-- Check flagged rows from the last import
SELECT reason, COUNT(*) as count
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
GROUP BY reason;

-- Check if we have providers
SELECT COUNT(*) as provider_count FROM providers;

-- Check if we have clients
SELECT COUNT(*) as client_count FROM clients;

-- Check actual sessions created
SELECT COUNT(*) as session_count FROM sessions WHERE imported_at IS NOT NULL;
