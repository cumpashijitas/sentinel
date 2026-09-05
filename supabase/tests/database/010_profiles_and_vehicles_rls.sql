-- Sentinel V2 — RLS: profiles and vehicles are private, edits by another
-- user are silently filtered out (0 rows affected), never applied.
--
-- Run with: npx supabase test db
--
-- Fixtures come from supabase/seed.sql (applied by `db reset` before this
-- runs): rider1/rider2/rider3 share "Ruta de los Domingos"; outsider does
-- not belong to any group.
begin;
select plan(6);

-- ---------------------------------------------------------------------------
-- usuario A no puede modificar perfil B
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

update public.profiles set display_name = 'Hacked by rider1' where id = '33333333-3333-3333-3333-333333333333';

reset role;
select set_config('request.jwt.claims', '', true);

select isnt(
  (select display_name from public.profiles where id = '33333333-3333-3333-3333-333333333333'),
  'Hacked by rider1',
  'rider1 cannot change rider3''s (fellow group member''s) display_name'
);

-- sanity: rider3 can still update their own profile
set local role authenticated;
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

update public.profiles set display_name = 'Carla R.' where id = '33333333-3333-3333-3333-333333333333';

reset role;
select set_config('request.jwt.claims', '', true);

select is(
  (select display_name from public.profiles where id = '33333333-3333-3333-3333-333333333333'),
  'Carla R.',
  'rider3 can update their own profile'
);

-- ---------------------------------------------------------------------------
-- usuario A no puede editar vehículo B
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

update public.vehicles set color = 'Verde' where id = 'cccccccc-cccc-cccc-cccc-cccccccccccd'; -- rider2's vehicle

reset role;
select set_config('request.jwt.claims', '', true);

select isnt(
  (select color from public.vehicles where id = 'cccccccc-cccc-cccc-cccc-cccccccccccd'),
  'Verde',
  'rider1 cannot change rider2''s vehicle'
);

-- rider1 CAN edit their own vehicle
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

update public.vehicles set color = 'Negro' where id = 'cccccccc-cccc-cccc-cccc-cccccccccccc'; -- rider1's own vehicle

reset role;
select set_config('request.jwt.claims', '', true);

select is(
  (select color from public.vehicles where id = 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
  'Negro',
  'rider1 can update their own vehicle'
);

-- an outsider (no vehicles of their own) cannot even see rider1's vehicle
set local role authenticated;
set local request.jwt.claims to '{"sub":"44444444-4444-4444-4444-444444444444","role":"authenticated"}';

select is(
  (select count(*)::int from public.vehicles where owner_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'outsider cannot read rider1''s vehicles'
);

reset role;
select set_config('request.jwt.claims', '', true);

-- and an unauthenticated (anon) request sees no profiles at all
set local role anon;

select is(
  (select count(*)::int from public.profiles),
  0,
  'anonymous (unauthenticated) role cannot read any profile'
);

reset role;

select * from finish();
rollback;
