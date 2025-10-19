# Database Migration Guide - Phase 2 Revenue Cycle Management

## Step 1: Access Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sign in to your account
3. Select your FSC Portal project
4. Navigate to **SQL Editor** in the left sidebar

## Step 2: Run Migration Script
1. Click **"New Query"** in the SQL Editor
2. Copy the entire contents of `backend/sql/phase2-migration.sql`
3. Paste it into the query editor
4. Click **"Run"** to execute the script

## Step 3: Verify Migration Success
After running the script, execute these verification queries:

### Check Tables Created
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'insurance_portals', 'payments', 'payment_sessions',
    'session_status_history', 'alerts'
  );
```

### Check Sessions Table Columns
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sessions' 
  AND column_name IN (
    'billing_status', 'date_submitted', 'date_paid',
    'amount_billed', 'amount_paid'
  );
```

### Test Views
```sql
SELECT * FROM public.dashboard_metrics LIMIT 1;
SELECT * FROM public.aging_report LIMIT 5;
```

## Step 4: Update Existing Data
After the migration, run this to set default billing status for existing sessions:

```sql
-- Set default billing status for existing sessions
UPDATE public.sessions
SET billing_status = 'completed'
WHERE billing_status IS NULL;

-- Mark sessions with submitted notes as documented
UPDATE public.sessions
SET billing_status = 'documented'
WHERE note_submitted = true AND billing_status = 'completed';
```

## Expected Results
- ✅ 5 new tables created
- ✅ Sessions table has 9 new columns
- ✅ 2 views created (dashboard_metrics, aging_report)
- ✅ 2 triggers created for status change logging
- ✅ All existing sessions have billing_status = 'completed' or 'documented'

## Troubleshooting
If you encounter errors:
1. **Permission errors**: Ensure you're using the service role key
2. **Column already exists**: The script uses `IF NOT EXISTS` clauses
3. **Enum errors**: The script creates the enum type first, then updates the column

## Next Steps After Migration
1. Test the updated Sessions page to see billing status badges
2. Test the Revenue Dashboard at `/billing/revenue`
3. Import a test CSV to verify billing_status is set correctly
4. Schedule Mackenzi validation session
