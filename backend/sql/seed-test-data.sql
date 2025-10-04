-- Seed test data for development and demo purposes
-- Run this in Supabase SQL Editor AFTER running seed-payers.sql

-- Insert sample providers
INSERT INTO public.providers (name, email, created_at) VALUES
  ('Dr. Lauren Rivera', 'lrivera@fscnj.com', NOW()),
  ('Dr. David Chen', 'dchen@fscnj.com', NOW()),
  ('Dr. Maria Garcia', 'mgarcia@fscnj.com', NOW())
ON CONFLICT (email) DO NOTHING;

-- Insert sample clients
INSERT INTO public.clients (name, email, created_at) VALUES
  ('Alex Johnson', 'ajohnson@example.com', NOW()),
  ('Brianna Smith', 'bsmith@example.com', NOW()),
  ('Carlos Mendez', 'cmendez@example.com', NOW()),
  ('Diana Patel', 'dpatel@example.com', NOW()),
  ('Ethan Brooks', 'ebrooks@example.com', NOW()),
  ('Fiona Martinez', 'fmartinez@example.com', NOW()),
  ('Gabriel Lee', 'glee@example.com', NOW()),
  ('Hannah Wilson', 'hwilson@example.com', NOW())
ON CONFLICT (email) DO NOTHING;

-- Insert sample sessions (requires provider_id and client_id)
-- Using CTEs to reference providers and clients by name
WITH
  provider_rivera AS (SELECT id FROM public.providers WHERE email = 'lrivera@fscnj.com' LIMIT 1),
  provider_chen AS (SELECT id FROM public.providers WHERE email = 'dchen@fscnj.com' LIMIT 1),
  provider_garcia AS (SELECT id FROM public.providers WHERE email = 'mgarcia@fscnj.com' LIMIT 1),
  client_alex AS (SELECT id FROM public.clients WHERE email = 'ajohnson@example.com' LIMIT 1),
  client_brianna AS (SELECT id FROM public.clients WHERE email = 'bsmith@example.com' LIMIT 1),
  client_carlos AS (SELECT id FROM public.clients WHERE email = 'cmendez@example.com' LIMIT 1),
  client_diana AS (SELECT id FROM public.clients WHERE email = 'dpatel@example.com' LIMIT 1),
  client_ethan AS (SELECT id FROM public.clients WHERE email = 'ebrooks@example.com' LIMIT 1)
INSERT INTO public.sessions (
  provider_id,
  client_id,
  session_date,
  start_time,
  end_time,
  minutes,
  insurance_type,
  note_submitted,
  client_type,
  primary_insurance,
  billing_route,
  external_source,
  imported_at
)
SELECT * FROM (VALUES
  -- Dr. Rivera sessions
  ((SELECT id FROM provider_rivera), (SELECT id FROM client_alex), '2025-10-01', '09:00 AM', '09:50 AM', 50, 'Horizon NJ Health', true, 'Adult', 'Horizon NJ Health (22356)', 'portal', 'simplepractice', NOW()),
  ((SELECT id FROM provider_rivera), (SELECT id FROM client_brianna), '2025-10-01', '10:00 AM', '10:45 AM', 45, 'Aetna', true, 'Minor', 'Aetna (80954)', 'portal', 'simplepractice', NOW()),
  ((SELECT id FROM provider_rivera), (SELECT id FROM client_diana), '2025-10-02', '11:00 AM', '11:50 AM', 50, 'Horizon NJ Health', false, 'Adult', 'Horizon NJ Health (22356)', 'portal', 'simplepractice', NOW()),

  -- Dr. Chen sessions
  ((SELECT id FROM provider_chen), (SELECT id FROM client_carlos), '2025-10-01', '02:00 PM', '02:55 PM', 55, 'AmeriHealth', true, 'Adult', 'AmeriHealth (22110)', 'portal', 'simplepractice', NOW()),
  ((SELECT id FROM provider_chen), (SELECT id FROM client_ethan), '2025-10-02', '01:00 PM', '01:45 PM', 45, 'United Healthcare', false, 'Minor', 'United Healthcare (77102)', 'portal', 'simplepractice', NOW()),

  -- Dr. Garcia sessions
  ((SELECT id FROM provider_garcia), (SELECT id FROM client_alex), '2025-10-03', '03:00 PM', '03:50 PM', 50, 'Medicare', true, 'Adult', 'Medicare', 'simplepractice', 'simplepractice', NOW()),
  ((SELECT id FROM provider_garcia), (SELECT id FROM client_brianna), '2025-10-03', '04:00 PM', '04:45 PM', 45, 'Medicaid', false, 'Minor', 'Medicaid', 'simplepractice', 'simplepractice', NOW())
) AS session_data;

-- Create a sample import run
INSERT INTO public.import_runs (
  source,
  file_name,
  started_at,
  finished_at,
  total_rows,
  inserted_rows,
  updated_rows,
  flagged_rows
) VALUES (
  'simplepractice',
  'sample_test_data.csv',
  NOW() - INTERVAL '1 hour',
  NOW() - INTERVAL '59 minutes',
  7,
  7,
  0,
  0
);

-- Verify the data
SELECT
  'Providers' as table_name,
  COUNT(*) as record_count
FROM public.providers

UNION ALL

SELECT
  'Clients' as table_name,
  COUNT(*) as record_count
FROM public.clients

UNION ALL

SELECT
  'Sessions' as table_name,
  COUNT(*) as record_count
FROM public.sessions

UNION ALL

SELECT
  'Payers' as table_name,
  COUNT(*) as record_count
FROM public.payers

UNION ALL

SELECT
  'Import Runs' as table_name,
  COUNT(*) as record_count
FROM public.import_runs;

-- Show sample session data with relationships
SELECT
  s.session_date,
  p.name as provider_name,
  c.name as client_name,
  s.minutes,
  s.note_submitted,
  s.billing_route,
  s.primary_insurance
FROM public.sessions s
JOIN public.providers p ON s.provider_id = p.id
JOIN public.clients c ON s.client_id = c.id
ORDER BY s.session_date DESC, s.start_time
LIMIT 10;
