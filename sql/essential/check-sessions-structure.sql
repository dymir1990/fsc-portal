-- Check what columns actually exist in sessions table
-- Run this first to see the actual structure

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sessions' 
ORDER BY ordinal_position;
