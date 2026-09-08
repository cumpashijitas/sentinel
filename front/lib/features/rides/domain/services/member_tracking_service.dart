import '../entities/location_fix.dart';
import '../entities/member_location.dart';
import '../entities/member_tracking_config.dart';
import '../entities/ride_session_participant.dart';
import 'straggler_detection_strategy.dart';

/// Turns "who's in this ride" + "where was everyone last seen" into a
/// roster of [MemberLocation] with a computed [MemberTrackingStatus] —
/// pure, synchronous, and independent of Supabase/Riverpod so it can be
/// unit-tested with plain fixtures (see
/// `test/features/rides/domain/services/member_tracking_service_test.dart`).
///
/// Two-pass algorithm:
///  1. Classify every participant as `active`/`stale`/`offline` purely from
///     fix age (how long ago `recordedAt` was, relative to `now`).
///  2. Among the still-`active` participants, ask [stragglerStrategy]
///     whether each one is too far from the rest of the *trusted* (i.e.
///     also still-`active`) group — a stale/offline rider's last-known
///     position doesn't get to anchor "where the group is".
class MemberTrackingService {
  const MemberTrackingService({
    this.config = const MemberTrackingConfig(),
    this.stragglerStrategy = const CentroidStragglerDetectionStrategy(),
  });

  final MemberTrackingConfig config;
  final StragglerDetectionStrategy stragglerStrategy;

  List<MemberLocation> computeStatuses({
    required List<RideSessionParticipant> participants,
    required Map<String, LocationFix> fixesByUserId,
    required DateTime now,
  }) {
    final ageStatusByUserId = <String, MemberTrackingStatus>{
      for (final participant in participants)
        participant.userId: _ageStatus(fixesByUserId[participant.userId], now),
    };

    final trustedFixesByUserId = <String, LocationFix>{
      for (final participant in participants)
        if (ageStatusByUserId[participant.userId] ==
            MemberTrackingStatus.active)
          participant.userId: fixesByUserId[participant.userId]!,
    };

    return participants
        .map((participant) {
          final fix = fixesByUserId[participant.userId];
          var status = ageStatusByUserId[participant.userId]!;

          if (status == MemberTrackingStatus.active && fix != null) {
            final otherTrustedFixes = [
              for (final entry in trustedFixesByUserId.entries)
                if (entry.key != participant.userId) entry.value,
            ];
            if (stragglerStrategy.isLagging(
              memberFix: fix,
              groupFixes: otherTrustedFixes,
              config: config,
            )) {
              status = MemberTrackingStatus.lagging;
            }
          }

          return MemberLocation(
            userId: participant.userId,
            displayName: participant.displayName,
            avatarUrl: participant.avatarUrl,
            fix: fix,
            status: status,
          );
        })
        .toList(growable: false);
  }

  MemberTrackingStatus _ageStatus(LocationFix? fix, DateTime now) {
    if (fix == null) return MemberTrackingStatus.offline;
    final ageSeconds = now.difference(fix.recordedAt).inSeconds;
    if (ageSeconds > config.offlineLocationSeconds) {
      return MemberTrackingStatus.offline;
    }
    if (ageSeconds > config.staleLocationSeconds) {
      return MemberTrackingStatus.stale;
    }
    return MemberTrackingStatus.active;
  }
}
