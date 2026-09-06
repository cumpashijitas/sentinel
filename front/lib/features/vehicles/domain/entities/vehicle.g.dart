// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vehicle _$VehicleFromJson(Map<String, dynamic> json) => _Vehicle(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  brand: json['brand'] as String,
  model: json['model'] as String,
  year: (json['year'] as num?)?.toInt(),
  plate: json['plate'] as String?,
  color: json['color'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$VehicleToJson(_Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'brand': instance.brand,
  'model': instance.model,
  'year': instance.year,
  'plate': instance.plate,
  'color': instance.color,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
