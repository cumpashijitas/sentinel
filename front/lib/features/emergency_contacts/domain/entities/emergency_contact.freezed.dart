// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmergencyContact {

 String get id; String get ownerId; String? get contactUserId; String get name; String get phone; String? get relationship; bool get notifyPush; bool get notifySms; bool get notifyWhatsapp; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyContactCopyWith<EmergencyContact> get copyWith => _$EmergencyContactCopyWithImpl<EmergencyContact>(this as EmergencyContact, _$identity);

  /// Serializes this EmergencyContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyContact&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.contactUserId, contactUserId) || other.contactUserId == contactUserId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.notifyPush, notifyPush) || other.notifyPush == notifyPush)&&(identical(other.notifySms, notifySms) || other.notifySms == notifySms)&&(identical(other.notifyWhatsapp, notifyWhatsapp) || other.notifyWhatsapp == notifyWhatsapp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,contactUserId,name,phone,relationship,notifyPush,notifySms,notifyWhatsapp,createdAt,updatedAt);

@override
String toString() {
  return 'EmergencyContact(id: $id, ownerId: $ownerId, contactUserId: $contactUserId, name: $name, phone: $phone, relationship: $relationship, notifyPush: $notifyPush, notifySms: $notifySms, notifyWhatsapp: $notifyWhatsapp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmergencyContactCopyWith<$Res>  {
  factory $EmergencyContactCopyWith(EmergencyContact value, $Res Function(EmergencyContact) _then) = _$EmergencyContactCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String? contactUserId, String name, String phone, String? relationship, bool notifyPush, bool notifySms, bool notifyWhatsapp, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$EmergencyContactCopyWithImpl<$Res>
    implements $EmergencyContactCopyWith<$Res> {
  _$EmergencyContactCopyWithImpl(this._self, this._then);

  final EmergencyContact _self;
  final $Res Function(EmergencyContact) _then;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? contactUserId = freezed,Object? name = null,Object? phone = null,Object? relationship = freezed,Object? notifyPush = null,Object? notifySms = null,Object? notifyWhatsapp = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(EmergencyContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,contactUserId: freezed == contactUserId ? _self.contactUserId : contactUserId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,notifyPush: null == notifyPush ? _self.notifyPush : notifyPush // ignore: cast_nullable_to_non_nullable
as bool,notifySms: null == notifySms ? _self.notifySms : notifySms // ignore: cast_nullable_to_non_nullable
as bool,notifyWhatsapp: null == notifyWhatsapp ? _self.notifyWhatsapp : notifyWhatsapp // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyContact].
extension EmergencyContactPatterns on EmergencyContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyContact value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyContact value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String? contactUserId,  String name,  String phone,  String? relationship,  bool notifyPush,  bool notifySms,  bool notifyWhatsapp,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that.id,_that.ownerId,_that.contactUserId,_that.name,_that.phone,_that.relationship,_that.notifyPush,_that.notifySms,_that.notifyWhatsapp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String? contactUserId,  String name,  String phone,  String? relationship,  bool notifyPush,  bool notifySms,  bool notifyWhatsapp,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmergencyContact():
return $default(_that.id,_that.ownerId,_that.contactUserId,_that.name,_that.phone,_that.relationship,_that.notifyPush,_that.notifySms,_that.notifyWhatsapp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String? contactUserId,  String name,  String phone,  String? relationship,  bool notifyPush,  bool notifySms,  bool notifyWhatsapp,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that.id,_that.ownerId,_that.contactUserId,_that.name,_that.phone,_that.relationship,_that.notifyPush,_that.notifySms,_that.notifyWhatsapp,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _EmergencyContact implements EmergencyContact {
  const _EmergencyContact({required this.id, required this.ownerId, this.contactUserId, required this.name, required this.phone, this.relationship, required this.notifyPush, required this.notifySms, required this.notifyWhatsapp, required this.createdAt, required this.updatedAt});
  factory _EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String? contactUserId;
@override final  String name;
@override final  String phone;
@override final  String? relationship;
@override final  bool notifyPush;
@override final  bool notifySms;
@override final  bool notifyWhatsapp;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyContactCopyWith<_EmergencyContact> get copyWith => __$EmergencyContactCopyWithImpl<_EmergencyContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyContact&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.contactUserId, contactUserId) || other.contactUserId == contactUserId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.notifyPush, notifyPush) || other.notifyPush == notifyPush)&&(identical(other.notifySms, notifySms) || other.notifySms == notifySms)&&(identical(other.notifyWhatsapp, notifyWhatsapp) || other.notifyWhatsapp == notifyWhatsapp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,contactUserId,name,phone,relationship,notifyPush,notifySms,notifyWhatsapp,createdAt,updatedAt);

@override
String toString() {
  return 'EmergencyContact(id: $id, ownerId: $ownerId, contactUserId: $contactUserId, name: $name, phone: $phone, relationship: $relationship, notifyPush: $notifyPush, notifySms: $notifySms, notifyWhatsapp: $notifyWhatsapp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmergencyContactCopyWith<$Res> implements $EmergencyContactCopyWith<$Res> {
  factory _$EmergencyContactCopyWith(_EmergencyContact value, $Res Function(_EmergencyContact) _then) = __$EmergencyContactCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String? contactUserId, String name, String phone, String? relationship, bool notifyPush, bool notifySms, bool notifyWhatsapp, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$EmergencyContactCopyWithImpl<$Res>
    implements _$EmergencyContactCopyWith<$Res> {
  __$EmergencyContactCopyWithImpl(this._self, this._then);

  final _EmergencyContact _self;
  final $Res Function(_EmergencyContact) _then;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? contactUserId = freezed,Object? name = null,Object? phone = null,Object? relationship = freezed,Object? notifyPush = null,Object? notifySms = null,Object? notifyWhatsapp = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_EmergencyContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,contactUserId: freezed == contactUserId ? _self.contactUserId : contactUserId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,notifyPush: null == notifyPush ? _self.notifyPush : notifyPush // ignore: cast_nullable_to_non_nullable
as bool,notifySms: null == notifySms ? _self.notifySms : notifySms // ignore: cast_nullable_to_non_nullable
as bool,notifyWhatsapp: null == notifyWhatsapp ? _self.notifyWhatsapp : notifyWhatsapp // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
