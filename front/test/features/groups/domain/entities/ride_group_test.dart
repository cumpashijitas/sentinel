import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/groups/domain/entities/ride_group.dart';

void main() {
  group('RideGroup', () {
    test('fromJson maps snake_case Postgres columns, including the enum', () {
      final group = RideGroup.fromJson({
        'id': 'g1',
        'owner_id': 'u1',
        'name': 'Ruta de los Domingos',
        'description': 'Salida grupal.',
        'invite_code': 'SUNDAY01',
        'status': 'active',
        'created_at': '2026-08-27T12:00:00.000Z',
        'updated_at': '2026-08-27T12:00:00.000Z',
      });

      expect(group.id, 'g1');
      expect(group.ownerId, 'u1');
      expect(group.name, 'Ruta de los Domingos');
      expect(group.inviteCode, 'SUNDAY01');
      expect(group.status, RideGroupStatus.active);
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final group = RideGroup(
        id: 'g1',
        ownerId: 'u1',
        name: 'Ruta de los Domingos',
        inviteCode: 'SUNDAY01',
        status: RideGroupStatus.archived,
        createdAt: DateTime.utc(2026, 8, 27),
        updatedAt: DateTime.utc(2026, 8, 27),
      );

      final roundTripped = RideGroup.fromJson(group.toJson());

      expect(roundTripped, equals(group));
    });
  });
}
