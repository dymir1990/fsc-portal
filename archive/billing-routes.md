# Billing Routes Reference

This list is generated from the canonical `public.payers` table in Supabase. Update the table first, then refresh this doc so the frontend and handbook stay aligned.

| Payer | Billing Route | Portal / Notes |
| --- | --- | --- |
| Aetna | portal | Submit via Availity portal; include auth number when required. |
| AmeriHealth | portal | Use AmeriHealth web portal for claims. |
| Magellan | portal | Magellan provider portal. |
| Medicaid | simplepractice | File directly in SimplePractice unless otherwise noted. |
| Medicare | simplepractice | Bill through SimplePractice. |
| Oscar Health Insurance | portal | Oscar provider portal. |
| Tricare | portal | Tricare portal submission. |

**Keeping this list fresh**
1. Add or update payers in Supabase using:
   ```sql
   insert into public.payers (name, status)
   values ('PAYER', 'Active')
   on conflict (name) do update set status = excluded.status, updated_at = now();
   ```
2. Refresh the importer UI and this document so Mackenzi sees the latest options.
3. If a payer is inactive, flip the `status` column to `Inactive` and add a note here.

For quick checks, run:
```sql
select name, status, updated_at
from public.payers
order by name;
```
