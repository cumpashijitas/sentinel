// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideSession {

 String get id; String get groupId; String get startedBy; String? get name; RideSessionStatus get status; DateTime get startedAt; DateTime? get endedAt; DateTime get createdAt;
/// Create a copy of RideSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideSessionCopyWith<RideSession> get copyWith => _$RideSessionCopyWithImpl<RideSession>(this as RideSession, _$identity);

  /// Serializes this RideSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSession&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.startedBy, startedBy) || other.startedBy == startedBy)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,startedBy,name,status,startedAt,endedAt,createdAt);

@override
String toString() {
  return 'RideSession(id: $id, groupId: $groupId, startedBy: $startedBy, name: $name, status: $status, startedAt: $startedAt, endedAt: $endedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RideSessionCopyWith<$Res>  {
  factory $RideSessionCopyWith(RideSession value, $Res Function(RideSession) _then) = _$RideSessionCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String startedBy, String? name, RideSessionStatus status, DateTime startedAt, DateTime? endedAt, DateTime createdAt
});




}
/// @nodoc
class _$RideSessionCopyWithImpl<$Res>
    implements $RideSessionCopyWith<$Res> {
  _$RideSessionCopyWithImpl(this._self, this._then);

  final RideSession _self;
  final $Res Function(RideSession) _then;

/// Create a copy of RideSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? startedBy = null,Object? name = freezed,Object? status = null,Object? startedAt = null,Object? endedAt = freezed,Object? createdAt = null,}) {
  return _then(RideSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,startedBy: null == startedBy ? _self.startedBy : startedBy // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideSessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RideSession].
extension RideSessionPatterns on RideSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSession value)  $default,){
final _that = this;
switch (_that) {
case _RideSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSession value)?  $default,){
final _that = this;
switch (_that) {
case _RideSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String startedBy,  String? name,  RideSessionStatus status,  DateTime startedAt,  DateTime? endedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSession() when $default != null:
return $default(_that.id,_that.groupId,_that.startedBy,_that.name,_that.status,_that.startedAt,_that.endedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String startedBy,  String? name,  RideSessionStatus status,  DateTime startedAt,  DateTime? endedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _RideSession():
return $default(_that.id,_that.groupId,_that.startedBy,_that.name,_that.status,_that.startedAt,_that.endedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String startedBy,  String? name,  RideSessionStatus status,  DateTime startedAt,  DateTime? endedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RideSession() when $default != null:
return $default(_that.id,_that.groupId,_that.startedBy,_that.name,_that.status,_that.startedAt,_that.endedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RideSession implements RideSession {
  const _RideSession({required this.id, required this.groupId, required this.startedBy, this.name, required this.status, required this.startedAt, this.endedAt, required this.createdAt});
  factory _RideSession.fromJson(Map<String, dynamic> json) => _$RideSessionFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String startedBy;
@override final  String? name;
@override final  RideSessionStatus status;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override final  DateTime createdAt;

/// Create a copy of RideSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideSessionCopyWith<_RideSession> get copyWith => __$RideSessionCopyWithImpl<_RideSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSession&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.startedBy, startedBy) || other.startedBy == startedBy)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,startedBy,name,status,startedAt,endedAt,createdAt);

@override
String toString() {
  return 'RideSession(id: $id, groupId: $groupId, startedBy: $startedBy, name: $name, status: $status, startedAt: $startedAt, endedAt: $endedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RideSessionCopyWith<$Res> implements $RideSessionCopyWith<$Res> {
  factory _$RideSessionCopyWith(_RideSession value, $Res Function(_RideSession) _then) = __$RideSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String startedBy, String? name, RideSessionStatus status, DateTime startedAt, DateTime? endedAt, DateTime createdAt
});




}
/// @nodoc
class __$RideSessionCopyWithImpl<$Res>
    implements _$RideSessionCopyWith<$Res> {
  __$RideSessionCopyWithImpl(this._self, this._then);

  final _RideSession _self;
  final $Res Function(_RideSession) _then;

/// Create a copy of RideSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? startedBy = null,Object? name = freezed,Object? status = null,Object? startedAt = null,Object? endedAt = freezed,Object? createdAt = null,}) {
  return _then(_RideSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,startedBy: null == startedBy ? _self.startedBy : startedBy // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideSessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
