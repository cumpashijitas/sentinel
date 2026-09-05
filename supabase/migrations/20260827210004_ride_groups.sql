-- Sentinel V2 — ride_groups, ride_group_members
--
-- A group of riders. Membership is many-to-many via ride_group_members,
-- whose composite primary key (group_id, user_id) is what guarantees a
-- user can never be duplicated in the same group — re-joining after
-- leaving updates that same row instead of inserting a new one (see
-- join_group_by_code in 20260827210009_rpc_functions.sql).

create type public.ride_group_status as enum ('active', 'archived');
create type public.ride_group_role as enum ('owner', 'admin', 'member');
create type public.ride_group_member_status as enum ('invited', 'active', 'left', 'removed');

create table public.ride_groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  description text,
  invite_code text not null,
  status public.ride_group_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ride_groups_invite_code_key unique (invite_code),
  constraint ride_groups_name_not_blank check (btrim(name) <> '')
);

create index ride_groups_owner_id_idx on public.ride_groups (owner_id);

create trigger set_ride_groups_updated_at
  before update on public.ride_groups
  for each row execute function public.set_updated_at();

create table public.ride_group_members (
  group_id uuid not null references public.ride_groups (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.ride_group_role not null default 'member',
  status public.ride_group_member_status not null default 'active',
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  primary key (group_id, user_id) -- also the anti-duplicate-membership constraint
);

create index ride_group_members_user_id_idx on public.ride_group_members (user_id);

-- ---------------------------------------------------------------------------
-- Helper functions
-- ---------------------------------------------------------------------------
--
-- Both are SECURITY DEFINER for the same reason: a policy on
-- ride_group_members that queried ride_group_members through a normal
-- (invoker-rights) function would recheck RLS on ride_group_members while
-- evaluating that very policy, which either recurses or forces a much wider
-- policy just to let the check see the rows it needs. Running the helper as
-- the (trusted, table-owning) function owner sidesteps that self-reference.
-- This is safe because the function is narrow and read-only: it can only
-- ever answer "is this exact (group, user) pair an active member/admin?",
-- never return arbitrary rows. `search_path` is pinned to `public` to rule
-- out search_path hijacking, and EXECUTE is granted only to `authenticated`
-- (never to `anon`/`public`).
create or replace function public.is_group_member(group_uuid uuid, user_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.ride_group_members m
    where m.group_id = group_uuid
      and m.user_id = user_uuid
      and m.status = 'active'
  );
$$;

create or replace function public.is_group_admin(group_uuid uuid, user_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.ride_group_members m
    where m.group_id = group_uuid
      and m.user_id = user_uuid
      and m.status = 'active'
      and m.role in ('owner', 'admin')
  );
$$;

revoke all on function public.is_group_member(uuid, uuid) from public;
revoke all on function public.is_group_admin(uuid, uuid) from public;
grant execute on function public.is_group_member(uuid, uuid) to authenticated;
grant execute on function public.is_group_admin(uuid, uuid) to authenticated;

comment on function public.is_group_member(uuid, uuid) is
  'True if user_uuid is an active member of group_uuid. SECURITY DEFINER to avoid RLS self-recursion on ride_group_members — see inline comment.';
comment on function public.is_group_admin(uuid, uuid) is
  'True if user_uuid is an active owner/admin of group_uuid. SECURITY DEFINER — see is_group_member comment.';

-- ---------------------------------------------------------------------------
-- RLS — ride_groups
-- ---------------------------------------------------------------------------
alter table public.ride_groups enable row level security;

create policy ride_groups_select_members
  on public.ride_groups for select
  using (public.is_group_member(id, auth.uid()));

create policy ride_groups_update_owner
  on public.ride_groups for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy ride_groups_delete_owner
  on public.ride_groups for delete
  using (owner_id = auth.uid());

-- No INSERT policy: creating a group must also insert the creator as its
-- 'owner' member atomically, which a bare RLS policy can't express. That's
-- exactly what create_ride_group() (SECURITY DEFINER RPC) does — see
-- 20260827210009_rpc_functions.sql. This keeps "a group always has exactly
-- one consistent owner membership row" true by construction.

-- ---------------------------------------------------------------------------
-- RLS — ride_group_members
-- ---------------------------------------------------------------------------
alter table public.ride_group_members enable row level security;

create policy ride_group_members_select
  on public.ride_group_members for select
  using (public.is_group_member(group_id, auth.uid()));

-- Owner/admin can invite (insert an 'invited'/'active' row) and otherwise
-- administer members (change role/status) directly.
create policy ride_group_members_insert_admin
  on public.ride_group_members for insert
  with check (public.is_group_admin(group_id, auth.uid()));

create policy ride_group_members_update_admin
  on public.ride_group_members for update
  using (public.is_group_admin(group_id, auth.uid()))
  with check (public.is_group_admin(group_id, auth.uid()));

-- No DELETE policy: memberships are soft-removed via status ('left'/
-- 'removed'), never hard-deleted from the client. No self-service INSERT/
-- UPDATE policy for a plain member either — joining goes through
-- join_group_by_code() and leaving through leave_group(), both RPCs, so
-- that domain rules (valid invite code, can't-duplicate, owner-can't-leave)
-- are enforced in one trusted place instead of re-implemented in RLS.

-- ---------------------------------------------------------------------------
-- profiles: let group-mates see each other's basic profile
-- ---------------------------------------------------------------------------
--
-- Design decision: this grants full SELECT on the profiles row (including
-- `phone`) to anyone sharing an active group with the owner, not just a
-- reduced column set — Postgres RLS is row-level, not column-level, and for
-- a group-ride safety app being able to call a companion is a feature, not
-- a leak. If a future requirement needs to hide `phone` from group-mates
-- specifically, split it into a narrower `public.group_member_profiles`
-- view instead of trying to do column-level filtering in this policy.
create policy profiles_select_group_members
  on public.profiles for select
  using (
    exists (
      select 1
      from public.ride_group_members me
      join public.ride_group_members them
        on them.group_id = me.group_id
       and them.status = 'active'
      where me.user_id = auth.uid()
        and me.status = 'active'
        and them.user_id = profiles.id
    )
  );

-- Realtime: group roster changes (join/leave/role change) are shown live.
alter publication supabase_realtime add table public.ride_group_members;
