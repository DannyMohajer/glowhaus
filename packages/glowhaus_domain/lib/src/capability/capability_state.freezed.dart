// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capability_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
CapabilityState _$CapabilityStateFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'onOff':
          return OnOffState.fromJson(
            json
          );
                case 'brightness':
          return BrightnessState.fromJson(
            json
          );
                case 'color':
          return ColorState.fromJson(
            json
          );
                case 'colorTemperature':
          return ColorTemperatureState.fromJson(
            json
          );
                case 'position':
          return PositionState.fromJson(
            json
          );
                case 'thermostat':
          return ThermostatState.fromJson(
            json
          );
                case 'powerMeter':
          return PowerMeterState.fromJson(
            json
          );
                case 'lock':
          return LockState.fromJson(
            json
          );
                case 'temperatureSensor':
          return TemperatureSensorState.fromJson(
            json
          );
                case 'humiditySensor':
          return HumiditySensorState.fromJson(
            json
          );
                case 'motionSensor':
          return MotionSensorState.fromJson(
            json
          );
                case 'contactSensor':
          return ContactSensorState.fromJson(
            json
          );
                case 'camera':
          return CameraState.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'CapabilityState',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$CapabilityState {



  /// Serializes this CapabilityState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CapabilityState);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CapabilityState()';
}


}

/// @nodoc
class $CapabilityStateCopyWith<$Res>  {
$CapabilityStateCopyWith(CapabilityState _, $Res Function(CapabilityState) __);
}


