// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideGroup {

 String get id; String get ownerId; String get name; String? get description; String get inviteCode; RideGroupStatus get status; DateTime get createdAt; DateTime get updatedAt; String? get pinnedNote;
/// Create a copy of RideGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideGroupCopyWith<RideGroup> get copyWith => _$RideGroupCopyWithImpl<RideGroup>(this as RideGroup, _$identity);

  /// Serializes this RideGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pinnedNote, pinnedNote) || other.pinnedNote == pinnedNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,description,inviteCode,status,createdAt,updatedAt,pinnedNote);

@override
String toString() {
  return 'RideGroup(id: $id, ownerId: $ownerId, name: $name, description: $description, inviteCode: $inviteCode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, pinnedNote: $pinnedNote)';
}


}

/// @nodoc
abstract mixin class $RideGroupCopyWith<$Res>  {
  factory $RideGroupCopyWith(RideGroup value, $Res Function(RideGroup) _then) = _$RideGroupCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String name, String? description, String inviteCode, RideGroupStatus status, DateTime createdAt, DateTime updatedAt, String? pinnedNote
});




}
/// @nodoc
class _$RideGroupCopyWithImpl<$Res>
    implements $RideGroupCopyWith<$Res> {
  _$RideGroupCopyWithImpl(this._self, this._then);

  final RideGroup _self;
  final $Res Function(RideGroup) _then;

/// Create a copy of RideGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? description = freezed,Object? inviteCode = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? pinnedNote = freezed,}) {
  return _then(RideGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideGroupStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pinnedNote: freezed == pinnedNote ? _self.pinnedNote : pinnedNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideGroup].
extension RideGroupPatterns on RideGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideGroup value)  $default,){
final _that = this;
switch (_that) {
case _RideGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideGroup value)?  $default,){
final _that = this;
switch (_that) {
case _RideGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  String? description,  String inviteCode,  RideGroupStatus status,  DateTime createdAt,  DateTime updatedAt,  String? pinnedNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideGroup() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.description,_that.inviteCode,_that.status,_that.createdAt,_that.updatedAt,_that.pinnedNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  String? description,  String inviteCode,  RideGroupStatus status,  DateTime createdAt,  DateTime updatedAt,  String? pinnedNote)  $default,) {final _that = this;
switch (_that) {
case _RideGroup():
return $default(_that.id,_that.ownerId,_that.name,_that.description,_that.inviteCode,_that.status,_that.createdAt,_that.updatedAt,_that.pinnedNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String name,  String? description,  String inviteCode,  RideGroupStatus status,  DateTime createdAt,  DateTime updatedAt,  String? pinnedNote)?  $default,) {final _that = this;
switch (_that) {
case _RideGroup() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.description,_that.inviteCode,_that.status,_that.createdAt,_that.updatedAt,_that.pinnedNote);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RideGroup implements RideGroup {
  const _RideGroup({required this.id, required this.ownerId, required this.name, this.description, required this.inviteCode, required this.status, required this.createdAt, required this.updatedAt, this.pinnedNote});
  factory _RideGroup.fromJson(Map<String, dynamic> json) => _$RideGroupFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String name;
@override final  String? description;
@override final  String inviteCode;
@override final  RideGroupStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? pinnedNote;

/// Create a copy of RideGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideGroupCopyWith<_RideGroup> get copyWith => __$RideGroupCopyWithImpl<_RideGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pinnedNote, pinnedNote) || other.pinnedNote == pinnedNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,description,inviteCode,status,createdAt,updatedAt,pinnedNote);

@override
String toString() {
  return 'RideGroup(id: $id, ownerId: $ownerId, name: $name, description: $description, inviteCode: $inviteCode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, pinnedNote: $pinnedNote)';
}


}

/// @nodoc
abstract mixin class _$RideGroupCopyWith<$Res> implements $RideGroupCopyWith<$Res> {
  factory _$RideGroupCopyWith(_RideGroup value, $Res Function(_RideGroup) _then) = __$RideGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String name, String? description, String inviteCode, RideGroupStatus status, DateTime createdAt, DateTime updatedAt, String? pinnedNote
});




}
/// @nodoc
class __$RideGroupCopyWithImpl<$Res>
    implements _$RideGroupCopyWith<$Res> {
  __$RideGroupCopyWithImpl(this._self, this._then);

  final _RideGroup _self;
  final $Res Function(_RideGroup) _then;

/// Create a copy of RideGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? description = freezed,Object? inviteCode = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? pinnedNote = freezed,}) {
  return _then(_RideGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideGroupStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pinnedNote: freezed == pinnedNote ? _self.pinnedNote : pinnedNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
