// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceState {

/// Null while the device is unknown (still loading, or removed).
 DeviceView? get view; Room? get room;/// True once the repository has answered, so "unknown" means "gone".
 bool get resolved;
/// Create a copy of DeviceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceStateCopyWith<DeviceState> get copyWith => _$DeviceStateCopyWithImpl<DeviceState>(this as DeviceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceState&&(identical(other.view, _this.view) || other.view == _this.view)&&(identical(other.room, _this.room) || other.room == _this.room)&&(identical(other.resolved, _this.resolved) || other.resolved == _this.resolved));
}


@override
int get hashCode {
  final _this = this as DeviceState;
  return Object.hash(runtimeType,_this.view,_this.room,_this.resolved);
}

@override
String toString() {
  final _this = this as DeviceState;
  return 'DeviceState(view: ${_this.view}, room: ${_this.room}, resolved: ${_this.resolved})';
}


}

/// @nodoc
abstract mixin class $DeviceStateCopyWith<$Res>  {
  factory $DeviceStateCopyWith(DeviceState value, $Res Function(DeviceState) _then) = _$DeviceStateCopyWithImpl;
@useResult
$Res call({
 DeviceView? view, Room? room, bool resolved
});


$RoomCopyWith<$Res>? get room;

}
/// @nodoc
class _$DeviceStateCopyWithImpl<$Res>
    implements $DeviceStateCopyWith<$Res> {
  _$DeviceStateCopyWithImpl(this._self, this._then);

  final DeviceState _self;
  final $Res Function(DeviceState) _then;

/// Create a copy of DeviceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? view = freezed,Object? room = freezed,Object? resolved = null,}) {
  return _then(DeviceState(
view: freezed == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as DeviceView?,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room?,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DeviceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomCopyWith<$Res>? get room {
    if (_self.room == null) {
    return null;
  }

  return $RoomCopyWith<$Res>(_self.room!, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeviceState].
extension DeviceStatePatterns on DeviceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceState value)  $default,){
final _that = this;
switch (_that) {
case _DeviceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceState value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceView? view,  Room? room,  bool resolved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceState() when $default != null:
return $default(_that.view,_that.room,_that.resolved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceView? view,  Room? room,  bool resolved)  $default,) {final _that = this;
switch (_that) {
case _DeviceState():
return $default(_that.view,_that.room,_that.resolved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceView? view,  Room? room,  bool resolved)?  $default,) {final _that = this;
switch (_that) {
case _DeviceState() when $default != null:
return $default(_that.view,_that.room,_that.resolved);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceState implements DeviceState {
  const _DeviceState({this.view, this.room, this.resolved = false});
  

/// Null while the device is unknown (still loading, or removed).
@override final  DeviceView? view;
@override final  Room? room;
/// True once the repository has answered, so "unknown" means "gone".
@override@JsonKey() final  bool resolved;

/// Create a copy of DeviceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceStateCopyWith<_DeviceState> get copyWith => __$DeviceStateCopyWithImpl<_DeviceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceState&&(identical(other.view, view) || other.view == view)&&(identical(other.room, room) || other.room == room)&&(identical(other.resolved, resolved) || other.resolved == resolved));
}


@override
int get hashCode {
    return Object.hash(runtimeType,view,room,resolved);
}

@override
String toString() {
    return 'DeviceState(view: $view, room: $room, resolved: $resolved)';
}


}

/// @nodoc
abstract mixin class _$DeviceStateCopyWith<$Res> implements $DeviceStateCopyWith<$Res> {
  factory _$DeviceStateCopyWith(_DeviceState value, $Res Function(_DeviceState) _then) = __$DeviceStateCopyWithImpl;
@override @useResult
$Res call({
 DeviceView? view, Room? room, bool resolved
});


@override $RoomCopyWith<$Res>? get room;

}
/// @nodoc
class __$DeviceStateCopyWithImpl<$Res>
    implements _$DeviceStateCopyWith<$Res> {
  __$DeviceStateCopyWithImpl(this._self, this._then);

  final _DeviceState _self;
  final $Res Function(_DeviceState) _then;

/// Create a copy of DeviceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? view = freezed,Object? room = freezed,Object? resolved = null,}) {
  return _then(_DeviceState(
view: freezed == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as DeviceView?,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room?,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DeviceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomCopyWith<$Res>? get room {
    if (_self.room == null) {
    return null;
  }

  return $RoomCopyWith<$Res>(_self.room!, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}

// dart format on
