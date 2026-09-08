// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MemberLocation {

 String get userId; String get displayName; String? get avatarUrl; LocationFix? get fix; MemberTrackingStatus get status;
/// Create a copy of MemberLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberLocationCopyWith<MemberLocation> get copyWith => _$MemberLocationCopyWithImpl<MemberLocation>(this as MemberLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberLocation&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.fix, fix) || other.fix == fix)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl,fix,status);

@override
String toString() {
  return 'MemberLocation(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, fix: $fix, status: $status)';
}


}

/// @nodoc
abstract mixin class $MemberLocationCopyWith<$Res>  {
  factory $MemberLocationCopyWith(MemberLocation value, $Res Function(MemberLocation) _then) = _$MemberLocationCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String? avatarUrl, LocationFix? fix, MemberTrackingStatus status
});


$LocationFixCopyWith<$Res>? get fix;

}
/// @nodoc
class _$MemberLocationCopyWithImpl<$Res>
    implements $MemberLocationCopyWith<$Res> {
  _$MemberLocationCopyWithImpl(this._self, this._then);

  final MemberLocation _self;
  final $Res Function(MemberLocation) _then;

/// Create a copy of MemberLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,Object? fix = freezed,Object? status = null,}) {
  return _then(MemberLocation(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,fix: freezed == fix ? _self.fix : fix // ignore: cast_nullable_to_non_nullable
as LocationFix?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberTrackingStatus,
  ));
}
/// Create a copy of MemberLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationFixCopyWith<$Res>? get fix {
    if (_self.fix == null) {
    return null;
  }

  return $LocationFixCopyWith<$Res>(_self.fix!, (value) {
    return _then(_self.copyWith(fix: value));
  });
}
}


/// Adds pattern-matching-related methods to [MemberLocation].
extension MemberLocationPatterns on MemberLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberLocation value)  $default,){
final _that = this;
switch (_that) {
case _MemberLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberLocation value)?  $default,){
final _that = this;
switch (_that) {
case _MemberLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl,  LocationFix? fix,  MemberTrackingStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberLocation() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.fix,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl,  LocationFix? fix,  MemberTrackingStatus status)  $default,) {final _that = this;
switch (_that) {
case _MemberLocation():
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.fix,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String? avatarUrl,  LocationFix? fix,  MemberTrackingStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MemberLocation() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.fix,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _MemberLocation implements MemberLocation {
  const _MemberLocation({required this.userId, required this.displayName, this.avatarUrl, this.fix, required this.status});
  

@override final  String userId;
@override final  String displayName;
@override final  String? avatarUrl;
@override final  LocationFix? fix;
@override final  MemberTrackingStatus status;

/// Create a copy of MemberLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberLocationCopyWith<_MemberLocation> get copyWith => __$MemberLocationCopyWithImpl<_MemberLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberLocation&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.fix, fix) || other.fix == fix)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl,fix,status);

@override
String toString() {
  return 'MemberLocation(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, fix: $fix, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MemberLocationCopyWith<$Res> implements $MemberLocationCopyWith<$Res> {
  factory _$MemberLocationCopyWith(_MemberLocation value, $Res Function(_MemberLocation) _then) = __$MemberLocationCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String? avatarUrl, LocationFix? fix, MemberTrackingStatus status
});


@override $LocationFixCopyWith<$Res>? get fix;

}
/// @nodoc
class __$MemberLocationCopyWithImpl<$Res>
    implements _$MemberLocationCopyWith<$Res> {
  __$MemberLocationCopyWithImpl(this._self, this._then);

  final _MemberLocation _self;
  final $Res Function(_MemberLocation) _then;

/// Create a copy of MemberLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,Object? fix = freezed,Object? status = null,}) {
  return _then(_MemberLocation(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,fix: freezed == fix ? _self.fix : fix // ignore: cast_nullable_to_non_nullable
as LocationFix?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberTrackingStatus,
  ));
}

/// Create a copy of MemberLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationFixCopyWith<$Res>? get fix {
    if (_self.fix == null) {
    return null;
  }

  return $LocationFixCopyWith<$Res>(_self.fix!, (value) {
    return _then(_self.copyWith(fix: value));
  });
}
}

// dart format on
