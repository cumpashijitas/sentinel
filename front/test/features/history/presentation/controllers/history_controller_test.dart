import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/presentation/controllers/accident_event_providers.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/emergency_shares/domain/entities/emergency_share.dart';
import 'package:sentinel_v2/features/emergency_shares/presentation/controllers/emergency_share_providers.dart';
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

EmergencyShare _share(
  String id, {
  DateTime? startedAt,
  DateTime? endedAt,
}) => EmergencyShare(
  id: id,
  userId: 'u1',
  shareToken: 'tok-$id',
  status: EmergencyShareStatus.ended,
  startedAt: startedAt ?? DateTime.utc(2026, 8, 27, 10),
  endedAt: endedAt ?? DateTime.utc(2026, 8, 27, 10, 30),
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
  late FakeEmergencyShareRepository fakeEmergencyShareRepository;
  late FakeAccidentEventRepository fakeAccidentEventRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeRideSessionRepository = FakeRideSessionRepository();
    fakeEmergencyShareRepository = FakeEmergencyShareRepository();
    fakeAccidentEventRepository = FakeAccidentEventRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        rideSessionRepositoryProvider.overrideWithValue(
          fakeRideSessionRepository,
        ),
        emergencyShareRepositoryProvider.overrideWithValue(
          fakeEmergencyShareRepository,
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

  group('shareHistoryProvider', () {
    test('returns an empty list without an authenticated user', () async {
      fakeAuthRepository.userOverride = null;
      container.listen(shareHistoryProvider, (_, _) {});

      final history = await container.read(shareHistoryProvider.future);

      expect(history, isEmpty);
    });

    test('fetches ended shares for the signed-in user', () async {
      fakeEmergencyShareRepository.historyToReturn = [_share('sh1')];
      container.listen(shareHistoryProvider, (_, _) {});

      final history = await container.read(shareHistoryProvider.future);

      expect(history, hasLength(1));
    });
  });

  group('routeHistoryProvider', () {
    test('merges group rides and individual shares, newest first', () async {
      fakeRideSessionRepository.historyToReturn = [
        _ride('s1'), // startedAt 2026-08-27 08:00
      ];
      fakeEmergencyShareRepository.historyToReturn = [
        _share('sh1', startedAt: DateTime.utc(2026, 8, 27, 12)),
      ];
      container.listen(routeHistoryProvider, (_, _) {});

      final routes = await container.read(routeHistoryProvider.future);

      expect(routes, hasLength(2));
      // El share (12:00) es más reciente que el ride (08:00).
      expect(routes.first.isGroup, isFalse);
      expect(routes.last.isGroup, isTrue);
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
      expect(stats.totalIndividualRides, 0);
    });

    test('folds individual shares into the totals too', () async {
      fakeRideSessionRepository.historyToReturn = [_ride('s1')];
      fakeEmergencyShareRepository.historyToReturn = [
        _share(
          'sh1',
          startedAt: DateTime.utc(2026, 8, 27, 10),
          endedAt: DateTime.utc(2026, 8, 27, 10, 45),
        ),
      ];
      container.listen(rideStatisticsProvider, (_, _) {});

      final stats = await container.read(rideStatisticsProvider.future);

      expect(stats.totalIndividualRides, 1);
      expect(stats.totalIndividualRideDuration, const Duration(minutes: 45));
      expect(stats.totalActivities, 2);
    });
  });
}
