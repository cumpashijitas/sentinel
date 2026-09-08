import 'package:freezed_annotation/freezed_annotation.dart';

import 'ride_session.dart';

part 'ride_history_entry.freezed.dart';

/// A finished (or cancelled) [RideSession] the caller participated in,
/// with just enough group context to render a history row.
///
/// Assembled by `RideSessionRepositoryImpl.fetchHistory` from a joined
/// `ride_session_members` → `ride_sessions` → `ride_groups` query — same
/// reasoning as `RideSessionParticipant` for why there's no `fromJson`
/// here: the shape comes from a nested embed, not a flat table row.
@freezed
abstract class RideHistoryEntry with _$RideHistoryEntry {
  const factory RideHistoryEntry({
    required String sessionId,
    required String groupId,
    required String groupName,
    String? name,
    required RideSessionStatus status,
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _RideHistoryEntry;

  const RideHistoryEntry._();

  /// `null` while [endedAt] isn't set. In practice this never happens today
  /// — `RideSessionRepository.fetchHistory` only ever returns `finished`
  /// sessions, and `finish_ride_session` always sets `ended_at` — kept
  /// nullable defensively rather than asserting a DB invariant in Dart.
  Duration? get duration => endedAt?.difference(startedAt);
}
