-- Quick Fix: Create Missing Views
-- Run this to create the dashboard_metrics and aging_report views

-- Create dashboard metrics view
CREATE OR REPLACE VIEW public.dashboard_metrics AS
SELECT 
  COUNT(*) FILTER (WHERE billing_status = 'completed') as completed_sessions,
  COUNT(*) FILTER (WHERE billing_status = 'ready_to_bill') as ready_to_bill,
  COUNT(*) FILTER (WHERE billing_status = 'submitted') as submitted_claims,
  COUNT(*) FILTER (WHERE billing_status = 'paid') as paid_sessions,
  COUNT(*) FILTER (WHERE billing_status = 'denied') as denied_claims,
  SUM(amount_billed) FILTER (WHERE billing_status NOT IN ('paid', 'denied')) as outstanding_amount,
  SUM(amount_paid) as total_collected,
  AVG(EXTRACT(DAY FROM date_paid - date_submitted)) FILTER (WHERE date_paid IS NOT NULL) as avg_days_to_payment
FROM public.sessions
WHERE session_date >= DATE_TRUNC('month', NOW());

-- Create aging report view
CREATE OR REPLACE VIEW public.aging_report AS
SELECT 
  s.id,
  s.session_date as date,
  s.billing_status,
  c.name as client_name,
  pr.name as provider_name,
  pa.name as payer_name,
  s.amount_billed,
  s.amount_paid,
  CASE 
    WHEN s.billing_status = 'paid' THEN 0
    WHEN s.date_submitted IS NULL THEN 
      EXTRACT(DAY FROM NOW() - s.session_date)
    ELSE 
      EXTRACT(DAY FROM NOW() - s.date_submitted)
  END as days_outstanding,
  CASE 
    WHEN s.billing_status = 'paid' THEN 'Paid'
    WHEN s.date_submitted IS NULL THEN 'Not Submitted'
    WHEN EXTRACT(DAY FROM NOW() - s.date_submitted) <= 30 THEN '0-30 days'
    WHEN EXTRACT(DAY FROM NOW() - s.date_submitted) <= 60 THEN '31-60 days'
    WHEN EXTRACT(DAY FROM NOW() - s.date_submitted) <= 90 THEN '61-90 days'
    ELSE '90+ days'
  END as age_bracket
FROM public.sessions s
LEFT JOIN public.clients c ON s.client_id = c.id
LEFT JOIN public.providers pr ON s.provider_id = pr.id
LEFT JOIN public.payers pa ON s.payer_id = pa.id
WHERE s.billing_status != 'paid';

-- Test the views
SELECT 'dashboard_metrics' as view_name, COUNT(*) as row_count FROM public.dashboard_metrics
UNION ALL
SELECT 'aging_report' as view_name, COUNT(*) as row_count FROM public.aging_report;