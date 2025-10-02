# FSC Portal — Copilot instructions

Quick, targeted guidance for AI coding agents working on the FSC Portal repository.

- Project layout
  - `backend/` — FastAPI service that accepts CSV imports (see `backend/main.py`). Uses Supabase Python client and expects `SUPABASE_URL` & `SUPABASE_SERVICE_ROLE_KEY` in env. Key endpoints: `/api/imports/simplepractice` and `/health`.
  - `frontend/` — SvelteKit (Svelte v5) app. Entry scripts in `frontend/package.json` (dev/build/preview). Supabase client is wired in `frontend/src/lib/supabaseClient.ts` using `$env/static/public` env variables.
  - `scripts/deploy.sh` — Local orchestration script that creates a Python venv, runs the backend via `uvicorn main:app` on :8001, builds the frontend with Vite and previews on :5173. It checks Node version (requires Node >=20.19 or 22+), Tailwind/PostCSS config, and backend CORS.
  - `sql/` — SQL migrations/snippets (example: `2024-09-28-update-sessions.sql`).

- Big-picture architecture
  - Single-repo, two-process web app: a Python FastAPI backend and a SvelteKit frontend. They communicate indirectly via Supabase (Postgres + Auth) rather than a private API for most data; the backend uses a Supabase "service role" key to perform privileged inserts/updates during CSV import.
  - Frontend authenticates users using Supabase client (`frontend/src/lib/supabaseClient.ts`) with public anon keys. Backend uses bearer JWT from Authorization header and validates it with `SB.auth.get_user(jwt=token)`.
  - Data flow for imports: user uploads CSV to the backend `/api/imports/simplepractice`. Backend parses CSV, matches providers/clients via Supabase queries, upserts into `sessions` table and records import runs in `import_runs` / `import_staging` tables.

- Developer workflows & commands (use these exact commands)
  - Start both locally (recommended): `scripts/deploy.sh` (it builds frontend and starts uvicorn + preview). The script creates a Python venv inside `backend/`.
  - Backend only: from `backend/` run `python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && uvicorn main:app --host 0.0.0.0 --port 8001`
  - Frontend only: from `frontend/` run `npm install` (or `npm ci` when lockfile present) then `npm run dev` (or `npm run build` + `npm run preview` to validate production build).

- Important environment variables
  - Backend: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, optional `ALLOWED_ORIGIN` (set to `http://localhost:5173` for local testing). See `backend/main.py` and `scripts/deploy.sh`.
  - Frontend: `PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_ANON_KEY` (used in `frontend/src/lib/supabaseClient.ts`).

- Project-specific patterns & conventions
  - CSV import: flexible column aliasing via `COLS` mapping in `backend/main.py`. When matching rows, prefer `external_session_id` upsert if present, else a natural-key match on provider/client/date/time. Respect `is_duplicate` flags written to the `sessions` table.
  - Auth: Frontend uses public anon keys; backend requires `Authorization: Bearer <jwt>` and validates with Supabase server SDK. When writing endpoints that need user context, use the `require_user` pattern from `backend/main.py`.
  - `src/lib/` is the project's `$lib` alias for shared frontend utilities (see `frontend/src/lib/index.ts`). Keep reusable client wrappers here.
  - Scripts enforce checks: `scripts/deploy.sh` ensures specific Node/Tailwind/PostCSS wiring. If adding tooling, follow the version constraints and keep `postcss.config.cjs` + `tailwind.config.cjs` in `frontend/`.

- Integration & external dependencies
  - Supabase is the central integration point (Auth + Postgres). Backend uses the service role key for privileged DB ops; frontend uses anon/public keys.
  - No separate API gateway — the import endpoint is the main server-side integration; other flows rely on Supabase direct DB and Auth usage.

- Tests & linting
  - Frontend: `npm run check` (runs `svelte-check`) and `npm run lint` (prettier + eslint). Use `npm run format` to auto-format.
  - Backend: no tests present. Keep edits small and run a quick `python -m compileall .` in `backend/` or start the server to catch syntax/runtime errors.

- Files to inspect when changing behavior
  - CSV import logic: `backend/main.py` (COLS mapping, `to_minutes`, provider/client lookup, upsert logic)
  - Frontend Supabase wiring: `frontend/src/lib/supabaseClient.ts`
  - Local orchestration: `scripts/deploy.sh`
  - Environment hints: `backend/.env` (not committed) and `frontend/package.json` scripts

- Quick test harness
  - `scripts/test_import.py` — small script that POSTS `backend/sample_data/simplepractice_mock.csv` to the backend import endpoint. It expects a user JWT via the `TEST_USER_JWT` env var and `BACKEND_URL` (default: `http://localhost:8001`). Useful for smoke-testing imports locally.

- Safety / permissions notes for AI edits
  - Do NOT commit or expose secrets. `SUPABASE_SERVICE_ROLE_KEY` must remain in env and never be hard-coded or committed.
  - When modifying auth or DB logic, keep the `require_user` pattern and service-role usage separation: only backend service code should use service role key.

- Example tasks & pointers
  - Add a new import mapping: update `COLS` in `backend/main.py`, add unit cases by creating small CSV samples in `backend/sample_data/` and run the import endpoint locally.
  - Frontend change affecting auth: update `frontend/src/lib/supabaseClient.ts` and ensure `PUBLIC_SUPABASE_ANON_KEY` is present in dev env; test via `npm run dev`.
  - UI quick wins (done): header now shows a live backend health indicator (`/health`) in `frontend/src/routes/+layout.svelte`. Small spinner/CSS added to `frontend/src/app.css`.

If any of the above sections are unclear or you want the file to contain more examples (e.g., common SQL migrations in `sql/`), tell me what to expand and I will iterate.

## One-click Safe Push Workflow

To streamline commits and protect against accidental key leaks or unwanted history overwrites, a helper script `scripts/auto_push.sh` is available.

Usage:
```
chmod +x scripts/auto_push.sh  # first time only
./scripts/auto_push.sh         # normal safe push
./scripts/auto_push.sh --force # only if remote diverged and you intentionally want to overwrite (force-with-lease)
```

What it does:
- Verifies repository context.
- Scans tracked files for private key patterns (`id_ed25519`, `*.pem`, `*.key`). Aborts if any are found.
- Stages all changes and creates a generic commit if there are staged diffs.
- Ensures the current branch is `main` (renames if not).
- Fetches `origin/main` and detects divergence.
- Performs a normal push when fast-forward or first push.
- Requires explicit `--force` flag to perform a `--force-with-lease` push when histories diverge.

Agent Guidance:
- Before instructing the user to deploy (Render or Vercel), first ask them to run the safe push script if there are unpushed changes.
- Never suggest a plain `git push --force`; prefer the script or `--force-with-lease` explicitly.
- If the script aborts due to divergence and the user is unsure, prompt them to inspect remote logs rather than forcing immediately.

Future Enhancements (optional):
- Add a pre-push Git hook replicating the key scan logic for contributors not using the script.
- Extend script to run minimal build/lint (`npm run build` / `npm run check`) before pushing.
