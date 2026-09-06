import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';

void main() {
  group('RideHistoryEntry.duration', () {
    test('is the gap between startedAt and endedAt when both are set', () {
      final entry = RideHistoryEntry(
        sessionId: 's1',
        groupId: 'g1',
        groupName: 'Los Nómadas',
        status: RideSessionStatus.finished,
        startedAt: DateTime.utc(2026, 8, 27, 8),
        endedAt: DateTime.utc(2026, 8, 27, 10, 30),
      );

      expect(entry.duration, const Duration(hours: 2, minutes: 30));
    });

    test('is null when endedAt is not set', () {
      final entry = RideHistoryEntry(
        sessionId: 's1',
        groupId: 'g1',
        groupName: 'Los Nómadas',
        status: RideSessionStatus.finished,
        startedAt: DateTime.utc(2026, 8, 27, 8),
      );

      expect(entry.duration, isNull);
    });
  });
}
