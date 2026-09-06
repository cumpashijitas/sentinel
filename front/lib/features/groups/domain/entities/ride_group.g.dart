// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideGroup _$RideGroupFromJson(Map<String, dynamic> json) => _RideGroup(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  inviteCode: json['invite_code'] as String,
  status: $enumDecode(_$RideGroupStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RideGroupToJson(_RideGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'description': instance.description,
      'invite_code': instance.inviteCode,
      'status': _$RideGroupStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$RideGroupStatusEnumMap = {
  RideGroupStatus.active: 'active',
  RideGroupStatus.archived: 'archived',
};
