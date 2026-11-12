// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rooms_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoomState {

/// Null if the room does not exist.
 Room? get room; List<DeviceView> get devices;/// Null shows every type.
 DeviceType? get filter;
/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomStateCopyWith<RoomState> get copyWith => _$RoomStateCopyWithImpl<RoomState>(this as RoomState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoomState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomState&&(identical(other.room, _this.room) || other.room == _this.room)&&const DeepCollectionEquality().equals(other.devices, _this.devices)&&(identical(other.filter, _this.filter) || other.filter == _this.filter));
}


@override
int get hashCode {
  final _this = this as RoomState;
  return Object.hash(runtimeType,_this.room,const DeepCollectionEquality().hash(_this.devices),_this.filter);
}

@override
String toString() {
  final _this = this as RoomState;
  return 'RoomState(room: ${_this.room}, devices: ${_this.devices}, filter: ${_this.filter})';
}


}

/// @nodoc
abstract mixin class $RoomStateCopyWith<$Res>  {
  factory $RoomStateCopyWith(RoomState value, $Res Function(RoomState) _then) = _$RoomStateCopyWithImpl;
@useResult
$Res call({
 Room? room, List<DeviceView> devices, DeviceType? filter
});


$RoomCopyWith<$Res>? get room;

}
/// @nodoc
class _$RoomStateCopyWithImpl<$Res>
    implements $RoomStateCopyWith<$Res> {
  _$RoomStateCopyWithImpl(this._self, this._then);

  final RoomState _self;
  final $Res Function(RoomState) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? room = freezed,Object? devices = null,Object? filter = freezed,}) {
  return _then(RoomState(
room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room?,devices: null == devices ? _self.devices : devices // ignore: cast_nullable_to_non_nullable
as List<DeviceView>,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as DeviceType?,
  ));
}
/// Create a copy of RoomState
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


/// Adds pattern-matching-related methods to [RoomState].
extension RoomStatePatterns on RoomState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomState value)  $default,){
final _that = this;
switch (_that) {
case _RoomState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomState value)?  $default,){
final _that = this;
switch (_that) {
case _RoomState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Room? room,  List<DeviceView> devices,  DeviceType? filter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomState() when $default != null:
return $default(_that.room,_that.devices,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Room? room,  List<DeviceView> devices,  DeviceType? filter)  $default,) {final _that = this;
switch (_that) {
case _RoomState():
return $default(_that.room,_that.devices,_that.filter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Room? room,  List<DeviceView> devices,  DeviceType? filter)?  $default,) {final _that = this;
switch (_that) {
case _RoomState() when $default != null:
return $default(_that.room,_that.devices,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class _RoomState extends RoomState {
  const _RoomState({this.room,  List<DeviceView> devices = const <DeviceView>[], this.filter}): _devices = devices,super._();
  

/// Null if the room does not exist.
@override final  Room? room;
 final  List<DeviceView> _devices;
@override@JsonKey() List<DeviceView> get devices {
  if (_devices is EqualUnmodifiableListView) return _devices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_devices);
}

/// Null shows every type.
@override final  DeviceType? filter;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomStateCopyWith<_RoomState> get copyWith => __$RoomStateCopyWithImpl<_RoomState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomState&&(identical(other.room, room) || other.room == room)&&const DeepCollectionEquality().equals(other.devices, _devices)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode {
    return Object.hash(runtimeType,room,const DeepCollectionEquality().hash(_devices),filter);
}

@override
String toString() {
    return 'RoomState(room: $room, devices: $devices, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$RoomStateCopyWith<$Res> implements $RoomStateCopyWith<$Res> {
  factory _$RoomStateCopyWith(_RoomState value, $Res Function(_RoomState) _then) = __$RoomStateCopyWithImpl;
@override @useResult
$Res call({
 Room? room, List<DeviceView> devices, DeviceType? filter
});


@override $RoomCopyWith<$Res>? get room;

}
/// @nodoc
class __$RoomStateCopyWithImpl<$Res>
    implements _$RoomStateCopyWith<$Res> {
  __$RoomStateCopyWithImpl(this._self, this._then);

  final _RoomState _self;
  final $Res Function(_RoomState) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? room = freezed,Object? devices = null,Object? filter = freezed,}) {
  return _then(_RoomState(
room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room?,devices: null == devices ? _self._devices : devices // ignore: cast_nullable_to_non_nullable
as List<DeviceView>,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as DeviceType?,
  ));
}

/// Create a copy of RoomState
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
