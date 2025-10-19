-- Quick Fix for Step 7 - Insurance Portals Table
-- Run this instead of Step 7 if you're getting an error

-- First, let's check if payers table exists and what its structure is
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'payers' 
ORDER BY ordinal_position;

-- If payers table doesn't exist, create it first
CREATE TABLE IF NOT EXISTS public.payers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  billing_route TEXT,
  status TEXT DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Now create insurance portals table
CREATE TABLE IF NOT EXISTS public.insurance_portals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  portal_name TEXT NOT NULL,
  portal_url TEXT,
  payer_id UUID REFERENCES public.payers(id),
  billing_route TEXT,
  login_instructions TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_portals_payer ON public.insurance_portals(payer_id);
ALTER TABLE public.insurance_portals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins and billing can view portals"
ON public.insurance_portals FOR SELECT
USING (
  auth.uid() IN (
    SELECT id FROM public.profiles 
    WHERE role IN ('admin', 'billing', 'director')
  )
);
