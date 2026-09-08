// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_share.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmergencyShare _$EmergencyShareFromJson(Map<String, dynamic> json) =>
    _EmergencyShare(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shareToken: json['share_token'] as String,
      status: $enumDecode(_$EmergencyShareStatusEnumMap, json['status']),
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
    );

Map<String, dynamic> _$EmergencyShareToJson(_EmergencyShare instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'share_token': instance.shareToken,
      'status': _$EmergencyShareStatusEnumMap[instance.status]!,
      'started_at': instance.startedAt.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
    };

const _$EmergencyShareStatusEnumMap = {
  EmergencyShareStatus.active: 'active',
  EmergencyShareStatus.ended: 'ended',
};
