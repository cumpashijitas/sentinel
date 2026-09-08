import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/rides/data/datasources/android_background_location_service.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/location_tracker.dart';

class _FakeLocationTracker implements LocationTracker {
  bool permissionGranted = true;

  @override
  Future<bool> ensurePermission() async => permissionGranted;

  @override
  Future<bool> ensureBackgroundPermission() async => permissionGranted;

  @override
  Stream<LocationFix> watchPosition() => const Stream.empty();

  @override
  Future<LocationFix?> getCurrentFix() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.sentinel.app/background_location');
  final calls = <MethodCall>[];
  Object? Function(MethodCall)? handlerOverride;

  setUp(() {
    calls.clear();
    handlerOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return handlerOverride?.call(call);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AndroidBackgroundLocationService', () {
    test('start() sends the sessionId to the native channel', () async {
      final tracker = _FakeLocationTracker();
      final service = AndroidBackgroundLocationService(
        tracker: tracker,
        channel: channel,
      );

      await service.start('s1');

      expect(calls, hasLength(1));
      expect(calls.single.method, 'start');
      expect(calls.single.arguments, {'sessionId': 's1'});
    });

    test('start() throws without reaching the channel when permission is denied', () async {
      final tracker = _FakeLocationTracker()..permissionGranted = false;
      final service = AndroidBackgroundLocationService(
        tracker: tracker,
        channel: channel,
      );

      await expectLater(service.start('s1'), throwsA(isA<DataException>()));
      expect(calls, isEmpty);
    });

    test(
      'start() translates a native PERMISSION_DENIED into DataException',
      () async {
        handlerOverride = (call) =>
            throw PlatformException(code: 'PERMISSION_DENIED');
        final service = AndroidBackgroundLocationService(
          tracker: _FakeLocationTracker(),
          channel: channel,
        );

        await expectLater(service.start('s1'), throwsA(isA<DataException>()));
      },
    );

    test('stop() calls the native channel', () async {
      final service = AndroidBackgroundLocationService(
        tracker: _FakeLocationTracker(),
        channel: channel,
      );

      await service.stop();

      expect(calls.single.method, 'stop');
    });

    test('isRunning() returns the native result', () async {
      handlerOverride = (call) => true;
      final service = AndroidBackgroundLocationService(
        tracker: _FakeLocationTracker(),
        channel: channel,
      );

      expect(await service.isRunning(), isTrue);
    });

    test(
      'isRunning() defaults to false when the native side returns null',
      () async {
        handlerOverride = (call) => null;
        final service = AndroidBackgroundLocationService(
          tracker: _FakeLocationTracker(),
          channel: channel,
        );

        expect(await service.isRunning(), isFalse);
      },
    );
  });
}
