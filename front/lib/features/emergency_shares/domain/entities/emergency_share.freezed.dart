// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_share.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmergencyShare {

 String get id; String get userId; String get shareToken; EmergencyShareStatus get status; DateTime get startedAt; DateTime? get endedAt;
/// Create a copy of EmergencyShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyShareCopyWith<EmergencyShare> get copyWith => _$EmergencyShareCopyWithImpl<EmergencyShare>(this as EmergencyShare, _$identity);

  /// Serializes this EmergencyShare to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyShare&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,shareToken,status,startedAt,endedAt);

@override
String toString() {
  return 'EmergencyShare(id: $id, userId: $userId, shareToken: $shareToken, status: $status, startedAt: $startedAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class $EmergencyShareCopyWith<$Res>  {
  factory $EmergencyShareCopyWith(EmergencyShare value, $Res Function(EmergencyShare) _then) = _$EmergencyShareCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String shareToken, EmergencyShareStatus status, DateTime startedAt, DateTime? endedAt
});




}
/// @nodoc
class _$EmergencyShareCopyWithImpl<$Res>
    implements $EmergencyShareCopyWith<$Res> {
  _$EmergencyShareCopyWithImpl(this._self, this._then);

  final EmergencyShare _self;
  final $Res Function(EmergencyShare) _then;

/// Create a copy of EmergencyShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? shareToken = null,Object? status = null,Object? startedAt = null,Object? endedAt = freezed,}) {
  return _then(EmergencyShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shareToken: null == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmergencyShareStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyShare].
extension EmergencySharePatterns on EmergencyShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyShare value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyShare value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String shareToken,  EmergencyShareStatus status,  DateTime startedAt,  DateTime? endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyShare() when $default != null:
return $default(_that.id,_that.userId,_that.shareToken,_that.status,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String shareToken,  EmergencyShareStatus status,  DateTime startedAt,  DateTime? endedAt)  $default,) {final _that = this;
switch (_that) {
case _EmergencyShare():
return $default(_that.id,_that.userId,_that.shareToken,_that.status,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String shareToken,  EmergencyShareStatus status,  DateTime startedAt,  DateTime? endedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyShare() when $default != null:
return $default(_that.id,_that.userId,_that.shareToken,_that.status,_that.startedAt,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _EmergencyShare implements EmergencyShare {
  const _EmergencyShare({required this.id, required this.userId, required this.shareToken, required this.status, required this.startedAt, this.endedAt});
  factory _EmergencyShare.fromJson(Map<String, dynamic> json) => _$EmergencyShareFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String shareToken;
@override final  EmergencyShareStatus status;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;

/// Create a copy of EmergencyShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyShareCopyWith<_EmergencyShare> get copyWith => __$EmergencyShareCopyWithImpl<_EmergencyShare>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyShareToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyShare&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,shareToken,status,startedAt,endedAt);

@override
String toString() {
  return 'EmergencyShare(id: $id, userId: $userId, shareToken: $shareToken, status: $status, startedAt: $startedAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$EmergencyShareCopyWith<$Res> implements $EmergencyShareCopyWith<$Res> {
  factory _$EmergencyShareCopyWith(_EmergencyShare value, $Res Function(_EmergencyShare) _then) = __$EmergencyShareCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String shareToken, EmergencyShareStatus status, DateTime startedAt, DateTime? endedAt
});




}
/// @nodoc
class __$EmergencyShareCopyWithImpl<$Res>
    implements _$EmergencyShareCopyWith<$Res> {
  __$EmergencyShareCopyWithImpl(this._self, this._then);

  final _EmergencyShare _self;
  final $Res Function(_EmergencyShare) _then;

/// Create a copy of EmergencyShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? shareToken = null,Object? status = null,Object? startedAt = null,Object? endedAt = freezed,}) {
  return _then(_EmergencyShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shareToken: null == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmergencyShareStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$SharedWithMeEntry {

 String get shareId; String get riderUserId; String get riderDisplayName; DateTime get startedAt;/// Reuses the same public `/share/<token>` screen for this in-app path
/// instead of a second implementation — see `EmergencySharePage`.
/// Seeing this list already proves the caller is a linked emergency
/// contact, so handing them the token isn't a wider hole than that.
 String get shareToken;
/// Create a copy of SharedWithMeEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedWithMeEntryCopyWith<SharedWithMeEntry> get copyWith => _$SharedWithMeEntryCopyWithImpl<SharedWithMeEntry>(this as SharedWithMeEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedWithMeEntry&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.riderUserId, riderUserId) || other.riderUserId == riderUserId)&&(identical(other.riderDisplayName, riderDisplayName) || other.riderDisplayName == riderDisplayName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken));
}


@override
int get hashCode => Object.hash(runtimeType,shareId,riderUserId,riderDisplayName,startedAt,shareToken);

@override
String toString() {
  return 'SharedWithMeEntry(shareId: $shareId, riderUserId: $riderUserId, riderDisplayName: $riderDisplayName, startedAt: $startedAt, shareToken: $shareToken)';
}


}

/// @nodoc
abstract mixin class $SharedWithMeEntryCopyWith<$Res>  {
  factory $SharedWithMeEntryCopyWith(SharedWithMeEntry value, $Res Function(SharedWithMeEntry) _then) = _$SharedWithMeEntryCopyWithImpl;
@useResult
$Res call({
 String shareId, String riderUserId, String riderDisplayName, DateTime startedAt, String shareToken
});




}
/// @nodoc
class _$SharedWithMeEntryCopyWithImpl<$Res>
    implements $SharedWithMeEntryCopyWith<$Res> {
  _$SharedWithMeEntryCopyWithImpl(this._self, this._then);

  final SharedWithMeEntry _self;
  final $Res Function(SharedWithMeEntry) _then;

/// Create a copy of SharedWithMeEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shareId = null,Object? riderUserId = null,Object? riderDisplayName = null,Object? startedAt = null,Object? shareToken = null,}) {
  return _then(SharedWithMeEntry(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String,riderUserId: null == riderUserId ? _self.riderUserId : riderUserId // ignore: cast_nullable_to_non_nullable
as String,riderDisplayName: null == riderDisplayName ? _self.riderDisplayName : riderDisplayName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,shareToken: null == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedWithMeEntry].
extension SharedWithMeEntryPatterns on SharedWithMeEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedWithMeEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedWithMeEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedWithMeEntry value)  $default,){
final _that = this;
switch (_that) {
case _SharedWithMeEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedWithMeEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SharedWithMeEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String shareId,  String riderUserId,  String riderDisplayName,  DateTime startedAt,  String shareToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedWithMeEntry() when $default != null:
return $default(_that.shareId,_that.riderUserId,_that.riderDisplayName,_that.startedAt,_that.shareToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String shareId,  String riderUserId,  String riderDisplayName,  DateTime startedAt,  String shareToken)  $default,) {final _that = this;
switch (_that) {
case _SharedWithMeEntry():
return $default(_that.shareId,_that.riderUserId,_that.riderDisplayName,_that.startedAt,_that.shareToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String shareId,  String riderUserId,  String riderDisplayName,  DateTime startedAt,  String shareToken)?  $default,) {final _that = this;
switch (_that) {
case _SharedWithMeEntry() when $default != null:
return $default(_that.shareId,_that.riderUserId,_that.riderDisplayName,_that.startedAt,_that.shareToken);case _:
  return null;

}
}

}

/// @nodoc


class _SharedWithMeEntry implements SharedWithMeEntry {
  const _SharedWithMeEntry({required this.shareId, required this.riderUserId, required this.riderDisplayName, required this.startedAt, required this.shareToken});
  

@override final  String shareId;
@override final  String riderUserId;
@override final  String riderDisplayName;
@override final  DateTime startedAt;
/// Reuses the same public `/share/<token>` screen for this in-app path
/// instead of a second implementation — see `EmergencySharePage`.
/// Seeing this list already proves the caller is a linked emergency
/// contact, so handing them the token isn't a wider hole than that.
@override final  String shareToken;

/// Create a copy of SharedWithMeEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedWithMeEntryCopyWith<_SharedWithMeEntry> get copyWith => __$SharedWithMeEntryCopyWithImpl<_SharedWithMeEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedWithMeEntry&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.riderUserId, riderUserId) || other.riderUserId == riderUserId)&&(identical(other.riderDisplayName, riderDisplayName) || other.riderDisplayName == riderDisplayName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken));
}


@override
int get hashCode => Object.hash(runtimeType,shareId,riderUserId,riderDisplayName,startedAt,shareToken);

@override
String toString() {
  return 'SharedWithMeEntry(shareId: $shareId, riderUserId: $riderUserId, riderDisplayName: $riderDisplayName, startedAt: $startedAt, shareToken: $shareToken)';
}


}

/// @nodoc
abstract mixin class _$SharedWithMeEntryCopyWith<$Res> implements $SharedWithMeEntryCopyWith<$Res> {
  factory _$SharedWithMeEntryCopyWith(_SharedWithMeEntry value, $Res Function(_SharedWithMeEntry) _then) = __$SharedWithMeEntryCopyWithImpl;
@override @useResult
$Res call({
 String shareId, String riderUserId, String riderDisplayName, DateTime startedAt, String shareToken
});




}
/// @nodoc
class __$SharedWithMeEntryCopyWithImpl<$Res>
    implements _$SharedWithMeEntryCopyWith<$Res> {
  __$SharedWithMeEntryCopyWithImpl(this._self, this._then);

  final _SharedWithMeEntry _self;
  final $Res Function(_SharedWithMeEntry) _then;

/// Create a copy of SharedWithMeEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shareId = null,Object? riderUserId = null,Object? riderDisplayName = null,Object? startedAt = null,Object? shareToken = null,}) {
  return _then(_SharedWithMeEntry(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String,riderUserId: null == riderUserId ? _self.riderUserId : riderUserId // ignore: cast_nullable_to_non_nullable
as String,riderDisplayName: null == riderDisplayName ? _self.riderDisplayName : riderDisplayName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,shareToken: null == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
