// Sentinel — cliente mínimo de WhatsApp Cloud API (Meta).
//
// Basado en `supabase/functions/dispatch-accident-alerts/whatsapp.ts`, con
// un cambio real encontrado en vivo creando la plantilla de este proyecto:
// Meta ya no acepta variables numéricas (`{{1}}`/`{{2}}`/`{{3}}`) en
// plantillas nuevas — ahora exige nombres (`{{rider_name}}`, etc.), y el
// envío tiene que mandar `parameter_name` en cada parámetro para que
// coincida con el nombre de la plantilla, no alcanza con el orden.

import type { WhatsAppTemplateParam } from './message.js';

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
  params: readonly WhatsAppTemplateParam[],
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
                parameters: params.map((param) => ({
                  type: 'text',
                  parameter_name: param.name,
                  text: param.value,
                })),
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
