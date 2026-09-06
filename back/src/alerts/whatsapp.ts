// Sentinel — cliente mínimo de WhatsApp Cloud API (Meta).
//
// Puerto literal de
// `supabase/functions/dispatch-accident-alerts/whatsapp.ts` — usa solo
// `fetch`, sin nada específico de Deno.

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
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: toE164,
          type: 'template',
          template: {
            name: templateName,
            language: { code: templateLanguage },
            components: [
              {
                type: 'body',
                parameters: params.map((text) => ({ type: 'text', text })),
              },
            ],
          },
        }),
      },
    );
    const json = (await response.json()) as {
      error?: { message?: string };
      messages?: Array<{ id?: string }>;
    };
    if (!response.ok) {
      const reason = json?.error?.message ?? `http_${response.status}`;
      return { ok: false, error: `whatsapp_${reason}` };
    }
    const providerMessageId = json?.messages?.[0]?.id;
    return { ok: true, providerMessageId };
  } catch (error) {
    return { ok: false, error: `whatsapp_exception: ${String(error)}` };
  }
}
