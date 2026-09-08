/// Thresholds for [MemberTrackingService] — deliberately a plain,
/// hand-written immutable class (not `freezed`): it's a handful of
/// primitive fields with no derived behavior of their own, constructed
/// once as a default or in tests, so generating `copyWith`/JSON code for
/// it wouldn't pay for itself.
///
/// Centralizing these here (rather than hardcoding them inside a widget or
/// the tracking service) is what makes the straggler/stale/offline
/// strategy swappable and unit-testable — see
/// `StragglerDetectionStrategy` and `docs/realtime.md`.
class MemberTrackingConfig {
  const MemberTrackingConfig({
    this.maxDistanceFromGroupMeters = 500,
    this.staleLocationSeconds = 45,
    this.offlineLocationSeconds = 180,
  }) : assert(
         staleLocationSeconds < offlineLocationSeconds,
         'a fix must go stale before it goes offline',
       );

  /// Beyond this distance from the group's centroid, an otherwise-recent
  /// member is considered [MemberTrackingStatus.lagging].
  final double maxDistanceFromGroupMeters;

  /// A fix older than this (but younger than [offlineLocationSeconds]) is
  /// [MemberTrackingStatus.stale].
  final int staleLocationSeconds;

  /// A fix older than this (or absent) is [MemberTrackingStatus.offline].
  final int offlineLocationSeconds;
}
