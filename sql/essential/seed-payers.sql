-- Seed payers table with default billing routes
-- Run this in Supabase SQL Editor after creating the payers table

-- Create payers table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.payers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  billing_route TEXT NOT NULL DEFAULT 'simplepractice',
  status TEXT NOT NULL DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payers_updated_at
  BEFORE UPDATE ON public.payers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert default payers based on docs/billing-routes.md
INSERT INTO public.payers (name, billing_route, status) VALUES
  ('Aetna', 'portal', 'Active'),
  ('AmeriHealth', 'portal', 'Active'),
  ('Horizon NJ Health', 'portal', 'Active'),
  ('Magellan', 'portal', 'Active'),
  ('Medicaid', 'simplepractice', 'Active'),
  ('Medicare', 'simplepractice', 'Active'),
  ('Oscar Health Insurance', 'portal', 'Active'),
  ('Tricare', 'portal', 'Active'),
  ('United Healthcare', 'portal', 'Active')
ON CONFLICT (name) DO UPDATE
  SET
    billing_route = EXCLUDED.billing_route,
    status = EXCLUDED.status,
    updated_at = NOW();

-- Verify insert
SELECT name, billing_route, status, created_at
FROM public.payers
ORDER BY name;
