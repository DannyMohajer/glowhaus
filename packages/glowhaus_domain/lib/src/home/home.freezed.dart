// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Room {

 String get id; String get name;@JsonKey(unknownEnumValue: RoomKind.other) RoomKind get kind;/// Translation key of a seeded default [name]; null once renamed.
/// The name itself is always shown as typed when there is no key.
 String? get nameKey;
/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCopyWith<Room> get copyWith => _$RoomCopyWithImpl<Room>(this as Room, _$identity);

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Room;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Room&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Room;
  return Object.hash(runtimeType,_this.id,_this.name,_this.kind,_this.nameKey);
}

@override
String toString() {
  final _this = this as Room;
  return 'Room(id: ${_this.id}, name: ${_this.name}, kind: ${_this.kind}, nameKey: ${_this.nameKey})';
}


}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res>  {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) = _$RoomCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: RoomKind.other) RoomKind kind, String? nameKey
});




}
/// @nodoc
class _$RoomCopyWithImpl<$Res>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? nameKey = freezed,}) {
  return _then(Room(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RoomKind,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Room].
extension RoomPatterns on Room {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Room value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Room value)  $default,){
final _that = this;
switch (_that) {
case _Room():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Room value)?  $default,){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: RoomKind.other)  RoomKind kind,  String? nameKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.nameKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: RoomKind.other)  RoomKind kind,  String? nameKey)  $default,) {final _that = this;
switch (_that) {
case _Room():
return $default(_that.id,_that.name,_that.kind,_that.nameKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(unknownEnumValue: RoomKind.other)  RoomKind kind,  String? nameKey)?  $default,) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.nameKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Room extends Room {
  const _Room({required this.id, required this.name, @JsonKey(unknownEnumValue: RoomKind.other) this.kind = RoomKind.other, this.nameKey}): super._();
  factory _Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(unknownEnumValue: RoomKind.other) final  RoomKind kind;
/// Translation key of a seeded default [name]; null once renamed.
/// The name itself is always shown as typed when there is no key.
@override final  String? nameKey;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCopyWith<_Room> get copyWith => __$RoomCopyWithImpl<_Room>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Room&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,kind,nameKey);
}

