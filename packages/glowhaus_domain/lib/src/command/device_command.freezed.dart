// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceCommand {

 String get id; String get homeId; String get deviceId; DateTime get issuedAt; Map<String, CapabilityPatch> get patches;
/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCommandCopyWith<DeviceCommand> get copyWith => _$DeviceCommandCopyWithImpl<DeviceCommand>(this as DeviceCommand, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceCommand;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceCommand&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.homeId, _this.homeId) || other.homeId == _this.homeId)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.issuedAt, _this.issuedAt) || other.issuedAt == _this.issuedAt)&&const DeepCollectionEquality().equals(other.patches, _this.patches));
}


@override
int get hashCode {
  final _this = this as DeviceCommand;
  return Object.hash(runtimeType,_this.id,_this.homeId,_this.deviceId,_this.issuedAt,const DeepCollectionEquality().hash(_this.patches));
}

@override
String toString() {
  final _this = this as DeviceCommand;
  return 'DeviceCommand(id: ${_this.id}, homeId: ${_this.homeId}, deviceId: ${_this.deviceId}, issuedAt: ${_this.issuedAt}, patches: ${_this.patches})';
}


}

/// @nodoc
abstract mixin class $DeviceCommandCopyWith<$Res>  {
  factory $DeviceCommandCopyWith(DeviceCommand value, $Res Function(DeviceCommand) _then) = _$DeviceCommandCopyWithImpl;
@useResult
$Res call({
 String id, String homeId, String deviceId, DateTime issuedAt, Map<String, CapabilityPatch> patches
});




}
/// @nodoc
class _$DeviceCommandCopyWithImpl<$Res>
    implements $DeviceCommandCopyWith<$Res> {
  _$DeviceCommandCopyWithImpl(this._self, this._then);

  final DeviceCommand _self;
  final $Res Function(DeviceCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? homeId = null,Object? deviceId = null,Object? issuedAt = null,Object? patches = null,}) {
  return _then(DeviceCommand(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,patches: null == patches ? _self.patches : patches // ignore: cast_nullable_to_non_nullable
as Map<String, CapabilityPatch>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceCommand].
extension DeviceCommandPatterns on DeviceCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceCommand value)  $default,){
final _that = this;
switch (_that) {
case _DeviceCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceCommand value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String homeId,  String deviceId,  DateTime issuedAt,  Map<String, CapabilityPatch> patches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceCommand() when $default != null:
return $default(_that.id,_that.homeId,_that.deviceId,_that.issuedAt,_that.patches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String homeId,  String deviceId,  DateTime issuedAt,  Map<String, CapabilityPatch> patches)  $default,) {final _that = this;
switch (_that) {
case _DeviceCommand():
return $default(_that.id,_that.homeId,_that.deviceId,_that.issuedAt,_that.patches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String homeId,  String deviceId,  DateTime issuedAt,  Map<String, CapabilityPatch> patches)?  $default,) {final _that = this;
switch (_that) {
case _DeviceCommand() when $default != null:
return $default(_that.id,_that.homeId,_that.deviceId,_that.issuedAt,_that.patches);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceCommand extends DeviceCommand {
  const _DeviceCommand({required this.id, required this.homeId, required this.deviceId, required this.issuedAt, required  Map<String, CapabilityPatch> patches}): _patches = patches,super._();
  

@override final  String id;
@override final  String homeId;
@override final  String deviceId;
@override final  DateTime issuedAt;
 final  Map<String, CapabilityPatch> _patches;
@override Map<String, CapabilityPatch> get patches {
  if (_patches is EqualUnmodifiableMapView) return _patches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_patches);
}


/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceCommandCopyWith<_DeviceCommand> get copyWith => __$DeviceCommandCopyWithImpl<_DeviceCommand>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceCommand&&(identical(other.id, id) || other.id == id)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&const DeepCollectionEquality().equals(other.patches, _patches));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,homeId,deviceId,issuedAt,const DeepCollectionEquality().hash(_patches));
}

@override
String toString() {
    return 'DeviceCommand(id: $id, homeId: $homeId, deviceId: $deviceId, issuedAt: $issuedAt, patches: $patches)';
}


}

