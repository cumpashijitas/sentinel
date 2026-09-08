import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/auth/session_store.dart';
import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/logging/app_logger.dart';
import '../core/network/api_client.dart';
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
/// Since the front holds no Supabase credential (see docs/architecture.md),
/// this engine talks to `back/` over HTTP/WebSocket exactly like the UI
/// engine does — `SessionStore`/`ApiClient` are hand-constructed here
/// instead of read via `ref.watch`, for the same "no ProviderScope" reason.
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
    // Separate FlutterEngine/isolate from the UI one — `.env` must be
    // (re)loaded here too, it isn't shared across engines.
    await dotenv.load();
    config = AppConfig.fromEnvironment();
  } on ConfigurationException catch (error) {
    AppLogger.error('RideBackgroundService: ${error.message}');
    return;
  } catch (error) {
    AppLogger.error('RideBackgroundService: no se pudo cargar .env: $error');
    return;
  }

  // Resumes the session the UI engine already established — refresh tokens
  // are persisted to disk (see SessionStore.restore's doc comment), which
  // is what lets this *separate* isolate pick the same session back up
  // without any token crossing the MethodChannel from the UI side.
  final sessionStore = SessionStore(config.apiBaseUrl);
  await sessionStore.restore();
  final authRepository = AuthRepositoryImpl(
    SessionStoreAuthRemoteDataSource(sessionStore),
  );
  if (authRepository.currentUser == null) {
    AppLogger.error(
      'RideBackgroundService: no hay sesión activa — no se puede compartir ubicación.',
    );
    return;
  }

  final apiClient = ApiClient(baseUrl: config.apiBaseUrl, sessionStore: sessionStore);

  final locationRepository = LocationRepositoryImpl(
    tracker: const GeolocatorLocationTracker(),
    liveLocationRepository: LiveLocationRepositoryImpl(
      HttpLiveLocationRemoteDataSource(apiClient),
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
        HttpAccidentEventRemoteDataSource(apiClient),
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
