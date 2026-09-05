# Sentinel V2 — modelo de datos

Esquema inicial de grupos, viajes, ubicación en tiempo real y accidentes,
100% versionado en `supabase/migrations/`. Nada de esto se creó a mano desde
el Dashboard — `npx supabase db reset` reconstruye el proyecto local
únicamente a partir de las migraciones (+ `supabase/seed.sql` para datos de
desarrollo).

## Diagrama entidad-relación

```mermaid
erDiagram
  auth_users ||--|| profiles : "id = id"
  auth_users ||--o{ vehicles : owns
  auth_users ||--o{ emergency_contacts : owns
  auth_users ||--o{ ride_groups : owns
  auth_users ||--o{ ride_group_members : "is member"
  auth_users ||--o{ ride_session_members : participates
  auth_users ||--o{ live_locations : reports
  auth_users ||--o{ location_history : reports
  auth_users ||--o{ accident_events : triggers
  auth_users ||--o{ device_push_tokens : registers
  ride_groups ||--o{ ride_group_members : has
  ride_groups ||--o{ ride_sessions : has
  ride_sessions ||--o{ ride_session_members : has
  ride_sessions ||--o{ live_locations : "current positions"
  ride_sessions ||--o{ location_history : "position trail"
  ride_sessions |o--o{ accident_events : "occurred during"
  accident_events ||--o{ alerts : triggers

  auth_users {
    uuid id PK
    text email
  }
  profiles {
    uuid id PK_FK
    text display_name
    text phone
    text avatar_url
    bool whatsapp_alerts_opt_in
  }
  vehicles {
    uuid id PK
    uuid owner_id FK
    text brand
    text model
    int year
    text plate
  }
  emergency_contacts {
    uuid id PK
    uuid owner_id FK
    uuid contact_user_id FK "nullable"
    text name
    text phone
    bool notify_push
    bool notify_sms
    bool notify_whatsapp
  }
  ride_groups {
    uuid id PK
    uuid owner_id FK
    text name
    text invite_code UK
    enum status
  }
  ride_group_members {
    uuid group_id PK_FK
    uuid user_id PK_FK
    enum role
    enum status
    timestamptz left_at
  }
  ride_sessions {
    uuid id PK
    uuid group_id FK
    uuid started_by FK
    enum status
    timestamptz started_at
    timestamptz ended_at
  }
  ride_session_members {
    uuid session_id PK_FK
    uuid user_id PK_FK
    enum status
    timestamptz last_seen_at
  }
  live_locations {
    uuid session_id PK_FK
    uuid user_id PK_FK
    float latitude
    float longitude
    int battery_level
  }
  location_history {
    uuid id PK
    uuid session_id FK
    uuid user_id FK
    float latitude
    float longitude
    timestamptz recorded_at
  }
  accident_events {
    uuid id PK
    uuid session_id FK "nullable"
    uuid user_id FK
    float impact_mps2
    float confidence_score
    jsonb sensor_snapshot
    enum status
  }
  alerts {
    uuid id PK
    uuid accident_id FK
    enum recipient_type
    uuid recipient_user_id FK "nullable"
    enum channel
    enum status
  }
  device_push_tokens {
    uuid id PK
    uuid user_id FK
    enum platform
    text token UK
  }
```

## Migraciones

Todas bajo `supabase/migrations/`, aplicadas en orden por nombre
(`YYYYMMDDHHMMSS_descripción.sql`):

