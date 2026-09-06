import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;

import '../../domain/entities/map_coordinate.dart';
import '../../domain/entities/map_marker.dart';
import '../../domain/entities/map_route.dart';
import '../../domain/entities/map_tile_config.dart';
import '../../domain/entities/map_viewport.dart';
import '../../domain/repositories/map_controller.dart';
import '../../domain/repositories/map_service.dart';

/// [MapService] backed by `maplibre_gl` — the only file in this feature
/// (besides its own test) allowed to import that package. Fase B/C: online
/// only, no offline region support yet (Fase D).
///
/// Markers render as [maplibre.Circle]s, not [maplibre.Symbol]s: a
/// `Symbol`'s icon must be a registered image
/// (`MapLibreMapController.addImage`), which means bundling actual marker
/// PNG/SVG assets — nothing this session can produce. A `Circle` is styled
/// entirely through style properties (`circleColor`/`circleRadius`/
/// `circleStrokeColor`), no image asset needed, which is enough to satisfy
/// "marcadores diferenciados por estado" (color-coded by
/// [MapMarkerStatus]/[MapMarkerCategory]). What this honestly does **not**
/// do yet: rotate a directional arrow to show [MapMarker.headingDegrees] —
/// that needs a real icon asset and a `Symbol` layer. The heading value is
/// still carried through in each circle's `data` payload so a future
/// icon-based upgrade (or a tap-to-see-detail sheet) has it available
/// without re-plumbing anything.
class MapLibreMapService implements MapService {
  @override
  Widget buildMap({
    required MapTileConfig tileConfig,
    required MapViewport initialViewport,
    required ValueChanged<MapController> onMapReady,
  }) {
    return _MapLibreMapWidget(
      tileConfig: tileConfig,
      initialViewport: initialViewport,
      onMapReady: onMapReady,
    );
  }
}

class _MapLibreMapWidget extends StatefulWidget {
  const _MapLibreMapWidget({
    required this.tileConfig,
    required this.initialViewport,
    required this.onMapReady,
  });

  final MapTileConfig tileConfig;
  final MapViewport initialViewport;
  final ValueChanged<MapController> onMapReady;

  @override
  State<_MapLibreMapWidget> createState() => _MapLibreMapWidgetState();
}

class _MapLibreMapWidgetState extends State<_MapLibreMapWidget> {
  maplibre.MapLibreMapController? _rawController;
  _MapLibreController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        maplibre.MapLibreMap(
          styleString: widget.tileConfig.styleUrl,
          initialCameraPosition: _toCameraPosition(widget.initialViewport),
          // Default is already false — left unset rather than passed
          // explicitly. Sentinel's own "current user" marker (via
          // MapMarker/setMarkers) is the current-position indicator; the
          // engine's built-in location puck would be a second, redundant
          // one, driven by its own GPS subscription instead of
          // LocationRepository's.
          onMapCreated: (controller) => _rawController = controller,
          // Annotations must only be added once the style has finished
          // loading (see MapController's doc comment) — this is that
          // signal, not onMapCreated.
          onStyleLoadedCallback: () {
            final raw = _rawController;
            if (raw == null) return;
            final controller = _MapLibreController(raw);
            _controller = controller;
            widget.onMapReady(controller);
          },
        ),
        Positioned(
          left: 4,
          bottom: 4,
          child: _AttributionLabel(text: widget.tileConfig.attribution),
        ),
      ],
    );
  }
}

/// Explicit, always-visible attribution text — belt-and-suspenders
/// alongside whatever built-in attribution control the style/engine
/// itself renders (see docs/maps.md: "mostrar siempre atribución
/// requerida" is a hard requirement, not a nice-to-have).
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

maplibre.CameraPosition _toCameraPosition(MapViewport viewport) {
  return maplibre.CameraPosition(
    target: _toLatLng(viewport.center),
    zoom: viewport.zoom,
    bearing: viewport.bearing,
    tilt: viewport.tilt,
  );
}

maplibre.LatLng _toLatLng(MapCoordinate coordinate) {
  return maplibre.LatLng(coordinate.latitude, coordinate.longitude);
}

Color _colorForMarker(MapMarker marker) {
  if (marker.category == MapMarkerCategory.routeStart) return Colors.blue;
  if (marker.category == MapMarkerCategory.routeDestination)
    return Colors.purple;
  if (marker.category == MapMarkerCategory.accidentSite) return Colors.red;

  return switch (marker.status) {
    MapMarkerStatus.sos || MapMarkerStatus.incident => Colors.red,
    MapMarkerStatus.lagging => Colors.orange,
    MapMarkerStatus.stale => Colors.yellow,
    MapMarkerStatus.offline => Colors.blueGrey,
    MapMarkerStatus.normal || null => Colors.green,
  };
}

