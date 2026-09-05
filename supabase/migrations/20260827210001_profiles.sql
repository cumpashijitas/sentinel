-- Sentinel V2 — profiles
--
-- One row per Sentinel account, 1:1 with auth.users. Created automatically
-- by the on_auth_user_created trigger below — never inserted by the client.

-- Shared trigger function reused by every table below that has an
-- `updated_at` column. Defined once here since this is the first migration.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'Generic BEFORE UPDATE trigger: stamps updated_at = now() on every row update.';

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  phone text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is
  'Public-facing profile for a Sentinel account. 1:1 with auth.users, created by on_auth_user_created.';

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;

-- A user can always read and edit their own profile.
create policy profiles_select_own
  on public.profiles for select
  using (id = auth.uid());

create policy profiles_update_own
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

-- No INSERT/DELETE policy for authenticated/anon: rows are created
-- exclusively by the on_auth_user_created trigger (SECURITY DEFINER, below)
-- and removed only via the auth.users ON DELETE CASCADE. This keeps profile
-- creation a single, trusted code path instead of something any signed-in
-- client could forge for another id.
--
-- NOTE: the policy that lets a user read their *fellow group members'*
-- profiles is added in 20260827210004_ride_groups.sql, once
-- ride_group_members (and therefore is_group_member) exists. Until that
-- migration runs, profiles_select_own is the only SELECT policy.

-- ---------------------------------------------------------------------------
-- Auto-create a profile when a new auth.users row appears.
-- ---------------------------------------------------------------------------
--
-- SECURITY DEFINER is required here: this trigger fires under whichever role
-- performed the INSERT into auth.users (supabase_auth_admin for real
-- sign-ups, postgres for seed.sql), and that role has no reason to also hold
-- INSERT rights on public.profiles. Running as the function owner (postgres)
-- lets it write the row regardless of caller, while the function body itself
-- is narrow (a single insert derived from the NEW row) so it can't be
-- repurposed to write arbitrary data. `search_path` is pinned to `public` to
-- prevent a search_path-hijacking attack against a SECURITY DEFINER function.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing; -- idempotent: never duplicate a profile

  return new;
end;
$$;

comment on function public.handle_new_user() is
  'Creates public.profiles row for a new auth.users signup. SECURITY DEFINER: see inline comment.';

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
