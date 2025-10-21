# FSC Portal - Troubleshooting Guide
**Last Updated:** October 21, 2025

---

## 🔥 **Active Issues & Fixes**

### **Issue #1: CSV Upload Shows 0 Imported, All Flagged** ✅ FIXED

**Symptoms:**
- CSV file uploads successfully
- Shows "Upload Complete" message
- Total rows correct (e.g., 19)
- **0 Records Imported**
- **All rows flagged** (e.g., 19 flagged)
- Sessions don't appear in Sessions page

**Root Cause:**
The CSV import required providers (therapists) and clients (patients) to already exist in the database. If they didn't exist, sessions were flagged with reason "missing_provider" or "missing_client" instead of being imported.

**Fix Applied:** ✅ **Oct 21, 2025**
Updated the CSV import to automatically create providers and clients if they don't exist.

**Code Changes:**
- Added `find_or_create_provider()` function
- Added `find_or_create_client()` function  
- Modified import endpoint to use new functions
- Git commit: `9e45582`

**How to Verify Fix:**
1. Wait 5 minutes after deployment
2. Re-upload the same CSV file
3. Should see: **19 Records Imported, 0 Flagged**
4. Sessions appear in Sessions page with correct names

**Deployment:**
- **Status:** ✅ Deployed to production
- **Where:** Render backend (auto-deploy)
- **When:** Oct 21, 2025
- **ETA:** Live within 5 minutes of push

---

## 📋 **Common Issues**

### **Login Issues**

**"Magic link not received"**
- Check spam/junk folder
- Verify email address is correct
- Wait 1-2 minutes for email delivery
- Try different email address

**"Magic link expired"**
- Request a new magic link
- Magic links expire after 1 hour
- Click the newest link if multiple received

---

### **CSV Import Issues**

**"File upload failed"**
- Check file size (max 10MB)
- Verify file is .csv format
- Check file isn't corrupted
- Try refreshing page and re-uploading

**"Sessions not appearing"**
- Check Sessions page (not Dashboard)
- Use search to find specific sessions
- Check date filters
- Verify CSV had correct column headers

**"Wrong data in sessions"**
- Check CSV column headers match expected format
- Verify date format is correct
- Check client/provider names for typos

---

### **UI/Navigation Issues**

**"Mobile menu not working"**
- Tap hamburger icon (3 lines) in top-left
- Try refreshing page
- Verify using modern browser (Chrome/Safari)
- Check JavaScript isn't blocked

**"Pagination not showing"**
- Only appears when >25 sessions exist
- Check total session count
- Try changing items per page

**"User menu not opening"**
- Click avatar/email in top-right
- Try refreshing page
- Check for JavaScript errors

---

## 🔍 **Diagnostic Queries**

Run these in Supabase SQL Editor to diagnose issues:

### **Check Last Import**
```sql
SELECT * FROM import_runs 
ORDER BY started_at DESC 
LIMIT 1;
```

### **Check Flagged Rows**
```sql
SELECT reason, COUNT(*) as count
FROM import_staging
WHERE run_id = (SELECT id FROM import_runs ORDER BY started_at DESC LIMIT 1)
GROUP BY reason;
```

### **Check Providers**
```sql
SELECT * FROM providers ORDER BY name;
```

### **Check Clients**
```sql
SELECT * FROM clients ORDER BY name;
```

### **Check Recent Sessions**
```sql
SELECT 
  s.session_date,
  c.name as client_name,
  p.name as provider_name,
  s.billing_status
FROM sessions s
LEFT JOIN clients c ON s.client_id = c.id
LEFT JOIN providers p ON s.provider_id = p.id
ORDER BY s.session_date DESC
LIMIT 20;
```

---

## 🚀 **Performance Issues**

**"Slow loading"**
- Check internet connection
- Verify Render/Vercel status
- Check browser console for errors
- Try incognito/private mode

**"Sessions page slow with many records"**
- Use pagination (default 25 per page)
- Use search to filter results
- Use status filters to narrow down
- Consider archiving old sessions

---

## 📞 **Getting Help**

### **During Testing:**
1. Take screenshots of error
2. Note what you were trying to do
3. Check browser console (F12) for errors
4. Email: support@fscnj.com

### **Error Information to Include:**
- What you were trying to do
- Error message (exact text)
- Screenshot of issue
- Browser and device used
- Time/date of issue

---

## 🔧 **Developer Debugging**

### **Check Backend Logs (Render):**
1. Go to https://dashboard.render.com
2. Find "fsc-portal-backend"
3. Click "Logs" tab
4. Look for errors around upload time

### **Check Frontend Logs (Browser):**
1. Open browser DevTools (F12)
2. Click "Console" tab
3. Look for red error messages
4. Check "Network" tab for failed requests

### **Common Error Codes:**
- **401:** Authentication failed
- **403:** Permission denied
- **404:** Resource not found
- **500:** Server error
- **502/503:** Backend unavailable

---

## ✅ **Known Fixed Issues**

### **✅ CSV Import Not Creating Sessions** - Fixed Oct 21, 2025
- **Issue:** Providers/clients had to exist before import
- **Fix:** Auto-create providers and clients during import
- **Status:** Deployed to production

### **✅ Mobile Navigation Missing** - Fixed Oct 21, 2025
- **Issue:** No way to navigate on mobile devices
- **Fix:** Added hamburger menu with responsive design
- **Status:** Deployed to production

### **✅ No Pagination** - Fixed Oct 21, 2025
- **Issue:** Large datasets caused slow loading
- **Fix:** Added pagination with 10/25/50/100 options
- **Status:** Deployed to production

### **✅ No Error Pages** - Fixed Oct 21, 2025
- **Issue:** Generic browser errors on 404/500
- **Fix:** Custom branded error pages
- **Status:** Deployed to production

---

## 🎯 **Quick Fixes**

**Clear browser cache:**
```
Chrome: Cmd+Shift+Delete (Mac) or Ctrl+Shift+Delete (Windows)
Safari: Cmd+Option+E (Mac)
```

**Force refresh:**
```
Chrome/Safari: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
```

**Check deployment status:**
- Backend: https://dashboard.render.com
- Frontend: https://vercel.com/dashboard

---

**Last Updated:** October 21, 2025  
**Version:** Week 3 + Live Testing Fixes
