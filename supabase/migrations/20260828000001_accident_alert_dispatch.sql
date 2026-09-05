-- Sentinel V2 — Fase 8: dispatch alerts when an accident is confirmed
--
-- The client-side pipeline (Fase 7) can only ever move an accident_events
-- row from 'candidate' to 'confirmed'/'cancelled' — see the RLS policy
-- accident_events_update_self_while_candidate in 20260827210007. Getting
-- from 'confirmed' to actually notifying anyone is, by design, a
-- server-side concern (docs/security.md principle 2): this migration wires
-- a database trigger that fires the moment that transition happens and
-- hands off to the dispatch-accident-alerts Edge Function, which alone has
-- the service_role privilege needed to write `alerts` and read across
-- users. Full design: docs/alerts.md.

-- pg_net gives Postgres an async, non-blocking HTTP client (net.http_post
-- queues the request and returns immediately — the trigger's transaction
-- never waits on the Edge Function's response time).
create extension if not exists pg_net;

-- ---------------------------------------------------------------------------
-- dispatch_accident_alert_webhook: the trigger function.
--
-- Deliberately NOT the built-in supabase_functions.http_request() (the one
-- Supabase Studio's "Database Webhooks" UI generates) — that function only
-- accepts a *static* jsonb literal for headers (a trigger argument, fixed
-- at CREATE TRIGGER time), which would mean baking the webhook's shared
-- secret directly into this migration file — a file committed to git. This
-- version reads the secret from Vault at call time instead, so nothing
-- secret ever appears in tracked source. See docs/alerts.md for how the
-- secret is provisioned per environment (local/staging/prod) — never via a
-- migration.
--
-- If the secret hasn't been provisioned yet (fresh clone, `db reset` before
-- the one-time Vault setup step), this WARNs and returns rather than
-- raising — an accident confirmation must never fail or roll back just
-- because alert dispatch isn't configured yet.
-- ---------------------------------------------------------------------------
create or replace function public.dispatch_accident_alert_webhook()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_secret text;
  -- Local dev default: the Edge Function reachable from *inside* the
  -- Postgres container via the shared docker network is the Kong gateway
  -- container, not host.docker.internal:54321 (that port mapping is only
  -- reachable from the host, not from sibling containers). A real
  -- deployment overrides this with its project's public function URL:
  --   alter database postgres set app.settings.accident_alert_function_url
  --     = 'https://<project-ref>.supabase.co/functions/v1/dispatch-accident-alerts';
  v_url text := coalesce(
    nullif(current_setting('app.settings.accident_alert_function_url', true), ''),
    'http://kong:8000/functions/v1/dispatch-accident-alerts'
  );
begin
  select decrypted_secret into v_secret
  from vault.decrypted_secrets
  where name = 'accident_alert_webhook_secret'
  limit 1;

  if v_secret is null then
    raise warning
      'dispatch_accident_alert_webhook: accident_alert_webhook_secret not set in Vault — accident_event % confirmed but no alert dispatch was triggered. See docs/alerts.md.',
      new.id;
    return new;
  end if;

  perform net.http_post(
    url := v_url,
    body := jsonb_build_object('accident_event_id', new.id),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', v_secret
    ),
    timeout_milliseconds := 5000
  );

  return new;
end;
$$;

comment on function public.dispatch_accident_alert_webhook() is
  'Trigger: on accident_events candidate->confirmed, POSTs {accident_event_id} to the dispatch-accident-alerts Edge Function. Fire-and-forget (pg_net is async). See docs/alerts.md.';

create trigger accident_events_confirmed_dispatch_alerts
  after update on public.accident_events
  for each row
  when (old.status = 'candidate' and new.status = 'confirmed')
  execute function public.dispatch_accident_alert_webhook();
