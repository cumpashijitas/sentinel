-- Sentinel V2 — Fase 8: schema-level regression guards for the alert
-- dispatch pipeline. What this deliberately does NOT test: the trigger
-- actually reaching the Edge Function (pg_net's HTTP call is async and
-- network-dependent — out of scope for pgTAP, verified live instead, see
-- docs/alerts.md "cómo verificar").
begin;
select plan(7);

select has_extension('pg_net', 'pg_net is installed (needed by the accident alert dispatch trigger)');

select has_trigger(
  'public', 'accident_events', 'accident_events_confirmed_dispatch_alerts',
  'the confirmed-accident alert dispatch trigger exists on accident_events'
);

-- `alerts` staying policy-less for every client role is the whole reason
-- dispatch-accident-alerts needs to exist as a service_role Edge Function
-- in the first place (see the migration's comment) — a regression here
-- would silently make this table writable/readable straight from the
-- Flutter client.
select policies_are(
  'public', 'alerts', ARRAY[]::name[],
  'alerts has zero client-facing RLS policies (service_role/Edge Function only)'
);

select is(
  (select relrowsecurity from pg_class where oid = 'public.alerts'::regclass),
  true,
  'alerts keeps RLS enabled even with no policies (deny-by-default, not "RLS off")'
);

-- WhatsApp extensión: 'whatsapp' es un valor válido de alert_channel, y
-- existen las dos columnas de consentimiento que dispatch-accident-alerts
-- exige antes de intentar ese canal (ver 20260829000001_whatsapp_alerts.sql).
select enum_has_labels(
  'public', 'alert_channel', ARRAY['push', 'sms', 'email', 'whatsapp'],
  'alert_channel includes whatsapp alongside push/sms/email'
);

select has_column(
  'public', 'emergency_contacts', 'notify_whatsapp',
  'emergency_contacts has a notify_whatsapp consent flag, independent of notify_push/notify_sms'
);

select has_column(
  'public', 'profiles', 'whatsapp_alerts_opt_in',
  'profiles has a whatsapp_alerts_opt_in consent flag for group-member alerts'
);

select * from finish();
rollback;
