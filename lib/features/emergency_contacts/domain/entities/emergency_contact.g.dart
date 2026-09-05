// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    _EmergencyContact(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      contactUserId: json['contact_user_id'] as String?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String?,
      notifyPush: json['notify_push'] as bool,
      notifySms: json['notify_sms'] as bool,
      notifyWhatsapp: json['notify_whatsapp'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EmergencyContactToJson(_EmergencyContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'contact_user_id': instance.contactUserId,
      'name': instance.name,
      'phone': instance.phone,
      'relationship': instance.relationship,
      'notify_push': instance.notifyPush,
      'notify_sms': instance.notifySms,
      'notify_whatsapp': instance.notifyWhatsapp,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
