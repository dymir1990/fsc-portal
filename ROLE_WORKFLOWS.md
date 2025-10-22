# 🎯 FSC Portal - Role-Based Workflows & UX Design

**Nordic Design Philosophy:** Clean, simple, role-specific interfaces  
**Date:** October 22, 2025

---

## 🏥 **FSC Portal Roles (Mental Health Practice)**

### **1. 👨‍⚕️ Provider (Therapist/Clinician)**
**Who:** Dr. Kandice Cooper, Edison Jaquez, Diamond Williams, etc.  
**Focus:** Client care, documentation

#### Daily Tasks:
- ✅ See their upcoming sessions
- ✅ Complete session notes
- ✅ View their client roster
- ✅ Check which sessions need documentation

#### What They DON'T Need:
- ❌ Billing details
- ❌ Payment tracking
- ❌ Insurance portals
- ❌ Revenue metrics

#### Optimal UX:
```
📋 My Sessions
   ├─ Today's appointments
   ├─ Notes pending completion
   └─ Filter by client

👥 My Clients  
   └─ Active client list

📊 Simple Stats
   └─ Sessions this week/month
```

**Navigation:** 3 items max  
**Focus:** Clinical work, not billing

---

### **2. 💼 Billing Specialist**
**Who:** Mackenzi (your billing team member)  
**Focus:** Claims, payments, insurance portals

#### Daily Workflow:
1. **Morning:** Check overnight payments
2. **Daily:** Submit completed session claims to insurance
3. **Ongoing:** Follow up on denied/pending claims
4. **Weekly:** Reconcile payments vs. expected
5. **Monthly:** Aging report review

#### Key Tasks:
- ✅ Import sessions from SimplePractice
- ✅ Review flagged sessions (missing insurance)
- ✅ Submit claims to insurance portals
- ✅ Record payments when received
- ✅ Track claim status (submitted → pending → paid)
- ✅ Follow up on aging claims (30/60/90 days)
- ✅ Mark sessions as self-pay
- ✅ Add new insurance companies

#### What They Need Immediate Access To:
- 🎯 **Work Queue** - Sessions needing action
- 🎯 **Flagged Items** - Need clarification
- 🎯 **Revenue Dashboard** - Key metrics
- 🎯 **Aging Report** - Outstanding claims

#### Optimal UX (Nordic Clean):
```
💰 Revenue (Home)
   ├─ Quick metrics (unbilled, pending, collected)
   ├─ [Import CSV] button
   └─ Flagged items alert

📋 Sessions
   ├─ Filter by billing status
   ├─ Bulk actions
   └─ Quick status change

🏥 Insurance
   ├─ Payer list
   ├─ Portal links
   └─ Add new payer

📊 Reports
   └─ Aging, revenue, denials
```

**Navigation:** 4-5 items  
**Focus:** Revenue cycle efficiency

---

### **3. 📊 Case Manager/Care Coordinator**
**Who:** Coordinates client care across providers  
**Focus:** Client outcomes, provider coordination

#### Daily Tasks:
- ✅ Monitor client progress across providers
- ✅ Coordinate referrals
- ✅ Track client engagement
- ✅ Ensure continuity of care
- ✅ Flag at-risk clients

#### What They Need:
- Client-centric view (not session-centric)
- Provider coordination tools
- Client status tracking
- Notes/communication log

#### Optimal UX:
```
👥 Clients
   ├─ Active clients
   ├─ At-risk flags
   └─ Last contact date

📅 Care Plans
   └─ Client goals & progress

👨‍⚕️ Provider Coordination
   └─ Which provider sees which client
```

**Navigation:** 3-4 items  
**Focus:** Client wellbeing, coordination

---

### **4. 🔧 Admin/Director**
**Who:** You (Dymir)  
**Focus:** Oversight, strategy, system management

#### Tasks:
- ✅ Monitor overall practice health
- ✅ Review revenue metrics
- ✅ Manage users and permissions
- ✅ Configure system settings
- ✅ Oversee all workflows

#### What They Need:
- Full system access
- High-level dashboards
- User management
- System configuration

#### Optimal UX:
```
📊 Dashboard
   └─ Practice-wide metrics

💰 Revenue
   └─ Full financial view

👥 Team
   └─ Providers, billing, case managers

⚙️ Settings
   └─ System configuration
```

**Navigation:** All features  
**Focus:** Strategic oversight

---

## 🎨 **NORDIC UX RECOMMENDATIONS BY ROLE**

