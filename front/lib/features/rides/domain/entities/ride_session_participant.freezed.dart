// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_session_participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RideSessionParticipant {

 String get sessionId; String get userId; RideParticipantStatus get status; DateTime get joinedAt; DateTime? get leftAt; DateTime? get lastSeenAt; String get displayName; String? get avatarUrl;
/// Create a copy of RideSessionParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideSessionParticipantCopyWith<RideSessionParticipant> get copyWith => _$RideSessionParticipantCopyWithImpl<RideSessionParticipant>(this as RideSessionParticipant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSessionParticipant&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,userId,status,joinedAt,leftAt,lastSeenAt,displayName,avatarUrl);

@override
String toString() {
  return 'RideSessionParticipant(sessionId: $sessionId, userId: $userId, status: $status, joinedAt: $joinedAt, leftAt: $leftAt, lastSeenAt: $lastSeenAt, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $RideSessionParticipantCopyWith<$Res>  {
  factory $RideSessionParticipantCopyWith(RideSessionParticipant value, $Res Function(RideSessionParticipant) _then) = _$RideSessionParticipantCopyWithImpl;
@useResult
$Res call({
 String sessionId, String userId, RideParticipantStatus status, DateTime joinedAt, DateTime? leftAt, DateTime? lastSeenAt, String displayName, String? avatarUrl
});




}
/// @nodoc
class _$RideSessionParticipantCopyWithImpl<$Res>
    implements $RideSessionParticipantCopyWith<$Res> {
  _$RideSessionParticipantCopyWithImpl(this._self, this._then);

  final RideSessionParticipant _self;
  final $Res Function(RideSessionParticipant) _then;

/// Create a copy of RideSessionParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? userId = null,Object? status = null,Object? joinedAt = null,Object? leftAt = freezed,Object? lastSeenAt = freezed,Object? displayName = null,Object? avatarUrl = freezed,}) {
  return _then(RideSessionParticipant(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideParticipantStatus,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideSessionParticipant].
extension RideSessionParticipantPatterns on RideSessionParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSessionParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSessionParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSessionParticipant value)  $default,){
final _that = this;
switch (_that) {
case _RideSessionParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSessionParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _RideSessionParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String userId,  RideParticipantStatus status,  DateTime joinedAt,  DateTime? leftAt,  DateTime? lastSeenAt,  String displayName,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSessionParticipant() when $default != null:
return $default(_that.sessionId,_that.userId,_that.status,_that.joinedAt,_that.leftAt,_that.lastSeenAt,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String userId,  RideParticipantStatus status,  DateTime joinedAt,  DateTime? leftAt,  DateTime? lastSeenAt,  String displayName,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _RideSessionParticipant():
return $default(_that.sessionId,_that.userId,_that.status,_that.joinedAt,_that.leftAt,_that.lastSeenAt,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String userId,  RideParticipantStatus status,  DateTime joinedAt,  DateTime? leftAt,  DateTime? lastSeenAt,  String displayName,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _RideSessionParticipant() when $default != null:
return $default(_that.sessionId,_that.userId,_that.status,_that.joinedAt,_that.leftAt,_that.lastSeenAt,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _RideSessionParticipant implements RideSessionParticipant {
  const _RideSessionParticipant({required this.sessionId, required this.userId, required this.status, required this.joinedAt, this.leftAt, this.lastSeenAt, required this.displayName, this.avatarUrl});
  

@override final  String sessionId;
@override final  String userId;
@override final  RideParticipantStatus status;
@override final  DateTime joinedAt;
@override final  DateTime? leftAt;
@override final  DateTime? lastSeenAt;
@override final  String displayName;
@override final  String? avatarUrl;

/// Create a copy of RideSessionParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideSessionParticipantCopyWith<_RideSessionParticipant> get copyWith => __$RideSessionParticipantCopyWithImpl<_RideSessionParticipant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSessionParticipant&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,userId,status,joinedAt,leftAt,lastSeenAt,displayName,avatarUrl);

@override
String toString() {
  return 'RideSessionParticipant(sessionId: $sessionId, userId: $userId, status: $status, joinedAt: $joinedAt, leftAt: $leftAt, lastSeenAt: $lastSeenAt, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$RideSessionParticipantCopyWith<$Res> implements $RideSessionParticipantCopyWith<$Res> {
  factory _$RideSessionParticipantCopyWith(_RideSessionParticipant value, $Res Function(_RideSessionParticipant) _then) = __$RideSessionParticipantCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String userId, RideParticipantStatus status, DateTime joinedAt, DateTime? leftAt, DateTime? lastSeenAt, String displayName, String? avatarUrl
});




}
/// @nodoc
class __$RideSessionParticipantCopyWithImpl<$Res>
    implements _$RideSessionParticipantCopyWith<$Res> {
  __$RideSessionParticipantCopyWithImpl(this._self, this._then);

  final _RideSessionParticipant _self;
  final $Res Function(_RideSessionParticipant) _then;

/// Create a copy of RideSessionParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? userId = null,Object? status = null,Object? joinedAt = null,Object? leftAt = freezed,Object? lastSeenAt = freezed,Object? displayName = null,Object? avatarUrl = freezed,}) {
  return _then(_RideSessionParticipant(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideParticipantStatus,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
