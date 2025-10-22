# 🎯 FSC Portal Demo Guide - Tomorrow
**Date:** October 23, 2025  
**Critical:** CSV Import Demonstration

---

## 📋 **PRE-DEMO CHECKLIST (Morning of Demo)**

### 1. Test Import URL (CRITICAL - 2 minutes)
Open in browser:
```
https://app.fscnj.com/case-manager/import
```

**Expected:**
- ✅ Page loads with insurance companies list
- ✅ "Choose File" button visible
- ✅ Upload area present

**If page doesn't load:** Check Vercel deployment status

---

### 2. Verify Backend is Live (1 minute)
Check Render dashboard:
- Backend service should show "Live" status
- No recent errors in logs

---

### 3. Verify Database Ready (1 minute)
In Supabase SQL Editor, run:
```sql
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'sessions' AND column_name = 'payer_uuid';
```

**Expected:** `is_nullable: YES` ✅

---

## 🎬 **DEMO SCRIPT**

### Opening (30 seconds)
"I'll show you how our new FSC Portal handles SimplePractice CSV imports with automatic provider and client creation."

---

### Part 1: Navigate to Import (15 seconds)

**USE THIS ROUTE** (confirmed working):
1. Go directly to: `app.fscnj.com/case-manager/import`
2. Say: "Let me show you our import system for billing staff"

**Note**: The default page is currently `/dashboard` (old UI). The new Revenue-first navigation is deployed but cached. Use the direct URL for the demo.

---

### Part 2: Show Insurance Companies (30 seconds)

**Point out:**
- "These are all the insurance companies currently in the system"
- "The system knows about Horizon, Aetna, Tricare, etc."
- "If a CSV has unknown insurance, it flags for review"

---

### Part 3: Upload CSV (1 minute)

**File to use:**
```
/Users/dymirtatem/Downloads/appointments_report-3.csv
```

**Actions:**
1. Click "Choose File"
2. Select `appointments_report-3.csv`
3. Click "Upload CSV"
4. **Wait 5-10 seconds** for processing

**Expected Result:**
```
✅ Success!
   24 Records Imported
   0 Flagged Rows
```

**What to say:**
"The system just:
- Parsed 24 sessions from SimplePractice
- Auto-created providers (Edison Jaquez, Diamond Williams, etc.)
- Auto-created clients (Will Corley, Sharron Alexander, etc.)
- Linked sessions to insurance companies
- Ready for billing immediately"

---

### Part 4: Show Imported Data (30 seconds)

**Navigate to Sessions:**
1. Click "Sessions" in sidebar (or go to `app.fscnj.com/sessions`)
2. Scroll to see imported sessions
3. **Point out:**
   - Provider names correct
   - Client names correct
   - Dates: October 6-10, 2025
   - Insurance companies assigned

---

## 🚨 **TROUBLESHOOTING (If Things Go Wrong)**

### Issue: Import Button Missing
**Solution:** Use direct URL
```
app.fscnj.com/case-manager/import
```

### Issue: 0 Imported, All Flagged
**Check reason in flagged rows**

If "unknown_insurance":
- Say: "This is the flagging system working - it caught an insurance company not in our system"
- "Billing staff would add it to the payers table and re-import"

If "missing_provider, date":
- **This shouldn't happen** - backend is fixed
- Fallback: "Let me show you the sessions that are already in the system"

### Issue: Upload Fails Completely
**Fallback demo:**
1. Show existing sessions in Sessions page
2. Explain: "These were imported earlier using the same process"
3. Walk through the flagging logic concept

---

## 📊 **KEY TALKING POINTS**

### 1. Auto-Creation
"No more manual data entry. Providers and clients are created automatically from the CSV."

### 2. Intelligent Flagging
"Sessions with missing or unknown insurance are flagged for human review, not rejected. This prevents data loss."

### 3. Production Ready
"This is running on:
- Vercel for frontend (auto-scaling)
- Render for backend (Python FastAPI)
- Supabase for database (PostgreSQL with RLS)"

### 4. Nordic Design
"We simplified the navigation to 4 items based on billing specialist workflow research. Revenue page is home because that's what billing staff check first every day."

---

## 🎯 **SUCCESS METRICS TO SHOW**

If demo goes perfectly:
- ✅ 24/24 sessions imported (100% success rate)
- ✅ 0 flagged rows
- ✅ All provider/client names correct
- ✅ Insurance assignments accurate
- ✅ Dates parsed correctly

---

## 📞 **BACKUP PLAN**

If live demo fails:
1. Have screenshots ready of successful import
2. Show Supabase table with imported data
3. Walk through the code logic instead
4. Explain what WOULD happen in a working demo

---

## ⏰ **TIMING**

Total demo: **3-4 minutes**
- Setup: 15 sec
- Insurance companies: 30 sec
- CSV upload: 1 min
- Show results: 30 sec
- Q&A: 1-2 min

---

## 🔗 **QUICK LINKS FOR DEMO**

**Direct Import Page:**
```
https://app.fscnj.com/case-manager/import
```

**Sessions Page:**
```
https://app.fscnj.com/sessions
```

**Revenue Page:**
```
https://app.fscnj.com/billing/revenue
```

**Vercel Dashboard:**
```
https://vercel.com/dashboard
```

**Render Dashboard:**
```
https://dashboard.render.com
```

**Supabase:**
```
https://supabase.com/dashboard
```

---

## ✅ **FINAL CHECKLIST (30 MIN BEFORE DEMO)**

- [ ] Test import URL loads
- [ ] Test CSV upload with sample file
- [ ] Clear browser cache
- [ ] Close unnecessary tabs
- [ ] Have CSV file ready on desktop
- [ ] Have backup screenshots ready
- [ ] Test on same computer/browser you'll use for demo
- [ ] Verify good internet connection

---

**YOU'VE GOT THIS!** 🚀

The functionality works - it's proven in our testing. Just use the direct URL if the UI isn't showing the new design yet.

