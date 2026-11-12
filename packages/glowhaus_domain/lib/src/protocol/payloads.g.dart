// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceDescriptor _$DeviceDescriptorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DeviceDescriptor', json, ($checkedConvert) {
      final val = _DeviceDescriptor(
        id: $checkedConvert('id', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(
            _$DeviceTypeEnumMap,
            v,
            unknownValue: DeviceType.unknown,
          ),
        ),
        name: $checkedConvert('name', (v) => v as String),
        capabilities: $checkedConvert(
          'capabilities',
          (v) => (v as List<dynamic>)
              .map((e) => Capability.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        manufacturer: $checkedConvert('manufacturer', (v) => v as String?),
        model: $checkedConvert('model', (v) => v as String?),
        firmware: $checkedConvert('firmware', (v) => v as String?),
        roomHint: $checkedConvert('roomHint', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DeviceDescriptorToJson(_DeviceDescriptor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'name': instance.name,
      'capabilities': instance.capabilities.map((e) => e.toJson()).toList(),
      'manufacturer': ?instance.manufacturer,
      'model': ?instance.model,
      'firmware': ?instance.firmware,
      'roomHint': ?instance.roomHint,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.light: 'light',
  DeviceType.wallSwitch: 'switch',
  DeviceType.curtain: 'curtain',
  DeviceType.thermostat: 'thermostat',
  DeviceType.outlet: 'outlet',
  DeviceType.lock: 'lock',
  DeviceType.sensor: 'sensor',
  DeviceType.camera: 'camera',
  DeviceType.unknown: 'unknown',
};

DiscoveryAnnounce _$DiscoveryAnnounceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DiscoveryAnnounce', json, ($checkedConvert) {
      final val = DiscoveryAnnounce(
        ts: $checkedConvert('ts', (v) => (v as num).toInt()),
        device: $checkedConvert(
          'device',
          (v) => DeviceDescriptor.fromJson(v as Map<String, dynamic>),
        ),
        v: $checkedConvert(
          'v',
          (v) => (v as num?)?.toInt() ?? Protocol.version,
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$DiscoveryAnnounceToJson(DiscoveryAnnounce instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'device': instance.device.toJson(),
      'v': instance.v,
      'type': instance.$type,
    };

DiscoveryQuery _$DiscoveryQueryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DiscoveryQuery', json, ($checkedConvert) {
      final val = DiscoveryQuery(
        ts: $checkedConvert('ts', (v) => (v as num).toInt()),
        v: $checkedConvert(
          'v',
          (v) => (v as num?)?.toInt() ?? Protocol.version,
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$DiscoveryQueryToJson(DiscoveryQuery instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'v': instance.v,
      'type': instance.$type,
    };

DiscoveryBye _$DiscoveryByeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DiscoveryBye', json, ($checkedConvert) {
      final val = DiscoveryBye(
        ts: $checkedConvert('ts', (v) => (v as num).toInt()),
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        v: $checkedConvert(
          'v',
          (v) => (v as num?)?.toInt() ?? Protocol.version,
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$DiscoveryByeToJson(DiscoveryBye instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'deviceId': instance.deviceId,
      'v': instance.v,
      'type': instance.$type,
    };

_AvailabilityPayload _$AvailabilityPayloadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AvailabilityPayload', json, ($checkedConvert) {
      final val = _AvailabilityPayload(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$AvailabilityStatusEnumMap, v),
        ),
        ts: $checkedConvert('ts', (v) => (v as num?)?.toInt()),
        v: $checkedConvert(
          'v',
          (v) => (v as num?)?.toInt() ?? Protocol.version,
        ),
      );
      return val;
    });

Map<String, dynamic> _$AvailabilityPayloadToJson(
  _AvailabilityPayload instance,
) => <String, dynamic>{
  'status': _$AvailabilityStatusEnumMap[instance.status]!,
  'ts': ?instance.ts,
  'v': instance.v,
};

const _$AvailabilityStatusEnumMap = {
  AvailabilityStatus.online: 'online',
  AvailabilityStatus.offline: 'offline',
};

_StatePayload _$StatePayloadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_StatePayload', json, ($checkedConvert) {
      final val = _StatePayload(
        ts: $checkedConvert('ts', (v) => (v as num).toInt()),
        state: $checkedConvert(
          'state',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, e as Map<String, dynamic>),
          ),
        ),
        v: $checkedConvert(
          'v',
          (v) => (v as num?)?.toInt() ?? Protocol.version,
        ),
      );
      return val;
    });

Map<String, dynamic> _$StatePayloadToJson(_StatePayload instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'state': instance.state,
      'v': instance.v,
    };

_SetPayload _$SetPayloadFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_SetPayload',
  json,
  ($checkedConvert) {
    final val = _SetPayload(
      commandId: $checkedConvert('commandId', (v) => v as String),
      ts: $checkedConvert('ts', (v) => (v as num).toInt()),
      set: $checkedConvert(
        'set',
        (v) => (v as Map<String, dynamic>).map(
          (k, e) => MapEntry(k, e as Map<String, dynamic>),
        ),
      ),
      v: $checkedConvert('v', (v) => (v as num?)?.toInt() ?? Protocol.version),
    );
    return val;
  },
);

Map<String, dynamic> _$SetPayloadToJson(_SetPayload instance) =>
    <String, dynamic>{
      'commandId': instance.commandId,
      'ts': instance.ts,
      'set': instance.set,
      'v': instance.v,
    };

_AckError _$AckErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AckError', json, ($checkedConvert) {
      final val = _AckError(
        code: $checkedConvert(
          'code',
          (v) => $enumDecode(
            _$ProtocolErrorCodeEnumMap,
            v,
            unknownValue: ProtocolErrorCode.unknown,
          ),
        ),
        message: $checkedConvert('message', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AckErrorToJson(_AckError instance) => <String, dynamic>{
  'code': _$ProtocolErrorCodeEnumMap[instance.code]!,
  'message': ?instance.message,
};

const _$ProtocolErrorCodeEnumMap = {
  ProtocolErrorCode.invalidPayload: 'invalid_payload',
  ProtocolErrorCode.unsupportedVersion: 'unsupported_version',
  ProtocolErrorCode.unsupportedCapability: 'unsupported_capability',
  ProtocolErrorCode.readOnly: 'read_only',
  ProtocolErrorCode.outOfRange: 'out_of_range',
  ProtocolErrorCode.busy: 'busy',
  ProtocolErrorCode.hardwareFault: 'hardware_fault',
  ProtocolErrorCode.notAllowed: 'not_allowed',
  ProtocolErrorCode.expired: 'expired',
  ProtocolErrorCode.unknown: 'unknown',
};

_AckPayload _$AckPayloadFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_AckPayload',
  json,
  ($checkedConvert) {
    final val = _AckPayload(
      commandId: $checkedConvert('commandId', (v) => v as String),
      ok: $checkedConvert('ok', (v) => v as bool),
      ts: $checkedConvert('ts', (v) => (v as num?)?.toInt()),
      error: $checkedConvert(
        'error',
        (v) => v == null ? null : AckError.fromJson(v as Map<String, dynamic>),
      ),
      v: $checkedConvert('v', (v) => (v as num?)?.toInt() ?? Protocol.version),
    );
    return val;
  },
);

Map<String, dynamic> _$AckPayloadToJson(_AckPayload instance) =>
    <String, dynamic>{
      'commandId': instance.commandId,
      'ok': instance.ok,
      'ts': ?instance.ts,
      'error': ?instance.error?.toJson(),
      'v': instance.v,
    };
