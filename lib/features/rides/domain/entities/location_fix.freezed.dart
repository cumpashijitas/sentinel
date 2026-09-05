// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_fix.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationFix {

 double get latitude; double get longitude; double? get accuracy; double? get speed; double? get heading; int? get batteryLevel; DateTime get recordedAt;
/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationFixCopyWith<LocationFix> get copyWith => _$LocationFixCopyWithImpl<LocationFix>(this as LocationFix, _$identity);

  /// Serializes this LocationFix to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationFix&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,speed,heading,batteryLevel,recordedAt);

@override
String toString() {
  return 'LocationFix(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, speed: $speed, heading: $heading, batteryLevel: $batteryLevel, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class $LocationFixCopyWith<$Res>  {
  factory $LocationFixCopyWith(LocationFix value, $Res Function(LocationFix) _then) = _$LocationFixCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double? accuracy, double? speed, double? heading, int? batteryLevel, DateTime recordedAt
});




}
/// @nodoc
class _$LocationFixCopyWithImpl<$Res>
    implements $LocationFixCopyWith<$Res> {
  _$LocationFixCopyWithImpl(this._self, this._then);

  final LocationFix _self;
  final $Res Function(LocationFix) _then;

/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? speed = freezed,Object? heading = freezed,Object? batteryLevel = freezed,Object? recordedAt = null,}) {
  return _then(LocationFix(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationFix].
extension LocationFixPatterns on LocationFix {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationFix value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationFix value)  $default,){
final _that = this;
switch (_that) {
case _LocationFix():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationFix value)?  $default,){
final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracy,  double? speed,  double? heading,  int? batteryLevel,  DateTime recordedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.speed,_that.heading,_that.batteryLevel,_that.recordedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracy,  double? speed,  double? heading,  int? batteryLevel,  DateTime recordedAt)  $default,) {final _that = this;
switch (_that) {
case _LocationFix():
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.speed,_that.heading,_that.batteryLevel,_that.recordedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double? accuracy,  double? speed,  double? heading,  int? batteryLevel,  DateTime recordedAt)?  $default,) {final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.speed,_that.heading,_that.batteryLevel,_that.recordedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _LocationFix implements LocationFix {
  const _LocationFix({required this.latitude, required this.longitude, this.accuracy, this.speed, this.heading, this.batteryLevel, required this.recordedAt});
  factory _LocationFix.fromJson(Map<String, dynamic> json) => _$LocationFixFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  double? accuracy;
@override final  double? speed;
@override final  double? heading;
@override final  int? batteryLevel;
@override final  DateTime recordedAt;

/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationFixCopyWith<_LocationFix> get copyWith => __$LocationFixCopyWithImpl<_LocationFix>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationFixToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationFix&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,speed,heading,batteryLevel,recordedAt);

@override
String toString() {
  return 'LocationFix(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, speed: $speed, heading: $heading, batteryLevel: $batteryLevel, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class _$LocationFixCopyWith<$Res> implements $LocationFixCopyWith<$Res> {
  factory _$LocationFixCopyWith(_LocationFix value, $Res Function(_LocationFix) _then) = __$LocationFixCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double? accuracy, double? speed, double? heading, int? batteryLevel, DateTime recordedAt
});




}
/// @nodoc
class __$LocationFixCopyWithImpl<$Res>
    implements _$LocationFixCopyWith<$Res> {
  __$LocationFixCopyWithImpl(this._self, this._then);

  final _LocationFix _self;
  final $Res Function(_LocationFix) _then;

/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? speed = freezed,Object? heading = freezed,Object? batteryLevel = freezed,Object? recordedAt = null,}) {
  return _then(_LocationFix(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
