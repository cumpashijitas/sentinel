import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';

void main() {
  group('LocationFix', () {
    test('fromJson maps snake_case Postgres columns', () {
      final fix = LocationFix.fromJson({
        'latitude': -17.3935,
        'longitude': -66.1570,
        'accuracy': 5.0,
        'speed': 12.3,
        'heading': 90.0,
        'battery_level': 82,
        'recorded_at': '2026-08-27T12:00:00.000Z',
      });

      expect(fix.latitude, -17.3935);
      expect(fix.longitude, -66.1570);
      expect(fix.batteryLevel, 82);
      expect(fix.recordedAt, DateTime.parse('2026-08-27T12:00:00.000Z'));
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final fix = LocationFix(
        latitude: -17.3935,
        longitude: -66.1570,
        recordedAt: DateTime.utc(2026, 8, 27, 12),
      );

      final roundTripped = LocationFix.fromJson(fix.toJson());

      expect(roundTripped, equals(fix));
    });
  });
}
