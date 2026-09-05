-- Sentinel V2 — local development seed data
--
-- Every account below is a REAL row in auth.users (+ auth.identities), not a
-- dangling UUID — so every foreign key in the domain tables below actually
-- resolves, and every user can genuinely log in locally via
-- email/password. This is the standard trick for seeding user-owned rows
-- against Supabase's local stack: GoTrue reads auth.users directly, so
-- inserting into it (with a bcrypt password hash via pgcrypto) is
-- indistinguishable from a real signup. LOCAL/DEV ONLY — never do this
-- against a real project.
--
-- Password for every seed account: Sentinel123!
--
--   rider1@sentinel.dev  Ana Rider    — owns "Ruta de los Domingos", group owner
--   rider2@sentinel.dev  Bruno Rider  — group admin
--   rider3@sentinel.dev  Carla Rider  — group member
--   outsider@sentinel.dev Diego Outsider — NOT in the group (used to prove RLS denies non-members)

do $$
declare
  v_users jsonb := '[
    {"id":"11111111-1111-1111-1111-111111111111","email":"rider1@sentinel.dev","name":"Ana Rider"},
    {"id":"22222222-2222-2222-2222-222222222222","email":"rider2@sentinel.dev","name":"Bruno Rider"},
    {"id":"33333333-3333-3333-3333-333333333333","email":"rider3@sentinel.dev","name":"Carla Rider"},
    {"id":"44444444-4444-4444-4444-444444444444","email":"outsider@sentinel.dev","name":"Diego Outsider"}
  ]'::jsonb;
  v_user jsonb;
begin
  for v_user in select * from jsonb_array_elements(v_users)
  loop
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      confirmation_token, recovery_token, email_change_token_new, email_change,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) values (
      '00000000-0000-0000-0000-000000000000',
      (v_user ->> 'id')::uuid,
      'authenticated',
      'authenticated',
      v_user ->> 'email',
      extensions.crypt('Sentinel123!', extensions.gen_salt('bf')),
      now(),
      '', '', '', '',
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('display_name', v_user ->> 'name'),
      now(), now()
    )
    on conflict (id) do nothing;

    insert into auth.identities (
      id, provider_id, user_id, identity_data, provider, created_at, updated_at, last_sign_in_at
    ) values (
      gen_random_uuid(),
      v_user ->> 'id',
      (v_user ->> 'id')::uuid,
      jsonb_build_object('sub', v_user ->> 'id', 'email', v_user ->> 'email'),
      'email',
      now(), now(), now()
    )
    on conflict (provider_id, provider) do nothing;
  end loop;
end;
$$;

-- profiles rows for the four accounts above already exist at this point,
-- created automatically by the on_auth_user_created trigger.

update public.profiles set phone = '+591 700 00001' where id = '11111111-1111-1111-1111-111111111111';
update public.profiles set phone = '+591 700 00002' where id = '22222222-2222-2222-2222-222222222222';
-- rider3: phone + WhatsApp opt-in, but NO device_push_tokens override below
-- (rider3 keeps their seeded 'web' token) — this fixture deliberately has
-- push AND WhatsApp both reachable for the same person, to prove
-- dispatch-accident-alerts attempts both independently (Fase 8 extensión).
update public.profiles set phone = '+591 700 00003', whatsapp_alerts_opt_in = true where id = '33333333-3333-3333-3333-333333333333';

-- ---------------------------------------------------------------------------
-- vehicles
-- ---------------------------------------------------------------------------
insert into public.vehicles (id, owner_id, brand, model, year, plate, color) values
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111',
   'Honda', 'CB500X', 2022, 'SEN-101', 'Rojo'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccd', '22222222-2222-2222-2222-222222222222',
   'Yamaha', 'MT-07', 2021, 'SEN-102', 'Azul');

-- ---------------------------------------------------------------------------
-- emergency_contacts
-- ---------------------------------------------------------------------------
insert into public.emergency_contacts (owner_id, contact_user_id, name, phone, relationship, notify_push, notify_sms, notify_whatsapp) values
  -- linked to another Sentinel account (rider2): reachable by push, SMS
  -- AND WhatsApp — all three, to prove each is attempted independently.
  ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
   'Bruno Rider', '+591 700 00002', 'Compañero de ruta', true, true, true),
  -- phone-only contact, no Sentinel account, and deliberately did NOT
  -- consent to WhatsApp (notify_whatsapp=false) — proves the flag is
  -- respected literally, not inferred from having a phone on file.
  ('11111111-1111-1111-1111-111111111111', null,
   'María Rider', '+591 700 09999', 'Familiar', false, true, false);

