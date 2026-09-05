// Sentinel V2 — Fase 8: dispatch-accident-alerts Edge Function
//
// Invoked exclusively by the `accident_events_confirmed_dispatch_alerts`
// database trigger (20260828000001_accident_alert_dispatch.sql) the moment
// an accident_events row moves candidate -> confirmed. Never called by the
// Flutter client directly — `alerts` has zero client RLS policies for the
// same reason this function exists: dispatching/recording alerts is a
// privileged, backend-only operation that needs to read across users
// (another rider's session-mates, another rider's emergency contacts),
// which no authenticated user's own RLS grants allow. Full design,
// verification notes, and deuda técnica: docs/alerts.md.
//
// Auth model: this function sets `verify_jwt = false` (see
// supabase/config.toml) because its one and only legitimate caller is a
// Postgres trigger, not a signed-in user — there is no user JWT to verify
// in the first place. In its place, every request must carry a shared
// secret header matching Vault's `accident_alert_webhook_secret`, checked
// before anything else runs.

import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { buildAlertMessage, buildWhatsAppTemplateParams } from "./message.ts";
import { resolvePushProvider, resolveSmsProvider, resolveWhatsAppProvider } from "./providers.ts";

const WEBHOOK_SECRET = Deno.env.get("ACCIDENT_ALERT_WEBHOOK_SECRET");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

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
  recipient_type: "group_member" | "emergency_contact";
  recipient_user_id: string | null;
  recipient_phone: string | null;
  channel: "push" | "sms" | "whatsapp";
  /** Present only for channel='push' — the actual device token to send to. */
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
 * (`profiles.whatsapp_alerts_opt_in`, required by Meta — see
 * docs/alerts.md) and has a phone on file, regardless of whether push
 * already reached them; redundancy is desirable for an accident alert. A
 * member with no push token, no WhatsApp opt-in, and no phone on file is
 * genuinely unreachable — nothing to write an `alerts` row for. */
async function planGroupMemberAlerts(
  client: SupabaseClient,
  accident: AccidentEventRow,
): Promise<PlannedAlert[]> {
  if (!accident.session_id) return [];

  const { data: members, error: membersError } = await client
    .from("ride_session_members")
    .select("user_id")
    .eq("session_id", accident.session_id)
    .eq("status", "active")
    .neq("user_id", accident.user_id);
  if (membersError || !members || members.length === 0) return [];

  const memberIds = members.map((m) => m.user_id as string);

  const [{ data: tokens }, { data: profiles }] = await Promise.all([
    client
      .from("device_push_tokens")
      .select("user_id, token")
      .in("user_id", memberIds)
      .eq("enabled", true),
    client
      .from("profiles")
      .select("id, phone, whatsapp_alerts_opt_in")
      .in("id", memberIds),
  ]);

  const tokensByUser = new Map<string, string[]>();
  for (const row of tokens ?? []) {
    const list = tokensByUser.get(row.user_id) ?? [];
    list.push(row.token);
    tokensByUser.set(row.user_id, list);
  }
  const profileById = new Map<string, { phone: string | null; whatsapp_alerts_opt_in: boolean }>();
  for (const row of profiles ?? []) {
    profileById.set(row.id, { phone: row.phone, whatsapp_alerts_opt_in: row.whatsapp_alerts_opt_in });
  }

  const planned: PlannedAlert[] = [];
  for (const userId of memberIds) {
    const userTokens = tokensByUser.get(userId);
    const profile = profileById.get(userId);

    if (userTokens && userTokens.length > 0) {
      for (const token of userTokens) {
        planned.push({
          recipient_type: "group_member",
          recipient_user_id: userId,
          recipient_phone: null,
          channel: "push",
          device_token: token,
        });
      }
    } else if (profile?.phone) {
      planned.push({
        recipient_type: "group_member",
        recipient_user_id: userId,
        recipient_phone: profile.phone,
        channel: "sms",
      });
    }

    if (profile?.whatsapp_alerts_opt_in && profile.phone) {
      planned.push({
        recipient_type: "group_member",
        recipient_user_id: userId,
        recipient_phone: profile.phone,
        channel: "whatsapp",
      });
    }
  }
  return planned;
}

/** The rider's own emergency_contacts, honoring each contact's individual
 * notify_push/notify_sms/notify_whatsapp preference exactly (never
 * inferred — notify_whatsapp is the contact's explicit consent to receive
 * WhatsApp messages from Sentinel's business number, a separate legal
 * requirement from notify_push/notify_sms; see docs/alerts.md). */
