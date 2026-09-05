// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_marker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapMarker {

/// Stable across updates — a member's is their `userId`; route
/// start/destination/accident markers use a fixed constant id.
/// `MapController.setMarkers` uses this to decide "update in place"
/// vs. "add"/"remove" rather than tearing down every marker each call.
 String get id; MapCoordinate get coordinate; MapMarkerCategory get category; MapMarkerStatus? get status; String? get label;/// Degrees, 0-360, or `null` if unknown — rotates the marker icon to
/// face the direction of travel.
 double? get headingDegrees;/// km/h, or `null` if unknown/not shown for this marker.
 double? get speedKmh;
/// Create a copy of MapMarker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapMarkerCopyWith<MapMarker> get copyWith => _$MapMarkerCopyWithImpl<MapMarker>(this as MapMarker, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapMarker&&(identical(other.id, id) || other.id == id)&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.label, label) || other.label == label)&&(identical(other.headingDegrees, headingDegrees) || other.headingDegrees == headingDegrees)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh));
}


@override
int get hashCode => Object.hash(runtimeType,id,coordinate,category,status,label,headingDegrees,speedKmh);

@override
String toString() {
  return 'MapMarker(id: $id, coordinate: $coordinate, category: $category, status: $status, label: $label, headingDegrees: $headingDegrees, speedKmh: $speedKmh)';
}


}

/// @nodoc
abstract mixin class $MapMarkerCopyWith<$Res>  {
  factory $MapMarkerCopyWith(MapMarker value, $Res Function(MapMarker) _then) = _$MapMarkerCopyWithImpl;
@useResult
$Res call({
 String id, MapCoordinate coordinate, MapMarkerCategory category, MapMarkerStatus? status, String? label, double? headingDegrees, double? speedKmh
});


$MapCoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class _$MapMarkerCopyWithImpl<$Res>
    implements $MapMarkerCopyWith<$Res> {
  _$MapMarkerCopyWithImpl(this._self, this._then);

  final MapMarker _self;
  final $Res Function(MapMarker) _then;

/// Create a copy of MapMarker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coordinate = null,Object? category = null,Object? status = freezed,Object? label = freezed,Object? headingDegrees = freezed,Object? speedKmh = freezed,}) {
  return _then(MapMarker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as MapCoordinate,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MapMarkerCategory,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MapMarkerStatus?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,headingDegrees: freezed == headingDegrees ? _self.headingDegrees : headingDegrees // ignore: cast_nullable_to_non_nullable
as double?,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of MapMarker
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get coordinate {
  
  return $MapCoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapMarker].
extension MapMarkerPatterns on MapMarker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapMarker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapMarker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapMarker value)  $default,){
final _that = this;
switch (_that) {
case _MapMarker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapMarker value)?  $default,){
final _that = this;
switch (_that) {
case _MapMarker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MapCoordinate coordinate,  MapMarkerCategory category,  MapMarkerStatus? status,  String? label,  double? headingDegrees,  double? speedKmh)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapMarker() when $default != null:
return $default(_that.id,_that.coordinate,_that.category,_that.status,_that.label,_that.headingDegrees,_that.speedKmh);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MapCoordinate coordinate,  MapMarkerCategory category,  MapMarkerStatus? status,  String? label,  double? headingDegrees,  double? speedKmh)  $default,) {final _that = this;
switch (_that) {
case _MapMarker():
return $default(_that.id,_that.coordinate,_that.category,_that.status,_that.label,_that.headingDegrees,_that.speedKmh);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MapCoordinate coordinate,  MapMarkerCategory category,  MapMarkerStatus? status,  String? label,  double? headingDegrees,  double? speedKmh)?  $default,) {final _that = this;
switch (_that) {
case _MapMarker() when $default != null:
return $default(_that.id,_that.coordinate,_that.category,_that.status,_that.label,_that.headingDegrees,_that.speedKmh);case _:
  return null;

}
}

}

/// @nodoc


class _MapMarker implements MapMarker {
  const _MapMarker({required this.id, required this.coordinate, required this.category, this.status, this.label, this.headingDegrees, this.speedKmh});
  

/// Stable across updates — a member's is their `userId`; route
/// start/destination/accident markers use a fixed constant id.
/// `MapController.setMarkers` uses this to decide "update in place"
/// vs. "add"/"remove" rather than tearing down every marker each call.
@override final  String id;
@override final  MapCoordinate coordinate;
@override final  MapMarkerCategory category;
@override final  MapMarkerStatus? status;
@override final  String? label;
/// Degrees, 0-360, or `null` if unknown — rotates the marker icon to
/// face the direction of travel.
@override final  double? headingDegrees;
/// km/h, or `null` if unknown/not shown for this marker.
@override final  double? speedKmh;

/// Create a copy of MapMarker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapMarkerCopyWith<_MapMarker> get copyWith => __$MapMarkerCopyWithImpl<_MapMarker>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapMarker&&(identical(other.id, id) || other.id == id)&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.label, label) || other.label == label)&&(identical(other.headingDegrees, headingDegrees) || other.headingDegrees == headingDegrees)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh));
}


@override
int get hashCode => Object.hash(runtimeType,id,coordinate,category,status,label,headingDegrees,speedKmh);

@override
String toString() {
  return 'MapMarker(id: $id, coordinate: $coordinate, category: $category, status: $status, label: $label, headingDegrees: $headingDegrees, speedKmh: $speedKmh)';
}


}

/// @nodoc
abstract mixin class _$MapMarkerCopyWith<$Res> implements $MapMarkerCopyWith<$Res> {
  factory _$MapMarkerCopyWith(_MapMarker value, $Res Function(_MapMarker) _then) = __$MapMarkerCopyWithImpl;
@override @useResult
$Res call({
 String id, MapCoordinate coordinate, MapMarkerCategory category, MapMarkerStatus? status, String? label, double? headingDegrees, double? speedKmh
});


@override $MapCoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class __$MapMarkerCopyWithImpl<$Res>
    implements _$MapMarkerCopyWith<$Res> {
  __$MapMarkerCopyWithImpl(this._self, this._then);

  final _MapMarker _self;
  final $Res Function(_MapMarker) _then;

/// Create a copy of MapMarker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coordinate = null,Object? category = null,Object? status = freezed,Object? label = freezed,Object? headingDegrees = freezed,Object? speedKmh = freezed,}) {
  return _then(_MapMarker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as MapCoordinate,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MapMarkerCategory,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MapMarkerStatus?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,headingDegrees: freezed == headingDegrees ? _self.headingDegrees : headingDegrees // ignore: cast_nullable_to_non_nullable
as double?,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of MapMarker
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get coordinate {
  
  return $MapCoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
  });
}
}

// dart format on