| # | Archivo | Contenido |
|---|---|---|
| 1 | `20260827210001_profiles.sql` | `set_updated_at()`, `profiles`, trigger `handle_new_user()` en `auth.users` |
| 2 | `20260827210002_vehicles.sql` | `vehicles` |
| 3 | `20260827210003_emergency_contacts.sql` | `emergency_contacts` |
| 4 | `20260827210004_ride_groups.sql` | tipos, `ride_groups`, `ride_group_members`, `is_group_member`/`is_group_admin`, política de `profiles` para compañeros de grupo, Realtime de `ride_group_members` |
| 5 | `20260827210005_ride_sessions.sql` | tipos, `ride_sessions`, `ride_session_members`, `is_session_member`, trigger anti-cambio de PK, Realtime de `ride_sessions` |
| 6 | `20260827210006_locations.sql` | `live_locations`, `location_history`, Realtime de `live_locations` |
| 7 | `20260827210007_accident_events.sql` | tipo `accident_event_status`, `accident_events`, Realtime |
| 8 | `20260827210008_push_tokens_and_alerts.sql` | `device_push_tokens`, `alerts` (sin políticas: solo backend) |
| 9 | `20260827210009_rpc_functions.sql` | `create_ride_group`, `join_group_by_code`, `leave_group`, `start_ride_session`, `finish_ride_session` |
| 10 | `20260827210010_realtime.sql` | autorización de canal privado `ride:<session_id>` sobre `realtime.messages` |
| 11 | `20260827210011_pgtap.sql` | extensión `pgtap` para `supabase test db` |
| 12 | `20260828000001_accident_alert_dispatch.sql` | extensión `pg_net`, `dispatch_accident_alert_webhook()`, trigger `accident_events_confirmed_dispatch_alerts` (Fase 8 — ver [docs/alerts.md](alerts.md)) |
| 13 | `20260829000001_whatsapp_alerts.sql` | `alert_channel` + `'whatsapp'`, `emergency_contacts.notify_whatsapp`, `profiles.whatsapp_alerts_opt_in` (Fase 8, extensión WhatsApp — ver [docs/alerts.md](alerts.md)) |

## Tablas

### profiles
1:1 con `auth.users`. Creada automáticamente por el trigger
`on_auth_user_created` (nunca por el cliente). `id`, `display_name`,
`phone?`, `avatar_url?`, `whatsapp_alerts_opt_in` (consentimiento para
alertas de accidente de compañeros por WhatsApp — Fase 8, ver
[docs/alerts.md](alerts.md); default `false`), `created_at`, `updated_at`.

### vehicles
`id`, `owner_id → auth.users`, `brand`, `model`, `year?` (check 1900..año+1),
`plate?`, `color?`, timestamps. Índice: `owner_id`.

### emergency_contacts
`id`, `owner_id → auth.users`, `contact_user_id? → auth.users` (enlace
opcional a otra cuenta Sentinel), `name`, `phone`, `relationship?`,
`notify_push`, `notify_sms`, `notify_whatsapp` (consentimiento explícito
para WhatsApp — Fase 8, distinto de los otros dos; ver
[docs/alerts.md](alerts.md); default `false`), timestamps. Índices:
`owner_id`, `contact_user_id` (parcial, `where not null`).

### ride_groups
`id`, `owner_id → auth.users`, `name` (check no vacío), `description?`,
`invite_code` **UNIQUE**, `status` (`active`/`archived`), timestamps.
Índice: `owner_id`.

### ride_group_members
`group_id → ride_groups`, `user_id → auth.users`, `role`
(`owner`/`admin`/`member`), `status`
(`invited`/`active`/`left`/`removed`), `joined_at`, `left_at?`.
**PK compuesta `(group_id, user_id)`** — es la constraint anti-duplicados:
un usuario tiene como máximo una fila por grupo; volver a unirse reactiva
esa misma fila (ver `join_group_by_code`). Índice: `user_id`.

### ride_sessions
`id`, `group_id → ride_groups`, `started_by → auth.users`, `name?`,
`status` (`waiting`/`active`/`finished`/`cancelled`), `started_at`,
`ended_at?` (check `>= started_at`), `created_at`. Índices: `group_id`,
`status`.

### ride_session_members
`session_id → ride_sessions`, `user_id → auth.users`, `status`
(`active`/`left`), `joined_at`, `left_at?`, `last_seen_at?`. **PK
compuesta `(session_id, user_id)`**. Un trigger impide modificar
`session_id`/`user_id` una vez creada la fila (evita "mover" la
participación a otra sesión). Índice: `user_id`.

### live_locations
`session_id → ride_sessions`, `user_id → auth.users`, `latitude`,
`longitude`, `accuracy?`, `speed?`, `heading?`, `battery_level?`,
`recorded_at`. **PK compuesta `(session_id, user_id)`** — exactamente una
posición actual por usuario y sesión, tal como se pidió; el cliente hace
`upsert` (`on conflict (session_id, user_id) do update`).
`REPLICA IDENTITY FULL` para que Realtime incluya la fila completa en
updates. Checks de rango en lat/lon/batería.

