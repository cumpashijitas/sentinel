// Sentinel — resolución de proveedores de envío (push/SMS/WhatsApp).
//
// Puerto de `supabase/functions/dispatch-accident-alerts/providers.ts` —
// único cambio real: `Deno.env.get('X')` → `process.env.X` (ver cada
// `resolve*Provider`). Sin credenciales configuradas en `.env`, cada canal
// cae a un Noop que igual deja correr el pipeline completo (una fila en
// `alerts` con status='failed' y un motivo claro) en vez de saltarse el
// intento silenciosamente.

import { parseServiceAccount, sendFcmPush } from './fcm.js';
import { sendWhatsAppTemplate } from './whatsapp.js';

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
  constructor(private account: NonNullable<ReturnType<typeof parseServiceAccount>>) {}
  send(deviceToken: string, title: string, body: string): Promise<SendResult> {
    return sendFcmPush(this.account, deviceToken, title, body);
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
      const credentials = Buffer.from(`${this.accountSid}:${this.authToken}`).toString(
        'base64',
      );
      const response = await fetch(
        `https://api.twilio.com/2010-04-01/Accounts/${this.accountSid}/Messages.json`,
        {
          method: 'POST',
          headers: {
            Authorization: `Basic ${credentials}`,
            'content-type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            To: phoneNumber,
            From: this.fromNumber,
            Body: body,
          }),
        },
      );
      const json = (await response.json()) as { message?: string; sid?: string };
      if (!response.ok) {
        return { ok: false, error: `twilio_http_${response.status}: ${json?.message ?? ''}` };
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

export function resolvePushProvider(env: NodeJS.ProcessEnv = process.env): PushProvider {
  const raw = env.FCM_SERVICE_ACCOUNT_JSON;
  if (!raw) return new NoopPushProvider('push_provider_not_configured');
  const account = parseServiceAccount(raw);
  if (!account) return new NoopPushProvider('push_provider_invalid_service_account_json');
  return new FcmPushProvider(account);
}

export function resolveSmsProvider(env: NodeJS.ProcessEnv = process.env): SmsProvider {
  const accountSid = env.TWILIO_ACCOUNT_SID;
  const authToken = env.TWILIO_AUTH_TOKEN;
  const fromNumber = env.TWILIO_FROM_NUMBER;
  if (!accountSid || !authToken || !fromNumber) {
    return new NoopSmsProvider('sms_provider_not_configured');
  }
  return new TwilioSmsProvider(accountSid, authToken, fromNumber);
}

export function resolveWhatsAppProvider(
  env: NodeJS.ProcessEnv = process.env,
): WhatsAppProvider {
  const accessToken = env.META_WHATSAPP_ACCESS_TOKEN;
  const phoneNumberId = env.META_WHATSAPP_PHONE_NUMBER_ID;
  if (!accessToken || !phoneNumberId) {
    return new NoopWhatsAppProvider('whatsapp_provider_not_configured');
  }
  const templateName = env.META_WHATSAPP_TEMPLATE_NAME ?? 'accident_alert';
  const templateLanguage = env.META_WHATSAPP_TEMPLATE_LANG ?? 'es';
  return new MetaWhatsAppProvider(accessToken, phoneNumberId, templateName, templateLanguage);
}
