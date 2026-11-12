import 'package:flutter/widgets.dart' hide LockState;
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:intl/intl.dart';

/// How a device is shown: icon, colour, status line, and what its main
/// switch does. Everything is derived from capabilities; the device type
/// only picks an icon and a filter group.

/// Locale-aware number formatting for readings.
class Readings {
  new(this.l10n)
    : _oneDecimal = NumberFormat('0.0', l10n.localeName),
      _whole = NumberFormat.decimalPattern(l10n.localeName)
        ..maximumFractionDigits = 0,
      _energy = NumberFormat.decimalPattern(l10n.localeName)
        ..minimumFractionDigits = 1
        ..maximumFractionDigits = 1;

  factory of(BuildContext context) => Readings(AppLocalizations.of(context));

  final AppLocalizations l10n;
  final NumberFormat _oneDecimal;
  final NumberFormat _whole;
  final NumberFormat _energy;

  String temperature(double celsius) =>
      l10n.temperatureValue(_oneDecimal.format(celsius));

  String watts(double watts) => l10n.wattsValue(_whole.format(watts));

  String energy(double kwh) => l10n.kwhValue(_energy.format(kwh));

  String percent(num value) => l10n.percentValue(value.round());
}

/// The one switch shown on a device's tile.
@immutable
class PrimaryToggle {
  const new({required this.on, required this.patchesFor});

  final bool on;

  /// The command that turns the device on or off.
  final Map<String, CapabilityPatch> Function({required bool on}) patchesFor;
}

/// What the tile switch of [device] controls, or null if it has none.
///
/// On/off channels first (all of them together), then a lock, then a
/// thermostat (off, or back to the mode it last ran in).
PrimaryToggle? primaryToggle(Device device) {
  final switches = device.capabilitiesOf(CapabilityKind.onOff).toList();
  if (switches.isNotEmpty) {
    return PrimaryToggle(
      on: device.isOn,
      patchesFor: ({required on}) => {
        for (final capability in switches)
          capability.id: CapabilityPatch.onOff(on: on),
      },
    );
  }

  final lock = device.capabilitiesOf(CapabilityKind.lock).firstOrNull;
  if (lock != null) {
    return PrimaryToggle(
      on: device.stateOf<LockState>(lock.id)?.locked ?? false,
      patchesFor: ({required on}) => {
        lock.id: CapabilityPatch.lock(locked: on),
      },
    );
  }

  final thermostat = device
      .capabilitiesOf(CapabilityKind.thermostat)
      .firstOrNull;
  if (thermostat != null) {
    final modes =
        thermostat.thermostatConfig?.modes ??
        const [ThermostatMode.off, ThermostatMode.heat];
    final state = device.stateOf<ThermostatState>(thermostat.id);
    final mode = state?.mode;
    // Resume the last active mode the device reported; fall back to the
    // first mode it supports when it never ran or does not report one.
    final onMode = switch (state?.lastActiveMode) {
      final last? when last != ThermostatMode.off && modes.contains(last) =>
        last,
      _ => modes.firstWhere(
        (mode) => mode != ThermostatMode.off,
        orElse: () => ThermostatMode.heat,
      ),
    };
    return PrimaryToggle(
      on: mode != null && mode != ThermostatMode.off,
      patchesFor: ({required on}) => {
        thermostat.id: CapabilityPatch.thermostat(
          mode: on ? onMode : ThermostatMode.off,
        ),
      },
    );
  }
  return null;
}

/// Joins short status parts with the language's separator.
String joinParts(AppLocalizations l10n, Iterable<String> parts) =>
    parts.join(l10n.listSeparator);

/// Whether the tile should look "lit".
bool deviceLooksOn(Device device) {
  final toggle = primaryToggle(device);
  if (toggle != null) return toggle.on;
  final position = device.firstState<PositionState>();
  if (position != null) return position.target > 0;
  return (device.firstState<MotionSensorState>()?.motion ?? false) ||
      (device.firstState<ContactSensorState>()?.open ?? false);
}

IconData deviceIcon(Device device) => switch (device.type) {
  DeviceType.light =>
    device.has(CapabilityKind.color)
        ? GlowIcons.lampFloor
        : device.has(CapabilityKind.brightness)
        ? GlowIcons.lampCeiling
        : GlowIcons.lightbulb,
  DeviceType.wallSwitch => GlowIcons.toggleRight,
  DeviceType.curtain => GlowIcons.blinds,
  DeviceType.thermostat => GlowIcons.thermometer,
  DeviceType.outlet => GlowIcons.plug,
  DeviceType.lock =>
    (device.firstState<LockState>()?.locked ?? true)
        ? GlowIcons.lock
        : GlowIcons.lockOpen,
  DeviceType.sensor =>
    device.has(CapabilityKind.motionSensor)
        ? GlowIcons.radar
        : device.has(CapabilityKind.contactSensor)
        ? ((device.firstState<ContactSensorState>()?.open ?? false)
              ? GlowIcons.doorOpen
              : GlowIcons.doorClosed)
        : GlowIcons.droplets,
  DeviceType.camera => GlowIcons.cctv,
  DeviceType.unknown => GlowIcons.zap,
};

