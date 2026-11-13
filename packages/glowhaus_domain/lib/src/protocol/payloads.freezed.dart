// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payloads.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceDescriptor {

 String get id;@JsonKey(unknownEnumValue: DeviceType.unknown) DeviceType get type; String get name; List<Capability> get capabilities; String? get manufacturer; String? get model; String? get firmware; String? get roomHint;/// Optional translation key for the factory default [name].
 String? get nameKey;
/// Create a copy of DeviceDescriptor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceDescriptorCopyWith<DeviceDescriptor> get copyWith => _$DeviceDescriptorCopyWithImpl<DeviceDescriptor>(this as DeviceDescriptor, _$identity);

  /// Serializes this DeviceDescriptor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviceDescriptor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceDescriptor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.capabilities, _this.capabilities)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.firmware, _this.firmware) || other.firmware == _this.firmware)&&(identical(other.roomHint, _this.roomHint) || other.roomHint == _this.roomHint)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviceDescriptor;
  return Object.hash(runtimeType,_this.id,_this.type,_this.name,const DeepCollectionEquality().hash(_this.capabilities),_this.manufacturer,_this.model,_this.firmware,_this.roomHint,_this.nameKey);
}

@override
String toString() {
  final _this = this as DeviceDescriptor;
  return 'DeviceDescriptor(id: ${_this.id}, type: ${_this.type}, name: ${_this.name}, capabilities: ${_this.capabilities}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, firmware: ${_this.firmware}, roomHint: ${_this.roomHint}, nameKey: ${_this.nameKey})';
}


}

/// @nodoc
abstract mixin class $DeviceDescriptorCopyWith<$Res>  {
  factory $DeviceDescriptorCopyWith(DeviceDescriptor value, $Res Function(DeviceDescriptor) _then) = _$DeviceDescriptorCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: DeviceType.unknown) DeviceType type, String name, List<Capability> capabilities, String? manufacturer, String? model, String? firmware, String? roomHint, String? nameKey
});




}
/// @nodoc
class _$DeviceDescriptorCopyWithImpl<$Res>
    implements $DeviceDescriptorCopyWith<$Res> {
  _$DeviceDescriptorCopyWithImpl(this._self, this._then);

  final DeviceDescriptor _self;
  final $Res Function(DeviceDescriptor) _then;

/// Create a copy of DeviceDescriptor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? capabilities = null,Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? roomHint = freezed,Object? nameKey = freezed,}) {
  return _then(DeviceDescriptor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeviceType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<Capability>,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,roomHint: freezed == roomHint ? _self.roomHint : roomHint // ignore: cast_nullable_to_non_nullable
as String?,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceDescriptor].
extension DeviceDescriptorPatterns on DeviceDescriptor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceDescriptor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceDescriptor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceDescriptor value)  $default,){
final _that = this;
switch (_that) {
case _DeviceDescriptor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceDescriptor value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceDescriptor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: DeviceType.unknown)  DeviceType type,  String name,  List<Capability> capabilities,  String? manufacturer,  String? model,  String? firmware,  String? roomHint,  String? nameKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceDescriptor() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.capabilities,_that.manufacturer,_that.model,_that.firmware,_that.roomHint,_that.nameKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: DeviceType.unknown)  DeviceType type,  String name,  List<Capability> capabilities,  String? manufacturer,  String? model,  String? firmware,  String? roomHint,  String? nameKey)  $default,) {final _that = this;
switch (_that) {
case _DeviceDescriptor():
return $default(_that.id,_that.type,_that.name,_that.capabilities,_that.manufacturer,_that.model,_that.firmware,_that.roomHint,_that.nameKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: DeviceType.unknown)  DeviceType type,  String name,  List<Capability> capabilities,  String? manufacturer,  String? model,  String? firmware,  String? roomHint,  String? nameKey)?  $default,) {final _that = this;
switch (_that) {
case _DeviceDescriptor() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.capabilities,_that.manufacturer,_that.model,_that.firmware,_that.roomHint,_that.nameKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceDescriptor implements DeviceDescriptor {
  const _DeviceDescriptor({required this.id, @JsonKey(unknownEnumValue: DeviceType.unknown) required this.type, required this.name, required  List<Capability> capabilities, this.manufacturer, this.model, this.firmware, this.roomHint, this.nameKey}): _capabilities = capabilities;
  factory _DeviceDescriptor.fromJson(Map<String, dynamic> json) => _$DeviceDescriptorFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: DeviceType.unknown) final  DeviceType type;
@override final  String name;
 final  List<Capability> _capabilities;
@override List<Capability> get capabilities {
  if (_capabilities is EqualUnmodifiableListView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_capabilities);
}

@override final  String? manufacturer;
@override final  String? model;
@override final  String? firmware;
@override final  String? roomHint;
/// Optional translation key for the factory default [name].
@override final  String? nameKey;

/// Create a copy of DeviceDescriptor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceDescriptorCopyWith<_DeviceDescriptor> get copyWith => __$DeviceDescriptorCopyWithImpl<_DeviceDescriptor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceDescriptorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceDescriptor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.capabilities, _capabilities)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware)&&(identical(other.roomHint, roomHint) || other.roomHint == roomHint)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,name,const DeepCollectionEquality().hash(_capabilities),manufacturer,model,firmware,roomHint,nameKey);
}

@override
String toString() {
    return 'DeviceDescriptor(id: $id, type: $type, name: $name, capabilities: $capabilities, manufacturer: $manufacturer, model: $model, firmware: $firmware, roomHint: $roomHint, nameKey: $nameKey)';
}


}

