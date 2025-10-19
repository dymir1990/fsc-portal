# ⚡ FSC Portal - Quick Reference
## Essential Commands & Information

**Last Updated:** October 19, 2025  
**Project:** FSC Portal - Billing lifecycle tracking system  
**Status:** Phase 2 Backend Complete | Frontend Integration Needed

---

## 🎯 30-SECOND CONTEXT

**Current Task:** Frontend integration to display payer data in Sessions table  
**Current Issue:** Sessions table shows "Unknown" for payers (data exists in DB)  
**Next Step:** Update API endpoint to JOIN payers table  
**Demo:** October 20, 2025

---

## 🔧 TECH QUICK FACTS

**Database:** Supabase (PostgreSQL) - Project ID: dyfrmyspiwxjwjhqncvo  
**Frontend:** SvelteKit + Tailwind CSS - Deployed on Vercel  
**Backend:** FastAPI + Python - Deployed on Render  
**Domain:** app.fscnj.com

**Key Tables:**
- `sessions` - has `payer_uuid` column (FK to payers)
- `payers` - 13 insurance companies
- `clients`, `providers` - standard references

**Important:** Column names use `_uuid` not `_id`, amount is `amount_billed` not `amount_charged`

---

## ✅ WHAT'S WORKING

- ✅ Database has all Phase 2 columns (billing_status, payer_uuid, submission_date, etc.)
- ✅ 5 test sessions linked to different insurance companies
- ✅ SQL queries return complete data with payer names
- ✅ Backend API exists (just needs payer JOIN)
- ✅ Authentication flow works
- ✅ CSV import with validation
- ✅ Dashboard with real metrics

**Working SQL Query:**
```sql
SELECT s.*, c.name as client, p.name as provider, 
       pay.name as insurance_company
FROM sessions s
LEFT JOIN clients c ON s.client_id = c.id
LEFT JOIN providers p ON s.provider_id = p.id  
LEFT JOIN payers pay ON s.payer_uuid = pay.id;
```

---

## ⚠️ WHAT'S NOT WORKING

- ⚠️ Frontend Sessions table shows "Unknown" in Payer column
- ⚠️ API endpoint doesn't JOIN payers table yet
- ⚠️ No status change UI functionality
- ⚠️ Dashboard not using Phase 2 metrics

---

## 🚀 QUICK COMMANDS

### Local Development
```bash
# Backend
cd backend
source venv/bin/activate
uvicorn main:app --reload --port 8001

# Frontend
cd frontend
npm run dev
```

### Deployment
```bash
# Push changes
git add .
git commit -m "descriptive message"
git push origin main

# Backend deploys automatically via Render Blueprint
# Frontend: Update Vercel environment variables
```

### Database
```sql
-- Run in Supabase SQL Editor
\i sql/essential/2024-09-28-update-sessions.sql
\i sql/essential/seed-payers.sql
```

---

## 📁 KEY FILES

**Read These:**
- `FSC_PORTAL_MASTER_DOCUMENTATION.md` - Complete reference
- `QUICK_HANDOFF.md` - This file
- `CONTEXT_HANDOFF_TEMPLATE.md` - AI handoff format

**SQL Scripts:**
- `sql/essential/2024-09-28-update-sessions.sql` - Main migration
- `sql/essential/seed-payers.sql` - Insurance companies
- `sql/essential/seed-test-data.sql` - Sample data

**Code:**
- `frontend/src/routes/sessions/+page.svelte` - Sessions table
- `backend/main.py` - API endpoints
- `frontend/src/lib/api.ts` - API client

---

## 🎯 IMMEDIATE NEXT STEPS

**Priority 1:** Demo prep (Oct 20)  
**Priority 2:** Find Sessions API endpoint  
**Priority 3:** Add payers JOIN to API  
**Priority 4:** Update Sessions table UI component

---

## 💬 COPY/PASTE FOR AI ASSISTANTS

### For Claude
```
I'm working on FSC Portal Phase 2. Backend complete (billing_status, 
payer tracking). Frontend needs payer data display.

Current task: [your current task]

Context: Sessions table has payer_uuid linking to payers table. 
Database has all data. API needs to JOIN payers table to return 
insurance company names.

Full details in FSC_PORTAL_MASTER_DOCUMENTATION.md
```

### For Cursor AI
```
FSC Portal - updating [filename]

Need: Add payers table JOIN to sessions query
Location: [file path]
Issue: Frontend shows "Unknown", data exists in DB

Database:
- sessions.payer_uuid → payers.id
- Need: include payers.name as insurance_company

See FSC_PORTAL_MASTER_DOCUMENTATION.md for schema details
```

---

## 🔍 SUCCESS = THIS WORKING

```
Sessions Table in UI:
Date | Client | Provider | Insurance Company | Status
-----|--------|----------|-------------------|-------
9/18 | John   | Dr. Chen | Horizon BCBS NJ   | Pending
9/17 | Sarah  | Lauren   | AmeriHealth       | Pending
```

Currently shows "Unknown" - need to display actual company names.

---

## 🐛 COMMON ISSUES

**CORS Errors:** Check ALLOWED_ORIGIN in Render env vars  
**Auth Failures:** Verify Supabase keys in both frontend/backend  
**Database Errors:** Check RLS policies and foreign keys  
**Import Failures:** Verify CSV format and provider/client existence

---

## 📞 QUICK LINKS

- **Supabase Dashboard:** https://supabase.com/dashboard
- **Production App:** https://app.fscnj.com
- **Render Dashboard:** https://dashboard.render.com
- **Vercel Dashboard:** https://vercel.com/dashboard

---

**Save this file, update it every session, and you'll never lose context!** ⚡
