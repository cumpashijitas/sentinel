# Sentinel V2 — seguridad y privacidad

Principios que rigen **todas** las fases del proyecto, no solo lo ya
implementado. Cuando una fase nueva (ubicación en tiempo real, sensores,
alertas) introduce una decisión que choca con alguno de estos puntos, la
decisión debe documentarse explícitamente aquí y en el módulo
correspondiente — no asumirse en silencio.

## Principios

1. **Mínimo privilegio.** RLS habilitado en toda tabla de `public`
   accesible desde el cliente (ver
   [docs/database.md](database.md#row-level-security)); ninguna policy usa
   `using (true)` sobre datos privados. Operaciones con reglas de dominio
   (crear grupo, unirse, iniciar/finalizar viaje) pasan por RPC
   `SECURITY DEFINER` en vez de una policy de INSERT/UPDATE suelta — ver el
   detalle de cada función en `docs/database.md`.
2. **Nunca `service_role` en Flutter.** La app solo recibe la
   *publishable key* (`SUPABASE_PUBLISHABLE_KEY`, ver README §4). La
   service_role key y cualquier secreto de proveedor (push, SMS) viven
   exclusivamente como Supabase Secrets, consumidos desde Edge Functions
   (Fase 8) — nunca compilados dentro del bundle Flutter.
3. **Sin secretos hardcodeados.** Toda configuración sensible entra por
   `--dart-define-from-file` (`core/config/app_config.dart`); `config/*.json`
   reales están en `.gitignore`, solo se versionan los `*.example.json`.
4. **Validación server-side para operaciones importantes.** Un cliente
   Flutter comprometido o modificado no debe poder, por ejemplo, unirse a
   un grupo sin código válido, marcar un accidente de otro usuario como
   confirmado, o leer ubicaciones de una sesión ajena — esas reglas están en
   Postgres (RLS + RPC), no solo en la UI. La UI puede (y debe) validar
   también, pero como mejora de UX, nunca como única barrera.
5. **Mínima recopilación de datos.**
   - `location_history` guarda una muestra (política de tiempo/distancia/
     cambio relevante — Fase 5), no cada evento GPS crudo.
   - Los datos de sensores (acelerómetro/giroscopio) **no se envían nunca
     como stream continuo** a Supabase — viven en un ring buffer en memoria
     del dispositivo (Fase 7) y solo se persiste un `sensor_snapshot`
     acotado cuando efectivamente hay un `accident_event`.
   - `alerts` no expone información médica; el payload de una alerta es el
     mínimo necesario (nombre, hora, lat/lon, link de mapa, `ride_session`,
     `accident_id` — ver Fase 8).
6. **Control explícito del usuario sobre compartir ubicación.** Un usuario
   comparte su ubicación **solo** cuando: (a) pertenece a un `ride_session`
   activo, y (b) explícitamente activó la participación (Fase 4/5) — nunca
   como efecto secundario de tener la app abierta. Al abandonar o
   finalizarse el viaje, el tracking se detiene (`ride_session_members` /
   `live_locations` dejan de actualizarse; ver `finish_ride_session` en
   `docs/database.md`).
7. **Nada de detección crítica de accidentes dependiendo del navegador.**
   `PlatformCapabilities` (ver `docs/architecture.md`) impide que
   `AccidentDetector`/sensores/ubicación en background corran en Web —
   estas capacidades son exclusivamente Android.

## Estado actual (Fase 1: Auth + Profile)

- Auth: Supabase Auth (email/password), sin Firebase Auth. Sesión manejada
  por `supabase_flutter`; el token nunca se maneja manualmente en Dart.
- Profile: RLS restringe `update` a la propia fila
  (`id = auth.uid()`); un usuario nunca puede escribir el perfil de otro
  aunque manipule la app cliente — probado en
  `supabase/tests/database/010_profiles_and_vehicles_rls.sql` (pgTAP) y
  reconfirmado en este módulo contra una instancia Supabase local real
  (login real + lectura/escritura real de `profiles`, no solo fakes).
- `phone` de `profiles` es visible para compañeros de grupo activos (no
  solo el propio usuario) — decisión de producto documentada en
  `docs/database.md`, no un descuido: en una app de seguridad grupal, poder
  llamar a un compañero es una funcionalidad, y la fila solo es visible a
  quien comparte un grupo activo con el dueño.

## Fase 8: alertas

`dispatch-accident-alerts` es la primera pieza server-side del proyecto:
corre exclusivamente con la `service_role` key (nunca compilada en el
bundle Flutter, inyectada automáticamente por el runtime de Edge
Functions) y es la única escritora de `alerts`, que sigue sin ninguna
policy de cliente. Su único llamador legítimo es un trigger de base de
datos, no un usuario — se autentica con un secreto compartido guardado en
Supabase Vault en vez de un JWT de usuario, precisamente para que ese
secreto nunca quede escrito en una migración versionada. Detalle completo
en [docs/alerts.md](alerts.md).

## Pendiente (fases futuras — no implementado todavía)

- Retención/purga de `location_history` y `alerts` (`TODO(retention)` en
  la migración `20260827210006_locations.sql`).
- Credenciales reales de proveedor (Firebase/FCM, Twilio) para que el envío
  de alertas de la Fase 8 entregue de verdad, no solo lo intente — ver
  deuda técnica en `docs/alerts.md`.
- Revisión de compatibilidad de background location/sensores con
  restricciones de Android (proceso terminado, optimización de batería) —
  se documentará en `docs/background-location.md` cuando arranque la Fase 6,
  sin prometer garantías que Android no ofrece.
