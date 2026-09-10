import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/entities/member_location.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/background_location_service.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/live_location_repository.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/location_repository.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/live_tracking_controller.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';

RideSessionParticipant _participant(String userId) => RideSessionParticipant(
  sessionId: 's1',
  userId: userId,
  status: RideParticipantStatus.active,
  joinedAt: DateTime.utc(2026, 8, 27),
  displayName: userId,
);

LocationFix _fixNow() => LocationFix(
  latitude: -17.3935,
  longitude: -66.1570,
  recordedAt: DateTime.now(),
);

class _FakeLiveLocationRepository implements LiveLocationRepository {
  int listenerCount = 0;
  late final _controller = StreamController<Map<String, LocationFix>>.broadcast(
    onListen: () => listenerCount++,
    onCancel: () => listenerCount--,
  );

  void emit(Map<String, LocationFix> fixes) => _controller.add(fixes);

  @override
  Stream<Map<String, LocationFix>> watchSessionLocations(String sessionId) =>
      _controller.stream;

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) => throw UnimplementedError();

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) => throw UnimplementedError();
}

class _FakeLocationRepository implements LocationRepository {
  bool _sharing = false;
  Object? errorToThrow;
  String? lastStartedSessionId;

  @override
  bool get isSharing => _sharing;

  @override
  Future<void> startSharing(String sessionId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastStartedSessionId = sessionId;
    _sharing = true;
  }

  @override
  Future<void> stopSharing() async {
    _sharing = false;
  }
}

class _FakeBackgroundLocationService implements BackgroundLocationService {
  bool _running = false;
  Object? errorToThrow;
  String? lastStartedSessionId;

  @override
  Future<void> start({
    required String trackingId,
    required BackgroundTrackingKind kind,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastStartedSessionId = trackingId;
    _running = true;
  }

  @override
  Future<void> stop() async {
    _running = false;
  }

  @override
  Future<bool> isRunning() async => _running;
}

void main() {
  group('sessionMemberLocationsProvider', () {
    test(
      'combines participants and the live-location stream into a roster',
      () async {
        final fakeLiveLocationRepository = _FakeLiveLocationRepository();
        final container = ProviderContainer(
          overrides: [
            rideParticipantsProvider('s1')
                .overrideWith((ref) async => [_participant('u1')]),
            liveLocationRepositoryProvider.overrideWithValue(
              fakeLiveLocationRepository,
            ),
          ],
        );
        addTearDown(container.dispose);

        final states = <List<MemberLocation>>[];
        final sub = container.listen(sessionMemberLocationsProvider('s1'), (
          previous,
          next,
        ) {
          final value = next.value;
          if (value != null) states.add(value);
        }, fireImmediately: true);
        addTearDown(sub.close);

        // Let the provider's async* body finish awaiting
        // `rideParticipantsProvider(...).future` and subscribe to
        // `watchSessionLocations` before emitting — otherwise the broadcast
        // stream has no listener yet and the event is dropped.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        fakeLiveLocationRepository.emit({'u1': _fixNow()});
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(states, isNotEmpty);
        expect(states.last.single.userId, 'u1');
        expect(states.last.single.status, MemberTrackingStatus.active);
      },
    );

    test(
      'stops updating once disposed (Realtime subscription released)',
      () async {
        final fakeLiveLocationRepository = _FakeLiveLocationRepository();
        final container = ProviderContainer(
          overrides: [
            rideParticipantsProvider('s1')
                .overrideWith((ref) async => [_participant('u1')]),
            liveLocationRepositoryProvider.overrideWithValue(
              fakeLiveLocationRepository,
            ),
          ],
        );

        final sub = container.listen(
          sessionMemberLocationsProvider('s1'),
          (previous, next) {},
          fireImmediately: true,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(fakeLiveLocationRepository.listenerCount, 1);

        sub.close();
        container.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // The provider's internal subscription to watchSessionLocations was
        // actually cancelled on disposal, not left dangling — this is what
        // releases the underlying Realtime channel in the real
        // implementation (see LiveLocationRepositoryImpl).
        expect(fakeLiveLocationRepository.listenerCount, 0);
      },
    );
  });

  // `flutter test`'s `defaultTargetPlatform` is Android by default (and
  // `kIsWeb` is always false in the VM), so `PlatformCapabilities.isAndroid`
  // is true unless overridden — these two groups exercise
  // `LiveTrackingController`'s platform branch (Fase 6) each way. "Web" here
  // means only "not Android" as far as `debugDefaultTargetPlatformOverride`
  // is concerned — the app has no third target, so this is exactly the
  // condition the controller itself branches on, not a claim that iOS
  // behaves like Web.
  group('LiveTrackingController on Android (default test platform)', () {
    test(
      'start() delegates to BackgroundLocationService, not LocationRepository',
      () async {
        final fakeBackgroundService = _FakeBackgroundLocationService();
        final container = ProviderContainer(
          overrides: [
            backgroundLocationServiceProvider.overrideWithValue(
              fakeBackgroundService,
            ),
            locationRepositoryProvider.overrideWithValue(
              _FakeLocationRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(liveTrackingControllerProvider.notifier)
            .start('s1');

        expect(fakeBackgroundService.lastStartedSessionId, 's1');
        expect(await fakeBackgroundService.isRunning(), isTrue);
        expect(
          container.read(liveTrackingControllerProvider).hasError,
          isFalse,
        );
      },
    );

    test('surfaces a startSharing failure as an error state', () async {
      final fakeBackgroundService = _FakeBackgroundLocationService()
        ..errorToThrow = Exception('permission denied');
      final container = ProviderContainer(
        overrides: [
          backgroundLocationServiceProvider.overrideWithValue(
            fakeBackgroundService,
          ),
          locationRepositoryProvider.overrideWithValue(
            _FakeLocationRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(liveTrackingControllerProvider.notifier).start('s1');

      expect(container.read(liveTrackingControllerProvider).hasError, isTrue);
    });

    test('stop() delegates to BackgroundLocationService', () async {
      final fakeBackgroundService = _FakeBackgroundLocationService();
      final container = ProviderContainer(
        overrides: [
          backgroundLocationServiceProvider.overrideWithValue(
            fakeBackgroundService,
          ),
          locationRepositoryProvider.overrideWithValue(
            _FakeLocationRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(liveTrackingControllerProvider.notifier).start('s1');
      await container.read(liveTrackingControllerProvider.notifier).stop();

      expect(await fakeBackgroundService.isRunning(), isFalse);
    });
  });

  group('LiveTrackingController on Web (non-Android)', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('start() calls LocationRepository.startSharing', () async {
      final fakeLocationRepository = _FakeLocationRepository();
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(fakeLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(liveTrackingControllerProvider.notifier).start('s1');

      expect(fakeLocationRepository.lastStartedSessionId, 's1');
      expect(fakeLocationRepository.isSharing, isTrue);
      expect(container.read(liveTrackingControllerProvider).hasError, isFalse);
    });

    test('surfaces a startSharing failure as an error state', () async {
      final fakeLocationRepository = _FakeLocationRepository()
        ..errorToThrow = Exception('permission denied');
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(fakeLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(liveTrackingControllerProvider.notifier).start('s1');

      expect(container.read(liveTrackingControllerProvider).hasError, isTrue);
    });

    test('stop() calls LocationRepository.stopSharing', () async {
      final fakeLocationRepository = _FakeLocationRepository();
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(fakeLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(liveTrackingControllerProvider.notifier).start('s1');
      await container.read(liveTrackingControllerProvider.notifier).stop();

      expect(fakeLocationRepository.isSharing, isFalse);
    });
  });
}
