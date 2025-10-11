# FSC Portal - Role Management Guide

## Overview

Your FSC Portal now has a complete role management system with 4 role levels:

1. **Admin** - Full access (you!)
2. **Director** - Management level
3. **Billing** - Billing department
4. **Provider** - Therapists (future)

---

## 🚀 Setup Instructions

### Step 1: Run the SQL Setup

1. Go to your **Supabase Dashboard**: https://supabase.com/dashboard
2. Open your FSC Portal project
3. Click on **SQL Editor** in the left sidebar
4. Click **New Query**
5. Copy and paste ALL the SQL from `supabase-setup.sql`
6. **IMPORTANT**: Replace `'your.email@fscnj.com'` with YOUR actual email (line 72)
7. Click **Run** or press `Ctrl/Cmd + Enter`

**This creates:**
- ✅ `profiles` table to store user roles
- ✅ Automatic profile creation when users sign up
- ✅ Security policies (only admins can change roles)
- ✅ Makes YOU an admin

---

## 👥 Understanding Each Role

### 1. Admin (You)
**Who gets this role:**
- Dymir (you)
- Practice owner
- Technical administrator

**What they can see/do:**
- ✅ Everything in the portal
- ✅ Manage all users and assign roles
- ✅ View all sessions and billing
- ✅ Import CSV files
- ✅ Manage payers and payroll
- ✅ View all reports

**Sidebar menu shows:**
- Dashboard
- Sessions
- Import CSV
- Work Queue
- Billing
- Reports
- Payers
- Payroll
- **Users** (only admins see this)

---

### 2. Director
**Who gets this role:**
- Clinical Directors
- Practice Managers
- Operations leads

**What they can see/do:**
- ✅ View all sessions
- ✅ Import CSV files
- ✅ Manage work queue
- ✅ View reports
- ✅ Manage payers
- ❌ **Cannot** see billing financials
- ❌ **Cannot** see payroll
- ❌ **Cannot** manage user roles

**Sidebar menu shows:**
- Dashboard
- Sessions
- Import CSV
- Work Queue
- Reports
- Payers

---

### 3. Billing
**Who gets this role:**
- Billing specialists
- Billing coordinators
- Claims processors

**What they can see/do:**
- ✅ View dashboard (limited)
- ✅ See only THEIR assigned work
- ❌ **Cannot** see all sessions
- ❌ **Cannot** import files
- ❌ **Cannot** see reports
- ❌ **Cannot** change settings

**Sidebar menu shows:**
- Dashboard
- My Work (only their assigned tasks)

---

### 4. Provider (Future)
**Who gets this role:**
- Therapists
- Clinicians
- Service providers

**What they will see/do:**
- ✅ Their own sessions only
- ✅ Submit clinical notes
- ✅ Check their billing status
- ❌ Cannot see other providers' data

**Sidebar menu will show:**
- Dashboard (my sessions)
- My Sessions
- Submit Notes

---

## 📋 How to Assign Roles

### Method 1: Using the Portal (Easiest)

1. **Sign in as admin** (you)
2. Look at the sidebar, click **"Users"** at the bottom
3. You'll see a table with all users
4. Find the person you want to change
5. Click the dropdown in the **"Actions"** column
6. Select their new role:
   - Admin
   - Director
   - Billing
   - Provider
7. ✅ Done! Role updated instantly

**The user will see their new menu next time they refresh.**

---

### Method 2: Using Supabase SQL (Manual)

If you need to do it manually in Supabase:

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Run one of these commands:

**Make someone an Admin:**
```sql
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'user@fscnj.com';
```

**Make someone a Director:**
```sql
UPDATE public.profiles
SET role = 'director'
WHERE email = 'user@fscnj.com';
```

**Make someone Billing:**
```sql
UPDATE public.profiles
SET role = 'billing'
WHERE email = 'user@fscnj.com';
```

**Make someone a Provider:**
```sql
UPDATE public.profiles
SET role = 'provider'
WHERE email = 'user@fscnj.com';
```

