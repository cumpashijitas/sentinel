import '../entities/location_fix.dart';

/// Abstraction over the device's own GPS — the *only* thing in this app
/// allowed to know that `geolocator` exists. The UI, controllers and
/// repositories talk to this interface, never to `geolocator` directly.
///
/// One implementation (`GeolocatorLocationTracker`, `data/`), used on both
/// Android and Web — `geolocator`'s own federated Android/Web
/// implementations already give it a uniform Dart API, so there is nothing
/// platform-specific to branch on here. **Not** a second implementation for
/// background tracking (an earlier version of this comment predicted one):
/// Fase 6's `RideBackgroundService` still uses this exact same
/// `GeolocatorLocationTracker`, just from a *different Dart isolate* (a
/// background `FlutterEngine` the native service starts, see
/// `lib/background/ride_background_main.dart`) rather than a different
/// class — swapping implementations would not have helped, since the
/// problem Fase 6 solves is which *process/isolate* runs the subscription,
/// not which package talks to the GPS. See
/// `docs/background_service.md` and `BackgroundLocationService` (the
/// separate interface that remote-controls that other isolate) for the
/// full picture. Web has no background counterpart —
/// `PlatformCapabilities.supportsBackgroundLocation` is `false` there, and
/// stays foreground-only permanently (see `docs/security.md`).
abstract interface class LocationTracker {
  /// Requests location permission if not already granted. Returns `true`
  /// once permission is available (whether it already was or was just
  /// granted), `false` if the user declined or the OS denies it
  /// permanently.
  Future<bool> ensurePermission();

  /// Requests the stronger "Allow all the time" permission
  /// (`ACCESS_BACKGROUND_LOCATION` on Android) required to receive
  /// location updates from a context the OS doesn't consider foreground —
  /// which, per Android's platform behavior since API 29, includes a
  /// foreground `Service` with no visible `Activity`: [ensurePermission]'s
  /// "while in use" grant is *not* sufficient there, even though it's
  /// enough for [watchPosition] while the app itself is visible. Only
  /// meaningful on Android — see `BackgroundLocationService`, the only
  /// caller.
  Future<bool> ensureBackgroundPermission();

  /// A stream of the device's position while something is listening.
  /// Callers are expected to `cancel()` their subscription when tracking
  /// should stop (leaving the ride, finishing the session, backgrounding
  /// the app on Web) — this tracker has no independent notion of "a ride
  /// is active" itself.
  Stream<LocationFix> watchPosition();
}
