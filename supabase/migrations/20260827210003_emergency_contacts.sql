-- Sentinel V2 — emergency_contacts
--
-- Contacts a rider wants alerted on a confirmed accident. Strictly private:
-- only the owner manages their own contact list. `contact_user_id` is an
-- optional link to another Sentinel account (so the contact can also be
-- reached via push, not just SMS) — it is never required.

create table public.emergency_contacts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  contact_user_id uuid references auth.users (id) on delete set null,
  name text not null,
  phone text not null,
  relationship text,
  notify_push boolean not null default true,
  notify_sms boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index emergency_contacts_owner_id_idx on public.emergency_contacts (owner_id);
create index emergency_contacts_contact_user_id_idx
  on public.emergency_contacts (contact_user_id)
  where contact_user_id is not null;

create trigger set_emergency_contacts_updated_at
  before update on public.emergency_contacts
  for each row execute function public.set_updated_at();

alter table public.emergency_contacts enable row level security;

-- Owner-only CRUD. Note this is deliberately NOT visible to
-- contact_user_id's own account — being listed as someone's emergency
-- contact does not grant read access to that list.
create policy emergency_contacts_select_own
  on public.emergency_contacts for select
  using (owner_id = auth.uid());

create policy emergency_contacts_insert_own
  on public.emergency_contacts for insert
  with check (owner_id = auth.uid());

create policy emergency_contacts_update_own
  on public.emergency_contacts for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy emergency_contacts_delete_own
  on public.emergency_contacts for delete
  using (owner_id = auth.uid());
