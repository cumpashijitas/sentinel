# Sentinel V2

Seguridad y viajes grupales para motociclistas: grupos, viajes en tiempo real,
ubicación compartida y detección de accidentes en Android, con Auth,
Postgres, Realtime y Storage en Supabase.

Este repositorio empieza limpio — no reutiliza código de versiones
anteriores.

## 1. Requisitos

| Herramienta | Versión usada en este repo | Notas |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.47.1 (stable) | incluye Dart 3.13.1 |
| [Android Studio](https://developer.android.com/studio) + Android SDK | SDK 35 / build-tools 35.0.0 | acepta las licencias con `flutter doctor --android-licenses` |
| JDK | 21 (Temurin) | requerido por el Android Gradle Plugin actual |
| Chrome o Edge | — | para `flutter run -d chrome` / Flutter Web |
| [Node.js](https://nodejs.org/) | ≥ 20 (probado con 22.19) | solo para la CLI de Supabase |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) (o runtime compatible) | 28.x | requerido por `supabase start` |
| [Git](https://git-scm.com/) | 2.51 | |
| Supabase CLI | vía `npx supabase` (2.116.0) | instalada como devDependency de npm, no global |

Verifica tu entorno con:

```powershell
flutter --version
dart --version
flutter doctor -v
flutter devices
java -version
adb version
node --version
npm --version
docker --version
npx supabase --version
```

`flutter doctor -v` no debe reportar errores en Android toolchain, Chrome ni
Connected devices (el checker de Visual Studio/Windows desktop se puede
ignorar: este proyecto no soporta la plataforma Windows desktop).

## 2. Instalación

```powershell
git clone <este-repositorio>
cd sentinel_v2
flutter pub get
npm install
```

## 3. Generación de código

El proyecto usa `freezed`, `json_serializable` y `riverpod_generator`. Tras
clonar o modificar cualquier clase anotada (`@freezed`, `@riverpod`, …):

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Los archivos generados (`*.g.dart`, `*.freezed.dart`) están commiteados en
este repo para que `flutter analyze` / `flutter test` / `flutter build`
funcionen sin un paso extra — vuelve a ejecutar el comando de arriba cada vez
que cambies un archivo anotado.

## 4. Configuración / variables de entorno

**Nunca** se hardcodean secretos en el código Dart. Toda configuración
sensible (URL de Supabase, publishable key, API key de mapas) se inyecta en
tiempo de compilación vía `--dart-define-from-file`.

1. Copia la plantilla:

   ```powershell
   Copy-Item config/dev.json.example config/dev.json
   ```

2. Completa `config/dev.json` con los valores de tu instancia de Supabase
   (local o remota) — ver la sección siguiente.
3. Para producción, copia `config/prod.json.example` a `config/prod.json` y
   complétalo con las credenciales del proyecto de Supabase en la nube.

`config/*.json` (excepto los `*.example.json`) está en `.gitignore`: **no se
commitea**.

Claves usadas:

| Clave | Descripción |
|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase (local: `http://127.0.0.1:54321`) |
| `SUPABASE_PUBLISHABLE_KEY` | Publishable key del proyecto (antes llamada "anon key") |
| `GOOGLE_MAPS_API_KEY` | Mapa del viaje (`google_maps_flutter`, Fase 5). Vacía en `config/dev.json` — sin ella el mapa no renderiza tiles, pero el resto del flujo (roster, estados, compartir ubicación) funciona igual |
| `ENVIRONMENT` | `dev` / `prod` — controla `AppConfig.isProduction` |

La service_role key de Supabase **nunca** debe entrar a este proyecto
Flutter. Los secretos server-side (service_role, credenciales de push, etc.)
viven únicamente como Supabase Secrets, consumidos desde Edge Functions.

## 5. Supabase local

```powershell
npx supabase start
```

Esto levanta Postgres, Auth, Realtime, Storage y Studio vía Docker. Al
terminar, la CLI imprime la URL y las claves locales — copia el
`anon key`/`publishable key` a `config/dev.json`.

Comandos útiles:

```powershell
npx supabase status   # ver URLs/keys de la instancia local
npx supabase stop     # apagar el stack
```

`supabase/config.toml`, `supabase/migrations/`, `supabase/seed.sql` y
`supabase/functions/` están versionados. El esquema completo (perfiles,
vehículos, contactos de emergencia, grupos, viajes, ubicación y
accidentes) vive en `supabase/migrations/` — ver
[docs/database.md](docs/database.md) para el diagrama y el detalle
completo. Para recrear el proyecto local desde cero a partir únicamente de
las migraciones:

```powershell
npx supabase db reset
```

Esto también carga `supabase/seed.sql`, que crea 4 usuarios de desarrollo
reales (`rider1/2/3@sentinel.dev` + `outsider@sentinel.dev`, contraseña
`Sentinel123!`) y datos de ejemplo (grupo, sesión activa, ubicaciones,
accidentes). Para correr las pruebas del esquema (pgTAP):

```powershell
npx supabase test db
```

## 6. Ejecutar en Android

```powershell
flutter emulators --launch Pixel_6_API_34   # o conecta un dispositivo físico
flutter run -d android --dart-define-from-file=config/dev.json
```

Para que el mapa del viaje (Fase 5) muestre tiles, `android/local.properties`
necesita `MAPS_API_KEY=<tu clave>` (leída por `android/app/build.gradle.kts`
e inyectada como `meta-data` en el manifest) — sin ella, el mapa se ve en
blanco pero el resto de la pantalla (roster, estados de los integrantes,
compartir ubicación) funciona igual.

**Emulador contra Supabase local**: `127.0.0.1` dentro del emulador
apunta al propio emulador, no a tu máquina — usa
`Copy-Item config/dev.android.json.example config/dev.android.json` (URL
`http://10.0.2.2:54321`, el alias que el emulador de Android reserva para
el host) y lanza con
`flutter run -d android --dart-define-from-file=config/dev.android.json`
en vez de `config/dev.json`. Innecesario en un dispositivo físico en la
misma red (usa la IP LAN de tu máquina en su lugar) ni al compilar para
producción.

Compartir ubicación en segundo plano (Fase 6, `RideBackgroundService`)
pide permiso de ubicación "todo el tiempo" (`Allow all the time`) la
primera vez — Android no ofrece esa opción en el diálogo inicial junto al
permiso de primer plano; hace falta ir a Ajustes > Apps > Sentinel >
Permisos > Ubicación una vez concedido "mientras se usa la app". Detalle
completo, incluyendo por qué esta fase optó por un `Service` nativo en vez
de la config de `geolocator`, en
[docs/background_service.md](docs/background_service.md).

## 7. Ejecutar en Web

```powershell
flutter run -d chrome --dart-define-from-file=config/dev.json
```

Para el mapa en Web, descomenta el script de Google Maps en `web/index.html`
y reemplaza el placeholder por tu clave (o usa `GOOGLE_MAPS_API_KEY` en
`config/dev.json` para la parte de la app que sí lee configuración en
tiempo de compilación — el script de `index.html` es estático y no puede
leer `--dart-define-from-file`, por eso son dos pasos separados).

Desde la Fase 10, ensancha la ventana del navegador (o el viewport de
DevTools) por encima de 840px para ver el dashboard: una barra de
navegación lateral persistente (`NavigationRail`) aparece a la izquierda
de Inicio/Grupos/Vehículos/Contactos/Historial — ver
[docs/web_dashboard.md](docs/web_dashboard.md). Por debajo de ese ancho,
Web se ve idéntico a como se veía antes de esta fase.

## 8. Tests

```powershell
dart format .
flutter analyze
flutter test
```

Base de datos (pgTAP, contra el stack local — ver §5):

```powershell
npx supabase test db
```

Edge Function de la Fase 8 (Deno; el host de desarrollo no necesita tener
Deno instalado — `npx deno` lo resuelve on-demand):

```powershell
cd supabase/functions/dispatch-accident-alerts
npx -y deno test message_test.ts
npx -y deno lint .
```

## 9. Arquitectura

Documentación completa de la arquitectura Flutter (capas, manejo de
errores, convenciones de Riverpod, testing) en
[docs/architecture.md](docs/architecture.md), con diagrama Mermaid.
Feature-first, con `data/domain/presentation` dentro de cada feature (solo
se crean las capas que ya tienen contenido real — nada de carpetas vacías):

```
lib/
  app/            # bootstrap, MaterialApp.router, GoRouter
                  # adaptive_shell.dart (Fase 10, Web-only dashboard shell)
  core/           # config, errores, logging, plataforma, tema, servicios
  features/
    auth/
      data/         # datasource + repository (Supabase)
      domain/       # entidad AppUser, contrato AuthRepository
      presentation/ # controllers (Riverpod), páginas de login/registro
    profile/
      data/         # datasource + repository (tabla profiles)
      domain/       # entidad Profile, contrato ProfileRepository
      presentation/ # controller + página de ver/editar perfil
    vehicles/
      data/         # datasource + repository (tabla vehicles)
      domain/       # entidad Vehicle, contrato VehicleRepository
      presentation/ # controller (lista + form) + página CRUD
    emergency_contacts/
      data/         # datasource + repository (tabla emergency_contacts)
      domain/       # entidad EmergencyContact, contrato EmergencyContactRepository
      presentation/ # controller (lista + form) + página CRUD
    groups/
      data/         # datasource (tablas + RPC) + repository
      domain/       # entidades RideGroup/GroupMember, contrato GroupRepository
      presentation/ # controller (lista/detalle/roster + acciones) + páginas
    rides/
      data/         # datasources (tablas/RPC de sesión + live_locations/location_history) + repositories
      domain/
        entities/     # RideSession, RideSessionParticipant, LocationFix, MemberLocation, MemberTrackingConfig,
                       # RideHistoryEntry (Fase 9)
        repositories/ # RideSessionRepository, LocationTracker, LiveLocationRepository, LocationRepository,
                       # BackgroundLocationService (Fase 6, Android-only)
        services/     # MemberTrackingService, StragglerDetectionStrategy, LocationSamplingPolicy (lógica pura)
      data/
        datasources/  # ...además AndroidBackgroundLocationService (Fase 6, MethodChannel)
      presentation/
        controllers/  # sesión activa/detalle/roster + live tracking (compartir ubicación)
        pages/        # detalle de sesión + mapa del viaje (Fase 5)
        utils/        # member_markers.dart — mapeo a Marker de google_maps_flutter
    accidents/
      domain/
        entities/     # AccidentEvent, MotionSample
        repositories/ # MotionTracker, AccidentEventRepository, AccidentAlertNotifier,
                       # AccidentMonitorService (Fase 7, Android-only)
        services/     # AccidentDetectionService (heurística pura de umbral)
      data/
        datasources/  # SensorsPlusMotionTracker, LocalAccidentAlertNotifier (flutter_local_notifications),
                       # AccidentEventRemoteDataSource
        repositories/ # AccidentEventRepositoryImpl, AccidentMonitorServiceImpl (orquestador)
      presentation/
        controllers/  # accident_event_providers.dart (Fase 9 — el repositorio ya existía en Fase 7,
                       # pero nada dentro del árbol de widgets lo necesitaba hasta ahora)
      accident_alert_response.dart # registro del handler de "Estoy bien" en el engine de UI
    history/           # Fase 9: historial de viajes/accidentes + estadísticas básicas
      domain/
        entities/     # RideStatistics
        services/     # RideStatisticsCalculator (lógica pura, misma familia que
                       # MemberTrackingService/AccidentDetectionService)
      presentation/
        controllers/  # rideHistoryProvider/accidentHistoryProvider/rideStatisticsProvider
        pages/        # HistoryPage (tabs Viajes/Accidentes/Estadísticas), AccidentDetailPage
                       # RideHistoryEntry vive en features/rides/domain/entities/ — ver docs/history.md
    push_tokens/
      domain/
        entities/     # DevicePushToken
        repositories/ # DevicePushTokenRepository, PushTokenSource (seam para firebase_messaging)
        services/     # PushTokenRegistrar (orquestación pura, testeada con fakes)
      data/
        datasources/  # SupabaseDevicePushTokenRemoteDataSource, UnavailablePushTokenSource
        repositories/ # DevicePushTokenRepositoryImpl
      presentation/
        controllers/  # providers Riverpod, watched desde SentinelApp
    home/
      presentation/ # landing tras login, con acceso a Grupos/Vehículos/Contactos
  background/       # Fase 6: entrypoint del FlutterEngine headless que arranca
                     # RideBackgroundService (Android) — ver ride_background_main.dart
                     # (Fase 7: también arranca AccidentMonitorServiceImpl ahí mismo)
  shared/
    widgets/        # AppTextField, PrimaryButton, PlaceholderPage, ResponsiveContent (Fase 10)
  main.dart
```

```
android/app/src/main/kotlin/com/sentinel/app/
  MainActivity.kt           # registra el MethodChannel de background location
  RideBackgroundService.kt  # foreground Service (Fase 6) — ver docs/background_service.md
```

```
supabase/functions/dispatch-accident-alerts/  # Fase 8 — único código server-side (Deno)
  index.ts       # handler HTTP + resolución de destinatarios + orquestación
  message.ts     # formato del mensaje (puro, testeado sin red)
  providers.ts   # PushProvider/SmsProvider/WhatsAppProvider reales, con fallback Noop
  fcm.ts         # firma JWT de cuenta de servicio + FCM HTTP v1, sin SDK de Google
  whatsapp.ts    # WhatsApp Cloud API (plantilla pre-aprobada, no texto libre)
  .env.example   # plantilla de secretos (real: supabase/functions/.env, gitignored)
```

Piezas clave de los módulos ya implementados (Auth + Profile — Fase 1;
Emergency Contacts + Vehicles — Fase 2; Ride Groups — Fase 3; Ride
Sessions — Fase 4; Realtime Location + Map — Fase 5; Android Background
Service — Fase 6; Detección de Accidentes — Fase 7; Despacho de Alertas —
Fase 8):

- **`AppConfig`** (`core/config/app_config.dart`): lee la configuración
  exclusivamente desde `String.fromEnvironment`, y falla con un mensaje claro
  si falta `--dart-define-from-file`.
- **`PlatformCapabilities`** (`core/platform/platform_capabilities.dart`):
  única fuente de verdad sobre qué funciona en Android vs. Web (sensores,
  ubicación en background, detección de accidentes, notificaciones son
  Android-only; auth, grupos, viajes, mapa y ubicación en foreground
  funcionan en ambas plataformas). Expone `requireAndroid(feature)` como
  guardia defensiva para que código Android-only nunca se ejecute
  accidentalmente en Web.
- **`AuthRepository`**/**`ProfileRepository`**/**`VehicleRepository`**/
  **`EmergencyContactRepository`** (dominio) + sus `*Impl` (datos): la capa
  de presentación depende solo de la interfaz de dominio, nunca de
  `supabase_flutter` directamente — lo que permite testear con fakes sin
  red. `DataException` (`core/errors/app_exception.dart`) es el tipo de
  error compartido para este tipo de feature CRUD simple.
- **Router** (`app/router.dart`): rutas protegidas con `redirect` basado en
  el estado de sesión de Supabase (vía `GoRouterRefreshStream`). Todas las
  rutas del producto están declaradas desde el inicio del proyecto, aunque
  al principio varias apuntaban a un `PlaceholderPage` hasta que su feature
  se implementaba — con la Fase 9 (`/history`, `/accidents/:id`) ya no
  queda ninguna: cada ruta declarada resuelve a una página real.
  `PlaceholderPage` (`shared/widgets/`) sigue existiendo como recurso para
  la próxima ruta que se agregue antes de tener su pantalla lista. Desde la
  Fase 10, las cinco rutas "hub" (Inicio/Grupos/Vehículos/Contactos/
  Historial) se envuelven en un `ShellRoute` con `AdaptiveShell` **solo en
  Web** (`if (PlatformCapabilities.isWeb)`) — en Android son exactamente
  los mismos `GoRoute` de siempre, sin shell.
- **Vehicles/EmergencyContacts**: a diferencia de Profile (una sola fila
  1:1, lectura/escritura separadas), son listas — cada una usa un único
  `*Controller` `AsyncNotifier<List<T>>` para la lista (con
  `ref.invalidate` tras cada mutación) y un `*FormController` separado solo
  para el resultado de la acción de guardar/borrar, siguiendo el mismo
  patrón lectura/escritura de Profile pero aplicado a colecciones. Detalle
  y justificación en [docs/architecture.md](docs/architecture.md).
- **Groups** (`GroupRepository`): a diferencia de las features anteriores,
  crear/unirse/salir de un grupo **no** son inserts/updates directos —
  llaman a las RPC `SECURITY DEFINER` ya migradas
  (`create_ride_group`/`join_group_by_code`/`leave_group`) vía
  `supabase.rpc(...)`, porque `ride_groups`/`ride_group_members` no tienen
  policy de INSERT para el cliente (ver `docs/database.md`). El roster de
  un grupo (`GroupMember`) tampoco viene de una sola tabla: `profiles` no
  tiene FK directa a `ride_group_members` (ambas solo referencian
  `auth.users` por separado), así que PostgREST no puede *embeder* una en
  la otra — el repositorio hace dos consultas (miembros, luego perfiles) y
  las combina en memoria. `GroupActionsController` también rompe
  ligeramente el patrón "estado = solo la acción": sus métodos además
  *devuelven* el grupo creado/el id al que te uniste, para que la página
  pueda navegar sin una segunda vuelta por un provider.
- **Rides** (`RideSessionRepository`): mismo patrón que Groups (RPC en vez
  de insert/update directo — `ride_sessions` tampoco tiene policy de
  cliente; roster de `RideSessionParticipant` armado con dos consultas por
  la misma razón que `GroupMember`). Sin embargo **no existe un "unirse a
  la sesión"**: `start_ride_session` ya inscribe automáticamente a todos
  los miembros activos del grupo en `ride_session_members`, así que
  participar en un viaje es un efecto secundario de pertenecer al grupo
  cuando arranca, no una acción aparte — `RideSessionRepository` ni
  siquiera declara un método `join`. `GroupDetailPage` (feature `groups`)
  importa el provider `activeSessionProvider` de `rides` para mostrar
  "Iniciar viaje"/"Ver viaje en curso" — composición de UI entre features
  a propósito (la sesión pertenece conceptualmente al grupo), documentada
  aquí para que no se lea como una dependencia circular accidental.
- **Realtime Location + Map** (`LocationTracker`/`LiveLocationRepository`/
  `LocationRepository`): tres interfaces de dominio separadas en vez de una
  — `LocationTracker` (lee el GPS del dispositivo, hoy una única
  implementación `GeolocatorLocationTracker` para Android+Web ya que
  `geolocator` federa ambas plataformas), `LiveLocationRepository` (lee/
  escribe `live_locations`/`location_history` en Supabase) y
  `LocationRepository` (orquesta ambas: al compartir, escucha el tracker y
  hace upsert en cada fix, más un insert muestreado en `location_history`
  según `LocationSamplingPolicy` — no una fila por cada posición GPS). El
  estado de cada integrante (`activo`/`stale`/`offline`/`lagging`) lo
  calcula `MemberTrackingService` con un algoritmo de dos pasadas: primero
  clasifica por antigüedad del último fix, y solo entre los que siguen
  "activos" por edad evalúa si alguno quedó geográficamente atrás
  (`CentroidStragglerDetectionStrategy`, centroide de los demás vs.
  distancia). `sessionMemberLocationsProvider` combina el stream de
  Realtime de `live_locations` con un ticker de 10s (un estado puede
  volverse `stale`/`offline` solo por el paso del tiempo, sin que llegue
  ningún evento nuevo) — detalle completo del canal, su ciclo de
  suscripción/cancelación y dos bugs reales que solo aparecieron en
  verificación E2E (no en los tests unitarios) en
  [docs/realtime.md](docs/realtime.md). `RideMapPage` empieza siempre con
  "compartir ubicación" apagado — consentimiento explícito por pantalla,
  nunca reanudado automáticamente (ver
  [docs/security.md](docs/security.md)).
- **Android Background Service** (`RideBackgroundService`,
  `BackgroundLocationService`): en Android, `LiveTrackingController`
  siempre delega en un `Service` nativo con notificación persistente en
  vez de compartir directamente desde el engine de la UI — así solo hay
  un lugar haciendo tracking en Android, por construcción, nunca dos
  suscripciones en paralelo. El `Service` arranca un segundo
  `FlutterEngine` headless (`lib/background/ride_background_main.dart`)
  que reconstruye a mano las mismas clases de la Fase 5
  (`LocationRepositoryImpl` y compañía) — cero lógica de tracking
  duplicada entre el camino de foreground y el de background. En Web
  (sin Service posible) el camino sigue siendo exactamente el de la Fase
  5. Se optó por un `Service` propio en vez de la
  `foregroundNotificationConfig` de `geolocator` específicamente para
  sobrevivir a que el usuario cierre la app desde Recientes mientras
  comparte ubicación — decisión, diagrama de secuencia completo y dos
  bugs reales encontrados en la verificación E2E en un dispositivo real
  (no solo en tests) en
  [docs/background_service.md](docs/background_service.md).
- **Detección de Accidentes** (`AccidentMonitorServiceImpl`,
  `AccidentDetectionService`): corre dentro del mismo engine de background
  de la Fase 6, mientras se comparte ubicación — no un tercer engine
  aparte. `AccidentDetectionService` (dominio, puro) evalúa cada lectura
  cruda del acelerómetro (con gravedad, no el "user accelerometer" virtual
  de Android — ver `docs/accident_detection.md` para el porqué) contra un
  umbral configurable; el giroscopio no filtra el disparo, solo ajusta la
  `confidenceScore`. Un candidato dispara una notificación persistente
  ("¿Estás bien?" + acción "Estoy bien") con un countdown de 20s: sin
  respuesta, se auto-confirma; con respuesta, se cancela. Hallazgo de esta
  fase, verificado en vivo con `adb emu sensor set` inyectando impactos
  reales: `flutter_local_notifications` reencamina el tap de una acción a
  través de la Activity principal de la app sin importar en qué engine se
  llamó `initialize()`, así que el registro original (solo en el engine de
  background) nunca recibía la respuesta — el fix registra un *segundo*
  manejador independiente en el engine de UI
  (`initializeAccidentAlertResponseHandling`, llamado desde `bootstrap()`)
  que cancela el candidato directo contra Supabase, sin tocar el estado en
  memoria del engine de background (la policy RLS hace inofensiva
  cualquier escritura tardía de ese lado). Deliberadamente **no** envía
  ninguna alerta a nadie todavía — eso es la Fase 8. Detalle completo en
  [docs/accident_detection.md](docs/accident_detection.md).
- **Despacho de Alertas** (`supabase/functions/dispatch-accident-alerts`):
  primer código server-side del proyecto, no Dart. Un trigger de Postgres
  (`dispatch_accident_alert_webhook`, en la migración
  `20260828000001_accident_alert_dispatch.sql`) reacciona a la transición
  `candidate → confirmed` de un `accident_event` y despacha, vía `pg_net`
  (asíncrono), a una Edge Function que corre con `service_role`: resuelve
  compañeros de sesión activos (push a `device_push_tokens`, con SMS al
  `phone` del perfil como respaldo si no tienen token) y los
  `emergency_contacts` del rider (respetando `notify_push`/`notify_sms` por
  contacto), escribe una fila en `alerts` por cada intento, y mueve el
  evento a `notified`. **WhatsApp** es un tercer canal, independiente de
  push/SMS (se intenta además, no en su lugar): a diferencia de SMS, un
  mensaje de WhatsApp iniciado por el negocio tiene que usar una plantilla
  pre-aprobada por Meta (no texto libre) y el destinatario tiene que haber
  dado consentimiento explícito — por eso `emergency_contacts.notify_whatsapp`
  y `profiles.whatsapp_alerts_opt_in` (migración
  `20260829000001_whatsapp_alerts.sql`) son columnas propias, nunca
  inferidas de `notify_push`/`notify_sms`. El trigger se autentica ante la
  función con un secreto compartido leído de Supabase Vault en cada
  llamada — no con la función incorporada de Supabase para esto
  (`supabase_functions.http_request()`), porque esa solo acepta headers
  literales fijos en la migración, lo que habría significado versionar el
  secreto en git. Verificado en vivo contra el stack local (el trigger
  dispara solo al hacer `UPDATE ... SET status='confirmed'` en `psql`, sin
  invocar nada manualmente) con los fixtures de `seed.sql`, incluyendo un
  compañero de sesión que recibe push **y** WhatsApp a la vez; sin
  credenciales reales de FCM/Twilio/Meta en este entorno, el envío real
  degrada a un intento registrado como `status='failed'` en vez de fallar
  en silencio (mismo patrón que `MotionTracker.isAvailable()` en la Fase
  7). Detalle completo, incluida la lista honesta de qué se verificó en
  vivo y qué no, en [docs/alerts.md](docs/alerts.md).
- **Consentimiento de WhatsApp + registro de `device_push_tokens`**
  (deuda de Fase 8 cerrada): `profile` y `emergency_contacts` ahora exponen
  el switch de `whatsapp_alerts_opt_in`/`notify_whatsapp` — mismo flujo de
  guardado que sus demás campos, sin controller/página nuevos. Aparte,
  `lib/features/push_tokens/` registra el token de este dispositivo en
  `device_push_tokens` en cuanto cambia la sesión (`PushTokenRegistrar`,
  dominio puro, testeado con fakes) o el proveedor lo rota
  (`PushTokenSource.onTokenRefresh`), y se mantiene vivo por Riverpod desde
  `SentinelApp` (`ref.watch(pushTokenRegistrationProvider)`) igual que
  `goRouterProvider`. La única pieza que **no** es real todavía es de dónde
  sale el token: `UnavailablePushTokenSource` (la única implementación de
  `PushTokenSource` hoy) nunca produce uno, a propósito — cablear
  `firebase_messaging` de verdad exige el `google-services.json` de un
  proyecto Firebase real; sin él, el plugin Gradle
  `com.google.gms.google-services` rompe el build de Android para todo el
  repo, no solo esta función. Mismo proyecto Firebase pendiente que arriba.
  Detalle en [docs/alerts.md](docs/alerts.md).
- **Historial + estadísticas básicas** (`RideHistoryEntry`,
  `RideStatistics`/`RideStatisticsCalculator`): `RideSessionRepository`
  (Fase 4) gana `fetchHistory`, resuelto con un único `select` de
  PostgREST que embebe `ride_sessions` dentro de `ride_session_members` y
  `ride_groups` dentro de `ride_sessions` — hay FK real en toda la cadena,
  a diferencia de `fetchMembers`/`fetchParticipants` (que arman su
  resultado en Dart con dos consultas porque ahí no la hay). Filtrar a
  solo sesiones `finished` y ordenar por fecha se hace en Dart, no en la
  query. `AccidentEventRepository` (Fase 7) gana `fetchMine`/`fetchById` —
  y, por ser la primera vez que algo dentro del árbol de widgets lo
  necesita, su primer provider de Riverpod
  (`accident_event_providers.dart`; antes solo se instanciaba a mano en el
  engine de background y el handler de notificaciones). Las estadísticas
  se calculan en el cliente a partir de las listas que las otras dos
  pestañas ya cargan (`RideStatisticsCalculator`, lógica pura y testeada,
  sin RPC nueva). `HistoryPage` (`/history`, tabs Viajes/Accidentes/
  Estadísticas) y `AccidentDetailPage` (`/accidents/:id`) reemplazan los
  `PlaceholderPage` que esas rutas tenían reservados desde el inicio.
  Verificado en vivo el embed anidado contra Supabase local (no solo con
  fakes). Detalle completo, incluida la deuda técnica de esta fase, en
  [docs/history.md](docs/history.md).
- **Dashboard responsive de Web** (`AdaptiveShell`, `ResponsiveContent`):
  un único punto de ramificación por plataforma
  (`if (PlatformCapabilities.isWeb)` en `app/router.dart`) decide si las
  cinco pantallas "hub" (Inicio/Grupos/Vehículos/Contactos/Historial) se
  envuelven en un `ShellRoute` con `AdaptiveShell`, que agrega un
  `NavigationRail` persistente una vez que el viewport supera los 840px —
  cada página sigue siendo dueña de su propio `Scaffold`/`AppBar` tal cual
  ya era; el shell solo le pone al lado la navegación lateral. Nada de esto
  se construye en Android ni bajo `flutter test` (que corre como Android
  por defecto — ver docs/architecture.md), así que el flujo de navegación
  ya probado para motociclistas queda intacto byte a byte.
  `ResponsiveContent` (`shared/widgets/`) es el segundo elemento de esta
  fase, ortogonal al shell: le pone un ancho máximo centrado al contenido
  de listas (Grupos/Vehículos/Contactos/Historial) para que no se estire
  borde a borde en una ventana ancha — un `MediaQuery` puro, sin preguntar
  plataforma, así que también es un no-op idéntico al layout anterior por
  debajo de su umbral. Verificado con `flutter build web` real, no solo
  `flutter analyze`.
- **Ajustes de UI post-Fase 10** (tema + navegación móvil, a pedido del
  usuario): el tema (`core/theme/app_theme.dart`) generaba su paleta con
  `ColorScheme.fromSeed` puro sobre el azul `0xFF1B6FD1` — modo claro con
  `surface` casi blanco (HSL L≈0.99) y modo oscuro casi negro (L≈0.08).
  `_softenSurfaces` desplaza los ocho tonos `surface*` la misma magnitud
  (0.09) en direcciones opuestas según el brillo, preservando el
  espaciado tonal entre ellos — `primary`/`secondary`/`tertiary`/`error`
  quedan intactos, así que el azul sigue siendo exactamente el mismo.
  Aparte, `app/app_drawer.dart` reemplaza la flecha de "atrás" por un
  menú hamburguesa en las cinco pantallas hub en layouts angostos
  (`Scaffold(drawer: showsHubRail(context) ? null : const AppDrawer())`)
  — un `Scaffold` con `drawer` no nulo siempre le pone el ícono de menú a
  su `AppBar` en vez de una flecha de volver, sin importar si la ruta
  podía hacer pop (confirmado leyendo `_AppBarState.build` del propio
  framework, no adivinado). De paso quedó al descubierto y arreglado un
  bug real preexistente: nada observaba `authControllerProvider`, así que
  `signOut()` podía autodesecharse a mitad del `await` y lanzar — ver
  "Trampa conocida de Riverpod 3" en `docs/architecture.md`.

Estado: `flutter_riverpod` + `riverpod_generator` (proveedores con
`@riverpod`/`@Riverpod(keepAlive: true)`). Navegación: `go_router`. Modelos
inmutables con `freezed`/`json_serializable` donde aportan valor real
(`AppUser`, `Profile`, `Vehicle`, `EmergencyContact`, `RideGroup`,
`RideSession`) — nota: con freezed 3.x, `@JsonSerializable(...)` para
configurar el mapeo JSON (p. ej. `fieldRename: FieldRename.snake`) va sobre
el `const factory`, no sobre la clase (ver cualquiera de estas entidades).
Cuidado adicional: no nombrar un provider `group` (ni `test`, `setUp`,
`expect`...) — colisiona con las exportaciones top-level de
`package:flutter_test` en cualquier archivo de test que importe ambos (de
ahí `groupDetailProvider`, no `groupProvider`).

## 10. Base de datos (esquema)

Documentación completa, con diagrama ER en Mermaid, en
[docs/database.md](docs/database.md). Resumen:

**Tablas** (12, todas con RLS habilitado): `profiles` (1:1 con
`auth.users`), `vehicles`, `emergency_contacts`, `ride_groups` +
`ride_group_members`, `ride_sessions` + `ride_session_members`,
`live_locations` + `location_history`, `accident_events`,
`device_push_tokens`, `alerts`.

**Relaciones clave**: un grupo (`ride_groups`) tiene muchos miembros
(`ride_group_members`, PK compuesta `group_id+user_id` — evita
duplicados) y muchas sesiones de viaje (`ride_sessions`); una sesión tiene
muchos participantes (`ride_session_members`) y exactamente una posición
actual por participante (`live_locations`, PK compuesta
`session_id+user_id`) además de su historial (`location_history`); un
`accident_event` puede generar varios `alerts`.

**RLS**: mínimo privilegio en todas las tablas — nunca `using (true)` para
datos privados. Ejemplos: un usuario solo edita su propio perfil/vehículo/
contacto/ubicación; un miembro de grupo/sesión solo ve lo de su
grupo/sesión; `alerts` no tiene ninguna policy (solo accesible vía
`service_role`/Edge Function). Detalle tabla por tabla en
[docs/database.md](docs/database.md#row-level-security).

**RPC atómicas** (`SECURITY DEFINER`, identidad siempre desde `auth.uid()`):
`create_ride_group`, `join_group_by_code`, `leave_group`,
`start_ride_session`, `finish_ride_session`.

**Realtime**: habilitado solo en `live_locations`, `ride_group_members`,
`ride_sessions`, `accident_events`. Canal privado por viaje
(`ride:<session_id>`) autorizado vía RLS sobre `realtime.messages`
(Realtime Authorization) — el cliente debe abrirlo con `private: true`.

## 11. Convenciones

- Imports absolutos con `package:sentinel_v2/...` está permitido pero dentro
  de `lib/` se usan imports relativos entre archivos de la propia app.
- No se agregan carpetas (`groups/`, `rides/`, `sensors/`, …) hasta que
  exista código real para ellas — evitar sobreingeniería.
- Código Android-only vive detrás de una interfaz/adapter y se guarda con
  `PlatformCapabilities.requireAndroid(...)`.
- `analysis_options.yaml` activa `strict-casts`, `strict-inference`,
  `strict-raw-types` y un set de lints adicional sobre `flutter_lints`.
- Cada feature con lógica de negocio no trivial debe tener al menos un test
  (unitario para repository/controller, widget para páginas).
- Principios de seguridad/privacidad válidos para toda fase futura (mínimo
  privilegio, sin `service_role` en Flutter, mínima recopilación de datos,
  consentimiento explícito de ubicación, etc.) están centralizados en
  [docs/security.md](docs/security.md) — no se re-derivan por módulo.

## Próximo módulo recomendado

Fases 1 (Auth + Profile), 2 (Emergency Contacts + Vehicles), 3 (Ride
Groups), 4 (Ride Sessions), 5 (Realtime Location + Map), 6 (Android
Background Service), 7 (Detección de Accidentes —
[docs/accident_detection.md](docs/accident_detection.md)) y 8 (Despacho de
Alertas: trigger de Postgres + Edge Function `service_role`, resolución de
compañeros de sesión/`emergency_contacts`, registro en `alerts`, UI de
consentimiento de WhatsApp y registro de `device_push_tokens` —
[docs/alerts.md](docs/alerts.md)) están completas. El bucle de seguridad
central del producto (login → grupo → viaje → ubicación en vivo →
detección → alerta) está cerrado de punta a punta, incluido todo lo que se
puede construir sin credenciales externas reales.

Lo único que queda pendiente **dentro** de la Fase 8 ya no es código, sino
**configuración externa**: un proyecto Firebase real
(`FCM_SERVICE_ACCOUNT_JSON`, también necesario para que
`PushTokenSource`/`firebase_messaging` produzcan un token real — ver
`lib/features/push_tokens/`), una cuenta Twilio (`TWILIO_*`) y una app de
Meta Developer con WhatsApp configurado (`META_WHATSAPP_*`, incluida la
plantilla `accident_alert` aprobada) — ninguno de los tres existe en este
entorno de desarrollo.

**Fase 9 (Ride history / Accident history / Basic statistics) también está
completa** — `HistoryPage`/`AccidentDetailPage`, `fetchHistory` en
`RideSessionRepository`, `fetchMine`/`fetchById` en
`AccidentEventRepository`, `RideStatisticsCalculator`. Detalle completo,
incluida su propia deuda técnica, en [docs/history.md](docs/history.md).

**Fase 10 (Responsive Web dashboard) también está completa** —
`AdaptiveShell` (`NavigationRail` persistente, Web-only, un único
`if (PlatformCapabilities.isWeb)` en `app/router.dart`) y
`ResponsiveContent` (ancho máximo centrado, cualquier plataforma) sobre las
cinco pantallas hub. Detalle completo, incluida su deuda técnica, en
[docs/web_dashboard.md](docs/web_dashboard.md).

**Las diez fases del alcance original del prompt maestro están completas.**
El bucle de seguridad central (login → grupo → viaje → ubicación en vivo →
detección → alerta) funciona de punta a punta, con historial/estadísticas
y un dashboard Web responsive encima. Lo que queda no es una fase nueva de
producto, sino trabajo acumulado de configuración externa y hardening:

- **Configuración externa pendiente de la Fase 8**: proyecto Firebase real
  (`FCM_SERVICE_ACCOUNT_JSON`, también necesario para que
  `PushTokenSource`/`firebase_messaging` produzcan un token real), cuenta
  Twilio (`TWILIO_*`), app de Meta Developer con WhatsApp
  (`META_WHATSAPP_*`, plantilla `accident_alert` aprobada) — ninguno de
  los tres existe en este entorno de desarrollo. Sin esto, el pipeline de
  alertas es real pero nunca entrega de verdad. Ver `docs/alerts.md`.
- **Hardening operativo**: retención/purga de `location_history` y
  `alerts` (`TODO(retention)` pendiente desde la Fase 5), y un proceso que
  detecte y resuelva `accident_events` huérfanos en `candidate` demasiado
  tiempo (el hueco de `RideBackgroundService` documentado en
  `docs/accident_detection.md`) — natural ahora que existe una Edge
  Function corriendo con `service_role`.
- **Detalle de viaje finalizado con roster histórico** — ver deuda técnica
  en [docs/history.md](docs/history.md).
- **Layout maestro-detalle real para el dashboard Web** (más allá del
  ancho centrado actual) y **vista de administración de grupo** pensada
  para pantalla ancha — ver deuda técnica en
  [docs/web_dashboard.md](docs/web_dashboard.md).
- **`AccidentDetailPage` sin link a un mapa externo** (`url_launcher`) —
  ver deuda técnica en [docs/history.md](docs/history.md).
- Transferencia de ownership de un `ride_group` (el owner no puede
  abandonar ni ser reemplazado por RPC hoy — ver `docs/database.md`).