/// @nodoc
abstract mixin class _$DeviceDescriptorCopyWith<$Res> implements $DeviceDescriptorCopyWith<$Res> {
  factory _$DeviceDescriptorCopyWith(_DeviceDescriptor value, $Res Function(_DeviceDescriptor) _then) = __$DeviceDescriptorCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: DeviceType.unknown) DeviceType type, String name, List<Capability> capabilities, String? manufacturer, String? model, String? firmware, String? roomHint, String? nameKey
});




}
/// @nodoc
class __$DeviceDescriptorCopyWithImpl<$Res>
    implements _$DeviceDescriptorCopyWith<$Res> {
  __$DeviceDescriptorCopyWithImpl(this._self, this._then);

  final _DeviceDescriptor _self;
  final $Res Function(_DeviceDescriptor) _then;

/// Create a copy of DeviceDescriptor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? capabilities = null,Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? roomHint = freezed,Object? nameKey = freezed,}) {
  return _then(_DeviceDescriptor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeviceType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capabilities: null == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<Capability>,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,roomHint: freezed == roomHint ? _self.roomHint : roomHint // ignore: cast_nullable_to_non_nullable
as String?,nameKey: freezed == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

DiscoveryMessage _$DiscoveryMessageFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'announce':
          return DiscoveryAnnounce.fromJson(
            json
          );
                case 'query':
          return DiscoveryQuery.fromJson(
            json
          );
                case 'bye':
          return DiscoveryBye.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'DiscoveryMessage',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$DiscoveryMessage {

 int get ts; int get v;
/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryMessageCopyWith<DiscoveryMessage> get copyWith => _$DiscoveryMessageCopyWithImpl<DiscoveryMessage>(this as DiscoveryMessage, _$identity);

  /// Serializes this DiscoveryMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DiscoveryMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryMessage&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&(identical(other.v, _this.v) || other.v == _this.v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DiscoveryMessage;
  return Object.hash(runtimeType,_this.ts,_this.v);
}

@override
String toString() {
  final _this = this as DiscoveryMessage;
  return 'DiscoveryMessage(ts: ${_this.ts}, v: ${_this.v})';
}


}

/// @nodoc
abstract mixin class $DiscoveryMessageCopyWith<$Res>  {
  factory $DiscoveryMessageCopyWith(DiscoveryMessage value, $Res Function(DiscoveryMessage) _then) = _$DiscoveryMessageCopyWithImpl;
@useResult
$Res call({
 int ts, int v
});




}
/// @nodoc
class _$DiscoveryMessageCopyWithImpl<$Res>
    implements $DiscoveryMessageCopyWith<$Res> {
  _$DiscoveryMessageCopyWithImpl(this._self, this._then);

  final DiscoveryMessage _self;
  final $Res Function(DiscoveryMessage) _then;

/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ts = null,Object? v = null,}) {
  return _then(_self.copyWith(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoveryMessage].
extension DiscoveryMessagePatterns on DiscoveryMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DiscoveryAnnounce value)?  announce,TResult Function( DiscoveryQuery value)?  query,TResult Function( DiscoveryBye value)?  bye,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DiscoveryAnnounce() when announce != null:
return announce(_that);case DiscoveryQuery() when query != null:
return query(_that);case DiscoveryBye() when bye != null:
return bye(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DiscoveryAnnounce value)  announce,required TResult Function( DiscoveryQuery value)  query,required TResult Function( DiscoveryBye value)  bye,}){
final _that = this;
switch (_that) {
case DiscoveryAnnounce():
return announce(_that);case DiscoveryQuery():
return query(_that);case DiscoveryBye():
return bye(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DiscoveryAnnounce value)?  announce,TResult? Function( DiscoveryQuery value)?  query,TResult? Function( DiscoveryBye value)?  bye,}){
final _that = this;
switch (_that) {
case DiscoveryAnnounce() when announce != null:
return announce(_that);case DiscoveryQuery() when query != null:
return query(_that);case DiscoveryBye() when bye != null:
return bye(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int ts,  DeviceDescriptor device,  int v)?  announce,TResult Function( int ts,  int v)?  query,TResult Function( int ts,  String deviceId,  int v)?  bye,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DiscoveryAnnounce() when announce != null:
return announce(_that.ts,_that.device,_that.v);case DiscoveryQuery() when query != null:
return query(_that.ts,_that.v);case DiscoveryBye() when bye != null:
return bye(_that.ts,_that.deviceId,_that.v);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int ts,  DeviceDescriptor device,  int v)  announce,required TResult Function( int ts,  int v)  query,required TResult Function( int ts,  String deviceId,  int v)  bye,}) {final _that = this;
switch (_that) {
case DiscoveryAnnounce():
return announce(_that.ts,_that.device,_that.v);case DiscoveryQuery():
return query(_that.ts,_that.v);case DiscoveryBye():
return bye(_that.ts,_that.deviceId,_that.v);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int ts,  DeviceDescriptor device,  int v)?  announce,TResult? Function( int ts,  int v)?  query,TResult? Function( int ts,  String deviceId,  int v)?  bye,}) {final _that = this;
switch (_that) {
case DiscoveryAnnounce() when announce != null:
return announce(_that.ts,_that.device,_that.v);case DiscoveryQuery() when query != null:
return query(_that.ts,_that.v);case DiscoveryBye() when bye != null:
return bye(_that.ts,_that.deviceId,_that.v);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class DiscoveryAnnounce implements DiscoveryMessage {
  const DiscoveryAnnounce({required this.ts, required this.device, this.v = Protocol.version,  String? $type}): $type = $type ?? 'announce';
  factory DiscoveryAnnounce.fromJson(Map<String, dynamic> json) => _$DiscoveryAnnounceFromJson(json);

@override final  int ts;
 final  DeviceDescriptor device;
@override@JsonKey() final  int v;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryAnnounceCopyWith<DiscoveryAnnounce> get copyWith => _$DiscoveryAnnounceCopyWithImpl<DiscoveryAnnounce>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoveryAnnounceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryAnnounce&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.device, device) || other.device == device)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ts,device,v);
}

