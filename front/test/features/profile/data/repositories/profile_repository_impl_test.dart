import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sentinel_v2/features/profile/data/repositories/profile_repository_impl.dart';

Map<String, dynamic> _row({String? phone, bool whatsappAlertsOptIn = false}) =>
    {
      'id': 'u1',
      'display_name': 'Ana Rider',
      'phone': phone,
      'avatar_url': null,
      'whatsapp_alerts_opt_in': whatsappAlertsOptIn,
      'created_at': '2026-08-27T12:00:00.000Z',
      'updated_at': '2026-08-27T12:00:00.000Z',
    };

class _FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  Map<String, dynamic>? rowToReturn;
  Object? errorToThrow;
  String? lastUpdatedUserId;
  String? lastUpdatedDisplayName;
  String? lastUpdatedPhone;
  bool? lastUpdatedWhatsappAlertsOptIn;

  @override
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) async {
    lastUpdatedUserId = userId;
    lastUpdatedDisplayName = displayName;
    lastUpdatedPhone = phone;
    lastUpdatedWhatsappAlertsOptIn = whatsappAlertsOptIn;
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }
}

void main() {
  late _FakeProfileRemoteDataSource dataSource;
  late ProfileRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(dataSource);
  });

  group('ProfileRepositoryImpl', () {
    test('fetchProfile maps the datasource row to a Profile', () async {
      dataSource.rowToReturn = _row(phone: '+591 700 00001');

      final profile = await repository.fetchProfile('u1');

      expect(profile.id, 'u1');
      expect(profile.displayName, 'Ana Rider');
      expect(profile.phone, '+591 700 00001');
    });

    test(
      'fetchProfile translates a "row not found" ApiException',
      () async {
        dataSource.errorToThrow = const ApiException('not found', statusCode: 404);

        await expectLater(
          () => repository.fetchProfile('missing'),
          throwsA(isA<DataException>()),
        );
      },
    );

    test('fetchProfile translates a permission-denied ApiException', () async {
      dataSource.errorToThrow = const ApiException('permission denied', statusCode: 403);

      await expectLater(
        () => repository.fetchProfile('someone-else'),
        throwsA(
          isA<DataException>().having(
            (e) => e.message,
            'message',
            'No tienes permiso para realizar esta acción.',
          ),
        ),
      );
    });

    test(
      'updateProfile forwards the exact arguments to the datasource',
      () async {
        dataSource.rowToReturn = _row(phone: '+591 700 09999');

        await repository.updateProfile(
          userId: 'u1',
          displayName: 'Ana R.',
          phone: '+591 700 09999',
          whatsappAlertsOptIn: true,
        );

        expect(dataSource.lastUpdatedUserId, 'u1');
        expect(dataSource.lastUpdatedDisplayName, 'Ana R.');
        expect(dataSource.lastUpdatedPhone, '+591 700 09999');
        expect(dataSource.lastUpdatedWhatsappAlertsOptIn, isTrue);
      },
    );

    test('updateProfile returns the updated Profile', () async {
      dataSource.rowToReturn = _row();

      final profile = await repository.updateProfile(
        userId: 'u1',
        displayName: 'Ana Rider',
        whatsappAlertsOptIn: false,
      );

      expect(profile.phone, isNull);
    });
  });
}