---

### Method 3: View All Users & Roles

To see everyone's role in Supabase:

```sql
SELECT email, role, full_name, created_at
FROM public.profiles
ORDER BY created_at DESC;
```

---

## 🔒 Security Features

### What's Protected:

1. **New users default to "billing" role** - Safest default
2. **Only admins can change roles** - Others can't promote themselves
3. **Everyone can only see their own profile** - Privacy protected
4. **Roles control sidebar menu** - Users only see what they can access
5. **Backend API checks roles too** - Frontend restrictions backed by server

---

## 🆕 When Someone New Joins

### Automatic Process:

1. New staff member signs up at **app.fscnj.com**
2. They enter email + password
3. **System automatically creates them as "billing" role**
4. They sign in and see the billing menu only
5. **You assign their real role** using the Users page

### Your Steps:

1. Go to **Users** page in the portal
2. Find the new person
3. Change their role dropdown to the correct role
4. Tell them to refresh the page
5. ✅ They now see the correct menu

---

## 🔐 Password Reset Feature

### How It Works:

1. User goes to **app.fscnj.com/login**
2. Clicks **"Forgot Password?"** link
3. Enters their email
4. Clicks **"Send Reset Link"**
5. They receive an email from Supabase
6. They click the link in the email
7. They're taken to **app.fscnj.com/reset-password**
8. They enter new password twice
9. ✅ Password updated, redirected to dashboard

---

## 📊 Role Assignment Examples

### Typical Staff Structure:

**You (Dymir)** → `admin`
- Full control of everything

**Practice Manager (Sarah)** → `director`
- Manages operations, sees reports, but not financials

**Billing Coordinator (Maria)** → `billing`
- Only sees her assigned billing tasks

**Therapist (Dr. Johnson)** → `provider`
- Only sees his own sessions and notes

---

## ❓ Common Questions

### Q: Can a Director change their own role to Admin?
**A:** No. Only admins can change roles.

### Q: What happens if I accidentally remove my admin role?
**A:** Use Supabase SQL Editor to restore it:
```sql
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'your.email@fscnj.com';
```

### Q: Can I have multiple admins?
**A:** Yes! Assign as many admins as you want.

### Q: What if someone's role doesn't update?
**A:** Tell them to:
1. Sign out
2. Sign back in
3. Or refresh the page (Cmd+R or Ctrl+R)

### Q: How do I see who has what role?
**A:** Click **Users** in the sidebar (admin only)

### Q: Can billing staff see financial data?
**A:** No, they only see their assigned tasks in "My Work"

---

## 🚨 Troubleshooting

### Problem: User says "Access Denied" on a page
**Solution:** Check their role - they might not have permission

### Problem: New user can't sign in
**Solution:**
1. Check Supabase Auth → Users
2. Make sure their email is confirmed
3. Check if profile was created

### Problem: User doesn't see expected menu items
**Solution:**
1. Check their role in Users page
2. Tell them to refresh
3. Make sure they signed out and back in

### Problem: Password reset email not arriving
**Solution:**
1. Check spam folder
2. Verify email templates in Supabase → Authentication → Email Templates
3. Make sure Supabase email service is configured

---

## 📝 Next Steps

After setup:

1. ✅ Run the SQL setup (make yourself admin)
2. ✅ Sign in and verify you see the **Users** menu
3. ✅ Test the **Forgot Password** feature
4. ✅ Create test accounts for each role
5. ✅ Assign roles to your existing staff
6. ✅ Show staff how to reset passwords

---

## 🎯 Quick Reference

| Role | Dashboard | Sessions | Import | Queue | Billing | Reports | Settings | Users |
|------|-----------|----------|--------|-------|---------|---------|----------|-------|
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Director | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | Partial | ❌ |
| Billing | Limited | ❌ | ❌ | ❌ | My Work | ❌ | ❌ | ❌ |
| Provider | My Data | My Data | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

**Need help? Message Chizu or check the Supabase docs!**
