import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';

void main() {
  group('AccidentEvent', () {
    test('fromJson maps snake_case Postgres columns, including status', () {
      final event = AccidentEvent.fromJson({
        'id': 'a1',
        'session_id': 's1',
        'user_id': 'u1',
        'latitude': null,
        'longitude': null,
        'impact_mps2': 25.0,
        'gyro_rad_s': 3.2,
        'speed_kmh': null,
        'g_force': 2.5,
        'confidence_score': 0.7,
        'status': 'candidate',
        'occurred_at': '2026-08-28T12:00:00.000Z',
      });

      expect(event.id, 'a1');
      expect(event.sessionId, 's1');
      expect(event.impactMps2, 25.0);
      expect(event.status, AccidentEventStatus.candidate);
      expect(event.occurredAt, DateTime.parse('2026-08-28T12:00:00.000Z'));
    });

    test('toJson serializes the status enum back to its Postgres name', () {
      final event = AccidentEvent(
        id: 'a1',
        userId: 'u1',
        impactMps2: 25.0,
        status: AccidentEventStatus.confirmed,
        occurredAt: DateTime.utc(2026, 8, 28, 12),
      );

      expect(event.toJson()['status'], 'confirmed');
    });
  });
}