### location_history
`id`, `session_id → ride_sessions`, `user_id → auth.users`, `latitude`,
`longitude`, `accuracy?`, `speed?`, `heading?`, `recorded_at`. Índices:
`session_id`, `user_id`, `recorded_at`, y uno compuesto
`(session_id, user_id, recorded_at)` para el patrón de consulta real
("historial de este usuario en esta sesión, en orden de tiempo").
**Retención**: no implementada todavía — ver comentario `TODO(retention)`
en la migración; antes de producción debe purgarse con un job programado
(pg_cron o Edge Function con cron).

### accident_events
`id`, `session_id? → ride_sessions`, `user_id → auth.users`, `latitude?`,
`longitude?`, `impact_mps2`, `gyro_rad_s?`, `speed_kmh?`, `g_force?`,
`confidence_score?` (check 0..1), `sensor_snapshot? jsonb`, `status`
(`candidate`/`cancelled`/`confirmed`/`notified`/`resolved`), `occurred_at`,
`confirmed_at?`, `cancelled_at?`, `created_at`. `REPLICA IDENTITY FULL`.
Índices: `user_id`, `session_id` (parcial), `status`.

### device_push_tokens
`id`, `user_id → auth.users`, `platform` (`android`/`web`), `token`
**UNIQUE**, `enabled`, `last_seen_at`, `created_at`. Índice: `user_id`.

### alerts
`id`, `accident_id → accident_events`, `recipient_type`
(`group_member`/`emergency_contact`), `recipient_user_id?`,
`recipient_phone?`, `channel` (`push`/`sms`/`email`/`whatsapp`, este
último agregado en la Fase 8 — ver [docs/alerts.md](alerts.md)), `status`
(`pending`/`sent`/`failed`), `provider_message_id?`, `created_at`,
`sent_at?`. Check: si `recipient_type = 'group_member'` entonces
`recipient_user_id` es obligatorio. Índices: `accident_id`,
`recipient_user_id` (parcial).

## Row Level Security

**Todas** las 12 tablas de `public` tienen RLS habilitado. Ninguna política
usa `using (true)` para datos privados. Resumen:

| Tabla | Política | Regla |
|---|---|---|
| `profiles` | select | propio perfil, o el de un compañero de grupo activo |
| `profiles` | update | solo el propio |
| `vehicles` | CRUD | solo el propio (`owner_id = auth.uid()`) |
| `emergency_contacts` | CRUD | solo el propio (`owner_id = auth.uid()`) |
| `ride_groups` | select | miembro activo del grupo |
| `ride_groups` | update/delete | solo el owner |
| `ride_groups` | insert | **ninguna** — solo vía `create_ride_group()` |
| `ride_group_members` | select | miembro activo del grupo |
| `ride_group_members` | insert/update | solo owner/admin del grupo |
| `ride_sessions` | select | miembro activo del grupo |
| `ride_sessions` | insert/update | **ninguna** — solo vía `start_/finish_ride_session()` |
| `ride_session_members` | select | miembro activo de la sesión |
| `ride_session_members` | update | la propia fila (heartbeat / dejar de compartir) |
| `live_locations` | select | miembro activo de la sesión |
| `live_locations` | insert/update | la propia posición, y solo si es miembro de la sesión |
| `location_history` | insert | la propia, y solo si es miembro de la sesión |
| `location_history` | select | miembro activo de la sesión |
| `accident_events` | insert | el propio (`user_id = auth.uid()`, imposible falsificar) |
| `accident_events` | select | el propio (cualquier estado), o de la sesión si `status` ∈ `{confirmed,notified,resolved}` |
| `accident_events` | update | el propio, solo mientras `status = 'candidate'` (cancelar falsa alarma) |
| `device_push_tokens` | CRUD | solo el propio |
| `alerts` | — | **sin políticas**: inaccesible desde el cliente, solo Edge Function/`service_role` (Fase 8 — ver [docs/alerts.md](alerts.md)) |

Decisiones de diseño que van más allá de lo literal (documentadas también
inline en las migraciones):

- **`profiles` para compañeros de grupo** expone la fila completa (incluido
  `phone`), no una vista reducida — RLS es por fila, no por columna, y en
  una app de seguridad grupal poder llamar a un compañero es una
  funcionalidad deseada. Si se necesita ocultar `phone` en el futuro, la
  vía correcta es una vista `group_member_profiles` con columnas
  reducidas, no filtrado por columna en la policy.
