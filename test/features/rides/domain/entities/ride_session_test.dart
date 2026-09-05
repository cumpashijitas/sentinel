import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';

void main() {
  group('RideSession', () {
    test('fromJson maps snake_case Postgres columns, including the enum', () {
      final session = RideSession.fromJson({
        'id': 's1',
        'group_id': 'g1',
        'started_by': 'u1',
        'name': 'Salida domingo',
        'status': 'active',
        'started_at': '2026-08-27T12:00:00.000Z',
        'ended_at': null,
        'created_at': '2026-08-27T12:00:00.000Z',
      });

      expect(session.id, 's1');
      expect(session.groupId, 'g1');
      expect(session.startedBy, 'u1');
      expect(session.status, RideSessionStatus.active);
      expect(session.endedAt, isNull);
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final session = RideSession(
        id: 's1',
        groupId: 'g1',
        startedBy: 'u1',
        status: RideSessionStatus.finished,
        startedAt: DateTime.utc(2026, 8, 27, 10),
        endedAt: DateTime.utc(2026, 8, 27, 11),
        createdAt: DateTime.utc(2026, 8, 27, 10),
      );

      final roundTripped = RideSession.fromJson(session.toJson());

      expect(roundTripped, equals(session));
    });
  });
}
