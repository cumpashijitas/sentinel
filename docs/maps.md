# Sentinel V2 — mapas (Fase B/C de la migración "realtime-v2")

Reemplaza `google_maps_flutter` por MapLibre detrás de una abstracción
propia, para: (1) no acoplar Sentinel a un proveedor de mapas específico,
y (2) poder agregar mapas offline (Fase D) sin depender de un SDK que no
lo soporte. Ver [docs/realtime-v2-migration.md](realtime-v2-migration.md)
para el resto de la migración (MQTT, PostGIS, backend).

## Qué NO es esta fase

No implementa mapas offline todavía (Fase D). No toca `accident_detection`
ni `alerts`. No retira `google_maps_flutter` de `pubspec.yaml` — sigue
compilando hasta que MapLibre esté validado en Android y Web y se apruebe
explícitamente reemplazarlo (ver "Estrategia de retiro" abajo).

## Por qué MapLibre, y qué versión

`maplibre_gl: ^0.27.0` — versión estable verificada en pub.dev el
2026-09-04 (no un número inventado), requiere Dart ≥3.7/Flutter ≥3.29;
este proyecto usa Dart 3.13.1/Flutter 3.47.1, cómodamente por encima del
mínimo. Motor open-source, sin API key, con soporte nativo Android y Web
(vía `maplibre-gl-js` embebido).

## `MapService` — la abstracción

```
features/maps/
  domain/
    entities/       MapCoordinate, MapMarker, MapRoute, MapViewport, MapTileConfig
    repositories/    MapService, MapController
  data/
    datasources/     MapLibreMapService (única implementación; único archivo
                      del feature que importa maplibre_gl)
  presentation/
    controllers/     map_providers.dart (Riverpod)
```

Ninguna pantalla importa `maplibre_gl` directamente — `RideMapPage` llama
`MapService.buildMap(...)` y recibe un `MapController` vía `onMapReady`,
exactamente como antes recibía un `GoogleMapController` implícito a través
del widget `GoogleMap`. El día que exista un segundo motor (o un modo
mock para tests), es una segunda implementación de `MapService`, no un
cambio en ninguna pantalla.

`MapMarkerStatus` es un enum propio de `maps/`, **no** el
`MemberTrackingStatus` de `rides/` — la capa de dominio de una feature
nunca importa el dominio de otra (ver `docs/architecture.md`). El mapeo
`MemberTrackingStatus → MapMarkerStatus` vive en
`rides/presentation/utils/member_map_markers.dart`, el mismo lugar donde
antes vivía el mapeo a `google_maps_flutter`'s `Marker`.

## Por qué `Circle`, no `Symbol`

`maplibre_gl` puede renderizar marcadores como `Symbol` (un ícono
registrado vía `addImage`) o como `Circle` (coloreado por propiedades de
estilo, sin ningún asset). Esta fase usa `Circle` deliberadamente: no hay
manera de generar/bundlear assets de íconos reales en este entorno de
desarrollo, y un círculo coloreado por `MapMarkerStatus` ya satisface el
requisito central ("marcadores diferenciados por estado"). **Limitación
honesta**: no hay flecha de heading rotada — `MapMarker.headingDegrees` se
sigue capturando y viaja en el `data` payload de cada círculo, listo para
un futuro upgrade a `Symbol` con un ícono direccional real, sin tener que
replumbing nada del lado del dominio.

## Rendimiento: por qué no se reconstruye el widget en cada fix de GPS

`RideMapPage`/`_RideMapBody` reciben un nuevo roster (`List<MemberLocation>`)
en cada tick de Supabase Realtime. `_RideMapBodyState` mantiene el
`MapController` en su propio estado (asignado una sola vez, en
`onMapReady`) y en `didUpdateWidget` llama
`controller.setMarkers(...)` — nunca reconstruye el widget `MapLibreMap`
en sí (Flutter reutiliza el mismo elemento/vista nativa mientras la
posición en el árbol y el tipo de widget no cambien, con o sin
`setState` en un ancestro). Dentro de `_MapLibreController.setMarkers`,
cada marcador se compara por valor (`MapMarker` es `freezed`, `==`
compara campos) contra el último valor efectivamente enviado al motor —
si no cambió nada, no se llama a `updateCircle` para ese marcador. Solo
se agregan los ids nuevos y se remueven los que ya no están.

