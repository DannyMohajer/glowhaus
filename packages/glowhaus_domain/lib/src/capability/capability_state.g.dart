// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capability_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnOffState _$OnOffStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OnOffState', json, ($checkedConvert) {
      final val = OnOffState(
        on: $checkedConvert('on', (v) => v as bool),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$OnOffStateToJson(OnOffState instance) =>
    <String, dynamic>{'on': instance.on, 'kind': instance.$type};

BrightnessState _$BrightnessStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BrightnessState', json, ($checkedConvert) {
      final val = BrightnessState(
        level: $checkedConvert('level', (v) => (v as num).toInt()),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$BrightnessStateToJson(BrightnessState instance) =>
    <String, dynamic>{'level': instance.level, 'kind': instance.$type};

ColorState _$ColorStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ColorState', json, ($checkedConvert) {
      final val = ColorState(
        hue: $checkedConvert('hue', (v) => (v as num).toInt()),
        saturation: $checkedConvert('saturation', (v) => (v as num).toInt()),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ColorStateToJson(ColorState instance) =>
    <String, dynamic>{
      'hue': instance.hue,
      'saturation': instance.saturation,
      'kind': instance.$type,
    };

ColorTemperatureState _$ColorTemperatureStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ColorTemperatureState', json, ($checkedConvert) {
  final val = ColorTemperatureState(
    kelvin: $checkedConvert('kelvin', (v) => (v as num).toInt()),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ColorTemperatureStateToJson(
  ColorTemperatureState instance,
) => <String, dynamic>{'kelvin': instance.kelvin, 'kind': instance.$type};

PositionState _$PositionStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PositionState', json, ($checkedConvert) {
      final val = PositionState(
        position: $checkedConvert('position', (v) => (v as num).toInt()),
        target: $checkedConvert('target', (v) => (v as num).toInt()),
        moving: $checkedConvert('moving', (v) => v as bool? ?? false),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$PositionStateToJson(PositionState instance) =>
    <String, dynamic>{
      'position': instance.position,
      'target': instance.target,
      'moving': instance.moving,
      'kind': instance.$type,
    };

ThermostatState _$ThermostatStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ThermostatState', json, ($checkedConvert) {
      final val = ThermostatState(
        setpoint: $checkedConvert('setpoint', (v) => (v as num).toDouble()),
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecode(_$ThermostatModeEnumMap, v),
        ),
        fan: $checkedConvert(
          'fan',
          (v) => $enumDecodeNullable(_$FanModeEnumMap, v),
        ),
        action: $checkedConvert(
          'action',
          (v) =>
              $enumDecodeNullable(_$ThermostatActionEnumMap, v) ??
              ThermostatAction.idle,
        ),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ThermostatStateToJson(ThermostatState instance) =>
    <String, dynamic>{
      'setpoint': instance.setpoint,
      'mode': _$ThermostatModeEnumMap[instance.mode]!,
      'fan': ?_$FanModeEnumMap[instance.fan],
      'action': _$ThermostatActionEnumMap[instance.action]!,
      'kind': instance.$type,
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

const _$ThermostatActionEnumMap = {
  ThermostatAction.idle: 'idle',
  ThermostatAction.heating: 'heating',
  ThermostatAction.cooling: 'cooling',
};

PowerMeterState _$PowerMeterStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PowerMeterState', json, ($checkedConvert) {
      final val = PowerMeterState(
        watts: $checkedConvert('watts', (v) => (v as num).toDouble()),
        energyKwh: $checkedConvert('energyKwh', (v) => (v as num?)?.toDouble()),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$PowerMeterStateToJson(PowerMeterState instance) =>
    <String, dynamic>{
      'watts': instance.watts,
      'energyKwh': ?instance.energyKwh,
      'kind': instance.$type,
    };

LockState _$LockStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LockState', json, ($checkedConvert) {
      final val = LockState(
        locked: $checkedConvert('locked', (v) => v as bool),
        jammed: $checkedConvert('jammed', (v) => v as bool? ?? false),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$LockStateToJson(LockState instance) => <String, dynamic>{
  'locked': instance.locked,
  'jammed': instance.jammed,
  'kind': instance.$type,
};

TemperatureSensorState _$TemperatureSensorStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TemperatureSensorState', json, ($checkedConvert) {
  final val = TemperatureSensorState(
    celsius: $checkedConvert('celsius', (v) => (v as num).toDouble()),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$TemperatureSensorStateToJson(
  TemperatureSensorState instance,
) => <String, dynamic>{'celsius': instance.celsius, 'kind': instance.$type};

HumiditySensorState _$HumiditySensorStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HumiditySensorState', json, ($checkedConvert) {
      final val = HumiditySensorState(
        percent: $checkedConvert('percent', (v) => (v as num).toDouble()),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$HumiditySensorStateToJson(
  HumiditySensorState instance,
) => <String, dynamic>{'percent': instance.percent, 'kind': instance.$type};

MotionSensorState _$MotionSensorStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MotionSensorState', json, ($checkedConvert) {
      final val = MotionSensorState(
        motion: $checkedConvert('motion', (v) => v as bool),
        lastMotionAt: $checkedConvert(
          'lastMotionAt',
          (v) => (v as num?)?.toInt(),
        ),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$MotionSensorStateToJson(MotionSensorState instance) =>
    <String, dynamic>{
      'motion': instance.motion,
      'lastMotionAt': ?instance.lastMotionAt,
      'kind': instance.$type,
    };

ContactSensorState _$ContactSensorStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ContactSensorState', json, ($checkedConvert) {
      final val = ContactSensorState(
        open: $checkedConvert('open', (v) => v as bool),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ContactSensorStateToJson(ContactSensorState instance) =>
    <String, dynamic>{'open': instance.open, 'kind': instance.$type};

CameraState _$CameraStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CameraState', json, ($checkedConvert) {
      final val = CameraState(
        streaming: $checkedConvert('streaming', (v) => v as bool),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$CameraStateToJson(CameraState instance) =>
    <String, dynamic>{'streaming': instance.streaming, 'kind': instance.$type};
