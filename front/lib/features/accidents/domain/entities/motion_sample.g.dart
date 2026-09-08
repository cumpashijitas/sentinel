// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motion_sample.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MotionSample _$MotionSampleFromJson(Map<String, dynamic> json) =>
    _MotionSample(
      accelX: (json['accel_x'] as num).toDouble(),
      accelY: (json['accel_y'] as num).toDouble(),
      accelZ: (json['accel_z'] as num).toDouble(),
      gyroX: (json['gyro_x'] as num?)?.toDouble(),
      gyroY: (json['gyro_y'] as num?)?.toDouble(),
      gyroZ: (json['gyro_z'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );

Map<String, dynamic> _$MotionSampleToJson(_MotionSample instance) =>
    <String, dynamic>{
      'accel_x': instance.accelX,
      'accel_y': instance.accelY,
      'accel_z': instance.accelZ,
      'gyro_x': instance.gyroX,
      'gyro_y': instance.gyroY,
      'gyro_z': instance.gyroZ,
      'recorded_at': instance.recordedAt.toIso8601String(),
    };
