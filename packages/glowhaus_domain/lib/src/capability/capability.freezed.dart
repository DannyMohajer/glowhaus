// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Capability {

 String get id;@JsonKey(unknownEnumValue: CapabilityKind.unknown) CapabilityKind get kind; String? get label; Map<String, dynamic> get config;
/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapabilityCopyWith<Capability> get copyWith => _$CapabilityCopyWithImpl<Capability>(this as Capability, _$identity);

  /// Serializes this Capability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Capability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Capability&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.label, _this.label) || other.label == _this.label)&&const DeepCollectionEquality().equals(other.config, _this.config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Capability;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.label,const DeepCollectionEquality().hash(_this.config));
}

@override
String toString() {
  final _this = this as Capability;
  return 'Capability(id: ${_this.id}, kind: ${_this.kind}, label: ${_this.label}, config: ${_this.config})';
}


}

/// @nodoc
abstract mixin class $CapabilityCopyWith<$Res>  {
  factory $CapabilityCopyWith(Capability value, $Res Function(Capability) _then) = _$CapabilityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: CapabilityKind.unknown) CapabilityKind kind, String? label, Map<String, dynamic> config
});




}
/// @nodoc
class _$CapabilityCopyWithImpl<$Res>
    implements $CapabilityCopyWith<$Res> {
  _$CapabilityCopyWithImpl(this._self, this._then);

  final Capability _self;
  final $Res Function(Capability) _then;

/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? label = freezed,Object? config = null,}) {
  return _then(Capability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CapabilityKind,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Capability].
extension CapabilityPatterns on Capability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Capability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Capability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Capability value)  $default,){
final _that = this;
switch (_that) {
case _Capability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Capability value)?  $default,){
final _that = this;
switch (_that) {
case _Capability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: CapabilityKind.unknown)  CapabilityKind kind,  String? label,  Map<String, dynamic> config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Capability() when $default != null:
return $default(_that.id,_that.kind,_that.label,_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: CapabilityKind.unknown)  CapabilityKind kind,  String? label,  Map<String, dynamic> config)  $default,) {final _that = this;
switch (_that) {
case _Capability():
return $default(_that.id,_that.kind,_that.label,_that.config);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: CapabilityKind.unknown)  CapabilityKind kind,  String? label,  Map<String, dynamic> config)?  $default,) {final _that = this;
switch (_that) {
case _Capability() when $default != null:
return $default(_that.id,_that.kind,_that.label,_that.config);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Capability extends Capability {
  const _Capability({required this.id, @JsonKey(unknownEnumValue: CapabilityKind.unknown) required this.kind, this.label,  Map<String, dynamic> config = const <String, dynamic>{}}): _config = config,super._();
  factory _Capability.fromJson(Map<String, dynamic> json) => _$CapabilityFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: CapabilityKind.unknown) final  CapabilityKind kind;
@override final  String? label;
 final  Map<String, dynamic> _config;
@override@JsonKey() Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}


/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapabilityCopyWith<_Capability> get copyWith => __$CapabilityCopyWithImpl<_Capability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapabilityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Capability&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.config, _config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,label,const DeepCollectionEquality().hash(_config));
}

@override
String toString() {
    return 'Capability(id: $id, kind: $kind, label: $label, config: $config)';
}


}

