-- Fix: Make payer_uuid nullable in sessions table
-- Some sessions don't have insurance (self-pay), so payer_uuid should be optional

ALTER TABLE sessions 
ALTER COLUMN payer_uuid DROP NOT NULL;

-- Verify the change
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'sessions' AND column_name = 'payer_uuid';