@override
String toString() {
    return 'Room(id: $id, name: $name, kind: $kind, nameKey: $nameKey)';
}


}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) = __$RoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: RoomKind.other) RoomKind kind, String? nameKey
});




}
/// @nodoc
class __$RoomCopyWithImpl<$Res>
    implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? nameKey = freezed,}) {
  return _then(_Room(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RoomKind,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$User {

 String get id; String get name;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.name});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'User(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$HomeMember {

 User get user; Role get role;
/// Create a copy of HomeMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeMemberCopyWith<HomeMember> get copyWith => _$HomeMemberCopyWithImpl<HomeMember>(this as HomeMember, _$identity);

  /// Serializes this HomeMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeMember&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeMember;
  return Object.hash(runtimeType,_this.user,_this.role);
}

@override
String toString() {
  final _this = this as HomeMember;
  return 'HomeMember(user: ${_this.user}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $HomeMemberCopyWith<$Res>  {
  factory $HomeMemberCopyWith(HomeMember value, $Res Function(HomeMember) _then) = _$HomeMemberCopyWithImpl;
@useResult
$Res call({
 User user, Role role
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$HomeMemberCopyWithImpl<$Res>
    implements $HomeMemberCopyWith<$Res> {
  _$HomeMemberCopyWithImpl(this._self, this._then);

  final HomeMember _self;
  final $Res Function(HomeMember) _then;

/// Create a copy of HomeMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? role = null,}) {
  return _then(HomeMember(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,
  ));
}
/// Create a copy of HomeMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeMember].
extension HomeMemberPatterns on HomeMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeMember value)  $default,){
final _that = this;
switch (_that) {
case _HomeMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeMember value)?  $default,){
final _that = this;
switch (_that) {
case _HomeMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  Role role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeMember() when $default != null:
return $default(_that.user,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  Role role)  $default,) {final _that = this;
switch (_that) {
case _HomeMember():
return $default(_that.user,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  Role role)?  $default,) {final _that = this;
switch (_that) {
case _HomeMember() when $default != null:
return $default(_that.user,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeMember implements HomeMember {
  const _HomeMember({required this.user, required this.role});
  factory _HomeMember.fromJson(Map<String, dynamic> json) => _$HomeMemberFromJson(json);

@override final  User user;
@override final  Role role;

/// Create a copy of HomeMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeMemberCopyWith<_HomeMember> get copyWith => __$HomeMemberCopyWithImpl<_HomeMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeMember&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,user,role);
}

@override
String toString() {
    return 'HomeMember(user: $user, role: $role)';
}


}

/// @nodoc
abstract mixin class _$HomeMemberCopyWith<$Res> implements $HomeMemberCopyWith<$Res> {
  factory _$HomeMemberCopyWith(_HomeMember value, $Res Function(_HomeMember) _then) = __$HomeMemberCopyWithImpl;
@override @useResult
$Res call({
 User user, Role role
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$HomeMemberCopyWithImpl<$Res>
    implements _$HomeMemberCopyWith<$Res> {
  __$HomeMemberCopyWithImpl(this._self, this._then);

  final _HomeMember _self;
  final $Res Function(_HomeMember) _then;

/// Create a copy of HomeMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? role = null,}) {
  return _then(_HomeMember(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,
  ));
}

/// Create a copy of HomeMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$SceneAction {

 String get deviceId; Map<String, CapabilityPatch> get patches;
/// Create a copy of SceneAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneActionCopyWith<SceneAction> get copyWith => _$SceneActionCopyWithImpl<SceneAction>(this as SceneAction, _$identity);

  /// Serializes this SceneAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SceneAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneAction&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&const DeepCollectionEquality().equals(other.patches, _this.patches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SceneAction;
  return Object.hash(runtimeType,_this.deviceId,const DeepCollectionEquality().hash(_this.patches));
}

@override
String toString() {
  final _this = this as SceneAction;
  return 'SceneAction(deviceId: ${_this.deviceId}, patches: ${_this.patches})';
}


}

/// @nodoc
abstract mixin class $SceneActionCopyWith<$Res>  {
  factory $SceneActionCopyWith(SceneAction value, $Res Function(SceneAction) _then) = _$SceneActionCopyWithImpl;
@useResult
$Res call({
 String deviceId, Map<String, CapabilityPatch> patches
});




}
/// @nodoc
class _$SceneActionCopyWithImpl<$Res>
    implements $SceneActionCopyWith<$Res> {
  _$SceneActionCopyWithImpl(this._self, this._then);

  final SceneAction _self;
  final $Res Function(SceneAction) _then;

/// Create a copy of SceneAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceId = null,Object? patches = null,}) {
  return _then(SceneAction(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,patches: null == patches ? _self.patches : patches // ignore: cast_nullable_to_non_nullable
as Map<String, CapabilityPatch>,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneAction].
extension SceneActionPatterns on SceneAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneAction value)  $default,){
final _that = this;
switch (_that) {
case _SceneAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneAction value)?  $default,){
final _that = this;
switch (_that) {
case _SceneAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deviceId,  Map<String, CapabilityPatch> patches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneAction() when $default != null:
return $default(_that.deviceId,_that.patches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deviceId,  Map<String, CapabilityPatch> patches)  $default,) {final _that = this;
switch (_that) {
case _SceneAction():
return $default(_that.deviceId,_that.patches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deviceId,  Map<String, CapabilityPatch> patches)?  $default,) {final _that = this;
switch (_that) {
case _SceneAction() when $default != null:
return $default(_that.deviceId,_that.patches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneAction implements SceneAction {
  const _SceneAction({required this.deviceId, required  Map<String, CapabilityPatch> patches}): _patches = patches;
  factory _SceneAction.fromJson(Map<String, dynamic> json) => _$SceneActionFromJson(json);

@override final  String deviceId;
 final  Map<String, CapabilityPatch> _patches;
@override Map<String, CapabilityPatch> get patches {
  if (_patches is EqualUnmodifiableMapView) return _patches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_patches);
}


/// Create a copy of SceneAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneActionCopyWith<_SceneAction> get copyWith => __$SceneActionCopyWithImpl<_SceneAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneAction&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&const DeepCollectionEquality().equals(other.patches, _patches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,deviceId,const DeepCollectionEquality().hash(_patches));
}

@override
String toString() {
    return 'SceneAction(deviceId: $deviceId, patches: $patches)';
}


}

/// @nodoc
abstract mixin class _$SceneActionCopyWith<$Res> implements $SceneActionCopyWith<$Res> {
  factory _$SceneActionCopyWith(_SceneAction value, $Res Function(_SceneAction) _then) = __$SceneActionCopyWithImpl;
@override @useResult
$Res call({
 String deviceId, Map<String, CapabilityPatch> patches
});




}
/// @nodoc
class __$SceneActionCopyWithImpl<$Res>
    implements _$SceneActionCopyWith<$Res> {
  __$SceneActionCopyWithImpl(this._self, this._then);

  final _SceneAction _self;
  final $Res Function(_SceneAction) _then;

/// Create a copy of SceneAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? patches = null,}) {
  return _then(_SceneAction(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,patches: null == patches ? _self._patches : patches // ignore: cast_nullable_to_non_nullable
as Map<String, CapabilityPatch>,
  ));
}


}


/// @nodoc
mixin _$Scene {

 String get id; String get name; List<SceneAction> get actions;/// Translation key of a seeded default [name]; null once renamed.
/// The name itself is always shown as typed when there is no key.
 String? get nameKey;
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneCopyWith<Scene> get copyWith => _$SceneCopyWithImpl<Scene>(this as Scene, _$identity);

  /// Serializes this Scene to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Scene;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scene&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.actions, _this.actions)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Scene;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.actions),_this.nameKey);
}

@override
String toString() {
  final _this = this as Scene;
  return 'Scene(id: ${_this.id}, name: ${_this.name}, actions: ${_this.actions}, nameKey: ${_this.nameKey})';
}


}

/// @nodoc
abstract mixin class $SceneCopyWith<$Res>  {
  factory $SceneCopyWith(Scene value, $Res Function(Scene) _then) = _$SceneCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<SceneAction> actions, String? nameKey
});




}
/// @nodoc
class _$SceneCopyWithImpl<$Res>
    implements $SceneCopyWith<$Res> {
  _$SceneCopyWithImpl(this._self, this._then);

  final Scene _self;
  final $Res Function(Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? actions = null,Object? nameKey = freezed,}) {
  return _then(Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<SceneAction>,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Scene].
extension ScenePatterns on Scene {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scene value)  $default,){
final _that = this;
switch (_that) {
case _Scene():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scene value)?  $default,){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<SceneAction> actions,  String? nameKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.name,_that.actions,_that.nameKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<SceneAction> actions,  String? nameKey)  $default,) {final _that = this;
switch (_that) {
case _Scene():
return $default(_that.id,_that.name,_that.actions,_that.nameKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<SceneAction> actions,  String? nameKey)?  $default,) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.name,_that.actions,_that.nameKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scene extends Scene {
  const _Scene({required this.id, required this.name,  List<SceneAction> actions = const <SceneAction>[], this.nameKey}): _actions = actions,super._();
  factory _Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

@override final  String id;
@override final  String name;
 final  List<SceneAction> _actions;
@override@JsonKey() List<SceneAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

/// Translation key of a seeded default [name]; null once renamed.
/// The name itself is always shown as typed when there is no key.
@override final  String? nameKey;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneCopyWith<_Scene> get copyWith => __$SceneCopyWithImpl<_Scene>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.actions, _actions)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_actions),nameKey);
}

@override
String toString() {
    return 'Scene(id: $id, name: $name, actions: $actions, nameKey: $nameKey)';
}


}

/// @nodoc
abstract mixin class _$SceneCopyWith<$Res> implements $SceneCopyWith<$Res> {
  factory _$SceneCopyWith(_Scene value, $Res Function(_Scene) _then) = __$SceneCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<SceneAction> actions, String? nameKey
});




}
/// @nodoc
class __$SceneCopyWithImpl<$Res>
    implements _$SceneCopyWith<$Res> {
  __$SceneCopyWithImpl(this._self, this._then);

  final _Scene _self;
  final $Res Function(_Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? actions = null,Object? nameKey = freezed,}) {
  return _then(_Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<SceneAction>,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Home {

 String get id; String get name; List<Room> get rooms; List<Scene> get scenes; List<HomeMember> get members;
/// Create a copy of Home
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCopyWith<Home> get copyWith => _$HomeCopyWithImpl<Home>(this as Home, _$identity);

  /// Serializes this Home to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Home;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Home&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.rooms, _this.rooms)&&const DeepCollectionEquality().equals(other.scenes, _this.scenes)&&const DeepCollectionEquality().equals(other.members, _this.members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Home;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.rooms),const DeepCollectionEquality().hash(_this.scenes),const DeepCollectionEquality().hash(_this.members));
}

@override
String toString() {
  final _this = this as Home;
  return 'Home(id: ${_this.id}, name: ${_this.name}, rooms: ${_this.rooms}, scenes: ${_this.scenes}, members: ${_this.members})';
}


}

/// @nodoc
abstract mixin class $HomeCopyWith<$Res>  {
  factory $HomeCopyWith(Home value, $Res Function(Home) _then) = _$HomeCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<Room> rooms, List<Scene> scenes, List<HomeMember> members
});




}
/// @nodoc
class _$HomeCopyWithImpl<$Res>
    implements $HomeCopyWith<$Res> {
  _$HomeCopyWithImpl(this._self, this._then);

  final Home _self;
  final $Res Function(Home) _then;

/// Create a copy of Home
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? rooms = null,Object? scenes = null,Object? members = null,}) {
  return _then(Home(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rooms: null == rooms ? _self.rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<Room>,scenes: null == scenes ? _self.scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<HomeMember>,
  ));
}

}


