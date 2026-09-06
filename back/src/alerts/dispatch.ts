// Sentinel — despacho de alertas de accidente.
//
// Puerto de `supabase/functions/dispatch-accident-alerts/index.ts`
// (`dispatchAlertsFor`), con dos cambios de fondo respecto al original:
//
// 1. Ya no corre como Edge Function invocada por un trigger de Postgres vía
//    `pg_net` + un secreto en Vault — `accidents.routes.ts` la llama
//    directo, en el mismo request que confirma el accidente (el backend ya
//    sabe que acaba de pasar `candidate -> confirmed`, no necesita que la
//    base de datos se lo avise por HTTP).
// 2. Consulta Postgres directo con `pg` (`pool.query`) en vez de
//    `@supabase/supabase-js`'s `.from(...)` contra PostgREST — coherente
//    con el resto de este backend (ver docs/architecture.md).
//
// La lógica de negocio en sí (a quién avisar, por qué canal, con qué
// mensaje, cuándo no reenviar) es exactamente la misma — ver
// `docs/alerts.md` para el diseño completo.

import type { Pool, PoolClient } from 'pg';
import { buildAlertMessage, buildWhatsAppTemplateParams } from './message.js';
import {
  resolvePushProvider,
  resolveSmsProvider,
  resolveWhatsAppProvider,
} from './providers.js';

interface AccidentEventRow {
  id: string;
  session_id: string | null;
  user_id: string;
  latitude: number | null;
  longitude: number | null;
  status: string;
  occurred_at: string;
}

interface PlannedAlert {
  recipient_type: 'group_member' | 'emergency_contact';
  recipient_user_id: string | null;
  recipient_phone: string | null;
  channel: 'push' | 'sms' | 'whatsapp';
  device_token?: string;
}

export interface DispatchResult {
  ok: boolean;
  accidentEventId: string;
  reason?: string;
  recipients?: number;
  sent?: number;
  failed?: number;
}

/** Every active session member other than the rider themself. Push is the
 * primary channel (one attempt per enabled device token); if a member has
 * none, SMS to their profile's phone is the fallback. WhatsApp is
 * independent of both — attempted in addition whenever the member opted in
 * and has a phone on file. See docs/alerts.md. */
async function planGroupMemberAlerts(
  db: Pool | PoolClient,
  accident: AccidentEventRow,
): Promise<PlannedAlert[]> {
  if (!accident.session_id) return [];

  const { rows: members } = await db.query(
    `select user_id from public.ride_session_members
      where session_id = $1 and status = 'active' and user_id <> $2`,
    [accident.session_id, accident.user_id],
  );
  if (members.length === 0) return [];
  const memberIds: string[] = members.map((m) => m.user_id);

  const [{ rows: tokens }, { rows: profiles }] = await Promise.all([
    db.query(
      'select user_id, token from public.device_push_tokens where user_id = any($1) and enabled = true',
      [memberIds],
    ),
    db.query(
      'select id, phone, whatsapp_alerts_opt_in from public.profiles where id = any($1)',
      [memberIds],
    ),
  ]);

  const tokensByUser = new Map<string, string[]>();
  for (const row of tokens) {
    const list = tokensByUser.get(row.user_id) ?? [];
    list.push(row.token);
    tokensByUser.set(row.user_id, list);
  }
  const profileById = new Map<
    string,
    { phone: string | null; whatsapp_alerts_opt_in: boolean }
  >();
  for (const row of profiles) profileById.set(row.id, row);

  const planned: PlannedAlert[] = [];
  for (const userId of memberIds) {
    const userTokens = tokensByUser.get(userId);
    const profile = profileById.get(userId);

    if (userTokens && userTokens.length > 0) {
      for (const token of userTokens) {
        planned.push({
          recipient_type: 'group_member',
          recipient_user_id: userId,
          recipient_phone: null,
          channel: 'push',
          device_token: token,
        });
      }
    } else if (profile?.phone) {
      planned.push({
        recipient_type: 'group_member',
        recipient_user_id: userId,
        recipient_phone: profile.phone,
        channel: 'sms',
      });
    }

    if (profile?.whatsapp_alerts_opt_in && profile.phone) {
      planned.push({
        recipient_type: 'group_member',
        recipient_user_id: userId,
        recipient_phone: profile.phone,
        channel: 'whatsapp',
      });
    }
  }
  return planned;
}

/** The rider's own emergency_contacts, honoring each contact's individual
 * notify_push/notify_sms/notify_whatsapp preference exactly. */
