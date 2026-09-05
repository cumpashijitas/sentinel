import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/utils/geo_math.dart';

void main() {
  group('GeoMath.distanceMeters', () {
    test('is zero for identical coordinates', () {
      final distance = GeoMath.distanceMeters(
        fromLat: -17.3935,
        fromLng: -66.1570,
        toLat: -17.3935,
        toLng: -66.1570,
      );
      expect(distance, 0);
    });

    test('matches a known approximate distance', () {
      // Cochabamba, Bolivia plaza area vs. a point ~1.1km north — a
      // reasonable real-world sanity check rather than an exact fixture.
      final distance = GeoMath.distanceMeters(
        fromLat: -17.3935,
        fromLng: -66.1570,
        toLat: -17.4035,
        toLng: -66.1570,
      );
      expect(distance, closeTo(1112, 5));
    });
  });

  group('GeoMath.centroid', () {
    test('of a single point is that point', () {
      final (lat, lng) = GeoMath.centroid([(-17.0, -66.0)]);
      expect(lat, -17.0);
      expect(lng, -66.0);
    });

    test('of two points is their midpoint', () {
      final (lat, lng) = GeoMath.centroid([(-17.0, -66.0), (-19.0, -68.0)]);
      expect(lat, -18.0);
      expect(lng, -67.0);
    });

    test('throws on an empty set', () {
      expect(() => GeoMath.centroid(const []), throwsArgumentError);
    });
  });
}
