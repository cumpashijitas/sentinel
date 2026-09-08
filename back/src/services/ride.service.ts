// Sentinel back/ — reglas de negocio de viajes (ride sessions) y ubicación.
//
// Puerto de `start_ride_session`/`finish_ride_session`
// (`supabase/migrations/20260827210009_rpc_functions.sql`), del helper
// `is_session_member` (`20260827210005_ride_sessions.sql`), y de las
// escrituras a `live_locations`/`location_history` que antes hacía el
// cliente directo contra Supabase (`20260827210006_locations.sql`).

import { pool, withTransaction } from '../db/pool.js';
import { HttpError } from '../lib/http.js';
import { isGroupAdmin, isGroupMember } from './group.service.js';

export async function isSessionMember(
  sessionId: string,
  userId: string,
): Promise<boolean> {
  const { rows } = await pool.query(
    `select 1 from public.ride_session_members
      where session_id = $1 and user_id = $2 and status = 'active'
      limit 1`,
    [sessionId, userId],
  );
  return rows.length > 0;
}

/** `null` (not an error) when the caller isn't a member of the group, or
 * the group has no waiting/active session — same as the old RLS-filtered
 * `.maybeSingle()` returning null. */
export async function fetchActiveSession(userId: string, groupId: string) {
  if (!(await isGroupMember(groupId, userId))) return null;
  const { rows } = await pool.query(
    `select * from public.ride_sessions
      where group_id = $1 and status in ('waiting', 'active')`,
    [groupId],
  );
  return rows[0] ?? null;
}

export async function fetchSession(userId: string, sessionId: string) {
  const { rows } = await pool.query(
    'select * from public.ride_sessions where id = $1',
    [sessionId],
  );
  const session = rows[0];
  if (!session || !(await isGroupMember(session.group_id, userId))) {
    throw new HttpError(404, 'ride session not found');
  }
  return session;
}

/** Empty (not an error) when the caller isn't an active participant — same
 * as `ride_session_members_select`'s RLS silently returning zero rows. */
export async function fetchParticipants(userId: string, sessionId: string) {
  if (!(await isSessionMember(sessionId, userId))) return [];
  const { rows } = await pool.query(
    `select * from public.ride_session_members
      where session_id = $1 and status = 'active'
      order by joined_at`,
    [sessionId],
  );
  return rows;
}

export async function startSession(
  userId: string,
  groupId: string,
  name: string | null,
) {
  if (!(await isGroupAdmin(groupId, userId))) {
    throw new HttpError(
      403,
      'only the group owner or an admin can start a ride session',
    );
  }

  return withTransaction(async (client) => {
    const { rows: existing } = await client.query(
      `select 1 from public.ride_sessions
        where group_id = $1 and status in ('waiting', 'active')`,
      [groupId],
    );
    if (existing.length > 0) {
      throw new HttpError(409, 'this group already has an active ride session');
    }

    const { rows: sessionRows } = await client.query(
      `insert into public.ride_sessions (group_id, started_by, name, status, started_at)
       values ($1, $2, $3, 'active', now())
       returning *`,
      [groupId, userId, name],
    );
    const session = sessionRows[0];

    await client.query(
      `insert into public.ride_session_members (session_id, user_id, status, joined_at)
       select $1, m.user_id, 'active', now()
         from public.ride_group_members m
        where m.group_id = $2 and m.status = 'active'`,
      [session.id, groupId],
    );

    return session;
  });
}

export async function finishSession(userId: string, sessionId: string) {
  return withTransaction(async (client) => {
    const { rows } = await client.query(
      'select * from public.ride_sessions where id = $1',
      [sessionId],
    );
    const session = rows[0];
    if (!session) throw new HttpError(404, 'ride session not found');

    if (!(await isGroupAdmin(session.group_id, userId))) {
      throw new HttpError(
        403,
        'only the group owner or an admin can finish this ride session',
      );
    }
    if (session.status !== 'waiting' && session.status !== 'active') {
      throw new HttpError(409, `this ride session is already ${session.status}`);
    }

    const { rows: updated } = await client.query(
      `update public.ride_sessions
          set status = 'finished', ended_at = now()
        where id = $1
        returning *`,
      [sessionId],
    );
    await client.query(
      `update public.ride_session_members
          set status = 'left', left_at = now()
        where session_id = $1 and status = 'active'`,
      [sessionId],
    );
    return updated[0];
  });
}

