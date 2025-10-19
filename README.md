# 🏥 FSC Portal
## Billing Lifecycle Tracking System

**Status:** Phase 2 Backend Complete | Frontend Integration Needed  
**Last Updated:** October 19, 2025

---

## 📋 Quick Start

### Essential Documentation
- **📖 [Master Documentation](FSC_PORTAL_MASTER_DOCUMENTATION.md)** - Complete project reference
- **⚡ [Quick Handoff](QUICK_HANDOFF.md)** - Essential commands and context
- **🤖 [AI Handoff Template](CONTEXT_HANDOFF_TEMPLATE.md)** - For switching between AI assistants

### Project Status
- ✅ **Phase 1:** CSV import, session tracking, basic dashboard
- ✅ **Phase 2 Backend:** Billing status, insurance companies, payment tracking
- ⚠️ **Phase 2 Frontend:** UI integration to display payer data (In Progress)
- 📅 **Phase 3:** Advanced features, automation, reporting (TBD)

---

## 🚀 Quick Commands

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
git add .
git commit -m "descriptive message"
git push origin main
# Backend auto-deploys via Render Blueprint
# Frontend: Update Vercel environment variables
```

---

## 🏗️ Project Structure

```
fsc-portal/
├── 📖 FSC_PORTAL_MASTER_DOCUMENTATION.md  # Complete reference
├── ⚡ QUICK_HANDOFF.md                     # Essential commands
├── 🤖 CONTEXT_HANDOFF_TEMPLATE.md          # AI handoff format
├── 📁 frontend/                            # SvelteKit application
├── 📁 backend/                             # FastAPI server
├── 📁 sql/essential/                       # Database scripts
├── 📁 docs/                                # Additional documentation
├── 📁 archive/                             # Consolidated files
└── 📁 scripts/                              # Utility scripts
```

---

## 🔧 Tech Stack

- **Frontend:** SvelteKit + Tailwind CSS + TypeScript
- **Backend:** FastAPI + Python 3.12
- **Database:** Supabase (PostgreSQL)
- **Deployment:** Vercel (frontend) + Render (backend)
- **Domain:** app.fscnj.com

---

## 📊 Current State

### ✅ What's Working
- Database with complete Phase 2 schema
- Authentication flow (magic links)
- CSV import with validation
- Dashboard with real metrics
- Sessions browsing/search
- Payers reference table
- Backend API with billing endpoints

### ⚠️ What Needs Work
- Frontend Sessions table shows "Unknown" for payers
- API endpoints need payer JOIN
- Status change UI functionality
- Mobile navigation
- User menu completion

---

## 🎯 Immediate Next Steps

1. **Demo Prep** (Oct 20, 2025)
2. **Frontend Integration** - Update Sessions API to include payer data
3. **Status Change UI** - Add dropdown for billing status updates
4. **User Testing** - Validate with real SimplePractice CSV

---

## 📞 Support

- **Master Documentation:** [FSC_PORTAL_MASTER_DOCUMENTATION.md](FSC_PORTAL_MASTER_DOCUMENTATION.md)
- **Quick Reference:** [QUICK_HANDOFF.md](QUICK_HANDOFF.md)
- **Supabase Dashboard:** https://supabase.com/dashboard
- **Production App:** https://app.fscnj.com

---

## 📁 Archive

Historical files have been consolidated into the `archive/` directory. See [archive/README.md](archive/README.md) for details.

---

**This project uses a consolidated documentation approach to maintain clarity and reduce redundancy. Always refer to the master documentation for complete information.**
