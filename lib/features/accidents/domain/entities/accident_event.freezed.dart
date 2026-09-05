// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accident_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccidentEvent {

 String get id; String? get sessionId; String get userId; double? get latitude; double? get longitude; double get impactMps2; double? get gyroRadS; double? get speedKmh; double? get gForce; double? get confidenceScore; AccidentEventStatus get status; DateTime get occurredAt;
/// Create a copy of AccidentEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccidentEventCopyWith<AccidentEvent> get copyWith => _$AccidentEventCopyWithImpl<AccidentEvent>(this as AccidentEvent, _$identity);

  /// Serializes this AccidentEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccidentEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.impactMps2, impactMps2) || other.impactMps2 == impactMps2)&&(identical(other.gyroRadS, gyroRadS) || other.gyroRadS == gyroRadS)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.gForce, gForce) || other.gForce == gForce)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.status, status) || other.status == status)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,userId,latitude,longitude,impactMps2,gyroRadS,speedKmh,gForce,confidenceScore,status,occurredAt);

@override
String toString() {
  return 'AccidentEvent(id: $id, sessionId: $sessionId, userId: $userId, latitude: $latitude, longitude: $longitude, impactMps2: $impactMps2, gyroRadS: $gyroRadS, speedKmh: $speedKmh, gForce: $gForce, confidenceScore: $confidenceScore, status: $status, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $AccidentEventCopyWith<$Res>  {
  factory $AccidentEventCopyWith(AccidentEvent value, $Res Function(AccidentEvent) _then) = _$AccidentEventCopyWithImpl;
@useResult
$Res call({
 String id, String? sessionId, String userId, double? latitude, double? longitude, double impactMps2, double? gyroRadS, double? speedKmh, double? gForce, double? confidenceScore, AccidentEventStatus status, DateTime occurredAt
});




}
/// @nodoc
class _$AccidentEventCopyWithImpl<$Res>
    implements $AccidentEventCopyWith<$Res> {
  _$AccidentEventCopyWithImpl(this._self, this._then);

  final AccidentEvent _self;
  final $Res Function(AccidentEvent) _then;

/// Create a copy of AccidentEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = freezed,Object? userId = null,Object? latitude = freezed,Object? longitude = freezed,Object? impactMps2 = null,Object? gyroRadS = freezed,Object? speedKmh = freezed,Object? gForce = freezed,Object? confidenceScore = freezed,Object? status = null,Object? occurredAt = null,}) {
  return _then(AccidentEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,impactMps2: null == impactMps2 ? _self.impactMps2 : impactMps2 // ignore: cast_nullable_to_non_nullable
as double,gyroRadS: freezed == gyroRadS ? _self.gyroRadS : gyroRadS // ignore: cast_nullable_to_non_nullable
as double?,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,gForce: freezed == gForce ? _self.gForce : gForce // ignore: cast_nullable_to_non_nullable
as double?,confidenceScore: freezed == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccidentEventStatus,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AccidentEvent].
extension AccidentEventPatterns on AccidentEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccidentEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccidentEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccidentEvent value)  $default,){
final _that = this;
switch (_that) {
case _AccidentEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccidentEvent value)?  $default,){
final _that = this;
switch (_that) {
case _AccidentEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String userId,  double? latitude,  double? longitude,  double impactMps2,  double? gyroRadS,  double? speedKmh,  double? gForce,  double? confidenceScore,  AccidentEventStatus status,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccidentEvent() when $default != null:
return $default(_that.id,_that.sessionId,_that.userId,_that.latitude,_that.longitude,_that.impactMps2,_that.gyroRadS,_that.speedKmh,_that.gForce,_that.confidenceScore,_that.status,_that.occurredAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sessionId,  String userId,  double? latitude,  double? longitude,  double impactMps2,  double? gyroRadS,  double? speedKmh,  double? gForce,  double? confidenceScore,  AccidentEventStatus status,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _AccidentEvent():
return $default(_that.id,_that.sessionId,_that.userId,_that.latitude,_that.longitude,_that.impactMps2,_that.gyroRadS,_that.speedKmh,_that.gForce,_that.confidenceScore,_that.status,_that.occurredAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sessionId,  String userId,  double? latitude,  double? longitude,  double impactMps2,  double? gyroRadS,  double? speedKmh,  double? gForce,  double? confidenceScore,  AccidentEventStatus status,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _AccidentEvent() when $default != null:
return $default(_that.id,_that.sessionId,_that.userId,_that.latitude,_that.longitude,_that.impactMps2,_that.gyroRadS,_that.speedKmh,_that.gForce,_that.confidenceScore,_that.status,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AccidentEvent implements AccidentEvent {
  const _AccidentEvent({required this.id, this.sessionId, required this.userId, this.latitude, this.longitude, required this.impactMps2, this.gyroRadS, this.speedKmh, this.gForce, this.confidenceScore, required this.status, required this.occurredAt});
  factory _AccidentEvent.fromJson(Map<String, dynamic> json) => _$AccidentEventFromJson(json);

@override final  String id;
@override final  String? sessionId;
@override final  String userId;
@override final  double? latitude;
@override final  double? longitude;
@override final  double impactMps2;
@override final  double? gyroRadS;
@override final  double? speedKmh;
@override final  double? gForce;
@override final  double? confidenceScore;
@override final  AccidentEventStatus status;
@override final  DateTime occurredAt;

/// Create a copy of AccidentEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccidentEventCopyWith<_AccidentEvent> get copyWith => __$AccidentEventCopyWithImpl<_AccidentEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccidentEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccidentEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.impactMps2, impactMps2) || other.impactMps2 == impactMps2)&&(identical(other.gyroRadS, gyroRadS) || other.gyroRadS == gyroRadS)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.gForce, gForce) || other.gForce == gForce)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.status, status) || other.status == status)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,userId,latitude,longitude,impactMps2,gyroRadS,speedKmh,gForce,confidenceScore,status,occurredAt);

@override
String toString() {
  return 'AccidentEvent(id: $id, sessionId: $sessionId, userId: $userId, latitude: $latitude, longitude: $longitude, impactMps2: $impactMps2, gyroRadS: $gyroRadS, speedKmh: $speedKmh, gForce: $gForce, confidenceScore: $confidenceScore, status: $status, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$AccidentEventCopyWith<$Res> implements $AccidentEventCopyWith<$Res> {
  factory _$AccidentEventCopyWith(_AccidentEvent value, $Res Function(_AccidentEvent) _then) = __$AccidentEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sessionId, String userId, double? latitude, double? longitude, double impactMps2, double? gyroRadS, double? speedKmh, double? gForce, double? confidenceScore, AccidentEventStatus status, DateTime occurredAt
});




}
/// @nodoc
class __$AccidentEventCopyWithImpl<$Res>
    implements _$AccidentEventCopyWith<$Res> {
  __$AccidentEventCopyWithImpl(this._self, this._then);

  final _AccidentEvent _self;
  final $Res Function(_AccidentEvent) _then;

/// Create a copy of AccidentEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = freezed,Object? userId = null,Object? latitude = freezed,Object? longitude = freezed,Object? impactMps2 = null,Object? gyroRadS = freezed,Object? speedKmh = freezed,Object? gForce = freezed,Object? confidenceScore = freezed,Object? status = null,Object? occurredAt = null,}) {
  return _then(_AccidentEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,impactMps2: null == impactMps2 ? _self.impactMps2 : impactMps2 // ignore: cast_nullable_to_non_nullable
as double,gyroRadS: freezed == gyroRadS ? _self.gyroRadS : gyroRadS // ignore: cast_nullable_to_non_nullable
as double?,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,gForce: freezed == gForce ? _self.gForce : gForce // ignore: cast_nullable_to_non_nullable
as double?,confidenceScore: freezed == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccidentEventStatus,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
