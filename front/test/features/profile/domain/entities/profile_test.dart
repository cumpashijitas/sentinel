import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/profile/domain/entities/profile.dart';

void main() {
  group('Profile', () {
    test('fromJson maps snake_case Postgres columns', () {
      final profile = Profile.fromJson({
        'id': 'u1',
        'display_name': 'Ana Rider',
        'phone': '+591 700 00001',
        'avatar_url': null,
        'whatsapp_alerts_opt_in': true,
        'created_at': '2026-08-27T12:00:00.000Z',
        'updated_at': '2026-08-27T12:00:00.000Z',
      });

      expect(profile.id, 'u1');
      expect(profile.displayName, 'Ana Rider');
      expect(profile.phone, '+591 700 00001');
      expect(profile.avatarUrl, isNull);
      expect(profile.whatsappAlertsOptIn, isTrue);
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final profile = Profile(
        id: 'u1',
        displayName: 'Ana Rider',
        whatsappAlertsOptIn: true,
        createdAt: DateTime.utc(2026, 8, 27),
        updatedAt: DateTime.utc(2026, 8, 27),
      );

      final roundTripped = Profile.fromJson(profile.toJson());

      expect(roundTripped, equals(profile));
    });

    test('two instances with the same fields are equal', () {
      final now = DateTime.utc(2026);
      final a = Profile(
        id: 'u1',
        displayName: 'Ana',
        whatsappAlertsOptIn: false,
        createdAt: now,
        updatedAt: now,
      );
      final b = Profile(
        id: 'u1',
        displayName: 'Ana',
        whatsappAlertsOptIn: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(a, equals(b));
    });
  });
}
