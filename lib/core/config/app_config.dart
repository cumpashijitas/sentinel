import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';

/// Build-time configuration, populated exclusively through
/// `--dart-define-from-file=config/<env>.json` (see `config/*.example.json`
/// and the README). Never hardcode secrets here — this file only *reads*
/// values baked in at compile time.
class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.environmentName,
    required this.googleMapsApiKey,
    required this.mapStyleUrl,
    required this.mapTileProvider,
    required this.mapOfflineEnabled,
    required this.mapAttribution,
  });

  /// Builds the config from the values injected at compile time. Throws
  /// [ConfigurationException] when a required value is missing, e.g. when
  /// the app was launched without `--dart-define-from-file`.
  factory AppConfig.fromEnvironment() {
    if (_supabaseUrl.isEmpty || _supabasePublishableKey.isEmpty) {
      throw const ConfigurationException(
        'Configuración incompleta: faltan SUPABASE_URL y/o '
        'SUPABASE_PUBLISHABLE_KEY. Ejecuta la app con '
        '--dart-define-from-file=config/dev.json '
        '(copia config/dev.json.example y complétalo). Ver README.md.',
      );
    }
    return const AppConfig(
      supabaseUrl: _supabaseUrl,
      supabasePublishableKey: _supabasePublishableKey,
      environmentName: _environmentName,
      googleMapsApiKey: _googleMapsApiKey,
      mapStyleUrl: _mapStyleUrl,
      mapTileProvider: _mapTileProvider,
      mapOfflineEnabled: _mapOfflineEnabled,
      mapAttribution: _mapAttribution,
    );
  }

  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const String _environmentName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  // Not required yet (maps aren't implemented in this first slice), but the
  // field exists now so the maps feature never needs to hardcode a key.
  // Superseded by MapLibre (`features/maps/`, "realtime-v2" migration) —
  // kept, not removed: `google_maps_flutter` still compiles and works
  // until MapLibre is validated end-to-end and explicitly approved to
  // replace it (see docs/realtime-v2-migration.md).
  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  // MapLibre config (`features/maps/domain/entities/map_tile_config.dart`)
  // — see docs/maps.md. Defaults to MapLibre's public demo style so a
  // `config/*.json` that predates this never breaks; every real dev/prod
  // config should still set these explicitly (`README.md` §4).
  static const String _mapStyleUrl = String.fromEnvironment(
    'MAP_STYLE_URL',
    defaultValue: 'https://demotiles.maplibre.org/style.json',
  );
  static const String _mapTileProvider = String.fromEnvironment(
    'MAP_TILE_PROVIDER',
    defaultValue: 'MapLibre demo style',
  );
  // Must reflect the provider's actual terms — never default to true.
  // See MapTileConfig.offlineAllowed's doc comment.
  static const bool _mapOfflineEnabled = bool.fromEnvironment(
    'MAP_OFFLINE_ENABLED',
  );
  static const String _mapAttribution = String.fromEnvironment(
    'MAP_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String environmentName;
  final String googleMapsApiKey;
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