/// @nodoc
abstract mixin class _$DeviceCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory _$DeviceCommandCopyWith(_DeviceCommand value, $Res Function(_DeviceCommand) _then) = __$DeviceCommandCopyWithImpl;
@override @useResult
$Res call({
 String id, String homeId, String deviceId, DateTime issuedAt, Map<String, CapabilityPatch> patches
});




}
/// @nodoc
class __$DeviceCommandCopyWithImpl<$Res>
    implements _$DeviceCommandCopyWith<$Res> {
  __$DeviceCommandCopyWithImpl(this._self, this._then);

  final _DeviceCommand _self;
  final $Res Function(_DeviceCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? homeId = null,Object? deviceId = null,Object? issuedAt = null,Object? patches = null,}) {
  return _then(_DeviceCommand(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,patches: null == patches ? _self._patches : patches // ignore: cast_nullable_to_non_nullable
as Map<String, CapabilityPatch>,
  ));
}


}

/// @nodoc
mixin _$CommandResult {

 String get commandId;
/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandResultCopyWith<CommandResult> get copyWith => _$CommandResultCopyWithImpl<CommandResult>(this as CommandResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommandResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandResult&&(identical(other.commandId, _this.commandId) || other.commandId == _this.commandId));
}


@override
int get hashCode {
  final _this = this as CommandResult;
  return Object.hash(runtimeType,_this.commandId);
}

@override
String toString() {
  final _this = this as CommandResult;
  return 'CommandResult(commandId: ${_this.commandId})';
}


}

/// @nodoc
abstract mixin class $CommandResultCopyWith<$Res>  {
  factory $CommandResultCopyWith(CommandResult value, $Res Function(CommandResult) _then) = _$CommandResultCopyWithImpl;
@useResult
$Res call({
 String commandId
});




}
/// @nodoc
class _$CommandResultCopyWithImpl<$Res>
    implements $CommandResultCopyWith<$Res> {
  _$CommandResultCopyWithImpl(this._self, this._then);

  final CommandResult _self;
  final $Res Function(CommandResult) _then;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commandId = null,}) {
  return _then(_self.copyWith(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommandResult].
extension CommandResultPatterns on CommandResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CommandAcked value)?  acked,TResult Function( CommandFailed value)?  failed,TResult Function( CommandTimedOut value)?  timedOut,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CommandAcked() when acked != null:
return acked(_that);case CommandFailed() when failed != null:
return failed(_that);case CommandTimedOut() when timedOut != null:
return timedOut(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CommandAcked value)  acked,required TResult Function( CommandFailed value)  failed,required TResult Function( CommandTimedOut value)  timedOut,}){
final _that = this;
switch (_that) {
case CommandAcked():
return acked(_that);case CommandFailed():
return failed(_that);case CommandTimedOut():
return timedOut(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CommandAcked value)?  acked,TResult? Function( CommandFailed value)?  failed,TResult? Function( CommandTimedOut value)?  timedOut,}){
final _that = this;
switch (_that) {
case CommandAcked() when acked != null:
return acked(_that);case CommandFailed() when failed != null:
return failed(_that);case CommandTimedOut() when timedOut != null:
return timedOut(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String commandId)?  acked,TResult Function( String commandId,  ProtocolErrorCode code,  String? message)?  failed,TResult Function( String commandId)?  timedOut,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CommandAcked() when acked != null:
return acked(_that.commandId);case CommandFailed() when failed != null:
return failed(_that.commandId,_that.code,_that.message);case CommandTimedOut() when timedOut != null:
return timedOut(_that.commandId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String commandId)  acked,required TResult Function( String commandId,  ProtocolErrorCode code,  String? message)  failed,required TResult Function( String commandId)  timedOut,}) {final _that = this;
switch (_that) {
case CommandAcked():
return acked(_that.commandId);case CommandFailed():
return failed(_that.commandId,_that.code,_that.message);case CommandTimedOut():
return timedOut(_that.commandId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String commandId)?  acked,TResult? Function( String commandId,  ProtocolErrorCode code,  String? message)?  failed,TResult? Function( String commandId)?  timedOut,}) {final _that = this;
switch (_that) {
case CommandAcked() when acked != null:
return acked(_that.commandId);case CommandFailed() when failed != null:
return failed(_that.commandId,_that.code,_that.message);case CommandTimedOut() when timedOut != null:
return timedOut(_that.commandId);case _:
  return null;

}
}

}

