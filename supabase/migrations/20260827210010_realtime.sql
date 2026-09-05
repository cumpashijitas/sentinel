-- Sentinel V2 — Realtime private channel authorization
--
-- `postgres_changes` on live_locations / ride_group_members / ride_sessions
-- / accident_events (enabled alongside each table in its own migration) is
-- already access-controlled for free: Realtime evaluates each subscriber's
-- own RLS on the underlying table, so a client whose SELECT policy would
-- return zero rows for a table simply never receives change events for it.
-- No separate channel-level rule is needed for those.
--
-- This migration covers the other case the app also needs: a named,
-- non-table Broadcast/Presence channel per ride, `ride:<session_id>` (e.g.
-- ephemeral "member went offline" signals, typing/presence-style state that
-- isn't backed by a row). That uses Supabase's Realtime Authorization
-- feature: RLS policies on `realtime.messages`, keyed by the channel's
-- topic. RLS is already enabled by default on `realtime.messages` (no
-- ALTER TABLE needed) — see
-- https://supabase.com/docs/guides/realtime/authorization.
--
-- Client contract: a client must open the channel with
-- `RealtimeChannelConfig(private: true)` (Dart) / `{ config: { private:
-- true } }` (JS) for these policies to be consulted at all — a non-private
-- channel bypasses this check entirely, so the Flutter client code for ride
-- channels MUST always set `private: true` when this lands.

create policy "ride channel: session members can read"
  on realtime.messages for select
  to authenticated
  using (
    realtime.topic() like 'ride:%'
    and public.is_session_member(
      (substring(realtime.topic() from 6))::uuid,
      auth.uid()
    )
  );

create policy "ride channel: session members can write"
  on realtime.messages for insert
  to authenticated
  with check (
    realtime.topic() like 'ride:%'
    and public.is_session_member(
      (substring(realtime.topic() from 6))::uuid,
      auth.uid()
    )
  );

-- No UPDATE/DELETE policy: realtime.messages entries for broadcast/presence
-- are write-once, read-only after that — nothing in this app needs to
-- mutate or remove a past message.
