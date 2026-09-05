-- Sentinel V2 — RLS: accident_events cannot be forged for another user, and
-- visibility follows the candidate/confirmed split.
begin;
select plan(4);

-- ---------------------------------------------------------------------------
-- usuario no puede falsificar un accident_event para otro user_id
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select throws_ok(
  $$ insert into public.accident_events (session_id, user_id, impact_mps2)
     values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 30.0) $$,
  'new row violates row-level security policy for table "accident_events"',
  'rider1 cannot insert an accident_event with someone else''s user_id'
);

-- but CAN insert their own
select lives_ok(
  $$ insert into public.accident_events (session_id, user_id, impact_mps2)
     values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 30.0) $$,
  'rider1 can insert an accident_event with their own user_id'
);

-- ---------------------------------------------------------------------------
-- visibility: a 'candidate' accident stays private to its owner, even to
-- session-mates; a 'confirmed' one is visible to the whole session.
-- ---------------------------------------------------------------------------
reset role;
select set_config('request.jwt.claims', '', true);
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select is(
  (select count(*)::int from public.accident_events
     where id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'), -- rider2's 'candidate' event
  0,
  'rider1 cannot see rider2''s still-candidate accident_event, even sharing a session'
);

select is(
  (select count(*)::int from public.accident_events
     where id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'), -- rider3's 'confirmed' event
  1,
  'rider1 can see rider3''s confirmed accident_event via the session-members policy'
);

select * from finish();
rollback;
