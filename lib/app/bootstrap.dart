import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/logging/app_logger.dart';
import '../core/platform/platform_capabilities.dart';
import '../features/accidents/accident_alert_response.dart';
import 'app.dart';

/// Entry point shared by `main.dart` (and, later, per-flavor mains).
///
/// Resolves [AppConfig] from the values baked in via
/// `--dart-define-from-file`, initializes Supabase, and only then starts the
/// widget tree. If configuration or Supabase initialization fails, a
/// minimal error screen is shown instead of a blank crash — this is the
/// first thing a misconfigured `flutter run` will show.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Uncaught Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  final AppConfig config;
  try {
    config = AppConfig.fromEnvironment();
  } on ConfigurationException catch (error) {
    AppLogger.error(error.message);
    runApp(_BootstrapErrorApp(message: error.message));
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
      'No se pudo inicializar Supabase',
      error: error,
      stackTrace: stackTrace,
    );
    runApp(
      const _BootstrapErrorApp(
        message:
            'No se pudo conectar con Supabase. Verifica la configuración '
            'y la conexión de red.',
      ),
    );
    return;
  }

  // Fase 7: this engine's half of "Estoy bien" notification-tap handling
  // — see `initializeAccidentAlertResponseHandling`'s doc comment for why
  // the *main* engine, not just `RideBackgroundService`'s background one,
  // needs its own registration. Android-only (no accident detection on
  // Web at all); failing to set this up shouldn't block the app from
  // starting, so it's logged, not fatal.
  if (PlatformCapabilities.isAndroid) {
    try {
      await initializeAccidentAlertResponseHandling();
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudo inicializar el manejo de la alerta de accidente',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const SentinelApp(),
    ),
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
