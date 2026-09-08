import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/push_tokens/domain/entities/device_push_token.dart';

void main() {
  group('DevicePushToken', () {
    test('fromJson maps snake_case Postgres columns, including the enum', () {
      final token = DevicePushToken.fromJson({
        'id': 't1',
        'user_id': 'u1',
        'platform': 'android',
        'token': 'fcm-token-abc',
        'enabled': true,
        'last_seen_at': '2026-08-27T12:00:00.000Z',
        'created_at': '2026-08-27T12:00:00.000Z',
      });

      expect(token.id, 't1');
      expect(token.userId, 'u1');
      expect(token.platform, DevicePushTokenPlatform.android);
      expect(token.token, 'fcm-token-abc');
      expect(token.enabled, isTrue);
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final token = DevicePushToken(
        id: 't1',
        userId: 'u1',
        platform: DevicePushTokenPlatform.android,
        token: 'fcm-token-abc',
        enabled: true,
        lastSeenAt: DateTime.utc(2026, 8, 27),
        createdAt: DateTime.utc(2026, 8, 27),
      );

      final roundTripped = DevicePushToken.fromJson(token.toJson());

      expect(roundTripped, equals(token));
    });
  });
}
