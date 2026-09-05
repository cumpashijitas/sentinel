// Sentinel V2 — Fase 8
//
// Pure formatting: turns an accident_events row + the affected rider's
// display name into the title/body sent through whichever channel. No I/O
// here on purpose — keeps this trivially unit-testable (see
// message_test.ts) independent of Supabase/network mocking.

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
  return date.toLocaleTimeString("es-BO", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  });
}

function mapLinkOrNull(source: AccidentAlertSource): string | null {
  const hasLocation = source.latitude != null && source.longitude != null;
  return hasLocation ? `https://maps.google.com/?q=${source.latitude},${source.longitude}` : null;
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

/** Ordered parameters for the WhatsApp "accident_alert" template's {{1}}
 * {{2}} {{3}} placeholders — WhatsApp business-initiated messages can't
 * send arbitrary free text (see docs/alerts.md), only fill in a
 * pre-approved template. The template's body text, submitted to Meta for
 * approval, must read exactly:
 *
 *   "Posible accidente: {{1}} pudo haber tenido un accidente a las {{2}}
 *   y no respondió a tiempo. Ubicación: {{3}}"
 *
 * — i.e. the same wording as buildAlertMessage's body, split into params. */
export function buildWhatsAppTemplateParams(source: AccidentAlertSource): [string, string, string] {
  const time = formatTime(source.occurredAt);
  const mapLink = mapLinkOrNull(source);
  return [source.riderName, time, mapLink ?? "Sin ubicación disponible"];
}
