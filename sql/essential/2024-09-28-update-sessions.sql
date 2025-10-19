-- Add new session metadata columns for billing + insurance tracking.
alter table sessions
  add column if not exists billing_route text default 'simplepractice',
  add column if not exists primary_insurance text,
  add column if not exists client_type text,
  add column if not exists is_duplicate boolean default false;

update sessions set is_duplicate = false where is_duplicate is null;
