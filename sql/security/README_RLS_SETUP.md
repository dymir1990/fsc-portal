# 🔒 RLS Security Setup Guide

**CRITICAL: Your database is currently UNPROTECTED!**

All your tables are exposed without Row Level Security. This means anyone can read/modify your data if they get your API keys.

---

## ⚠️ Current Security Issues

You have the following warnings in Supabase:

1. ❌ **Table `public.clients` - RLS not enabled**
2. ❌ **Table `public.providers` - RLS not enabled**
3. ❌ **Table `public.sessions` - RLS not enabled**
4. ❌ **Table `public.payers` - RLS not enabled**
5. ❌ **Table `public.import_runs` - RLS not enabled**
6. ❌ **Table `public.import_staging` - RLS not enabled**
7. ⚠️ **View `aging_report` - SECURITY DEFINER issue**
8. ⚠️ **View `dashboard_metrics` - SECURITY DEFINER issue**

---

## ✅ What This Script Does

The `enable-rls-security.sql` script will:

1. **Enable RLS** on all your tables
2. **Create policies** that match your app's role system:
   - **Admin**: Full access to everything
   - **Director**: Can manage all data
   - **Billing**: Can manage sessions, clients, providers
   - **Provider**: Can view own sessions only
   - **Authenticated**: Can view data (read-only)
3. **Fix SECURITY DEFINER views**
4. **Protect your data** from unauthorized access

---

## 🚀 How to Apply This Fix

### Step 1: Open Supabase Dashboard

1. Go to: https://supabase.com/dashboard
2. Select your project: **fsc-portal**
3. Click **SQL Editor** in the left sidebar

### Step 2: Run the Security Script

1. Click **New Query**
2. Open the file: `/home/user/fsc-portal/sql/security/enable-rls-security.sql`
3. Copy the ENTIRE contents
4. Paste into the SQL Editor
5. Click **Run** (or press Ctrl+Enter)

### Step 3: Verify It Worked

At the bottom of the script output, you should see:

```
✅ Tables with RLS enabled:
   - clients (rls_enabled: true)
   - providers (rls_enabled: true)
   - sessions (rls_enabled: true)
   ... etc
```

---

## 🧪 Testing After Setup

### Test 1: Backend API Still Works

Your backend API uses the **service role key** which bypasses RLS, so it should work exactly as before.

```bash
# Test the sessions endpoint
curl https://your-backend.onrender.com/api/sessions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Expected:** ✅ Returns sessions data (still works!)

### Test 2: Frontend Still Works

Your frontend uses the **authenticated key** which is subject to RLS policies.

1. Log in to your app
2. Navigate to `/sessions`
3. Try uploading a CSV at `/case-manager/import`

**Expected:** ✅ Everything still works!

### Test 3: Unauthorized Access Blocked

Try accessing the API without authentication:

```bash
# This should fail
curl https://your-supabase-url/rest/v1/clients
```

**Expected:** ❌ 401 Unauthorized (Good! RLS is working)

---

## 🔐 Understanding the Security Model

### Service Role Key (Backend)
- Used by: Your FastAPI backend
- Location: Backend `.env` file
- Access: **BYPASSES RLS** - full access
- **NEVER expose this in frontend!**

### Authenticated Key (Frontend)
- Used by: Your SvelteKit frontend
- Location: Frontend `.env` file (`PUBLIC_SUPABASE_ANON_KEY`)
- Access: **Subject to RLS policies**
- Safe to expose in browser (it's public)

### How It Works Together

```
┌─────────────────────────────────────────┐
│ Frontend (Browser)                      │
│ Uses: Authenticated Key                 │
│ RLS: ✅ ENABLED                         │
│ Can only do what policies allow         │
└─────────────────────────────────────────┘
            │
            ├── Calls Backend API
            ↓
┌─────────────────────────────────────────┐
│ Backend (FastAPI on Render)             │
│ Uses: Service Role Key                  │
│ RLS: ❌ BYPASSED                        │
│ Full database access                    │
└─────────────────────────────────────────┘
```

---

## 📋 Role-Based Access Summary

After applying the script, here's who can do what:

### Admin Role
- ✅ View all data
- ✅ Create/edit/delete everything
- ✅ Manage users and roles
- ✅ Import CSV files

### Director Role
- ✅ View all data
- ✅ Create/edit sessions, clients, providers
- ✅ Import CSV files
- ❌ Cannot manage user accounts

### Billing Role
- ✅ View all data
- ✅ Create/edit sessions, clients, providers
- ✅ Import CSV files
- ❌ Cannot manage user accounts

### Provider Role
- ✅ View own sessions only
- ✅ View clients they work with
- ❌ Cannot edit or import

### Authenticated (logged in)
- ✅ View data (read-only)
- ❌ Cannot modify anything

---

## 🐛 Troubleshooting

### Issue: "Backend API stopped working after enabling RLS"

**Cause:** Backend might be using wrong key

**Fix:**
```bash
# Check backend/.env has service role key, NOT anon key:
SUPABASE_KEY=eyJhbGc... (should be LONG key, starts with eyJ)
```

### Issue: "Frontend can't load data"

**Cause:** User might not be authenticated

**Fix:**
1. Check user is logged in
2. Verify JWT token is valid
3. Check browser console for errors

### Issue: "Some operations fail but others work"

**Cause:** Policies might be too restrictive

**Fix:**
1. Check the user's role in `profiles` table
2. Verify the policy matches the role
3. Add more permissive policy if needed

---

## 🔄 Rollback (If Needed)

If something breaks and you need to temporarily disable RLS:

```sql
-- TEMPORARY: Disable RLS on all tables
ALTER TABLE public.clients DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.providers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.payers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.import_runs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.import_staging DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- ⚠️ WARNING: Your database is now UNPROTECTED again!
-- Fix the issue and re-enable RLS ASAP!
```

---

## ✅ Security Checklist

After running the script, verify:

- [ ] All tables show `rls_enabled: true` in verification query
- [ ] Backend API still works (test `/api/sessions`)
- [ ] Frontend still works (can view sessions)
- [ ] CSV import still works
- [ ] Role switcher still works
- [ ] Cannot access data without logging in
- [ ] Supabase warnings are gone

---

## 📞 Need Help?

If you run into issues:

1. Check the troubleshooting section above
2. Review Supabase logs: Dashboard → Logs → API
3. Check browser console for errors
4. Verify user roles in `profiles` table

---

## 🎯 Summary

**Before:** ❌ Anyone with your API key can access/modify ALL data
**After:** ✅ Only authorized users can access data based on their role

**This is a CRITICAL security update!** Run it as soon as possible.

---

**File:** `sql/security/enable-rls-security.sql`
**Status:** Ready to apply
**Impact:** HIGH - Secures entire database
**Breaking Changes:** None (if backend uses service role key)
