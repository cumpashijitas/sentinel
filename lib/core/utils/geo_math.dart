import 'dart:math' as math;

/// Small, dependency-free geodesic helpers. Kept separate from any
/// location/tracking feature so it can be reused (accident detection,
/// straggler detection, future route logic) without pulling in Supabase or
/// `geolocator`.
abstract final class GeoMath {
  static const _earthRadiusMeters = 6371000.0;

  /// Great-circle distance between two coordinates, in meters (haversine
  /// formula). Accurate enough for "how far is this rider from the group"
  /// at the scale a motorcycle ride operates on — not for surveying.
  static double distanceMeters({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final dLat = _degToRad(toLat - fromLat);
    final dLng = _degToRad(toLng - fromLng);
    final lat1 = _degToRad(fromLat);
    final lat2 = _degToRad(toLat);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) *
            math.sin(dLng / 2) *
            math.cos(lat1) *
            math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  /// The centroid (simple average) of a set of coordinates. Good enough as
  /// a stand-in for "where the group is" at city/road scale; does not
  /// correct for antimeridian wraparound.
  static (double lat, double lng) centroid(
    Iterable<(double lat, double lng)> points,
  ) {
    if (points.isEmpty) {
      throw ArgumentError('centroid() requires at least one point');
    }
    var latSum = 0.0;
    var lngSum = 0.0;
    var count = 0;
    for (final (lat, lng) in points) {
      latSum += lat;
      lngSum += lng;
      count++;
    }
    return (latSum / count, lngSum / count);
  }

  static double _degToRad(double deg) => deg * (math.pi / 180);
}
