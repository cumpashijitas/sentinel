// Sentinel — formato del mensaje de alerta de accidente.
//
// Puerto literal de `supabase/functions/dispatch-accident-alerts/message.ts`
// (Fase 8 original) — pura formatting, sin I/O, sin nada específico de
// Deno, así que no necesitó ningún cambio más allá de vivir en Node.

export interface AccidentAlertSource {
  riderName: string;
  occurredAt: string;
  latitude: number | null;
  longitude: number | null;
}

export interface AlertMessage {
  title: string;
  body: string;
}

/** `es-BO` HH:mm, e.g. "14:07" — full date is implicit ("ahora mismo"). */
function formatTime(isoTimestamp: string): string {
  const date = new Date(isoTimestamp);
  return date.toLocaleTimeString('es-BO', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });
}

function mapLinkOrNull(source: AccidentAlertSource): string | null {
  const hasLocation = source.latitude != null && source.longitude != null;
  return hasLocation
    ? `https://maps.google.com/?q=${source.latitude},${source.longitude}`
    : null;
}

export function buildAlertMessage(source: AccidentAlertSource): AlertMessage {
  const time = formatTime(source.occurredAt);
  const mapLink = mapLinkOrNull(source);

  return {
    title: `Posible accidente: ${source.riderName}`,
    body: mapLink
      ? `${source.riderName} pudo haber tenido un accidente a las ${time} y no respondió a tiempo. Ubicación: ${mapLink}`
      : `${source.riderName} pudo haber tenido un accidente a las ${time} y no respondió a tiempo. Sin ubicación disponible.`,
  };
}

export interface WhatsAppTemplateParam {
  name: string;
  value: string;
}

/** Named parameters for the WhatsApp "accident_alert" template's
 * `{{rider_name}}`/`{{time}}`/`{{location}}` placeholders — see
 * docs/alerts.md for the exact approved template text (must match
 * buildAlertMessage's body). Meta stopped accepting purely-numbered
 * `{{1}}`/`{{2}}`/`{{3}}` variables in newly created templates (found live
 * creating this project's template) — sending a template message now also
 * requires each parameter's `parameter_name` to match, not just position;
 * see whatsapp.ts. */
export function buildWhatsAppTemplateParams(
  source: AccidentAlertSource,
): WhatsAppTemplateParam[] {
  const time = formatTime(source.occurredAt);
  const mapLink = mapLinkOrNull(source);
  return [
    { name: 'rider_name', value: source.riderName },
    { name: 'time', value: time },
    { name: 'location', value: mapLink ?? 'Sin ubicación disponible' },
  ];
}
