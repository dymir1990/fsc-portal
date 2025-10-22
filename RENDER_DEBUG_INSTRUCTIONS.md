# 🔍 Render Log Debug Instructions

## What to Check:

1. **Go to Render Dashboard** → Your Backend Service → **Logs** tab

2. **Look for these specific log lines** (from the most recent upload):

```
Starting CSV import: [filename]
Processing row 2: [client] - [provider] - [date]
```

## What We Need to See:

### ✅ **IF EXTRACTION WORKS:**
```
INFO: Processing row 2: Alex Johnson - Lauren Rivera - 09/15/2025
INFO: Searching for provider: Lauren Rivera
```

### ❌ **IF EXTRACTION FAILS:**
```
INFO: Processing row 2:  -  -   (all empty!)
WARNING: Row 2 flagged: missing client, provider, date
```

## The Test:

1. Upload `backend/sample_data/simplepractice_mock.csv` again
2. Check Render logs **immediately** after upload
3. Look for the "Processing row 2" line
4. **Take a screenshot** of the logs showing rows 2-5

---

## Alternative: Check What Was Actually Uploaded

Run this SQL in Supabase to see the EXACT CSV data:

```sql
SELECT 
    raw->'Client' as client_raw,
    raw->'Primary clinician' as provider_raw,
    raw->'Date added' as date_raw
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
LIMIT 3;
```

This will show us if the CSV data is actually making it to the database!