**Camino de escalado documentado, no implementado todavía**: a la escala
actual (10-50 miembros por viaje, según el propio requisito de
rendimiento), diffear círculo por círculo es más que suficiente. Si un
despliegue futuro necesita cientos de marcadores simultáneos, `maplibre_gl`
expone `setGeoJsonSource`/`setFeatureState` — una sola fuente GeoJSON con
todo el roster como `FeatureCollection`, actualizada de una vez, y un
`SymbolLayer`/`CircleLayer` con una expresión de estilo data-driven sobre
la propiedad `status` — evitando N llamadas de plataforma por N
marcadores. No se implementó ahora por ser prematuro a esta escala.

## Fuente de mapa — `MapTileConfig`

```dart
class MapTileConfig {
  final String styleUrl;      // style.json — lo único que consume MapLibreMapService hoy
  final String? tilesUrl;     // reservado para un proveedor de tiles crudos (no usado aún)
  final String attribution;   // se muestra siempre, superpuesto al mapa
  final bool offlineAllowed;  // debe reflejar los términos reales del proveedor — nunca default true
  final String providerName;  // solo para logs/UI, nunca para lógica de rama
}
```

Construida en `core/config/app_config.dart` desde `--dart-define-from-file`
(`MAP_STYLE_URL`, `MAP_TILE_PROVIDER`, `MAP_OFFLINE_ENABLED`,
`MAP_ATTRIBUTION` — ver `config/dev.json.example`). Hoy, todo `config/*.json`
de desarrollo apunta al **demo style público de MapLibre**
(`https://demotiles.maplibre.org/style.json`) — gratuito, basado en OSM,
**explícitamente no apto para producción** (sin SLA) **ni para descarga
offline** (`MAP_OFFLINE_ENABLED=false`). `config/prod.json.example` deja
`MAP_STYLE_URL`/`MAP_TILE_PROVIDER` como placeholders — la Fase D no
puede avanzar hasta elegir (con el usuario) un proveedor real que declare
explícitamente permitir offline/prefetch. **Nunca** se usa
`tile.openstreetmap.org` para nada — ni siquiera online — precisamente
para no depender de un servidor cuya política de uso no cubre lo que esta
app necesita a futuro.

Atribución: el propio estilo/motor de MapLibre ya renderiza su control de
atribución por defecto; `MapLibreMapService` además superpone
`MapTileConfig.attribution` como texto explícito (`_AttributionLabel`,
esquina inferior izquierda) — "mostrar siempre atribución requerida" no
depende únicamente del comportamiento por defecto del motor.

## Qué implementa esta fase, del listado original

✅ Ubicación del usuario actual (marcador `currentUser`) · ✅ ubicación de
miembros · ✅ velocidad (convertida m/s→km/h) · ✅ marcadores
diferenciados por estado (`normal/stale/offline/lagging/sos/incident`) ·
✅ polylines (`MapRoute`/`setRoute`) · ✅ centrar en un punto
(`centerOnCoordinate`) · ✅ centrar en grupo (`fitBounds`) · ✅ cámara con
`moveCamera` animado o instantáneo.

❌ Orientación/heading visual (círculo no rota — ver arriba) · ❌ modo
"cámara sigue al conductor" automático (la primitiva `moveCamera` existe;
ninguna pantalla la dispara todavía en modo seguimiento continuo) · ❌
punto de inicio/destino/accidente en `RideMapPage` (categorías `routeStart`/
`routeDestination`/`accidentSite` ya existen en `MapMarker`; nadie las
construye desde datos reales todavía — falta conectar `RideSession`/
`AccidentEvent` a un `MapMarker`, análogo a lo que
`member_map_markers.dart` ya hace para miembros).

## Estrategia de retiro de `google_maps_flutter`

Sigue en `pubspec.yaml` y compilando (nada más lo usa: se confirmó por
auditoría que solo `RideMapPage` y el extinto `member_markers.dart` lo
importaban). Se retira en un commit propio, después de validar MapLibre en
vivo en Android y Web — no en esta misma fase, para poder revertir sin
pelear con dos cambios mezclados si algo no funciona como se espera.

## Deuda técnica

- Sin marcadores de inicio/destino/accidente conectados a datos reales
  todavía (ver arriba).
- Sin ícono direccional para heading (necesita assets + `Symbol`).
- Sin modo "cámara sigue al conductor" ni "modo libre" explícitos como
  toggle de UI — la primitiva de cámara ya existe, falta el control.
- `google_maps_flutter` todavía no retirado (intencional, ver arriba).
- No verificado en vivo en un dispositivo/navegador real en esta sesión —
  ver el reporte de la fase para el detalle exacto de qué se verificó
  (`flutter analyze`/`flutter test`) y qué no (render real).
