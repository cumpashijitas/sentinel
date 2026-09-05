// Sentinel V2 — Fase 8 (extensión WhatsApp)
//
// Minimal client for Meta's WhatsApp Cloud API. Unlike push/SMS, a
// business-initiated WhatsApp message (this is always one — an accident
// alert, never a reply to something the recipient wrote first) MUST use a
// pre-approved message template; free-form text is rejected by the API for
// this kind of send. See docs/alerts.md for what the template text has to
// say (must match message.ts's buildWhatsAppTemplateParams exactly) and
// how to get it approved in Meta Business Manager.
//
// Needs META_WHATSAPP_ACCESS_TOKEN + META_WHATSAPP_PHONE_NUMBER_ID (from a
// Meta Developer app's WhatsApp product — see supabase/functions/.env.example).
// Not configured in this project's local/dev environment (no Meta
// Developer app exists yet), so this is exercised via providers.ts's Noop
// fallback, not a live send, until that's set up.

export interface WhatsAppSendResult {
  ok: boolean;
  providerMessageId?: string;
  error?: string;
}

export async function sendWhatsAppTemplate(
  accessToken: string,
  phoneNumberId: string,
  templateName: string,
  templateLanguage: string,
  toE164: string,
  params: readonly string[],
): Promise<WhatsAppSendResult> {
  try {
    const response = await fetch(
      `https://graph.facebook.com/v21.0/${phoneNumberId}/messages`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({
          messaging_product: "whatsapp",
          to: toE164,
          type: "template",
          template: {
            name: templateName,
            language: { code: templateLanguage },
            components: [
              {
                type: "body",
                parameters: params.map((text) => ({ type: "text", text })),
              },
            ],
          },
        }),
      },
    );
    const json = await response.json();
    if (!response.ok) {
      const reason = json?.error?.message ?? `http_${response.status}`;
      return { ok: false, error: `whatsapp_${reason}` };
    }
    const providerMessageId = json?.messages?.[0]?.id as string | undefined;
    return { ok: true, providerMessageId };
  } catch (error) {
    return { ok: false, error: `whatsapp_exception: ${String(error)}` };
  }
}
