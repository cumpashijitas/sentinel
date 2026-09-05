import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/logging/app_logger.dart';
import '../features/accidents/data/datasources/accident_event_remote_datasource.dart';
import '../features/accidents/data/datasources/local_accident_alert_notifier.dart';
import '../features/accidents/data/datasources/sensors_plus_motion_tracker.dart';
import '../features/accidents/data/repositories/accident_event_repository_impl.dart';
import '../features/accidents/data/repositories/accident_monitor_service_impl.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/rides/data/datasources/geolocator_location_tracker.dart';
import '../features/rides/data/datasources/live_location_remote_datasource.dart';
import '../features/rides/data/repositories/live_location_repository_impl.dart';
import '../features/rides/data/repositories/location_repository_impl.dart';

/// Entry point for `RideBackgroundService`'s own `FlutterEngine`
/// (`android/app/src/main/kotlin/com/sentinel/app/RideBackgroundService.kt`)
/// — a **separate** engine/isolate from the one running the app's UI
/// (`lib/main.dart`), started by the native Android service so location
/// sharing keeps running while the app is backgrounded. See
/// `docs/background_service.md` for the full picture.
///
/// `@pragma('vm:entry-point')` is required on every function Android calls
/// into directly rather than through normal Dart imports — without it, the
/// release/AOT build's tree shaker removes this function since nothing in
/// the Dart call graph appears to reference it.
///
/// Deliberately reuses the *exact* Fase 5 domain/data classes
/// (`LocationRepositoryImpl`, `GeolocatorLocationTracker`,
/// `LiveLocationRepositoryImpl`) instead of a background-specific
/// reimplementation — the tracking/sampling *logic* doesn't change based on
/// who's driving it, only how the caller reaches it (Riverpod providers
/// for the UI path vs. this hand-wired bootstrap here, since there is no
/// widget tree — and therefore no `ProviderScope` — in a headless engine).
@pragma('vm:entry-point')
Future<void> rideBackgroundMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Uncaught error in RideBackgroundService engine',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  final sessionId = args.isNotEmpty ? args.first : null;
  if (sessionId == null || sessionId.isEmpty) {
    AppLogger.error(
      'rideBackgroundMain started without a sessionId argument — nothing to share.',
    );
    return;
  }

  final AppConfig config;
  try {
    config = AppConfig.fromEnvironment();
  } on ConfigurationException catch (error) {
    AppLogger.error('RideBackgroundService: ${error.message}');
    return;
  }

  try {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
      debug: !config.isProduction,
    );
  } catch (error, stackTrace) {
    AppLogger.error(
      'RideBackgroundService: no se pudo inicializar Supabase',
      error: error,
      stackTrace: stackTrace,
    );
    return;
  }

  // Same storage the foreground engine's Supabase.initialize() persisted
  // to (both engines run in the same Android process, but do NOT share
  // Dart isolate state) — this is what lets the background engine resume
  // the already-signed-in session without any token crossing the
  // MethodChannel from the UI side.
  final client = Supabase.instance.client;
  final authRepository = AuthRepositoryImpl(
    SupabaseAuthRemoteDataSource(client),
  );
  if (authRepository.currentUser == null) {
    AppLogger.error(
      'RideBackgroundService: no hay sesión activa — no se puede compartir ubicación.',
    );
    return;
  }

  final locationRepository = LocationRepositoryImpl(
    tracker: const GeolocatorLocationTracker(),
    liveLocationRepository: LiveLocationRepositoryImpl(
      SupabaseLiveLocationRemoteDataSource(client),
    ),
    authRepository: authRepository,
  );

  try {
    await locationRepository.startSharing(sessionId);
  } catch (error, stackTrace) {
    AppLogger.error(
      'RideBackgroundService: startSharing falló',
      error: error,
      stackTrace: stackTrace,
    );
    return;
  }

  // Fase 7: accident detection runs alongside location sharing, in this
  // exact engine — see `AccidentMonitorServiceImpl`'s doc comment for why
  // it doesn't attach a GPS position to what it reports. A failure here
  // logs and falls through rather than aborting: a rider should still get
  // location sharing even if, say, this device has no accelerometer.
  try {
    final accidentMonitor = AccidentMonitorServiceImpl(
      motionTracker: const SensorsPlusMotionTracker(),
      accidentEventRepository: AccidentEventRepositoryImpl(
        SupabaseAccidentEventRemoteDataSource(client),
      ),
      alertNotifier: LocalAccidentAlertNotifier(),
      authRepository: authRepository,
    );
    await accidentMonitor.start(sessionId);
  } catch (error, stackTrace) {
    AppLogger.error(
      'RideBackgroundService: no se pudo iniciar la detección de accidentes',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Deliberately no explicit "keep alive" construct below: `startSharing`
  // leaves an active `StreamSubscription` registered on the tracker's
  // position stream, and Dart does not let an isolate's event loop go
  // idle while a subscription/timer is still pending — that's what keeps
  // this engine (and therefore this function's Dart isolate) alive after
  // returning, for as long as `RideBackgroundService` keeps it around.
  // Stopping is entirely the *native* side's responsibility (destroying
  // this FlutterEngine), not something this entrypoint listens for — see
  // the comment on `BackgroundLocationService.stop()`.
  AppLogger.info(
    'RideBackgroundService: compartiendo ubicación de la sesión $sessionId',
  );
}
