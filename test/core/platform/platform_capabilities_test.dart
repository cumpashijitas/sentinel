import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/platform/platform_capabilities.dart';

void main() {
  // These tests intentionally avoid asserting a specific literal platform
  // (Android vs. Web vs. desktop host), since that depends on how the test
  // runner reports `defaultTargetPlatform`. Instead they assert the
  // *contract*: every Android-only capability must track `isAndroid`
  // exactly, capabilities available everywhere must stay `true`, and the
  // guard must throw precisely when the platform isn't Android.
  group('PlatformCapabilities', () {
    test('Android-only capabilities always match isAndroid', () {
      final isAndroid = PlatformCapabilities.isAndroid;

      expect(PlatformCapabilities.supportsBackgroundLocation, isAndroid);
      expect(PlatformCapabilities.supportsAccelerometer, isAndroid);
      expect(PlatformCapabilities.supportsGyroscope, isAndroid);
      expect(PlatformCapabilities.supportsAccidentDetection, isAndroid);
      expect(PlatformCapabilities.supportsDeviceNotifications, isAndroid);
    });

    test('cross-platform capabilities are always supported', () {
      expect(PlatformCapabilities.supportsForegroundLocation, isTrue);
      expect(PlatformCapabilities.supportsMaps, isTrue);
    });

    test('isWeb and isAndroid are mutually exclusive', () {
      expect(
        PlatformCapabilities.isWeb && PlatformCapabilities.isAndroid,
        isFalse,
      );
    });

    test('requireAndroid throws off Android, is a no-op on Android', () {
      if (PlatformCapabilities.isAndroid) {
        expect(
          () => PlatformCapabilities.requireAndroid('accident detection'),
          returnsNormally,
        );
      } else {
        expect(
          () => PlatformCapabilities.requireAndroid('accident detection'),
          throwsUnsupportedError,
        );
      }
    });
  });
}