/// Adds pattern-matching-related methods to [CapabilityState].
extension CapabilityStatePatterns on CapabilityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OnOffState value)?  onOff,TResult Function( BrightnessState value)?  brightness,TResult Function( ColorState value)?  color,TResult Function( ColorTemperatureState value)?  colorTemperature,TResult Function( PositionState value)?  position,TResult Function( ThermostatState value)?  thermostat,TResult Function( PowerMeterState value)?  powerMeter,TResult Function( LockState value)?  lock,TResult Function( TemperatureSensorState value)?  temperatureSensor,TResult Function( HumiditySensorState value)?  humiditySensor,TResult Function( MotionSensorState value)?  motionSensor,TResult Function( ContactSensorState value)?  contactSensor,TResult Function( CameraState value)?  camera,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OnOffState() when onOff != null:
return onOff(_that);case BrightnessState() when brightness != null:
return brightness(_that);case ColorState() when color != null:
return color(_that);case ColorTemperatureState() when colorTemperature != null:
return colorTemperature(_that);case PositionState() when position != null:
return position(_that);case ThermostatState() when thermostat != null:
return thermostat(_that);case PowerMeterState() when powerMeter != null:
return powerMeter(_that);case LockState() when lock != null:
return lock(_that);case TemperatureSensorState() when temperatureSensor != null:
return temperatureSensor(_that);case HumiditySensorState() when humiditySensor != null:
return humiditySensor(_that);case MotionSensorState() when motionSensor != null:
return motionSensor(_that);case ContactSensorState() when contactSensor != null:
return contactSensor(_that);case CameraState() when camera != null:
return camera(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OnOffState value)  onOff,required TResult Function( BrightnessState value)  brightness,required TResult Function( ColorState value)  color,required TResult Function( ColorTemperatureState value)  colorTemperature,required TResult Function( PositionState value)  position,required TResult Function( ThermostatState value)  thermostat,required TResult Function( PowerMeterState value)  powerMeter,required TResult Function( LockState value)  lock,required TResult Function( TemperatureSensorState value)  temperatureSensor,required TResult Function( HumiditySensorState value)  humiditySensor,required TResult Function( MotionSensorState value)  motionSensor,required TResult Function( ContactSensorState value)  contactSensor,required TResult Function( CameraState value)  camera,}){
final _that = this;
switch (_that) {
case OnOffState():
return onOff(_that);case BrightnessState():
return brightness(_that);case ColorState():
return color(_that);case ColorTemperatureState():
return colorTemperature(_that);case PositionState():
return position(_that);case ThermostatState():
return thermostat(_that);case PowerMeterState():
return powerMeter(_that);case LockState():
return lock(_that);case TemperatureSensorState():
return temperatureSensor(_that);case HumiditySensorState():
return humiditySensor(_that);case MotionSensorState():
return motionSensor(_that);case ContactSensorState():
return contactSensor(_that);case CameraState():
return camera(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OnOffState value)?  onOff,TResult? Function( BrightnessState value)?  brightness,TResult? Function( ColorState value)?  color,TResult? Function( ColorTemperatureState value)?  colorTemperature,TResult? Function( PositionState value)?  position,TResult? Function( ThermostatState value)?  thermostat,TResult? Function( PowerMeterState value)?  powerMeter,TResult? Function( LockState value)?  lock,TResult? Function( TemperatureSensorState value)?  temperatureSensor,TResult? Function( HumiditySensorState value)?  humiditySensor,TResult? Function( MotionSensorState value)?  motionSensor,TResult? Function( ContactSensorState value)?  contactSensor,TResult? Function( CameraState value)?  camera,}){
final _that = this;
switch (_that) {
case OnOffState() when onOff != null:
return onOff(_that);case BrightnessState() when brightness != null:
return brightness(_that);case ColorState() when color != null:
return color(_that);case ColorTemperatureState() when colorTemperature != null:
return colorTemperature(_that);case PositionState() when position != null:
return position(_that);case ThermostatState() when thermostat != null:
return thermostat(_that);case PowerMeterState() when powerMeter != null:
return powerMeter(_that);case LockState() when lock != null:
return lock(_that);case TemperatureSensorState() when temperatureSensor != null:
return temperatureSensor(_that);case HumiditySensorState() when humiditySensor != null:
return humiditySensor(_that);case MotionSensorState() when motionSensor != null:
return motionSensor(_that);case ContactSensorState() when contactSensor != null:
return contactSensor(_that);case CameraState() when camera != null:
return camera(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool on)?  onOff,TResult Function( int level)?  brightness,TResult Function( int hue,  int saturation)?  color,TResult Function( int kelvin)?  colorTemperature,TResult Function( int position,  int target,  bool moving)?  position,TResult Function( double setpoint,  ThermostatMode mode,  FanMode? fan,  ThermostatAction action)?  thermostat,TResult Function( double watts,  double? energyKwh)?  powerMeter,TResult Function( bool locked,  bool jammed)?  lock,TResult Function( double celsius)?  temperatureSensor,TResult Function( double percent)?  humiditySensor,TResult Function( bool motion,  int? lastMotionAt)?  motionSensor,TResult Function( bool open)?  contactSensor,TResult Function( bool streaming)?  camera,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OnOffState() when onOff != null:
return onOff(_that.on);case BrightnessState() when brightness != null:
return brightness(_that.level);case ColorState() when color != null:
return color(_that.hue,_that.saturation);case ColorTemperatureState() when colorTemperature != null:
return colorTemperature(_that.kelvin);case PositionState() when position != null:
return position(_that.position,_that.target,_that.moving);case ThermostatState() when thermostat != null:
return thermostat(_that.setpoint,_that.mode,_that.fan,_that.action);case PowerMeterState() when powerMeter != null:
return powerMeter(_that.watts,_that.energyKwh);case LockState() when lock != null:
return lock(_that.locked,_that.jammed);case TemperatureSensorState() when temperatureSensor != null:
return temperatureSensor(_that.celsius);case HumiditySensorState() when humiditySensor != null:
return humiditySensor(_that.percent);case MotionSensorState() when motionSensor != null:
return motionSensor(_that.motion,_that.lastMotionAt);case ContactSensorState() when contactSensor != null:
return contactSensor(_that.open);case CameraState() when camera != null:
return camera(_that.streaming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool on)  onOff,required TResult Function( int level)  brightness,required TResult Function( int hue,  int saturation)  color,required TResult Function( int kelvin)  colorTemperature,required TResult Function( int position,  int target,  bool moving)  position,required TResult Function( double setpoint,  ThermostatMode mode,  FanMode? fan,  ThermostatAction action)  thermostat,required TResult Function( double watts,  double? energyKwh)  powerMeter,required TResult Function( bool locked,  bool jammed)  lock,required TResult Function( double celsius)  temperatureSensor,required TResult Function( double percent)  humiditySensor,required TResult Function( bool motion,  int? lastMotionAt)  motionSensor,required TResult Function( bool open)  contactSensor,required TResult Function( bool streaming)  camera,}) {final _that = this;
switch (_that) {
case OnOffState():
return onOff(_that.on);case BrightnessState():
return brightness(_that.level);case ColorState():
return color(_that.hue,_that.saturation);case ColorTemperatureState():
return colorTemperature(_that.kelvin);case PositionState():
return position(_that.position,_that.target,_that.moving);case ThermostatState():
return thermostat(_that.setpoint,_that.mode,_that.fan,_that.action);case PowerMeterState():
return powerMeter(_that.watts,_that.energyKwh);case LockState():
return lock(_that.locked,_that.jammed);case TemperatureSensorState():
return temperatureSensor(_that.celsius);case HumiditySensorState():
return humiditySensor(_that.percent);case MotionSensorState():
return motionSensor(_that.motion,_that.lastMotionAt);case ContactSensorState():
return contactSensor(_that.open);case CameraState():
return camera(_that.streaming);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool on)?  onOff,TResult? Function( int level)?  brightness,TResult? Function( int hue,  int saturation)?  color,TResult? Function( int kelvin)?  colorTemperature,TResult? Function( int position,  int target,  bool moving)?  position,TResult? Function( double setpoint,  ThermostatMode mode,  FanMode? fan,  ThermostatAction action)?  thermostat,TResult? Function( double watts,  double? energyKwh)?  powerMeter,TResult? Function( bool locked,  bool jammed)?  lock,TResult? Function( double celsius)?  temperatureSensor,TResult? Function( double percent)?  humiditySensor,TResult? Function( bool motion,  int? lastMotionAt)?  motionSensor,TResult? Function( bool open)?  contactSensor,TResult? Function( bool streaming)?  camera,}) {final _that = this;
switch (_that) {
case OnOffState() when onOff != null:
return onOff(_that.on);case BrightnessState() when brightness != null:
return brightness(_that.level);case ColorState() when color != null:
return color(_that.hue,_that.saturation);case ColorTemperatureState() when colorTemperature != null:
return colorTemperature(_that.kelvin);case PositionState() when position != null:
return position(_that.position,_that.target,_that.moving);case ThermostatState() when thermostat != null:
return thermostat(_that.setpoint,_that.mode,_that.fan,_that.action);case PowerMeterState() when powerMeter != null:
return powerMeter(_that.watts,_that.energyKwh);case LockState() when lock != null:
return lock(_that.locked,_that.jammed);case TemperatureSensorState() when temperatureSensor != null:
return temperatureSensor(_that.celsius);case HumiditySensorState() when humiditySensor != null:
return humiditySensor(_that.percent);case MotionSensorState() when motionSensor != null:
return motionSensor(_that.motion,_that.lastMotionAt);case ContactSensorState() when contactSensor != null:
return contactSensor(_that.open);case CameraState() when camera != null:
return camera(_that.streaming);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class OnOffState extends CapabilityState {
  const OnOffState({required this.on,  String? $type}): $type = $type ?? 'onOff',super._();
  factory OnOffState.fromJson(Map<String, dynamic> json) => _$OnOffStateFromJson(json);

 final  bool on;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnOffStateCopyWith<OnOffState> get copyWith => _$OnOffStateCopyWithImpl<OnOffState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnOffStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OnOffState&&(identical(other.on, on) || other.on == on));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,on);
}

