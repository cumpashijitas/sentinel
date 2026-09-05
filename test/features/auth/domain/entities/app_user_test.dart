import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    test('two instances with the same fields are equal', () {
      const a = AppUser(id: '1', email: 'rider@sentinel.app');
      const b = AppUser(id: '1', email: 'rider@sentinel.app');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith overrides only the given fields', () {
      const original = AppUser(id: '1', email: 'rider@sentinel.app');

      final updated = original.copyWith(displayName: 'Rider');

      expect(updated.id, '1');
      expect(updated.email, 'rider@sentinel.app');
      expect(updated.displayName, 'Rider');
    });

    test('fromJson/toJson round-trip', () {
      const user = AppUser(
        id: '1',
        email: 'rider@sentinel.app',
        displayName: 'Rider',
      );

      final roundTripped = AppUser.fromJson(user.toJson());

      expect(roundTripped, equals(user));
    });
  });
}
