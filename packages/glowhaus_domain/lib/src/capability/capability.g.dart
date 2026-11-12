// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Capability _$CapabilityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Capability', json, ($checkedConvert) {
      final val = _Capability(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$CapabilityKindEnumMap,
            v,
            unknownValue: CapabilityKind.unknown,
          ),
        ),
        label: $checkedConvert('label', (v) => v as String?),
        config: $checkedConvert(
          'config',
          (v) => v as Map<String, dynamic>? ?? const <String, dynamic>{},
        ),
      );
      return val;
    });

Map<String, dynamic> _$CapabilityToJson(_Capability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$CapabilityKindEnumMap[instance.kind]!,
      'label': ?instance.label,
      'config': instance.config,
    };

const _$CapabilityKindEnumMap = {
  CapabilityKind.onOff: 'onOff',
  CapabilityKind.brightness: 'brightness',
  CapabilityKind.color: 'color',
  CapabilityKind.colorTemperature: 'colorTemperature',
  CapabilityKind.position: 'position',
  CapabilityKind.thermostat: 'thermostat',
  CapabilityKind.powerMeter: 'powerMeter',
  CapabilityKind.lock: 'lock',
  CapabilityKind.temperatureSensor: 'temperatureSensor',
  CapabilityKind.humiditySensor: 'humiditySensor',
  CapabilityKind.motionSensor: 'motionSensor',
  CapabilityKind.contactSensor: 'contactSensor',
  CapabilityKind.camera: 'camera',
  CapabilityKind.unknown: 'unknown',
};

_ThermostatConfig _$ThermostatConfigFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ThermostatConfig', json, ($checkedConvert) {
  final val = _ThermostatConfig(
    minSetpoint: $checkedConvert('minSetpoint', (v) => (v as num).toDouble()),
    maxSetpoint: $checkedConvert('maxSetpoint', (v) => (v as num).toDouble()),
    step: $checkedConvert('step', (v) => (v as num).toDouble()),
    modes: $checkedConvert(
      'modes',
      (v) => (v as List<dynamic>)
          .map((e) => $enumDecode(_$ThermostatModeEnumMap, e))
          .toList(),
    ),
    fanModes: $checkedConvert(
      'fanModes',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => $enumDecode(_$FanModeEnumMap, e))
              .toList() ??
          const <FanMode>[],
    ),
  );
  return val;
});

Map<String, dynamic> _$ThermostatConfigToJson(_ThermostatConfig instance) =>
    <String, dynamic>{
      'minSetpoint': instance.minSetpoint,
      'maxSetpoint': instance.maxSetpoint,
      'step': instance.step,
      'modes': instance.modes.map((e) => _$ThermostatModeEnumMap[e]!).toList(),
      'fanModes': instance.fanModes.map((e) => _$FanModeEnumMap[e]!).toList(),
    };

const _$ThermostatModeEnumMap = {
  ThermostatMode.off: 'off',
  ThermostatMode.heat: 'heat',
  ThermostatMode.cool: 'cool',
  ThermostatMode.auto: 'auto',
};

const _$FanModeEnumMap = {
  FanMode.auto: 'auto',
  FanMode.low: 'low',
  FanMode.medium: 'medium',
  FanMode.high: 'high',
};

_ColorTemperatureConfig _$ColorTemperatureConfigFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ColorTemperatureConfig', json, ($checkedConvert) {
  final val = _ColorTemperatureConfig(
    minKelvin: $checkedConvert('minKelvin', (v) => (v as num).toInt()),
    maxKelvin: $checkedConvert('maxKelvin', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$ColorTemperatureConfigToJson(
  _ColorTemperatureConfig instance,
) => <String, dynamic>{
  'minKelvin': instance.minKelvin,
  'maxKelvin': instance.maxKelvin,
};

_CameraConfig _$CameraConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CameraConfig', json, ($checkedConvert) {
      final val = _CameraConfig(
        streams: $checkedConvert(
          'streams',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => CameraStream.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const <CameraStream>[],
        ),
        snapshotUrl: $checkedConvert('snapshotUrl', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CameraConfigToJson(_CameraConfig instance) =>
    <String, dynamic>{
      'streams': instance.streams.map((e) => e.toJson()).toList(),
      'snapshotUrl': ?instance.snapshotUrl,
    };

_CameraStream _$CameraStreamFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CameraStream', json, ($checkedConvert) {
      final val = _CameraStream(
        protocol: $checkedConvert('protocol', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CameraStreamToJson(_CameraStream instance) =>
    <String, dynamic>{'protocol': instance.protocol, 'url': instance.url};
