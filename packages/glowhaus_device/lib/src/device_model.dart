import 'dart:collection';
import 'dart:math';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:meta/meta.dart';

/// The definition of one virtual device: what it is and how it starts.
@immutable
class DeviceSpec {
  const new({
    required this.descriptor,
    required this.initialState,
    this.online = true,
    this.onWatts = 0,
  });

  final DeviceDescriptor descriptor;

  /// Initial state keyed by capability id.
  final Map<String, CapabilityState> initialState;

  final bool online;

  /// What a `powerMeter` reads while the device is switched on.
  final double onWatts;
}

/// The behaviour of one device, with no I/O: it takes `set` payloads and
/// answers with `ack` payloads and a new state, exactly as section 8 of
/// `docs/protocol.md` prescribes (atomic commands, the documented error
/// codes, expiry, idempotent redelivery), and derives readings (power
/// follows the switch, a thermostat's action follows its mode and the room).
class DeviceModel {
  new(this.spec)
    : online = spec.online,
      state = Map.of(spec.initialState),
      _restingCelsius = spec.initialState.values
          .whereType<TemperatureSensorState>()
          .firstOrNull
          ?.celsius {
    _derive();
  }

  static const int _rememberedCommands = 8;
  static const int _positionStep = 5;

  final DeviceSpec spec;
  final Map<String, CapabilityState> state;
  final double? _restingCelsius;
  final LinkedHashMap<String, AckPayload> _handled = LinkedHashMap();

  bool online;

  String get id => spec.descriptor.id;

  Map<String, CapabilityState> snapshot() => Map.unmodifiable(Map.of(state));

  bool get isMoving => state.values.whereType<PositionState>().any(
    (position) => position.moving,
  );

  /// Handles a `set` the way section 8 of the protocol prescribes.
  ///
  /// Returns the ack to publish and whether the state changed (false for a
  /// rejected command and for a redelivered one, which gets its original
  /// ack again without being applied twice).
  ({AckPayload ack, bool applied}) handle(
    SetPayload payload, {
    required DateTime now,
    required bool Function() shouldFail,
  }) {
    final previous = _handled[payload.commandId];
    if (previous != null) return (ack: previous, applied: false);

    final (:ack, :applied) = _evaluate(
      payload,
      now: now,
      shouldFail: shouldFail,
    );
    _handled[payload.commandId] = ack;
    if (_handled.length > _rememberedCommands) {
      _handled.remove(_handled.keys.first);
    }
    return (ack: ack, applied: applied);
  }

  ({AckPayload ack, bool applied}) _evaluate(
    SetPayload payload, {
    required DateTime now,
    required bool Function() shouldFail,
  }) {
    ({AckPayload ack, bool applied}) fail(
      ProtocolErrorCode code,
      String message,
    ) => (
      ack: AckPayload(
        commandId: payload.commandId,
        ok: false,
        ts: now.millisecondsSinceEpoch,
        error: AckError(code: code, message: message),
      ),
      applied: false,
    );

    if (payload.isExpired(now)) {
      return fail(ProtocolErrorCode.expired, 'command is older than 10 s');
    }
    final (:patches, :error) = payload.decode(spec.descriptor.capabilities);
    if (error != null) return fail(error, 'rejected: ${error.name}');
    if (shouldFail()) {
      return fail(ProtocolErrorCode.busy, 'device is busy');
    }

    for (final MapEntry(key: id, value: patch) in patches.entries) {
      final next = patch.applyTo(state[id]);
      if (next != null) state[id] = next;
    }
    _derive();
    return (
      ack: AckPayload(
        commandId: payload.commandId,
        ok: true,
        ts: now.millisecondsSinceEpoch,
      ),
      applied: true,
    );
  }