/// @nodoc


class CommandAcked extends CommandResult {
  const CommandAcked({required this.commandId}): super._();
  

@override final  String commandId;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandAckedCopyWith<CommandAcked> get copyWith => _$CommandAckedCopyWithImpl<CommandAcked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandAcked&&(identical(other.commandId, commandId) || other.commandId == commandId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,commandId);
}

@override
String toString() {
    return 'CommandResult.acked(commandId: $commandId)';
}


}

/// @nodoc
abstract mixin class $CommandAckedCopyWith<$Res> implements $CommandResultCopyWith<$Res> {
  factory $CommandAckedCopyWith(CommandAcked value, $Res Function(CommandAcked) _then) = _$CommandAckedCopyWithImpl;
@override @useResult
$Res call({
 String commandId
});




}
/// @nodoc
class _$CommandAckedCopyWithImpl<$Res>
    implements $CommandAckedCopyWith<$Res> {
  _$CommandAckedCopyWithImpl(this._self, this._then);

  final CommandAcked _self;
  final $Res Function(CommandAcked) _then;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,}) {
  return _then(CommandAcked(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CommandFailed extends CommandResult {
  const CommandFailed({required this.commandId, required this.code, this.message}): super._();
  

@override final  String commandId;
 final  ProtocolErrorCode code;
 final  String? message;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandFailedCopyWith<CommandFailed> get copyWith => _$CommandFailedCopyWithImpl<CommandFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandFailed&&(identical(other.commandId, commandId) || other.commandId == commandId)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,commandId,code,message);
}

@override
String toString() {
    return 'CommandResult.failed(commandId: $commandId, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $CommandFailedCopyWith<$Res> implements $CommandResultCopyWith<$Res> {
  factory $CommandFailedCopyWith(CommandFailed value, $Res Function(CommandFailed) _then) = _$CommandFailedCopyWithImpl;
@override @useResult
$Res call({
 String commandId, ProtocolErrorCode code, String? message
});




}
/// @nodoc
class _$CommandFailedCopyWithImpl<$Res>
    implements $CommandFailedCopyWith<$Res> {
  _$CommandFailedCopyWithImpl(this._self, this._then);

  final CommandFailed _self;
  final $Res Function(CommandFailed) _then;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,Object? code = null,Object? message = freezed,}) {
  return _then(CommandFailed(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ProtocolErrorCode,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CommandTimedOut extends CommandResult {
  const CommandTimedOut({required this.commandId}): super._();
  

@override final  String commandId;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandTimedOutCopyWith<CommandTimedOut> get copyWith => _$CommandTimedOutCopyWithImpl<CommandTimedOut>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandTimedOut&&(identical(other.commandId, commandId) || other.commandId == commandId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,commandId);
}

@override
String toString() {
    return 'CommandResult.timedOut(commandId: $commandId)';
}


}

/// @nodoc
abstract mixin class $CommandTimedOutCopyWith<$Res> implements $CommandResultCopyWith<$Res> {
  factory $CommandTimedOutCopyWith(CommandTimedOut value, $Res Function(CommandTimedOut) _then) = _$CommandTimedOutCopyWithImpl;
@override @useResult
$Res call({
 String commandId
});




}
/// @nodoc
class _$CommandTimedOutCopyWithImpl<$Res>
    implements $CommandTimedOutCopyWith<$Res> {
  _$CommandTimedOutCopyWithImpl(this._self, this._then);

  final CommandTimedOut _self;
  final $Res Function(CommandTimedOut) _then;

/// Create a copy of CommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,}) {
  return _then(CommandTimedOut(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