@override
String toString() {
    return 'CapabilityState.onOff(on: $on)';
}


}

/// @nodoc
abstract mixin class $OnOffStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $OnOffStateCopyWith(OnOffState value, $Res Function(OnOffState) _then) = _$OnOffStateCopyWithImpl;
@useResult
$Res call({
 bool on
});




}
/// @nodoc
class _$OnOffStateCopyWithImpl<$Res>
    implements $OnOffStateCopyWith<$Res> {
  _$OnOffStateCopyWithImpl(this._self, this._then);

  final OnOffState _self;
  final $Res Function(OnOffState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? on = null,}) {
  return _then(OnOffState(
on: null == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BrightnessState extends CapabilityState {
  const BrightnessState({required this.level,  String? $type}): $type = $type ?? 'brightness',super._();
  factory BrightnessState.fromJson(Map<String, dynamic> json) => _$BrightnessStateFromJson(json);

 final  int level;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrightnessStateCopyWith<BrightnessState> get copyWith => _$BrightnessStateCopyWithImpl<BrightnessState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrightnessStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BrightnessState&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level);
}

@override
String toString() {
    return 'CapabilityState.brightness(level: $level)';
}


}

/// @nodoc
abstract mixin class $BrightnessStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $BrightnessStateCopyWith(BrightnessState value, $Res Function(BrightnessState) _then) = _$BrightnessStateCopyWithImpl;
@useResult
$Res call({
 int level
});




}
/// @nodoc
class _$BrightnessStateCopyWithImpl<$Res>
    implements $BrightnessStateCopyWith<$Res> {
  _$BrightnessStateCopyWithImpl(this._self, this._then);

  final BrightnessState _self;
  final $Res Function(BrightnessState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? level = null,}) {
  return _then(BrightnessState(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ColorState extends CapabilityState {
  const ColorState({required this.hue, required this.saturation,  String? $type}): $type = $type ?? 'color',super._();
  factory ColorState.fromJson(Map<String, dynamic> json) => _$ColorStateFromJson(json);

 final  int hue;
 final  int saturation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorStateCopyWith<ColorState> get copyWith => _$ColorStateCopyWithImpl<ColorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorState&&(identical(other.hue, hue) || other.hue == hue)&&(identical(other.saturation, saturation) || other.saturation == saturation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hue,saturation);
}

@override
String toString() {
    return 'CapabilityState.color(hue: $hue, saturation: $saturation)';
}


}

/// @nodoc
abstract mixin class $ColorStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $ColorStateCopyWith(ColorState value, $Res Function(ColorState) _then) = _$ColorStateCopyWithImpl;
@useResult
$Res call({
 int hue, int saturation
});




}
/// @nodoc
class _$ColorStateCopyWithImpl<$Res>
    implements $ColorStateCopyWith<$Res> {
  _$ColorStateCopyWithImpl(this._self, this._then);

  final ColorState _self;
  final $Res Function(ColorState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hue = null,Object? saturation = null,}) {
  return _then(ColorState(
hue: null == hue ? _self.hue : hue // ignore: cast_nullable_to_non_nullable
as int,saturation: null == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ColorTemperatureState extends CapabilityState {
  const ColorTemperatureState({required this.kelvin,  String? $type}): $type = $type ?? 'colorTemperature',super._();
  factory ColorTemperatureState.fromJson(Map<String, dynamic> json) => _$ColorTemperatureStateFromJson(json);

 final  int kelvin;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorTemperatureStateCopyWith<ColorTemperatureState> get copyWith => _$ColorTemperatureStateCopyWithImpl<ColorTemperatureState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorTemperatureStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorTemperatureState&&(identical(other.kelvin, kelvin) || other.kelvin == kelvin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kelvin);
}

@override
String toString() {
    return 'CapabilityState.colorTemperature(kelvin: $kelvin)';
}


}

/// @nodoc
abstract mixin class $ColorTemperatureStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $ColorTemperatureStateCopyWith(ColorTemperatureState value, $Res Function(ColorTemperatureState) _then) = _$ColorTemperatureStateCopyWithImpl;
@useResult
$Res call({
 int kelvin
});




}
/// @nodoc
class _$ColorTemperatureStateCopyWithImpl<$Res>
    implements $ColorTemperatureStateCopyWith<$Res> {
  _$ColorTemperatureStateCopyWithImpl(this._self, this._then);

  final ColorTemperatureState _self;
  final $Res Function(ColorTemperatureState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kelvin = null,}) {
  return _then(ColorTemperatureState(
kelvin: null == kelvin ? _self.kelvin : kelvin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PositionState extends CapabilityState {
  const PositionState({required this.position, required this.target, this.moving = false,  String? $type}): $type = $type ?? 'position',super._();
  factory PositionState.fromJson(Map<String, dynamic> json) => _$PositionStateFromJson(json);

 final  int position;
 final  int target;
@JsonKey() final  bool moving;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PositionStateCopyWith<PositionState> get copyWith => _$PositionStateCopyWithImpl<PositionState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PositionStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PositionState&&(identical(other.position, position) || other.position == position)&&(identical(other.target, target) || other.target == target)&&(identical(other.moving, moving) || other.moving == moving));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,position,target,moving);
}

@override
String toString() {
    return 'CapabilityState.position(position: $position, target: $target, moving: $moving)';
}


}

/// @nodoc
abstract mixin class $PositionStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $PositionStateCopyWith(PositionState value, $Res Function(PositionState) _then) = _$PositionStateCopyWithImpl;
@useResult
$Res call({
 int position, int target, bool moving
});




}
/// @nodoc
class _$PositionStateCopyWithImpl<$Res>
    implements $PositionStateCopyWith<$Res> {
  _$PositionStateCopyWithImpl(this._self, this._then);

  final PositionState _self;
  final $Res Function(PositionState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,Object? target = null,Object? moving = null,}) {
  return _then(PositionState(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,moving: null == moving ? _self.moving : moving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ThermostatState extends CapabilityState {
  const ThermostatState({required this.setpoint, required this.mode, this.fan, this.action = ThermostatAction.idle,  String? $type}): $type = $type ?? 'thermostat',super._();
  factory ThermostatState.fromJson(Map<String, dynamic> json) => _$ThermostatStateFromJson(json);

 final  double setpoint;
 final  ThermostatMode mode;
 final  FanMode? fan;
@JsonKey() final  ThermostatAction action;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThermostatStateCopyWith<ThermostatState> get copyWith => _$ThermostatStateCopyWithImpl<ThermostatState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThermostatStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ThermostatState&&(identical(other.setpoint, setpoint) || other.setpoint == setpoint)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.fan, fan) || other.fan == fan)&&(identical(other.action, action) || other.action == action));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,setpoint,mode,fan,action);
}

