-- Sentinel V2 — RPC functions
--
-- Every function below is SECURITY DEFINER for the same reason: the base
-- tables intentionally have no direct client INSERT/UPDATE policy for these
-- operations (see the RLS comments in the preceding migrations), because
-- each one is really "make N writes and enforce a domain rule, atomically".
-- Each function:
--   * pins `search_path = public` (no search_path hijacking),
--   * derives the acting user exclusively from auth.uid() — never from a
--     client-supplied parameter, so nobody can act "as" another user,
--   * is REVOKEd from PUBLIC and re-GRANTed only to `authenticated`.

-- ---------------------------------------------------------------------------
-- create_ride_group: create a group and enroll the caller as its owner,
-- atomically (a group must never exist without an owner membership row).
-- ---------------------------------------------------------------------------
create or replace function public.create_ride_group(
  p_name text,
  p_description text default null
)
returns public.ride_groups
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_group public.ride_groups;
  v_code text;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;
  if btrim(coalesce(p_name, '')) = '' then
    raise exception 'group name is required';
  end if;

  -- Short, human-typable invite code. Collisions against the UNIQUE
  -- constraint are astronomically unlikely (8 hex chars) but handled
  -- anyway by retrying with a fresh code instead of failing the call.
  loop
    v_code := upper(substr(md5(gen_random_uuid()::text), 1, 8));
    begin
      insert into public.ride_groups (owner_id, name, description, invite_code)
      values (v_uid, p_name, p_description, v_code)
      returning * into v_group;
      exit;
    exception when unique_violation then
      -- retry with a new invite_code
    end;
  end loop;

  insert into public.ride_group_members (group_id, user_id, role, status)
  values (v_group.id, v_uid, 'owner', 'active');

  return v_group;
end;
$$;

revoke all on function public.create_ride_group(text, text) from public;
grant execute on function public.create_ride_group(text, text) to authenticated;

comment on function public.create_ride_group(text, text) is
  'Creates a ride_groups row and enrolls auth.uid() as its owner, atomically. SECURITY DEFINER: see file header.';

-- ---------------------------------------------------------------------------
-- join_group_by_code: look up a group by invite code and add/reactivate the
-- caller as an active member. Idempotent — calling it again while already
-- active is a no-op, not an error.
-- ---------------------------------------------------------------------------
create or replace function public.join_group_by_code(p_invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_group public.ride_groups;
  v_existing public.ride_group_members;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  select * into v_group
  from public.ride_groups
  where invite_code = upper(btrim(p_invite_code));

  if not found then
    raise exception 'invalid invite code';
  end if;

  if v_group.status <> 'active' then
    raise exception 'this group is not accepting new members';
  end if;

  -- Lock any existing membership row for this (group, user) so two
  -- concurrent joins can't both decide "not found" and double-insert.
  select * into v_existing
  from public.ride_group_members
  where group_id = v_group.id and user_id = v_uid
  for update;

  if found then
    -- Reactivate if needed; if already active, this is a no-op (idempotent).
    if v_existing.status <> 'active' then
      update public.ride_group_members
        set status = 'active', left_at = null, joined_at = now()
        where group_id = v_group.id and user_id = v_uid;
    end if;
  else
    insert into public.ride_group_members (group_id, user_id, role, status)
    values (v_group.id, v_uid, 'member', 'active');
  end if;

  return v_group.id;
end;
$$;

revoke all on function public.join_group_by_code(text) from public;
grant execute on function public.join_group_by_code(text) to authenticated;

comment on function public.join_group_by_code(text) is
  'Adds/reactivates auth.uid() as an active member of the group matching p_invite_code. SECURITY DEFINER: see file header.';

-- ---------------------------------------------------------------------------
-- leave_group: caller leaves a group they are an active member of. The
-- owner cannot leave this way (a group must always have an owner) —
-- transferring or archiving ownership is a separate, not-yet-implemented
-- concern.
-- ---------------------------------------------------------------------------
create or replace function public.leave_group(p_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_role public.ride_group_role;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  select role into v_role
  from public.ride_group_members
  where group_id = p_group_id and user_id = v_uid and status = 'active';

  if not found then
    raise exception 'you are not an active member of this group';
  end if;

  if v_role = 'owner' then
    raise exception 'the group owner cannot leave; transfer ownership or archive the group first';
  end if;

  update public.ride_group_members
    set status = 'left', left_at = now()
    where group_id = p_group_id and user_id = v_uid;
end;
$$;

revoke all on function public.leave_group(uuid) from public;
grant execute on function public.leave_group(uuid) to authenticated;

comment on function public.leave_group(uuid) is
  'auth.uid() leaves p_group_id (status -> left). Raises if caller is not an active member or is the owner. SECURITY DEFINER: see file header.';

-- ---------------------------------------------------------------------------
-- start_ride_session: only a group owner/admin may start one, only one
-- waiting/active session may exist per group at a time, and every
-- currently-active group member is enrolled into the session automatically.
-- ---------------------------------------------------------------------------
create or replace function public.start_ride_session(
  p_group_id uuid,
  p_name text default null
)
returns public.ride_sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_session public.ride_sessions;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  if not public.is_group_admin(p_group_id, v_uid) then
    raise exception 'only the group owner or an admin can start a ride session';
  end if;

  if exists (
    select 1 from public.ride_sessions
    where group_id = p_group_id and status in ('waiting', 'active')
  ) then
    raise exception 'this group already has an active ride session';
  end if;

  insert into public.ride_sessions (group_id, started_by, name, status, started_at)
  values (p_group_id, v_uid, p_name, 'active', now())
  returning * into v_session;

  insert into public.ride_session_members (session_id, user_id, status, joined_at)
  select v_session.id, m.user_id, 'active', now()
  from public.ride_group_members m
  where m.group_id = p_group_id and m.status = 'active';

  return v_session;
end;
$$;

revoke all on function public.start_ride_session(uuid, text) from public;
grant execute on function public.start_ride_session(uuid, text) to authenticated;

comment on function public.start_ride_session(uuid, text) is
  'Starts a ride session for p_group_id and enrolls every active group member. Owner/admin only, one active session per group. SECURITY DEFINER: see file header.';

-- ---------------------------------------------------------------------------
-- finish_ride_session: only a group owner/admin may finish one, and it
-- releases every still-active session participant.
-- ---------------------------------------------------------------------------
create or replace function public.finish_ride_session(p_session_id uuid)
returns public.ride_sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_session public.ride_sessions;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  select * into v_session from public.ride_sessions where id = p_session_id;
  if not found then
    raise exception 'ride session not found';
  end if;

  if not public.is_group_admin(v_session.group_id, v_uid) then
    raise exception 'only the group owner or an admin can finish this ride session';
  end if;

  if v_session.status not in ('waiting', 'active') then
    raise exception 'this ride session is already %', v_session.status;
  end if;

  update public.ride_sessions
    set status = 'finished', ended_at = now()
    where id = p_session_id
    returning * into v_session;

  update public.ride_session_members
    set status = 'left', left_at = now()
    where session_id = p_session_id and status = 'active';

  return v_session;
end;
$$;

revoke all on function public.finish_ride_session(uuid) from public;
grant execute on function public.finish_ride_session(uuid) to authenticated;

comment on function public.finish_ride_session(uuid) is
  'Finishes p_session_id and releases its active participants. Owner/admin only. SECURITY DEFINER: see file header.';
