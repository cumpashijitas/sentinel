import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_statistics.freezed.dart';

/// Basic, derived (never persisted) usage summary for the signed-in rider —
/// Fase 9. Computed client-side by `RideStatisticsCalculator` from
/// [RideHistoryEntry]/`AccidentEvent` lists that are already being fetched
/// for the history screens, rather than a dedicated RPC — see that class's
/// doc comment for why.
@freezed
abstract class RideStatistics with _$RideStatistics {
  const factory RideStatistics({
    required int totalRides,
    required Duration totalRideDuration,
    required int totalAccidents,
    DateTime? lastRideAt,
  }) = _RideStatistics;
}
