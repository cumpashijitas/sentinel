// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_push_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DevicePushToken _$DevicePushTokenFromJson(Map<String, dynamic> json) =>
    _DevicePushToken(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      platform: $enumDecode(_$DevicePushTokenPlatformEnumMap, json['platform']),
      token: json['token'] as String,
      enabled: json['enabled'] as bool,
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DevicePushTokenToJson(_DevicePushToken instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'platform': _$DevicePushTokenPlatformEnumMap[instance.platform]!,
      'token': instance.token,
      'enabled': instance.enabled,
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$DevicePushTokenPlatformEnumMap = {
  DevicePushTokenPlatform.android: 'android',
  DevicePushTokenPlatform.web: 'web',
};
