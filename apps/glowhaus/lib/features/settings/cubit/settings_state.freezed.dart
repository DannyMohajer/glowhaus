// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsState {

 AppLanguage get language; ThemeMode get themeMode; AccentChoice get accent; bool get reduceMotion; int get latencyMs; double get failureRate;/// Native only: show the welcome screen at the next launch.
 bool get showWelcome;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);

  /// Serializes this SettingsState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.reduceMotion, _this.reduceMotion) || other.reduceMotion == _this.reduceMotion)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&(identical(other.failureRate, _this.failureRate) || other.failureRate == _this.failureRate)&&(identical(other.showWelcome, _this.showWelcome) || other.showWelcome == _this.showWelcome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SettingsState;
  return Object.hash(runtimeType,_this.language,_this.themeMode,_this.accent,_this.reduceMotion,_this.latencyMs,_this.failureRate,_this.showWelcome);
}

@override
String toString() {
  final _this = this as SettingsState;
  return 'SettingsState(language: ${_this.language}, themeMode: ${_this.themeMode}, accent: ${_this.accent}, reduceMotion: ${_this.reduceMotion}, latencyMs: ${_this.latencyMs}, failureRate: ${_this.failureRate}, showWelcome: ${_this.showWelcome})';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 AppLanguage language, ThemeMode themeMode, AccentChoice accent, bool reduceMotion, int latencyMs, double failureRate, bool showWelcome
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? themeMode = null,Object? accent = null,Object? reduceMotion = null,Object? latencyMs = null,Object? failureRate = null,Object? showWelcome = null,}) {
  return _then(SettingsState(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as AccentChoice,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,failureRate: null == failureRate ? _self.failureRate : failureRate // ignore: cast_nullable_to_non_nullable
as double,showWelcome: null == showWelcome ? _self.showWelcome : showWelcome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppLanguage language,  ThemeMode themeMode,  AccentChoice accent,  bool reduceMotion,  int latencyMs,  double failureRate,  bool showWelcome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.language,_that.themeMode,_that.accent,_that.reduceMotion,_that.latencyMs,_that.failureRate,_that.showWelcome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppLanguage language,  ThemeMode themeMode,  AccentChoice accent,  bool reduceMotion,  int latencyMs,  double failureRate,  bool showWelcome)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.language,_that.themeMode,_that.accent,_that.reduceMotion,_that.latencyMs,_that.failureRate,_that.showWelcome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppLanguage language,  ThemeMode themeMode,  AccentChoice accent,  bool reduceMotion,  int latencyMs,  double failureRate,  bool showWelcome)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.language,_that.themeMode,_that.accent,_that.reduceMotion,_that.latencyMs,_that.failureRate,_that.showWelcome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SettingsState implements SettingsState {
  const _SettingsState({this.language = AppLanguage.en, this.themeMode = ThemeMode.system, this.accent = AccentChoice.orange, this.reduceMotion = false, this.latencyMs = SettingsState.defaultLatencyMs, this.failureRate = 0, this.showWelcome = true});
  factory _SettingsState.fromJson(Map<String, dynamic> json) => _$SettingsStateFromJson(json);

@override@JsonKey() final  AppLanguage language;
@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  AccentChoice accent;
@override@JsonKey() final  bool reduceMotion;
@override@JsonKey() final  int latencyMs;
@override@JsonKey() final  double failureRate;
/// Native only: show the welcome screen at the next launch.
@override@JsonKey() final  bool showWelcome;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.language, language) || other.language == language)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.failureRate, failureRate) || other.failureRate == failureRate)&&(identical(other.showWelcome, showWelcome) || other.showWelcome == showWelcome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,language,themeMode,accent,reduceMotion,latencyMs,failureRate,showWelcome);
}

@override
String toString() {
    return 'SettingsState(language: $language, themeMode: $themeMode, accent: $accent, reduceMotion: $reduceMotion, latencyMs: $latencyMs, failureRate: $failureRate, showWelcome: $showWelcome)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 AppLanguage language, ThemeMode themeMode, AccentChoice accent, bool reduceMotion, int latencyMs, double failureRate, bool showWelcome
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? themeMode = null,Object? accent = null,Object? reduceMotion = null,Object? latencyMs = null,Object? failureRate = null,Object? showWelcome = null,}) {
  return _then(_SettingsState(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as AccentChoice,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,failureRate: null == failureRate ? _self.failureRate : failureRate // ignore: cast_nullable_to_non_nullable
as double,showWelcome: null == showWelcome ? _self.showWelcome : showWelcome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
