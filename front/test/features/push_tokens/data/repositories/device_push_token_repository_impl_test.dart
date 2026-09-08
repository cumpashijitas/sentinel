import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/push_tokens/data/datasources/device_push_token_remote_datasource.dart';
import 'package:sentinel_v2/features/push_tokens/data/repositories/device_push_token_repository_impl.dart';
import 'package:sentinel_v2/features/push_tokens/domain/entities/device_push_token.dart';

Map<String, dynamic> _row({String id = 't1'}) => {
  'id': id,
  'user_id': 'u1',
  'platform': 'android',
  'token': 'fcm-token-abc',
  'enabled': true,
  'last_seen_at': '2026-08-27T12:00:00.000Z',
  'created_at': '2026-08-27T12:00:00.000Z',
};

class _FakeDevicePushTokenRemoteDataSource
    implements DevicePushTokenRemoteDataSource {
  Map<String, dynamic>? rowToReturn;
  Object? errorToThrow;
  Map<String, dynamic>? lastUpsertedRow;
  String? lastDeletedToken;

  @override
  Future<Map<String, dynamic>> upsertToken(Map<String, dynamic> row) async {
    lastUpsertedRow = row;
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }

  @override
  Future<void> deleteToken(String token) async {
    lastDeletedToken = token;
    final error = errorToThrow;
    if (error != null) throw error;
  }
}

void main() {
  late _FakeDevicePushTokenRemoteDataSource dataSource;
  late DevicePushTokenRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeDevicePushTokenRemoteDataSource();
    repository = DevicePushTokenRepositoryImpl(dataSource);
  });

  group('DevicePushTokenRepositoryImpl', () {
    test(
      'registerToken forwards user/platform/token to the datasource',
      () async {
        dataSource.rowToReturn = _row();

        await repository.registerToken(
          userId: 'u1',
          platform: DevicePushTokenPlatform.android,
          token: 'fcm-token-abc',
        );

        expect(dataSource.lastUpsertedRow?['user_id'], 'u1');
        expect(dataSource.lastUpsertedRow?['platform'], 'android');
        expect(dataSource.lastUpsertedRow?['token'], 'fcm-token-abc');
        expect(dataSource.lastUpsertedRow?['last_seen_at'], isNotNull);
      },
    );

    test('registerToken returns the upserted DevicePushToken', () async {
      dataSource.rowToReturn = _row();

      final token = await repository.registerToken(
        userId: 'u1',
        platform: DevicePushTokenPlatform.android,
        token: 'fcm-token-abc',
      );

      expect(token.id, 't1');
      expect(token.platform, DevicePushTokenPlatform.android);
    });

    test('unregisterToken forwards the token to the datasource', () async {
      await repository.unregisterToken('fcm-token-abc');

      expect(dataSource.lastDeletedToken, 'fcm-token-abc');
    });

    test('translates a permission-denied ApiException', () async {
      dataSource.errorToThrow = const ApiException('permission denied', statusCode: 403);

      await expectLater(
        () => repository.unregisterToken('not-mine'),
        throwsA(
          isA<DataException>().having(
            (e) => e.message,
            'message',
            'No tienes permiso para realizar esta acción.',
          ),
        ),
      );
    });
  });
}
