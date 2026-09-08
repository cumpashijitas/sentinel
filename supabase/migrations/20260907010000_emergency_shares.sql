-- Sentinel V2 — emergency_shares: compartir ubicación con contactos de
-- emergencia, independiente de estar en un viaje de grupo.
--
-- Un motociclista puede activar "compartir mi estado con mis contactos de
-- emergencia" en cualquier momento, esté o no en un viaje de grupo. Genera
-- un `share_token` aleatorio e imposible de adivinar — ese token ES el
-- link público (`/share/<token>`) que cualquiera puede abrir sin cuenta.
-- Los contactos que además tienen cuenta en Sentinel (emergency_contacts.
-- contact_user_id) lo ven también dentro de la app, sin necesitar el link.
--
-- Solo un share activo por usuario a la vez — back/ se encarga de cerrar
-- cualquier anterior antes de abrir uno nuevo (misma lógica que
-- start_ride_session con las sesiones de un grupo, portada a TS desde el
-- principio en este caso, no a SQL — ver docs/architecture.md).

create table public.emergency_shares (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  share_token text not null,
  status text not null default 'active' check (status in ('active', 'ended')),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  constraint emergency_shares_token_key unique (share_token)
);

create index emergency_shares_user_id_idx on public.emergency_shares (user_id);
create index emergency_shares_active_idx
  on public.emergency_shares (user_id)
  where status = 'active';

-- Última posición conocida de un share — misma forma que `live_locations`
-- (una fila por share, upsert en cada fix), pero sin sesión de grupo.
create table public.emergency_share_locations (
  share_id uuid primary key references public.emergency_shares (id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  accuracy real,
  speed real,
  heading real,
  battery_level smallint,
  recorded_at timestamptz not null default now(),
  constraint emergency_share_locations_latitude_range check (latitude between -90 and 90),
  constraint emergency_share_locations_longitude_range check (longitude between -180 and 180)
);

-- Sin RLS ni policies: back/ es el único que toca estas dos tablas, vía su
-- conexión directa a Postgres — ver docs/architecture.md. La ruta pública
-- (`GET /public/emergency-shares/:token`) no tiene ninguna credencial de
-- Supabase, valida acceso por conocer el token, no por sesión.
