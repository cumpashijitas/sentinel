/// Watches the device's motion sensors for a possible accident while a
/// ride session is active, and drives the on-device countdown
/// (notification with "Estoy bien" → cancel; no response before it
/// elapses → confirm) — the single seam the background entrypoint calls
/// to turn this feature on/off. Owns its own sensor subscription and
/// countdown timer internally, same shape as `LocationRepository`.
///
/// Android-only, for the same reason as [MotionTracker]: no accelerometer/
/// gyroscope story on Web (`PlatformCapabilities.supportsAccidentDetection`).
/// Implementations must guard with `PlatformCapabilities.requireAndroid`.
abstract interface class AccidentMonitorService {
  /// Starts watching motion, reporting any candidate against [sessionId]
  /// — `null` when monitoring runs for a solo "compartir ubicación" share
  /// rather than a group ride session (`accident_events.session_id` is
  /// nullable exactly for this). A no-op if already monitoring this same
  /// session/share; switches if a different one was active.
  Future<void> start(String? sessionId);

  /// Stops watching. If a countdown was in-flight, its candidate is
  /// treated as cancelled (`cancel`, not `confirm`) rather than left
  /// dangling forever as `candidate` — reaching `stop()` at all requires
  /// something (the rider, or `LiveTrackingController`'s own teardown) to
  /// have actively interacted with the app, which is itself the same kind
  /// of "they're responsive" signal the "Estoy bien" action represents.
  /// Safe to call when not currently monitoring.
  Future<void> stop();
}
