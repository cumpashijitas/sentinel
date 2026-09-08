import '../entities/map_coordinate.dart';
import '../entities/map_marker.dart';
import '../entities/map_route.dart';
import '../entities/map_viewport.dart';

/// Drives an already-created map — the domain-facing counterpart of
/// `maplibre_gl`'s `MapLibreMapController`, without exposing that type
/// (or any engine type) to callers. Obtained via the `onMapReady`
/// callback passed to [MapService.buildMap].
///
/// [setMarkers] and [setRoute] are the only mutation points a caller
/// needs — implementations decide *how* to apply a diff efficiently
/// (update an existing annotation/feature in place, add only what's new,
/// remove only what's gone) instead of tearing down and rebuilding
/// everything on every call. See `MapLibreMapService`'s doc comment for
/// the specific strategy at this feature's current scale (a group's
/// handful to few dozen members) and the documented upgrade path
/// (a single GeoJSON source + `setFeatureState`) if that ever stops being
/// enough.
abstract interface class MapController {
  /// Reconciles the map's markers to exactly [markers] — adds new ones
  /// (by [MapMarker.id]), updates changed ones in place, and removes ones
  /// no longer present. Safe to call every time the roster changes,
  /// including with an unchanged list (a no-op diff).
  Future<void> setMarkers(List<MapMarker> markers);

  /// Draws (or replaces, or clears with `null`) a single named route —
  /// this feature only ever needs one polyline on screen at a time (the
  /// group's own path), not a general multi-route API.
  Future<void> setRoute(MapRoute? route);

  /// Moves the camera to [viewport]. Animated by default — pass
  /// `animate: false` for an instant jump (e.g. the very first frame).
  Future<void> moveCamera(MapViewport viewport, {bool animate = true});

  /// Convenience over [moveCamera] for "center on this one point",
  /// keeping the current zoom unless [zoom] is given.
  Future<void> centerOnCoordinate(MapCoordinate coordinate, {double? zoom});

  /// Moves/zooms the camera so every coordinate in [coordinates] is
  /// visible — "centrar en grupo". No-ops on an empty list.
  Future<void> fitBounds(
    List<MapCoordinate> coordinates, {
    double paddingPixels = 48,
  });

  /// Releases whatever native resources this controller holds. Call once,
  /// when the screen showing the map is disposed.
  void dispose();
}
