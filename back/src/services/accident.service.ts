// Sentinel back/ — reglas de negocio de accident_events.
//
// Puerto de las políticas RLS de
// `supabase/migrations/20260827210007_accident_events.sql` (nunca hubo un
// RPC para esto — era CRUD directo protegido por RLS) más el despacho de
// alertas, que ahora se dispara en el mismo request que confirma el
// accidente en vez de vía trigger + Edge Function (ver
// `back/src/alerts/dispatch.ts`).

import { pool } from '../db/pool.js';
import { HttpError } from '../lib/http.js';
import { dispatchAlertsFor } from '../alerts/dispatch.js';
import { isSessionMember } from './ride.service.js';

export interface ReportCandidateInput {
  sessionId: string | null;
  latitude: number | null;
  longitude: number | null;
  impactMps2: number;
  gyroRadS: number | null;
  gForce: number | null;
  confidenceScore: number | null;
  sensorSnapshot: unknown;
}

export async function reportCandidate(userId: string, input: ReportCandidateInput) {
  const { rows } = await pool.query(
    `insert into public.accident_events
       (user_id, session_id, latitude, longitude, impact_mps2, gyro_rad_s,
        g_force, confidence_score, sensor_snapshot)
     values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     returning *`,
    [
      userId,
      input.sessionId,
      input.latitude,
      input.longitude,
      input.impactMps2,
      input.gyroRadS,
      input.gForce,
      input.confidenceScore,
      JSON.stringify(input.sensorSnapshot ?? {}),
    ],
  );
  return rows[0];
}

/** `cancelled`/`confirmed` only ever apply while the row is still
 * `candidate` — a rider self-cancelling ("estoy bien") or the on-device
 * countdown elapsing (self-confirming) are both still valid once, and a
 * stale/duplicate call becomes a harmless no-op, same guarantee the old
 * `accident_events_update_self_while_candidate` RLS policy gave for free
 * (see `accident_alert_response.dart`'s doc comment). */
async function updateStatusWhileCandidate(
  userId: string,
  accidentEventId: string,
  status: 'cancelled' | 'confirmed',
) {
  const column = status === 'confirmed' ? 'confirmed_at' : 'cancelled_at';
  const { rows } = await pool.query(
    `update public.accident_events
        set status = $1, ${column} = now()
      where id = $2 and user_id = $3 and status = 'candidate'
      returning *`,
    [status, accidentEventId, userId],
  );
  return rows[0] ?? null;
}

export async function cancel(userId: string, accidentEventId: string) {
  // No-op (not an error) if already past 'candidate' — matches the old
  // RLS-filtered update silently matching zero rows.
  await updateStatusWhileCandidate(userId, accidentEventId, 'cancelled');
}

export async function confirm(userId: string, accidentEventId: string) {
  const updated = await updateStatusWhileCandidate(userId, accidentEventId, 'confirmed');
  if (updated) {
    // Fire-and-forget from the caller's perspective (the confirm request
    // doesn't wait on every provider's HTTP round trip), but still runs in
    // this process, not via a DB trigger/webhook — see dispatch.ts's header
    // comment for why that's the whole point of this migration.
    dispatchAlertsFor(pool, accidentEventId).catch((error) => {
      console.error(`dispatchAlertsFor(${accidentEventId}) failed:`, error);
    });
  }
}

export async function fetchMine(userId: string) {
  const { rows } = await pool.query(
    `select * from public.accident_events
      where user_id = $1
      order by occurred_at desc`,
    [userId],
  );
  return rows;
}

export async function fetchById(userId: string, accidentEventId: string) {
  const { rows } = await pool.query(
    'select * from public.accident_events where id = $1',
    [accidentEventId],
  );
  const accident = rows[0];
  if (!accident) throw new HttpError(404, 'accident event not found');

  const isOwner = accident.user_id === userId;
  const visibleToSessionMate =
    accident.session_id &&
    ['confirmed', 'notified', 'resolved'].includes(accident.status) &&
    (await isSessionMember(accident.session_id, userId));

  if (!isOwner && !visibleToSessionMate) {
    throw new HttpError(404, 'accident event not found');
  }
  return accident;
}
