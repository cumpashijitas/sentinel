-- Sentinel V2 — accident_events
--
-- A possible-accident record: created client-side the moment on-device
-- sensor fusion flags a candidate impact, then progresses through
-- confirmation/notification/resolution (mostly server-/Edge-Function-driven
-- in a later module — not implemented yet).

create type public.accident_event_status as enum (
  'candidate', -- just detected, countdown running on-device
  'cancelled', -- rider confirmed they're OK before the countdown ended
  'confirmed', -- countdown elapsed with no response: treated as real
  'notified',  -- group/emergency contacts have been alerted
  'resolved'   -- follow-up complete
);

create table public.accident_events (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.ride_sessions (id) on delete set null,
  user_id uuid not null references auth.users (id) on delete cascade,
  latitude double precision,
  longitude double precision,
  impact_mps2 real not null,
  gyro_rad_s real,
  speed_kmh real,
  g_force real,
  confidence_score real,
  sensor_snapshot jsonb,
  status public.accident_event_status not null default 'candidate',
  occurred_at timestamptz not null default now(),
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  constraint accident_events_latitude_range check (latitude is null or latitude between -90 and 90),
  constraint accident_events_longitude_range check (longitude is null or longitude between -180 and 180),
  constraint accident_events_confidence_range
    check (confidence_score is null or confidence_score between 0 and 1)
);

create index accident_events_user_id_idx on public.accident_events (user_id);
create index accident_events_session_id_idx
  on public.accident_events (session_id)
  where session_id is not null;
create index accident_events_status_idx on public.accident_events (status);

-- Realtime UPDATE payloads (candidate -> confirmed -> notified -> resolved)
-- need the old row's data.
alter table public.accident_events replica identity full;

alter table public.accident_events enable row level security;

-- A rider can always create and read their own accident events, at any
-- status — this is their own safety record.
create policy accident_events_insert_self
  on public.accident_events for insert
  with check (user_id = auth.uid());

create policy accident_events_select_self
  on public.accident_events for select
  using (user_id = auth.uid());

-- Session-mates only ever see events that have actually been confirmed (or
-- moved past confirmation) for a session they belong to — a 'candidate'
-- (still counting down) or 'cancelled' (false alarm) event stays private to
-- the affected rider, so a shaky road doesn't broadcast a false alarm to
-- the whole group.
create policy accident_events_select_session_members_confirmed
  on public.accident_events for select
  using (
    session_id is not null
    and status in ('confirmed', 'notified', 'resolved')
    and public.is_session_member(session_id, auth.uid())
  );

-- Design decision beyond the base spec: the affected rider needs to be able
-- to self-cancel during the on-device countdown ("estoy bien"), so allow a
-- self-UPDATE but only while the event is still 'candidate' — once it has
-- moved to 'confirmed'/'notified'/'resolved' it becomes a system-driven
-- record and is no longer client-writable (that transition belongs to a
-- future Edge Function running as service_role).
create policy accident_events_update_self_while_candidate
  on public.accident_events for update
  using (user_id = auth.uid() and status = 'candidate')
  with check (user_id = auth.uid());

-- No DELETE policy: accident records are permanent.

alter publication supabase_realtime add table public.accident_events;