@override
String toString() {
    return 'CapabilityState.thermostat(setpoint: $setpoint, mode: $mode, fan: $fan, action: $action)';
}


}

/// @nodoc
abstract mixin class $ThermostatStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $ThermostatStateCopyWith(ThermostatState value, $Res Function(ThermostatState) _then) = _$ThermostatStateCopyWithImpl;
@useResult
$Res call({
 double setpoint, ThermostatMode mode, FanMode? fan, ThermostatAction action
});




}
/// @nodoc
class _$ThermostatStateCopyWithImpl<$Res>
    implements $ThermostatStateCopyWith<$Res> {
  _$ThermostatStateCopyWithImpl(this._self, this._then);

  final ThermostatState _self;
  final $Res Function(ThermostatState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? setpoint = null,Object? mode = null,Object? fan = freezed,Object? action = null,}) {
  return _then(ThermostatState(
setpoint: null == setpoint ? _self.setpoint : setpoint // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ThermostatMode,fan: freezed == fan ? _self.fan : fan // ignore: cast_nullable_to_non_nullable
as FanMode?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ThermostatAction,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PowerMeterState extends CapabilityState {
  const PowerMeterState({required this.watts, this.energyKwh,  String? $type}): $type = $type ?? 'powerMeter',super._();
  factory PowerMeterState.fromJson(Map<String, dynamic> json) => _$PowerMeterStateFromJson(json);

 final  double watts;
 final  double? energyKwh;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PowerMeterStateCopyWith<PowerMeterState> get copyWith => _$PowerMeterStateCopyWithImpl<PowerMeterState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PowerMeterStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PowerMeterState&&(identical(other.watts, watts) || other.watts == watts)&&(identical(other.energyKwh, energyKwh) || other.energyKwh == energyKwh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,watts,energyKwh);
}

@override
String toString() {
    return 'CapabilityState.powerMeter(watts: $watts, energyKwh: $energyKwh)';
}


}

/// @nodoc
abstract mixin class $PowerMeterStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $PowerMeterStateCopyWith(PowerMeterState value, $Res Function(PowerMeterState) _then) = _$PowerMeterStateCopyWithImpl;
@useResult
$Res call({
 double watts, double? energyKwh
});




}
/// @nodoc
class _$PowerMeterStateCopyWithImpl<$Res>
    implements $PowerMeterStateCopyWith<$Res> {
  _$PowerMeterStateCopyWithImpl(this._self, this._then);

  final PowerMeterState _self;
  final $Res Function(PowerMeterState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? watts = null,Object? energyKwh = freezed,}) {
  return _then(PowerMeterState(
watts: null == watts ? _self.watts : watts // ignore: cast_nullable_to_non_nullable
as double,energyKwh: freezed == energyKwh ? _self.energyKwh : energyKwh // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LockState extends CapabilityState {
  const LockState({required this.locked, this.jammed = false,  String? $type}): $type = $type ?? 'lock',super._();
  factory LockState.fromJson(Map<String, dynamic> json) => _$LockStateFromJson(json);

 final  bool locked;
@JsonKey() final  bool jammed;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockStateCopyWith<LockState> get copyWith => _$LockStateCopyWithImpl<LockState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LockState&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.jammed, jammed) || other.jammed == jammed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locked,jammed);
}

@override
String toString() {
    return 'CapabilityState.lock(locked: $locked, jammed: $jammed)';
}


}

