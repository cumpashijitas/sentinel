import 'package:freezed_annotation/freezed_annotation.dart';

part 'motion_sample.freezed.dart';
part 'motion_sample.g.dart';

/// A single reading from the device's motion sensors, at one instant —
/// **raw** accelerometer (includes gravity, ~9.81 m/s² magnitude at rest)
/// plus the most recently known gyroscope reading. See [MotionTracker] for
/// why raw (not gravity-compensated) acceleration is used.
///
/// JSON-serializable so a sample can be embedded verbatim into
/// `accident_events.sensor_snapshot` (`jsonb`) when reporting a candidate —
/// the actual evidence, not just the derived `impact_mps2`/`g_force`
/// numbers.
@freezed
abstract class MotionSample with _$MotionSample {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MotionSample({
    required double accelX,
    required double accelY,
    required double accelZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    required DateTime recordedAt,
  }) = _MotionSample;

  factory MotionSample.fromJson(Map<String, dynamic> json) =>
      _$MotionSampleFromJson(json);
}
