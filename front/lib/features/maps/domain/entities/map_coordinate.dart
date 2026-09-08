import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_coordinate.freezed.dart';

/// A plain lat/lng pair — this feature's own coordinate type, so nothing
/// outside `features/maps/` needs to import a map-engine package
/// (`flutter_map`/`latlong2`'s `LatLng`, ...) just to describe "a point on
/// Earth". `OsmMapService` is the only place that converts to/from the
/// engine's own `LatLng`.
@freezed
abstract class MapCoordinate with _$MapCoordinate {
  const factory MapCoordinate({
    required double latitude,
    required double longitude,
  }) = _MapCoordinate;
}
