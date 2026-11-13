// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BrokerSettings {

 String get host;/// Null means the default for the transport: 8884 for WSS, 8883 for
/// TLS, 1883 for plain MQTT.
 int? get port; bool get tls;/// MQTT over WebSocket. Always on in a browser, which can only open
/// WebSockets.
 bool get webSocket; String get path; String get homeId; String get username;/// An extra CA to trust, in PEM, for a development broker whose CA the
/// platform does not know (Android ignores user-installed CAs). Native
/// only.
 String? get trustedCertificatePem;
/// Create a copy of BrokerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrokerSettingsCopyWith<BrokerSettings> get copyWith => _$BrokerSettingsCopyWithImpl<BrokerSettings>(this as BrokerSettings, _$identity);

  /// Serializes this BrokerSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BrokerSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrokerSettings&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.tls, _this.tls) || other.tls == _this.tls)&&(identical(other.webSocket, _this.webSocket) || other.webSocket == _this.webSocket)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.homeId, _this.homeId) || other.homeId == _this.homeId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.trustedCertificatePem, _this.trustedCertificatePem) || other.trustedCertificatePem == _this.trustedCertificatePem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BrokerSettings;
  return Object.hash(runtimeType,_this.host,_this.port,_this.tls,_this.webSocket,_this.path,_this.homeId,_this.username,_this.trustedCertificatePem);
}

@override
String toString() {
  final _this = this as BrokerSettings;
  return 'BrokerSettings(host: ${_this.host}, port: ${_this.port}, tls: ${_this.tls}, webSocket: ${_this.webSocket}, path: ${_this.path}, homeId: ${_this.homeId}, username: ${_this.username}, trustedCertificatePem: ${_this.trustedCertificatePem})';
}


}

