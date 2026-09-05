import '../../../../core/utils/geo_math.dart';
import '../entities/location_fix.dart';
import '../entities/member_tracking_config.dart';

/// Decides whether one member's fix counts as "too far from the group".
/// Pulled out as its own interface (rather than inlined in
/// `MemberTrackingService`) specifically so it can be replaced later
/// without touching the status-computation pipeline around it — e.g. a
/// route-aware strategy once `ride_sessions` gains a planned route, or a
/// leader-relative strategy for rides with a designated lead rider.
abstract interface class StragglerDetectionStrategy {
  /// [memberFix] is the rider being evaluated; [groupFixes] are the other
  /// currently-trusted (non-stale, non-offline) fixes to compare against.
  /// Returns `false` when [groupFixes] is empty — with nobody else to be
  /// far *from*, nobody can be lagging.
  bool isLagging({
    required LocationFix memberFix,
    required List<LocationFix> groupFixes,
    required MemberTrackingConfig config,
  });
}

/// Default strategy: compute the centroid of [groupFixes] and flag the
/// member if they're farther than [MemberTrackingConfig.maxDistanceFromGroupMeters]
/// from it. Simple, cheap, and a reasonable first approximation for a
/// group riding roughly together — not a substitute for route-matching.
final class CentroidStragglerDetectionStrategy
    implements StragglerDetectionStrategy {
  const CentroidStragglerDetectionStrategy();

  @override
  bool isLagging({
    required LocationFix memberFix,
    required List<LocationFix> groupFixes,
    required MemberTrackingConfig config,
  }) {
    if (groupFixes.isEmpty) return false;

    final (centroidLat, centroidLng) = GeoMath.centroid([
      for (final fix in groupFixes) (fix.latitude, fix.longitude),
    ]);

    final distance = GeoMath.distanceMeters(
      fromLat: memberFix.latitude,
      fromLng: memberFix.longitude,
      toLat: centroidLat,
      toLng: centroidLng,
    );

    return distance > config.maxDistanceFromGroupMeters;
  }
}
