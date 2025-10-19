# FSC Portal - Phase 2 Implementation Seed Document

## 🎯 **Current Status: Phase 2 Week 1 COMPLETE**

### ✅ **What's Been Accomplished (October 18, 2025)**

#### **Database Foundation (100% Complete)**
- ✅ **Billing Status Enum**: 10-stage lifecycle (completed → documented → ready_to_bill → submitted → pending → approved → paid → denied → appealing)
- ✅ **New Tables Created**:
  - `insurance_portals` - Track insurance portal information
  - `payments` - Record actual payments received
  - `payment_sessions` - Link payments to specific sessions
  - `session_status_history` - Audit trail for status changes
  - `alerts` - System-generated alerts for aging claims
- ✅ **Sessions Table Enhanced**: Added billing_status, amount_billed, amount_paid, date_submitted, date_paid, denial_reason, insurance_portal_id, payment_reference, last_status_change
- ✅ **Views Created**: dashboard_metrics, aging_report
- ✅ **Triggers**: Auto-log status changes, aging claim alerts
- ✅ **Constraints**: amount_paid <= amount_billed validation

#### **Frontend Components (100% Complete)**
- ✅ **BillingStatusBadge.svelte**: Color-coded status indicators with icons
- ✅ **Sessions Page Enhanced**: Shows billing status badges, amount columns, new "Billing" filter
- ✅ **Revenue Dashboard**: Basic metrics cards, status overview, quick actions
- ✅ **Backend API Updated**: `/api/sessions` includes billing fields

#### **User Role System (100% Complete)**
- ✅ **Added "billing" role** to user_role enum
- ✅ **Role-based access** for billing features

---

## 🚀 **Next Immediate Steps (15-30 minutes)**

### **1. Frontend Testing (5-10 minutes)**
- [ ] Visit `/sessions` - verify billing status badges appear
- [ ] Visit `/billing/revenue` - verify revenue dashboard loads
- [ ] Upload test CSV - verify billing_status = 'completed' is set
- [ ] Test billing status filter functionality

### **2. Mackenzi Validation Session (10-15 minutes)**
- [ ] Send walkthrough email with current features
- [ ] Schedule 30-minute session
- [ ] Test with real SimplePractice CSV
- [ ] Capture feedback on workflow and UI

### **3. Quick Polish (5-10 minutes)**
- [ ] Fix any UI issues from Mackenzi feedback
- [ ] Update documentation
- [ ] Commit final Phase 2 Week 1 changes

---

## 📋 **Phase 2 Remaining Work (Weeks 2-8)**

### **Week 2: Core UI Components**
- [ ] StatusDropdown component with validation
- [ ] AlertBanner component
- [ ] SessionCard component
- [ ] Update Sessions page with status change functionality

### **Week 3: Revenue Dashboard**
- [ ] Full 7-key metrics implementation
- [ ] Collections trend chart (Chart.js)
- [ ] Recent payments table
- [ ] Role-based access (admin, director only)

### **Week 4: Aging Report**
- [ ] Filters (age bracket, payer, provider, status)
- [ ] Color-coded aging table
- [ ] Bulk selection and actions
- [ ] Export to CSV functionality

### **Week 5: Payment Entry**
- [ ] Payment entry form
- [ ] Session search & selection
- [ ] Payment amount validation
- [ ] Auto-update session status to "paid"

### **Week 6: Claim Tracker & Session Detail**
- [ ] Claims search and filtering
- [ ] Session detail page with timeline
- [ ] Quick actions (update status, add notes)

### **Week 7: Work Queue & Alerts**
- [ ] Work queue with assigned sessions
- [ ] Alert banners (critical, warning, info)
- [ ] Daily cron job for aging alerts
- [ ] Automated alert generation

### **Week 8: Polish & Testing**
- [ ] Mobile responsive testing
- [ ] Error handling & user feedback
- [ ] User training documentation
- [ ] Production deployment

---

## 🔧 **Technical Implementation Notes**

### **Database Schema**
- **Migration Scripts**: All in `backend/sql/` directory
- **Key Files**: `phase2-migration-resume.sql`, `create-views-fixed.sql`
- **Views**: `dashboard_metrics`, `aging_report` are working
- **Constraints**: `amount_paid_lte_billed` constraint active

### **Frontend Components**
- **Status Badge**: `frontend/src/lib/components/BillingStatusBadge.svelte`
- **Sessions Page**: `frontend/src/routes/(app)/sessions/+page.svelte`
- **Revenue Dashboard**: `frontend/src/routes/(app)/billing/revenue/+page.svelte`
- **Backend API**: `backend/main.py` updated with billing fields

### **Environment Variables**
- **Backend**: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, ALLOWED_ORIGIN
- **Frontend**: PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, PUBLIC_API_BASE

---

## 📊 **Key Metrics to Track**

1. **Unbilled Sessions**: <10 (target)
2. **Outstanding Claims ($)**: Track vs goal
3. **Avg Days to Payment**: <45 days (target)
4. **Aging >90 Days**: 0 claims (target)
5. **Denial Rate**: <5% (target)
6. **This Month Collections**: Track vs budget
7. **Claims per Staff**: Workload balance

---

## 🎯 **Success Criteria**

### **Phase 2 Week 1 (COMPLETE)**
- ✅ Database foundation with 10-stage billing lifecycle
- ✅ Basic UI components for status tracking
- ✅ Revenue dashboard with key metrics
- ✅ User validation ready

### **Phase 2 Complete (Target: 8 weeks)**
- [ ] Complete revenue cycle management system
- [ ] Automated aging alerts
- [ ] Payment reconciliation
- [ ] Work queue for billing staff
- [ ] Production-ready with monitoring

---

## 📞 **Key Contacts & Resources**

- **Primary User**: Mackenzi (validation and feedback)
- **Database**: Supabase (Production environment)
- **Frontend**: Vercel deployment
- **Backend**: Render deployment
- **Documentation**: All in project root directory

---

## 🚨 **Known Issues & Solutions**

### **Resolved Issues**
- ✅ Enum casting error: Fixed with proper DROP/CREATE sequence
- ✅ Constraint already exists: Fixed with IF EXISTS clauses
- ✅ Missing payer_id column: Fixed views to work with actual schema
- ✅ Role enum missing "billing": Added successfully

### **Current Status**
- 🟢 **Database**: Fully functional
- 🟢 **Backend API**: Working correctly
- 🟢 **Frontend Components**: Ready for testing
- 🟡 **User Validation**: Pending Mackenzi session

---

## 📝 **Next Chat Session Focus**

When starting a new chat session, focus on:

1. **Frontend Testing**: Verify all Phase 2 Week 1 features work
2. **Mackenzi Validation**: Schedule and conduct user testing
3. **Week 2 Planning**: Begin core UI components development
4. **Documentation**: Update user guides and technical docs

**Estimated Time to Complete Phase 2**: 6-7 weeks (full-time developer)
**Current Progress**: Week 1 Complete (12.5% of Phase 2)

---

*Last Updated: October 18, 2025*
*Status: Phase 2 Week 1 Complete - Ready for User Validation*