-- ---------------------------------------------------------------------------
-- ride_groups + ride_group_members
-- ---------------------------------------------------------------------------
insert into public.ride_groups (id, owner_id, name, description, invite_code, status) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111',
   'Ruta de los Domingos', 'Salida grupal todos los domingos por la mañana.', 'SUNDAY01', 'active');

insert into public.ride_group_members (group_id, user_id, role, status) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'owner', 'active'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'admin', 'active'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'member', 'active');
  -- outsider (44444444-…) is deliberately NOT a member of this group.

-- ---------------------------------------------------------------------------
-- ride_sessions + ride_session_members (an in-progress ride)
-- ---------------------------------------------------------------------------
insert into public.ride_sessions (id, group_id, started_by, name, status, started_at) values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   '11111111-1111-1111-1111-111111111111', 'Salida domingo 30/08', 'active', now() - interval '20 minutes');

insert into public.ride_session_members (session_id, user_id, status, joined_at, last_seen_at) values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'active', now() - interval '20 minutes', now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'active', now() - interval '19 minutes', now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'active', now() - interval '18 minutes', now());

-- ---------------------------------------------------------------------------
-- live_locations (current position, one row per rider in the session)
-- ---------------------------------------------------------------------------
insert into public.live_locations (session_id, user_id, latitude, longitude, accuracy, speed, heading, battery_level, recorded_at) values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', -17.393800, -66.156900, 5, 12.3, 90, 82, now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', -17.394200, -66.157400, 6, 14.1, 91, 65, now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', -17.393500, -66.156200, 4, 10.8, 88, 43, now());

-- ---------------------------------------------------------------------------
-- location_history (a couple of earlier fixes for the group owner)
-- ---------------------------------------------------------------------------
insert into public.location_history (session_id, user_id, latitude, longitude, accuracy, speed, heading, recorded_at) values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', -17.395100, -66.158200, 6, 8.5, 85, now() - interval '15 minutes'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', -17.394500, -66.157600, 5, 11.0, 89, now() - interval '8 minutes');

-- ---------------------------------------------------------------------------
-- accident_events — one still-private candidate, one confirmed (visible to
-- the session) with a matching alert
-- ---------------------------------------------------------------------------
insert into public.accident_events (id, session_id, user_id, latitude, longitude, impact_mps2, gyro_rad_s, speed_kmh, g_force, confidence_score, status, occurred_at)
values
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222',
   -17.394200, -66.157400, 22.5, 3.1, 41.0, 2.3, 0.55, 'candidate', now() - interval '2 minutes'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333',
   -17.393500, -66.156200, 38.9, 6.7, 52.4, 4.1, 0.92, 'confirmed', now() - interval '10 minutes');

update public.accident_events
  set confirmed_at = now() - interval '9 minutes 30 seconds'
  where id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

insert into public.alerts (accident_id, recipient_type, recipient_user_id, channel, status, sent_at) values
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'group_member', '11111111-1111-1111-1111-111111111111', 'push', 'sent', now() - interval '9 minutes');

-- A third accident_event, still 'candidate' and owned by rider1 (who,
-- unlike rider2/rider3, actually has emergency_contacts seeded above) —
-- Fase 8's fixture for exercising dispatch-accident-alerts end to end:
-- flipping this row to 'confirmed' fires the trigger and should produce
-- alerts for both of rider1's session-mates (group_member, push, via their
-- seeded device_push_tokens) AND rider1's emergency_contacts (rider2 by
-- push+sms, María by sms only) — see docs/alerts.md "cómo verificar".
insert into public.accident_events (id, session_id, user_id, latitude, longitude, impact_mps2, gyro_rad_s, speed_kmh, g_force, confidence_score, status, occurred_at)
values
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111',
   -17.393800, -66.156900, 25.4, 4.2, 38.5, 2.6, 0.61, 'candidate', now() - interval '1 minute');

-- ---------------------------------------------------------------------------
-- device_push_tokens
-- ---------------------------------------------------------------------------
insert into public.device_push_tokens (user_id, platform, token) values
  ('11111111-1111-1111-1111-111111111111', 'android', 'seed-token-rider1-android'),
  ('22222222-2222-2222-2222-222222222222', 'android', 'seed-token-rider2-android'),
  ('33333333-3333-3333-3333-333333333333', 'web', 'seed-token-rider3-web');
