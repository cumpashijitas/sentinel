-- Sentinel V2 — Fase 8 (extensión): alertas por WhatsApp.
--
-- WhatsApp Business Platform requiere dos cosas que no aplican a
-- push/SMS/email: (1) los mensajes iniciados por el "negocio" (una alerta,
-- no una respuesta a algo que el destinatario escribió primero) tienen que
-- usar una plantilla pre-aprobada por Meta, y (2) el destinatario tiene
-- que haber dado consentimiento explícito para recibir mensajes de ese
-- número de negocio — a diferencia de SMS, donde cualquier número es
-- válido de entrada. Estas dos columnas nuevas capturan exactamente ese
-- consentimiento, por separado del ya existente `notify_push`/`notify_sms`
-- (que rigen canales sin ese requisito legal). Ver docs/alerts.md.

-- ---------------------------------------------------------------------------
-- alert_channel: agregar 'whatsapp' junto a los ya existentes push/sms/email.
-- ALTER TYPE ... ADD VALUE no puede usarse en la misma transacción en la que
-- se referencia el valor nuevo — por eso vive solo en esta migración, sin
-- ningún uso del literal 'whatsapp' en el resto del archivo.
-- ---------------------------------------------------------------------------
alter type public.alert_channel add value if not exists 'whatsapp';

-- ---------------------------------------------------------------------------
-- emergency_contacts.notify_whatsapp: mismo patrón que notify_push/notify_sms
-- — una preferencia por contacto, respetada de forma literal e independiente
-- (dispatch-accident-alerts nunca infiere consentimiento de WhatsApp a partir
-- de notify_push/notify_sms).
-- ---------------------------------------------------------------------------
alter table public.emergency_contacts
  add column notify_whatsapp boolean not null default false;

-- ---------------------------------------------------------------------------
-- profiles.whatsapp_alerts_opt_in: el consentimiento equivalente para un
-- compañero de grupo/sesión (no tiene una fila propia como
-- emergency_contacts, así que el flag vive en su perfil). Deliberadamente
-- separado de que `phone` ya sea visible entre compañeros de grupo desde la
-- Fase 1 (docs/database.md) — visibilidad para llamar no es lo mismo que
-- consentimiento para recibir mensajes de negocio de WhatsApp.
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column whatsapp_alerts_opt_in boolean not null default false;