/// @nodoc
abstract mixin class $LockStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $LockStateCopyWith(LockState value, $Res Function(LockState) _then) = _$LockStateCopyWithImpl;
@useResult
$Res call({
 bool locked, bool jammed
});




}
/// @nodoc
class _$LockStateCopyWithImpl<$Res>
    implements $LockStateCopyWith<$Res> {
  _$LockStateCopyWithImpl(this._self, this._then);

  final LockState _self;
  final $Res Function(LockState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locked = null,Object? jammed = null,}) {
  return _then(LockState(
locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,jammed: null == jammed ? _self.jammed : jammed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TemperatureSensorState extends CapabilityState {
  const TemperatureSensorState({required this.celsius,  String? $type}): $type = $type ?? 'temperatureSensor',super._();
  factory TemperatureSensorState.fromJson(Map<String, dynamic> json) => _$TemperatureSensorStateFromJson(json);

 final  double celsius;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemperatureSensorStateCopyWith<TemperatureSensorState> get copyWith => _$TemperatureSensorStateCopyWithImpl<TemperatureSensorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemperatureSensorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TemperatureSensorState&&(identical(other.celsius, celsius) || other.celsius == celsius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,celsius);
}

@override
String toString() {
    return 'CapabilityState.temperatureSensor(celsius: $celsius)';
}


}

/// @nodoc
abstract mixin class $TemperatureSensorStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $TemperatureSensorStateCopyWith(TemperatureSensorState value, $Res Function(TemperatureSensorState) _then) = _$TemperatureSensorStateCopyWithImpl;
@useResult
$Res call({
 double celsius
});




}
/// @nodoc
class _$TemperatureSensorStateCopyWithImpl<$Res>
    implements $TemperatureSensorStateCopyWith<$Res> {
  _$TemperatureSensorStateCopyWithImpl(this._self, this._then);

  final TemperatureSensorState _self;
  final $Res Function(TemperatureSensorState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? celsius = null,}) {
  return _then(TemperatureSensorState(
celsius: null == celsius ? _self.celsius : celsius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class HumiditySensorState extends CapabilityState {
  const HumiditySensorState({required this.percent,  String? $type}): $type = $type ?? 'humiditySensor',super._();
  factory HumiditySensorState.fromJson(Map<String, dynamic> json) => _$HumiditySensorStateFromJson(json);

 final  double percent;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HumiditySensorStateCopyWith<HumiditySensorState> get copyWith => _$HumiditySensorStateCopyWithImpl<HumiditySensorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HumiditySensorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HumiditySensorState&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,percent);
}

@override
String toString() {
    return 'CapabilityState.humiditySensor(percent: $percent)';
}


}

/// @nodoc
abstract mixin class $HumiditySensorStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $HumiditySensorStateCopyWith(HumiditySensorState value, $Res Function(HumiditySensorState) _then) = _$HumiditySensorStateCopyWithImpl;
@useResult
$Res call({
 double percent
});




}
/// @nodoc
class _$HumiditySensorStateCopyWithImpl<$Res>
    implements $HumiditySensorStateCopyWith<$Res> {
  _$HumiditySensorStateCopyWithImpl(this._self, this._then);

  final HumiditySensorState _self;
  final $Res Function(HumiditySensorState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? percent = null,}) {
  return _then(HumiditySensorState(
percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MotionSensorState extends CapabilityState {
  const MotionSensorState({required this.motion, this.lastMotionAt,  String? $type}): $type = $type ?? 'motionSensor',super._();
  factory MotionSensorState.fromJson(Map<String, dynamic> json) => _$MotionSensorStateFromJson(json);

 final  bool motion;
 final  int? lastMotionAt;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotionSensorStateCopyWith<MotionSensorState> get copyWith => _$MotionSensorStateCopyWithImpl<MotionSensorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MotionSensorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MotionSensorState&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.lastMotionAt, lastMotionAt) || other.lastMotionAt == lastMotionAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,motion,lastMotionAt);
}

@override
String toString() {
    return 'CapabilityState.motionSensor(motion: $motion, lastMotionAt: $lastMotionAt)';
}


}

/// @nodoc
abstract mixin class $MotionSensorStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $MotionSensorStateCopyWith(MotionSensorState value, $Res Function(MotionSensorState) _then) = _$MotionSensorStateCopyWithImpl;
@useResult
$Res call({
 bool motion, int? lastMotionAt
});




}
/// @nodoc
class _$MotionSensorStateCopyWithImpl<$Res>
    implements $MotionSensorStateCopyWith<$Res> {
  _$MotionSensorStateCopyWithImpl(this._self, this._then);

  final MotionSensorState _self;
  final $Res Function(MotionSensorState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? motion = null,Object? lastMotionAt = freezed,}) {
  return _then(MotionSensorState(
motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as bool,lastMotionAt: freezed == lastMotionAt ? _self.lastMotionAt : lastMotionAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ContactSensorState extends CapabilityState {
  const ContactSensorState({required this.open,  String? $type}): $type = $type ?? 'contactSensor',super._();
  factory ContactSensorState.fromJson(Map<String, dynamic> json) => _$ContactSensorStateFromJson(json);

 final  bool open;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactSensorStateCopyWith<ContactSensorState> get copyWith => _$ContactSensorStateCopyWithImpl<ContactSensorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactSensorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactSensorState&&(identical(other.open, open) || other.open == open));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,open);
}

@override
String toString() {
    return 'CapabilityState.contactSensor(open: $open)';
}


}