/** Mirrors the old `ride_session_members?select=session_id,
 * ride_sessions(*, ride_groups(name))` PostgREST nested-select the client
 * used to run directly — same shape (a `ride_sessions` object embedded
 * under each row, itself carrying a `ride_groups` object) so
 * `RideSessionRepositoryImpl.fetchHistory`'s parsing needed zero changes. */
export async function fetchHistoryRows(userId: string) {
  const { rows } = await pool.query(
    `select
        rsm.session_id,
        json_build_object(
          'id', rs.id, 'group_id', rs.group_id, 'started_by', rs.started_by,
          'name', rs.name, 'status', rs.status, 'started_at', rs.started_at,
          'ended_at', rs.ended_at, 'created_at', rs.created_at,
          'ride_groups', json_build_object('name', rg.name)
        ) as ride_sessions
       from public.ride_session_members rsm
       join public.ride_sessions rs on rs.id = rsm.session_id
       join public.ride_groups rg on rg.id = rs.group_id
      where rsm.user_id = $1`,
    [userId],
  );
  return rows;
}

// ---------------------------------------------------------------------------
// Ubicación en vivo — solo escritura (la lectura sigue siendo Supabase
// Realtime directo desde el front, ver docs/architecture.md). Ambas
// operaciones exigen ser un participante activo de la sesión, igual que
// `live_locations_insert_self`/`location_history_insert_self`.
// ---------------------------------------------------------------------------

/** Empty (not an error) when the caller isn't an active session
 * participant — same as `live_locations_select_session_members`'s RLS
 * silently returning zero rows. Used both by `GET
 * /sessions/:id/locations` (the initial snapshot the front reads once
 * before opening the WebSocket, see `ws/location-hub.ts`) and by the hub
 * itself when a client first connects. */
export async function fetchCurrentLocations(userId: string, sessionId: string) {
  if (!(await isSessionMember(sessionId, userId))) return [];
  const { rows } = await pool.query(
    'select * from public.live_locations where session_id = $1',
    [sessionId],
  );
  return rows;
}

export interface LocationFixInput {
  latitude: number;
  longitude: number;
  accuracy?: number | null;
  speed?: number | null;
  heading?: number | null;
  batteryLevel?: number | null;
  recordedAt: string;
}

export async function upsertMyLocation(
  userId: string,
  sessionId: string,
  fix: LocationFixInput,
) {
  if (!(await isSessionMember(sessionId, userId))) {
    throw new HttpError(
      403,
      'you must be an active session participant to share your location',
    );
  }
  // `returning *` — the caller (rides.routes.ts) broadcasts this row over
  // the WebSocket hub to the session's other viewers (see
  // ws/location-hub.ts), replacing the Realtime `postgres_changes` event
  // Supabase used to push automatically.
  const { rows } = await pool.query(
    `insert into public.live_locations
       (session_id, user_id, latitude, longitude, accuracy, speed, heading, battery_level, recorded_at)
     values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     on conflict (session_id, user_id) do update
       set latitude = excluded.latitude,
           longitude = excluded.longitude,
           accuracy = excluded.accuracy,
           speed = excluded.speed,
           heading = excluded.heading,
           battery_level = excluded.battery_level,
           recorded_at = excluded.recorded_at
     returning *`,
    [
      sessionId,
      userId,
      fix.latitude,
      fix.longitude,
      fix.accuracy ?? null,
      fix.speed ?? null,
      fix.heading ?? null,
      fix.batteryLevel ?? null,
      fix.recordedAt,
    ],
  );
  return rows[0];
}

export async function recordLocationHistory(
  userId: string,
  sessionId: string,
  fix: LocationFixInput,
) {
  if (!(await isSessionMember(sessionId, userId))) {
    throw new HttpError(
      403,
      'you must be an active session participant to record location history',
    );
  }
  // location_history has no battery_level column, same as the old
  // SupabaseLiveLocationRemoteDataSource.recordHistory.
  await pool.query(
    `insert into public.location_history
       (session_id, user_id, latitude, longitude, accuracy, speed, heading, recorded_at)
     values ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [
      sessionId,
      userId,
      fix.latitude,
      fix.longitude,
      fix.accuracy ?? null,
      fix.speed ?? null,
      fix.heading ?? null,
      fix.recordedAt,
    ],
  );
}
