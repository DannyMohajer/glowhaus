// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capability_patch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
CapabilityPatch _$CapabilityPatchFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'onOff':
          return OnOffPatch.fromJson(
            json
          );
                case 'brightness':
          return BrightnessPatch.fromJson(
            json
          );
                case 'color':
          return ColorPatch.fromJson(
            json
          );
                case 'colorTemperature':
          return ColorTemperaturePatch.fromJson(
            json
          );
                case 'position':
          return PositionPatch.fromJson(
            json
          );
                case 'thermostat':
          return ThermostatPatch.fromJson(
            json
          );
                case 'lock':
          return LockPatch.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'CapabilityPatch',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$CapabilityPatch {



  /// Serializes this CapabilityPatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CapabilityPatch);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CapabilityPatch()';
}


}

/// @nodoc
class $CapabilityPatchCopyWith<$Res>  {
$CapabilityPatchCopyWith(CapabilityPatch _, $Res Function(CapabilityPatch) __);
}


/// Adds pattern-matching-related methods to [CapabilityPatch].
extension CapabilityPatchPatterns on CapabilityPatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OnOffPatch value)?  onOff,TResult Function( BrightnessPatch value)?  brightness,TResult Function( ColorPatch value)?  color,TResult Function( ColorTemperaturePatch value)?  colorTemperature,TResult Function( PositionPatch value)?  position,TResult Function( ThermostatPatch value)?  thermostat,TResult Function( LockPatch value)?  lock,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OnOffPatch() when onOff != null:
return onOff(_that);case BrightnessPatch() when brightness != null:
return brightness(_that);case ColorPatch() when color != null:
return color(_that);case ColorTemperaturePatch() when colorTemperature != null:
return colorTemperature(_that);case PositionPatch() when position != null:
return position(_that);case ThermostatPatch() when thermostat != null:
return thermostat(_that);case LockPatch() when lock != null:
return lock(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OnOffPatch value)  onOff,required TResult Function( BrightnessPatch value)  brightness,required TResult Function( ColorPatch value)  color,required TResult Function( ColorTemperaturePatch value)  colorTemperature,required TResult Function( PositionPatch value)  position,required TResult Function( ThermostatPatch value)  thermostat,required TResult Function( LockPatch value)  lock,}){
final _that = this;
switch (_that) {
case OnOffPatch():
return onOff(_that);case BrightnessPatch():
return brightness(_that);case ColorPatch():
return color(_that);case ColorTemperaturePatch():
return colorTemperature(_that);case PositionPatch():
return position(_that);case ThermostatPatch():
return thermostat(_that);case LockPatch():
return lock(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OnOffPatch value)?  onOff,TResult? Function( BrightnessPatch value)?  brightness,TResult? Function( ColorPatch value)?  color,TResult? Function( ColorTemperaturePatch value)?  colorTemperature,TResult? Function( PositionPatch value)?  position,TResult? Function( ThermostatPatch value)?  thermostat,TResult? Function( LockPatch value)?  lock,}){
final _that = this;
switch (_that) {
case OnOffPatch() when onOff != null:
return onOff(_that);case BrightnessPatch() when brightness != null:
return brightness(_that);case ColorPatch() when color != null:
return color(_that);case ColorTemperaturePatch() when colorTemperature != null:
return colorTemperature(_that);case PositionPatch() when position != null:
return position(_that);case ThermostatPatch() when thermostat != null:
return thermostat(_that);case LockPatch() when lock != null:
return lock(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool on)?  onOff,TResult Function( int level)?  brightness,TResult Function( int? hue,  int? saturation)?  color,TResult Function( int kelvin)?  colorTemperature,TResult Function( int? target,  bool? stop)?  position,TResult Function( double? setpoint,  ThermostatMode? mode,  FanMode? fan)?  thermostat,TResult Function( bool locked)?  lock,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OnOffPatch() when onOff != null:
return onOff(_that.on);case BrightnessPatch() when brightness != null:
return brightness(_that.level);case ColorPatch() when color != null:
return color(_that.hue,_that.saturation);case ColorTemperaturePatch() when colorTemperature != null:
return colorTemperature(_that.kelvin);case PositionPatch() when position != null:
return position(_that.target,_that.stop);case ThermostatPatch() when thermostat != null:
return thermostat(_that.setpoint,_that.mode,_that.fan);case LockPatch() when lock != null:
return lock(_that.locked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool on)  onOff,required TResult Function( int level)  brightness,required TResult Function( int? hue,  int? saturation)  color,required TResult Function( int kelvin)  colorTemperature,required TResult Function( int? target,  bool? stop)  position,required TResult Function( double? setpoint,  ThermostatMode? mode,  FanMode? fan)  thermostat,required TResult Function( bool locked)  lock,}) {final _that = this;
switch (_that) {
case OnOffPatch():
return onOff(_that.on);case BrightnessPatch():
return brightness(_that.level);case ColorPatch():
return color(_that.hue,_that.saturation);case ColorTemperaturePatch():
return colorTemperature(_that.kelvin);case PositionPatch():
return position(_that.target,_that.stop);case ThermostatPatch():
return thermostat(_that.setpoint,_that.mode,_that.fan);case LockPatch():
return lock(_that.locked);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool on)?  onOff,TResult? Function( int level)?  brightness,TResult? Function( int? hue,  int? saturation)?  color,TResult? Function( int kelvin)?  colorTemperature,TResult? Function( int? target,  bool? stop)?  position,TResult? Function( double? setpoint,  ThermostatMode? mode,  FanMode? fan)?  thermostat,TResult? Function( bool locked)?  lock,}) {final _that = this;
switch (_that) {
case OnOffPatch() when onOff != null:
return onOff(_that.on);case BrightnessPatch() when brightness != null:
return brightness(_that.level);case ColorPatch() when color != null:
return color(_that.hue,_that.saturation);case ColorTemperaturePatch() when colorTemperature != null:
return colorTemperature(_that.kelvin);case PositionPatch() when position != null:
return position(_that.target,_that.stop);case ThermostatPatch() when thermostat != null:
return thermostat(_that.setpoint,_that.mode,_that.fan);case LockPatch() when lock != null:
return lock(_that.locked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class OnOffPatch extends CapabilityPatch {
  const OnOffPatch({required this.on,  String? $type}): $type = $type ?? 'onOff',super._();
  factory OnOffPatch.fromJson(Map<String, dynamic> json) => _$OnOffPatchFromJson(json);

 final  bool on;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnOffPatchCopyWith<OnOffPatch> get copyWith => _$OnOffPatchCopyWithImpl<OnOffPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnOffPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OnOffPatch&&(identical(other.on, on) || other.on == on));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,on);
}

@override
String toString() {
    return 'CapabilityPatch.onOff(on: $on)';
}


}

