import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:meta/meta.dart';

/// What a device just did, as a person would say it: the plain-words side of
/// a `state` message. The devices sheet shows the latest one under the
/// devices ("Reading light · turned on · now"); the full MQTT log is one tap
/// away.
enum DeviceActivityKind {
  turnedOn,
  turnedOff,
  locked,
  unlocked,
  jammed,
  opened,
  closed,
  opening,
  closing,
  leakFound,
  driedUp,
  sawMotion,
  motionStopped,
  streaming,
  stoppedStreaming,
  heating,
  cooling,
  idle,
  reading,
  wentOffline,
  cameBack,

  /// It published, but nothing a person would notice changed (a retained
  /// state republished, a field this app does not show).
  reported,
}

/// The latest thing a device did.
@immutable
class DeviceActivity {
  const new({required this.deviceId, required this.kind, required this.at});

  final String deviceId;
  final DeviceActivityKind kind;
  final DateTime at;
}

/// What changed between [before] and [after], as one thing to say.
///
/// Capabilities are read in the order a person would notice them, the same
/// order the status line uses: power first, then the lock, the curtain, the
/// thermostat, the sensors, and plain on/off last. Readings (temperature,
/// humidity, power) are the quietest thing a device can report.
DeviceActivityKind activityKind(Device? before, Device after) {
  if (before != null && before.isOffline != after.isOffline) {
    return after.isOffline
        ? DeviceActivityKind.wentOffline
        : DeviceActivityKind.cameBack;
  }

  bool changed<T extends CapabilityState>() =>
      before?.firstState<T>() != after.firstState<T>();

  final lock = after.firstState<LockState>();
  if (lock != null && changed<LockState>()) {
    return lock.jammed
        ? DeviceActivityKind.jammed
        : lock.locked
        ? DeviceActivityKind.locked
        : DeviceActivityKind.unlocked;
  }

  final position = after.firstState<PositionState>();
  if (position != null && changed<PositionState>()) {
    if (position.moving) {
      return position.target > position.position
          ? DeviceActivityKind.opening
          : DeviceActivityKind.closing;
    }
    return position.position == 0
        ? DeviceActivityKind.closed
        : DeviceActivityKind.opened;
  }

  final thermostat = after.firstState<ThermostatState>();
  if (thermostat != null && changed<ThermostatState>()) {
    if (thermostat.mode == ThermostatMode.off) {
      return DeviceActivityKind.turnedOff;
    }
    return switch (thermostat.action) {
      ThermostatAction.heating => DeviceActivityKind.heating,
      ThermostatAction.cooling => DeviceActivityKind.cooling,
      ThermostatAction.idle => DeviceActivityKind.idle,
    };
  }

  final camera = after.firstState<CameraState>();
  if (camera != null && changed<CameraState>()) {
    return camera.streaming
        ? DeviceActivityKind.streaming
        : DeviceActivityKind.stoppedStreaming;
  }

  final contact = after.firstState<ContactSensorState>();
  if (contact != null && changed<ContactSensorState>()) {
    return contact.open ? DeviceActivityKind.opened : DeviceActivityKind.closed;
  }

  final leak = after.firstState<LeakSensorState>();
  if (leak != null && changed<LeakSensorState>()) {
    return leak.wet ? DeviceActivityKind.leakFound : DeviceActivityKind.driedUp;
  }

  final motion = after.firstState<MotionSensorState>();
  if (motion != null && changed<MotionSensorState>()) {
    return motion.motion
        ? DeviceActivityKind.sawMotion
        : DeviceActivityKind.motionStopped;
  }

  final switches = after.state.values.whereType<OnOffState>();
  if (switches.isNotEmpty &&
      before?.state.values.whereType<OnOffState>().toList() !=
          switches.toList()) {
    return switches.any((s) => s.on)
        ? DeviceActivityKind.turnedOn
        : DeviceActivityKind.turnedOff;
  }

  if (changed<TemperatureSensorState>() ||
      changed<HumiditySensorState>() ||
      changed<PowerMeterState>() ||
      changed<BrightnessState>()) {
    return DeviceActivityKind.reading;
  }
  return DeviceActivityKind.reported;
}
