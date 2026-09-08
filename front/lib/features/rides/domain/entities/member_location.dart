import 'package:freezed_annotation/freezed_annotation.dart';

import 'location_fix.dart';

part 'member_location.freezed.dart';

/// A session participant's tracking status, as computed by
/// `MemberTrackingService`. Not persisted — recomputed client-side from
/// `live_locations` + wall-clock time, so it's never stale in the
/// database sense.
enum MemberTrackingStatus {
  /// Recent fix, close enough to the rest of the group.
  active,

  /// Fix is older than `staleLocationSeconds` but not yet
  /// `offlineLocationSeconds` — connection hiccup, tunnel, dead zone.
  stale,

  /// No fix at all, or older than `offlineLocationSeconds`.
  offline,

  /// Recent-enough fix, but farther from the group than
  /// `maxDistanceFromGroupMeters` — see `StragglerDetectionStrategy`.
  lagging,

  /// Reserved for Fase 7 (accident detection): a confirmed
  /// `accident_event` tied to this rider's session. `MemberTrackingService`
  /// never sets this today — there is no accident signal to compute it
  /// from yet — but the UI/status model already accounts for it so that
  /// wiring it in later doesn't require another status enum migration.
  possibleIncident,
}

/// One roster entry for the ride-map screen: who they are, where they
/// (last) were, and how "found" they currently look.
@freezed
abstract class MemberLocation with _$MemberLocation {
  const factory MemberLocation({
    required String userId,
    required String displayName,
    String? avatarUrl,
    LocationFix? fix,
    required MemberTrackingStatus status,
  }) = _MemberLocation;
}
