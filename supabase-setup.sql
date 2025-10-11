-- ============================================
-- FSC Portal - Role Management Setup
-- ============================================
-- Run this in your Supabase SQL Editor
-- ============================================

-- Step 1: Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'billing' CHECK (role IN ('admin', 'director', 'billing', 'provider')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Step 3: Create RLS Policies

-- Anyone can read their own profile
CREATE POLICY "Users can read own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Only admins can read all profiles
CREATE POLICY "Admins can read all profiles"
  ON public.profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins can update roles
CREATE POLICY "Admins can update profiles"
  ON public.profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Step 4: Create function to auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role)
  VALUES (NEW.id, NEW.email, 'billing'); -- Default role is 'billing'
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Create trigger to auto-create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Step 6: Create updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- IMPORTANT: Create your first admin user!
-- ============================================
-- After you sign up, run this to make yourself admin:
-- Replace 'your.email@fscnj.com' with YOUR email

INSERT INTO public.profiles (id, email, full_name, role)
SELECT id, email, raw_user_meta_data->>'full_name', 'admin'
FROM auth.users
WHERE email = 'your.email@fscnj.com'
ON CONFLICT (id) DO UPDATE
SET role = 'admin';

-- ============================================
-- How to assign roles manually:
-- ============================================

-- Make someone an admin:
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'user@fscnj.com';

-- Make someone a director:
-- UPDATE public.profiles SET role = 'director' WHERE email = 'user@fscnj.com';

-- Make someone billing:
-- UPDATE public.profiles SET role = 'billing' WHERE email = 'user@fscnj.com';

-- Make someone a provider:
-- UPDATE public.profiles SET role = 'provider' WHERE email = 'user@fscnj.com';

-- View all users and their roles:
-- SELECT email, role, created_at FROM public.profiles ORDER BY created_at DESC;
