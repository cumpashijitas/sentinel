-- Sentinel V2 — historial de recorrido para "compartir ubicación" personal.
--
-- Mismo rol que public.location_history para un ride_session, pero para
-- un emergency_share (compartir ubicación fuera de un grupo) — pedido
-- explícito en vivo: poder dibujar el camino recorrido en un "viaje
-- individual", igual que ya se puede para un viaje de grupo. No hay
-- columna battery_level, mismo criterio que location_history.

create table public.emergency_share_location_history (
  id bigint generated always as identity primary key,
  share_id uuid not null references public.emergency_shares (id) on delete cascade,
  latitude double precision not null check (latitude >= -90 and latitude <= 90),
  longitude double precision not null check (longitude >= -180 and longitude <= 180),
  accuracy real,
  speed real,
  heading real,
  recorded_at timestamptz not null
);

create index emergency_share_location_history_share_id_idx
  on public.emergency_share_location_history (share_id, recorded_at);
