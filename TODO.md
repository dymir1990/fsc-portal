1. Mackenzi validation session
   a. Send the walkthrough email and schedule a quick call if needed.
   b. Sit with Mackenzi while she uploads a real SimplePractice CSV (or confirm she can follow the email).
   c. Capture feedback on the dropdown, flagged rows, and any missing pieces.
2. Incorporate feedback
   a. Triage any changes she requests (UI tweaks, new payers, etc.).
   b. Update Supabase `public.payers` and the `docs/billing-routes.md` table if new routes surface.
   c. Re-test the importer after changes and confirm regression-free.
3. Deploy & handoff
   a. Confirm backend (`main.py`) and frontend builds are ready for deployment.
   b. Share the final doc link and remind the team how to keep payers in sync.
   c. Move this task to “Done” in project tracking.
