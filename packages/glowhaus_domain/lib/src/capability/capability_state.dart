import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability_kind.dart';

part 'capability_state.freezed.dart';
part 'capability_state.g.dart';

const String _kindKey = 'kind';

/// The reported state of one capability. See `docs/protocol.md`, section 9.
@Freezed(unionKey: _kindKey)
sealed class CapabilityState with _$CapabilityState {
  const factory onOff({required bool on}) = OnOffState;

  const factory brightness({required int level}) = BrightnessState;

  const factory color({required int hue, required int saturation}) = ColorState;

  const factory colorTemperature({required int kelvin}) = ColorTemperatureState;

  const factory position({
    required int position,
    required int target,
    @Default(false) bool moving,
  }) = PositionState;

  const factory thermostat({
    required double setpoint,
    required ThermostatMode mode,
    FanMode? fan,
    @Default(ThermostatAction.idle) ThermostatAction action,
  }) = ThermostatState;

  const factory powerMeter({required double watts, double? energyKwh}) =
      PowerMeterState;

  const factory lock({required bool locked, @Default(false) bool jammed}) =
      LockState;

  const factory temperatureSensor({required double celsius}) =
      TemperatureSensorState;

  const factory humiditySensor({required double percent}) = HumiditySensorState;

  const factory motionSensor({required bool motion, int? lastMotionAt}) =
      MotionSensorState;

  const factory contactSensor({required bool open}) = ContactSensorState;

  const factory camera({required bool streaming}) = CameraState;

  /// Tagged JSON (includes a `kind` key). Used for app-side persistence.
  factory fromJson(Map<String, dynamic> json) =>
      _$CapabilityStateFromJson(json);

  const new _();

  /// Parses the untagged wire object of a capability of the given [kind].
  ///
  /// Returns null for unknown kinds and malformed objects, so one bad entry
  /// never poisons a whole state message. Unknown fields are ignored.
  static CapabilityState? fromWire(
    CapabilityKind kind,
    Map<String, dynamic> json,
  ) {
    if (kind == CapabilityKind.unknown) return null;
    try {
      return CapabilityState.fromJson(<String, dynamic>{
        ...json,
        _kindKey: kind.name,
      });
    } on CheckedFromJsonException {
      return null;
    }
  }

  /// The untagged object published on the wire.
  Map<String, dynamic> toWire() => toJson()..remove(_kindKey);

  CapabilityKind get kind => switch (this) {
    OnOffState() => CapabilityKind.onOff,
    BrightnessState() => CapabilityKind.brightness,
    ColorState() => CapabilityKind.color,
    ColorTemperatureState() => CapabilityKind.colorTemperature,
    PositionState() => CapabilityKind.position,
    ThermostatState() => CapabilityKind.thermostat,
    PowerMeterState() => CapabilityKind.powerMeter,
    LockState() => CapabilityKind.lock,
    TemperatureSensorState() => CapabilityKind.temperatureSensor,
    HumiditySensorState() => CapabilityKind.humiditySensor,
    MotionSensorState() => CapabilityKind.motionSensor,
    ContactSensorState() => CapabilityKind.contactSensor,
    CameraState() => CapabilityKind.camera,
  };
}
