import 'dart:math';

import '../entities/motion_sample.dart';

/// Standard gravity, m/s² — the accelerometer's resting magnitude on a
/// stationary device (see [MotionTracker]'s doc comment for why this
/// service works from *raw* acceleration and subtracts gravity itself
/// instead of relying on Android's own gravity-compensated virtual
/// sensor).
const gravityMps2 = 9.80665;

/// Tunable thresholds for [AccidentDetectionService]. Defaults are a
/// starting point, **not** a calibrated crash-detection model — real
/// tuning needs real ride data (accelerometer traces from actual impacts
/// vs. potholes/gravel/emergency braking), which is out of scope for this
/// phase. See `docs/accident_detection.md`.
class AccidentDetectionConfig {
  const AccidentDetectionConfig({
    this.impactDeltaThresholdMps2 = 20,
    this.gyroThresholdRadS = 4,
    this.cooldown = const Duration(seconds: 60),
  }) : assert(impactDeltaThresholdMps2 > 0),
       assert(gyroThresholdRadS > 0);

  /// How far the accelerometer magnitude must deviate from resting
  /// gravity to count as a possible impact. ~20 m/s² ≈ 2g of sudden force
  /// beyond gravity.
  final double impactDeltaThresholdMps2;

  /// Angular velocity magnitude (rad/s) that counts as corroborating
  /// rotation evidence — a real crash usually tumbles the bike/phone, a
  /// straight-line hard stop mostly doesn't.
  final double gyroThresholdRadS;

  /// Minimum time between two triggers, so one physical event (and the
  /// sensor noise right after it) doesn't produce a flood of candidates.
  final Duration cooldown;
}

/// A detected possible impact, ready to hand to
/// `AccidentEventRepository.reportCandidate`.
class AccidentCandidate {
  const AccidentCandidate({
    required this.impactMps2,
    required this.gyroRadS,
    required this.gForce,
    required this.confidenceScore,
    required this.sample,
  });

  /// Deviation from resting gravity, m/s² — what `accident_events.impact_mps2`
  /// stores.
  final double impactMps2;

  /// Angular velocity magnitude at the same instant, if the gyroscope had
  /// reported a reading yet (`null` only when no gyroscope sample has
  /// arrived at all — a genuine "no rotation" reading is `0.0`, not `null`).
  final double? gyroRadS;

  /// `impactMps2` expressed in g, matching `accident_events.g_force`.
  final double gForce;

  /// 0.0–1.0, see [AccidentDetectionService.evaluate] for how it's derived.
  /// Not a probability in any statistical sense — a relative signal for
  /// how far past threshold this reading was, on both axes.
  final double confidenceScore;

  /// The raw sample that triggered this candidate — embedded as
  /// `accident_events.sensor_snapshot` so the evidence, not just the
  /// derived numbers, is preserved.
  final MotionSample sample;
}

/// Pure threshold heuristic — no I/O, no device access, easily unit
/// tested with synthetic [MotionSample]s. [AccidentMonitorServiceImpl]
/// (data layer) is what actually feeds it live sensor readings and acts on
/// the result.
class AccidentDetectionService {
  const AccidentDetectionService({
    this.config = const AccidentDetectionConfig(),
  });

  final AccidentDetectionConfig config;

  /// Returns an [AccidentCandidate] if [sample] looks like a possible
  /// impact, or `null` if it doesn't clear the threshold or [cooldown] (see
  /// [AccidentDetectionConfig]) hasn't elapsed since [lastTriggeredAt].
  /// Stateless by design — same shape as `LocationSamplingPolicy`, the
  /// caller is what tracks `lastTriggeredAt` across calls.
  AccidentCandidate? evaluate({
    required MotionSample sample,
    required DateTime now,
    DateTime? lastTriggeredAt,
  }) {
    if (lastTriggeredAt != null &&
        now.difference(lastTriggeredAt) < config.cooldown) {
      return null;
    }

    final accelMagnitude = _magnitude(
      sample.accelX,
      sample.accelY,
      sample.accelZ,
    );
    final impactMps2 = (accelMagnitude - gravityMps2).abs();
    if (impactMps2 < config.impactDeltaThresholdMps2) return null;

    final gyroMagnitude = sample.gyroX == null
        ? null
        : _magnitude(sample.gyroX!, sample.gyroY!, sample.gyroZ!);

    // Each axis contributes 0.0 at "no signal" up to 1.0 at 2x its own
    // threshold; missing gyro data (sensor never reported, not "reported
    // zero rotation") scores as neutral rather than penalizing the accel
    // signal that already cleared its own threshold.
    final accelScore =
        (impactMps2 / config.impactDeltaThresholdMps2).clamp(0.0, 2.0) / 2.0;
    final gyroScore = gyroMagnitude == null
        ? 0.5
        : (gyroMagnitude / config.gyroThresholdRadS).clamp(0.0, 2.0) / 2.0;

    return AccidentCandidate(
      impactMps2: impactMps2,
      gyroRadS: gyroMagnitude,
      gForce: accelMagnitude / gravityMps2,
      confidenceScore: ((accelScore + gyroScore) / 2).clamp(0.0, 1.0),
      sample: sample,
    );
  }

  static double _magnitude(double x, double y, double z) =>
      sqrt(x * x + y * y + z * z);
}
