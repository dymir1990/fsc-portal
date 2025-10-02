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

## Using the visual
- Open `docs/ui-overview.svg` in any browser or vector editor for higher-quality inspection.
- Keep the file with design notes or share a screenshot when aligning with stakeholders.
- Update this SVG when UI structure changes so the visual stays trustworthy.
