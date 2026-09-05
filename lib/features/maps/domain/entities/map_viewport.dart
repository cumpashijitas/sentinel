import 'package:freezed_annotation/freezed_annotation.dart';

import 'map_coordinate.dart';

part 'map_viewport.freezed.dart';

/// The map camera's state — used both to set an initial view and to
/// describe where [MapController.moveCamera] should animate to. Mirrors
/// `maplibre_gl`'s `CameraPosition` in shape (so `MapLibreMapService`'s
/// conversion is a straight field copy), without exposing that type to
/// callers.
@freezed
abstract class MapViewport with _$MapViewport {
  const factory MapViewport({
    required MapCoordinate center,
    required double zoom,

    /// Degrees clockwise from north — 0 is "north up". Non-zero when the
    /// camera is following a moving rider's heading.
    @Default(0) double bearing,

    /// Camera pitch in degrees, 0 = straight down.
    @Default(0) double tilt,
  }) = _MapViewport;
}