/// The colour of the icon disc while the device is on. Null is the accent.
Color? deviceActiveColor(GlowhausColors colors, Device device) =>
    switch (device.type) {
      DeviceType.light => colors.lamp,
      DeviceType.outlet => colors.power,
      DeviceType.thermostat =>
        device.firstState<ThermostatState>()?.mode == ThermostatMode.cool
            ? colors.cool
            : colors.heat,
      DeviceType.curtain => colors.cool,
      _ => null,
    };

IconData roomIcon(RoomKind kind) => switch (kind) {
  RoomKind.livingRoom => GlowIcons.sofa,
  RoomKind.bedroom => GlowIcons.bed,
  RoomKind.kitchen => GlowIcons.cookingPot,
  RoomKind.entrance => GlowIcons.doorOpen,
  RoomKind.bathroom => GlowIcons.bath,
  RoomKind.office => GlowIcons.briefcase,
  RoomKind.other => GlowIcons.house,
};

String deviceTypeLabel(AppLocalizations l10n, DeviceType type) =>
    switch (type) {
      DeviceType.light => l10n.typeLights,
      DeviceType.wallSwitch => l10n.typeSwitches,
      DeviceType.curtain => l10n.typeCurtains,
      DeviceType.thermostat => l10n.typeClimate,
      DeviceType.outlet => l10n.typeOutlets,
      DeviceType.lock => l10n.typeLocks,
      DeviceType.sensor => l10n.typeSensors,
      DeviceType.camera => l10n.typeCameras,
      DeviceType.unknown => l10n.typeOther,
    };

/// The one-line status under a device's name.
String deviceStatus(Readings readings, Device device) {
  final l10n = readings.l10n;
  if (device.isOffline) return l10n.stateOffline;
  if (device.state.isEmpty) return l10n.stateUnknown;

  final thermostat = device.firstState<ThermostatState>();
  if (thermostat != null) {
    if (thermostat.mode == ThermostatMode.off) return l10n.stateOff;
    final action = switch (thermostat.action) {
      ThermostatAction.heating => l10n.stateHeating,
      ThermostatAction.cooling => l10n.stateCooling,
      ThermostatAction.idle => l10n.stateIdle,
    };
    return joinParts(l10n, [readings.temperature(thermostat.setpoint), action]);
  }

  final lock = device.firstState<LockState>();
  if (lock != null) {
    return lock.jammed
        ? l10n.stateJammed
        : (lock.locked ? l10n.stateLocked : l10n.stateUnlocked);
  }

  final position = device.firstState<PositionState>();
  if (position != null) {
    if (position.moving) {
      return position.target > position.position
          ? l10n.stateOpening
          : l10n.stateClosing;
    }
    return position.position == 0
        ? l10n.stateClosed
        : l10n.stateOpenPercent(position.position);
  }

  final switches = device.state.values.whereType<OnOffState>().toList();
  if (switches.length > 1) {
    final on = switches.where((s) => s.on).length;
    return on == 0 ? l10n.stateOff : l10n.stateChannelsOn(on, switches.length);
  }
  if (switches.length == 1) {
    if (!switches.single.on) return l10n.stateOff;
    final power = device.firstState<PowerMeterState>();
    if (power != null) {
      return joinParts(l10n, [l10n.stateOn, readings.watts(power.watts)]);
    }
    final brightness = device.firstState<BrightnessState>();
    return brightness == null
        ? l10n.stateOn
        : l10n.stateOnLevel(brightness.level);
  }

  final temperature = device.firstState<TemperatureSensorState>();
  if (temperature != null) {
    final humidity = device.firstState<HumiditySensorState>();
    final celsius = readings.temperature(temperature.celsius);
    return humidity == null
        ? celsius
        : joinParts(l10n, [celsius, readings.percent(humidity.percent)]);
  }
  final motion = device.firstState<MotionSensorState>();
  if (motion != null) {
    return motion.motion ? l10n.stateMotion : l10n.stateNoMotion;
  }
  final contact = device.firstState<ContactSensorState>();
  if (contact != null) return contact.open ? l10n.stateOpen : l10n.stateClosed;
  if (device.firstState<CameraState>() != null) return l10n.stateLive;
  return l10n.stateUnknown;
}
