import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/rides/data/datasources/ride_session_remote_datasource.dart';
import 'package:sentinel_v2/features/rides/data/repositories/ride_session_repository_impl.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';

Map<String, dynamic> _sessionRow({
  String id = 's1',
  String status = 'active',
}) => {
  'id': id,
  'group_id': 'g1',
  'started_by': 'u1',
  'name': 'Salida domingo',
  'status': status,
  'started_at': '2026-08-27T12:00:00.000Z',
  'ended_at': null,
  'created_at': '2026-08-27T12:00:00.000Z',
};

Map<String, dynamic> _participantRow({String userId = 'u1'}) => {
  'session_id': 's1',
  'user_id': userId,
  'status': 'active',
  'joined_at': '2026-08-27T12:00:00.000Z',
  'left_at': null,
  'last_seen_at': null,
};

Map<String, dynamic> _profileRow({
  String id = 'u1',
  String displayName = 'Ana Rider',
}) => {'id': id, 'display_name': displayName, 'avatar_url': null};

/// A `ride_session_members` row with `ride_sessions`/`ride_groups`
/// embedded, matching the shape `fetchHistoryRows`' PostgREST nested
/// select actually returns.
Map<String, dynamic> _historyRow({
  String sessionId = 's1',
  String status = 'finished',
  String? groupName = 'Los Nómadas',
  DateTime? startedAt,
  DateTime? endedAt,
}) => {
  'session_id': sessionId,
  'ride_sessions': {
    'id': sessionId,
    'group_id': 'g1',
    'name': 'Salida domingo',
    'status': status,
    'started_at': (startedAt ?? DateTime.utc(2026, 8, 27, 8)).toIso8601String(),
    'ended_at': (endedAt ?? DateTime.utc(2026, 8, 27, 10)).toIso8601String(),
    'ride_groups': groupName == null ? null : {'name': groupName},
  },
};

class _FakeRideSessionRemoteDataSource implements RideSessionRemoteDataSource {
  Map<String, dynamic>? activeSessionToReturn;
  Map<String, dynamic>? sessionToReturn;
  List<Map<String, dynamic>> participantsToReturn = [];
  List<Map<String, dynamic>> profilesToReturn = [];
  List<Map<String, dynamic>> historyRowsToReturn = [];
  Object? errorToThrow;

  @override
  Future<Map<String, dynamic>?> fetchActiveSession(String groupId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return activeSessionToReturn;
  }

