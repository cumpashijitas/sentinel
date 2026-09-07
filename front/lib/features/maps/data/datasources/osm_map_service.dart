import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

import '../../domain/entities/map_coordinate.dart';
import '../../domain/entities/map_marker.dart';
import '../../domain/entities/map_route.dart';
import '../../domain/entities/map_tile_config.dart';
import '../../domain/entities/map_viewport.dart';
import '../../domain/repositories/map_controller.dart';
import '../../domain/repositories/map_service.dart';

/// [MapService] backed by `flutter_map`, con tiles directo de
/// `tile.openstreetmap.org` — el único archivo de esta feature (además de
/// su propio test) que puede importar `flutter_map`/`latlong2`.
///
/// Reemplaza a `MapLibreMapService` (ver historial de git) por dos
/// razones: es Dart puro — sin plugin nativo ni Gradle propio, esquiva por
/// completo la incompatibilidad de `maplibre_gl` con AGP 9 que bloqueaba
/// el build del APK — y `tile.openstreetmap.org` no tiene ningún nivel
/// pago que se pueda cruzar sin querer, a diferencia de Google Maps.
/// Cumple la política de uso de OSM
/// (https://operations.osmfoundation.org/policies/tiles/): User-Agent
/// propio vía `userAgentPackageName`, atribución siempre visible
/// (`_AttributionLabel`), y `MapTileConfig.offlineAllowed` sigue en
/// `false` por defecto — esa política prohíbe explícitamente el uso/
/// descarga offline de estos tiles.
///
/// Markers/ruta son widgets declarativos (`MarkerLayer`/`PolylineLayer`),
/// no llamadas imperativas a un controlador nativo como en MapLibre:
/// `setMarkers`/`setRoute` solo actualizan un `ValueNotifier` que el árbol
/// de widgets ya escucha — el diffing por-id que `MapLibreMapService`
/// necesitaba a mano (`addCircle`/`updateCircle`/`removeCircle`) lo hace
/// Flutter solo al reconstruir la lista.
class OsmMapService implements MapService {
  @override
  Widget buildMap({
    required MapTileConfig tileConfig,
    required MapViewport initialViewport,
    required ValueChanged<MapController> onMapReady,
  }) {
    return _OsmMapWidget(
      tileConfig: tileConfig,
      initialViewport: initialViewport,
      onMapReady: onMapReady,
    );
  }
}

class _OsmMapWidget extends StatefulWidget {
  const _OsmMapWidget({
    required this.tileConfig,
    required this.initialViewport,
    required this.onMapReady,
  });

  final MapTileConfig tileConfig;
  final MapViewport initialViewport;
  final ValueChanged<MapController> onMapReady;

  @override
  State<_OsmMapWidget> createState() => _OsmMapWidgetState();
}

class _OsmMapWidgetState extends State<_OsmMapWidget> {
  final _rawController = fm.MapController();
  final _markers = ValueNotifier<List<MapMarker>>(const []);
  final _route = ValueNotifier<MapRoute?>(null);

