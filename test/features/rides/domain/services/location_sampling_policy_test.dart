import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/services/location_sampling_policy.dart';

LocationFix _fix({
  double lat = -17.3935,
  double lng = -66.1570,
  double? heading,
  required DateTime at,
}) => LocationFix(
  latitude: lat,
  longitude: lng,
  heading: heading,
  recordedAt: at,
);

void main() {
  // Exercises the class's own defaults: 20s / 25m / 35°.
  const policy = LocationSamplingPolicy();
  final base = DateTime.utc(2026, 8, 27, 12);

  group('LocationSamplingPolicy.shouldRecord', () {
    test('always records the very first fix (no last recorded)', () {
      expect(
        policy.shouldRecord(lastRecorded: null, current: _fix(at: base)),
        isTrue,
      );
    });

    test('does not record when nothing meaningfully changed', () {
      final last = _fix(at: base);
      final current = _fix(at: base.add(const Duration(seconds: 5)));

      expect(
        policy.shouldRecord(lastRecorded: last, current: current),
        isFalse,
      );
    });

    test('records once minInterval has elapsed, even with no movement', () {
      final last = _fix(at: base);
      final current = _fix(at: base.add(const Duration(seconds: 21)));

      expect(policy.shouldRecord(lastRecorded: last, current: current), isTrue);
    });

    test('records on a large-enough distance change within the interval', () {
      final last = _fix(at: base);
      // ~0.01 degrees ≈ 1.1km north — comfortably over the 25m threshold.
      final current = _fix(
        lat: -17.4035,
        at: base.add(const Duration(seconds: 5)),
      );

      expect(policy.shouldRecord(lastRecorded: last, current: current), isTrue);
    });

    test('records on a large-enough heading change within the interval', () {
      final last = _fix(heading: 10, at: base);
      final current = _fix(
        heading: 100,
        at: base.add(const Duration(seconds: 5)),
      );

      expect(policy.shouldRecord(lastRecorded: last, current: current), isTrue);
    });

    test('heading change wraps correctly around 0/360', () {
      final last = _fix(heading: 5, at: base);
      // 5 -> 355 is only a 10-degree turn, not 350.
      final current = _fix(
        heading: 355,
        at: base.add(const Duration(seconds: 5)),
      );

      expect(
        policy.shouldRecord(lastRecorded: last, current: current),
        isFalse,
      );
    });

    test('ignores heading when either fix has none', () {
      final last = _fix(at: base); // no heading
      final current = _fix(
        heading: 200,
        at: base.add(const Duration(seconds: 5)),
      );

      expect(
        policy.shouldRecord(lastRecorded: last, current: current),
        isFalse,
      );
    });
  });
}
