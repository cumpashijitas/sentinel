-- Sentinel V2 — live_locations, location_history

-- ---------------------------------------------------------------------------
-- live_locations: one current position per (session, user). The composite
-- primary key IS the "only one current position per user per session"
-- constraint — clients upsert (insert ... on conflict (session_id, user_id)
-- do update) rather than insert a new row every update.
-- ---------------------------------------------------------------------------
create table public.live_locations (
  session_id uuid not null references public.ride_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  accuracy real,
  speed real,
  heading real,
  battery_level smallint,
  recorded_at timestamptz not null default now(),
  primary key (session_id, user_id),
  constraint live_locations_latitude_range check (latitude between -90 and 90),
  constraint live_locations_longitude_range check (longitude between -180 and 180),
  constraint live_locations_battery_range check (battery_level is null or battery_level between 0 and 100)
);

-- Realtime UPDATE/DELETE payloads need the old row values (the row's
-- identity is its PK, not a surrogate id), so ship the full old row.
alter table public.live_locations replica identity full;

alter table public.live_locations enable row level security;

create policy live_locations_select_session_members
  on public.live_locations for select
  using (public.is_session_member(session_id, auth.uid()));

create policy live_locations_insert_self
  on public.live_locations for insert
  with check (user_id = auth.uid() and public.is_session_member(session_id, auth.uid()));

create policy live_locations_update_self
  on public.live_locations for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and public.is_session_member(session_id, auth.uid()));

-- No DELETE policy: rows disappear via ON DELETE CASCADE when their session
-- is removed; a user never needs to delete their own live position.

alter publication supabase_realtime add table public.live_locations;

-- ---------------------------------------------------------------------------
-- location_history: append-only trail, one row per recorded fix.
-- ---------------------------------------------------------------------------
create table public.location_history (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.ride_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  accuracy real,
  speed real,
  heading real,
  recorded_at timestamptz not null default now(),
  constraint location_history_latitude_range check (latitude between -90 and 90),
  constraint location_history_longitude_range check (longitude between -180 and 180)
);

create index location_history_session_id_idx on public.location_history (session_id);
create index location_history_user_id_idx on public.location_history (user_id);
create index location_history_recorded_at_idx on public.location_history (recorded_at);
-- Covers the actual access pattern ("this session, this user, in time
-- order") in one index rather than relying on three separate single-column
-- indexes for that query.
create index location_history_session_user_recorded_idx
  on public.location_history (session_id, user_id, recorded_at);

-- TODO(retention): this table grows without bound. Before production,
-- add a scheduled job (pg_cron, or an Edge Function on a cron trigger)
-- that purges location_history rows older than a defined retention window
-- (e.g. `delete from public.location_history where recorded_at < now() -
-- interval '90 days'`), and decide whether closed/finished ride_sessions
-- should be purged sooner than active ones. Not implemented yet.

alter table public.location_history enable row level security;

create policy location_history_insert_self
  on public.location_history for insert
  with check (user_id = auth.uid() and public.is_session_member(session_id, auth.uid()));

-- Policy definition ("miembros autorizados de la sesión"): any active
-- member of the session can read the *entire* session's history trail, same
-- visibility as live_locations. Revisit if a stricter "only my own history"
-- rule is ever needed for a given deployment.
create policy location_history_select_session_members
  on public.location_history for select
  using (public.is_session_member(session_id, auth.uid()));

-- No UPDATE/DELETE policy: history rows are immutable once written from the
-- client; only a future service-role retention job removes them.
