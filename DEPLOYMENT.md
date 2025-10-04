# FSC Portal - Deployment Guide

## Backend (Render)

### Initial Setup

1. **Connect Repository to Render**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New +" → "Blueprint"
   - Connect your GitHub repository
   - Render will auto-detect `render.yaml`

2. **Configure Environment Variables**

   In Render dashboard, add these secrets:

   ```
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   ALLOWED_ORIGIN=https://app.fscnj.com
   ```

3. **Deploy**
   - Render will automatically build and deploy
   - Health check endpoint: `https://your-app.onrender.com/health`

### Manual Deployment (Alternative)

If not using Blueprint:

1. Create new Web Service
2. **Settings:**
   - Name: `fsc-portal-backend`
   - Runtime: `Python 3`
   - Build Command: `cd backend && pip install -r requirements.txt`
   - Start Command: `cd backend && uvicorn main:app --host 0.0.0.0 --port $PORT`
   - Health Check Path: `/health`

## Frontend (Vercel)

### Already Configured

Your frontend is already set up with:
- `vercel.json` - Framework detection
- `adapter-vercel` - SvelteKit adapter
- Environment variables needed:
  - `PUBLIC_SUPABASE_URL`
  - `PUBLIC_SUPABASE_ANON_KEY`
  - `PUBLIC_API_BASE` (your Render backend URL)

### Deploy Updates

```bash
cd frontend
vercel --prod
```

Or push to main branch for automatic deployment.

## Environment Variables Summary

### Backend (Render)
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key (admin access)
- `ALLOWED_ORIGIN` - Frontend URL (default: https://app.fscnj.com)

### Frontend (Vercel)
- `PUBLIC_SUPABASE_URL` - Same as backend
- `PUBLIC_SUPABASE_ANON_KEY` - Public anon key
- `PUBLIC_API_BASE` - Backend URL (e.g., https://fsc-portal-backend.onrender.com)

## CORS Configuration

The backend automatically handles CORS:
- **Production**: Uses `ALLOWED_ORIGIN` env var (default: https://app.fscnj.com)
- **Development**: Auto-adds localhost:5173, localhost:5174 if not in production

## Post-Deployment Checklist

- [ ] Backend health check returns `{"ok": true}`
- [ ] Frontend can authenticate (magic link works)
- [ ] CSV import succeeds (check with test file)
- [ ] Dashboard shows real data
- [ ] Sessions page loads with foreign key data
- [ ] Payers table displays on import page

## Troubleshooting

**CORS Errors:**
- Verify `ALLOWED_ORIGIN` matches your frontend domain exactly
- Check browser console for actual origin being sent

**Auth Errors:**
- Ensure Supabase keys are correct
- Verify JWT token is being passed in Authorization header

**Database Errors:**
- Check RLS policies in Supabase
- Verify service role key has admin access
- Ensure foreign key relationships exist (clients, providers)

## Local Development

```bash
# Backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8001

# Frontend
cd frontend
npm install
npm run dev
```

Make sure `.env` files are configured locally with the same variables.
