-- ============================================
-- FSC Portal - Debug & Diagnostic SQL Queries
-- ============================================

-- ============================================
-- 1. CHECK RECENT IMPORT STATUS
-- ============================================

-- View recent import runs
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
LIMIT 5;

-- ============================================
-- 2. CHECK FLAGGED ROWS FROM LATEST IMPORT
-- ============================================

SELECT 
    raw->>'Primary clinician' as provider_name,
    raw->>'Clinician' as provider_name_new,
    raw->>'Date added' as date_field,
    raw->>'Date of Service' as date_field_new,
    raw->>'Client' as client_name,
    reason
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
LIMIT 10;

-- ============================================
-- 3. CHECK RECENTLY CREATED PROVIDERS
-- ============================================

SELECT * FROM providers
WHERE created_at > NOW() - INTERVAL '10 minutes'
ORDER BY created_at DESC;

-- ============================================
-- 4. CHECK RECENTLY CREATED SESSIONS
-- ============================================

SELECT COUNT(*) as recent_sessions
FROM sessions 
WHERE imported_at > NOW() - INTERVAL '10 minutes';

-- Full details of recent sessions
SELECT 
    s.id,
    s.session_date,
    p.name as provider,
    c.name as client,
    s.billing_status,
    s.imported_at
FROM sessions s
JOIN providers p ON s.provider_id = p.id
JOIN clients c ON s.client_id = c.id
WHERE s.imported_at > NOW() - INTERVAL '10 minutes'
ORDER BY s.session_date DESC;

-- ============================================
-- 5. CHECK TABLE STRUCTURES
-- ============================================

-- Check providers table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'providers'
ORDER BY ordinal_position;

-- Check clients table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'clients'
ORDER BY ordinal_position;

-- ============================================
-- 6. CHECK RAW CSV DATA IN STAGING
-- ============================================

SELECT 
    raw->'Client' as client_raw,
    raw->'Primary clinician' as provider_raw,
    raw->'Date added' as date_raw
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
LIMIT 5;

-- ============================================
-- 7. DIAGNOSTIC: WHY ROWS WERE FLAGGED
-- ============================================

SELECT 
    reason,
    COUNT(*) as count
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
GROUP BY reason;

