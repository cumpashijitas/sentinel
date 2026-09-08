// Sentinel back/ — compartir ubicación con contactos de emergencia,
// independiente de un viaje de grupo. Ver
// supabase/migrations/20260907010000_emergency_shares.sql.

import { randomBytes } from 'node:crypto';
import { pool } from '../db/pool.js';
import { HttpError } from '../lib/http.js';

function newShareToken(): string {
  // 24 bytes al azar -> 32 chars base64url, suficiente para que adivinarlo
  // no sea viable — este token ES el control de acceso del link público,
  // no hay nada más protegiéndolo.
  return randomBytes(24).toString('base64url');
}

export async function startShare(userId: string) {
  // Un solo share activo por usuario — cierra cualquier anterior antes de
  // abrir uno nuevo, mismo principio que "una sola sesión de viaje activa
  // por grupo" en ride.service.ts.
  await pool.query(
    `update public.emergency_shares
        set status = 'ended', ended_at = now()
      where user_id = $1 and status = 'active'`,
    [userId],
  );

  const { rows } = await pool.query(
    `insert into public.emergency_shares (user_id, share_token, status, started_at)
     values ($1, $2, 'active', now())
     returning *`,
    [userId, newShareToken()],
  );
  return rows[0];
}

export async function stopShare(userId: string) {
  await pool.query(
    `update public.emergency_shares
        set status = 'ended', ended_at = now()
      where user_id = $1 and status = 'active'`,
    [userId],
  );
}

export async function fetchActiveShare(userId: string) {
  const { rows } = await pool.query(
    `select * from public.emergency_shares
      where user_id = $1 and status = 'active'`,
    [userId],
  );
  return rows[0] ?? null;
}

async function loadOwnedActiveShare(userId: string, shareId: string) {
  const { rows } = await pool.query(
    `select * from public.emergency_shares
      where id = $1 and user_id = $2 and status = 'active'`,
    [shareId, userId],
  );
  const share = rows[0];
  if (!share) throw new HttpError(404, 'active share not found');
  return share;
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

/** Devuelve la fila insertada/actualizada (para el broadcast por
 * WebSocket) junto con el `share_token`, que es la clave con la que se
 * relevan las conexiones — ver ws/emergency-share-hub.ts. */
export async function upsertShareLocation(
  userId: string,
  shareId: string,
  fix: LocationFixInput,
) {
  const share = await loadOwnedActiveShare(userId, shareId);
  const { rows } = await pool.query(
    `insert into public.emergency_share_locations
       (share_id, latitude, longitude, accuracy, speed, heading, battery_level, recorded_at)
     values ($1, $2, $3, $4, $5, $6, $7, $8)
     on conflict (share_id) do update
       set latitude = excluded.latitude,
           longitude = excluded.longitude,
           accuracy = excluded.accuracy,
           speed = excluded.speed,
           heading = excluded.heading,
           battery_level = excluded.battery_level,
           recorded_at = excluded.recorded_at
     returning *`,
    [
      shareId,
      fix.latitude,
      fix.longitude,
      fix.accuracy ?? null,
      fix.speed ?? null,
      fix.heading ?? null,
      fix.batteryLevel ?? null,
      fix.recordedAt,
    ],
  );
  return { row: rows[0], shareToken: share.share_token as string };
}

/** Camino "adentro de la app": todo rider que me tiene como contacto de
 * emergencia con cuenta propia (`emergency_contacts.contact_user_id`) y
 * que tiene un share activo ahora mismo. */
/// Trae también `share_token`: el front reusa la misma pantalla pública
/// (`/share/<token>`) para este camino en vez de duplicarla — ver
/// `emergency_share_page.dart`. No es un hueco de seguridad distinto al
/// que ya existe: quien ve esta lista ya demostró ser un contacto de
/// emergencia vinculado, así que conocer el token no le da más acceso del
/// que ya tenía.
export async function fetchSharesForContact(contactUserId: string) {
  const { rows } = await pool.query(
    `select es.*, p.display_name as rider_display_name
       from public.emergency_shares es
       join public.emergency_contacts ec
         on ec.owner_id = es.user_id and ec.contact_user_id = $1
       join public.profiles p on p.id = es.user_id
      where es.status = 'active'
      order by es.started_at desc`,
    [contactUserId],
  );
  return rows;
}

/** Camino "link público": sin auth, valida solo por conocer el token. */
export async function fetchByToken(token: string) {
  const { rows } = await pool.query(
    `select es.*, p.display_name as rider_display_name,
            l.latitude, l.longitude, l.accuracy, l.speed, l.heading, l.recorded_at
       from public.emergency_shares es
       join public.profiles p on p.id = es.user_id
       left join public.emergency_share_locations l on l.share_id = es.id
      where es.share_token = $1`,
    [token],
  );
  const share = rows[0];
  if (!share) throw new HttpError(404, 'share not found');
  return share;
}

export async function shareIdForToken(token: string): Promise<string | null> {
  const { rows } = await pool.query(
    `select id from public.emergency_shares where share_token = $1 and status = 'active'`,
    [token],
  );
  return rows[0]?.id ?? null;
}
