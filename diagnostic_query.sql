-- Fixed query to check why rows are flagged
SELECT reason, COUNT(*) as count
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
GROUP BY reason;