async function planEmergencyContactAlerts(
  db: Pool | PoolClient,
  accident: AccidentEventRow,
): Promise<PlannedAlert[]> {
  const { rows: contacts } = await db.query(
    `select contact_user_id, phone, notify_push, notify_sms, notify_whatsapp
       from public.emergency_contacts
      where owner_id = $1`,
    [accident.user_id],
  );
  if (contacts.length === 0) return [];

  const linkedIds: string[] = contacts
    .filter((c) => c.notify_push && c.contact_user_id)
    .map((c) => c.contact_user_id);

  const tokensByUser = new Map<string, string[]>();
  if (linkedIds.length > 0) {
    const { rows: tokens } = await db.query(
      'select user_id, token from public.device_push_tokens where user_id = any($1) and enabled = true',
      [linkedIds],
    );
    for (const row of tokens) {
      const list = tokensByUser.get(row.user_id) ?? [];
      list.push(row.token);
      tokensByUser.set(row.user_id, list);
    }
  }

  const planned: PlannedAlert[] = [];
  for (const contact of contacts) {
    if (contact.notify_push && contact.contact_user_id) {
      const userTokens = tokensByUser.get(contact.contact_user_id) ?? [];
      for (const token of userTokens) {
        planned.push({
          recipient_type: 'emergency_contact',
          recipient_user_id: contact.contact_user_id,
          recipient_phone: null,
          channel: 'push',
          device_token: token,
        });
      }
    }
    if (contact.notify_sms) {
      planned.push({
        recipient_type: 'emergency_contact',
        recipient_user_id: contact.contact_user_id,
        recipient_phone: contact.phone,
        channel: 'sms',
      });
    }
    if (contact.notify_whatsapp && contact.phone) {
      planned.push({
        recipient_type: 'emergency_contact',
        recipient_user_id: contact.contact_user_id,
        recipient_phone: contact.phone,
        channel: 'whatsapp',
      });
    }
  }
  return planned;
}

export async function dispatchAlertsFor(
  db: Pool,
  accidentEventId: string,
): Promise<DispatchResult> {
  const { rows: accidentRows } = await db.query(
    `select id, session_id, user_id, latitude, longitude, status, occurred_at
       from public.accident_events where id = $1`,
    [accidentEventId],
  );
  const accident: AccidentEventRow | undefined = accidentRows[0];
  if (!accident) {
    return { ok: false, accidentEventId, reason: 'accident_event_not_found' };
  }
  // Idempotency guard #1: only ever act on a row that's actually
  // 'confirmed'.
  if (accident.status !== 'confirmed') {
    return { ok: false, accidentEventId, reason: `status_is_${accident.status}` };
  }

  // Idempotency guard #2: a prior dispatch already wrote alerts rows for
  // this accident — don't double-send.
  const { rows: existingRows } = await db.query(
    'select count(*)::int as count from public.alerts where accident_id = $1',
    [accidentEventId],
  );
  if ((existingRows[0]?.count ?? 0) > 0) {
    return {
      ok: true,
      accidentEventId,
      reason: 'already_dispatched',
      recipients: 0,
      sent: 0,
      failed: 0,
    };
  }

  const { rows: profileRows } = await db.query(
    'select display_name from public.profiles where id = $1',
    [accident.user_id],
  );
  const riderName = profileRows[0]?.display_name ?? 'Un compañero';

  const [groupAlerts, contactAlerts] = await Promise.all([
    planGroupMemberAlerts(db, accident),
    planEmergencyContactAlerts(db, accident),
  ]);
  const planned = [...groupAlerts, ...contactAlerts];

  const alertSource = {
    riderName,
    occurredAt: accident.occurred_at,
    latitude: accident.latitude,
    longitude: accident.longitude,
  };
  const message = buildAlertMessage(alertSource);
  const whatsappParams = buildWhatsAppTemplateParams(alertSource);

  const pushProvider = resolvePushProvider();
  const smsProvider = resolveSmsProvider();
  const whatsappProvider = resolveWhatsAppProvider();

  let sent = 0;
  let failed = 0;
  for (const alert of planned) {
    const result =
      alert.channel === 'push'
        ? await pushProvider.send(alert.device_token!, message.title, message.body)
        : alert.channel === 'sms'
          ? await smsProvider.send(alert.recipient_phone!, message.body)
          : await whatsappProvider.send(alert.recipient_phone!, whatsappParams);

    if (result.ok) sent++;
    else failed++;

    try {
      await db.query(
        `insert into public.alerts
           (accident_id, recipient_type, recipient_user_id, recipient_phone,
            channel, status, provider_message_id, sent_at)
         values ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          accidentEventId,
          alert.recipient_type,
          alert.recipient_user_id,
          alert.recipient_phone,
          alert.channel,
          result.ok ? 'sent' : 'failed',
          result.providerMessageId ?? null,
          result.ok ? new Date().toISOString() : null,
        ],
      );
    } catch (error) {
      console.error(`dispatch-accident-alerts: failed to record alert row: ${error}`);
    }
  }

  // 'notified' means "the dispatch attempt ran", not "every recipient
  // confirmed receipt" — individual outcomes live on each `alerts` row.
  await db.query(
    `update public.accident_events set status = 'notified'
      where id = $1 and status = 'confirmed'`,
    [accidentEventId],
  );

  return { ok: true, accidentEventId, recipients: planned.length, sent, failed };
}
