-- Check what's ACTUALLY in the raw CSV data
SELECT 
    raw->'Client' as client_raw,
    raw->'Primary clinician' as provider_raw,
    raw->'Date added' as date_raw,
    reason
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
LIMIT 5;

