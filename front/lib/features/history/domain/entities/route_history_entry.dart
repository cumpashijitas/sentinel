import '../../../emergency_shares/domain/entities/emergency_share.dart';
import '../../../rides/domain/entities/ride_history_entry.dart';

/// One row in the "Viajes" tab of history — either a finished group ride
/// or a finished individual share, merged into a single chronological feed
/// (Strava mixes solo and group activities the same way). Deliberately a
/// plain class, not `@freezed`: this is a display-only merge of two
/// *already* modeled entities, never itself compared/copied/serialized —
/// see [RouteHistoryMerger].
class RouteHistoryEntry {
  const RouteHistoryEntry.group(RideHistoryEntry entry)
    : ride = entry,
      share = null;

  const RouteHistoryEntry.individual(EmergencyShare entry)
    : ride = null,
      share = entry;

  /// Non-null exactly when this row is a group ride.
  final RideHistoryEntry? ride;

  /// Non-null exactly when this row is an individual share.
  final EmergencyShare? share;

  bool get isGroup => ride != null;

  DateTime get startedAt => ride?.startedAt ?? share!.startedAt;

  Duration? get duration =>
      ride != null ? ride!.duration : share!.endedAt?.difference(share!.startedAt);
}

/// Merges [RideHistoryEntry] and [EmergencyShare] lists into one
/// [RouteHistoryEntry] feed, newest first — pure logic, same shape as
/// `RideStatisticsCalculator`.
abstract final class RouteHistoryMerger {
  static List<RouteHistoryEntry> merge({
    required List<RideHistoryEntry> rides,
    required List<EmergencyShare> shares,
  }) {
    final entries = [
      ...rides.map(RouteHistoryEntry.group),
      ...shares.map(RouteHistoryEntry.individual),
    ];
    entries.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return entries;
  }
}