@override
String toString() {
    return 'DiscoveryMessage.announce(ts: $ts, device: $device, v: $v)';
}


}

/// @nodoc
abstract mixin class $DiscoveryAnnounceCopyWith<$Res> implements $DiscoveryMessageCopyWith<$Res> {
  factory $DiscoveryAnnounceCopyWith(DiscoveryAnnounce value, $Res Function(DiscoveryAnnounce) _then) = _$DiscoveryAnnounceCopyWithImpl;
@override @useResult
$Res call({
 int ts, DeviceDescriptor device, int v
});


$DeviceDescriptorCopyWith<$Res> get device;

}
/// @nodoc
class _$DiscoveryAnnounceCopyWithImpl<$Res>
    implements $DiscoveryAnnounceCopyWith<$Res> {
  _$DiscoveryAnnounceCopyWithImpl(this._self, this._then);

  final DiscoveryAnnounce _self;
  final $Res Function(DiscoveryAnnounce) _then;

/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = null,Object? device = null,Object? v = null,}) {
  return _then(DiscoveryAnnounce(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceDescriptor,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceDescriptorCopyWith<$Res> get device {
  
  return $DeviceDescriptorCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class DiscoveryQuery implements DiscoveryMessage {
  const DiscoveryQuery({required this.ts, this.v = Protocol.version,  String? $type}): $type = $type ?? 'query';
  factory DiscoveryQuery.fromJson(Map<String, dynamic> json) => _$DiscoveryQueryFromJson(json);

@override final  int ts;
@override@JsonKey() final  int v;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryQueryCopyWith<DiscoveryQuery> get copyWith => _$DiscoveryQueryCopyWithImpl<DiscoveryQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoveryQueryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryQuery&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ts,v);
}

@override
String toString() {
    return 'DiscoveryMessage.query(ts: $ts, v: $v)';
}


}

/// @nodoc
abstract mixin class $DiscoveryQueryCopyWith<$Res> implements $DiscoveryMessageCopyWith<$Res> {
  factory $DiscoveryQueryCopyWith(DiscoveryQuery value, $Res Function(DiscoveryQuery) _then) = _$DiscoveryQueryCopyWithImpl;
@override @useResult
$Res call({
 int ts, int v
});




}
/// @nodoc
class _$DiscoveryQueryCopyWithImpl<$Res>
    implements $DiscoveryQueryCopyWith<$Res> {
  _$DiscoveryQueryCopyWithImpl(this._self, this._then);

  final DiscoveryQuery _self;
  final $Res Function(DiscoveryQuery) _then;

/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = null,Object? v = null,}) {
  return _then(DiscoveryQuery(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DiscoveryBye implements DiscoveryMessage {
  const DiscoveryBye({required this.ts, required this.deviceId, this.v = Protocol.version,  String? $type}): $type = $type ?? 'bye';
  factory DiscoveryBye.fromJson(Map<String, dynamic> json) => _$DiscoveryByeFromJson(json);

@override final  int ts;
 final  String deviceId;
@override@JsonKey() final  int v;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryByeCopyWith<DiscoveryBye> get copyWith => _$DiscoveryByeCopyWithImpl<DiscoveryBye>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoveryByeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryBye&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ts,deviceId,v);
}

@override
String toString() {
    return 'DiscoveryMessage.bye(ts: $ts, deviceId: $deviceId, v: $v)';
}


}

/// @nodoc
abstract mixin class $DiscoveryByeCopyWith<$Res> implements $DiscoveryMessageCopyWith<$Res> {
  factory $DiscoveryByeCopyWith(DiscoveryBye value, $Res Function(DiscoveryBye) _then) = _$DiscoveryByeCopyWithImpl;
@override @useResult
$Res call({
 int ts, String deviceId, int v
});




}
/// @nodoc
class _$DiscoveryByeCopyWithImpl<$Res>
    implements $DiscoveryByeCopyWith<$Res> {
  _$DiscoveryByeCopyWithImpl(this._self, this._then);

  final DiscoveryBye _self;
  final $Res Function(DiscoveryBye) _then;

/// Create a copy of DiscoveryMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = null,Object? deviceId = null,Object? v = null,}) {
  return _then(DiscoveryBye(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$InfoPayload {

 int get ts; DeviceDescriptor get device; int get v;
/// Create a copy of InfoPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InfoPayloadCopyWith<InfoPayload> get copyWith => _$InfoPayloadCopyWithImpl<InfoPayload>(this as InfoPayload, _$identity);

  /// Serializes this InfoPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InfoPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InfoPayload&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.v, _this.v) || other.v == _this.v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InfoPayload;
  return Object.hash(runtimeType,_this.ts,_this.device,_this.v);
}

@override
String toString() {
  final _this = this as InfoPayload;
  return 'InfoPayload(ts: ${_this.ts}, device: ${_this.device}, v: ${_this.v})';
}


}

/// @nodoc
abstract mixin class $InfoPayloadCopyWith<$Res>  {
  factory $InfoPayloadCopyWith(InfoPayload value, $Res Function(InfoPayload) _then) = _$InfoPayloadCopyWithImpl;
@useResult
$Res call({
 int ts, DeviceDescriptor device, int v
});


$DeviceDescriptorCopyWith<$Res> get device;

}
/// @nodoc
class _$InfoPayloadCopyWithImpl<$Res>
    implements $InfoPayloadCopyWith<$Res> {
  _$InfoPayloadCopyWithImpl(this._self, this._then);

  final InfoPayload _self;
  final $Res Function(InfoPayload) _then;

/// Create a copy of InfoPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ts = null,Object? device = null,Object? v = null,}) {
  return _then(InfoPayload(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceDescriptor,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of InfoPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceDescriptorCopyWith<$Res> get device {
  
  return $DeviceDescriptorCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}
}


/// Adds pattern-matching-related methods to [InfoPayload].
extension InfoPayloadPatterns on InfoPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InfoPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InfoPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InfoPayload value)  $default,){
final _that = this;
switch (_that) {
case _InfoPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InfoPayload value)?  $default,){
final _that = this;
switch (_that) {
case _InfoPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ts,  DeviceDescriptor device,  int v)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InfoPayload() when $default != null:
return $default(_that.ts,_that.device,_that.v);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ts,  DeviceDescriptor device,  int v)  $default,) {final _that = this;
switch (_that) {
case _InfoPayload():
return $default(_that.ts,_that.device,_that.v);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ts,  DeviceDescriptor device,  int v)?  $default,) {final _that = this;
switch (_that) {
case _InfoPayload() when $default != null:
return $default(_that.ts,_that.device,_that.v);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InfoPayload implements InfoPayload {
  const _InfoPayload({required this.ts, required this.device, this.v = Protocol.version});
  factory _InfoPayload.fromJson(Map<String, dynamic> json) => _$InfoPayloadFromJson(json);

@override final  int ts;
@override final  DeviceDescriptor device;
@override@JsonKey() final  int v;

/// Create a copy of InfoPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InfoPayloadCopyWith<_InfoPayload> get copyWith => __$InfoPayloadCopyWithImpl<_InfoPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InfoPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InfoPayload&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.device, device) || other.device == device)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ts,device,v);
}

@override
String toString() {
    return 'InfoPayload(ts: $ts, device: $device, v: $v)';
}


}

/// @nodoc
abstract mixin class _$InfoPayloadCopyWith<$Res> implements $InfoPayloadCopyWith<$Res> {
  factory _$InfoPayloadCopyWith(_InfoPayload value, $Res Function(_InfoPayload) _then) = __$InfoPayloadCopyWithImpl;
@override @useResult
$Res call({
 int ts, DeviceDescriptor device, int v
});


@override $DeviceDescriptorCopyWith<$Res> get device;

}
/// @nodoc
class __$InfoPayloadCopyWithImpl<$Res>
    implements _$InfoPayloadCopyWith<$Res> {
  __$InfoPayloadCopyWithImpl(this._self, this._then);

  final _InfoPayload _self;
  final $Res Function(_InfoPayload) _then;

/// Create a copy of InfoPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = null,Object? device = null,Object? v = null,}) {
  return _then(_InfoPayload(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceDescriptor,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of InfoPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceDescriptorCopyWith<$Res> get device {
  
  return $DeviceDescriptorCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}
}


/// @nodoc
mixin _$AvailabilityPayload {

 AvailabilityStatus get status; int? get ts; int get v;
/// Create a copy of AvailabilityPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityPayloadCopyWith<AvailabilityPayload> get copyWith => _$AvailabilityPayloadCopyWithImpl<AvailabilityPayload>(this as AvailabilityPayload, _$identity);

  /// Serializes this AvailabilityPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AvailabilityPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityPayload&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&(identical(other.v, _this.v) || other.v == _this.v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AvailabilityPayload;
  return Object.hash(runtimeType,_this.status,_this.ts,_this.v);
}

@override
String toString() {
  final _this = this as AvailabilityPayload;
  return 'AvailabilityPayload(status: ${_this.status}, ts: ${_this.ts}, v: ${_this.v})';
}


}

/// @nodoc
abstract mixin class $AvailabilityPayloadCopyWith<$Res>  {
  factory $AvailabilityPayloadCopyWith(AvailabilityPayload value, $Res Function(AvailabilityPayload) _then) = _$AvailabilityPayloadCopyWithImpl;
@useResult
$Res call({
 AvailabilityStatus status, int? ts, int v
});




}
/// @nodoc
class _$AvailabilityPayloadCopyWithImpl<$Res>
    implements $AvailabilityPayloadCopyWith<$Res> {
  _$AvailabilityPayloadCopyWithImpl(this._self, this._then);

  final AvailabilityPayload _self;
  final $Res Function(AvailabilityPayload) _then;

/// Create a copy of AvailabilityPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? ts = freezed,Object? v = null,}) {
  return _then(AvailabilityPayload(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AvailabilityStatus,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int?,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityPayload].
extension AvailabilityPayloadPatterns on AvailabilityPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityPayload value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityPayload value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AvailabilityStatus status,  int? ts,  int v)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityPayload() when $default != null:
return $default(_that.status,_that.ts,_that.v);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AvailabilityStatus status,  int? ts,  int v)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityPayload():
return $default(_that.status,_that.ts,_that.v);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AvailabilityStatus status,  int? ts,  int v)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityPayload() when $default != null:
return $default(_that.status,_that.ts,_that.v);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AvailabilityPayload extends AvailabilityPayload {
  const _AvailabilityPayload({required this.status, this.ts, this.v = Protocol.version}): super._();
  factory _AvailabilityPayload.fromJson(Map<String, dynamic> json) => _$AvailabilityPayloadFromJson(json);

@override final  AvailabilityStatus status;
@override final  int? ts;
@override@JsonKey() final  int v;

/// Create a copy of AvailabilityPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityPayloadCopyWith<_AvailabilityPayload> get copyWith => __$AvailabilityPayloadCopyWithImpl<_AvailabilityPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityPayload&&(identical(other.status, status) || other.status == status)&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,ts,v);
}

@override
String toString() {
    return 'AvailabilityPayload(status: $status, ts: $ts, v: $v)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityPayloadCopyWith<$Res> implements $AvailabilityPayloadCopyWith<$Res> {
  factory _$AvailabilityPayloadCopyWith(_AvailabilityPayload value, $Res Function(_AvailabilityPayload) _then) = __$AvailabilityPayloadCopyWithImpl;
@override @useResult
$Res call({
 AvailabilityStatus status, int? ts, int v
});




}
/// @nodoc
class __$AvailabilityPayloadCopyWithImpl<$Res>
    implements _$AvailabilityPayloadCopyWith<$Res> {
  __$AvailabilityPayloadCopyWithImpl(this._self, this._then);

  final _AvailabilityPayload _self;
  final $Res Function(_AvailabilityPayload) _then;

/// Create a copy of AvailabilityPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? ts = freezed,Object? v = null,}) {
  return _then(_AvailabilityPayload(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AvailabilityStatus,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int?,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StatePayload {

 int get ts; Map<String, Map<String, dynamic>> get state; int get v;
/// Create a copy of StatePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatePayloadCopyWith<StatePayload> get copyWith => _$StatePayloadCopyWithImpl<StatePayload>(this as StatePayload, _$identity);

  /// Serializes this StatePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StatePayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatePayload&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&const DeepCollectionEquality().equals(other.state, _this.state)&&(identical(other.v, _this.v) || other.v == _this.v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StatePayload;
  return Object.hash(runtimeType,_this.ts,const DeepCollectionEquality().hash(_this.state),_this.v);
}

@override
String toString() {
  final _this = this as StatePayload;
  return 'StatePayload(ts: ${_this.ts}, state: ${_this.state}, v: ${_this.v})';
}


}

/// @nodoc
abstract mixin class $StatePayloadCopyWith<$Res>  {
  factory $StatePayloadCopyWith(StatePayload value, $Res Function(StatePayload) _then) = _$StatePayloadCopyWithImpl;
@useResult
$Res call({
 int ts, Map<String, Map<String, dynamic>> state, int v
});




}
/// @nodoc
class _$StatePayloadCopyWithImpl<$Res>
    implements $StatePayloadCopyWith<$Res> {
  _$StatePayloadCopyWithImpl(this._self, this._then);

  final StatePayload _self;
  final $Res Function(StatePayload) _then;

/// Create a copy of StatePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ts = null,Object? state = null,Object? v = null,}) {
  return _then(StatePayload(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, dynamic>>,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatePayload].
extension StatePayloadPatterns on StatePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatePayload value)  $default,){
final _that = this;
switch (_that) {
case _StatePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatePayload value)?  $default,){
final _that = this;
switch (_that) {
case _StatePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ts,  Map<String, Map<String, dynamic>> state,  int v)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatePayload() when $default != null:
return $default(_that.ts,_that.state,_that.v);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ts,  Map<String, Map<String, dynamic>> state,  int v)  $default,) {final _that = this;
switch (_that) {
case _StatePayload():
return $default(_that.ts,_that.state,_that.v);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ts,  Map<String, Map<String, dynamic>> state,  int v)?  $default,) {final _that = this;
switch (_that) {
case _StatePayload() when $default != null:
return $default(_that.ts,_that.state,_that.v);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatePayload extends StatePayload {
  const _StatePayload({required this.ts, required  Map<String, Map<String, dynamic>> state, this.v = Protocol.version}): _state = state,super._();
  factory _StatePayload.fromJson(Map<String, dynamic> json) => _$StatePayloadFromJson(json);

@override final  int ts;
 final  Map<String, Map<String, dynamic>> _state;
@override Map<String, Map<String, dynamic>> get state {
  if (_state is EqualUnmodifiableMapView) return _state;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_state);
}

@override@JsonKey() final  int v;

/// Create a copy of StatePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatePayloadCopyWith<_StatePayload> get copyWith => __$StatePayloadCopyWithImpl<_StatePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatePayload&&(identical(other.ts, ts) || other.ts == ts)&&const DeepCollectionEquality().equals(other.state, _state)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ts,const DeepCollectionEquality().hash(_state),v);
}

@override
String toString() {
    return 'StatePayload(ts: $ts, state: $state, v: $v)';
}


}

/// @nodoc
abstract mixin class _$StatePayloadCopyWith<$Res> implements $StatePayloadCopyWith<$Res> {
  factory _$StatePayloadCopyWith(_StatePayload value, $Res Function(_StatePayload) _then) = __$StatePayloadCopyWithImpl;
@override @useResult
$Res call({
 int ts, Map<String, Map<String, dynamic>> state, int v
});




}
/// @nodoc
class __$StatePayloadCopyWithImpl<$Res>
    implements _$StatePayloadCopyWith<$Res> {
  __$StatePayloadCopyWithImpl(this._self, this._then);

  final _StatePayload _self;
  final $Res Function(_StatePayload) _then;

/// Create a copy of StatePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = null,Object? state = null,Object? v = null,}) {
  return _then(_StatePayload(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self._state : state // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, dynamic>>,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SetPayload {

 String get commandId; int get ts; Map<String, Map<String, dynamic>> get set; int get v;
/// Create a copy of SetPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPayloadCopyWith<SetPayload> get copyWith => _$SetPayloadCopyWithImpl<SetPayload>(this as SetPayload, _$identity);

  /// Serializes this SetPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPayload&&(identical(other.commandId, _this.commandId) || other.commandId == _this.commandId)&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&const DeepCollectionEquality().equals(other.set, _this.set)&&(identical(other.v, _this.v) || other.v == _this.v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetPayload;
  return Object.hash(runtimeType,_this.commandId,_this.ts,const DeepCollectionEquality().hash(_this.set),_this.v);
}

@override
String toString() {
  final _this = this as SetPayload;
  return 'SetPayload(commandId: ${_this.commandId}, ts: ${_this.ts}, set: ${_this.set}, v: ${_this.v})';
}


}

/// @nodoc
abstract mixin class $SetPayloadCopyWith<$Res>  {
  factory $SetPayloadCopyWith(SetPayload value, $Res Function(SetPayload) _then) = _$SetPayloadCopyWithImpl;
@useResult
$Res call({
 String commandId, int ts, Map<String, Map<String, dynamic>> set, int v
});




}
/// @nodoc
class _$SetPayloadCopyWithImpl<$Res>
    implements $SetPayloadCopyWith<$Res> {
  _$SetPayloadCopyWithImpl(this._self, this._then);

  final SetPayload _self;
  final $Res Function(SetPayload) _then;

/// Create a copy of SetPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commandId = null,Object? ts = null,Object? set = null,Object? v = null,}) {
  return _then(SetPayload(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,set: null == set ? _self.set : set // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, dynamic>>,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SetPayload].
extension SetPayloadPatterns on SetPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetPayload value)  $default,){
final _that = this;
switch (_that) {
case _SetPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetPayload value)?  $default,){
final _that = this;
switch (_that) {
case _SetPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String commandId,  int ts,  Map<String, Map<String, dynamic>> set,  int v)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetPayload() when $default != null:
return $default(_that.commandId,_that.ts,_that.set,_that.v);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String commandId,  int ts,  Map<String, Map<String, dynamic>> set,  int v)  $default,) {final _that = this;
switch (_that) {
case _SetPayload():
return $default(_that.commandId,_that.ts,_that.set,_that.v);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String commandId,  int ts,  Map<String, Map<String, dynamic>> set,  int v)?  $default,) {final _that = this;
switch (_that) {
case _SetPayload() when $default != null:
return $default(_that.commandId,_that.ts,_that.set,_that.v);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetPayload extends SetPayload {
  const _SetPayload({required this.commandId, required this.ts, required  Map<String, Map<String, dynamic>> set, this.v = Protocol.version}): _set = set,super._();
  factory _SetPayload.fromJson(Map<String, dynamic> json) => _$SetPayloadFromJson(json);

@override final  String commandId;
@override final  int ts;
 final  Map<String, Map<String, dynamic>> _set;
@override Map<String, Map<String, dynamic>> get set {
  if (_set is EqualUnmodifiableMapView) return _set;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_set);
}

@override@JsonKey() final  int v;

/// Create a copy of SetPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPayloadCopyWith<_SetPayload> get copyWith => __$SetPayloadCopyWithImpl<_SetPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPayload&&(identical(other.commandId, commandId) || other.commandId == commandId)&&(identical(other.ts, ts) || other.ts == ts)&&const DeepCollectionEquality().equals(other.set, _set)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,commandId,ts,const DeepCollectionEquality().hash(_set),v);
}

@override
String toString() {
    return 'SetPayload(commandId: $commandId, ts: $ts, set: $set, v: $v)';
}


}

/// @nodoc
abstract mixin class _$SetPayloadCopyWith<$Res> implements $SetPayloadCopyWith<$Res> {
  factory _$SetPayloadCopyWith(_SetPayload value, $Res Function(_SetPayload) _then) = __$SetPayloadCopyWithImpl;
@override @useResult
$Res call({
 String commandId, int ts, Map<String, Map<String, dynamic>> set, int v
});




}
/// @nodoc
class __$SetPayloadCopyWithImpl<$Res>
    implements _$SetPayloadCopyWith<$Res> {
  __$SetPayloadCopyWithImpl(this._self, this._then);

  final _SetPayload _self;
  final $Res Function(_SetPayload) _then;

/// Create a copy of SetPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,Object? ts = null,Object? set = null,Object? v = null,}) {
  return _then(_SetPayload(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int,set: null == set ? _self._set : set // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, dynamic>>,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AckError {

@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown) ProtocolErrorCode get code; String? get message;
/// Create a copy of AckError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AckErrorCopyWith<AckError> get copyWith => _$AckErrorCopyWithImpl<AckError>(this as AckError, _$identity);

  /// Serializes this AckError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AckError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AckError&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AckError;
  return Object.hash(runtimeType,_this.code,_this.message);
}

@override
String toString() {
  final _this = this as AckError;
  return 'AckError(code: ${_this.code}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $AckErrorCopyWith<$Res>  {
  factory $AckErrorCopyWith(AckError value, $Res Function(AckError) _then) = _$AckErrorCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown) ProtocolErrorCode code, String? message
});




}
/// @nodoc
class _$AckErrorCopyWithImpl<$Res>
    implements $AckErrorCopyWith<$Res> {
  _$AckErrorCopyWithImpl(this._self, this._then);

  final AckError _self;
  final $Res Function(AckError) _then;

/// Create a copy of AckError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = freezed,}) {
  return _then(AckError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ProtocolErrorCode,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AckError].
extension AckErrorPatterns on AckError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AckError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AckError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AckError value)  $default,){
final _that = this;
switch (_that) {
case _AckError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AckError value)?  $default,){
final _that = this;
switch (_that) {
case _AckError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown)  ProtocolErrorCode code,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AckError() when $default != null:
return $default(_that.code,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown)  ProtocolErrorCode code,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AckError():
return $default(_that.code,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown)  ProtocolErrorCode code,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AckError() when $default != null:
return $default(_that.code,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AckError implements AckError {
  const _AckError({@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown) required this.code, this.message});
  factory _AckError.fromJson(Map<String, dynamic> json) => _$AckErrorFromJson(json);

@override@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown) final  ProtocolErrorCode code;
@override final  String? message;

/// Create a copy of AckError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AckErrorCopyWith<_AckError> get copyWith => __$AckErrorCopyWithImpl<_AckError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AckErrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AckError&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message);
}

@override
String toString() {
    return 'AckError(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AckErrorCopyWith<$Res> implements $AckErrorCopyWith<$Res> {
  factory _$AckErrorCopyWith(_AckError value, $Res Function(_AckError) _then) = __$AckErrorCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ProtocolErrorCode.unknown) ProtocolErrorCode code, String? message
});




}
/// @nodoc
class __$AckErrorCopyWithImpl<$Res>
    implements _$AckErrorCopyWith<$Res> {
  __$AckErrorCopyWithImpl(this._self, this._then);

  final _AckError _self;
  final $Res Function(_AckError) _then;

/// Create a copy of AckError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = freezed,}) {
  return _then(_AckError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ProtocolErrorCode,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AckPayload {

 String get commandId; bool get ok; int? get ts; AckError? get error; int get v;
/// Create a copy of AckPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AckPayloadCopyWith<AckPayload> get copyWith => _$AckPayloadCopyWithImpl<AckPayload>(this as AckPayload, _$identity);

  /// Serializes this AckPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AckPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AckPayload&&(identical(other.commandId, _this.commandId) || other.commandId == _this.commandId)&&(identical(other.ok, _this.ok) || other.ok == _this.ok)&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.v, _this.v) || other.v == _this.v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AckPayload;
  return Object.hash(runtimeType,_this.commandId,_this.ok,_this.ts,_this.error,_this.v);
}

@override
String toString() {
  final _this = this as AckPayload;
  return 'AckPayload(commandId: ${_this.commandId}, ok: ${_this.ok}, ts: ${_this.ts}, error: ${_this.error}, v: ${_this.v})';
}


}

/// @nodoc
abstract mixin class $AckPayloadCopyWith<$Res>  {
  factory $AckPayloadCopyWith(AckPayload value, $Res Function(AckPayload) _then) = _$AckPayloadCopyWithImpl;
@useResult
$Res call({
 String commandId, bool ok, int? ts, AckError? error, int v
});


$AckErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$AckPayloadCopyWithImpl<$Res>
    implements $AckPayloadCopyWith<$Res> {
  _$AckPayloadCopyWithImpl(this._self, this._then);

  final AckPayload _self;
  final $Res Function(AckPayload) _then;

/// Create a copy of AckPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commandId = null,Object? ok = null,Object? ts = freezed,Object? error = freezed,Object? v = null,}) {
  return _then(AckPayload(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AckError?,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of AckPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AckErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $AckErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [AckPayload].
extension AckPayloadPatterns on AckPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AckPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AckPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AckPayload value)  $default,){
final _that = this;
switch (_that) {
case _AckPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AckPayload value)?  $default,){
final _that = this;
switch (_that) {
case _AckPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String commandId,  bool ok,  int? ts,  AckError? error,  int v)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AckPayload() when $default != null:
return $default(_that.commandId,_that.ok,_that.ts,_that.error,_that.v);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String commandId,  bool ok,  int? ts,  AckError? error,  int v)  $default,) {final _that = this;
switch (_that) {
case _AckPayload():
return $default(_that.commandId,_that.ok,_that.ts,_that.error,_that.v);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String commandId,  bool ok,  int? ts,  AckError? error,  int v)?  $default,) {final _that = this;
switch (_that) {
case _AckPayload() when $default != null:
return $default(_that.commandId,_that.ok,_that.ts,_that.error,_that.v);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AckPayload extends AckPayload {
  const _AckPayload({required this.commandId, required this.ok, this.ts, this.error, this.v = Protocol.version}): super._();
  factory _AckPayload.fromJson(Map<String, dynamic> json) => _$AckPayloadFromJson(json);

@override final  String commandId;
@override final  bool ok;
@override final  int? ts;
@override final  AckError? error;
@override@JsonKey() final  int v;

/// Create a copy of AckPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AckPayloadCopyWith<_AckPayload> get copyWith => __$AckPayloadCopyWithImpl<_AckPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AckPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AckPayload&&(identical(other.commandId, commandId) || other.commandId == commandId)&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.error, error) || other.error == error)&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,commandId,ok,ts,error,v);
}

@override
String toString() {
    return 'AckPayload(commandId: $commandId, ok: $ok, ts: $ts, error: $error, v: $v)';
}


}

/// @nodoc
abstract mixin class _$AckPayloadCopyWith<$Res> implements $AckPayloadCopyWith<$Res> {
  factory _$AckPayloadCopyWith(_AckPayload value, $Res Function(_AckPayload) _then) = __$AckPayloadCopyWithImpl;
@override @useResult
$Res call({
 String commandId, bool ok, int? ts, AckError? error, int v
});


@override $AckErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$AckPayloadCopyWithImpl<$Res>
    implements _$AckPayloadCopyWith<$Res> {
  __$AckPayloadCopyWithImpl(this._self, this._then);

  final _AckPayload _self;
  final $Res Function(_AckPayload) _then;

/// Create a copy of AckPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,Object? ok = null,Object? ts = freezed,Object? error = freezed,Object? v = null,}) {
  return _then(_AckPayload(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AckError?,v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of AckPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AckErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $AckErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
