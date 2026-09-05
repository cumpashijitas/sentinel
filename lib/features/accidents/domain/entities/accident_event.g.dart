// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accident_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccidentEvent _$AccidentEventFromJson(Map<String, dynamic> json) =>
    _AccidentEvent(
      id: json['id'] as String,
      sessionId: json['session_id'] as String?,
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      impactMps2: (json['impact_mps2'] as num).toDouble(),
      gyroRadS: (json['gyro_rad_s'] as num?)?.toDouble(),
      speedKmh: (json['speed_kmh'] as num?)?.toDouble(),
      gForce: (json['g_force'] as num?)?.toDouble(),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      status: $enumDecode(_$AccidentEventStatusEnumMap, json['status']),
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );

Map<String, dynamic> _$AccidentEventToJson(_AccidentEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'user_id': instance.userId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'impact_mps2': instance.impactMps2,
      'gyro_rad_s': instance.gyroRadS,
      'speed_kmh': instance.speedKmh,
      'g_force': instance.gForce,
      'confidence_score': instance.confidenceScore,
      'status': _$AccidentEventStatusEnumMap[instance.status]!,
      'occurred_at': instance.occurredAt.toIso8601String(),
    };

const _$AccidentEventStatusEnumMap = {
  AccidentEventStatus.candidate: 'candidate',
  AccidentEventStatus.cancelled: 'cancelled',
  AccidentEventStatus.confirmed: 'confirmed',
  AccidentEventStatus.notified: 'notified',
  AccidentEventStatus.resolved: 'resolved',
};