  /// Advances moving covers by one step. Returns whether anything changed.
  bool stepPositions() {
    var changed = false;
    for (final MapEntry(:key, :value) in state.entries.toList()) {
      if (value is! PositionState || !value.moving) continue;
      final delta = value.target - value.position;
      final position = delta.abs() <= _positionStep
          ? value.target
          : value.position + _positionStep * delta.sign;
      state[key] = value.copyWith(
        position: position,
        moving: position != value.target,
      );
      changed = true;
    }
    return changed;
  }

  /// Simulates the passing of time: power noise, temperature drift, motion.
  /// Returns whether anything changed.
  bool ambientTick(Random random, {required Duration elapsed, DateTime? now}) {
    var changed = false;
    final thermostat = state.values.whereType<ThermostatState>().firstOrNull;

    for (final MapEntry(:key, :value) in state.entries.toList()) {
      switch (value) {
        case PowerMeterState(:final watts, :final energyKwh) when watts > 0:
          final noisy = spec.onWatts * (1 + 0.04 * (random.nextDouble() - 0.5));
          final energy =
              (energyKwh ?? 0) +
              noisy *
                  elapsed.inMilliseconds /
                  Duration.millisecondsPerHour /
                  1000;
          state[key] = PowerMeterState(
            watts: _round(noisy),
            energyKwh: double.parse(energy.toStringAsFixed(4)),
          );
          changed = true;
        case TemperatureSensorState(:final celsius):
          final next = thermostat == null
              ? _wander(celsius, random)
              : _climate(celsius, thermostat.action);
          if (next != celsius) {
            state[key] = TemperatureSensorState(celsius: next);
            changed = true;
          }
        case HumiditySensorState(:final percent) when random.nextDouble() < 0.3:
          final next = (percent + (random.nextBool() ? 1 : -1)).clamp(20, 80);
          state[key] = HumiditySensorState(percent: next.toDouble());
          changed = true;
        case MotionSensorState(:final motion, :final lastMotionAt)
            when random.nextDouble() < 0.15:
          state[key] = MotionSensorState(
            motion: !motion,
            lastMotionAt: !motion
                ? now?.millisecondsSinceEpoch ?? lastMotionAt
                : lastMotionAt,
          );
          changed = true;
        default:
      }
    }
    if (changed) _derive();
    return changed;
  }

  /// Recomputes readings that follow from other state.
  void _derive() {
    final on = state.values.whereType<OnOffState>().any((s) => s.on);
    final celsius = state.values
        .whereType<TemperatureSensorState>()
        .firstOrNull
        ?.celsius;

    for (final MapEntry(:key, :value) in state.entries.toList()) {
      switch (value) {
        case PowerMeterState(:final watts):
          if (!on) {
            state[key] = value.copyWith(watts: 0);
          } else if (watts == 0) {
            state[key] = value.copyWith(watts: spec.onWatts);
          }
        case ThermostatState(:final mode, :final setpoint) when celsius != null:
          final heating = setpoint > celsius;
          final cooling = setpoint < celsius;
          state[key] = value.copyWith(
            action: switch (mode) {
              ThermostatMode.heat when heating => ThermostatAction.heating,
              ThermostatMode.cool when cooling => ThermostatAction.cooling,
              ThermostatMode.auto when heating => ThermostatAction.heating,
              ThermostatMode.auto when cooling => ThermostatAction.cooling,
              _ => ThermostatAction.idle,
            },
          );
        default:
      }
    }
  }

  double _climate(double celsius, ThermostatAction action) {
    final resting = _restingCelsius ?? celsius;
    return _round(switch (action) {
      ThermostatAction.heating => celsius + 0.1,
      ThermostatAction.cooling => celsius - 0.1,
      ThermostatAction.idle when celsius < resting - 0.05 => celsius + 0.1,
      ThermostatAction.idle when celsius > resting + 0.05 => celsius - 0.1,
      ThermostatAction.idle => celsius,
    });
  }

  double _wander(double celsius, Random random) => random.nextDouble() < 0.3
      ? _round(celsius + (random.nextBool() ? 0.1 : -0.1))
      : celsius;

  static double _round(double value) => (value * 10).round() / 10;
}