/// @nodoc
abstract mixin class _$CapabilityCopyWith<$Res> implements $CapabilityCopyWith<$Res> {
  factory _$CapabilityCopyWith(_Capability value, $Res Function(_Capability) _then) = __$CapabilityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: CapabilityKind.unknown) CapabilityKind kind, String? label, Map<String, dynamic> config
});




}
/// @nodoc
class __$CapabilityCopyWithImpl<$Res>
    implements _$CapabilityCopyWith<$Res> {
  __$CapabilityCopyWithImpl(this._self, this._then);

  final _Capability _self;
  final $Res Function(_Capability) _then;

/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? label = freezed,Object? config = null,}) {
  return _then(_Capability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CapabilityKind,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$ThermostatConfig {

 double get minSetpoint; double get maxSetpoint; double get step; List<ThermostatMode> get modes; List<FanMode> get fanModes;
/// Create a copy of ThermostatConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThermostatConfigCopyWith<ThermostatConfig> get copyWith => _$ThermostatConfigCopyWithImpl<ThermostatConfig>(this as ThermostatConfig, _$identity);

  /// Serializes this ThermostatConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThermostatConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThermostatConfig&&(identical(other.minSetpoint, _this.minSetpoint) || other.minSetpoint == _this.minSetpoint)&&(identical(other.maxSetpoint, _this.maxSetpoint) || other.maxSetpoint == _this.maxSetpoint)&&(identical(other.step, _this.step) || other.step == _this.step)&&const DeepCollectionEquality().equals(other.modes, _this.modes)&&const DeepCollectionEquality().equals(other.fanModes, _this.fanModes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThermostatConfig;
  return Object.hash(runtimeType,_this.minSetpoint,_this.maxSetpoint,_this.step,const DeepCollectionEquality().hash(_this.modes),const DeepCollectionEquality().hash(_this.fanModes));
}

@override
String toString() {
  final _this = this as ThermostatConfig;
  return 'ThermostatConfig(minSetpoint: ${_this.minSetpoint}, maxSetpoint: ${_this.maxSetpoint}, step: ${_this.step}, modes: ${_this.modes}, fanModes: ${_this.fanModes})';
}


}

/// @nodoc
abstract mixin class $ThermostatConfigCopyWith<$Res>  {
  factory $ThermostatConfigCopyWith(ThermostatConfig value, $Res Function(ThermostatConfig) _then) = _$ThermostatConfigCopyWithImpl;
@useResult
$Res call({
 double minSetpoint, double maxSetpoint, double step, List<ThermostatMode> modes, List<FanMode> fanModes
});




}
/// @nodoc
class _$ThermostatConfigCopyWithImpl<$Res>
    implements $ThermostatConfigCopyWith<$Res> {
  _$ThermostatConfigCopyWithImpl(this._self, this._then);

  final ThermostatConfig _self;
  final $Res Function(ThermostatConfig) _then;

/// Create a copy of ThermostatConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minSetpoint = null,Object? maxSetpoint = null,Object? step = null,Object? modes = null,Object? fanModes = null,}) {
  return _then(ThermostatConfig(
minSetpoint: null == minSetpoint ? _self.minSetpoint : minSetpoint // ignore: cast_nullable_to_non_nullable
as double,maxSetpoint: null == maxSetpoint ? _self.maxSetpoint : maxSetpoint // ignore: cast_nullable_to_non_nullable
as double,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as double,modes: null == modes ? _self.modes : modes // ignore: cast_nullable_to_non_nullable
as List<ThermostatMode>,fanModes: null == fanModes ? _self.fanModes : fanModes // ignore: cast_nullable_to_non_nullable
as List<FanMode>,
  ));
}

}