class _MapLibreController implements MapController {
  _MapLibreController(this._raw);

  final maplibre.MapLibreMapController _raw;

  /// Last marker actually pushed to the engine, per id — lets
  /// [setMarkers] skip an `updateCircle` call when nothing about a
  /// marker changed (`MapMarker` is a `freezed` value type, so `==`
  /// compares fields, not identity).
  final Map<String, MapMarker> _lastMarkers = {};
  final Map<String, maplibre.Circle> _circles = {};
  maplibre.Line? _line;

  @override
  Future<void> setMarkers(List<MapMarker> markers) async {
    final incomingIds = markers.map((m) => m.id).toSet();

    for (final staleId in _circles.keys.toSet().difference(incomingIds)) {
      final circle = _circles.remove(staleId);
      _lastMarkers.remove(staleId);
      if (circle != null) await _raw.removeCircle(circle);
    }

    for (final marker in markers) {
      if (_lastMarkers[marker.id] == marker) continue;

      final existing = _circles[marker.id];
      if (existing == null) {
        _circles[marker.id] = await _raw.addCircle(
          maplibre.CircleOptions(
            geometry: _toLatLng(marker.coordinate),
            circleColor: _colorHex(_colorForMarker(marker)),
            circleRadius: marker.category == MapMarkerCategory.currentUser
                ? 9
                : 7,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2,
          ),
          {
            'markerId': marker.id,
            'category': marker.category.name,
            if (marker.status != null) 'status': marker.status!.name,
            if (marker.label != null) 'label': marker.label,
            if (marker.headingDegrees != null)
              'headingDegrees': marker.headingDegrees,
            if (marker.speedKmh != null) 'speedKmh': marker.speedKmh,
          },
        );
      } else {
        await _raw.updateCircle(
          existing,
          maplibre.CircleOptions(
            geometry: _toLatLng(marker.coordinate),
            circleColor: _colorHex(_colorForMarker(marker)),
          ),
        );
      }
      _lastMarkers[marker.id] = marker;
    }
  }

  @override
  Future<void> setRoute(MapRoute? route) async {
    final current = _line;
    if (route == null) {
      if (current != null) {
        await _raw.removeLine(current);
        _line = null;
      }
      return;
    }

    final geometry = route.points.map(_toLatLng).toList(growable: false);
    if (current == null) {
      _line = await _raw.addLine(
        maplibre.LineOptions(
          geometry: geometry,
          lineColor: '#1B6FD1',
          lineWidth: 4,
        ),
      );
    } else {
      await _raw.updateLine(current, maplibre.LineOptions(geometry: geometry));
    }
  }

  @override
  Future<void> moveCamera(MapViewport viewport, {bool animate = true}) async {
    final update = maplibre.CameraUpdate.newCameraPosition(
      _toCameraPosition(viewport),
    );
    if (animate) {
      await _raw.animateCamera(update);
    } else {
      await _raw.moveCamera(update);
    }
  }

  @override
  Future<void> centerOnCoordinate(
    MapCoordinate coordinate, {
    double? zoom,
  }) async {
    final update = zoom == null
        ? maplibre.CameraUpdate.newLatLng(_toLatLng(coordinate))
        : maplibre.CameraUpdate.newLatLngZoom(_toLatLng(coordinate), zoom);
    await _raw.animateCamera(update);
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

    var minLat = coordinates.first.latitude;
    var maxLat = coordinates.first.latitude;
    var minLng = coordinates.first.longitude;
    var maxLng = coordinates.first.longitude;
    for (final coordinate in coordinates.skip(1)) {
      minLat = coordinate.latitude < minLat ? coordinate.latitude : minLat;
      maxLat = coordinate.latitude > maxLat ? coordinate.latitude : maxLat;
      minLng = coordinate.longitude < minLng ? coordinate.longitude : minLng;
      maxLng = coordinate.longitude > maxLng ? coordinate.longitude : maxLng;
    }

    final bounds = maplibre.LatLngBounds(
      southwest: maplibre.LatLng(minLat, minLng),
      northeast: maplibre.LatLng(maxLat, maxLng),
    );
    await _raw.animateCamera(
      maplibre.CameraUpdate.newLatLngBounds(
        bounds,
        left: paddingPixels,
        top: paddingPixels,
        right: paddingPixels,
        bottom: paddingPixels,
      ),
    );
  }

  @override
  void dispose() {
    _circles.clear();
    _lastMarkers.clear();
    _line = null;
  }

  static String _colorHex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
