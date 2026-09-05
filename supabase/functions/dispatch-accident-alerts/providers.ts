// Sentinel V2 — Fase 8
//
// Pluggable send providers, resolved once per invocation from environment
// secrets (Supabase Secrets locally via supabase/functions/.env, or
// `supabase secrets set` for a deployed project — see .env.example).
// Neither real provider has credentials configured in this project's
// local/dev environment yet (no Firebase or Twilio account exists — see
// docs/alerts.md's "qué no está verificado" section): resolvePushProvider
// / resolveSmsProvider fall back to a Noop implementation that still runs
// the full pipeline (an `alerts` row is genuinely written with
// status='failed' and a clear reason) rather than skipping the attempt —
// this is the same "degrade, don't skip silently" shape as
// MotionTracker.isAvailable() in Fase 7.

import { parseServiceAccount, sendFcmPush } from "./fcm.ts";
import { sendWhatsAppTemplate } from "./whatsapp.ts";

export interface SendResult {
  ok: boolean;
  providerMessageId?: string;
  error?: string;
}

export interface PushProvider {
  send(deviceToken: string, title: string, body: string): Promise<SendResult>;
}

export interface SmsProvider {
  send(phoneNumber: string, body: string): Promise<SendResult>;
}

export interface WhatsAppProvider {
  /** `templateParams` must match message.ts's buildWhatsAppTemplateParams
   * order exactly — see whatsapp.ts's header comment. */
  send(phoneNumber: string, templateParams: readonly string[]): Promise<SendResult>;
}

class NoopPushProvider implements PushProvider {
  constructor(private reason: string) {}
  send(): Promise<SendResult> {
    return Promise.resolve({ ok: false, error: this.reason });
  }
}

class NoopSmsProvider implements SmsProvider {
  constructor(private reason: string) {}
  send(): Promise<SendResult> {
    return Promise.resolve({ ok: false, error: this.reason });
  }
}

class NoopWhatsAppProvider implements WhatsAppProvider {
  constructor(private reason: string) {}
  send(): Promise<SendResult> {
    return Promise.resolve({ ok: false, error: this.reason });
  }
}

class FcmPushProvider implements PushProvider {
  constructor(private account: ReturnType<typeof parseServiceAccount> & object) {}
  send(deviceToken: string, title: string, body: string): Promise<SendResult> {
    // deno-lint-ignore no-explicit-any
    return sendFcmPush(this.account as any, deviceToken, title, body);
  }
}

class TwilioSmsProvider implements SmsProvider {
  constructor(
    private accountSid: string,
    private authToken: string,
    private fromNumber: string,
  ) {}

  async send(phoneNumber: string, body: string): Promise<SendResult> {
    try {
      const credentials = btoa(`${this.accountSid}:${this.authToken}`);
      const response = await fetch(
        `https://api.twilio.com/2010-04-01/Accounts/${this.accountSid}/Messages.json`,
        {
          method: "POST",
          headers: {
            Authorization: `Basic ${credentials}`,
            "content-type": "application/x-www-form-urlencoded",
          },
          body: new URLSearchParams({
            To: phoneNumber,
            From: this.fromNumber,
            Body: body,
          }),
        },
      );
      const json = await response.json();
      if (!response.ok) {
        return { ok: false, error: `twilio_http_${response.status}: ${json?.message ?? ""}` };
      }
      return { ok: true, providerMessageId: json.sid };
    } catch (error) {
      return { ok: false, error: `twilio_exception: ${String(error)}` };
    }
  }
}

class MetaWhatsAppProvider implements WhatsAppProvider {
  constructor(
    private accessToken: string,
    private phoneNumberId: string,
    private templateName: string,
    private templateLanguage: string,
  ) {}

  send(phoneNumber: string, templateParams: readonly string[]): Promise<SendResult> {
    return sendWhatsAppTemplate(
      this.accessToken,
      this.phoneNumberId,
      this.templateName,
      this.templateLanguage,
      phoneNumber,
      templateParams,
    );
  }
}

export function resolvePushProvider(env: Deno.Env = Deno.env): PushProvider {
  const raw = env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!raw) return new NoopPushProvider("push_provider_not_configured");
  const account = parseServiceAccount(raw);
  if (!account) return new NoopPushProvider("push_provider_invalid_service_account_json");
  return new FcmPushProvider(account);
}

export function resolveSmsProvider(env: Deno.Env = Deno.env): SmsProvider {
  const accountSid = env.get("TWILIO_ACCOUNT_SID");
  const authToken = env.get("TWILIO_AUTH_TOKEN");
  const fromNumber = env.get("TWILIO_FROM_NUMBER");
  if (!accountSid || !authToken || !fromNumber) {
    return new NoopSmsProvider("sms_provider_not_configured");
  }
  return new TwilioSmsProvider(accountSid, authToken, fromNumber);
}

export function resolveWhatsAppProvider(env: Deno.Env = Deno.env): WhatsAppProvider {
  const accessToken = env.get("META_WHATSAPP_ACCESS_TOKEN");
  const phoneNumberId = env.get("META_WHATSAPP_PHONE_NUMBER_ID");
  if (!accessToken || !phoneNumberId) {
    return new NoopWhatsAppProvider("whatsapp_provider_not_configured");
  }
  const templateName = env.get("META_WHATSAPP_TEMPLATE_NAME") ?? "accident_alert";
  const templateLanguage = env.get("META_WHATSAPP_TEMPLATE_LANG") ?? "es";
  return new MetaWhatsAppProvider(accessToken, phoneNumberId, templateName, templateLanguage);
}