/// Adds pattern-matching-related methods to [ThermostatConfig].
extension ThermostatConfigPatterns on ThermostatConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThermostatConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThermostatConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThermostatConfig value)  $default,){
final _that = this;
switch (_that) {
case _ThermostatConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThermostatConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ThermostatConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double minSetpoint,  double maxSetpoint,  double step,  List<ThermostatMode> modes,  List<FanMode> fanModes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThermostatConfig() when $default != null:
return $default(_that.minSetpoint,_that.maxSetpoint,_that.step,_that.modes,_that.fanModes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double minSetpoint,  double maxSetpoint,  double step,  List<ThermostatMode> modes,  List<FanMode> fanModes)  $default,) {final _that = this;
switch (_that) {
case _ThermostatConfig():
return $default(_that.minSetpoint,_that.maxSetpoint,_that.step,_that.modes,_that.fanModes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double minSetpoint,  double maxSetpoint,  double step,  List<ThermostatMode> modes,  List<FanMode> fanModes)?  $default,) {final _that = this;
switch (_that) {
case _ThermostatConfig() when $default != null:
return $default(_that.minSetpoint,_that.maxSetpoint,_that.step,_that.modes,_that.fanModes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThermostatConfig implements ThermostatConfig {
  const _ThermostatConfig({required this.minSetpoint, required this.maxSetpoint, required this.step, required  List<ThermostatMode> modes,  List<FanMode> fanModes = const <FanMode>[]}): _modes = modes,_fanModes = fanModes;
  factory _ThermostatConfig.fromJson(Map<String, dynamic> json) => _$ThermostatConfigFromJson(json);

@override final  double minSetpoint;
@override final  double maxSetpoint;
@override final  double step;
 final  List<ThermostatMode> _modes;
@override List<ThermostatMode> get modes {
  if (_modes is EqualUnmodifiableListView) return _modes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modes);
}

 final  List<FanMode> _fanModes;
@override@JsonKey() List<FanMode> get fanModes {
  if (_fanModes is EqualUnmodifiableListView) return _fanModes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fanModes);
}


/// Create a copy of ThermostatConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThermostatConfigCopyWith<_ThermostatConfig> get copyWith => __$ThermostatConfigCopyWithImpl<_ThermostatConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThermostatConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThermostatConfig&&(identical(other.minSetpoint, minSetpoint) || other.minSetpoint == minSetpoint)&&(identical(other.maxSetpoint, maxSetpoint) || other.maxSetpoint == maxSetpoint)&&(identical(other.step, step) || other.step == step)&&const DeepCollectionEquality().equals(other.modes, _modes)&&const DeepCollectionEquality().equals(other.fanModes, _fanModes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minSetpoint,maxSetpoint,step,const DeepCollectionEquality().hash(_modes),const DeepCollectionEquality().hash(_fanModes));
}

@override
String toString() {
    return 'ThermostatConfig(minSetpoint: $minSetpoint, maxSetpoint: $maxSetpoint, step: $step, modes: $modes, fanModes: $fanModes)';
}


}

/// @nodoc
abstract mixin class _$ThermostatConfigCopyWith<$Res> implements $ThermostatConfigCopyWith<$Res> {
  factory _$ThermostatConfigCopyWith(_ThermostatConfig value, $Res Function(_ThermostatConfig) _then) = __$ThermostatConfigCopyWithImpl;
@override @useResult
$Res call({
 double minSetpoint, double maxSetpoint, double step, List<ThermostatMode> modes, List<FanMode> fanModes
});




}
/// @nodoc
class __$ThermostatConfigCopyWithImpl<$Res>
    implements _$ThermostatConfigCopyWith<$Res> {
  __$ThermostatConfigCopyWithImpl(this._self, this._then);

  final _ThermostatConfig _self;
  final $Res Function(_ThermostatConfig) _then;

/// Create a copy of ThermostatConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minSetpoint = null,Object? maxSetpoint = null,Object? step = null,Object? modes = null,Object? fanModes = null,}) {
  return _then(_ThermostatConfig(
minSetpoint: null == minSetpoint ? _self.minSetpoint : minSetpoint // ignore: cast_nullable_to_non_nullable
as double,maxSetpoint: null == maxSetpoint ? _self.maxSetpoint : maxSetpoint // ignore: cast_nullable_to_non_nullable
as double,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as double,modes: null == modes ? _self._modes : modes // ignore: cast_nullable_to_non_nullable
as List<ThermostatMode>,fanModes: null == fanModes ? _self._fanModes : fanModes // ignore: cast_nullable_to_non_nullable
as List<FanMode>,
  ));
}


}


/// @nodoc
mixin _$ColorTemperatureConfig {

 int get minKelvin; int get maxKelvin;
/// Create a copy of ColorTemperatureConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorTemperatureConfigCopyWith<ColorTemperatureConfig> get copyWith => _$ColorTemperatureConfigCopyWithImpl<ColorTemperatureConfig>(this as ColorTemperatureConfig, _$identity);

  /// Serializes this ColorTemperatureConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ColorTemperatureConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorTemperatureConfig&&(identical(other.minKelvin, _this.minKelvin) || other.minKelvin == _this.minKelvin)&&(identical(other.maxKelvin, _this.maxKelvin) || other.maxKelvin == _this.maxKelvin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ColorTemperatureConfig;
  return Object.hash(runtimeType,_this.minKelvin,_this.maxKelvin);
}

@override
String toString() {
  final _this = this as ColorTemperatureConfig;
  return 'ColorTemperatureConfig(minKelvin: ${_this.minKelvin}, maxKelvin: ${_this.maxKelvin})';
}


}

