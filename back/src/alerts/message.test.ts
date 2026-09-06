// Puerto de
// `supabase/functions/dispatch-accident-alerts/message_test.ts` a Vitest —
// misma lógica pura, sin red, ahora corriendo con `npm --prefix back test`
// en vez de necesitar el runtime de Deno del contenedor de Supabase.

import { describe, expect, it } from 'vitest';
import { buildAlertMessage, buildWhatsAppTemplateParams } from './message.js';

describe('buildAlertMessage', () => {
  it('includes a Google Maps link when lat/lon are present', () => {
    const message = buildAlertMessage({
      riderName: 'Bruno Rider',
      occurredAt: '2026-08-28T14:07:00.000Z',
      latitude: -17.3942,
      longitude: -66.1574,
    });
    expect(message.title).toContain('Bruno Rider');
    expect(message.body).toContain('https://maps.google.com/?q=-17.3942,-66.1574');
  });

  it("falls back to 'sin ubicación' text when lat/lon are null", () => {
    const message = buildAlertMessage({
      riderName: 'Carla Rider',
      occurredAt: '2026-08-28T14:07:00.000Z',
      latitude: null,
      longitude: null,
    });
    expect(message.body).toContain('Sin ubicación disponible');
    expect(message.body.includes('maps.google.com')).toBe(false);
  });

  it('names the affected rider in the title regardless of location', () => {
    const message = buildAlertMessage({
      riderName: 'Ana Rider',
      occurredAt: '2026-08-28T14:07:00.000Z',
      latitude: null,
      longitude: null,
    });
    expect(message.title).toBe('Posible accidente: Ana Rider');
  });
});

describe('buildWhatsAppTemplateParams', () => {
  it('returns 3 ordered values, map link as the 3rd when present', () => {
    const params = buildWhatsAppTemplateParams({
      riderName: 'Bruno Rider',
      occurredAt: '2026-08-28T14:07:00.000Z',
      latitude: -17.3942,
      longitude: -66.1574,
    });
    expect(params.length).toBe(3);
    expect(params[0]).toBe('Bruno Rider');
    expect(params[2]).toBe('https://maps.google.com/?q=-17.3942,-66.1574');
  });

  it("3rd value is the fallback text when there's no location", () => {
    const params = buildWhatsAppTemplateParams({
      riderName: 'Carla Rider',
      occurredAt: '2026-08-28T14:07:00.000Z',
      latitude: null,
      longitude: null,
    });
    expect(params[2]).toBe('Sin ubicación disponible');
  });
});
