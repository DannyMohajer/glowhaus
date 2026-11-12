import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability.dart';
import 'package:glowhaus_domain/src/capability/capability_kind.dart';
import 'package:glowhaus_domain/src/capability/capability_state.dart';
import 'package:glowhaus_domain/src/protocol/protocol_error.dart';

part 'capability_patch.freezed.dart';
part 'capability_patch.g.dart';

const String _kindKey = 'kind';

/// The writable fields of one capability that a command wants to change.
///
/// Only writable kinds have a patch. Null fields are left untouched.
@Freezed(unionKey: _kindKey)
sealed class CapabilityPatch with _$CapabilityPatch {
  const factory onOff({required bool on}) = OnOffPatch;

  const factory brightness({required int level}) = BrightnessPatch;

  const factory color({int? hue, int? saturation}) = ColorPatch;

  const factory colorTemperature({required int kelvin}) = ColorTemperaturePatch;

  /// Either a new [target] or `stop: true`.
  const factory position({int? target, bool? stop}) = PositionPatch;

  const factory thermostat({
    double? setpoint,
    ThermostatMode? mode,
    FanMode? fan,
  }) = ThermostatPatch;

  const factory lock({required bool locked}) = LockPatch;

  /// Tagged JSON (includes a `kind` key). Used for scenes.
  factory fromJson(Map<String, dynamic> json) =>
      _$CapabilityPatchFromJson(json);

  const new _();

  /// Parses the untagged wire object for a capability of the given [kind].
  /// Returns null if the kind is not writable or the object is malformed.
  static CapabilityPatch? fromWire(
    CapabilityKind kind,
    Map<String, dynamic> json,
  ) {
    if (!kind.isWritable) return null;
    try {
      return CapabilityPatch.fromJson(<String, dynamic>{
        ...json,
        _kindKey: kind.name,
      });
    } on CheckedFromJsonException {
      return null;
    }
  }

  /// The untagged object sent inside `set`.
  Map<String, dynamic> toWire() => toJson()..remove(_kindKey);

  CapabilityKind get kind => switch (this) {
    OnOffPatch() => CapabilityKind.onOff,
    BrightnessPatch() => CapabilityKind.brightness,
    ColorPatch() => CapabilityKind.color,
    ColorTemperaturePatch() => CapabilityKind.colorTemperature,
    PositionPatch() => CapabilityKind.position,
    ThermostatPatch() => CapabilityKind.thermostat,
    LockPatch() => CapabilityKind.lock,
  };

  /// Checks this patch against the capability it targets.
  ///
  /// Returns null when valid, otherwise the error a device would ack with.
  ProtocolErrorCode? validate(Capability capability) {
    if (!capability.kind.isWritable) return ProtocolErrorCode.readOnly;
    if (capability.kind != kind) return ProtocolErrorCode.invalidPayload;
    return switch (this) {
      OnOffPatch() || LockPatch() => null,
      BrightnessPatch(:final level) => _percent(level),
      ColorPatch(:final hue, :final saturation) =>
        hue == null && saturation == null
            ? ProtocolErrorCode.invalidPayload
            : (hue != null && (hue < 0 || hue > 359)) ||
                  (saturation != null && _percent(saturation) != null)
            ? ProtocolErrorCode.outOfRange
            : null,
      ColorTemperaturePatch(:final kelvin) => _validateKelvin(
        kelvin,
        capability.colorTemperatureConfig,
      ),
      PositionPatch(:final target, :final stop) =>
        (target == null) == (stop == null) || stop == false
            ? ProtocolErrorCode.invalidPayload
            : target != null
            ? _percent(target)
            : null,
      final ThermostatPatch patch => _validateThermostat(
        patch,
        capability.thermostatConfig,
      ),
    };
  }

  /// The state a device would report after applying this patch to [current].
  ///
  /// Returns [current] unchanged when the kinds do not match.
  CapabilityState? applyTo(CapabilityState? current) => switch ((
    this,
    current,
  )) {
    (OnOffPatch(:final on), final OnOffState s) => s.copyWith(on: on),
    (BrightnessPatch(:final level), final BrightnessState s) => s.copyWith(
      level: level,
    ),
    (ColorPatch(:final hue, :final saturation), final ColorState s) =>
      s.copyWith(hue: hue ?? s.hue, saturation: saturation ?? s.saturation),
    (ColorTemperaturePatch(:final kelvin), final ColorTemperatureState s) =>
      s.copyWith(kelvin: kelvin),
    (PositionPatch(:final target?), final PositionState s) => s.copyWith(
      target: target,
      moving: target != s.position,
    ),
    (PositionPatch(stop: true), final PositionState s) => s.copyWith(
      target: s.position,
      moving: false,
    ),
    (final ThermostatPatch p, final ThermostatState s) => s.copyWith(
      setpoint: p.setpoint ?? s.setpoint,
      mode: p.mode ?? s.mode,
      fan: p.fan ?? s.fan,
    ),
    (LockPatch(:final locked), final LockState s) => s.copyWith(locked: locked),
    _ => current,
  };

  /// Whether a reported [state] already reflects what this patch asked for.
  ///
  /// This is what ends optimistic display: a pending patch is dropped once
  /// the device reports a matching state.
  bool isSatisfiedBy(CapabilityState? state) => switch ((this, state)) {
    (OnOffPatch(:final on), final OnOffState s) => s.on == on,
    (BrightnessPatch(:final level), final BrightnessState s) =>
      s.level == level,
    (ColorPatch(:final hue, :final saturation), final ColorState s) =>
      (hue == null || hue == s.hue) &&
          (saturation == null || saturation == s.saturation),
    (ColorTemperaturePatch(:final kelvin), final ColorTemperatureState s) =>
      s.kelvin == kelvin,
    (PositionPatch(:final target?), final PositionState s) =>
      s.target == target,
    (PositionPatch(stop: true), final PositionState s) => !s.moving,
    (final ThermostatPatch p, final ThermostatState s) =>
      (p.setpoint == null || p.setpoint == s.setpoint) &&
          (p.mode == null || p.mode == s.mode) &&
          (p.fan == null || p.fan == s.fan),
    (LockPatch(:final locked), final LockState s) => s.locked == locked,
    _ => false,
  };

  static ProtocolErrorCode? _percent(int value) =>
      value < 0 || value > 100 ? ProtocolErrorCode.outOfRange : null;

  static ProtocolErrorCode? _validateKelvin(
    int kelvin,
    ColorTemperatureConfig? config,
  ) {
    if (config == null) return null;
    return kelvin < config.minKelvin || kelvin > config.maxKelvin
        ? ProtocolErrorCode.outOfRange
        : null;
  }

  static ProtocolErrorCode? _validateThermostat(
    ThermostatPatch patch,
    ThermostatConfig? config,
  ) {
    final ThermostatPatch(:setpoint, :mode, :fan) = patch;
    if (setpoint == null && mode == null && fan == null) {
      return ProtocolErrorCode.invalidPayload;
    }
    if (config == null) return null;
    if (setpoint != null) {
      if (setpoint < config.minSetpoint || setpoint > config.maxSetpoint) {
        return ProtocolErrorCode.outOfRange;
      }
      final steps = (setpoint - config.minSetpoint) / config.step;
      if ((steps - steps.round()).abs() > 1e-6) {
        return ProtocolErrorCode.outOfRange;
      }
    }
    if (mode != null && !config.modes.contains(mode)) {
      return ProtocolErrorCode.outOfRange;
    }
    if (fan != null && !config.fanModes.contains(fan)) {
      return ProtocolErrorCode.outOfRange;
    }
    return null;
  }
}
