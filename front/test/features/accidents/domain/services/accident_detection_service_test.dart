import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';
import 'package:sentinel_v2/features/accidents/domain/services/accident_detection_service.dart';

final _now = DateTime.utc(2026, 8, 28, 12);

MotionSample _sample({
  double accelX = 0,
  double accelY = 0,
  double accelZ = gravityMps2, // resting, flat, facing up
  double? gyroX,
  double? gyroY,
  double? gyroZ,
  DateTime? at,
}) => MotionSample(
  accelX: accelX,
  accelY: accelY,
  accelZ: accelZ,
  gyroX: gyroX,
  gyroY: gyroY,
  gyroZ: gyroZ,
  recordedAt: at ?? _now,
);

void main() {
  group('AccidentDetectionService.evaluate', () {
    // Exercises the class's own defaults: 20 m/s² delta, 4 rad/s gyro, 60s cooldown.
    const service = AccidentDetectionService();

    test('a resting reading (just gravity) is never a candidate', () {
      final result = service.evaluate(sample: _sample(), now: _now);

      expect(result, isNull);
    });

    test('a reading just under the impact threshold is not a candidate', () {
      // gravity + 19 m/s² on one axis ≈ under the 20 m/s² delta threshold.
      final result = service.evaluate(
        sample: _sample(accelZ: gravityMps2 + 19),
        now: _now,
      );

      expect(result, isNull);
    });

    test('a reading over the impact threshold is a candidate', () {
      final result = service.evaluate(
        sample: _sample(accelZ: gravityMps2 + 25),
        now: _now,
      );

      expect(result, isNotNull);
      expect(result!.impactMps2, closeTo(25, 0.001));
      expect(result.gForce, closeTo((gravityMps2 + 25) / gravityMps2, 0.001));
    });

    test('a sudden drop in acceleration also counts (magnitude delta, not direction)', () {
      // Free-fall-ish (near-zero magnitude) is at most ~9.8 m/s² away from
      // resting gravity — below the *default* 20 m/s² threshold, so this
      // needs a lower threshold to demonstrate the drop direction works
      // the same as a spike, not just the default config.
      const sensitive = AccidentDetectionService(
        config: AccidentDetectionConfig(impactDeltaThresholdMps2: 5),
      );

      final result = sensitive.evaluate(sample: _sample(accelZ: 0), now: _now);

      expect(result, isNotNull);
      expect(result!.impactMps2, closeTo(gravityMps2, 0.001));
    });

    test('respects the cooldown — no new candidate within it', () {
      final result = service.evaluate(
        sample: _sample(accelZ: gravityMps2 + 40),
        now: _now,
        lastTriggeredAt: _now.subtract(const Duration(seconds: 10)),
      );

      expect(result, isNull);
    });

    test('triggers again once the cooldown has elapsed', () {
      final result = service.evaluate(
        sample: _sample(accelZ: gravityMps2 + 40),
        now: _now,
        lastTriggeredAt: _now.subtract(const Duration(seconds: 61)),
      );

      expect(result, isNotNull);
    });

    test('a custom config is honored', () {
      const strict = AccidentDetectionService(
        config: AccidentDetectionConfig(impactDeltaThresholdMps2: 100),
      );

      final result = strict.evaluate(
        sample: _sample(
          accelZ: gravityMps2 + 25,
        ), // clears the default, not this one
        now: _now,
      );

      expect(result, isNull);
    });

    test('gyroRadS is null when no gyroscope reading has ever arrived', () {
      final result = service.evaluate(
        sample: _sample(accelZ: gravityMps2 + 25),
        now: _now,
      );

      expect(result!.gyroRadS, isNull);
    });

    test('gyroRadS is populated (even as 0.0) once a reading exists', () {
      final result = service.evaluate(
        sample: _sample(accelZ: gravityMps2 + 25, gyroX: 0, gyroY: 0, gyroZ: 0),
        now: _now,
      );

      expect(result!.gyroRadS, 0.0);
    });

    test(
      'confidence is higher when both accel and gyro clear their thresholds',
      () {
        final accelOnly = service.evaluate(
          sample: _sample(
            accelZ: gravityMps2 + 40,
            gyroX: 0,
            gyroY: 0,
            gyroZ: 0,
          ),
          now: _now,
        )!;
        final accelAndGyro = service.evaluate(
          sample: _sample(
            accelZ: gravityMps2 + 40,
            gyroX: 5,
            gyroY: 0,
            gyroZ: 0,
          ),
          now: _now,
        )!;

        expect(
          accelAndGyro.confidenceScore,
          greaterThan(accelOnly.confidenceScore),
        );
      },
    );

    test('confidence stays within 0.0–1.0 even for extreme readings', () {
      final result = service.evaluate(
        sample: _sample(
          accelX: 500,
          accelY: 500,
          accelZ: 500,
          gyroX: 500,
          gyroY: 0,
          gyroZ: 0,
        ),
        now: _now,
      );

      expect(result!.confidenceScore, inInclusiveRange(0.0, 1.0));
    });
  });
}
