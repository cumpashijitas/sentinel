import '../entities/motion_sample.dart';

/// Abstraction over the device's raw motion sensors (accelerometer +
/// gyroscope) — the *only* thing in this app allowed to know that
/// `sensors_plus` exists, same story as [LocationTracker] and
/// `package:geolocator`.
///
/// Deliberately **raw** accelerometer (gravity included, ~9.81 m/s² at
/// rest), not the gravity-compensated "linear acceleration"/"user
/// accelerometer" virtual sensor Android also exposes: that virtual sensor
/// runs through the OS's own low-pass gravity-tracking filter, which adds
/// latency and an extra layer this app can't see into or unit-test against.
/// Working from the raw reading and computing the deviation from the
/// resting gravity magnitude ourselves (see
/// `AccidentDetectionService`) is simpler, more directly testable, and
/// verified end-to-end against the emulator's own sensor injection
/// (`adb emu sensor set acceleration ...`) exactly because it isn't hidden
/// behind that filter.
///
/// Android-only — call sites must guard with
/// `PlatformCapabilities.requireAndroid(...)`; there is no meaningful Web
/// implementation (`PlatformCapabilities.supportsAccelerometer`/
/// `supportsGyroscope` are `false` there).
abstract interface class MotionTracker {
  /// Whether the device actually reports usable accelerometer readings —
  /// not every Android device/emulator profile has one. Checked once
  /// before starting a monitoring session rather than left to fail
  /// silently mid-stream.
  Future<bool> isAvailable();

  /// A stream combining accelerometer and gyroscope readings into one
  /// [MotionSample] per accelerometer event (the gyroscope's most recent
  /// reading is attached to whichever accelerometer sample arrives next —
  /// exact reading pairing is unnecessary for a magnitude-threshold
  /// heuristic). Callers cancel their subscription to stop sensor reads.
  Stream<MotionSample> watchMotion();
}
