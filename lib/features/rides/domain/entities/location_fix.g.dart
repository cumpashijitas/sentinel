// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_fix.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationFix _$LocationFixFromJson(Map<String, dynamic> json) => _LocationFix(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  batteryLevel: (json['battery_level'] as num?)?.toInt(),
  recordedAt: DateTime.parse(json['recorded_at'] as String),
);

Map<String, dynamic> _$LocationFixToJson(_LocationFix instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'heading': instance.heading,
      'battery_level': instance.batteryLevel,
      'recorded_at': instance.recordedAt.toIso8601String(),
    };
