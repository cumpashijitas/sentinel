// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RideHistoryEntry {

 String get sessionId; String get groupId; String get groupName; String? get name; RideSessionStatus get status; DateTime get startedAt; DateTime? get endedAt;
/// Create a copy of RideHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideHistoryEntryCopyWith<RideHistoryEntry> get copyWith => _$RideHistoryEntryCopyWithImpl<RideHistoryEntry>(this as RideHistoryEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideHistoryEntry&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,groupId,groupName,name,status,startedAt,endedAt);

@override
String toString() {
  return 'RideHistoryEntry(sessionId: $sessionId, groupId: $groupId, groupName: $groupName, name: $name, status: $status, startedAt: $startedAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class $RideHistoryEntryCopyWith<$Res>  {
  factory $RideHistoryEntryCopyWith(RideHistoryEntry value, $Res Function(RideHistoryEntry) _then) = _$RideHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String sessionId, String groupId, String groupName, String? name, RideSessionStatus status, DateTime startedAt, DateTime? endedAt
});




}
/// @nodoc
class _$RideHistoryEntryCopyWithImpl<$Res>
    implements $RideHistoryEntryCopyWith<$Res> {
  _$RideHistoryEntryCopyWithImpl(this._self, this._then);

  final RideHistoryEntry _self;
  final $Res Function(RideHistoryEntry) _then;

/// Create a copy of RideHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? groupId = null,Object? groupName = null,Object? name = freezed,Object? status = null,Object? startedAt = null,Object? endedAt = freezed,}) {
  return _then(RideHistoryEntry(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideSessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideHistoryEntry].
extension RideHistoryEntryPatterns on RideHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _RideHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RideHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String groupId,  String groupName,  String? name,  RideSessionStatus status,  DateTime startedAt,  DateTime? endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideHistoryEntry() when $default != null:
return $default(_that.sessionId,_that.groupId,_that.groupName,_that.name,_that.status,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String groupId,  String groupName,  String? name,  RideSessionStatus status,  DateTime startedAt,  DateTime? endedAt)  $default,) {final _that = this;
switch (_that) {
case _RideHistoryEntry():
return $default(_that.sessionId,_that.groupId,_that.groupName,_that.name,_that.status,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String groupId,  String groupName,  String? name,  RideSessionStatus status,  DateTime startedAt,  DateTime? endedAt)?  $default,) {final _that = this;
switch (_that) {
case _RideHistoryEntry() when $default != null:
return $default(_that.sessionId,_that.groupId,_that.groupName,_that.name,_that.status,_that.startedAt,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RideHistoryEntry extends RideHistoryEntry {
  const _RideHistoryEntry({required this.sessionId, required this.groupId, required this.groupName, this.name, required this.status, required this.startedAt, this.endedAt}): super._();
  

@override final  String sessionId;
@override final  String groupId;
@override final  String groupName;
@override final  String? name;
@override final  RideSessionStatus status;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;

/// Create a copy of RideHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideHistoryEntryCopyWith<_RideHistoryEntry> get copyWith => __$RideHistoryEntryCopyWithImpl<_RideHistoryEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideHistoryEntry&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,groupId,groupName,name,status,startedAt,endedAt);

@override
String toString() {
  return 'RideHistoryEntry(sessionId: $sessionId, groupId: $groupId, groupName: $groupName, name: $name, status: $status, startedAt: $startedAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$RideHistoryEntryCopyWith<$Res> implements $RideHistoryEntryCopyWith<$Res> {
  factory _$RideHistoryEntryCopyWith(_RideHistoryEntry value, $Res Function(_RideHistoryEntry) _then) = __$RideHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String groupId, String groupName, String? name, RideSessionStatus status, DateTime startedAt, DateTime? endedAt
});




}
/// @nodoc
class __$RideHistoryEntryCopyWithImpl<$Res>
    implements _$RideHistoryEntryCopyWith<$Res> {
  __$RideHistoryEntryCopyWithImpl(this._self, this._then);

  final _RideHistoryEntry _self;
  final $Res Function(_RideHistoryEntry) _then;

/// Create a copy of RideHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? groupId = null,Object? groupName = null,Object? name = freezed,Object? status = null,Object? startedAt = null,Object? endedAt = freezed,}) {
  return _then(_RideHistoryEntry(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideSessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