async function planEmergencyContactAlerts(
  client: SupabaseClient,
  accident: AccidentEventRow,
): Promise<PlannedAlert[]> {
  const { data: contacts } = await client
    .from("emergency_contacts")
    .select("contact_user_id, phone, notify_push, notify_sms, notify_whatsapp")
    .eq("owner_id", accident.user_id);
  if (!contacts || contacts.length === 0) return [];

  const linkedIds = contacts
    .filter((c) => c.notify_push && c.contact_user_id)
    .map((c) => c.contact_user_id as string);

  const tokensByUser = new Map<string, string[]>();
  if (linkedIds.length > 0) {
    const { data: tokens } = await client
      .from("device_push_tokens")
      .select("user_id, token")
      .in("user_id", linkedIds)
      .eq("enabled", true);
    for (const row of tokens ?? []) {
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
          recipient_type: "emergency_contact",
          recipient_user_id: contact.contact_user_id,
          recipient_phone: null,
          channel: "push",
          device_token: token,
        });
      }
    }
    if (contact.notify_sms) {
      planned.push({
        recipient_type: "emergency_contact",
        recipient_user_id: contact.contact_user_id,
        recipient_phone: contact.phone,
        channel: "sms",
      });
    }
    if (contact.notify_whatsapp && contact.phone) {
      planned.push({
        recipient_type: "emergency_contact",
        recipient_user_id: contact.contact_user_id,
        recipient_phone: contact.phone,
        channel: "whatsapp",
      });
    }
  }
  return planned;
}

export async function dispatchAlertsFor(
  client: SupabaseClient,
  accidentEventId: string,
): Promise<DispatchResult> {
  const { data: accident, error: fetchError } = await client
    .from("accident_events")
    .select("id, session_id, user_id, latitude, longitude, status, occurred_at")
    .eq("id", accidentEventId)
    .maybeSingle();

  if (fetchError || !accident) {
    return { ok: false, accidentEventId, reason: "accident_event_not_found" };
  }
  // Idempotency guard #1: only ever act on a row that's actually
  // 'confirmed'. Covers both "not confirmed yet" and "already moved past
  // 'notified'" (a duplicate trigger fire lands here and no-ops).
  if (accident.status !== "confirmed") {
    return { ok: false, accidentEventId, reason: `status_is_${accident.status}` };
  }

  // Idempotency guard #2: a prior dispatch already wrote alerts rows for
  // this accident — don't double-send. Best-effort (no advisory lock), but
  // this function only ever runs once per confirmation in practice; see
  // docs/alerts.md deuda técnica.
  const { count: existingCount } = await client
    .from("alerts")
    .select("id", { count: "exact", head: true })
    .eq("accident_id", accidentEventId);
  if ((existingCount ?? 0) > 0) {
    return { ok: true, accidentEventId, reason: "already_dispatched", recipients: 0, sent: 0, failed: 0 };
  }

  const { data: profile } = await client
    .from("profiles")
    .select("display_name")
    .eq("id", accident.user_id)
    .maybeSingle();
  const riderName = profile?.display_name ?? "Un compañero";

  const [groupAlerts, contactAlerts] = await Promise.all([
    planGroupMemberAlerts(client, accident),
    planEmergencyContactAlerts(client, accident),
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
    const result = alert.channel === "push"
      ? await pushProvider.send(alert.device_token!, message.title, message.body)
      : alert.channel === "sms"
      ? await smsProvider.send(alert.recipient_phone!, message.body)
      : await whatsappProvider.send(alert.recipient_phone!, whatsappParams);

    if (result.ok) sent++; else failed++;

    const { error: insertError } = await client.from("alerts").insert({
      accident_id: accidentEventId,
      recipient_type: alert.recipient_type,
      recipient_user_id: alert.recipient_user_id,
      recipient_phone: alert.recipient_phone,
      channel: alert.channel,
      status: result.ok ? "sent" : "failed",
      provider_message_id: result.providerMessageId ?? null,
      sent_at: result.ok ? new Date().toISOString() : null,
    });
    if (insertError) {
      console.error(`dispatch-accident-alerts: failed to record alert row: ${insertError.message}`);
    }
  }

  // 'notified' means "the dispatch attempt ran", not "every recipient
  // confirmed receipt" — individual outcomes live on each `alerts` row.
  // See docs/alerts.md deuda técnica for why this doesn't retry failures.
  const { error: updateError } = await client
    .from("accident_events")
    .update({ status: "notified" })
    .eq("id", accidentEventId)
    .eq("status", "confirmed");
  if (updateError) {
    console.error(`dispatch-accident-alerts: failed to mark accident_event notified: ${updateError.message}`);
  }

  return { ok: true, accidentEventId, recipients: planned.length, sent, failed };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("method not allowed", { status: 405 });
  }
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("unauthorized", { status: 401 });
  }

  let body: { accident_event_id?: string };
  try {
    body = await req.json();
  } catch {
    return new Response("invalid JSON body", { status: 400 });
  }
  if (!body.accident_event_id) {
    return new Response("accident_event_id is required", { status: 400 });
  }

  const client = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });

  const result = await dispatchAlertsFor(client, body.accident_event_id);
  return new Response(JSON.stringify(result), {
    status: result.ok ? 200 : 422,
    headers: { "content-type": "application/json" },
  });
});
