import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/ride_session_repository.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';

RideSession _session({
  String id = 's1',
  RideSessionStatus status = RideSessionStatus.active,
}) => RideSession(
  id: id,
  groupId: 'g1',
  startedBy: 'u1',
  status: status,
  startedAt: DateTime.utc(2026, 8, 27),
  createdAt: DateTime.utc(2026, 8, 27),
);

class _FakeRideSessionRepository implements RideSessionRepository {
  RideSession? active;
  Object? errorToThrow;
  String? lastFinishedId;

  @override
  Future<RideSession?> fetchActiveSession(String groupId) async => active;

  @override
  Future<RideSession> fetchSession(String sessionId) async =>
      active ?? _session(id: sessionId);

  @override
  Future<List<RideSessionParticipant>> fetchParticipants(
    String sessionId,
  ) async => const [];

  @override
  Future<RideSession> startSession({
    required String groupId,
    String? name,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    active = _session();
    return active!;
  }

  @override
  Future<RideSession> finishSession(String sessionId) async {
    lastFinishedId = sessionId;
    final error = errorToThrow;
    if (error != null) throw error;
    final finished = _session(
      id: sessionId,
      status: RideSessionStatus.finished,
    );
    active = null;
    return finished;
  }

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) =>
      throw UnimplementedError();
}

void main() {
  late _FakeRideSessionRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = _FakeRideSessionRepository();
    container = ProviderContainer(
      overrides: [
        rideSessionRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    // See docs/architecture.md: a bare ProviderContainer needs an active
    // listener to keep an async provider alive across an `await`.
    container.listen(activeSessionProvider('g1'), (_, _) {});
  });

  group('RideSessionActionsController.start', () {
    test(
      'returns the started session and refreshes activeSessionProvider',
      () async {
        await container.read(activeSessionProvider('g1').future);

        final started = await container
            .read(rideSessionActionsControllerProvider.notifier)
            .start(groupId: 'g1');

        expect(started?.id, 's1');
        final active = await container.read(activeSessionProvider('g1').future);
        expect(active?.id, 's1');
      },
    );

    test('returns null and sets an error on failure', () async {
      fakeRepository.errorToThrow = Exception('boom');

      final started = await container
          .read(rideSessionActionsControllerProvider.notifier)
          .start(groupId: 'g1');

      expect(started, isNull);
      expect(
        container.read(rideSessionActionsControllerProvider).hasError,
        isTrue,
      );
    });
  });

  group('RideSessionActionsController.finish', () {
    test('finishes the session and clears activeSessionProvider', () async {
      fakeRepository.active = _session();
      await container.read(activeSessionProvider('g1').future);

      final finished = await container
          .read(rideSessionActionsControllerProvider.notifier)
          .finish(sessionId: 's1', groupId: 'g1');

      expect(fakeRepository.lastFinishedId, 's1');
      expect(finished?.status, RideSessionStatus.finished);
      final active = await container.read(activeSessionProvider('g1').future);
      expect(active, isNull);
    });
  });
}
