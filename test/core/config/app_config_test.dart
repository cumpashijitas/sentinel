import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/config/app_config.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';

void main() {
  group('AppConfig', () {
    test('isProduction is true only for the prod environment', () {
      const prod = AppConfig(
        supabaseUrl: 'https://example.supabase.co',
        supabasePublishableKey: 'publishable-key',
        environmentName: 'prod',
        googleMapsApiKey: '',
        mapStyleUrl: 'https://demotiles.maplibre.org/style.json',
        mapTileProvider: 'MapLibre demo style',
        mapOfflineEnabled: false,
        mapAttribution: '© OpenStreetMap contributors',
      );
      const dev = AppConfig(
        supabaseUrl: 'http://127.0.0.1:54321',
        supabasePublishableKey: 'publishable-key',
        environmentName: 'dev',
        googleMapsApiKey: '',
        mapStyleUrl: 'https://demotiles.maplibre.org/style.json',
        mapTileProvider: 'MapLibre demo style',
        mapOfflineEnabled: false,
        mapAttribution: '© OpenStreetMap contributors',
      );

      expect(prod.isProduction, isTrue);
      expect(dev.isProduction, isFalse);
    });

    test(
      'fromEnvironment throws ConfigurationException without dart-define',
      () {
        // The test runner isn't launched with --dart-define-from-file, so
        // SUPABASE_URL/SUPABASE_PUBLISHABLE_KEY are empty and this must fail
        // loudly instead of silently booting with an unusable Supabase client.
        expect(
          AppConfig.fromEnvironment,
          throwsA(isA<ConfigurationException>()),
        );
      },
    );
  });
}
