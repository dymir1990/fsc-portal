-- Emergency diagnostic: Check what the backend is actually seeing
-- Run this RIGHT AFTER uploading a CSV

-- 1. Check the most recent import attempt
SELECT 
    id,
    file_name,
    started_at,
    total_rows,
    inserted_rows,
    flagged_rows,
    errors
FROM import_runs
ORDER BY started_at DESC
LIMIT 3;

-- 2. Check what data was in the flagged rows
SELECT 
    raw->>'Primary clinician' as provider_name,
    raw->>'Date added' as date_field,
    raw->>'Client' as client_name,
    reason
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
LIMIT 10;

-- 3. Check if ANY providers were created during the import
SELECT * FROM providers
WHERE created_at > NOW() - INTERVAL '10 minutes'
ORDER BY created_at DESC;
