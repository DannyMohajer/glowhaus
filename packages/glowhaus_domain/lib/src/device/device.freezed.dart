// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Device {

 String get id; String get homeId; DeviceType get type; String get name; List<Capability> get capabilities; String? get roomId; String? get manufacturer; String? get model; String? get firmware; Map<String, CapabilityState> get state; DeviceAvailability get availability;
/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCopyWith<Device> get copyWith => _$DeviceCopyWithImpl<Device>(this as Device, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Device;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Device&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.homeId, _this.homeId) || other.homeId == _this.homeId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.capabilities, _this.capabilities)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.firmware, _this.firmware) || other.firmware == _this.firmware)&&const DeepCollectionEquality().equals(other.state, _this.state)&&(identical(other.availability, _this.availability) || other.availability == _this.availability));
}


@override
int get hashCode {
  final _this = this as Device;
  return Object.hash(runtimeType,_this.id,_this.homeId,_this.type,_this.name,const DeepCollectionEquality().hash(_this.capabilities),_this.roomId,_this.manufacturer,_this.model,_this.firmware,const DeepCollectionEquality().hash(_this.state),_this.availability);
}

@override
String toString() {
  final _this = this as Device;
  return 'Device(id: ${_this.id}, homeId: ${_this.homeId}, type: ${_this.type}, name: ${_this.name}, capabilities: ${_this.capabilities}, roomId: ${_this.roomId}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, firmware: ${_this.firmware}, state: ${_this.state}, availability: ${_this.availability})';
}


}

/// @nodoc
abstract mixin class $DeviceCopyWith<$Res>  {
  factory $DeviceCopyWith(Device value, $Res Function(Device) _then) = _$DeviceCopyWithImpl;
@useResult
$Res call({
 String id, String homeId, DeviceType type, String name, List<Capability> capabilities, String? roomId, String? manufacturer, String? model, String? firmware, Map<String, CapabilityState> state, DeviceAvailability availability
});




}
/// @nodoc
class _$DeviceCopyWithImpl<$Res>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._self, this._then);

  final Device _self;
  final $Res Function(Device) _then;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? homeId = null,Object? type = null,Object? name = null,Object? capabilities = null,Object? roomId = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? state = null,Object? availability = null,}) {
  return _then(Device(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeviceType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<Capability>,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as Map<String, CapabilityState>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as DeviceAvailability,
  ));
}

}


/// Adds pattern-matching-related methods to [Device].
extension DevicePatterns on Device {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Device value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Device() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Device value)  $default,){
final _that = this;
switch (_that) {
case _Device():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Device value)?  $default,){
final _that = this;
switch (_that) {
case _Device() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String homeId,  DeviceType type,  String name,  List<Capability> capabilities,  String? roomId,  String? manufacturer,  String? model,  String? firmware,  Map<String, CapabilityState> state,  DeviceAvailability availability)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Device() when $default != null:
return $default(_that.id,_that.homeId,_that.type,_that.name,_that.capabilities,_that.roomId,_that.manufacturer,_that.model,_that.firmware,_that.state,_that.availability);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String homeId,  DeviceType type,  String name,  List<Capability> capabilities,  String? roomId,  String? manufacturer,  String? model,  String? firmware,  Map<String, CapabilityState> state,  DeviceAvailability availability)  $default,) {final _that = this;
switch (_that) {
case _Device():
return $default(_that.id,_that.homeId,_that.type,_that.name,_that.capabilities,_that.roomId,_that.manufacturer,_that.model,_that.firmware,_that.state,_that.availability);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String homeId,  DeviceType type,  String name,  List<Capability> capabilities,  String? roomId,  String? manufacturer,  String? model,  String? firmware,  Map<String, CapabilityState> state,  DeviceAvailability availability)?  $default,) {final _that = this;
switch (_that) {
case _Device() when $default != null:
return $default(_that.id,_that.homeId,_that.type,_that.name,_that.capabilities,_that.roomId,_that.manufacturer,_that.model,_that.firmware,_that.state,_that.availability);case _:
  return null;

}
}

}

/// @nodoc


class _Device extends Device {
  const _Device({required this.id, required this.homeId, required this.type, required this.name, required  List<Capability> capabilities, this.roomId, this.manufacturer, this.model, this.firmware,  Map<String, CapabilityState> state = const <String, CapabilityState>{}, this.availability = DeviceAvailability.unknown}): _capabilities = capabilities,_state = state,super._();
  

@override final  String id;
@override final  String homeId;
@override final  DeviceType type;
@override final  String name;
 final  List<Capability> _capabilities;
@override List<Capability> get capabilities {
  if (_capabilities is EqualUnmodifiableListView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_capabilities);
}

@override final  String? roomId;
@override final  String? manufacturer;
@override final  String? model;
@override final  String? firmware;
 final  Map<String, CapabilityState> _state;
@override@JsonKey() Map<String, CapabilityState> get state {
  if (_state is EqualUnmodifiableMapView) return _state;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_state);
}

@override@JsonKey() final  DeviceAvailability availability;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceCopyWith<_Device> get copyWith => __$DeviceCopyWithImpl<_Device>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Device&&(identical(other.id, id) || other.id == id)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.capabilities, _capabilities)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware)&&const DeepCollectionEquality().equals(other.state, _state)&&(identical(other.availability, availability) || other.availability == availability));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,homeId,type,name,const DeepCollectionEquality().hash(_capabilities),roomId,manufacturer,model,firmware,const DeepCollectionEquality().hash(_state),availability);
}

@override
String toString() {
    return 'Device(id: $id, homeId: $homeId, type: $type, name: $name, capabilities: $capabilities, roomId: $roomId, manufacturer: $manufacturer, model: $model, firmware: $firmware, state: $state, availability: $availability)';
}


}

/// @nodoc
abstract mixin class _$DeviceCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$DeviceCopyWith(_Device value, $Res Function(_Device) _then) = __$DeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String homeId, DeviceType type, String name, List<Capability> capabilities, String? roomId, String? manufacturer, String? model, String? firmware, Map<String, CapabilityState> state, DeviceAvailability availability
});




}
/// @nodoc
class __$DeviceCopyWithImpl<$Res>
    implements _$DeviceCopyWith<$Res> {
  __$DeviceCopyWithImpl(this._self, this._then);

  final _Device _self;
  final $Res Function(_Device) _then;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? homeId = null,Object? type = null,Object? name = null,Object? capabilities = null,Object? roomId = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? state = null,Object? availability = null,}) {
  return _then(_Device(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeviceType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capabilities: null == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<Capability>,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self._state : state // ignore: cast_nullable_to_non_nullable
as Map<String, CapabilityState>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as DeviceAvailability,
  ));
}


}

// dart format on
