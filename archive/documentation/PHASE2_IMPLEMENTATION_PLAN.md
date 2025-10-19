# Phase 2 Implementation Plan - Week 1 Focus

## Immediate Actions (Today)

### 1. Database Foundation ✅
- [x] Created `backend/sql/phase2-database-foundation.sql` with complete schema
- [ ] Run SQL scripts in Supabase SQL Editor
- [ ] Verify all tables created successfully
- [ ] Test views (dashboard_metrics, aging_report)

### 2. Quick Wins (Next 2 hours)
- [ ] Add billing_status badges to existing Sessions page
- [ ] Create StatusBadge component for visual status indicators
- [ ] Update CSV import to set default billing_status
- [ ] Add basic aging query to dashboard

### 3. Mackenzi Validation Session (This Week)
- [ ] Schedule validation session
- [ ] Prepare test CSV with real SimplePractice data
- [ ] Document current workflow vs. new workflow
- [ ] Capture feedback on status tracking

## Week 1 Goals
1. **Database Foundation** - Complete revenue cycle tracking schema
2. **Visual Status Indicators** - Staff can see billing status at a glance
3. **User Validation** - Confirm workflow with Mackenzi
4. **Basic Metrics** - Show outstanding amounts and aging

## Next Steps After Week 1
- Week 2: Core UI Components (StatusDropdown, AlertBanner, SessionCard)
- Week 3: Revenue Dashboard with 7 key metrics
- Week 4: Aging Report with filters and bulk actions
- Week 5: Payment Entry and reconciliation
- Week 6: Claim Tracker and session detail pages
- Week 7: Work Queue and automated alerts
- Week 8: Polish, testing, and production deployment

## Key Metrics to Track
- Unbilled Sessions: <10
- Outstanding Claims ($): Track vs goal
- Avg Days to Payment: <45 days
- Aging >90 Days: 0 claims
- Denial Rate: <5%
- This Month Collections: Track vs budget
- Claims per Staff: Workload balance

## ROI Expectations
- Reduce manual portal checking: 5 hours/week → 1 hour/week (80% reduction)
- Faster payment reconciliation: 3 hours/week → 30 minutes/week
- Automated alerts eliminate manual tracking: 2 hours/week saved
- Revenue protection: Catch 2-3% of forgotten claims
- Break-even: Prevents losing $10,000/year in forgotten claims
