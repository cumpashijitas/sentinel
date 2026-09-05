/// Android-only: keeps [LocationRepository]-equivalent sharing running from
/// a native foreground `Service` — a process that survives the app being
/// backgrounded, the screen turning off, or (deliberately, see
/// `docs/background_service.md`) the user swiping Sentinel away from
/// Recents, none of which a plain in-app [LocationTracker] subscription
/// survives (see `PlatformCapabilities.supportsBackgroundLocation`).
///
/// Deliberately a **separate** interface from [LocationRepository] rather
/// than a second implementation of it: [LocationRepository] runs entirely
/// inside the calling isolate/engine (its `Stream<LocationFix>` is a Dart
/// object the caller holds a reference to), which is exactly what a
/// background *service* cannot offer — the actual tracking loop runs in a
/// separate native `Service` and a background `FlutterEngine`/isolate this
/// one has no handle to. What this interface exposes is only the remote
/// control for that other process: start it, stop it, ask whether it's
/// running. See `AndroidBackgroundLocationService` for the `MethodChannel`
/// bridge, and `lib/background/ride_background_main.dart` for what
/// actually runs on the other side — it constructs and drives its own
/// [LocationRepository] using the exact same domain/data classes as the
/// foreground path (Fase 5), so the tracking/sampling logic itself is not
/// duplicated between the two.
///
/// Only meaningful on Android — call sites must guard with
/// `PlatformCapabilities.requireAndroid(...)` before reaching for an
/// implementation of this interface; there is no Web implementation
/// because there is nothing on Web for it to control.
abstract interface class BackgroundLocationService {
  /// Starts (or restarts, if a different session was already running) the
  /// native foreground service sharing location for [sessionId]. Throws a
  /// [DataException]-style error if location permission — specifically
  /// "Allow all the time", not just "while using the app" — was not
  /// granted; this interface does not itself prompt for it beyond that one
  /// attempt.
  Future<void> start(String sessionId);

  /// Stops the native service if it is running. Safe to call when it
  /// isn't.
  Future<void> stop();

  /// Whether the native service is currently running, queried from the
  /// native side rather than tracked in Dart — the service can outlive
  /// this engine's own process state (e.g. the app was killed and
  /// relaunched while the service kept running), so this is a real ask,
  /// not a cached flag.
  Future<bool> isRunning();
}