/// Adds pattern-matching-related methods to [Home].
extension HomePatterns on Home {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Home value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Home() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Home value)  $default,){
final _that = this;
switch (_that) {
case _Home():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Home value)?  $default,){
final _that = this;
switch (_that) {
case _Home() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<Room> rooms,  List<Scene> scenes,  List<HomeMember> members)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Home() when $default != null:
return $default(_that.id,_that.name,_that.rooms,_that.scenes,_that.members);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<Room> rooms,  List<Scene> scenes,  List<HomeMember> members)  $default,) {final _that = this;
switch (_that) {
case _Home():
return $default(_that.id,_that.name,_that.rooms,_that.scenes,_that.members);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<Room> rooms,  List<Scene> scenes,  List<HomeMember> members)?  $default,) {final _that = this;
switch (_that) {
case _Home() when $default != null:
return $default(_that.id,_that.name,_that.rooms,_that.scenes,_that.members);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Home extends Home {
  const _Home({required this.id, required this.name,  List<Room> rooms = const <Room>[],  List<Scene> scenes = const <Scene>[],  List<HomeMember> members = const <HomeMember>[]}): _rooms = rooms,_scenes = scenes,_members = members,super._();
  factory _Home.fromJson(Map<String, dynamic> json) => _$HomeFromJson(json);

@override final  String id;
@override final  String name;
 final  List<Room> _rooms;
@override@JsonKey() List<Room> get rooms {
  if (_rooms is EqualUnmodifiableListView) return _rooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rooms);
}

 final  List<Scene> _scenes;
@override@JsonKey() List<Scene> get scenes {
  if (_scenes is EqualUnmodifiableListView) return _scenes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scenes);
}

 final  List<HomeMember> _members;
@override@JsonKey() List<HomeMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of Home
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeCopyWith<_Home> get copyWith => __$HomeCopyWithImpl<_Home>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Home&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.rooms, _rooms)&&const DeepCollectionEquality().equals(other.scenes, _scenes)&&const DeepCollectionEquality().equals(other.members, _members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_rooms),const DeepCollectionEquality().hash(_scenes),const DeepCollectionEquality().hash(_members));
}

@override
String toString() {
    return 'Home(id: $id, name: $name, rooms: $rooms, scenes: $scenes, members: $members)';
}


}

/// @nodoc
abstract mixin class _$HomeCopyWith<$Res> implements $HomeCopyWith<$Res> {
  factory _$HomeCopyWith(_Home value, $Res Function(_Home) _then) = __$HomeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<Room> rooms, List<Scene> scenes, List<HomeMember> members
});




}
/// @nodoc
class __$HomeCopyWithImpl<$Res>
    implements _$HomeCopyWith<$Res> {
  __$HomeCopyWithImpl(this._self, this._then);

  final _Home _self;
  final $Res Function(_Home) _then;

/// Create a copy of Home
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? rooms = null,Object? scenes = null,Object? members = null,}) {
  return _then(_Home(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<Room>,scenes: null == scenes ? _self._scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<HomeMember>,
  ));
}


}

// dart format on