### **Billing Specialist (Mackenzi) - PRIMARY USER**

#### **Ultra-Clean 4-Item Navigation:**

1. **💰 Revenue** (Home/Default)
   - Revenue metrics at top
   - **[Import CSV]** button (prominent)
   - Flagged items table (needs attention)
   - Recent activity

2. **📋 Sessions**
   - All sessions table
   - Filter by status
   - Search by client/provider
   - Bulk select & actions
   - Quick status change dropdown

3. **🏥 Insurance**
   - Insurance companies list
   - Portal URLs (quick links)
   - **[Add Insurance]** button
   - Billing routes

4. **📊 Reports**
   - Aging report
   - Revenue trends
   - Denial tracking
   - Export options

---

## 🔄 **BILLING SPECIALIST WORKFLOW (Mackenzi's Day)**

### **Morning Routine (10 minutes):**
1. Open **Revenue** page → See yesterday's collections
2. Check **Flagged Items** section → Review items needing clarification
3. Go to **Sessions** → Filter "Note Submitted" → See what's ready to bill

### **Main Work (2-3 hours):**
1. **Import yesterday's sessions:**
   - Click **[Import CSV]** on Revenue page
   - Upload SimplePractice export
   - Review flagged items (unknown insurance/self-pay)
   - Clarify flagged items (add insurance or mark self-pay)

2. **Submit claims:**
   - Filter sessions: "Ready to Bill"
   - Bulk select sessions
   - Click **[Submit to Portal]** → Opens insurance portal
   - Mark sessions as "Submitted"

3. **Record payments:**
   - Check insurance portal for payments
   - Find matching sessions
   - Click session → **[Record Payment]**
   - System auto-updates status to "Paid"

### **Weekly Tasks (1 hour):**
1. **Aging Review:**
   - Open **Reports** → Aging Report
   - Filter claims >30 days
   - Follow up on pending claims
   - Appeal denials

---

## 🎯 **RECOMMENDED SYSTEM STRUCTURE**

### **Role-Based Landing Pages:**

```
Billing Specialist → Revenue Dashboard
Provider → My Sessions  
Case Manager → Clients Overview
Admin → Practice Dashboard
```

### **Shared Core:**
- Sessions table (different default filters by role)
- Search (global)
- Notifications (role-specific)

---

## 💡 **NORDIC DESIGN PRINCIPLES APPLIED**

### **1. Minimalism:**
- White space is your friend
- One primary action per page
- Hide complexity until needed

### **2. Clarity:**
- Clear labels (no jargon)
- Obvious next steps
- Visual hierarchy

### **3. Efficiency:**
- Most common tasks = 1-2 clicks
- Keyboard shortcuts for power users
- Bulk actions for repetitive work

### **4. Trust:**
- Clear feedback after actions
- Undo capability where possible
- No data loss

---

## 🚀 **IMPLEMENTATION PRIORITY**

### **Phase 1: Billing Specialist (Mackenzi) - NOW**
Focus on her workflow exclusively:
- ✅ Revenue dashboard
- ✅ CSV import with flagging
- ✅ Sessions table with filters
- ✅ Insurance companies management

### **Phase 2: Providers - LATER**
Simple provider view:
- ✅ My upcoming sessions
- ✅ Notes pending
- ✅ My clients

### **Phase 3: Case Manager - LATER**
Client-centric view:
- ✅ Client list
- ✅ Care coordination
- ✅ Risk flags

---

## 🎯 **FINAL RECOMMENDATION: SIMPLEST STRUCTURE**

### **For Mackenzi (Billing Specialist):**

```
Navigation (4 items):

💰 Revenue (Home)
   └─ Metrics + [Import CSV] + Flagged Items

📋 Sessions  
   └─ Table + Filters + Bulk Actions

🏥 Insurance
   └─ Payers + Portals + [Add New]

⚙️ Settings
   └─ Profile + Preferences
```

### **Remove:**
- ❌ `/case-manager/` routes (confusing terminology)
- ❌ `/billing/my-work` (redundant with Revenue)
- ❌ `/reports` separate page (put in Revenue)
- ❌ Multiple dashboards (one main dashboard)

### **Keep Clean:**
- ✅ One clear purpose per page
- ✅ Progressive disclosure
- ✅ Context-aware actions
- ✅ Minimal navigation

---

**This is the cleanest, most efficient structure for a small mental health practice!** 🇸🇪✨

