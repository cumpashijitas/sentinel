import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/emergency_shares/data/datasources/emergency_share_remote_datasource.dart';
import 'package:sentinel_v2/features/emergency_shares/data/repositories/emergency_share_repository_impl.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';

Map<String, dynamic> _historyRow({double lat = -17.3935}) => {
  'latitude': lat,
  'longitude': -66.1570,
  'recorded_at': '2026-08-27T12:00:00.000Z',
};

LocationFix _fix() => LocationFix(
  latitude: -17.3935,
  longitude: -66.1570,
  recordedAt: DateTime.utc(2026, 8, 27),
);

class _FakeEmergencyShareRemoteDataSource
    implements EmergencyShareRemoteDataSource {
  List<Map<String, dynamic>> historyRowsToReturn = [];
  Object? errorToThrow;
  Map<String, dynamic>? lastRecordedFixJson;

  @override
  Future<Map<String, dynamic>?> fetchActiveShare() =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> startShare() => throw UnimplementedError();

  @override
  Future<void> stopShare() => throw UnimplementedError();

  @override
  Future<void> upsertLocation({
    required String shareId,
    required Map<String, dynamic> fixJson,
  }) => throw UnimplementedError();

  @override
  Future<void> recordHistory({
    required String shareId,
    required Map<String, dynamic> fixJson,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastRecordedFixJson = fixJson;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String shareId) async =>
      historyRowsToReturn;

  @override
  Future<List<Map<String, dynamic>>> fetchSharedWithMe() =>
      throw UnimplementedError();
}

void main() {
  late _FakeEmergencyShareRemoteDataSource dataSource;
  late EmergencyShareRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeEmergencyShareRemoteDataSource();
    repository = EmergencyShareRepositoryImpl(dataSource);
  });

  group('EmergencyShareRepositoryImpl.recordHistory', () {
    test('forwards the fix as JSON', () async {
      await repository.recordHistory(shareId: 's1', fix: _fix());

      expect(dataSource.lastRecordedFixJson?['latitude'], -17.3935);
    });

    test('translates an ApiException', () async {
      dataSource.errorToThrow = const ApiException(
        'active share not found',
        statusCode: 404,
      );

      await expectLater(
        () => repository.recordHistory(shareId: 's1', fix: _fix()),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('EmergencyShareRepositoryImpl.fetchMyRoute', () {
    test('maps every row into a LocationFix, in order', () async {
      dataSource.historyRowsToReturn = [
        _historyRow(),
        _historyRow(lat: -17.4),
      ];

      final route = await repository.fetchMyRoute('s1');

      expect(route, hasLength(2));
      expect(route.first.latitude, -17.3935);
      expect(route.last.latitude, -17.4);
    });

    test('returns an empty route when nothing was ever recorded', () async {
      final route = await repository.fetchMyRoute('s1');

      expect(route, isEmpty);
    });
  });
}
