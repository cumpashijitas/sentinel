-- Sentinel V2 — RLS: live_locations visibility and write scope.
--
-- Fixtures: session bbbbbbbb-…bbbb has rider1/rider2/rider3 as active
-- participants (from seed.sql); outsider is not a participant.
begin;
select plan(5);

-- ---------------------------------------------------------------------------
-- usuario externo no puede leer ubicación de una sesión
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub":"44444444-4444-4444-4444-444444444444","role":"authenticated"}';

select is(
  (select count(*)::int from public.live_locations where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  0,
  'outsider cannot read any live_locations row for a session they do not belong to'
);

reset role;
select set_config('request.jwt.claims', '', true);

-- ---------------------------------------------------------------------------
-- miembro sí puede leer ubicación de compañeros de sesión
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select is(
  (select count(*)::int from public.live_locations where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  3,
  'rider1 (a session member) can read all 3 companions'' live_locations rows'
);

select ok(
  exists(
    select 1 from public.live_locations
    where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
      and user_id = '33333333-3333-3333-3333-333333333333' -- rider3, not rider1
  ),
  'rider1 can specifically read rider3''s (a companion''s) position, not just their own'
);

-- ---------------------------------------------------------------------------
-- usuario sólo puede actualizar su propia ubicación
-- ---------------------------------------------------------------------------
update public.live_locations
  set latitude = 0, longitude = 0
  where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
    and user_id = '22222222-2222-2222-2222-222222222222'; -- rider2, not rider1

reset role;
select set_config('request.jwt.claims', '', true);

select isnt(
  (select latitude from public.live_locations
    where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
      and user_id = '22222222-2222-2222-2222-222222222222'),
  0::double precision,
  'rider1 cannot overwrite rider2''s live_locations row'
);

set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

update public.live_locations
  set latitude = -17.4, longitude = -66.2
  where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
    and user_id = '11111111-1111-1111-1111-111111111111'; -- rider1's own row

reset role;
select set_config('request.jwt.claims', '', true);

select is(
  (select latitude from public.live_locations
    where session_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
      and user_id = '11111111-1111-1111-1111-111111111111'),
  -17.4::double precision,
  'rider1 can update their own live_locations row'
);

select * from finish();
rollback;
