// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapRoute {

 String get id; List<MapCoordinate> get points;
/// Create a copy of MapRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapRouteCopyWith<MapRoute> get copyWith => _$MapRouteCopyWithImpl<MapRoute>(this as MapRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapRoute&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.points, points));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'MapRoute(id: $id, points: $points)';
}


}

/// @nodoc
abstract mixin class $MapRouteCopyWith<$Res>  {
  factory $MapRouteCopyWith(MapRoute value, $Res Function(MapRoute) _then) = _$MapRouteCopyWithImpl;
@useResult
$Res call({
 String id, List<MapCoordinate> points
});




}
/// @nodoc
class _$MapRouteCopyWithImpl<$Res>
    implements $MapRouteCopyWith<$Res> {
  _$MapRouteCopyWithImpl(this._self, this._then);

  final MapRoute _self;
  final $Res Function(MapRoute) _then;

/// Create a copy of MapRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? points = null,}) {
  return _then(MapRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<MapCoordinate>,
  ));
}

}


/// Adds pattern-matching-related methods to [MapRoute].
extension MapRoutePatterns on MapRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapRoute value)  $default,){
final _that = this;
switch (_that) {
case _MapRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapRoute value)?  $default,){
final _that = this;
switch (_that) {
case _MapRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<MapCoordinate> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapRoute() when $default != null:
return $default(_that.id,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<MapCoordinate> points)  $default,) {final _that = this;
switch (_that) {
case _MapRoute():
return $default(_that.id,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<MapCoordinate> points)?  $default,) {final _that = this;
switch (_that) {
case _MapRoute() when $default != null:
return $default(_that.id,_that.points);case _:
  return null;

}
}

}

/// @nodoc


class _MapRoute implements MapRoute {
  const _MapRoute({required this.id, required  List<MapCoordinate> points}): _points = points;
  

@override final  String id;
 final  List<MapCoordinate> _points;
@override List<MapCoordinate> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of MapRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapRouteCopyWith<_MapRoute> get copyWith => __$MapRouteCopyWithImpl<_MapRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapRoute&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._points, _points));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'MapRoute(id: $id, points: $points)';
}


}

/// @nodoc
abstract mixin class _$MapRouteCopyWith<$Res> implements $MapRouteCopyWith<$Res> {
  factory _$MapRouteCopyWith(_MapRoute value, $Res Function(_MapRoute) _then) = __$MapRouteCopyWithImpl;
@override @useResult
$Res call({
 String id, List<MapCoordinate> points
});




}
/// @nodoc
class __$MapRouteCopyWithImpl<$Res>
    implements _$MapRouteCopyWith<$Res> {
  __$MapRouteCopyWithImpl(this._self, this._then);

  final _MapRoute _self;
  final $Res Function(_MapRoute) _then;

/// Create a copy of MapRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? points = null,}) {
  return _then(_MapRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<MapCoordinate>,
  ));
}


}

// dart format on
