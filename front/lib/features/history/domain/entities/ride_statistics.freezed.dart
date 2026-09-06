// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RideStatistics {

 int get totalRides; Duration get totalRideDuration; int get totalAccidents; DateTime? get lastRideAt;
/// Create a copy of RideStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideStatisticsCopyWith<RideStatistics> get copyWith => _$RideStatisticsCopyWithImpl<RideStatistics>(this as RideStatistics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideStatistics&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.totalRideDuration, totalRideDuration) || other.totalRideDuration == totalRideDuration)&&(identical(other.totalAccidents, totalAccidents) || other.totalAccidents == totalAccidents)&&(identical(other.lastRideAt, lastRideAt) || other.lastRideAt == lastRideAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalRides,totalRideDuration,totalAccidents,lastRideAt);

@override
String toString() {
  return 'RideStatistics(totalRides: $totalRides, totalRideDuration: $totalRideDuration, totalAccidents: $totalAccidents, lastRideAt: $lastRideAt)';
}


}

/// @nodoc
abstract mixin class $RideStatisticsCopyWith<$Res>  {
  factory $RideStatisticsCopyWith(RideStatistics value, $Res Function(RideStatistics) _then) = _$RideStatisticsCopyWithImpl;
@useResult
$Res call({
 int totalRides, Duration totalRideDuration, int totalAccidents, DateTime? lastRideAt
});




}
/// @nodoc
class _$RideStatisticsCopyWithImpl<$Res>
    implements $RideStatisticsCopyWith<$Res> {
  _$RideStatisticsCopyWithImpl(this._self, this._then);

  final RideStatistics _self;
  final $Res Function(RideStatistics) _then;

/// Create a copy of RideStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRides = null,Object? totalRideDuration = null,Object? totalAccidents = null,Object? lastRideAt = freezed,}) {
  return _then(RideStatistics(
totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,totalRideDuration: null == totalRideDuration ? _self.totalRideDuration : totalRideDuration // ignore: cast_nullable_to_non_nullable
as Duration,totalAccidents: null == totalAccidents ? _self.totalAccidents : totalAccidents // ignore: cast_nullable_to_non_nullable
as int,lastRideAt: freezed == lastRideAt ? _self.lastRideAt : lastRideAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideStatistics].
extension RideStatisticsPatterns on RideStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideStatistics value)  $default,){
final _that = this;
switch (_that) {
case _RideStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _RideStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalRides,  Duration totalRideDuration,  int totalAccidents,  DateTime? lastRideAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideStatistics() when $default != null:
return $default(_that.totalRides,_that.totalRideDuration,_that.totalAccidents,_that.lastRideAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalRides,  Duration totalRideDuration,  int totalAccidents,  DateTime? lastRideAt)  $default,) {final _that = this;
switch (_that) {
case _RideStatistics():
return $default(_that.totalRides,_that.totalRideDuration,_that.totalAccidents,_that.lastRideAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalRides,  Duration totalRideDuration,  int totalAccidents,  DateTime? lastRideAt)?  $default,) {final _that = this;
switch (_that) {
case _RideStatistics() when $default != null:
return $default(_that.totalRides,_that.totalRideDuration,_that.totalAccidents,_that.lastRideAt);case _:
  return null;

}
}

}

/// @nodoc


class _RideStatistics implements RideStatistics {
  const _RideStatistics({required this.totalRides, required this.totalRideDuration, required this.totalAccidents, this.lastRideAt});
  

@override final  int totalRides;
@override final  Duration totalRideDuration;
@override final  int totalAccidents;
@override final  DateTime? lastRideAt;

/// Create a copy of RideStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideStatisticsCopyWith<_RideStatistics> get copyWith => __$RideStatisticsCopyWithImpl<_RideStatistics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideStatistics&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.totalRideDuration, totalRideDuration) || other.totalRideDuration == totalRideDuration)&&(identical(other.totalAccidents, totalAccidents) || other.totalAccidents == totalAccidents)&&(identical(other.lastRideAt, lastRideAt) || other.lastRideAt == lastRideAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalRides,totalRideDuration,totalAccidents,lastRideAt);

@override
String toString() {
  return 'RideStatistics(totalRides: $totalRides, totalRideDuration: $totalRideDuration, totalAccidents: $totalAccidents, lastRideAt: $lastRideAt)';
}


}

/// @nodoc
abstract mixin class _$RideStatisticsCopyWith<$Res> implements $RideStatisticsCopyWith<$Res> {
  factory _$RideStatisticsCopyWith(_RideStatistics value, $Res Function(_RideStatistics) _then) = __$RideStatisticsCopyWithImpl;
@override @useResult
$Res call({
 int totalRides, Duration totalRideDuration, int totalAccidents, DateTime? lastRideAt
});




}
/// @nodoc
class __$RideStatisticsCopyWithImpl<$Res>
    implements _$RideStatisticsCopyWith<$Res> {
  __$RideStatisticsCopyWithImpl(this._self, this._then);

  final _RideStatistics _self;
  final $Res Function(_RideStatistics) _then;

/// Create a copy of RideStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRides = null,Object? totalRideDuration = null,Object? totalAccidents = null,Object? lastRideAt = freezed,}) {
  return _then(_RideStatistics(
totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,totalRideDuration: null == totalRideDuration ? _self.totalRideDuration : totalRideDuration // ignore: cast_nullable_to_non_nullable
as Duration,totalAccidents: null == totalAccidents ? _self.totalAccidents : totalAccidents // ignore: cast_nullable_to_non_nullable
as int,lastRideAt: freezed == lastRideAt ? _self.lastRideAt : lastRideAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
