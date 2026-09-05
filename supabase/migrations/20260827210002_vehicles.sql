-- Sentinel V2 — vehicles
--
-- A rider's motorcycles. Strictly private: only the owner ever sees or edits
-- their own vehicles (no group-sharing concept for this table).

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  brand text not null,
  model text not null,
  year integer,
  plate text,
  color text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vehicles_year_range
    check (year is null or year between 1900 and extract(year from now())::int + 1)
);

create index vehicles_owner_id_idx on public.vehicles (owner_id);

create trigger set_vehicles_updated_at
  before update on public.vehicles
  for each row execute function public.set_updated_at();

alter table public.vehicles enable row level security;

-- Minimum privilege: full CRUD, but only ever on rows the caller owns.
create policy vehicles_select_own
  on public.vehicles for select
  using (owner_id = auth.uid());

create policy vehicles_insert_own
  on public.vehicles for insert
  with check (owner_id = auth.uid());

create policy vehicles_update_own
  on public.vehicles for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy vehicles_delete_own
  on public.vehicles for delete
  using (owner_id = auth.uid());
