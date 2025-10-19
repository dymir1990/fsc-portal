-- Fix for Role Enum Issue
-- First, let's see what roles are actually defined in your database

-- Check what roles exist in the user_role enum
SELECT unnest(enum_range(NULL::user_role)) as valid_roles;

-- Check what roles are actually used in the profiles table
SELECT DISTINCT role FROM public.profiles;

-- If "billing" is not in the enum, we need to either:
-- 1. Add "billing" to the enum, OR
-- 2. Use existing roles in our policies

-- Option 1: Add "billing" to the enum (if it doesn't exist)
-- ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'billing';

-- Option 2: Use existing roles instead
-- Let's create a safer policy that uses existing roles
CREATE POLICY "Admins and billing can view portals"
ON public.insurance_portals FOR SELECT
USING (
  auth.uid() IN (
    SELECT id FROM public.profiles 
    WHERE role IN ('admin', 'director')  -- Remove 'billing' for now
  )
);
