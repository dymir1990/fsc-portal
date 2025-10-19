# FSC Portal UI Overview

This diagram mirrors the current Svelte routes under `frontend/src/routes` and turns them into a quick visual reference.

![FSC Portal UI Overview](./ui-overview.svg)

## Pages depicted
- Landing redirect (`+page.svelte`): loading spinner that forwards to login or dashboard based on Supabase session.
- Login (`login/+page.svelte`): magic-link email form using `supabase.auth.signInWithOtp`.
- Dashboard (`dashboard/+page.svelte`): greets the signed-in email, offers Import CSV and Open Supabase actions.
- Case Manager Import (`case-manager/import/+page.svelte`): two-column layout with quick links, payer selector, CSV upload, and flagged preview.
- Billing preview (`billing/+page.svelte`): gated by Supabase session, shows waiting spinner and empty-state card.
- Reports preview (`reports/+page.svelte`): placeholder analytics cards waiting on data tables.
 - Global header (`+layout.svelte`): sticky top bar with backend health pill (polls `/health`) and a small build hash badge after the app name so you can verify deployments quickly.

## Using the visual
- Open `docs/ui-overview.svg` in any browser or vector editor for higher-quality inspection.
- Keep the file with design notes or share a screenshot when aligning with stakeholders.
- Update this SVG when UI structure changes so the visual stays trustworthy.

## Manual UI smoke test prompts
Use these short prompts/checklists when validating a new deployment (copy/paste into an issue or ChatGPT style assistant if needed):

### 1. Landing & Auth Redirect
Prompt: "Visit the root URL and confirm the landing screen shows spinner text then redirects appropriately based on session. If not logged in, it should go to /login within ~2s."  
Verify: Landing copy present, build hash badge visible, redirect behavior correct.

### 2. Login Magic Link Flow
Prompt: "Enter a valid work email on /login and submit. Confirm success message appears and no network errors occur."  
Verify: Button disabled while sending, message changes to success or error.

### 3. Dashboard Render
Prompt: "After auth, open /dashboard. Confirm greeting shows user email and both cards (Import SimplePractice CSV, Open Supabase) render."  
Verify: Sign Out button works and returns to /login.

### 4. Import Page Functionality
Prompt: "Navigate to /case-manager/import. Load payers (fallback list acceptable if table empty), choose a CSV, upload with a valid token. Confirm success summary text and flagged preview list (if rows flagged)."  
Verify: Authorization header present in network request, success metrics reflect file content.

### 5. Billing & Reports Stubs
Prompt: "Visit /billing and /reports while authenticated. Confirm each shows preview heading and loading state resolves (even if data not yet implemented)."  
Verify: No unexpected 401 redirects while session valid.

### 6. Backend Health Indicator
Prompt: "Observe header health pill. It should cycle from 'checking' to 'backend OK'. Simulate a failure by temporarily pointing PUBLIC_BACKEND_URL to a bad host (locally) and confirm pill shows 'backend down'."  
Verify: Color transitions: amber (checking) → green (OK) → red (down).

### 7. Build Hash Badge
Prompt: "Hard refresh the app and confirm the build hash badge changed after latest deploy. If unchanged, force clear cache or verify deployment timestamp in Vercel."  
Verify: Badge present; helps ensure user isn't on a stale cached build.

### 8. Accessibility & Basic Perf
Prompt: "Tab through the landing and login pages to ensure focus styles are visible; open dev tools Lighthouse (fast check) for accessibility score >90."  
Verify: Focus rings appear on links/buttons, no large layout shifts.

### 9. Mobile Layout Spot Check
Prompt: "Resize viewport to ~375px width and confirm header remains readable and import form elements reflow without horizontal scroll."  
Verify: No overflow on main content containers.

### 10. Error Handling (Import)
Prompt: "Upload a non-CSV (e.g., .txt) file. Confirm user-facing error message appears and no unhandled exception surfaces in console."  
Verify: Network response 400 with clear message.

## Future automation ideas
- Add Playwright tests for redirect, auth form, import success/failure scenarios.
- Snapshot test flagged preview rendering with mock CSV.
- Inject real commit hash via `VERCEL_GIT_COMMIT_SHA` and show first 7 chars in badge.
- Add a status endpoint for Supabase connectivity (currently only backend health is exposed).

