import '../../../maps/domain/entities/map_coordinate.dart';
import '../../../maps/domain/entities/map_marker.dart';
import '../../domain/entities/member_location.dart';

/// Turns a roster of [MemberLocation] into [MapMarker]s — the `rides`
/// feature's half of the seam with `features/maps/` (the mapping itself
/// lives here, in `rides`' presentation layer, rather than in `maps`,
/// because `maps/domain` must never import another feature's domain; see
/// `MapMarkerStatus`'s doc comment).
///
/// [currentUserId] picks [MapMarkerCategory.currentUser] for that one
/// entry so `MapLibreMapService` can render it distinctly (a larger,
/// consistently-colored dot) — pass `null` if it isn't known yet.
List<MapMarker> buildMemberMapMarkers(
  List<MemberLocation> members, {
  required String? currentUserId,
}) {
  return [
    for (final member in members)
      if (member.fix != null)
        MapMarker(
          id: member.userId,
          coordinate: MapCoordinate(
            latitude: member.fix!.latitude,
            longitude: member.fix!.longitude,
          ),
          category: member.userId == currentUserId
              ? MapMarkerCategory.currentUser
              : MapMarkerCategory.member,
          status: _statusFor(member.status),
          label: member.displayName,
          headingDegrees: member.fix!.heading,
          speedKmh: member.fix!.speed == null
              ? null
              : member.fix!.speed! * 3.6, // m/s (GPS) -> km/h
        ),
  ];
}

MapMarkerStatus _statusFor(MemberTrackingStatus status) => switch (status) {
  MemberTrackingStatus.active => MapMarkerStatus.normal,
  MemberTrackingStatus.stale => MapMarkerStatus.stale,
  MemberTrackingStatus.offline => MapMarkerStatus.offline,
  MemberTrackingStatus.lagging => MapMarkerStatus.lagging,
  MemberTrackingStatus.possibleIncident => MapMarkerStatus.incident,
};

String memberStatusLabel(MemberTrackingStatus status) => switch (status) {
  MemberTrackingStatus.active => 'Activo',
  MemberTrackingStatus.stale => 'Señal débil',
  MemberTrackingStatus.lagging => 'Rezagado',
  MemberTrackingStatus.offline => 'Sin conexión',
  MemberTrackingStatus.possibleIncident => 'Posible incidente',
};
