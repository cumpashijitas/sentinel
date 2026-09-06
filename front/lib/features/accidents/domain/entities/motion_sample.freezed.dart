// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'motion_sample.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MotionSample {

 double get accelX; double get accelY; double get accelZ; double? get gyroX; double? get gyroY; double? get gyroZ; DateTime get recordedAt;
/// Create a copy of MotionSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotionSampleCopyWith<MotionSample> get copyWith => _$MotionSampleCopyWithImpl<MotionSample>(this as MotionSample, _$identity);

  /// Serializes this MotionSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MotionSample&&(identical(other.accelX, accelX) || other.accelX == accelX)&&(identical(other.accelY, accelY) || other.accelY == accelY)&&(identical(other.accelZ, accelZ) || other.accelZ == accelZ)&&(identical(other.gyroX, gyroX) || other.gyroX == gyroX)&&(identical(other.gyroY, gyroY) || other.gyroY == gyroY)&&(identical(other.gyroZ, gyroZ) || other.gyroZ == gyroZ)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accelX,accelY,accelZ,gyroX,gyroY,gyroZ,recordedAt);

@override
String toString() {
  return 'MotionSample(accelX: $accelX, accelY: $accelY, accelZ: $accelZ, gyroX: $gyroX, gyroY: $gyroY, gyroZ: $gyroZ, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class $MotionSampleCopyWith<$Res>  {
  factory $MotionSampleCopyWith(MotionSample value, $Res Function(MotionSample) _then) = _$MotionSampleCopyWithImpl;
@useResult
$Res call({
 double accelX, double accelY, double accelZ, double? gyroX, double? gyroY, double? gyroZ, DateTime recordedAt
});




}
/// @nodoc
class _$MotionSampleCopyWithImpl<$Res>
    implements $MotionSampleCopyWith<$Res> {
  _$MotionSampleCopyWithImpl(this._self, this._then);

  final MotionSample _self;
  final $Res Function(MotionSample) _then;

/// Create a copy of MotionSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accelX = null,Object? accelY = null,Object? accelZ = null,Object? gyroX = freezed,Object? gyroY = freezed,Object? gyroZ = freezed,Object? recordedAt = null,}) {
  return _then(MotionSample(
accelX: null == accelX ? _self.accelX : accelX // ignore: cast_nullable_to_non_nullable
as double,accelY: null == accelY ? _self.accelY : accelY // ignore: cast_nullable_to_non_nullable
as double,accelZ: null == accelZ ? _self.accelZ : accelZ // ignore: cast_nullable_to_non_nullable
as double,gyroX: freezed == gyroX ? _self.gyroX : gyroX // ignore: cast_nullable_to_non_nullable
as double?,gyroY: freezed == gyroY ? _self.gyroY : gyroY // ignore: cast_nullable_to_non_nullable
as double?,gyroZ: freezed == gyroZ ? _self.gyroZ : gyroZ // ignore: cast_nullable_to_non_nullable
as double?,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MotionSample].
extension MotionSamplePatterns on MotionSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MotionSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MotionSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MotionSample value)  $default,){
final _that = this;
switch (_that) {
case _MotionSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MotionSample value)?  $default,){
final _that = this;
switch (_that) {
case _MotionSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double accelX,  double accelY,  double accelZ,  double? gyroX,  double? gyroY,  double? gyroZ,  DateTime recordedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MotionSample() when $default != null:
return $default(_that.accelX,_that.accelY,_that.accelZ,_that.gyroX,_that.gyroY,_that.gyroZ,_that.recordedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double accelX,  double accelY,  double accelZ,  double? gyroX,  double? gyroY,  double? gyroZ,  DateTime recordedAt)  $default,) {final _that = this;
switch (_that) {
case _MotionSample():
return $default(_that.accelX,_that.accelY,_that.accelZ,_that.gyroX,_that.gyroY,_that.gyroZ,_that.recordedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double accelX,  double accelY,  double accelZ,  double? gyroX,  double? gyroY,  double? gyroZ,  DateTime recordedAt)?  $default,) {final _that = this;
switch (_that) {
case _MotionSample() when $default != null:
return $default(_that.accelX,_that.accelY,_that.accelZ,_that.gyroX,_that.gyroY,_that.gyroZ,_that.recordedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MotionSample implements MotionSample {
  const _MotionSample({required this.accelX, required this.accelY, required this.accelZ, this.gyroX, this.gyroY, this.gyroZ, required this.recordedAt});
  factory _MotionSample.fromJson(Map<String, dynamic> json) => _$MotionSampleFromJson(json);

@override final  double accelX;
@override final  double accelY;
@override final  double accelZ;
@override final  double? gyroX;
@override final  double? gyroY;
@override final  double? gyroZ;
@override final  DateTime recordedAt;

/// Create a copy of MotionSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MotionSampleCopyWith<_MotionSample> get copyWith => __$MotionSampleCopyWithImpl<_MotionSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MotionSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MotionSample&&(identical(other.accelX, accelX) || other.accelX == accelX)&&(identical(other.accelY, accelY) || other.accelY == accelY)&&(identical(other.accelZ, accelZ) || other.accelZ == accelZ)&&(identical(other.gyroX, gyroX) || other.gyroX == gyroX)&&(identical(other.gyroY, gyroY) || other.gyroY == gyroY)&&(identical(other.gyroZ, gyroZ) || other.gyroZ == gyroZ)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accelX,accelY,accelZ,gyroX,gyroY,gyroZ,recordedAt);

@override
String toString() {
  return 'MotionSample(accelX: $accelX, accelY: $accelY, accelZ: $accelZ, gyroX: $gyroX, gyroY: $gyroY, gyroZ: $gyroZ, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class _$MotionSampleCopyWith<$Res> implements $MotionSampleCopyWith<$Res> {
  factory _$MotionSampleCopyWith(_MotionSample value, $Res Function(_MotionSample) _then) = __$MotionSampleCopyWithImpl;
@override @useResult
$Res call({
 double accelX, double accelY, double accelZ, double? gyroX, double? gyroY, double? gyroZ, DateTime recordedAt
});




}
/// @nodoc
class __$MotionSampleCopyWithImpl<$Res>
    implements _$MotionSampleCopyWith<$Res> {
  __$MotionSampleCopyWithImpl(this._self, this._then);

  final _MotionSample _self;
  final $Res Function(_MotionSample) _then;

/// Create a copy of MotionSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accelX = null,Object? accelY = null,Object? accelZ = null,Object? gyroX = freezed,Object? gyroY = freezed,Object? gyroZ = freezed,Object? recordedAt = null,}) {
  return _then(_MotionSample(
accelX: null == accelX ? _self.accelX : accelX // ignore: cast_nullable_to_non_nullable
as double,accelY: null == accelY ? _self.accelY : accelY // ignore: cast_nullable_to_non_nullable
as double,accelZ: null == accelZ ? _self.accelZ : accelZ // ignore: cast_nullable_to_non_nullable
as double,gyroX: freezed == gyroX ? _self.gyroX : gyroX // ignore: cast_nullable_to_non_nullable
as double?,gyroY: freezed == gyroY ? _self.gyroY : gyroY // ignore: cast_nullable_to_non_nullable
as double?,gyroZ: freezed == gyroZ ? _self.gyroZ : gyroZ // ignore: cast_nullable_to_non_nullable
as double?,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
