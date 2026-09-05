import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../domain/repositories/background_location_service.dart';
import '../../domain/repositories/location_tracker.dart';

/// `MethodChannel` bridge to `RideBackgroundService` (native Kotlin, see
/// `android/app/src/main/kotlin/com/sentinel/app/`). The channel name is
/// the one source of truth shared with the native side — if it changes
/// here, it must change in `MainActivity.kt` too.
const _channelName = 'com.sentinel.app/background_location';

class AndroidBackgroundLocationService implements BackgroundLocationService {
  // Initializing formal on a private field: still callable externally via
  // the public name `tracker:` — see the same note in
  // `LocationRepositoryImpl`'s constructor.
  AndroidBackgroundLocationService({
    required this._tracker,
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel(_channelName);

  final LocationTracker _tracker;
  final MethodChannel _channel;

  @override
  Future<void> start(String sessionId) async {
    PlatformCapabilities.requireAndroid('BackgroundLocationService.start');

    // Checked here, before ever reaching the native side: `watchPosition`
    // only needs `ensurePermission`'s "while in use" grant, but a
    // foreground service with no visible Activity does not count as
    // "in use" to Android's location permission system — it needs the
    // stronger "Allow all the time" grant. See `ensureBackgroundPermission`.
    final granted = await _tracker.ensureBackgroundPermission();
    if (!granted) {
      throw const DataException(
        'Sentinel necesita permiso de ubicación "todo el tiempo" para '
        'seguir compartiendo tu posición cuando la app está en segundo '
        'plano. Actívalo en Ajustes del sistema > Apps > Sentinel > '
        'Permisos > Ubicación.',
      );
    }

    // Best-effort, not a hard requirement: a foreground service keeps
    // running (and location keeps flowing) even without notification
    // permission — Android just silently drops the notification itself
    // (confirmed on-device: `startForeground()` succeeds either way). A
    // rider who declines this only loses the visible reminder that
    // sharing is still on, not the sharing itself, so declining doesn't
    // block `start` — and neither does the plugin channel simply not
    // being registered (e.g. under `flutter test`, which has no platform
    // implementation for it at all).
    try {
      await Permission.notification.request();
    } on MissingPluginException {
      // no-op — see comment above.
    }

    try {
      await _channel.invokeMethod<void>('start', {'sessionId': sessionId});
    } on PlatformException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    }
  }

  @override
  Future<void> stop() async {
    PlatformCapabilities.requireAndroid('BackgroundLocationService.stop');
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    }
  }

  @override
  Future<bool> isRunning() async {
    PlatformCapabilities.requireAndroid('BackgroundLocationService.isRunning');
    final result = await _channel.invokeMethod<bool>('isRunning');
    return result ?? false;
  }

  /// Maps the native side's error codes (see `RideBackgroundService.kt`'s
  /// `MethodChannel` handler) to user-facing Spanish messages, same spirit
  /// as `LocationRepositoryImpl`/`LiveLocationRepositoryImpl`'s own error
  /// translation. `PERMISSION_DENIED` here is a defensive fallback for the
  /// native side's own permission check — in practice `start()` above
  /// already fails before ever reaching the channel if permission is
  /// missing, so this is normally unreachable, not the primary path.
  static String _messageFor(PlatformException error) {
    return switch (error.code) {
      'PERMISSION_DENIED' =>
        'Sentinel necesita permiso de ubicación "todo el tiempo" para '
            'seguir compartiendo tu posición cuando la app está en segundo '
            'plano. Actívalo en Ajustes del sistema > Apps > Sentinel > '
            'Permisos > Ubicación.',
      _ => 'No se pudo iniciar el servicio de ubicación en segundo plano.',
    };
  }
}
