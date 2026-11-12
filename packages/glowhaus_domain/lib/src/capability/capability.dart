import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability_kind.dart';

part 'capability.freezed.dart';
part 'capability.g.dart';

/// One capability instance of a device, as announced in its descriptor.
///
/// [id] is the key used in state and commands. It equals the kind name when
/// the device has a single capability of that kind.
@freezed
abstract class Capability with _$Capability {
  const factory({
    required String id,
    @JsonKey(unknownEnumValue: CapabilityKind.unknown)
    required CapabilityKind kind,
    String? label,

    /// Optional translation key for the default [label].
    String? labelKey,
    @Default(<String, dynamic>{}) Map<String, dynamic> config,
  }) = _Capability;

  /// A capability whose id is its kind name.
  factory of(
    CapabilityKind kind, {
    Map<String, dynamic> config = const <String, dynamic>{},
  }) => Capability(id: kind.name, kind: kind, config: config);

  factory fromJson(Map<String, dynamic> json) => _$CapabilityFromJson(json);

  const new _();

  /// Typed view of [config] for a thermostat, or null if absent or malformed.
  ThermostatConfig? get thermostatConfig => kind == CapabilityKind.thermostat
      ? _tryParse(ThermostatConfig.fromJson)
      : null;

  ColorTemperatureConfig? get colorTemperatureConfig =>
      kind == CapabilityKind.colorTemperature
      ? _tryParse(ColorTemperatureConfig.fromJson)
      : null;

  CameraConfig? get cameraConfig =>
      kind == CapabilityKind.camera ? _tryParse(CameraConfig.fromJson) : null;

  T? _tryParse<T>(T Function(Map<String, dynamic>) parse) {
    try {
      return parse(config);
    } on CheckedFromJsonException {
      return null;
    }
  }
}

@freezed
abstract class ThermostatConfig with _$ThermostatConfig {
  const factory({
    required double minSetpoint,
    required double maxSetpoint,
    required double step,
    required List<ThermostatMode> modes,
    @Default(<FanMode>[]) List<FanMode> fanModes,
  }) = _ThermostatConfig;

  factory fromJson(Map<String, dynamic> json) =>
      _$ThermostatConfigFromJson(json);
}

@freezed
abstract class ColorTemperatureConfig with _$ColorTemperatureConfig {
  const factory({required int minKelvin, required int maxKelvin}) =
      _ColorTemperatureConfig;

  factory fromJson(Map<String, dynamic> json) =>
      _$ColorTemperatureConfigFromJson(json);
}

@freezed
abstract class CameraConfig with _$CameraConfig {
  const factory({
    @Default(<CameraStream>[]) List<CameraStream> streams,
    String? snapshotUrl,
  }) = _CameraConfig;

  factory fromJson(Map<String, dynamic> json) => _$CameraConfigFromJson(json);
}

@freezed
abstract class CameraStream with _$CameraStream {
  const factory({required String protocol, required String url}) =
      _CameraStream;

  factory fromJson(Map<String, dynamic> json) => _$CameraStreamFromJson(json);
}
