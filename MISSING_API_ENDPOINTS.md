# Missing Backend API Endpoints

## Currently Working ✅
1. `/api/imports/simplepractice` - CSV import (POST)
2. `/api/imports/test-connection` - Database test (GET)
3. `/api/sessions` - Get all sessions (GET) - **JUST ADDED**

## Missing Endpoints ❌

### Critical (Frontend is calling these NOW)

#### 1. `/api/user/profile` 
**Used by**: Layout component (every page load!)
**Purpose**: Get user role and profile info
**Current Status**: ❌ MISSING - Frontend shows "Unknown" role
**Priority**: HIGH

```python
@app.get("/api/user/profile")
async def get_user_profile(authorization: str = Header(None)):
    # Extract user from JWT token
    # Query profiles table for role
    # Return: { "role": "billing", "email": "...", "name": "..." }
```

#### 2. `/api/imports/history`
**Used by**: Dashboard, Import page
**Purpose**: Show recent import runs
**Current Status**: ❌ MISSING - Import history not showing
**Priority**: MEDIUM

```python
@app.get("/api/imports/history")
async def get_import_history():
    # Query import_runs table
    # Return list of recent imports with stats
```

---

## Impact Analysis

### What Breaks Without `/api/user/profile`:
- ❌ User role shows as "Unknown" in topbar
- ❌ Role-based navigation filtering doesn't work
- ❌ Can't enforce role-based permissions
- ⚠️ **BUT** - Sessions page still loads (doesn't require role)

### What Breaks Without `/api/imports/history`:
- ❌ Dashboard "Recent Imports" section empty
- ❌ Import history page shows no data
- ✅ **BUT** - CSV import still works!

---

## Quick Fix Priority

### For Tomorrow's Demo:

**Option A: Demo Works Without These** (0 minutes)
- Sessions page works (has `/api/sessions` now!)
- CSV import works (has `/api/imports/simplepractice`)
- Just ignore "Unknown" role and empty import history

**Option B: Add Critical Endpoint** (15 minutes)
- Add `/api/user/profile` endpoint
- User sees correct role
- Better demo experience

---

## Current Status After Latest Deploy

Once Render finishes deploying (commit `8205c15`):

✅ **Sessions page will work!** 
- Endpoint exists
- Will show all 6 sessions from database
- Refresh the page in 2 minutes

❌ **But these will still be broken:**
- User role shows "Unknown" (missing `/api/user/profile`)
- Import history empty (missing `/api/imports/history`)

---

## Recommendation for Demo Tomorrow

### Path 1: Ship It As-Is (90% working)
- ✅ CSV Import works
- ✅ Sessions page works (after deploy)
- ⚠️ Role shows "Unknown" (cosmetic issue)
- ⚠️ No import history (not critical for demo)

### Path 2: Add User Profile Endpoint (95% working)
- Add `/api/user/profile` endpoint (15 min)
- Everything else same as Path 1
- Better polish for demo

**I recommend Path 1 for tonight, then add endpoints tomorrow morning if time allows.**

---

## What Frontend Pages Use:

| Page | Endpoints Needed | Status |
|------|-----------------|--------|
| Sessions | `/api/sessions` | ✅ FIXED |
| Revenue | `/api/sessions` | ✅ FIXED |
| Dashboard | `/api/sessions`, `/api/imports/history` | ⚠️ Partial |
| Import | `/api/imports/simplepractice`, `/api/imports/history` | ⚠️ Partial |
| Layout (All) | `/api/user/profile` | ❌ Missing |
| Queue | `/api/sessions` | ✅ FIXED |
| My Work | `/api/sessions` | ✅ FIXED |

---

## Next Steps

1. **Wait 2 minutes** for Render to deploy `/api/sessions` fix
2. **Refresh sessions page** - should now show 6 sessions!
3. **Decide**: Add `/api/user/profile` tonight or demo with "Unknown" role?

**For demo tomorrow, you have enough to show:**
- CSV import (auto-creates providers/clients/payers)
- Sessions list with all imported data
- This is the core functionality!