/// @nodoc
abstract mixin class $ColorTemperatureConfigCopyWith<$Res>  {
  factory $ColorTemperatureConfigCopyWith(ColorTemperatureConfig value, $Res Function(ColorTemperatureConfig) _then) = _$ColorTemperatureConfigCopyWithImpl;
@useResult
$Res call({
 int minKelvin, int maxKelvin
});




}
/// @nodoc
class _$ColorTemperatureConfigCopyWithImpl<$Res>
    implements $ColorTemperatureConfigCopyWith<$Res> {
  _$ColorTemperatureConfigCopyWithImpl(this._self, this._then);

  final ColorTemperatureConfig _self;
  final $Res Function(ColorTemperatureConfig) _then;

/// Create a copy of ColorTemperatureConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minKelvin = null,Object? maxKelvin = null,}) {
  return _then(ColorTemperatureConfig(
minKelvin: null == minKelvin ? _self.minKelvin : minKelvin // ignore: cast_nullable_to_non_nullable
as int,maxKelvin: null == maxKelvin ? _self.maxKelvin : maxKelvin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorTemperatureConfig].
extension ColorTemperatureConfigPatterns on ColorTemperatureConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorTemperatureConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorTemperatureConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorTemperatureConfig value)  $default,){
final _that = this;
switch (_that) {
case _ColorTemperatureConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorTemperatureConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ColorTemperatureConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minKelvin,  int maxKelvin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorTemperatureConfig() when $default != null:
return $default(_that.minKelvin,_that.maxKelvin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minKelvin,  int maxKelvin)  $default,) {final _that = this;
switch (_that) {
case _ColorTemperatureConfig():
return $default(_that.minKelvin,_that.maxKelvin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minKelvin,  int maxKelvin)?  $default,) {final _that = this;
switch (_that) {
case _ColorTemperatureConfig() when $default != null:
return $default(_that.minKelvin,_that.maxKelvin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ColorTemperatureConfig implements ColorTemperatureConfig {
  const _ColorTemperatureConfig({required this.minKelvin, required this.maxKelvin});
  factory _ColorTemperatureConfig.fromJson(Map<String, dynamic> json) => _$ColorTemperatureConfigFromJson(json);

@override final  int minKelvin;
@override final  int maxKelvin;

/// Create a copy of ColorTemperatureConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorTemperatureConfigCopyWith<_ColorTemperatureConfig> get copyWith => __$ColorTemperatureConfigCopyWithImpl<_ColorTemperatureConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorTemperatureConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorTemperatureConfig&&(identical(other.minKelvin, minKelvin) || other.minKelvin == minKelvin)&&(identical(other.maxKelvin, maxKelvin) || other.maxKelvin == maxKelvin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minKelvin,maxKelvin);
}

@override
String toString() {
    return 'ColorTemperatureConfig(minKelvin: $minKelvin, maxKelvin: $maxKelvin)';
}


}

/// @nodoc
abstract mixin class _$ColorTemperatureConfigCopyWith<$Res> implements $ColorTemperatureConfigCopyWith<$Res> {
  factory _$ColorTemperatureConfigCopyWith(_ColorTemperatureConfig value, $Res Function(_ColorTemperatureConfig) _then) = __$ColorTemperatureConfigCopyWithImpl;
@override @useResult
$Res call({
 int minKelvin, int maxKelvin
});




}
/// @nodoc
class __$ColorTemperatureConfigCopyWithImpl<$Res>
    implements _$ColorTemperatureConfigCopyWith<$Res> {
  __$ColorTemperatureConfigCopyWithImpl(this._self, this._then);

  final _ColorTemperatureConfig _self;
  final $Res Function(_ColorTemperatureConfig) _then;

/// Create a copy of ColorTemperatureConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minKelvin = null,Object? maxKelvin = null,}) {
  return _then(_ColorTemperatureConfig(
minKelvin: null == minKelvin ? _self.minKelvin : minKelvin // ignore: cast_nullable_to_non_nullable
as int,maxKelvin: null == maxKelvin ? _self.maxKelvin : maxKelvin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CameraConfig {

 List<CameraStream> get streams; String? get snapshotUrl;
/// Create a copy of CameraConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraConfigCopyWith<CameraConfig> get copyWith => _$CameraConfigCopyWithImpl<CameraConfig>(this as CameraConfig, _$identity);

  /// Serializes this CameraConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CameraConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraConfig&&const DeepCollectionEquality().equals(other.streams, _this.streams)&&(identical(other.snapshotUrl, _this.snapshotUrl) || other.snapshotUrl == _this.snapshotUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CameraConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.streams),_this.snapshotUrl);
}

@override
String toString() {
  final _this = this as CameraConfig;
  return 'CameraConfig(streams: ${_this.streams}, snapshotUrl: ${_this.snapshotUrl})';
}


}

/// @nodoc
abstract mixin class $CameraConfigCopyWith<$Res>  {
  factory $CameraConfigCopyWith(CameraConfig value, $Res Function(CameraConfig) _then) = _$CameraConfigCopyWithImpl;
@useResult
$Res call({
 List<CameraStream> streams, String? snapshotUrl
});




}
/// @nodoc
class _$CameraConfigCopyWithImpl<$Res>
    implements $CameraConfigCopyWith<$Res> {
  _$CameraConfigCopyWithImpl(this._self, this._then);

  final CameraConfig _self;
  final $Res Function(CameraConfig) _then;

/// Create a copy of CameraConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? streams = null,Object? snapshotUrl = freezed,}) {
  return _then(CameraConfig(
streams: null == streams ? _self.streams : streams // ignore: cast_nullable_to_non_nullable
as List<CameraStream>,snapshotUrl: freezed == snapshotUrl ? _self.snapshotUrl : snapshotUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraConfig].
extension CameraConfigPatterns on CameraConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraConfig value)  $default,){
final _that = this;
switch (_that) {
case _CameraConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CameraConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CameraStream> streams,  String? snapshotUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraConfig() when $default != null:
return $default(_that.streams,_that.snapshotUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CameraStream> streams,  String? snapshotUrl)  $default,) {final _that = this;
switch (_that) {
case _CameraConfig():
return $default(_that.streams,_that.snapshotUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CameraStream> streams,  String? snapshotUrl)?  $default,) {final _that = this;
switch (_that) {
case _CameraConfig() when $default != null:
return $default(_that.streams,_that.snapshotUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CameraConfig implements CameraConfig {
  const _CameraConfig({ List<CameraStream> streams = const <CameraStream>[], this.snapshotUrl}): _streams = streams;
  factory _CameraConfig.fromJson(Map<String, dynamic> json) => _$CameraConfigFromJson(json);

 final  List<CameraStream> _streams;
@override@JsonKey() List<CameraStream> get streams {
  if (_streams is EqualUnmodifiableListView) return _streams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_streams);
}

@override final  String? snapshotUrl;

/// Create a copy of CameraConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraConfigCopyWith<_CameraConfig> get copyWith => __$CameraConfigCopyWithImpl<_CameraConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CameraConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraConfig&&const DeepCollectionEquality().equals(other.streams, _streams)&&(identical(other.snapshotUrl, snapshotUrl) || other.snapshotUrl == snapshotUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_streams),snapshotUrl);
}

@override
String toString() {
    return 'CameraConfig(streams: $streams, snapshotUrl: $snapshotUrl)';
}


}

/// @nodoc
abstract mixin class _$CameraConfigCopyWith<$Res> implements $CameraConfigCopyWith<$Res> {
  factory _$CameraConfigCopyWith(_CameraConfig value, $Res Function(_CameraConfig) _then) = __$CameraConfigCopyWithImpl;
@override @useResult
$Res call({
 List<CameraStream> streams, String? snapshotUrl
});




}
/// @nodoc
class __$CameraConfigCopyWithImpl<$Res>
    implements _$CameraConfigCopyWith<$Res> {
  __$CameraConfigCopyWithImpl(this._self, this._then);

  final _CameraConfig _self;
  final $Res Function(_CameraConfig) _then;

/// Create a copy of CameraConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? streams = null,Object? snapshotUrl = freezed,}) {
  return _then(_CameraConfig(
streams: null == streams ? _self._streams : streams // ignore: cast_nullable_to_non_nullable
as List<CameraStream>,snapshotUrl: freezed == snapshotUrl ? _self.snapshotUrl : snapshotUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CameraStream {

 String get protocol; String get url;
/// Create a copy of CameraStream
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraStreamCopyWith<CameraStream> get copyWith => _$CameraStreamCopyWithImpl<CameraStream>(this as CameraStream, _$identity);

  /// Serializes this CameraStream to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CameraStream;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraStream&&(identical(other.protocol, _this.protocol) || other.protocol == _this.protocol)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CameraStream;
  return Object.hash(runtimeType,_this.protocol,_this.url);
}

@override
String toString() {
  final _this = this as CameraStream;
  return 'CameraStream(protocol: ${_this.protocol}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $CameraStreamCopyWith<$Res>  {
  factory $CameraStreamCopyWith(CameraStream value, $Res Function(CameraStream) _then) = _$CameraStreamCopyWithImpl;
@useResult
$Res call({
 String protocol, String url
});




}
/// @nodoc
class _$CameraStreamCopyWithImpl<$Res>
    implements $CameraStreamCopyWith<$Res> {
  _$CameraStreamCopyWithImpl(this._self, this._then);

  final CameraStream _self;
  final $Res Function(CameraStream) _then;

/// Create a copy of CameraStream
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? protocol = null,Object? url = null,}) {
  return _then(CameraStream(
protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraStream].
extension CameraStreamPatterns on CameraStream {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraStream value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraStream() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraStream value)  $default,){
final _that = this;
switch (_that) {
case _CameraStream():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraStream value)?  $default,){
final _that = this;
switch (_that) {
case _CameraStream() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String protocol,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraStream() when $default != null:
return $default(_that.protocol,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String protocol,  String url)  $default,) {final _that = this;
switch (_that) {
case _CameraStream():
return $default(_that.protocol,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String protocol,  String url)?  $default,) {final _that = this;
switch (_that) {
case _CameraStream() when $default != null:
return $default(_that.protocol,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CameraStream implements CameraStream {
  const _CameraStream({required this.protocol, required this.url});
  factory _CameraStream.fromJson(Map<String, dynamic> json) => _$CameraStreamFromJson(json);

@override final  String protocol;
@override final  String url;

/// Create a copy of CameraStream
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraStreamCopyWith<_CameraStream> get copyWith => __$CameraStreamCopyWithImpl<_CameraStream>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CameraStreamToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraStream&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,protocol,url);
}

@override
String toString() {
    return 'CameraStream(protocol: $protocol, url: $url)';
}


}

/// @nodoc
abstract mixin class _$CameraStreamCopyWith<$Res> implements $CameraStreamCopyWith<$Res> {
  factory _$CameraStreamCopyWith(_CameraStream value, $Res Function(_CameraStream) _then) = __$CameraStreamCopyWithImpl;
@override @useResult
$Res call({
 String protocol, String url
});




}
/// @nodoc
class __$CameraStreamCopyWithImpl<$Res>
    implements _$CameraStreamCopyWith<$Res> {
  __$CameraStreamCopyWithImpl(this._self, this._then);

  final _CameraStream _self;
  final $Res Function(_CameraStream) _then;

/// Create a copy of CameraStream
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? protocol = null,Object? url = null,}) {
  return _then(_CameraStream(
protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
