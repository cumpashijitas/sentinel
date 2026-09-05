import '../../../accidents/domain/entities/accident_event.dart';
import '../../../rides/domain/entities/ride_history_entry.dart';
import '../entities/ride_statistics.dart';

/// Derives [RideStatistics] from already-fetched history lists — pure
/// logic, no Supabase, same shape as `MemberTrackingService`/
/// `AccidentDetectionService` and just as unit-testable.
///
/// Deliberately not a database RPC: both inputs are already fetched in
/// full for the ride/accident history screens (Fase 9 lists are
/// per-user and small — no pagination anywhere else in this app either),
/// so a second round trip just to sum what's already in memory would be
/// pure overhead, not more "real". Revisit if history grows large enough
/// that fetching it all client-side stops being reasonable.
abstract final class RideStatisticsCalculator {
  static RideStatistics compute({
    required List<RideHistoryEntry> rides,
    required List<AccidentEvent> accidents,
  }) {
    var totalRideDuration = Duration.zero;
    DateTime? lastRideAt;
    for (final ride in rides) {
      totalRideDuration += ride.duration ?? Duration.zero;
      if (lastRideAt == null || ride.startedAt.isAfter(lastRideAt)) {
        lastRideAt = ride.startedAt;
      }
    }

    // Only statuses that mean "this really happened" count — a 'candidate'
    // the rider dismissed via "Estoy bien" is a false alarm, not an
    // accident, and shouldn't inflate this number.
    const realAccidentStatuses = {
      AccidentEventStatus.confirmed,
      AccidentEventStatus.notified,
      AccidentEventStatus.resolved,
    };
    final totalAccidents = accidents
        .where((event) => realAccidentStatuses.contains(event.status))
        .length;

    return RideStatistics(
      totalRides: rides.length,
      totalRideDuration: totalRideDuration,
      totalAccidents: totalAccidents,
      lastRideAt: lastRideAt,
    );
  }
}