/// @nodoc
abstract mixin class $ContactSensorStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $ContactSensorStateCopyWith(ContactSensorState value, $Res Function(ContactSensorState) _then) = _$ContactSensorStateCopyWithImpl;
@useResult
$Res call({
 bool open
});




}
/// @nodoc
class _$ContactSensorStateCopyWithImpl<$Res>
    implements $ContactSensorStateCopyWith<$Res> {
  _$ContactSensorStateCopyWithImpl(this._self, this._then);

  final ContactSensorState _self;
  final $Res Function(ContactSensorState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? open = null,}) {
  return _then(ContactSensorState(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CameraState extends CapabilityState {
  const CameraState({required this.streaming,  String? $type}): $type = $type ?? 'camera',super._();
  factory CameraState.fromJson(Map<String, dynamic> json) => _$CameraStateFromJson(json);

 final  bool streaming;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraStateCopyWith<CameraState> get copyWith => _$CameraStateCopyWithImpl<CameraState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CameraStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraState&&(identical(other.streaming, streaming) || other.streaming == streaming));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,streaming);
}

@override
String toString() {
    return 'CapabilityState.camera(streaming: $streaming)';
}


}

/// @nodoc
abstract mixin class $CameraStateCopyWith<$Res> implements $CapabilityStateCopyWith<$Res> {
  factory $CameraStateCopyWith(CameraState value, $Res Function(CameraState) _then) = _$CameraStateCopyWithImpl;
@useResult
$Res call({
 bool streaming
});




}
/// @nodoc
class _$CameraStateCopyWithImpl<$Res>
    implements $CameraStateCopyWith<$Res> {
  _$CameraStateCopyWithImpl(this._self, this._then);

  final CameraState _self;
  final $Res Function(CameraState) _then;

/// Create a copy of CapabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? streaming = null,}) {
  return _then(CameraState(
streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
