-- Sentinel V2 — join_group_by_code() and leave_group() RPCs.
begin;
select plan(9);

-- ---------------------------------------------------------------------------
-- join_group_by_code funciona
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub":"44444444-4444-4444-4444-444444444444","role":"authenticated"}';

-- outsider is not a member yet
select is(
  (select count(*)::int from public.ride_group_members
     where group_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
       and user_id = '44444444-4444-4444-4444-444444444444'),
  0,
  'outsider is not yet a member of "Ruta de los Domingos"'
);

select is(
  public.join_group_by_code('SUNDAY01'),
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  'join_group_by_code returns the correct group_id for a valid invite code'
);

select is(
  (select status::text from public.ride_group_members
     where group_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
       and user_id = '44444444-4444-4444-4444-444444444444'),
  'active',
  'outsider is now an active member after joining'
);

-- idempotent: joining again while already active does not error or duplicate
select lives_ok(
  $$ select public.join_group_by_code('SUNDAY01') $$,
  'joining again while already active is a no-op, not an error'
);

select is(
  (select count(*)::int from public.ride_group_members
     where group_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
       and user_id = '44444444-4444-4444-4444-444444444444'),
  1,
  'joining twice does not create a duplicate membership row'
);

-- an invalid code is rejected
select throws_ok(
  $$ select public.join_group_by_code('NOTREAL1') $$,
  'invalid invite code',
  'join_group_by_code rejects an unknown invite code'
);

-- ---------------------------------------------------------------------------
-- abandonar grupo funciona
-- ---------------------------------------------------------------------------
select lives_ok(
  $$ select public.leave_group('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  'the newly-joined member can leave the group'
);

reset role;
select set_config('request.jwt.claims', '', true);

select is(
  (select status::text from public.ride_group_members
     where group_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
       and user_id = '44444444-4444-4444-4444-444444444444'),
  'left',
  'leave_group actually set the membership status to left'
);

-- domain rule: the owner cannot leave their own group this way
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select throws_ok(
  $$ select public.leave_group('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') $$,
  'the group owner cannot leave; transfer ownership or archive the group first',
  'the group owner cannot call leave_group on their own group'
);

reset role;
select set_config('request.jwt.claims', '', true);

select * from finish();
rollback;