- **`ride_groups`/`ride_sessions` sin INSERT/UPDATE policy propia**: crear
  un grupo, unirse, salir, iniciar y finalizar una sesión son operaciones
  con reglas de negocio (atomicidad, invitación válida, "un owner no puede
  simplemente irse", "solo una sesión activa por grupo") que no se pueden
  expresar de forma segura como una policy de RLS suelta. Viven en RPCs
  `SECURITY DEFINER` (ver abajo).
- **`accident_events` update propio mientras `candidate`**: no pedido
  explícitamente en las reglas de RLS del enunciado, pero necesario para
  que el motociclista pueda indicar "estoy bien" durante la cuenta
  regresiva (funcionalidad #10 del producto). Una vez `confirmed` en
  adelante, el registro pasa a ser responsabilidad del backend.

## Funciones auxiliares (`SECURITY DEFINER`)

`is_group_member(group_uuid, user_uuid)`, `is_group_admin(group_uuid,
user_uuid)`, `is_session_member(session_uuid, user_uuid)`.

Las tres son `SECURITY DEFINER` por el mismo motivo: una política de RLS
sobre `ride_group_members`/`ride_session_members` que consultara esa misma
tabla a través de una función de **invoker** volvería a evaluar RLS sobre
la propia tabla dentro de la política, generando recursión o forzando una
política mucho más permisiva solo para que la comprobación pueda ver las
filas que necesita. Ejecutar como el dueño de la función (que además es el
dueño de la tabla) evita esa auto-referencia. Es seguro porque:

- cada función es de solo lectura y devuelve exclusivamente un `boolean`;
- **`search_path` fijado explícitamente a `public`** en las tres, para
  evitar un ataque de *search_path hijacking* típico de las funciones
  `SECURITY DEFINER`;
- `EXECUTE` revocado de `PUBLIC` y otorgado únicamente a `authenticated`
  (nunca a `anon`).

## RPC

Las cinco operaciones atómicas pedidas, todas `SECURITY DEFINER` (mismo
razonamiento: las tablas base no tienen policy de INSERT/UPDATE directa
para estas rutas), con `search_path = public` fijo, identidad derivada
**siempre** de `auth.uid()` (nunca de un parámetro del cliente), y
`REVOKE ALL FROM PUBLIC` + `GRANT EXECUTE TO authenticated`:

- **`create_ride_group(p_name, p_description?)`** — crea el grupo y agrega
  al creador como `owner`/`active` en una sola transacción; genera un
  `invite_code` único con reintento ante colisión.
- **`join_group_by_code(p_invite_code)`** — busca el grupo por código,
  valida `status = 'active'`, evita duplicados (bloquea la fila existente
  con `for update`, reactiva si estaba `left`/`removed`, inserta si no
  existía), devuelve `group_id`. Idempotente si ya es miembro activo.
- **`leave_group(p_group_id)`** — el propio usuario abandona el grupo
  (`status → left`). Regla de dominio: el `owner` no puede abandonar así.
- **`start_ride_session(p_group_id, p_name?)`** — solo owner/admin; rechaza
  si el grupo ya tiene una sesión `waiting`/`active`; inscribe
  automáticamente a todos los miembros activos del grupo en
  `ride_session_members`.
- **`finish_ride_session(p_session_id)`** — solo owner/admin del grupo de
  esa sesión; marca `finished` y libera (`status → left`) a todos los
  participantes activos.

## Realtime

Habilitado **solo** en las 4 tablas pedidas (`alter publication
supabase_realtime add table ...`): `live_locations`, `ride_group_members`,
`ride_sessions`, `accident_events`. El resto queda fuera a propósito.

Para `postgres_changes`, la seguridad es automática: Realtime evalúa la RLS
de la tabla con el JWT del suscriptor, así que un cliente cuya policy de
`select` no devolvería una fila tampoco recibe eventos de cambio sobre
ella — no hace falta ninguna regla adicional para eso.

### Canal privado `ride:<session_id>`

Para señales efímeras que no están respaldadas por una tabla (presence,
"fulano se desconectó", etc.) se usa **Realtime Authorization**: políticas
RLS sobre `realtime.messages`, filtrando por el *topic* del canal
(`realtime.topic()`), ver
[migración 010](../supabase/migrations/20260827210010_realtime.sql) y la
[documentación oficial](https://supabase.com/docs/guides/realtime/authorization).

- Solo se permite `select`/`insert` cuando el topic empieza con `ride:` y
  `is_session_member(<uuid tras 'ride:'>, auth.uid())` es verdadero.
- **Contrato con el cliente**: el canal debe abrirse con
  `RealtimeChannelConfig(private: true)` (Flutter/Dart) — un canal no
  marcado como privado *no* pasa por estas políticas en absoluto.

## Trigger de creación de perfil

`handle_new_user()` (`SECURITY DEFINER`, `search_path = public`) se
dispara `after insert on auth.users` e inserta en `public.profiles` con
`on conflict (id) do nothing` (nunca duplica). El `display_name` sale de
`raw_user_meta_data->>'display_name'` si el signup lo mandó, si no del
prefijo del email.

## Datos de desarrollo (`supabase/seed.sql`)

Crea **usuarios reales** en `auth.users` + `auth.identities` (no UUIDs
sueltos que rompan FKs) para poder iniciar sesión de verdad contra el
stack local. Contraseña de los 4: `Sentinel123!`.

| Email | Rol en "Ruta de los Domingos" |
|---|---|
| `rider1@sentinel.dev` | owner |
| `rider2@sentinel.dev` | admin |
| `rider3@sentinel.dev` | member |
| `outsider@sentinel.dev` | **no** pertenece al grupo (fixture para probar RLS negativo) |

Además: 2 vehículos, 2 contactos de emergencia, 1 grupo, 1 sesión activa
con los 3 riders, 3 `live_locations`, 2 `location_history`, 2
`accident_events` (uno `candidate` privado, uno `confirmed` visible a la
sesión) con su `alert`, y 3 `device_push_tokens`.

## Pruebas del esquema

pgTAP vía `npx supabase test db`, en `supabase/tests/database/`. Cada
archivo simula un usuario real cambiando el rol de sesión y las claims del
JWT que `auth.uid()`/`auth.role()` leen:

```sql
set local role authenticated;
set local request.jwt.claims to '{"sub":"<uuid>","role":"authenticated"}';
-- ... assertions ...
reset role;
```

| Archivo | Cubre |
|---|---|
| `010_profiles_and_vehicles_rls.sql` | A no puede modificar perfil/vehículo de B; el propio dueño sí puede; un outsider no lee vehículos ajenos; `anon` no lee ningún perfil |
| `020_locations_rls.sql` | un externo no lee ubicaciones de una sesión ajena; un miembro sí lee las de sus compañeros; un usuario solo actualiza su propia ubicación |
| `030_accident_events_rls.sql` | no se puede falsificar un `accident_event` para otro `user_id`; un evento `candidate` es privado; uno `confirmed` es visible a la sesión |
| `040_group_rpc.sql` | `join_group_by_code` (código válido/ inválido, idempotencia, sin duplicados) y `leave_group` (funciona; el owner no puede) |

Ejecutar:

```powershell
npx supabase test db
```

24/24 assertions en verde sobre el estado sembrado por `seed.sql`.

## Reproducibilidad

```powershell
npx supabase db reset
```

recrea el proyecto local **exclusivamente** desde `supabase/migrations/` +
`supabase/seed.sql` — sin ningún paso manual en el Dashboard. La única
excepción deliberada es el secreto compartido de Fase 8
(`accident_alert_webhook_secret` en Vault): un secreto real no puede vivir
en una migración versionada — ver [docs/alerts.md](alerts.md) para el paso
de configuración de una sola vez que sí queda fuera de `db reset`.

## Pendiente / próximos pasos

- Política de retención/purga de `location_history` (`TODO(retention)` en
  la migración 006).
- Transferencia de ownership de un `ride_group` (hoy el owner no puede
  abandonar ni ser reemplazado por RPC).
- Credenciales reales de proveedor (Firebase/FCM, Twilio) para que el envío
  de `alerts` de la Fase 8 pase de "intentado, sin proveedor configurado" a
  entrega real — ver [docs/alerts.md](alerts.md) deuda técnica.
