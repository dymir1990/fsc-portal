
# FSC Portal - Quick Start

## 🚀 Deploy to Production (Render + Vercel)

### Step 1: Deploy Backend to Render

```bash
# Push your latest changes
git add .
git commit -m "Production-ready fixes"
git push origin main

# Deploy using Render Blueprint
# 1. Go to https://dashboard.render.com
# 2. Click "New +" → "Blueprint"
# 3. Connect this repo
# 4. Render auto-detects render.yaml
# 5. Add environment variables:
#    - SUPABASE_URL
#    - SUPABASE_SERVICE_ROLE_KEY
#    - ALLOWED_ORIGIN (default: https://app.fscnj.com)
# 6. Click "Apply"
```

**Or use Render CLI:**
```bash
render blueprint launch
```

### Step 2: Update Frontend Environment

```bash
# In Vercel dashboard, update these env vars:
# PUBLIC_API_BASE=https://fsc-portal-backend.onrender.com
# PUBLIC_SUPABASE_URL=your_supabase_url
# PUBLIC_SUPABASE_ANON_KEY=your_anon_key

# Then redeploy
cd frontend
vercel --prod
```

---

## 💻 Local Development

### Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Create .env file
cat > .env <<EOF
SUPABASE_URL=your_project_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
ALLOWED_ORIGIN=http://localhost:5173
EOF

# Run server
uvicorn main:app --reload --port 8001
```

### Frontend
```bash
cd frontend
npm install

# Create .env file
cat > .env <<EOF
PUBLIC_SUPABASE_URL=your_project_url
PUBLIC_SUPABASE_ANON_KEY=your_anon_key
PUBLIC_API_BASE=http://localhost:8001
EOF

# Run dev server
npm run dev
```

Visit: http://localhost:5173

---

## 🧪 Test Import Flow

```bash
# 1. Sign in with magic link
# 2. Upload sample CSV:
backend/sample_data/simplepractice_mock.csv

# Or test with API:
export TEST_USER_JWT="your_jwt_token"
export BACKEND_URL="http://localhost:8001"
python3 scripts/test_import.py
```

---

## 📊 Database Setup

### Required Tables

Run migration:
```sql
-- In Supabase SQL Editor
\i backend/sql/2024-09-28-update-sessions.sql
```

### Seed Payers
```sql
INSERT INTO public.payers (name, billing_route, status) VALUES
('Aetna', 'portal', 'Active'),
('AmeriHealth', 'portal', 'Active'),
('Horizon NJ Health', 'portal', 'Active'),
('Medicaid', 'simplepractice', 'Active'),
('Medicare', 'simplepractice', 'Active'),
('Oscar Health Insurance', 'portal', 'Active'),
('United Healthcare', 'portal', 'Active')
ON CONFLICT (name) DO UPDATE
SET billing_route = EXCLUDED.billing_route,
    status = EXCLUDED.status;
```

### Seed Test Data (Optional)
```sql
-- Add sample providers
INSERT INTO public.providers (name, email) VALUES
('Dr. Lauren Rivera', 'lrivera@fscnj.com'),
('Dr. David Chen', 'dchen@fscnj.com')
ON CONFLICT DO NOTHING;

-- Add sample clients
INSERT INTO public.clients (name, email) VALUES
('Alex Johnson', 'ajohnson@example.com'),
('Brianna Smith', 'bsmith@example.com')
ON CONFLICT DO NOTHING;
```

---

## 🔍 Verify Deployment

### Backend Health
```bash
curl https://fsc-portal-backend.onrender.com/health
# Expected: {"ok":true}
```

### Frontend Health
```bash
curl https://app.fscnj.com
# Expected: 200 OK
```

### Auth Flow
1. Visit https://app.fscnj.com
2. Should redirect to /login
3. Enter email → receive magic link
4. Click link → redirects to /dashboard
5. Dashboard shows real stats

### CSV Import
1. Go to "Import CSV"
2. See payers table populated
3. Upload CSV
4. See success message with counts
5. Check dashboard for updated numbers

---

## 🐛 Troubleshooting

### CORS Errors
```bash
# Check backend logs in Render dashboard
# Verify ALLOWED_ORIGIN matches frontend URL exactly
# Ensure no trailing slash
```

### Auth Failures
```bash
# Verify Supabase keys in both backend and frontend
# Check Supabase Auth settings (email templates enabled)
# Verify magic link redirect URL in Supabase dashboard
```

### Database Errors
```bash
# Check Supabase RLS policies
# Verify foreign key relationships exist
# Ensure service role key has admin access
```

### Import Failures
```bash
# Check CSV format matches expected columns
# Verify providers/clients exist in DB
# Check backend logs for specific errors
```

---

## 📚 Key Files

- `render.yaml` - Render deployment config
- `DEPLOYMENT.md` - Full deployment guide
- `FIXES_APPLIED.md` - Recent fixes documentation
- `backend/main.py` - API server
- `frontend/src/routes/` - UI pages
- `docs/billing-routes.md` - Payer reference

---

## 🎯 Next Steps

After deployment:
1. ✅ Test full user flow
2. ✅ Import real CSV from SimplePractice
3. ✅ Verify data accuracy
4. 🔄 Set up monitoring (Sentry/LogRocket)
5. 🔄 Add automated tests
6. 🔄 Document for Mackenzi (user training)

---

## 💡 Pro Tips

**Backend URLs:**
- Render free tier: `https://your-service.onrender.com`
- Spins down after 15min inactivity (first request slow)

**Frontend URLs:**
- Vercel production: `https://app.fscnj.com`
- Preview deploys: `https://fsc-portal-git-branch.vercel.app`

**Environment Variables:**
- Backend: Set in Render dashboard
- Frontend: Set in Vercel dashboard
- Local: Use `.env` files (gitignored)

**Database:**
- Use Supabase dashboard for schema changes
- Export SQL migrations for version control
- Always test with service role key first
