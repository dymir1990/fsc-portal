-- Check import_staging table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'import_staging'
ORDER BY ordinal_position;

-- Check the latest staging entries
SELECT 
    id,
    run_id,
    raw,
    reason,
    created_at
FROM import_staging
ORDER BY created_at DESC
LIMIT 5;

