// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capability_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnOffPatch _$OnOffPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OnOffPatch', json, ($checkedConvert) {
      final val = OnOffPatch(
        on: $checkedConvert('on', (v) => v as bool),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$OnOffPatchToJson(OnOffPatch instance) =>
    <String, dynamic>{'on': instance.on, 'kind': instance.$type};

BrightnessPatch _$BrightnessPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BrightnessPatch', json, ($checkedConvert) {
      final val = BrightnessPatch(
        level: $checkedConvert('level', (v) => (v as num).toInt()),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$BrightnessPatchToJson(BrightnessPatch instance) =>
    <String, dynamic>{'level': instance.level, 'kind': instance.$type};

ColorPatch _$ColorPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ColorPatch', json, ($checkedConvert) {
      final val = ColorPatch(
        hue: $checkedConvert('hue', (v) => (v as num?)?.toInt()),
        saturation: $checkedConvert('saturation', (v) => (v as num?)?.toInt()),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ColorPatchToJson(ColorPatch instance) =>
    <String, dynamic>{
      'hue': ?instance.hue,
      'saturation': ?instance.saturation,
      'kind': instance.$type,
    };

ColorTemperaturePatch _$ColorTemperaturePatchFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ColorTemperaturePatch', json, ($checkedConvert) {
  final val = ColorTemperaturePatch(
    kelvin: $checkedConvert('kelvin', (v) => (v as num).toInt()),
    $type: $checkedConvert('kind', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ColorTemperaturePatchToJson(
  ColorTemperaturePatch instance,
) => <String, dynamic>{'kelvin': instance.kelvin, 'kind': instance.$type};

PositionPatch _$PositionPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PositionPatch', json, ($checkedConvert) {
      final val = PositionPatch(
        target: $checkedConvert('target', (v) => (v as num?)?.toInt()),
        stop: $checkedConvert('stop', (v) => v as bool?),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$PositionPatchToJson(PositionPatch instance) =>
    <String, dynamic>{
      'target': ?instance.target,
      'stop': ?instance.stop,
      'kind': instance.$type,
    };

ThermostatPatch _$ThermostatPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ThermostatPatch', json, ($checkedConvert) {
      final val = ThermostatPatch(
        setpoint: $checkedConvert('setpoint', (v) => (v as num?)?.toDouble()),
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecodeNullable(_$ThermostatModeEnumMap, v),
        ),
        fan: $checkedConvert(
          'fan',
          (v) => $enumDecodeNullable(_$FanModeEnumMap, v),
        ),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$ThermostatPatchToJson(ThermostatPatch instance) =>
    <String, dynamic>{
      'setpoint': ?instance.setpoint,
      'mode': ?_$ThermostatModeEnumMap[instance.mode],
      'fan': ?_$FanModeEnumMap[instance.fan],
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

LockPatch _$LockPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LockPatch', json, ($checkedConvert) {
      final val = LockPatch(
        locked: $checkedConvert('locked', (v) => v as bool),
        $type: $checkedConvert('kind', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'kind'});

Map<String, dynamic> _$LockPatchToJson(LockPatch instance) => <String, dynamic>{
  'locked': instance.locked,
  'kind': instance.$type,
};
