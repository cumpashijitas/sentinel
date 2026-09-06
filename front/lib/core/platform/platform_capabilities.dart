import 'package:flutter/foundation.dart';

/// Single source of truth for which Sentinel capabilities are available on
/// the current platform.
///
/// Safety-critical features (raw accelerometer/gyroscope access, background
/// location tracking, on-device accident detection) only make sense on
/// Android, where the OS gives the app the background execution and sensor
/// access it needs. Flutter Web can authenticate, manage groups/rides and
/// show a live map, but must never assume it can run those Android-only
/// paths.
///
/// Feature code should branch on the getters below instead of checking
/// `kIsWeb`/`Platform.isAndroid` directly, and should call [requireAndroid]
/// as a defensive guard at the top of any Android-only code path.
abstract final class PlatformCapabilities {
  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Foreground GPS reads. Available on both platforms; on Web this depends
  /// on the browser's geolocation permission and only works while the tab
  /// is open and visible.
  static bool get supportsForegroundLocation => true;

  /// Continuous location updates while the app is minimized/backgrounded.
  /// Browsers suspend background tabs, so this is Android-only.
  static bool get supportsBackgroundLocation => isAndroid;

  static bool get supportsAccelerometer => isAndroid;

  static bool get supportsGyroscope => isAndroid;

  /// On-device motion-based accident detection depends on the raw sensors
  /// and background execution above, so it is Android-only.
  static bool get supportsAccidentDetection => isAndroid;

  /// Local/system device notifications (accident countdown alerts, etc.).
  static bool get supportsDeviceNotifications => isAndroid;

  /// Interactive maps render on both platforms — `google_maps_flutter` via
  /// its federated web implementation, and (since the "realtime-v2"
  /// migration, `docs/realtime-v2-migration.md`) `maplibre_gl`, which ships
  /// its own Android + Web engines. Offline map regions (Fase D) are
  /// Android-only — that distinction lives on `MapTileConfig.offlineAllowed`
  /// plus a platform check where the download UI is built, not here.
  static bool get supportsMaps => true;

  /// Throws [UnsupportedError] when called from a non-Android platform.
  ///
  /// Use this at the top of Android-only code (sensor listeners, background
  /// location, accident detection) so a mistaken call from Web fails loudly
  /// and immediately instead of silently misbehaving.
  static void requireAndroid(String feature) {
    if (!isAndroid) {
      final platform = isWeb ? 'Web' : defaultTargetPlatform.name;
      throw UnsupportedError(
        '$feature solo está disponible en Android (plataforma actual: $platform).',
      );
    }
  }
}
