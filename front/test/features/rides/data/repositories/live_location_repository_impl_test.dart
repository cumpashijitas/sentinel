import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/rides/data/datasources/live_location_remote_datasource.dart';
import 'package:sentinel_v2/features/rides/data/repositories/live_location_repository_impl.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';

Map<String, dynamic> _row({String userId = 'u1', double lat = -17.3935}) => {
  'user_id': userId,
  'latitude': lat,
  'longitude': -66.1570,
  'accuracy': null,
  'speed': null,
  'heading': null,
  'battery_level': null,
  'recorded_at': '2026-08-27T12:00:00.000Z',
};

LocationFix _fix() => LocationFix(
  latitude: -17.3935,
  longitude: -66.1570,
  recordedAt: DateTime.utc(2026, 8, 27),
);

class _FakeLiveLocationRemoteDataSource
    implements LiveLocationRemoteDataSource {
  List<Map<String, dynamic>> currentRowsToReturn = [];
  final _changesController = StreamController<Map<String, dynamic>>.broadcast();
  Object? errorToThrow;
  Map<String, dynamic>? lastUpsertedFixJson;
  Map<String, dynamic>? lastRecordedFixJson;

  void emitChange(Map<String, dynamic> row) => _changesController.add(row);

  @override
  Future<List<Map<String, dynamic>>> fetchCurrentLocations(
    String sessionId,
  ) async => currentRowsToReturn;

  @override
  Stream<Map<String, dynamic>> watchLocationChanges(String sessionId) =>
      _changesController.stream;

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastUpsertedFixJson = fixJson;
  }

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastRecordedFixJson = fixJson;
  }
}

void main() {
  late _FakeLiveLocationRemoteDataSource dataSource;
  late LiveLocationRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeLiveLocationRemoteDataSource();
    repository = LiveLocationRepositoryImpl(dataSource);
  });

  tearDown(() => dataSource._changesController.close());

  group('LiveLocationRepositoryImpl.watchSessionLocations', () {
    test('emits the initial snapshot first', () async {
      dataSource.currentRowsToReturn = [_row()];

      final first = await repository.watchSessionLocations('s1').first;

      expect(first.keys, contains('u1'));
    });

    test('merges a Realtime change into the running snapshot', () async {
      dataSource.currentRowsToReturn = [_row()];

      final states = <Map<String, LocationFix>>[];
      final sub = repository.watchSessionLocations('s1').listen(states.add);

      await Future<void>.delayed(Duration.zero);
      dataSource.emitChange(_row(userId: 'u2', lat: -17.5));
      await Future<void>.delayed(Duration.zero);
      // Deliberately not awaited: the fake's `watchLocationChanges` reuses
      // one long-lived broadcast controller for the whole test (unlike the
      // real datasource, which closes its controller in `onCancel` — see
      // `SupabaseLiveLocationRemoteDataSource`), so cancelling the outer
      // subscription here has nothing further to unwind. Both snapshots
      // are already captured above by the time we get here.
      unawaited(sub.cancel());

      expect(states, hasLength(2));
      expect(states.first.keys, ['u1']);
      // second snapshot has both — u1 wasn't dropped by u2's update.
      expect(states.last.keys, containsAll(['u1', 'u2']));
    });
  });

  group('LiveLocationRepositoryImpl writes', () {
    test('upsertMyLocation forwards the fix as JSON', () async {
      await repository.upsertMyLocation(
        sessionId: 's1',
        userId: 'u1',
        fix: _fix(),
      );

      expect(dataSource.lastUpsertedFixJson?['latitude'], -17.3935);
    });

    test('recordHistory forwards the fix as JSON', () async {
      await repository.recordHistory(
        sessionId: 's1',
        userId: 'u1',
        fix: _fix(),
      );

      expect(dataSource.lastRecordedFixJson?['latitude'], -17.3935);
    });

    test('translates a permission-denied ApiException', () async {
      dataSource.errorToThrow = const ApiException(
        'permission denied',
        statusCode: 403,
      );

      await expectLater(
        () => repository.upsertMyLocation(
          sessionId: 's1',
          userId: 'u1',
          fix: _fix(),
        ),
        throwsA(isA<DataException>()),
      );
    });
  });
}
