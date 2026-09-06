import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/push_tokens/domain/entities/device_push_token.dart';
import 'package:sentinel_v2/features/push_tokens/domain/repositories/device_push_token_repository.dart';
import 'package:sentinel_v2/features/push_tokens/domain/repositories/push_token_source.dart';
import 'package:sentinel_v2/features/push_tokens/domain/services/push_token_registrar.dart';

class _FakeDevicePushTokenRepository implements DevicePushTokenRepository {
  final registrations = <(String userId, String token)>[];
  Object? errorToThrow;

  @override
  Future<DevicePushToken> registerToken({
    required String userId,
    required DevicePushTokenPlatform platform,
    required String token,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    registrations.add((userId, token));
    return DevicePushToken(
      id: 't1',
      userId: userId,
      platform: platform,
      token: token,
      enabled: true,
      lastSeenAt: DateTime.utc(2026),
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<void> unregisterToken(String token) async {}
}

class _FakePushTokenSource implements PushTokenSource {
  String? tokenToReturn;
  final _refreshController = StreamController<String>.broadcast();

  @override
  Future<String?> getToken() async => tokenToReturn;

  @override
  Stream<String> get onTokenRefresh => _refreshController.stream;

  void emitRefresh(String token) => _refreshController.add(token);

  void close() => _refreshController.close();
}

void main() {
  late _FakeDevicePushTokenRepository repository;
  late _FakePushTokenSource source;
  late PushTokenRegistrar registrar;

  setUp(() {
    repository = _FakeDevicePushTokenRepository();
    source = _FakePushTokenSource();
    registrar = PushTokenRegistrar(repository: repository, source: source);
  });

  tearDown(() {
    registrar.dispose();
    source.close();
  });

  group('PushTokenRegistrar.onUserChanged', () {
    test('registers the current token for the new user', () async {
      source.tokenToReturn = 'token-1';

      await registrar.onUserChanged('u1');

      expect(repository.registrations, [('u1', 'token-1')]);
    });

    test('does nothing when the source has no token yet', () async {
      source.tokenToReturn = null;

      await registrar.onUserChanged('u1');

      expect(repository.registrations, isEmpty);
    });

    test('does nothing for a null (signed-out) user', () async {
      source.tokenToReturn = 'token-1';

      await registrar.onUserChanged(null);

      expect(repository.registrations, isEmpty);
    });

    test('re-registers on every token refresh for the current user', () async {
      source.tokenToReturn = 'token-1';
      await registrar.onUserChanged('u1');

      source.emitRefresh('token-2');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registrations, [('u1', 'token-1'), ('u1', 'token-2')]);
    });

    test('switching users replaces the refresh subscription instead of '
        'stacking it', () async {
      source.tokenToReturn = 'token-1';
      await registrar.onUserChanged('u1');
      await registrar.onUserChanged('u2');
      await registrar.onUserChanged('u3');
      repository.registrations.clear();

      source.emitRefresh('token-2');
      await Future<void>.delayed(Duration.zero);

      // If earlier subscriptions had leaked instead of being cancelled,
      // this single emitted event would have registered once per
      // stacked listener (for u1, u2 *and* u3).
      expect(repository.registrations, [('u3', 'token-2')]);
    });

    test(
      'a signed-out call cancels the previous refresh subscription',
      () async {
        source.tokenToReturn = 'token-1';
        await registrar.onUserChanged('u1');

        await registrar.onUserChanged(null);
        source.emitRefresh('token-2');
        await Future<void>.delayed(Duration.zero);

        expect(repository.registrations, [('u1', 'token-1')]);
      },
    );
  });
}
