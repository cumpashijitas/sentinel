import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';

/// Runtime configuration, populated exclusively from a `.env` file loaded
/// via `flutter_dotenv` (see `.env.example` and the README). Never hardcode
/// secrets here — this file only *reads* values loaded at startup.
///
/// The front holds **no credential of any external service** — no Supabase
/// URL/key, no maps key beyond what's needed to render a public style. The
/// only thing it needs to know is where its own backend (`back/`) lives;
/// every other connection (Postgres, Supabase Auth, push/SMS/WhatsApp
/// providers) is `back/`'s problem alone, configured in `back/.env` — see
/// docs/architecture.md.
///
/// Superseded the old `--dart-define-from-file` + `String.fromEnvironment`
/// approach: that required a manual per-target JSON file
/// (`config/dev.json`/`config/dev.android.json`/`config/prod.json`) and a
/// flag on every `flutter run`/`flutter build`. A plain `.env` file, loaded
/// once in `bootstrap()` before anything else runs, means every command
/// (`flutter run`, `flutter run -d android`, `flutter build apk`) works
/// unmodified.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.environmentName,
    required this.mapStyleUrl,
    required this.mapTileProvider,
    required this.mapOfflineEnabled,
    required this.mapAttribution,
  });

  /// Builds the config from the `.env` file already loaded by
  /// `dotenv.load()`. Throws [ConfigurationException] when a required value
  /// is missing, e.g. when `.env` doesn't exist or wasn't loaded yet.
  factory AppConfig.fromEnvironment() {
    final env = dotenv.env;
    final apiBaseUrl = env['API_BASE_URL'] ?? '';

    if (apiBaseUrl.isEmpty) {
      throw const ConfigurationException(
        'Configuración incompleta: falta API_BASE_URL (la URL del backend '
        'en back/). Copia .env.example a .env en la raíz de front/ y '
        'complétala. Ver README.md.',
      );
    }

    return AppConfig(
      apiBaseUrl: apiBaseUrl,
      environmentName: env['ENVIRONMENT'] ?? 'dev',
      mapStyleUrl:
          env['MAP_STYLE_URL'] ?? 'https://demotiles.maplibre.org/style.json',
      mapTileProvider: env['MAP_TILE_PROVIDER'] ?? 'MapLibre demo style',
      // Must reflect the provider's actual terms — never default to true.
      // See MapTileConfig.offlineAllowed's doc comment.
      mapOfflineEnabled: (env['MAP_OFFLINE_ENABLED'] ?? 'false') == 'true',
      mapAttribution: env['MAP_ATTRIBUTION'] ?? '© OpenStreetMap contributors',
    );
  }

  /// Base URL of the Sentinel backend (`back/`) — e.g.
  /// `http://localhost:3000` in dev, `http://10.0.2.2:3000` from an Android
  /// emulator, or the deployed URL in prod. Every feature, including Auth
  /// and the live-location feed, goes through this backend — see
  /// `docs/architecture.md`. The only network address the front knows.
  final String apiBaseUrl;
  final String environmentName;

  // MapLibre config (`features/maps/domain/entities/map_tile_config.dart`)
  // — see docs/maps.md. Defaults to MapLibre's public demo style so a `.env`
  // that predates this never breaks; every real dev/prod `.env` should still
  // set these explicitly (`README.md` §4).
  final String mapStyleUrl;
  final String mapTileProvider;
  final bool mapOfflineEnabled;
  final String mapAttribution;

  bool get isProduction => environmentName == 'prod';
}

/// Provided a real value in `bootstrap()` via `ProviderScope(overrides: …)`
/// once [AppConfig.fromEnvironment] has run successfully. Reading it before
/// that override is applied is a programming error.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError(
    'appConfigProvider must be overridden in bootstrap() before runApp().',
  );
});
