# ⚡ Demo Quick Reference Card

## 🔗 IMPORT URL (USE THIS!)
```
https://app.fscnj.com/case-manager/import
```

## 📂 CSV FILE LOCATION
```
/Users/dymirtatem/Downloads/appointments_report-3.csv
```

## ✅ EXPECTED RESULT
```
24 Records Imported
0 Flagged Rows
```

## 🚨 IF IMPORT BUTTON MISSING
Use direct URL above - functionality works, just UI cache issue

## 📊 DEMO FLOW (3 MIN)
1. Open import URL
2. Show insurance companies list
3. Upload CSV file
4. Show "24 imported" result
5. Navigate to Sessions page
6. Show imported data

## 🎯 KEY POINTS
- Auto-creates providers/clients
- Flags unknown insurance (not rejects)
- Production-ready system
- Nordic clean design

## 🔧 QUICK CHECKS
- Backend: Render dashboard (should be "Live")
- Database: `payer_uuid` is nullable
- Frontend: Vercel deployment `67d4e23`

## 💪 CONFIDENCE
Backend works ✅  
Database ready ✅  
CSV parsing fixed ✅  
Just UI routing/cache issue

**USE THE DIRECT URL AND YOU'RE GOLDEN!** 🎉

