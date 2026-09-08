import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/rides/data/repositories/location_repository_impl.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/live_location_repository.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/location_tracker.dart';
import 'package:sentinel_v2/features/rides/domain/services/location_sampling_policy.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  AppUser? userOverride = _currentUser;

  @override
  AppUser? get currentUser => userOverride;

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(userOverride).asBroadcastStream();

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

LocationFix _fix({int secondsFromEpoch = 0}) => LocationFix(
  latitude: -17.3935,
  longitude: -66.1570,
  recordedAt: DateTime.utc(
    2026,
    8,
    27,
  ).add(Duration(seconds: secondsFromEpoch)),
);

class _FakeLocationTracker implements LocationTracker {
  bool permissionGranted = true;
  int listenerCount = 0;
  late final _controller = StreamController<LocationFix>.broadcast(
    onListen: () => listenerCount++,
    onCancel: () => listenerCount--,
  );

  void emit(LocationFix fix) => _controller.add(fix);

  @override
  Future<bool> ensurePermission() async => permissionGranted;

  @override
  Future<bool> ensureBackgroundPermission() async => permissionGranted;

  @override
  Stream<LocationFix> watchPosition() => _controller.stream;

  @override
  Future<LocationFix?> getCurrentFix() async => null;
}

class _FakeLiveLocationRepository implements LiveLocationRepository {
  final upsertedFixes = <LocationFix>[];
  final recordedFixes = <LocationFix>[];

  @override
  Stream<Map<String, LocationFix>> watchSessionLocations(String sessionId) =>
      const Stream.empty();

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) async {
    upsertedFixes.add(fix);
  }

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) async {
    recordedFixes.add(fix);
  }
}

void main() {
  late _FakeAuthRepository fakeAuthRepository;
  late _FakeLocationTracker fakeTracker;
  late _FakeLiveLocationRepository fakeLiveLocationRepository;
  late LocationRepositoryImpl repository;

  setUp(() {
    fakeAuthRepository = _FakeAuthRepository();
    fakeTracker = _FakeLocationTracker();
    fakeLiveLocationRepository = _FakeLiveLocationRepository();
    repository = LocationRepositoryImpl(
      tracker: fakeTracker,
      liveLocationRepository: fakeLiveLocationRepository,
      authRepository: fakeAuthRepository,
      // Every fix is far enough apart in these tests to always sample.
      samplingPolicy: const LocationSamplingPolicy(
        minDistanceMeters: 0,
        minInterval: Duration.zero,
      ),
    );
  });

  group('LocationRepositoryImpl', () {
    test('isSharing is false until startSharing succeeds', () async {
      expect(repository.isSharing, isFalse);

      await repository.startSharing('s1');

      expect(repository.isSharing, isTrue);
    });

    test(
      'throws when permission is denied, and does not start sharing',
      () async {
        fakeTracker.permissionGranted = false;

        await expectLater(
          () => repository.startSharing('s1'),
          throwsA(isA<DataException>()),
        );
        expect(repository.isSharing, isFalse);
      },
    );

    test('throws when there is no authenticated user', () async {
      fakeAuthRepository.userOverride = null;

      await expectLater(
        () => repository.startSharing('s1'),
        throwsA(isA<DataException>()),
      );
    });

    test('pushes every tracker fix to upsertMyLocation', () async {
      await repository.startSharing('s1');

      fakeTracker.emit(_fix());
      fakeTracker.emit(_fix(secondsFromEpoch: 1));
      await Future<void>.delayed(Duration.zero);

      expect(fakeLiveLocationRepository.upsertedFixes, hasLength(2));
    });

    test('stopSharing stops forwarding further fixes', () async {
      await repository.startSharing('s1');
      fakeTracker.emit(_fix());
      await Future<void>.delayed(Duration.zero);

      await repository.stopSharing();
      fakeTracker.emit(_fix(secondsFromEpoch: 1));
      await Future<void>.delayed(Duration.zero);

      expect(fakeLiveLocationRepository.upsertedFixes, hasLength(1));
      expect(repository.isSharing, isFalse);
      expect(fakeTracker.listenerCount, 0);
    });

    test(
      'starting a new session while already sharing switches cleanly',
      () async {
        await repository.startSharing('s1');
        await repository.startSharing('s2'); // should not throw / double-listen

        // Exactly one active subscription — proves the old one was torn down
        // instead of stacking a second alongside it.
        expect(fakeTracker.listenerCount, 1);

        fakeTracker.emit(_fix());
        await Future<void>.delayed(Duration.zero);

        expect(fakeLiveLocationRepository.upsertedFixes, hasLength(1));
      },
    );
  });
}