  @override
  void dispose() {
    // Este State es dueño del controlador crudo de flutter_map — su ciclo
    // de vida es el del widget, no el de `_OsmController` (el dominio),
    // que `RideMapPage` dispone por separado sin tocar esto.
    _rawController.dispose();
    _markers.dispose();
    _route.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        fm.FlutterMap(
          mapController: _rawController,
          options: fm.MapOptions(
            initialCenter: _toLatLng(widget.initialViewport.center),
            initialZoom: widget.initialViewport.zoom,
            initialRotation: widget.initialViewport.bearing,
            onMapReady: () {
              widget.onMapReady(
                _OsmController(_rawController, _markers, _route),
              );
            },
          ),
          children: [
            fm.TileLayer(
              urlTemplate: widget.tileConfig.tilesUrl,
              userAgentPackageName: 'com.sentinel.app',
            ),
            ValueListenableBuilder<MapRoute?>(
              valueListenable: _route,
              builder: (context, route, _) {
                if (route == null || route.points.isEmpty) {
                  return const SizedBox.shrink();
                }
                return fm.PolylineLayer(
                  polylines: [
                    fm.Polyline(
                      points: route.points
                          .map(_toLatLng)
                          .toList(growable: false),
                      color: const Color(0xFF1B6FD1),
                      strokeWidth: 4,
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<List<MapMarker>>(
              valueListenable: _markers,
              builder: (context, markers, _) {
                return fm.MarkerLayer(
                  markers: [
                    for (final marker in markers) _buildMarker(marker),
                  ],
                );
              },
            ),
          ],
        ),
        Positioned(
          left: 4,
          bottom: 4,
          child: _AttributionLabel(text: widget.tileConfig.attribution),
        ),
      ],
    );
  }

  fm.Marker _buildMarker(MapMarker marker) {
    final isSelf = marker.category == MapMarkerCategory.currentUser;
    final size = isSelf ? 22.0 : 18.0;
    return fm.Marker(
      key: ValueKey(marker.id),
      point: _toLatLng(marker.coordinate),
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _colorForMarker(marker),
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

/// Texto de atribución siempre visible — obligatorio por la política de
/// uso de tile.openstreetmap.org (ver docs/maps.md), nunca detrás de un
/// toggle ni fuera de pantalla.
class _AttributionLabel extends StatelessWidget {
  const _AttributionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      color: Colors.white.withValues(alpha: 0.7),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }
}

ll.LatLng _toLatLng(MapCoordinate coordinate) =>
    ll.LatLng(coordinate.latitude, coordinate.longitude);

Color _colorForMarker(MapMarker marker) {
  if (marker.category == MapMarkerCategory.routeStart) return Colors.blue;
  if (marker.category == MapMarkerCategory.routeDestination) {
    return Colors.purple;
  }
  if (marker.category == MapMarkerCategory.accidentSite) return Colors.red;

  return switch (marker.status) {
    MapMarkerStatus.sos || MapMarkerStatus.incident => Colors.red,
    MapMarkerStatus.lagging => Colors.orange,
    MapMarkerStatus.stale => Colors.yellow,
    MapMarkerStatus.offline => Colors.blueGrey,
    MapMarkerStatus.normal || null => Colors.green,
  };
}

class _OsmController implements MapController {
  _OsmController(this._raw, this._markers, this._route);

  final fm.MapController _raw;
  final ValueNotifier<List<MapMarker>> _markers;
  final ValueNotifier<MapRoute?> _route;

  @override
  Future<void> setMarkers(List<MapMarker> markers) async {
    _markers.value = markers;
  }

  @override
  Future<void> setRoute(MapRoute? route) async {
    _route.value = route;
  }

  @override
  Future<void> moveCamera(MapViewport viewport, {bool animate = true}) async {
    // El `MapController` base de flutter_map no anima — un salto directo
    // es una simplificación aceptable acá; si en la práctica se siente
    // brusco, el paquete comunitario `flutter_map_animations` es el
    // camino documentado para agregar animación después, sin cambiar esta
    // interfaz.
    _raw.move(_toLatLng(viewport.center), viewport.zoom);
  }

  @override
  Future<void> centerOnCoordinate(
    MapCoordinate coordinate, {
    double? zoom,
  }) async {
    _raw.move(_toLatLng(coordinate), zoom ?? _raw.camera.zoom);
  }

  @override
  Future<void> fitBounds(
    List<MapCoordinate> coordinates, {
    double paddingPixels = 48,
  }) async {
    if (coordinates.isEmpty) return;
    if (coordinates.length == 1) {
      await centerOnCoordinate(coordinates.single);
      return;
    }
    _raw.fitCamera(
      fm.CameraFit.bounds(
        bounds: fm.LatLngBounds.fromPoints(
          coordinates.map(_toLatLng).toList(growable: false),
        ),
        padding: EdgeInsets.all(paddingPixels),
      ),
    );
  }

  @override
  void dispose() {
    // Nada que liberar acá — el `fm.MapController` crudo lo dispone
    // `_OsmMapWidgetState`, dueño de su ciclo de vida real.
  }
}
