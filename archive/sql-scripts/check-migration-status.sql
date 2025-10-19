-- Quick Database State Check
-- Run this in Supabase SQL Editor to see what's been migrated

-- Check if Phase 2 tables exist
SELECT 'Phase 2 Tables' as category, table_name as item, 'EXISTS' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('payers', 'insurance_portals', 'payments', 'payment_sessions', 'session_status_history', 'alerts')
ORDER BY table_name;

-- Check if Phase 2 columns exist in sessions
SELECT 'Sessions Columns' as category, 
       column_name as item, 
       CASE WHEN column_name IN ('billing_status', 'date_submitted', 'date_paid', 'amount_billed', 'amount_paid') 
            THEN 'EXISTS' ELSE 'MISSING' END as status
FROM information_schema.columns 
WHERE table_name = 'sessions' 
  AND column_name IN ('billing_status', 'date_submitted', 'date_paid', 'amount_billed', 'amount_paid', 'denial_reason', 'insurance_portal_id', 'payment_reference', 'last_status_change')
ORDER BY column_name;

-- Check if Phase 2 views exist
SELECT 'Phase 2 Views' as category, table_name as item, 'EXISTS' as status
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name IN ('dashboard_metrics', 'aging_report')
ORDER BY table_name;

-- Check billing status enum
SELECT 'Enum Types' as category, 
       t.typname as item,
       CASE WHEN t.typname = 'billing_status_enum' THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_type t 
WHERE t.typname = 'billing_status_enum';

-- Summary
SELECT 'SUMMARY' as category, 
       CASE 
         WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('payers', 'insurance_portals')) >= 2
         AND (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'billing_status') >= 1
         THEN 'Phase 2 Migration: COMPLETED ✅'
         ELSE 'Phase 2 Migration: INCOMPLETE ⚠️'
       END as item,
       'STATUS' as status;
