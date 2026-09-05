import 'package:freezed_annotation/freezed_annotation.dart';

import 'map_coordinate.dart';

part 'map_route.freezed.dart';

/// A polyline drawn on the map — e.g. the group's traveled path, or a
/// planned route. Points are ordered start-to-end.
@freezed
abstract class MapRoute with _$MapRoute {
  const factory MapRoute({
    required String id,
    required List<MapCoordinate> points,
  }) = _MapRoute;
}
