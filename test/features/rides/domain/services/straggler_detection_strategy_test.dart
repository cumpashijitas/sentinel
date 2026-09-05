import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/entities/member_tracking_config.dart';
import 'package:sentinel_v2/features/rides/domain/services/straggler_detection_strategy.dart';

LocationFix _fixAt(double lat, double lng) => LocationFix(
  latitude: lat,
  longitude: lng,
  recordedAt: DateTime.utc(2026, 8, 27),
);

void main() {
  const strategy = CentroidStragglerDetectionStrategy();
  // Exercises the default 500m threshold.
  const config = MemberTrackingConfig();

  group('CentroidStragglerDetectionStrategy', () {
    test('is never lagging when there is no group to compare against', () {
      final result = strategy.isLagging(
        memberFix: _fixAt(-17.3935, -66.1570),
        groupFixes: const [],
        config: config,
      );

      expect(result, isFalse);
    });

    test('is not lagging when close to the group centroid', () {
      final result = strategy.isLagging(
        memberFix: _fixAt(-17.3935, -66.1570),
        groupFixes: [_fixAt(-17.3936, -66.1571), _fixAt(-17.3934, -66.1569)],
        config: config,
      );

      expect(result, isFalse);
    });

    test('is lagging when far beyond maxDistanceFromGroupMeters', () {
      final result = strategy.isLagging(
        // ~0.02 degrees ≈ 2.2km away from the group below.
        memberFix: _fixAt(-17.4135, -66.1570),
        groupFixes: [_fixAt(-17.3935, -66.1570), _fixAt(-17.3936, -66.1571)],
        config: config,
      );

      expect(result, isTrue);
    });
  });
}
