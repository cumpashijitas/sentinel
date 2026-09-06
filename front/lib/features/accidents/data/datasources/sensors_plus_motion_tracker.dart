import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

import '../../domain/entities/motion_sample.dart';
import '../../domain/repositories/motion_tracker.dart';

/// The one and only place `package:sensors_plus` is imported in this app —
/// see [MotionTracker]'s doc comment for the raw-vs-gravity-compensated
/// reasoning.
class SensorsPlusMotionTracker implements MotionTracker {
  const SensorsPlusMotionTracker();

  @override
  Future<bool> isAvailable() async {
    try {
      await accelerometerEventStream().first.timeout(
        const Duration(seconds: 3),
      );
      return true;
    } catch (_) {
      // Times out (no sensor) or throws (platform reports unsupported) —
      // either way, not available.
      return false;
    }
  }

  @override
  Stream<MotionSample> watchMotion() {
    GyroscopeEvent? lastGyro;
    late final StreamController<MotionSample> controller;
    StreamSubscription<GyroscopeEvent>? gyroSubscription;
    StreamSubscription<AccelerometerEvent>? accelSubscription;

    controller = StreamController<MotionSample>.broadcast(
      onListen: () {
        gyroSubscription = gyroscopeEventStream().listen(
          (event) => lastGyro = event,
        );
        accelSubscription = accelerometerEventStream().listen((event) {
          final gyro = lastGyro;
          controller.add(
            MotionSample(
              accelX: event.x,
              accelY: event.y,
              accelZ: event.z,
              gyroX: gyro?.x,
              gyroY: gyro?.y,
              gyroZ: gyro?.z,
              // Deliberately `DateTime.now().toUtc()`, not
              // `event.timestamp`: sensors_plus documents that field as
              // platform uptime (Android: `SensorEvent.timestamp`, device
              // boot-relative), not wall-clock time — the exact same trap
              // `GeolocatorLocationTracker` hit with `position.timestamp`
              // in Fase 5 (see its doc comment). Using it here would
              // silently corrupt `accident_events.occurred_at`.
              recordedAt: DateTime.now().toUtc(),
            ),
          );
        });
      },
      onCancel: () async {
        await gyroSubscription?.cancel();
        await accelSubscription?.cancel();
        await controller.close();
      },
    );

    return controller.stream;
  }
}
