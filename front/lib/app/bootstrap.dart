import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '../core/auth/session_store.dart';
import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/logging/app_logger.dart';
import '../core/platform/platform_capabilities.dart';
import '../features/accidents/accident_alert_response.dart';
import 'app.dart';

/// Entry point shared by `main.dart` (and, later, per-flavor mains).
///
/// Loads `.env` (see `.env.example`), resolves [AppConfig] from it, then
/// tries to resume a previous session ([SessionStore.restore]) before
/// starting the widget tree. If configuration fails, a minimal error
/// screen is shown instead of a blank crash — this is the first thing a
/// misconfigured `flutter run` will show.
///
/// Builds its own [ProviderContainer] (rather than letting a plain
/// `ProviderScope(overrides: ...)` widget create one implicitly) so the
/// exact same [SessionStore] instance this function calls `restore()` on
/// is the one every provider in the running app reads afterwards — two
/// separate instances would mean the restored session never reaches the
/// widget tree. `UncontrolledProviderScope` hands that container to
/// `runApp` instead of building a fresh one.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sin esto, Flutter Web usa rutas con `#` (`/#/share/<token>`) — el
  // link público quedaría compartible igual, pero nunca matcheable por un
  // intent-filter de Android App Links (la parte después de `#` nunca
  // llega a la lógica de matching de `<data>`, solo al navegador). No-op
  // fuera de Web.
  usePathUrlStrategy();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Uncaught Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  final AppConfig config;
  try {
    try {
      await dotenv.load();
    } catch (error) {
      // Missing `.env` (fresh clone, never copied from `.env.example`)
      // throws a plain Exception from flutter_dotenv, not a
      // ConfigurationException — normalize it so the catch below handles
      // both the same way.
      throw ConfigurationException(
        'No se encontró front/.env. Copia .env.example a .env y '
        'complétalo. Ver README.md.',
        cause: error,
      );
    }
    config = AppConfig.fromEnvironment();
  } on ConfigurationException catch (error) {
    AppLogger.error(error.message);
    runApp(_BootstrapErrorApp(message: error.message));
    return;
  }

  final container = ProviderContainer(
    overrides: [appConfigProvider.overrideWithValue(config)],
  );

  try {
    await container.read(sessionStoreProvider).restore();
  } catch (error, stackTrace) {
    // Non-fatal: worst case the user just sees the login screen instead of
    // a resumed session — never block startup over this.
    AppLogger.error(
      'No se pudo restaurar la sesión guardada',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Fase 7: this engine's half of "Estoy bien" notification-tap handling
  // — see `initializeAccidentAlertResponseHandling`'s doc comment for why
  // the *main* engine, not just `RideBackgroundService`'s background one,
  // needs its own registration. Android-only (no accident detection on
  // Web at all); failing to set this up shouldn't block the app from
  // starting, so it's logged, not fatal.
  if (PlatformCapabilities.isAndroid) {
    try {
      await initializeAccidentAlertResponseHandling(container);
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudo inicializar el manejo de la alerta de accidente',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const SentinelApp()),
  );
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
