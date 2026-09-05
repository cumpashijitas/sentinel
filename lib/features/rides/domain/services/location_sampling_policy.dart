import '../../../../core/utils/geo_math.dart';
import '../entities/location_fix.dart';

/// Decides whether a new device fix is "different enough" from the last
/// one written to `location_history` to be worth a new row — time,
/// distance, or heading change, whichever comes first.
///
/// This governs `location_history` only. `live_locations` (the *current*
/// position) is a single upserted row per session+user, so every fix gets
/// pushed there regardless — see `LocationRepository`'s implementation.
/// `location_history` is an ever-growing append-only table, which is
/// exactly what this class exists to keep in check (see the `TODO
/// (retention)` note in `supabase/migrations/20260827210006_locations.sql`
/// for the other half of that story — purging old rows, not covered here).
class LocationSamplingPolicy {
  const LocationSamplingPolicy({
    this.minInterval = const Duration(seconds: 20),
    this.minDistanceMeters = 25,
    this.minHeadingChangeDegrees = 35,
  });

  final Duration minInterval;
  final double minDistanceMeters;
  final double minHeadingChangeDegrees;

  /// `true` on the very first fix ([lastRecorded] is `null`), or whenever
  /// [current] differs from [lastRecorded] by enough time, distance, or
  /// heading.
  bool shouldRecord({
    required LocationFix? lastRecorded,
    required LocationFix current,
  }) {
    final last = lastRecorded;
    if (last == null) return true;

    if (current.recordedAt.difference(last.recordedAt) >= minInterval) {
      return true;
    }

    final distance = GeoMath.distanceMeters(
      fromLat: last.latitude,
      fromLng: last.longitude,
      toLat: current.latitude,
      toLng: current.longitude,
    );
    if (distance >= minDistanceMeters) return true;

    final lastHeading = last.heading;
    final currentHeading = current.heading;
    if (lastHeading != null && currentHeading != null) {
      final delta = (currentHeading - lastHeading).abs() % 360;
      final headingChange = delta > 180 ? 360 - delta : delta;
      if (headingChange >= minHeadingChangeDegrees) return true;
    }

    return false;
  }
}
