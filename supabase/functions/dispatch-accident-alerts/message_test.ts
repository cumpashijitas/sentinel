// Sentinel V2 — Fase 8
// Run inside the edge runtime container (it bundles Deno; the host dev
// machine doesn't): see docs/alerts.md "cómo correr los tests" for the
// exact `docker exec` command used to verify this file.
//
// No deno.land/std import here on purpose — the edge runtime container has
// no reason to reach the open internet to run a unit test, so this file
// stays self-contained with two tiny local assertions instead.

import { buildAlertMessage, buildWhatsAppTemplateParams } from "./message.ts";

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`assertEquals failed:\n  actual:   ${JSON.stringify(actual)}\n  expected: ${JSON.stringify(expected)}`);
  }
}

function assertStringIncludes(actual: string, expected: string) {
  if (!actual.includes(expected)) {
    throw new Error(`assertStringIncludes failed: ${JSON.stringify(actual)} does not include ${JSON.stringify(expected)}`);
  }
}

Deno.test("includes a Google Maps link when lat/lon are present", () => {
  const message = buildAlertMessage({
    riderName: "Bruno Rider",
    occurredAt: "2026-08-28T14:07:00.000Z",
    latitude: -17.3942,
    longitude: -66.1574,
  });
  assertStringIncludes(message.title, "Bruno Rider");
  assertStringIncludes(message.body, "https://maps.google.com/?q=-17.3942,-66.1574");
});

Deno.test("falls back to 'sin ubicación' text when lat/lon are null", () => {
  const message = buildAlertMessage({
    riderName: "Carla Rider",
    occurredAt: "2026-08-28T14:07:00.000Z",
    latitude: null,
    longitude: null,
  });
  assertStringIncludes(message.body, "Sin ubicación disponible");
  assertEquals(message.body.includes("maps.google.com"), false);
});

Deno.test("names the affected rider in the title regardless of location", () => {
  const message = buildAlertMessage({
    riderName: "Ana Rider",
    occurredAt: "2026-08-28T14:07:00.000Z",
    latitude: null,
    longitude: null,
  });
  assertEquals(message.title, "Posible accidente: Ana Rider");
});

Deno.test("WhatsApp template params: 3 ordered values, map link as the 3rd when present", () => {
  const params = buildWhatsAppTemplateParams({
    riderName: "Bruno Rider",
    occurredAt: "2026-08-28T14:07:00.000Z",
    latitude: -17.3942,
    longitude: -66.1574,
  });
  assertEquals(params.length, 3);
  assertEquals(params[0], "Bruno Rider");
  assertEquals(params[2], "https://maps.google.com/?q=-17.3942,-66.1574");
});

Deno.test("WhatsApp template params: 3rd value is the fallback text when there's no location", () => {
  const params = buildWhatsAppTemplateParams({
    riderName: "Carla Rider",
    occurredAt: "2026-08-28T14:07:00.000Z",
    latitude: null,
    longitude: null,
  });
  assertEquals(params[2], "Sin ubicación disponible");
});
