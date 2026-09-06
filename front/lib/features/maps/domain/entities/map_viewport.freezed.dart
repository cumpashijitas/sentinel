// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_viewport.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapViewport {

 MapCoordinate get center; double get zoom;/// Degrees clockwise from north — 0 is "north up". Non-zero when the
/// camera is following a moving rider's heading.
 double get bearing;/// Camera pitch in degrees, 0 = straight down.
 double get tilt;
/// Create a copy of MapViewport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapViewportCopyWith<MapViewport> get copyWith => _$MapViewportCopyWithImpl<MapViewport>(this as MapViewport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapViewport&&(identical(other.center, center) || other.center == center)&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.bearing, bearing) || other.bearing == bearing)&&(identical(other.tilt, tilt) || other.tilt == tilt));
}


@override
int get hashCode => Object.hash(runtimeType,center,zoom,bearing,tilt);

@override
String toString() {
  return 'MapViewport(center: $center, zoom: $zoom, bearing: $bearing, tilt: $tilt)';
}


}

/// @nodoc
abstract mixin class $MapViewportCopyWith<$Res>  {
  factory $MapViewportCopyWith(MapViewport value, $Res Function(MapViewport) _then) = _$MapViewportCopyWithImpl;
@useResult
$Res call({
 MapCoordinate center, double zoom, double bearing, double tilt
});


$MapCoordinateCopyWith<$Res> get center;

}
/// @nodoc
class _$MapViewportCopyWithImpl<$Res>
    implements $MapViewportCopyWith<$Res> {
  _$MapViewportCopyWithImpl(this._self, this._then);

  final MapViewport _self;
  final $Res Function(MapViewport) _then;

/// Create a copy of MapViewport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? center = null,Object? zoom = null,Object? bearing = null,Object? tilt = null,}) {
  return _then(MapViewport(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as MapCoordinate,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,bearing: null == bearing ? _self.bearing : bearing // ignore: cast_nullable_to_non_nullable
as double,tilt: null == tilt ? _self.tilt : tilt // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of MapViewport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get center {
  
  return $MapCoordinateCopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapViewport].
extension MapViewportPatterns on MapViewport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapViewport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapViewport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapViewport value)  $default,){
final _that = this;
switch (_that) {
case _MapViewport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapViewport value)?  $default,){
final _that = this;
switch (_that) {
case _MapViewport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapCoordinate center,  double zoom,  double bearing,  double tilt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapViewport() when $default != null:
return $default(_that.center,_that.zoom,_that.bearing,_that.tilt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapCoordinate center,  double zoom,  double bearing,  double tilt)  $default,) {final _that = this;
switch (_that) {
case _MapViewport():
return $default(_that.center,_that.zoom,_that.bearing,_that.tilt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapCoordinate center,  double zoom,  double bearing,  double tilt)?  $default,) {final _that = this;
switch (_that) {
case _MapViewport() when $default != null:
return $default(_that.center,_that.zoom,_that.bearing,_that.tilt);case _:
  return null;

}
}

}

/// @nodoc


class _MapViewport implements MapViewport {
  const _MapViewport({required this.center, required this.zoom, this.bearing = 0, this.tilt = 0});
  

@override final  MapCoordinate center;
@override final  double zoom;
/// Degrees clockwise from north — 0 is "north up". Non-zero when the
/// camera is following a moving rider's heading.
@override@JsonKey() final  double bearing;
/// Camera pitch in degrees, 0 = straight down.
@override@JsonKey() final  double tilt;

/// Create a copy of MapViewport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapViewportCopyWith<_MapViewport> get copyWith => __$MapViewportCopyWithImpl<_MapViewport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapViewport&&(identical(other.center, center) || other.center == center)&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.bearing, bearing) || other.bearing == bearing)&&(identical(other.tilt, tilt) || other.tilt == tilt));
}


@override
int get hashCode => Object.hash(runtimeType,center,zoom,bearing,tilt);

@override
String toString() {
  return 'MapViewport(center: $center, zoom: $zoom, bearing: $bearing, tilt: $tilt)';
}


}

/// @nodoc
abstract mixin class _$MapViewportCopyWith<$Res> implements $MapViewportCopyWith<$Res> {
  factory _$MapViewportCopyWith(_MapViewport value, $Res Function(_MapViewport) _then) = __$MapViewportCopyWithImpl;
@override @useResult
$Res call({
 MapCoordinate center, double zoom, double bearing, double tilt
});


@override $MapCoordinateCopyWith<$Res> get center;

}
/// @nodoc
class __$MapViewportCopyWithImpl<$Res>
    implements _$MapViewportCopyWith<$Res> {
  __$MapViewportCopyWithImpl(this._self, this._then);

  final _MapViewport _self;
  final $Res Function(_MapViewport) _then;

/// Create a copy of MapViewport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? center = null,Object? zoom = null,Object? bearing = null,Object? tilt = null,}) {
  return _then(_MapViewport(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as MapCoordinate,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,bearing: null == bearing ? _self.bearing : bearing // ignore: cast_nullable_to_non_nullable
as double,tilt: null == tilt ? _self.tilt : tilt // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of MapViewport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get center {
  
  return $MapCoordinateCopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}

// dart format on