  @override
  Future<Map<String, dynamic>> fetchSession(String sessionId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return sessionToReturn!;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchParticipants(
    String sessionId,
  ) async => participantsToReturn;

  @override
  Future<List<Map<String, dynamic>>> fetchProfiles(
    List<String> userIds,
  ) async => profilesToReturn.where((p) => userIds.contains(p['id'])).toList();

  @override
  Future<Map<String, dynamic>> startSession({
    required String groupId,
    String? name,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return sessionToReturn!;
  }

  @override
  Future<Map<String, dynamic>> finishSession(String sessionId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return sessionToReturn!;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistoryRows(String userId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return historyRowsToReturn;
  }
}

void main() {
  late _FakeRideSessionRemoteDataSource dataSource;
  late RideSessionRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeRideSessionRemoteDataSource();
    repository = RideSessionRepositoryImpl(dataSource);
  });

  group('RideSessionRepositoryImpl', () {
    test('fetchActiveSession returns null when there is none', () async {
      dataSource.activeSessionToReturn = null;

      final session = await repository.fetchActiveSession('g1');

      expect(session, isNull);
    });

    test('fetchActiveSession maps the row when one exists', () async {
      dataSource.activeSessionToReturn = _sessionRow();

      final session = await repository.fetchActiveSession('g1');

      expect(session?.id, 's1');
    });

    test(
      'fetchParticipants merges membership rows with profile data',
      () async {
        dataSource.participantsToReturn = [
          _participantRow(),
          _participantRow(userId: 'u2'),
        ];
        dataSource.profilesToReturn = [
          _profileRow(),
          _profileRow(id: 'u2', displayName: 'Bruno Rider'),
        ];

        final participants = await repository.fetchParticipants('s1');

        expect(participants, hasLength(2));
        expect(participants[0].displayName, 'Ana Rider');
        expect(participants[0].status, RideParticipantStatus.active);
        expect(participants[1].displayName, 'Bruno Rider');
      },
    );

    test('fetchParticipants falls back to a placeholder name for a missing profile', () async {
      dataSource.participantsToReturn = [_participantRow(userId: 'u9')];
      dataSource.profilesToReturn = [];

      final participants = await repository.fetchParticipants('s1');

      expect(participants.single.displayName, 'Motociclista');
    });

    test('startSession returns the started RideSession', () async {
      dataSource.sessionToReturn = _sessionRow();

      final session = await repository.startSession(groupId: 'g1');

      expect(session.id, 's1');
    });

    test('finishSession returns the finished RideSession', () async {
      dataSource.sessionToReturn = _sessionRow(status: 'finished');

      final session = await repository.finishSession('s1');

      expect(session.status.name, 'finished');
    });

    test(
      'translates the RPC "already has an active session" message to Spanish',
      () async {
        dataSource.errorToThrow = const ApiException(
          'this group already has an active ride session',
          statusCode: 409,
        );

        await expectLater(
          () => repository.startSession(groupId: 'g1'),
          throwsA(
            isA<DataException>().having(
              (e) => e.message,
              'message',
              'Este grupo ya tiene un viaje en curso.',
            ),
          ),
        );
      },
    );

    test('translates the RPC "already <status>" message (with interpolated status) to Spanish', () async {
      dataSource.errorToThrow = const ApiException(
        'this ride session is already finished',
        statusCode: 409,
      );

      await expectLater(
        () => repository.finishSession('s1'),
        throwsA(
          isA<DataException>().having(
            (e) => e.message,
            'message',
            'Este viaje ya no está activo.',
          ),
        ),
      );
    });

    test(
      'translates the RPC "only owner or admin" message to Spanish',
      () async {
        dataSource.errorToThrow = const ApiException(
          'only the group owner or an admin can start a ride session',
          statusCode: 403,
        );

        await expectLater(
          () => repository.startSession(groupId: 'g1'),
          throwsA(
            isA<DataException>().having(
              (e) => e.message,
              'message',
              'Solo el propietario o un admin del grupo puede hacer esto.',
            ),
          ),
        );
      },
    );

    test('fetchHistory maps a finished session with its group name', () async {
      dataSource.historyRowsToReturn = [_historyRow()];

      final history = await repository.fetchHistory('u1');

      expect(history, hasLength(1));
      expect(history.single.sessionId, 's1');
      expect(history.single.groupName, 'Los Nómadas');
      expect(history.single.status, RideSessionStatus.finished);
      expect(history.single.duration, const Duration(hours: 2));
    });

    test('fetchHistory excludes waiting/active sessions', () async {
      dataSource.historyRowsToReturn = [
        _historyRow(status: 'active'),
        _historyRow(sessionId: 's2'),
      ];

      final history = await repository.fetchHistory('u1');

      expect(history.map((e) => e.sessionId), ['s2']);
    });

    test('fetchHistory skips a row whose session no longer embeds', () async {
      dataSource.historyRowsToReturn = [
        {'session_id': 's1', 'ride_sessions': null},
        _historyRow(sessionId: 's2'),
      ];

      final history = await repository.fetchHistory('u1');

      expect(history.map((e) => e.sessionId), ['s2']);
    });

    test('fetchHistory sorts newest first', () async {
      dataSource.historyRowsToReturn = [
        _historyRow(startedAt: DateTime.utc(2026, 8)),
        _historyRow(sessionId: 's2', startedAt: DateTime.utc(2026, 8, 20)),
      ];

      final history = await repository.fetchHistory('u1');

      expect(history.map((e) => e.sessionId), ['s2', 's1']);
    });
  });
}
