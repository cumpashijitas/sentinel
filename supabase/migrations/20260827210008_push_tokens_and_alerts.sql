-- Sentinel V2 — device_push_tokens, alerts

create type public.device_platform as enum ('android', 'web');

create table public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform public.device_platform not null,
  token text not null,
  enabled boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint device_push_tokens_token_key unique (token)
);

create index device_push_tokens_user_id_idx on public.device_push_tokens (user_id);

alter table public.device_push_tokens enable row level security;

create policy device_push_tokens_select_own
  on public.device_push_tokens for select
  using (user_id = auth.uid());

create policy device_push_tokens_insert_own
  on public.device_push_tokens for insert
  with check (user_id = auth.uid());

create policy device_push_tokens_update_own
  on public.device_push_tokens for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy device_push_tokens_delete_own
  on public.device_push_tokens for delete
  using (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- alerts: the outbound notification log for an accident (push/SMS/email to
-- group members and/or emergency contacts). Deliberately backend-only.
-- ---------------------------------------------------------------------------
create type public.alert_recipient_type as enum ('group_member', 'emergency_contact');
create type public.alert_channel as enum ('push', 'sms', 'email');
create type public.alert_status as enum ('pending', 'sent', 'failed');

create table public.alerts (
  id uuid primary key default gen_random_uuid(),
  accident_id uuid not null references public.accident_events (id) on delete cascade,
  recipient_type public.alert_recipient_type not null,
  recipient_user_id uuid references auth.users (id) on delete set null,
  recipient_phone text,
  channel public.alert_channel not null,
  status public.alert_status not null default 'pending',
  provider_message_id text,
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  constraint alerts_recipient_target_check check (
    (recipient_type = 'group_member' and recipient_user_id is not null)
    or recipient_type = 'emergency_contact'
  )
);

create index alerts_accident_id_idx on public.alerts (accident_id);
create index alerts_recipient_user_id_idx
  on public.alerts (recipient_user_id)
  where recipient_user_id is not null;

alter table public.alerts enable row level security;

-- Deliberately NO policies for `anon`/`authenticated`: dispatching and
-- tracking alerts is a privileged, backend-only concern (a future Edge
-- Function running with the service_role key, which bypasses RLS
-- entirely by design). RLS is still turned ON — rather than left off —
-- specifically so this table stays deny-by-default for client roles even
-- if a future migration or dashboard change accidentally grants them
-- table-level access; today, no client policy means zero rows are ever
-- visible or writable through the client SDK/PostgREST, in any direction.
