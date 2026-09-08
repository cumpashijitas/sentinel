import 'package:freezed_annotation/freezed_annotation.dart';

import 'map_coordinate.dart';

part 'map_marker.freezed.dart';

/// What kind of point this marker represents — decides which icon
/// `MapLibreMapService` picks, independent of [MapMarkerStatus] (which
/// only applies to [member]/[currentUser]).
enum MapMarkerCategory {
  /// The signed-in rider's own position.
  currentUser,

  /// A fellow ride participant's position.
  member,

  /// Where the ride started.
  routeStart,

  /// The ride's planned destination, if one is set.
  routeDestination,

  /// A confirmed `accident_events` location (Fase 7/8).
  accidentSite,
}

/// Only meaningful when [MapMarker.category] is [MapMarkerCategory.member]
/// or [MapMarkerCategory.currentUser] — picks the marker's color.
///
/// Deliberately **not** the same type as `rides`' own
/// `MemberTrackingStatus`: `features/maps/domain/` must not import another
/// feature's domain (see docs/architecture.md, "la capa de dominio de una
/// feature nunca importa otra feature") — `rides`' presentation layer maps
/// `MemberTrackingStatus` → [MapMarkerStatus] when it builds the marker
/// list, keeping this feature generic and reusable on its own.
enum MapMarkerStatus { normal, stale, offline, lagging, sos, incident }

/// One point Sentinel wants drawn on the map — the domain-level
/// equivalent of a `flutter_map` `Marker`, but not tied to it.
@freezed
abstract class MapMarker with _$MapMarker {
  const factory MapMarker({
    /// Stable across updates — a member's is their `userId`; route
    /// start/destination/accident markers use a fixed constant id.
    /// `MapController.setMarkers` uses this to decide "update in place"
    /// vs. "add"/"remove" rather than tearing down every marker each call.
    required String id,
    required MapCoordinate coordinate,
    required MapMarkerCategory category,
    MapMarkerStatus? status,
    String? label,

    /// Degrees, 0-360, or `null` if unknown — rotates the marker icon to
    /// face the direction of travel.
    double? headingDegrees,

    /// km/h, or `null` if unknown/not shown for this marker.
    double? speedKmh,
  }) = _MapMarker;
}
