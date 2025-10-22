-- Check providers table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'providers'
ORDER BY ordinal_position;

-- Check clients table structure  
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'clients'
ORDER BY ordinal_position;

-- Check if RLS is enabled and blocking inserts
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('providers', 'clients');
