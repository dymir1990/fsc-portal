#!/usr/bin/env bash
set -euo pipefail

log() { printf "\n\033[1m➜ %s\033[0m\n" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# -------- PRECHECKS --------
require_node() {
  if ! have node; then
    log "Node.js not found. Install Node 20.19+ or 22+ and re-run."
    exit 1
  fi
  local ver major minor patch
  ver=$(node -v | sed 's/^v//')
  major=${ver%%.*}
  rest=${ver#*.}; minor=${rest%%.*}
  rest=${rest#*.}; patch=${rest%%.*}
  # require >= 20.19.0 (or any 22+)
  if [ "$major" -lt 20 ]; then
    log "Node $ver detected. Please use Node 20.19+ or 22+."
    exit 1
  fi
  if [ "$major" -eq 20 ] && [ "$minor" -lt 19 ]; then
    log "Node $ver detected. Please upgrade to Node 20.19+ or 22+."
    exit 1
  fi
}

# -------- BACKEND --------
start_backend() {
  log "Starting backend (FastAPI @ :8001)"
  pushd backend >/dev/null

  # Ensure venv + deps
  if [ ! -d "venv" ]; then
    log "No venv found — creating one"
    python3 -m venv venv
  fi
  # shellcheck disable=SC1091
  source venv/bin/activate
  if [ -f requirements.txt ]; then
    pip install -r requirements.txt >/dev/null
  fi

  uvicorn main:app --host 0.0.0.0 --port 8001 &
  BACKEND_PID=$!
  popd >/dev/null
}

# -------- FRONTEND --------
start_frontend() {
  log "Building & serving frontend"
  pushd frontend >/dev/null

  # Verify Tailwind/PostCSS wiring and global CSS import
  if [ ! -f tailwind.config.cjs ]; then
    log "Missing frontend/tailwind.config.cjs (Tailwind config)."; exit 1
  fi
  if [ ! -f postcss.config.cjs ]; then
    log "Missing frontend/postcss.config.cjs (PostCSS config)."; exit 1
  fi
  if [ -f postcss.config.js ]; then
    log "Found postcss.config.js — removing to prefer CJS config."; rm -f postcss.config.js
  fi
  # Verify Tailwind v4 PostCSS plugin is installed
  if ! npm ls -D @tailwindcss/postcss >/dev/null 2>&1; then
    log "@tailwindcss/postcss not installed. Run: (cd frontend && npm i -D @tailwindcss/postcss)"; exit 1
  fi
  # Recommend tailwindcss package (should be present for v4)
  if ! npm ls tailwindcss >/dev/null 2>&1; then
    log "tailwindcss package not found. Install with: (cd frontend && npm i -D tailwindcss)"; exit 1
  fi
  if ! grep -q "/src/app.css" src/routes/+layout.svelte; then
    log "Global CSS import '/src/app.css' not found in src/routes/+layout.svelte."; exit 1
  fi
  if ! grep -q "@tailwind base;" src/app.css 2>/dev/null; then
    log "src/app.css missing Tailwind directives (@tailwind base/components/utilities)."; exit 1
  fi

  # Install deps
  if [ -f package-lock.json ]; then
    npm ci
  else
    npm install
  fi

  # Build with Vite (SvelteKit-compatible)
  rm -rf .svelte-kit dist
  npm run build

  # Preview built app with Vite on 5173
  npm run preview -- --port 5173 --host 0.0.0.0 &
  FRONTEND_PID=$!
  popd >/dev/null
}

open_importer() {
  if have open; then
    sleep 2 && open "http://localhost:5173/case-manager/import"
  elif have xdg-open; then
    sleep 2 && xdg-open "http://localhost:5173/case-manager/import" >/dev/null 2>&1 || true
  fi
}

# -------- ORCHESTRATION --------
log "Deploying FSC Portal (backend + frontend)"
require_node
# Warn if backend CORS origin doesn't match preview host
check_cors() {
  local env_file="backend/.env"
  local want="http://localhost:5173"
  if [ -f "$env_file" ]; then
    local current
    current=$(grep -E '^ALLOWED_ORIGIN=' "$env_file" | sed 's/^ALLOWED_ORIGIN=//')
    if [ -z "$current" ]; then
      log "ALLOWED_ORIGIN not set in $env_file. Consider adding: ALLOWED_ORIGIN=$want"
    elif [ "$current" != "$want" ]; then
      log "CORS warning: backend ALLOWED_ORIGIN=$current, but preview serves at $want"
      log "Update backend/.env to avoid browser CORS errors during testing."
    fi
  else
    log "backend/.env not found to verify CORS; ensure ALLOWED_ORIGIN=$want for local preview."
  fi
}
check_cors
start_backend
start_frontend
open_importer

log "Running (backend PID: ${BACKEND_PID:-?}, frontend PID: ${FRONTEND_PID:-?})"
log "Press CTRL+C to stop (or add scripts/stop.sh)."
wait
