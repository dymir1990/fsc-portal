# FSC Portal - User Validation Guide
## CSV Import & Revenue Cycle Management

**Prepared for:** Mackenzi  
**Date:** [Current Date]  
**Version:** Phase 2 Complete  

---

## 🎯 Overview

This guide will walk you through testing the FSC Portal's CSV import functionality and revenue cycle management features. The system is now production-ready with all UI improvements completed.

---

## 📋 Pre-Testing Checklist

### ✅ System Requirements
- [ ] Modern web browser (Chrome, Firefox, Safari, Edge)
- [ ] Stable internet connection
- [ ] Access to your SimplePractice CSV export
- [ ] Valid email address for login

### ✅ What's New in Phase 2
- **Mobile-responsive design** - Works on phones and tablets
- **Pagination** - Handle large datasets efficiently  
- **Professional error pages** - Better user experience
- **Enhanced navigation** - Active states and user menu
- **Your FSC logo** - Professional branding throughout

---

## 🚀 Step-by-Step Testing Guide

### Step 1: Access the Portal
1. **Navigate to:** `https://app.fscnj.com` (or your deployed URL)
2. **Expected:** Redirects to login page
3. **Enter your email** and click "Send Magic Link"
4. **Check your email** for the magic link
5. **Click the link** to access the portal

### Step 2: Explore the Dashboard
1. **Verify you see:**
   - Real-time session counts
   - Recent activity feed
   - Professional FSC branding
   - Responsive navigation

2. **Test mobile view:**
   - Resize browser window or use mobile device
   - Verify hamburger menu works
   - Check that all features are accessible

### Step 3: Review Sessions Page
1. **Navigate to:** Sessions (left sidebar)
2. **Verify features:**
   - Pagination controls (if you have many sessions)
   - Search functionality
   - Status filters (All, Pending, Submitted, Billing)
   - Billing status badges
   - Responsive table design

### Step 4: Test CSV Import (Main Focus)
1. **Navigate to:** Import CSV (left sidebar)
2. **Review the interface:**
   - Payers table showing available insurance companies
   - Upload area with drag-and-drop
   - Clear instructions

3. **Upload your SimplePractice CSV:**
   - Click "Choose File" or drag CSV into upload area
   - **Expected:** File uploads and processes
   - **Look for:** Success message with import summary

4. **Review import results:**
   - Check flagged rows (if any)
   - Verify billing status assignments
   - Confirm data accuracy

### Step 5: Verify Data Integration
1. **Return to Sessions page**
2. **Verify new sessions appear**
3. **Check billing status badges**
4. **Test search and filters**

---

## 🔍 What to Look For

### ✅ Positive Indicators
- **Smooth upload process** - No errors or timeouts
- **Accurate data mapping** - Client/provider names correct
- **Proper billing status** - Sessions marked appropriately
- **Responsive design** - Works on your device
- **Professional appearance** - Clean, branded interface

### ⚠️ Potential Issues to Report
- **Upload failures** - File not processing
- **Data mismatches** - Incorrect client/provider names
- **Missing payers** - Insurance company not in dropdown
- **UI problems** - Layout issues on your device
- **Performance issues** - Slow loading or freezing

---

## 📊 Expected CSV Format

Your SimplePractice CSV should include these columns:
- **Client Name** (or Client ID)
- **Provider Name** (or Provider ID)  
- **Session Date**
- **Duration** (minutes)
- **Session Type** (optional)
- **Notes** (optional)

### Sample Data Structure
```csv
Client Name,Provider Name,Session Date,Duration,Session Type
John Smith,Jane Doe,2024-01-15,50,Individual Therapy
Mary Johnson,Bob Wilson,2024-01-16,45,Group Session
```

---

## 🎨 UI Features to Test

### Navigation
- [ ] **Active page highlighting** - Current page is highlighted
- [ ] **Mobile menu** - Hamburger menu works on mobile
- [ ] **User menu** - Click avatar to see dropdown
- [ ] **Sign out** - Works properly

### Data Display
- [ ] **Pagination** - Navigate through large datasets
- [ ] **Search** - Find specific sessions
- [ ] **Filters** - Filter by status
- [ ] **Status badges** - Visual status indicators

### Responsive Design
- [ ] **Desktop view** - Full sidebar navigation
- [ ] **Tablet view** - Hamburger menu appears
- [ ] **Mobile view** - Touch-friendly interface
- [ ] **Error pages** - Professional 404/500 pages

---

## 📝 Feedback Collection

### Please Note:
1. **Overall experience** - How does the interface feel?
2. **CSV import process** - Was it intuitive?
3. **Data accuracy** - Are sessions imported correctly?
4. **Missing features** - What would you add?
5. **UI improvements** - Any visual/UX suggestions?
6. **Performance** - Any speed or loading issues?

### Specific Questions:
- **Are all your insurance payers listed?** If not, which ones are missing?
- **Do the billing status badges make sense?** Any confusion?
- **Is the mobile experience good?** Can you use it on your phone?
- **Would you use this daily?** What would make it better?

---

## 🆘 Troubleshooting

### Common Issues & Solutions

**"File upload failed"**
- Check file size (should be under 10MB)
- Verify CSV format
- Try refreshing the page

**"No sessions imported"**
- Check CSV column headers
- Verify data format
- Contact support if needed

**"Can't find my insurance company"**
- Note which payer is missing
- We'll add it to the system

**"Mobile menu not working"**
- Try refreshing the page
- Check browser compatibility

---

## 📞 Support Information

### During Testing
- **Email:** support@fscnj.com
- **Response time:** Within 2 hours during business hours
- **Include:** Screenshots of any issues

### After Testing
- **Schedule follow-up call** if needed
- **Provide detailed feedback** on any issues
- **Suggest improvements** for future versions

---

## 🎯 Success Criteria

### ✅ Test Passes If:
- CSV uploads successfully
- Sessions appear in the system
- Billing statuses are assigned correctly
- Interface is responsive and professional
- No critical errors occur

### 📈 Next Steps After Testing:
1. **Address any issues** you report
2. **Add missing payers** to the system
3. **Implement UI improvements** you suggest
4. **Deploy to production** for daily use
5. **Schedule training session** for your team

---

## 📋 Testing Checklist

### Core Functionality
- [ ] Login with magic link
- [ ] Navigate through all pages
- [ ] Upload CSV file
- [ ] Verify data import
- [ ] Test search and filters
- [ ] Check pagination

### UI/UX Testing
- [ ] Test on desktop browser
- [ ] Test on mobile device
- [ ] Verify responsive design
- [ ] Check error pages
- [ ] Test user menu
- [ ] Verify navigation states

### Data Validation
- [ ] Client names correct
- [ ] Provider names correct
- [ ] Session dates accurate
- [ ] Billing statuses appropriate
- [ ] No duplicate sessions
- [ ] All sessions imported

---

**Thank you for testing the FSC Portal! Your feedback is crucial for making this system perfect for your team's needs.**

*This document will be updated based on your testing results and feedback.*
