import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/vehicles/domain/entities/vehicle.dart';

void main() {
  group('Vehicle', () {
    test('fromJson maps snake_case Postgres columns', () {
      final vehicle = Vehicle.fromJson({
        'id': 'v1',
        'owner_id': 'u1',
        'brand': 'Honda',
        'model': 'CB500X',
        'year': 2022,
        'plate': 'SEN-101',
        'color': 'Rojo',
        'created_at': '2026-08-27T12:00:00.000Z',
        'updated_at': '2026-08-27T12:00:00.000Z',
      });

      expect(vehicle.id, 'v1');
      expect(vehicle.ownerId, 'u1');
      expect(vehicle.brand, 'Honda');
      expect(vehicle.model, 'CB500X');
      expect(vehicle.year, 2022);
      expect(vehicle.plate, 'SEN-101');
      expect(vehicle.color, 'Rojo');
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final vehicle = Vehicle(
        id: 'v1',
        ownerId: 'u1',
        brand: 'Yamaha',
        model: 'MT-07',
        createdAt: DateTime.utc(2026, 8, 27),
        updatedAt: DateTime.utc(2026, 8, 27),
      );

      final roundTripped = Vehicle.fromJson(vehicle.toJson());

      expect(roundTripped, equals(vehicle));
    });
  });
}
