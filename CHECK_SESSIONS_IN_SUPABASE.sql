-- Run these queries in Supabase SQL Editor to check if sessions exist

-- 1. Count total sessions
SELECT COUNT(*) as total_sessions FROM sessions;

-- 2. Count recently imported sessions (last hour)
SELECT COUNT(*) as recent_sessions 
FROM sessions 
WHERE imported_at > NOW() - INTERVAL '1 hour';

-- 3. Show last 10 sessions with details
SELECT 
  s.id,
  s.session_date,
  c.name as client_name,
  p.name as provider_name,
  s.billing_status,
  s.imported_at,
  s.payer_id
FROM sessions s
LEFT JOIN clients c ON s.client_id = c.id
LEFT JOIN providers p ON s.provider_id = p.id
ORDER BY s.imported_at DESC
LIMIT 10;

-- 4. Check if sessions table has RLS enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'sessions';

-- 5. Check RLS policies on sessions table
SELECT * FROM pg_policies WHERE tablename = 'sessions';

