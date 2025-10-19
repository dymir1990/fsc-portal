-- Migration Verification Script
-- Run this to verify Phase 2 migration is complete

-- ===========================================
-- CHECK TABLES CREATED
-- ===========================================
SELECT 'Tables Check' as check_type, table_name as result
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'insurance_portals', 'payments', 'payment_sessions',
    'session_status_history', 'alerts', 'payers'
  )
ORDER BY table_name;

-- ===========================================
-- CHECK SESSIONS TABLE COLUMNS
-- ===========================================
SELECT 'Sessions Columns' as check_type, 
       column_name || ' (' || data_type || ')' as result
FROM information_schema.columns 
WHERE table_name = 'sessions' 
  AND column_name IN (
    'billing_status', 'date_submitted', 'date_paid',
    'amount_billed', 'amount_paid', 'denial_reason',
    'insurance_portal_id', 'payment_reference', 'last_status_change'
  )
ORDER BY column_name;

-- ===========================================
-- CHECK VIEWS CREATED
-- ===========================================
SELECT 'Views Check' as check_type, table_name as result
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name IN ('dashboard_metrics', 'aging_report')
ORDER BY table_name;

-- ===========================================
-- CHECK ENUM TYPE
-- ===========================================
SELECT 'Enum Check' as check_type, 
       t.typname || ' (' || string_agg(e.enumlabel, ', ') || ')' as result
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
WHERE t.typname = 'billing_status_enum'
GROUP BY t.typname;

-- ===========================================
-- CHECK TRIGGERS
-- ===========================================
SELECT 'Triggers Check' as check_type, 
       trigger_name || ' on ' || event_object_table as result
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
  AND trigger_name = 'sessions_status_change';

-- ===========================================
-- TEST VIEWS WITH DATA
-- ===========================================
SELECT 'Dashboard Metrics' as check_type, 
       'completed_sessions: ' || completed_sessions || 
       ', ready_to_bill: ' || ready_to_bill ||
       ', submitted_claims: ' || submitted_claims as result
FROM public.dashboard_metrics;

SELECT 'Aging Report' as check_type, 
       'Total records: ' || COUNT(*)::TEXT as result
FROM public.aging_report;

-- ===========================================
-- CHECK BILLING STATUS VALUES
-- ===========================================
SELECT 'Billing Status Distribution' as check_type,
       billing_status || ': ' || COUNT(*)::TEXT as result
FROM public.sessions 
GROUP BY billing_status
ORDER BY billing_status;

-- ===========================================
-- SUMMARY
-- ===========================================
SELECT 'MIGRATION SUMMARY' as check_type,
       'Phase 2 Revenue Cycle Management migration verification complete' as result;
