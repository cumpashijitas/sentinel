import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/accidents/data/datasources/accident_event_remote_datasource.dart';
import 'package:sentinel_v2/features/accidents/data/repositories/accident_event_repository_impl.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';

Map<String, dynamic> _row({String status = 'candidate'}) => {
  'id': 'a1',
  'session_id': 's1',
  'user_id': 'u1',
  'latitude': null,
  'longitude': null,
  'impact_mps2': 25.0,
  'gyro_rad_s': 3.2,
  'speed_kmh': null,
  'g_force': 2.5,
  'confidence_score': 0.7,
  'status': status,
  'occurred_at': '2026-08-28T12:00:00.000Z',
};

MotionSample _sample() => MotionSample(
  accelX: 0,
  accelY: 0,
  accelZ: 30,
  recordedAt: DateTime.utc(2026, 8, 28, 12),
);

class _FakeAccidentEventRemoteDataSource
    implements AccidentEventRemoteDataSource {
  Map<String, dynamic>? rowToReturn;
  Map<String, dynamic>? lastInsertedRow;
  ({String id, String status})? lastStatusUpdate;
  Object? errorToThrow;
  List<Map<String, dynamic>> rowsToReturn = [];
  String? lastFetchedUserId;

  @override
  Future<Map<String, dynamic>> insertCandidate(Map<String, dynamic> row) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastInsertedRow = row;
    return rowToReturn!;
  }

  @override
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastStatusUpdate = (id: id, status: status);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMine(String userId) async {
    lastFetchedUserId = userId;
    final error = errorToThrow;
    if (error != null) throw error;
    return rowsToReturn;
  }

  @override
  Future<Map<String, dynamic>> fetchById(String id) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }
}

void main() {
  late _FakeAccidentEventRemoteDataSource fakeDataSource;
  late AccidentEventRepositoryImpl repository;

  setUp(() {
    fakeDataSource = _FakeAccidentEventRemoteDataSource()..rowToReturn = _row();
    repository = AccidentEventRepositoryImpl(fakeDataSource);
  });

  group('AccidentEventRepositoryImpl', () {
    test('reportCandidate sends the sample as sensor_snapshot and userId as user_id', () async {
      final sample = _sample();

      final event = await repository.reportCandidate(
        userId: 'u1',
        sessionId: 's1',
        impactMps2: 25.0,
        gyroRadS: 3.2,
        gForce: 2.5,
        confidenceScore: 0.7,
        sample: sample,
      );

      expect(event.id, 'a1');
      expect(event.status, AccidentEventStatus.candidate);
      expect(fakeDataSource.lastInsertedRow!['user_id'], 'u1');
      expect(fakeDataSource.lastInsertedRow!['session_id'], 's1');
      expect(
        fakeDataSource.lastInsertedRow!['sensor_snapshot'],
        sample.toJson(),
      );
    });

    test('cancel updates the row to status=cancelled', () async {
      await repository.cancel('a1');

      expect(fakeDataSource.lastStatusUpdate, (id: 'a1', status: 'cancelled'));
    });

    test('confirm updates the row to status=confirmed', () async {
      await repository.confirm('a1');

      expect(fakeDataSource.lastStatusUpdate, (id: 'a1', status: 'confirmed'));
    });

    test('translates an ApiException into a DataException', () async {
      fakeDataSource.errorToThrow = const ApiException('permission denied', statusCode: 403);

      await expectLater(
        repository.confirm('a1'),
        throwsA(isA<DataException>()),
      );
    });

    test('fetchMine maps every row and forwards the userId', () async {
      fakeDataSource.rowsToReturn = [
        _row(status: 'confirmed'),
        _row(status: 'cancelled'),
      ];

      final events = await repository.fetchMine('u1');

      expect(fakeDataSource.lastFetchedUserId, 'u1');
      expect(events, hasLength(2));
      expect(events.map((e) => e.status), [
        AccidentEventStatus.confirmed,
        AccidentEventStatus.cancelled,
      ]);
    });

    test('fetchById returns the mapped AccidentEvent', () async {
      fakeDataSource.rowToReturn = _row(status: 'notified');

      final event = await repository.fetchById('a1');

      expect(event.id, 'a1');
      expect(event.status, AccidentEventStatus.notified);
    });
  });
}
