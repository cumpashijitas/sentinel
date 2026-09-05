import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/presentation/controllers/accident_event_providers.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/history/presentation/controllers/history_controller.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';

import '../../support/fakes.dart';

RideHistoryEntry _ride(String id) => RideHistoryEntry(
  sessionId: id,
  groupId: 'g1',
  groupName: 'Los Nómadas',
  status: RideSessionStatus.finished,
  startedAt: DateTime.utc(2026, 8, 27, 8),
  endedAt: DateTime.utc(2026, 8, 27, 9),
);

AccidentEvent _accident(String id) => AccidentEvent(
  id: id,
  userId: 'u1',
  impactMps2: 30,
  status: AccidentEventStatus.confirmed,
  occurredAt: DateTime.utc(2026, 8, 27),
);

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeRideSessionRepository fakeRideSessionRepository;
  late FakeAccidentEventRepository fakeAccidentEventRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeRideSessionRepository = FakeRideSessionRepository();
    fakeAccidentEventRepository = FakeAccidentEventRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        rideSessionRepositoryProvider.overrideWithValue(
          fakeRideSessionRepository,
        ),
        accidentEventRepositoryProvider.overrideWithValue(
          fakeAccidentEventRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  // See docs/architecture.md: a bare ProviderContainer needs an active
  // listener to keep an auto-dispose async provider alive across an `await`
  // on its `.future` — added per test, *after* the fake's fixture data is
  // set, since listening also triggers the provider's first build: doing
  // it in `setUp()` (before any test sets its fixtures) would build once
  // against empty fakes and cache that result for every test.

  group('rideHistoryProvider', () {
    test('returns an empty list without an authenticated user', () async {
      fakeAuthRepository.userOverride = null;
      container.listen(rideHistoryProvider, (_, _) {});

      final history = await container.read(rideHistoryProvider.future);

      expect(history, isEmpty);
    });

    test('fetches history for the signed-in user', () async {
      fakeRideSessionRepository.historyToReturn = [_ride('s1')];
      container.listen(rideHistoryProvider, (_, _) {});

      final history = await container.read(rideHistoryProvider.future);

      expect(history, hasLength(1));
      expect(fakeRideSessionRepository.lastRequestedUserId, 'u1');
    });
  });

  group('accidentHistoryProvider', () {
    test('returns an empty list without an authenticated user', () async {
      fakeAuthRepository.userOverride = null;
      container.listen(accidentHistoryProvider, (_, _) {});

      final history = await container.read(accidentHistoryProvider.future);

      expect(history, isEmpty);
    });

    test("fetches the signed-in user's accident history", () async {
      fakeAccidentEventRepository.historyToReturn = [_accident('a1')];
      container.listen(accidentHistoryProvider, (_, _) {});

      final history = await container.read(accidentHistoryProvider.future);

      expect(history, hasLength(1));
    });
  });

  group('accidentDetailProvider', () {
    test('fetches a single accident event by id', () async {
      fakeAccidentEventRepository.byIdToReturn = _accident('a1');
      container.listen(accidentDetailProvider('a1'), (_, _) {});

      final event = await container.read(accidentDetailProvider('a1').future);

      expect(event.id, 'a1');
    });
  });

  group('rideStatisticsProvider', () {
    test('derives statistics from ride and accident history', () async {
      fakeRideSessionRepository.historyToReturn = [_ride('s1'), _ride('s2')];
      fakeAccidentEventRepository.historyToReturn = [_accident('a1')];
      container.listen(rideStatisticsProvider, (_, _) {});

      final stats = await container.read(rideStatisticsProvider.future);

      expect(stats.totalRides, 2);
      expect(stats.totalAccidents, 1);
      expect(stats.totalRideDuration, const Duration(hours: 2));
    });
  });
}
