// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

 String get userName; List<RoomOverview> get rooms; List<Scene> get scenes;/// Null shows every room.
 String? get selectedRoomId;/// False until the first devices have arrived.
 bool get loaded;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.userName, _this.userName) || other.userName == _this.userName)&&const DeepCollectionEquality().equals(other.rooms, _this.rooms)&&const DeepCollectionEquality().equals(other.scenes, _this.scenes)&&(identical(other.selectedRoomId, _this.selectedRoomId) || other.selectedRoomId == _this.selectedRoomId)&&(identical(other.loaded, _this.loaded) || other.loaded == _this.loaded));
}


@override
int get hashCode {
  final _this = this as DashboardState;
  return Object.hash(runtimeType,_this.userName,const DeepCollectionEquality().hash(_this.rooms),const DeepCollectionEquality().hash(_this.scenes),_this.selectedRoomId,_this.loaded);
}

@override
String toString() {
  final _this = this as DashboardState;
  return 'DashboardState(userName: ${_this.userName}, rooms: ${_this.rooms}, scenes: ${_this.scenes}, selectedRoomId: ${_this.selectedRoomId}, loaded: ${_this.loaded})';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 String userName, List<RoomOverview> rooms, List<Scene> scenes, String? selectedRoomId, bool loaded
});




}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? rooms = null,Object? scenes = null,Object? selectedRoomId = freezed,Object? loaded = null,}) {
  return _then(DashboardState(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,rooms: null == rooms ? _self.rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<RoomOverview>,scenes: null == scenes ? _self.scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,selectedRoomId: freezed == selectedRoomId ? _self.selectedRoomId : selectedRoomId // ignore: cast_nullable_to_non_nullable
as String?,loaded: null == loaded ? _self.loaded : loaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  List<RoomOverview> rooms,  List<Scene> scenes,  String? selectedRoomId,  bool loaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.userName,_that.rooms,_that.scenes,_that.selectedRoomId,_that.loaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  List<RoomOverview> rooms,  List<Scene> scenes,  String? selectedRoomId,  bool loaded)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.userName,_that.rooms,_that.scenes,_that.selectedRoomId,_that.loaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  List<RoomOverview> rooms,  List<Scene> scenes,  String? selectedRoomId,  bool loaded)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.userName,_that.rooms,_that.scenes,_that.selectedRoomId,_that.loaded);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState extends DashboardState {
  const _DashboardState({required this.userName,  List<RoomOverview> rooms = const <RoomOverview>[],  List<Scene> scenes = const <Scene>[], this.selectedRoomId, this.loaded = false}): _rooms = rooms,_scenes = scenes,super._();
  

@override final  String userName;
 final  List<RoomOverview> _rooms;
@override@JsonKey() List<RoomOverview> get rooms {
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

/// Null shows every room.
@override final  String? selectedRoomId;
/// False until the first devices have arrived.
@override@JsonKey() final  bool loaded;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.userName, userName) || other.userName == userName)&&const DeepCollectionEquality().equals(other.rooms, _rooms)&&const DeepCollectionEquality().equals(other.scenes, _scenes)&&(identical(other.selectedRoomId, selectedRoomId) || other.selectedRoomId == selectedRoomId)&&(identical(other.loaded, loaded) || other.loaded == loaded));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userName,const DeepCollectionEquality().hash(_rooms),const DeepCollectionEquality().hash(_scenes),selectedRoomId,loaded);
}

@override
String toString() {
    return 'DashboardState(userName: $userName, rooms: $rooms, scenes: $scenes, selectedRoomId: $selectedRoomId, loaded: $loaded)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 String userName, List<RoomOverview> rooms, List<Scene> scenes, String? selectedRoomId, bool loaded
});




}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? rooms = null,Object? scenes = null,Object? selectedRoomId = freezed,Object? loaded = null,}) {
  return _then(_DashboardState(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<RoomOverview>,scenes: null == scenes ? _self._scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,selectedRoomId: freezed == selectedRoomId ? _self.selectedRoomId : selectedRoomId // ignore: cast_nullable_to_non_nullable
as String?,loaded: null == loaded ? _self.loaded : loaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