/// @nodoc
abstract mixin class $BrokerSettingsCopyWith<$Res>  {
  factory $BrokerSettingsCopyWith(BrokerSettings value, $Res Function(BrokerSettings) _then) = _$BrokerSettingsCopyWithImpl;
@useResult
$Res call({
 String host, int? port, bool tls, bool webSocket, String path, String homeId, String username, String? trustedCertificatePem
});




}
/// @nodoc
class _$BrokerSettingsCopyWithImpl<$Res>
    implements $BrokerSettingsCopyWith<$Res> {
  _$BrokerSettingsCopyWithImpl(this._self, this._then);

  final BrokerSettings _self;
  final $Res Function(BrokerSettings) _then;

/// Create a copy of BrokerSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? port = freezed,Object? tls = null,Object? webSocket = null,Object? path = null,Object? homeId = null,Object? username = null,Object? trustedCertificatePem = freezed,}) {
  return _then(BrokerSettings(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,tls: null == tls ? _self.tls : tls // ignore: cast_nullable_to_non_nullable
as bool,webSocket: null == webSocket ? _self.webSocket : webSocket // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,trustedCertificatePem: freezed == trustedCertificatePem ? _self.trustedCertificatePem : trustedCertificatePem // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BrokerSettings].
extension BrokerSettingsPatterns on BrokerSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrokerSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrokerSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrokerSettings value)  $default,){
final _that = this;
switch (_that) {
case _BrokerSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrokerSettings value)?  $default,){
final _that = this;
switch (_that) {
case _BrokerSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  int? port,  bool tls,  bool webSocket,  String path,  String homeId,  String username,  String? trustedCertificatePem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrokerSettings() when $default != null:
return $default(_that.host,_that.port,_that.tls,_that.webSocket,_that.path,_that.homeId,_that.username,_that.trustedCertificatePem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  int? port,  bool tls,  bool webSocket,  String path,  String homeId,  String username,  String? trustedCertificatePem)  $default,) {final _that = this;
switch (_that) {
case _BrokerSettings():
return $default(_that.host,_that.port,_that.tls,_that.webSocket,_that.path,_that.homeId,_that.username,_that.trustedCertificatePem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  int? port,  bool tls,  bool webSocket,  String path,  String homeId,  String username,  String? trustedCertificatePem)?  $default,) {final _that = this;
switch (_that) {
case _BrokerSettings() when $default != null:
return $default(_that.host,_that.port,_that.tls,_that.webSocket,_that.path,_that.homeId,_that.username,_that.trustedCertificatePem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrokerSettings extends BrokerSettings {
  const _BrokerSettings({this.host = 'localhost', this.port, this.tls = true, this.webSocket = false, this.path = '/mqtt', this.homeId = DemoHome.homeId, this.username = '${DemoHome.homeId}.app', this.trustedCertificatePem}): super._();
  factory _BrokerSettings.fromJson(Map<String, dynamic> json) => _$BrokerSettingsFromJson(json);

@override@JsonKey() final  String host;
/// Null means the default for the transport: 8884 for WSS, 8883 for
/// TLS, 1883 for plain MQTT.
@override final  int? port;
@override@JsonKey() final  bool tls;
/// MQTT over WebSocket. Always on in a browser, which can only open
/// WebSockets.
@override@JsonKey() final  bool webSocket;
@override@JsonKey() final  String path;
@override@JsonKey() final  String homeId;
@override@JsonKey() final  String username;
/// An extra CA to trust, in PEM, for a development broker whose CA the
/// platform does not know (Android ignores user-installed CAs). Native
/// only.
@override final  String? trustedCertificatePem;

/// Create a copy of BrokerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrokerSettingsCopyWith<_BrokerSettings> get copyWith => __$BrokerSettingsCopyWithImpl<_BrokerSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrokerSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrokerSettings&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.tls, tls) || other.tls == tls)&&(identical(other.webSocket, webSocket) || other.webSocket == webSocket)&&(identical(other.path, path) || other.path == path)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.username, username) || other.username == username)&&(identical(other.trustedCertificatePem, trustedCertificatePem) || other.trustedCertificatePem == trustedCertificatePem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,host,port,tls,webSocket,path,homeId,username,trustedCertificatePem);
}

@override
String toString() {
    return 'BrokerSettings(host: $host, port: $port, tls: $tls, webSocket: $webSocket, path: $path, homeId: $homeId, username: $username, trustedCertificatePem: $trustedCertificatePem)';
}


}

/// @nodoc
abstract mixin class _$BrokerSettingsCopyWith<$Res> implements $BrokerSettingsCopyWith<$Res> {
  factory _$BrokerSettingsCopyWith(_BrokerSettings value, $Res Function(_BrokerSettings) _then) = __$BrokerSettingsCopyWithImpl;
@override @useResult
$Res call({
 String host, int? port, bool tls, bool webSocket, String path, String homeId, String username, String? trustedCertificatePem
});




}
/// @nodoc
class __$BrokerSettingsCopyWithImpl<$Res>
    implements _$BrokerSettingsCopyWith<$Res> {
  __$BrokerSettingsCopyWithImpl(this._self, this._then);

  final _BrokerSettings _self;
  final $Res Function(_BrokerSettings) _then;

/// Create a copy of BrokerSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? port = freezed,Object? tls = null,Object? webSocket = null,Object? path = null,Object? homeId = null,Object? username = null,Object? trustedCertificatePem = freezed,}) {
  return _then(_BrokerSettings(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,tls: null == tls ? _self.tls : tls // ignore: cast_nullable_to_non_nullable
as bool,webSocket: null == webSocket ? _self.webSocket : webSocket // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,trustedCertificatePem: freezed == trustedCertificatePem ? _self.trustedCertificatePem : trustedCertificatePem // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConnectionSettings {

 ConnectionMode get mode; BrokerSettings get broker;
/// Create a copy of ConnectionSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionSettingsCopyWith<ConnectionSettings> get copyWith => _$ConnectionSettingsCopyWithImpl<ConnectionSettings>(this as ConnectionSettings, _$identity);

  /// Serializes this ConnectionSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConnectionSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionSettings&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.broker, _this.broker) || other.broker == _this.broker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConnectionSettings;
  return Object.hash(runtimeType,_this.mode,_this.broker);
}

@override
String toString() {
  final _this = this as ConnectionSettings;
  return 'ConnectionSettings(mode: ${_this.mode}, broker: ${_this.broker})';
}


}

/// @nodoc
abstract mixin class $ConnectionSettingsCopyWith<$Res>  {
  factory $ConnectionSettingsCopyWith(ConnectionSettings value, $Res Function(ConnectionSettings) _then) = _$ConnectionSettingsCopyWithImpl;
@useResult
$Res call({
 ConnectionMode mode, BrokerSettings broker
});


$BrokerSettingsCopyWith<$Res> get broker;

}
/// @nodoc
class _$ConnectionSettingsCopyWithImpl<$Res>
    implements $ConnectionSettingsCopyWith<$Res> {
  _$ConnectionSettingsCopyWithImpl(this._self, this._then);

  final ConnectionSettings _self;
  final $Res Function(ConnectionSettings) _then;

/// Create a copy of ConnectionSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? broker = null,}) {
  return _then(ConnectionSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ConnectionMode,broker: null == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as BrokerSettings,
  ));
}
/// Create a copy of ConnectionSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrokerSettingsCopyWith<$Res> get broker {
  
  return $BrokerSettingsCopyWith<$Res>(_self.broker, (value) {
    return _then(_self.copyWith(broker: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionSettings].
extension ConnectionSettingsPatterns on ConnectionSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionSettings value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConnectionMode mode,  BrokerSettings broker)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionSettings() when $default != null:
return $default(_that.mode,_that.broker);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConnectionMode mode,  BrokerSettings broker)  $default,) {final _that = this;
switch (_that) {
case _ConnectionSettings():
return $default(_that.mode,_that.broker);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConnectionMode mode,  BrokerSettings broker)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionSettings() when $default != null:
return $default(_that.mode,_that.broker);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionSettings implements ConnectionSettings {
  const _ConnectionSettings({this.mode = ConnectionMode.demo, this.broker = const BrokerSettings()});
  factory _ConnectionSettings.fromJson(Map<String, dynamic> json) => _$ConnectionSettingsFromJson(json);

@override@JsonKey() final  ConnectionMode mode;
@override@JsonKey() final  BrokerSettings broker;

/// Create a copy of ConnectionSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionSettingsCopyWith<_ConnectionSettings> get copyWith => __$ConnectionSettingsCopyWithImpl<_ConnectionSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.broker, broker) || other.broker == broker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mode,broker);
}

@override
String toString() {
    return 'ConnectionSettings(mode: $mode, broker: $broker)';
}


}

/// @nodoc
abstract mixin class _$ConnectionSettingsCopyWith<$Res> implements $ConnectionSettingsCopyWith<$Res> {
  factory _$ConnectionSettingsCopyWith(_ConnectionSettings value, $Res Function(_ConnectionSettings) _then) = __$ConnectionSettingsCopyWithImpl;
@override @useResult
$Res call({
 ConnectionMode mode, BrokerSettings broker
});


@override $BrokerSettingsCopyWith<$Res> get broker;

}
/// @nodoc
class __$ConnectionSettingsCopyWithImpl<$Res>
    implements _$ConnectionSettingsCopyWith<$Res> {
  __$ConnectionSettingsCopyWithImpl(this._self, this._then);

  final _ConnectionSettings _self;
  final $Res Function(_ConnectionSettings) _then;

/// Create a copy of ConnectionSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? broker = null,}) {
  return _then(_ConnectionSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ConnectionMode,broker: null == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as BrokerSettings,
  ));
}

/// Create a copy of ConnectionSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrokerSettingsCopyWith<$Res> get broker {
  
  return $BrokerSettingsCopyWith<$Res>(_self.broker, (value) {
    return _then(_self.copyWith(broker: value));
  });
}
}

// dart format on
