import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/history/domain/services/ride_statistics_calculator.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';

RideHistoryEntry _ride({
  String sessionId = 's1',
  DateTime? startedAt,
  DateTime? endedAt,
}) => RideHistoryEntry(
  sessionId: sessionId,
  groupId: 'g1',
  groupName: 'Los Nómadas',
  status: RideSessionStatus.finished,
  startedAt: startedAt ?? DateTime.utc(2026, 8, 27, 8),
  endedAt: endedAt ?? DateTime.utc(2026, 8, 27, 9),
);

AccidentEvent _accident({
  String id = 'a1',
  AccidentEventStatus status = AccidentEventStatus.confirmed,
}) => AccidentEvent(
  id: id,
  userId: 'u1',
  impactMps2: 30,
  status: status,
  occurredAt: DateTime.utc(2026, 8, 27),
);

void main() {
  group('RideStatisticsCalculator.compute', () {
    test('is all zeros for no rides and no accidents', () {
      final stats = RideStatisticsCalculator.compute(
        rides: const [],
        accidents: const [],
      );

      expect(stats.totalRides, 0);
      expect(stats.totalRideDuration, Duration.zero);
      expect(stats.totalAccidents, 0);
      expect(stats.lastRideAt, isNull);
    });

    test('sums ride durations and counts rides', () {
      final stats = RideStatisticsCalculator.compute(
        rides: [
          _ride(
            startedAt: DateTime.utc(2026, 8, 1, 8),
            endedAt: DateTime.utc(2026, 8, 1, 9, 30),
          ),
          _ride(
            sessionId: 's2',
            startedAt: DateTime.utc(2026, 8, 2, 8),
            endedAt: DateTime.utc(2026, 8, 2, 9),
          ),
        ],
        accidents: const [],
      );

      expect(stats.totalRides, 2);
      expect(stats.totalRideDuration, const Duration(hours: 2, minutes: 30));
    });

    test('lastRideAt is the most recent startedAt, not insertion order', () {
      final stats = RideStatisticsCalculator.compute(
        rides: [
          _ride(startedAt: DateTime.utc(2026, 8)),
          _ride(sessionId: 's2', startedAt: DateTime.utc(2026, 8, 20)),
          _ride(sessionId: 's3', startedAt: DateTime.utc(2026, 8, 10)),
        ],
        accidents: const [],
      );

      expect(stats.lastRideAt, DateTime.utc(2026, 8, 20));
    });

    test('only counts confirmed/notified/resolved accidents, not candidate/cancelled', () {
      final stats = RideStatisticsCalculator.compute(
        rides: const [],
        accidents: [
          _accident(status: AccidentEventStatus.candidate),
          _accident(id: 'a2', status: AccidentEventStatus.cancelled),
          _accident(id: 'a3'),
          _accident(id: 'a4', status: AccidentEventStatus.notified),
          _accident(id: 'a5', status: AccidentEventStatus.resolved),
        ],
      );

      expect(stats.totalAccidents, 3);
    });

    test('a ride with no endedAt contributes zero duration, not a crash', () {
      final stats = RideStatisticsCalculator.compute(
        rides: [
          RideHistoryEntry(
            sessionId: 's1',
            groupId: 'g1',
            groupName: 'Los Nómadas',
            status: RideSessionStatus.finished,
            startedAt: DateTime.utc(2026, 8, 27, 8),
          ),
        ],
        accidents: const [],
      );

      expect(stats.totalRideDuration, Duration.zero);
      expect(stats.totalRides, 1);
    });
  });
}
