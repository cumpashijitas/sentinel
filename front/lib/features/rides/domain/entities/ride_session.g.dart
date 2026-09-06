// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideSession _$RideSessionFromJson(Map<String, dynamic> json) => _RideSession(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  startedBy: json['started_by'] as String,
  name: json['name'] as String?,
  status: $enumDecode(_$RideSessionStatusEnumMap, json['status']),
  startedAt: DateTime.parse(json['started_at'] as String),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$RideSessionToJson(_RideSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'started_by': instance.startedBy,
      'name': instance.name,
      'status': _$RideSessionStatusEnumMap[instance.status]!,
      'started_at': instance.startedAt.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$RideSessionStatusEnumMap = {
  RideSessionStatus.waiting: 'waiting',
  RideSessionStatus.active: 'active',
  RideSessionStatus.finished: 'finished',
  RideSessionStatus.cancelled: 'cancelled',
};
