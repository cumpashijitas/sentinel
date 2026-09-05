import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/data/repositories/accident_monitor_service_impl.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';
import 'package:sentinel_v2/features/accidents/domain/repositories/accident_alert_notifier.dart';
import 'package:sentinel_v2/features/accidents/domain/repositories/accident_event_repository.dart';
import 'package:sentinel_v2/features/accidents/domain/repositories/motion_tracker.dart';
import 'package:sentinel_v2/features/accidents/domain/services/accident_detection_service.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';

MotionSample _impactSample() => MotionSample(
  accelX: 0,
  accelY: 0,
  accelZ: gravityMps2 + 40, // comfortably over the default threshold
  recordedAt: DateTime.now().toUtc(),
);

MotionSample _restingSample() => MotionSample(
  accelX: 0,
  accelY: 0,
  accelZ: gravityMps2,
  recordedAt: DateTime.now().toUtc(),
);

class _FakeMotionTracker implements MotionTracker {
  bool available = true;
  final _controller = StreamController<MotionSample>.broadcast();

  void emit(MotionSample sample) => _controller.add(sample);

  @override
  Future<bool> isAvailable() async => available;

  @override
  Stream<MotionSample> watchMotion() => _controller.stream;
}

class _FakeAccidentEventRepository implements AccidentEventRepository {
  int nextId = 1;
  final reported = <String>[]; // ids returned, in order
  final cancelled = <String>[];
  final confirmed = <String>[];

  @override
  Future<AccidentEvent> reportCandidate({
    required String userId,
    required String? sessionId,
    required double impactMps2,
    double? gyroRadS,
    double? gForce,
    double? confidenceScore,
    double? latitude,
    double? longitude,
    required MotionSample sample,
  }) async {
    final id = 'a${nextId++}';
    reported.add(id);
    return AccidentEvent(
      id: id,
      sessionId: sessionId,
      userId: userId,
      impactMps2: impactMps2,
      gyroRadS: gyroRadS,
      gForce: gForce,
      confidenceScore: confidenceScore,
      status: AccidentEventStatus.candidate,
      occurredAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> cancel(String accidentEventId) async =>
      cancelled.add(accidentEventId);

  @override
  Future<void> confirm(String accidentEventId) async =>
      confirmed.add(accidentEventId);

  @override
  Future<List<AccidentEvent>> fetchMine(String userId) =>
      throw UnimplementedError();

  @override
  Future<AccidentEvent> fetchById(String accidentEventId) =>
      throw UnimplementedError();
}

class _FakeAccidentAlertNotifier implements AccidentAlertNotifier {
  void Function(String accidentEventId)? _onConfirmedOk;
  String? shownFor;
  bool dismissed = false;

  void tapImOk(String accidentEventId) => _onConfirmedOk?.call(accidentEventId);

  @override
  Future<void> initialize({
    required void Function(String accidentEventId) onConfirmedOk,
  }) async => _onConfirmedOk = onConfirmedOk;

  @override
  Future<void> showAlert({
    required String accidentEventId,
    required Duration countdown,
  }) async {
    shownFor = accidentEventId;
    dismissed = false;
  }

  @override
  Future<void> dismissAlert() async => dismissed = true;
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.currentUser);

  @override
  AppUser? currentUser;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(currentUser);

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

void main() {
  late _FakeMotionTracker fakeMotionTracker;
  late _FakeAccidentEventRepository fakeRepository;
  late _FakeAccidentAlertNotifier fakeNotifier;
  late _FakeAuthRepository fakeAuthRepository;

  AccidentMonitorServiceImpl buildService({
    Duration countdown = const Duration(milliseconds: 30),
  }) {
    return AccidentMonitorServiceImpl(
      motionTracker: fakeMotionTracker,
      accidentEventRepository: fakeRepository,
      alertNotifier: fakeNotifier,
      authRepository: fakeAuthRepository,
      countdown: countdown,
    );
  }

  setUp(() {
    fakeMotionTracker = _FakeMotionTracker();
    fakeRepository = _FakeAccidentEventRepository();
    fakeNotifier = _FakeAccidentAlertNotifier();
    fakeAuthRepository = _FakeAuthRepository(
      const AppUser(id: 'u1', email: 'rider1@sentinel.dev'),
    );
  });

  group('AccidentMonitorServiceImpl', () {
    test('an impact sample reports a candidate and shows the alert', () async {
      final service = buildService();
      await service.start('s1');

      fakeMotionTracker.emit(_impactSample());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(fakeRepository.reported, ['a1']);
      expect(fakeNotifier.shownFor, 'a1');
    });

    test('a resting sample never reports anything', () async {
      final service = buildService();
      await service.start('s1');

      fakeMotionTracker.emit(_restingSample());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(fakeRepository.reported, isEmpty);
    });

    test(
      'tapping "Estoy bien" before the countdown elapses cancels, not confirms',
      () async {
        final service = buildService(countdown: const Duration(seconds: 5));
        await service.start('s1');

        fakeMotionTracker.emit(_impactSample());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        fakeNotifier.tapImOk('a1');
        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(fakeRepository.cancelled, ['a1']);
        expect(fakeRepository.confirmed, isEmpty);
        expect(fakeNotifier.dismissed, isTrue);
      },
    );

    test('no response before the countdown elapses auto-confirms', () async {
      final service = buildService(); // 30ms countdown
      await service.start('s1');

      fakeMotionTracker.emit(_impactSample());
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(fakeRepository.confirmed, ['a1']);
      expect(fakeRepository.cancelled, isEmpty);
      expect(fakeNotifier.dismissed, isTrue);
    });

    test(
      'a second impact while a candidate is still pending is ignored',
      () async {
        final service = buildService(countdown: const Duration(seconds: 5));
        await service.start('s1');

        fakeMotionTracker.emit(_impactSample());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        fakeMotionTracker.emit(_impactSample());
        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(fakeRepository.reported, ['a1']); // not a2
      },
    );

    test(
      'stop() while a countdown is pending resolves it as cancelled',
      () async {
        final service = buildService(countdown: const Duration(seconds: 5));
        await service.start('s1');

        fakeMotionTracker.emit(_impactSample());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await service.stop();

        expect(fakeRepository.cancelled, ['a1']);
        expect(fakeRepository.confirmed, isEmpty);
      },
    );

    test(
      'stop() then a late sensor emission does nothing (subscription released)',
      () async {
        final service = buildService();
        await service.start('s1');
        await service.stop();

        fakeMotionTracker.emit(_impactSample());
        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(fakeRepository.reported, isEmpty);
      },
    );

    test(
      'does not subscribe at all when no accelerometer is available',
      () async {
        fakeMotionTracker.available = false;
        final service = buildService();
        await service.start('s1');

        fakeMotionTracker.emit(_impactSample());
        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(fakeRepository.reported, isEmpty);
      },
    );

    test('drops a candidate silently when no user is signed in', () async {
      fakeAuthRepository.currentUser = null;
      final service = buildService();
      await service.start('s1');

      fakeMotionTracker.emit(_impactSample());
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(fakeRepository.reported, isEmpty);
    });
  });
}
