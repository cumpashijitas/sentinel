-- Sentinel V2 — ride_sessions, ride_session_members
--
-- A single group ride ("we're riding now"). ride_session_members tracks who
-- is actually participating in the live tracking for that specific ride —
-- distinct from ride_group_members, which is the group's standing roster.

create type public.ride_session_status as enum ('waiting', 'active', 'finished', 'cancelled');
-- Participation in one specific ride session. Simpler than group-membership
-- status: a session participant is either currently sharing location
-- ('active') or has stopped ('left'). There is no 'invited'/'removed' here —
-- who gets enrolled is decided at start_ride_session() time (see RPCs).
create type public.ride_session_member_status as enum ('active', 'left');

create table public.ride_sessions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.ride_groups (id) on delete cascade,
  started_by uuid not null references auth.users (id) on delete restrict,
  name text,
  status public.ride_session_status not null default 'waiting',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  constraint ride_sessions_ended_after_started check (ended_at is null or ended_at >= started_at)
);

create index ride_sessions_group_id_idx on public.ride_sessions (group_id);
create index ride_sessions_status_idx on public.ride_sessions (status);

create table public.ride_session_members (
  session_id uuid not null references public.ride_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  status public.ride_session_member_status not null default 'active',
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  last_seen_at timestamptz,
  primary key (session_id, user_id)
);

create index ride_session_members_user_id_idx on public.ride_session_members (user_id);

-- session_id/user_id are the row's identity; letting a client UPDATE them
-- would let a session member "relabel" their row into a different session
-- they were never enrolled in. Everything else on the row (status,
-- last_seen_at, left_at) stays freely updatable by its owner.
create or replace function public.prevent_ride_session_member_key_change()
returns trigger
language plpgsql
as $$
begin
  if new.session_id <> old.session_id or new.user_id <> old.user_id then
    raise exception 'session_id and user_id cannot be changed on an existing ride_session_members row';
  end if;
  return new;
end;
$$;

create trigger ride_session_members_lock_keys
  before update on public.ride_session_members
  for each row execute function public.prevent_ride_session_member_key_change();

-- ---------------------------------------------------------------------------
-- Helper function — same SECURITY DEFINER rationale as is_group_member /
-- is_group_admin in 20260827210004_ride_groups.sql: avoids RLS
-- self-recursion when a ride_session_members policy needs to query
-- ride_session_members itself, stays narrow/read-only, fixed search_path,
-- EXECUTE limited to `authenticated`.
-- ---------------------------------------------------------------------------
create or replace function public.is_session_member(session_uuid uuid, user_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.ride_session_members sm
    where sm.session_id = session_uuid
      and sm.user_id = user_uuid
      and sm.status = 'active'
  );
$$;

revoke all on function public.is_session_member(uuid, uuid) from public;
grant execute on function public.is_session_member(uuid, uuid) to authenticated;

comment on function public.is_session_member(uuid, uuid) is
  'True if user_uuid is an active participant of session_uuid. SECURITY DEFINER to avoid RLS self-recursion — see is_group_member comment in 20260827210004_ride_groups.sql.';

-- ---------------------------------------------------------------------------
-- RLS — ride_sessions
-- ---------------------------------------------------------------------------
alter table public.ride_sessions enable row level security;

create policy ride_sessions_select_group_members
  on public.ride_sessions for select
  using (public.is_group_member(group_id, auth.uid()));

-- No INSERT/UPDATE policy at all: starting and finishing a session are
-- domain operations ("only one active session per group", "only
-- owner/admin", "enroll every active group member") that belong in
-- start_ride_session()/finish_ride_session() (SECURITY DEFINER RPCs, see
-- 20260827210009_rpc_functions.sql), not in a bare RLS predicate.

-- ---------------------------------------------------------------------------
-- RLS — ride_session_members
-- ---------------------------------------------------------------------------
alter table public.ride_session_members enable row level security;

create policy ride_session_members_select
  on public.ride_session_members for select
  using (public.is_session_member(session_id, auth.uid()));

-- A participant may update their own row (status/last_seen_at as they stop
-- sharing or send heartbeats) — enrollment itself happens in
-- start_ride_session(), not via client INSERT.
create policy ride_session_members_update_self
  on public.ride_session_members for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Realtime: session lifecycle (waiting/active/finished/cancelled) is shown live.
alter publication supabase_realtime add table public.ride_sessions;
