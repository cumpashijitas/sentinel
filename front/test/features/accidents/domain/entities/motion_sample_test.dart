import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';

void main() {
  group('MotionSample', () {
    test('fromJson maps snake_case columns', () {
      final sample = MotionSample.fromJson({
        'accel_x': 1.0,
        'accel_y': 2.0,
        'accel_z': 9.8,
        'gyro_x': 0.1,
        'gyro_y': null,
        'gyro_z': null,
        'recorded_at': '2026-08-28T12:00:00.000Z',
      });

      expect(sample.accelX, 1.0);
      expect(sample.accelZ, 9.8);
      expect(sample.gyroX, 0.1);
      expect(sample.gyroY, isNull);
      expect(sample.recordedAt, DateTime.parse('2026-08-28T12:00:00.000Z'));
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final sample = MotionSample(
        accelX: 1,
        accelY: 2,
        accelZ: 9.8,
        recordedAt: DateTime.utc(2026, 8, 28, 12),
      );

      expect(MotionSample.fromJson(sample.toJson()), equals(sample));
    });
  });
}