/// @nodoc
abstract mixin class $OnOffPatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $OnOffPatchCopyWith(OnOffPatch value, $Res Function(OnOffPatch) _then) = _$OnOffPatchCopyWithImpl;
@useResult
$Res call({
 bool on
});




}
/// @nodoc
class _$OnOffPatchCopyWithImpl<$Res>
    implements $OnOffPatchCopyWith<$Res> {
  _$OnOffPatchCopyWithImpl(this._self, this._then);

  final OnOffPatch _self;
  final $Res Function(OnOffPatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? on = null,}) {
  return _then(OnOffPatch(
on: null == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BrightnessPatch extends CapabilityPatch {
  const BrightnessPatch({required this.level,  String? $type}): $type = $type ?? 'brightness',super._();
  factory BrightnessPatch.fromJson(Map<String, dynamic> json) => _$BrightnessPatchFromJson(json);

 final  int level;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrightnessPatchCopyWith<BrightnessPatch> get copyWith => _$BrightnessPatchCopyWithImpl<BrightnessPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrightnessPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BrightnessPatch&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level);
}

@override
String toString() {
    return 'CapabilityPatch.brightness(level: $level)';
}


}

/// @nodoc
abstract mixin class $BrightnessPatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $BrightnessPatchCopyWith(BrightnessPatch value, $Res Function(BrightnessPatch) _then) = _$BrightnessPatchCopyWithImpl;
@useResult
$Res call({
 int level
});




}
/// @nodoc
class _$BrightnessPatchCopyWithImpl<$Res>
    implements $BrightnessPatchCopyWith<$Res> {
  _$BrightnessPatchCopyWithImpl(this._self, this._then);

  final BrightnessPatch _self;
  final $Res Function(BrightnessPatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? level = null,}) {
  return _then(BrightnessPatch(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ColorPatch extends CapabilityPatch {
  const ColorPatch({this.hue, this.saturation,  String? $type}): $type = $type ?? 'color',super._();
  factory ColorPatch.fromJson(Map<String, dynamic> json) => _$ColorPatchFromJson(json);

 final  int? hue;
 final  int? saturation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorPatchCopyWith<ColorPatch> get copyWith => _$ColorPatchCopyWithImpl<ColorPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorPatch&&(identical(other.hue, hue) || other.hue == hue)&&(identical(other.saturation, saturation) || other.saturation == saturation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hue,saturation);
}

@override
String toString() {
    return 'CapabilityPatch.color(hue: $hue, saturation: $saturation)';
}


}

/// @nodoc
abstract mixin class $ColorPatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $ColorPatchCopyWith(ColorPatch value, $Res Function(ColorPatch) _then) = _$ColorPatchCopyWithImpl;
@useResult
$Res call({
 int? hue, int? saturation
});




}
/// @nodoc
class _$ColorPatchCopyWithImpl<$Res>
    implements $ColorPatchCopyWith<$Res> {
  _$ColorPatchCopyWithImpl(this._self, this._then);

  final ColorPatch _self;
  final $Res Function(ColorPatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hue = freezed,Object? saturation = freezed,}) {
  return _then(ColorPatch(
hue: freezed == hue ? _self.hue : hue // ignore: cast_nullable_to_non_nullable
as int?,saturation: freezed == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ColorTemperaturePatch extends CapabilityPatch {
  const ColorTemperaturePatch({required this.kelvin,  String? $type}): $type = $type ?? 'colorTemperature',super._();
  factory ColorTemperaturePatch.fromJson(Map<String, dynamic> json) => _$ColorTemperaturePatchFromJson(json);

 final  int kelvin;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorTemperaturePatchCopyWith<ColorTemperaturePatch> get copyWith => _$ColorTemperaturePatchCopyWithImpl<ColorTemperaturePatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorTemperaturePatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorTemperaturePatch&&(identical(other.kelvin, kelvin) || other.kelvin == kelvin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kelvin);
}

@override
String toString() {
    return 'CapabilityPatch.colorTemperature(kelvin: $kelvin)';
}


}

/// @nodoc
abstract mixin class $ColorTemperaturePatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $ColorTemperaturePatchCopyWith(ColorTemperaturePatch value, $Res Function(ColorTemperaturePatch) _then) = _$ColorTemperaturePatchCopyWithImpl;
@useResult
$Res call({
 int kelvin
});




}
/// @nodoc
class _$ColorTemperaturePatchCopyWithImpl<$Res>
    implements $ColorTemperaturePatchCopyWith<$Res> {
  _$ColorTemperaturePatchCopyWithImpl(this._self, this._then);

  final ColorTemperaturePatch _self;
  final $Res Function(ColorTemperaturePatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kelvin = null,}) {
  return _then(ColorTemperaturePatch(
kelvin: null == kelvin ? _self.kelvin : kelvin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PositionPatch extends CapabilityPatch {
  const PositionPatch({this.target, this.stop,  String? $type}): $type = $type ?? 'position',super._();
  factory PositionPatch.fromJson(Map<String, dynamic> json) => _$PositionPatchFromJson(json);

 final  int? target;
 final  bool? stop;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PositionPatchCopyWith<PositionPatch> get copyWith => _$PositionPatchCopyWithImpl<PositionPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PositionPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PositionPatch&&(identical(other.target, target) || other.target == target)&&(identical(other.stop, stop) || other.stop == stop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,target,stop);
}

@override
String toString() {
    return 'CapabilityPatch.position(target: $target, stop: $stop)';
}


}

/// @nodoc
abstract mixin class $PositionPatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $PositionPatchCopyWith(PositionPatch value, $Res Function(PositionPatch) _then) = _$PositionPatchCopyWithImpl;
@useResult
$Res call({
 int? target, bool? stop
});




}
/// @nodoc
class _$PositionPatchCopyWithImpl<$Res>
    implements $PositionPatchCopyWith<$Res> {
  _$PositionPatchCopyWithImpl(this._self, this._then);

  final PositionPatch _self;
  final $Res Function(PositionPatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = freezed,Object? stop = freezed,}) {
  return _then(PositionPatch(
target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int?,stop: freezed == stop ? _self.stop : stop // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ThermostatPatch extends CapabilityPatch {
  const ThermostatPatch({this.setpoint, this.mode, this.fan,  String? $type}): $type = $type ?? 'thermostat',super._();
  factory ThermostatPatch.fromJson(Map<String, dynamic> json) => _$ThermostatPatchFromJson(json);

 final  double? setpoint;
 final  ThermostatMode? mode;
 final  FanMode? fan;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThermostatPatchCopyWith<ThermostatPatch> get copyWith => _$ThermostatPatchCopyWithImpl<ThermostatPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThermostatPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ThermostatPatch&&(identical(other.setpoint, setpoint) || other.setpoint == setpoint)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.fan, fan) || other.fan == fan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,setpoint,mode,fan);
}

@override
String toString() {
    return 'CapabilityPatch.thermostat(setpoint: $setpoint, mode: $mode, fan: $fan)';
}


}

/// @nodoc
abstract mixin class $ThermostatPatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $ThermostatPatchCopyWith(ThermostatPatch value, $Res Function(ThermostatPatch) _then) = _$ThermostatPatchCopyWithImpl;
@useResult
$Res call({
 double? setpoint, ThermostatMode? mode, FanMode? fan
});




}
/// @nodoc
class _$ThermostatPatchCopyWithImpl<$Res>
    implements $ThermostatPatchCopyWith<$Res> {
  _$ThermostatPatchCopyWithImpl(this._self, this._then);

  final ThermostatPatch _self;
  final $Res Function(ThermostatPatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? setpoint = freezed,Object? mode = freezed,Object? fan = freezed,}) {
  return _then(ThermostatPatch(
setpoint: freezed == setpoint ? _self.setpoint : setpoint // ignore: cast_nullable_to_non_nullable
as double?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ThermostatMode?,fan: freezed == fan ? _self.fan : fan // ignore: cast_nullable_to_non_nullable
as FanMode?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LockPatch extends CapabilityPatch {
  const LockPatch({required this.locked,  String? $type}): $type = $type ?? 'lock',super._();
  factory LockPatch.fromJson(Map<String, dynamic> json) => _$LockPatchFromJson(json);

 final  bool locked;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockPatchCopyWith<LockPatch> get copyWith => _$LockPatchCopyWithImpl<LockPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LockPatch&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locked);
}

@override
String toString() {
    return 'CapabilityPatch.lock(locked: $locked)';
}


}

/// @nodoc
abstract mixin class $LockPatchCopyWith<$Res> implements $CapabilityPatchCopyWith<$Res> {
  factory $LockPatchCopyWith(LockPatch value, $Res Function(LockPatch) _then) = _$LockPatchCopyWithImpl;
@useResult
$Res call({
 bool locked
});




}
/// @nodoc
class _$LockPatchCopyWithImpl<$Res>
    implements $LockPatchCopyWith<$Res> {
  _$LockPatchCopyWithImpl(this._self, this._then);

  final LockPatch _self;
  final $Res Function(LockPatch) _then;

/// Create a copy of CapabilityPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locked = null,}) {
  return _then(LockPatch(
locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
