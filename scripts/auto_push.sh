#!/usr/bin/env bash
set -euo pipefail

# One-click safe push script for fsc-portal
# - Verifies no private keys are staged
# - Ensures remote 'origin' exists
# - Optionally force-with-lease if remote has diverged and user passes --force
# Usage: ./scripts/auto_push.sh [--force]

RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; NC="\033[0m"

FORCE=false
if [[ ${1:-} == "--force" ]]; then
  FORCE=true
fi

echo -e "${GREEN}==> Starting auto push${NC}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo -e "${RED}Not inside a git repository${NC}" >&2
  exit 1
fi

echo -e "${GREEN}==> Checking for accidental key leaks${NC}"
if git ls-files | grep -E '(id_ed25519|\.pem|\.key)$' >/dev/null 2>&1; then
  echo -e "${RED}Refusing to continue: key-like files are tracked.${NC}" >&2
  git ls-files | grep -E '(id_ed25519|\.pem|\.key)$'
  exit 2
fi

echo -e "${GREEN}==> Staging changes${NC}"
git add .

if git diff --cached --quiet; then
  echo -e "${YELLOW}No staged changes (nothing to commit). Proceeding to push anyway.${NC}"
else
  MSG="chore: automated commit"
  echo -e "${GREEN}==> Creating commit: ${MSG}${NC}"
  git commit -m "${MSG}" || true
fi

if ! git remote | grep -q '^origin$'; then
  echo -e "${RED}Remote 'origin' not set. Add it with:\n  git remote add origin git@github.com:YOURUSER/fsc-portal.git${NC}" >&2
  exit 3
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  echo -e "${YELLOW}Switching to main branch (was $CURRENT_BRANCH)${NC}"
  git branch -M main
fi

echo -e "${GREEN}==> Fetching remote state${NC}"
git fetch origin main || true

LOCAL_HEAD=$(git rev-parse main 2>/dev/null || echo '')
REMOTE_HEAD=$(git rev-parse origin/main 2>/dev/null || echo '')

if [[ -n "$REMOTE_HEAD" && "$LOCAL_HEAD" != "$REMOTE_HEAD" ]]; then
  echo -e "${YELLOW}Divergence detected between local and origin/main${NC}"
  if $FORCE; then
    echo -e "${YELLOW}--force flag provided: using force-with-lease${NC}"
    git push --force-with-lease origin main
  else
    echo -e "${RED}Refusing to push without explicit consent. Re-run with --force to overwrite or manually reconcile (pull/rebase).${NC}"
    exit 4
  fi
else
  echo -e "${GREEN}==> Pushing main (fast-forward or first push)${NC}"
  git push -u origin main
fi

echo -e "${GREEN}==> Push complete${NC}"
exit 0
