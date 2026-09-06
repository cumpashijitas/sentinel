import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/config/app_config.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';

void main() {
  group('AppConfig', () {
    test('isProduction is true only for the prod environment', () {
      const prod = AppConfig(
        apiBaseUrl: 'https://api.example.com',
        environmentName: 'prod',
        mapStyleUrl: 'https://demotiles.maplibre.org/style.json',
        mapTileProvider: 'MapLibre demo style',
        mapOfflineEnabled: false,
        mapAttribution: '© OpenStreetMap contributors',
      );
      const dev = AppConfig(
        apiBaseUrl: 'http://localhost:3000',
        environmentName: 'dev',
        mapStyleUrl: 'https://demotiles.maplibre.org/style.json',
        mapTileProvider: 'MapLibre demo style',
        mapOfflineEnabled: false,
        mapAttribution: '© OpenStreetMap contributors',
      );

      expect(prod.isProduction, isTrue);
      expect(dev.isProduction, isFalse);
    });

    test(
      'fromEnvironment throws ConfigurationException without a loaded .env',
      () {
        // The test runner never calls dotenv.load() (see bootstrap.dart),
        // so dotenv.env is empty and API_BASE_URL is missing — this must
        // fail loudly instead of silently booting with no backend to
        // talk to.
        expect(
          AppConfig.fromEnvironment,
          throwsA(isA<ConfigurationException>()),
        );
      },
    );
  });
}
