import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:meta/meta.dart';

/// What a person can do with a device's own hardware, as the devices panel
/// offers it. Separate from the plug: this is the device working, the plug
/// is its power.
enum HandAction {
  /// A lamp's, switch's, outlet's or thermostat's own button: flips its
  /// main switch.
  button,

  /// The lock's keypad, locking it.
  lock,

  /// The lock's keypad, unlocking it.
  unlock,

  /// The curtain's own wall button, opening it.
  openCurtain,

  /// The same button, closing it.
  closeCurtain,

  /// The doorbell: the camera wakes up and streams.
  doorbell,

  /// Walking past a motion sensor.
  motion,
}

/// The hand action [device] offers right now, or null when it has none.
/// Sensors that only report (a door contact, a climate sensor, a leak
/// detector) have none: their faces are there to read, not to press.
HandAction? handAction(Device device) {
  if (device.has(CapabilityKind.lock)) {
    return (device.firstState<LockState>()?.locked ?? false)
        ? HandAction.unlock
        : HandAction.lock;
  }
  final position = device.firstState<PositionState>();
  if (position != null) {
    // While it travels, the button offers the opposite of where it is going.
    final heading = position.moving ? position.target : position.position;
    return heading > 0 ? HandAction.closeCurtain : HandAction.openCurtain;
  }
  if (device.has(CapabilityKind.camera)) return HandAction.doorbell;
  if (device.has(CapabilityKind.motionSensor)) return HandAction.motion;
  if (primaryToggle(device) != null) return HandAction.button;
  return null;
}

/// What the devices panel shows.
@immutable
class DevicesPanelState {
  const new({
    this.devices = const [],
    this.traffic = const [],
    this.publishes = const {},
    this.away = false,
  });

  /// Every virtual device as the app would show it, with its availability
  /// as the device itself knows it.
  final List<Device> devices;

  /// Newest first.
  final List<MqttTraffic> traffic;

  /// How many messages each device has published since the panel opened.
  /// The cards only watch for a change: one more dot leaves the card.
  final Map<String, int> publishes;

  /// The devices run in another tab; this one has nothing to show.
  final bool away;

  DevicesPanelState copyWith({
    List<Device>? devices,
    List<MqttTraffic>? traffic,
    Map<String, int>? publishes,
    bool? away,
  }) => DevicesPanelState(
    devices: devices ?? this.devices,
    traffic: traffic ?? this.traffic,
    publishes: publishes ?? this.publishes,
    away: away ?? this.away,
  );
}

/// The device side of the demo, for the panel: the virtual devices, their
/// plugs and buttons, and the MQTT messages they exchange.
///
/// It talks to the devices directly, never through the app's repository:
/// the panel is the other end of the protocol.
class DevicesPanelCubit extends Cubit<DevicesPanelState> {
  new({
    required VirtualHome home,
    required MqttTrafficLog traffic,
    Stream<bool>? away,
    bool initiallyAway = false,
    this.trafficShown = 40,
    DateTime Function()? clock,
  }) : _home = home,
       _traffic = traffic,
       _clock = clock ?? DateTime.now,
       super(DevicesPanelState(away: initiallyAway)) {
    _refresh();
    _subscriptions = [
      home.changes.listen((_) => _refresh()),
      traffic.stream.listen(_record),
      if (away != null)
        away.listen((value) => emit(state.copyWith(away: value))),
    ];
  }

  final VirtualHome _home;
  final MqttTrafficLog _traffic;
  final DateTime Function() _clock;

  /// How many of the latest messages the panel lists.
  final int trafficShown;
  late final List<StreamSubscription<Object?>> _subscriptions;

  /// Plugs a device in or pulls the plug, as a power cut would.
  Future<void> setPlugged(String deviceId, {required bool plugged}) =>
      _home.setOnline(deviceId, online: plugged);

  /// Uses the device's own hardware ([HandAction]): a lamp's button flips
  /// its main switch, a keypad locks or unlocks, a door opens or closes, a
  /// motion sensor sees someone. The device reports the new state, with no
  /// command and no ack, and the app follows.
  Future<void> press(String deviceId) async {
    final device = _home.device(deviceId);
    if (device == null) return;
    final view = _view(device);
    final action = handAction(view);
    switch (action) {
      case null:
        return;
      case HandAction.lock || HandAction.unlock:
        final lock = view.capabilitiesOf(CapabilityKind.lock).first;
        await device.pressLocal({
          lock.id: CapabilityPatch.lock(locked: action == HandAction.lock),
        });
      case HandAction.openCurtain || HandAction.closeCurtain:
        await device.pressLocal({
          for (final position in view.capabilitiesOf(CapabilityKind.position))
            position.id: CapabilityPatch.position(
              target: action == HandAction.openCurtain ? 100 : 0,
            ),
        });
      case HandAction.doorbell:
        // Someone at the door: the camera wakes up, or goes back to sleep.
        final streaming = view.firstState<CameraState>()?.streaming ?? false;
        await device.sense({
          for (final camera in view.capabilitiesOf(CapabilityKind.camera))
            camera.id: CapabilityState.camera(streaming: !streaming),
        });
      case HandAction.motion:
        await device.sense({
          for (final sensor in view.capabilitiesOf(CapabilityKind.motionSensor))
            sensor.id: CapabilityState.motionSensor(
              motion: true,
              lastMotionAt: _clock().millisecondsSinceEpoch,
            ),
        });
      case HandAction.button:
        final toggle = primaryToggle(view)!;
        await device.pressLocal(toggle.patchesFor(on: !toggle.on));
    }
  }

  /// Counts what a device sends, so its card can show it leaving.
  void _record(MqttTraffic entry) {
    if (entry.direction == TrafficDirection.sent) {
      _published[entry.who] = (_published[entry.who] ?? 0) + 1;
    }
    _refresh();
  }

  final Map<String, int> _published = {};

  /// Presses one rocker of a multi-channel wall switch.
  Future<void> pressChannel(String deviceId, String capabilityId) async {
    final device = _home.device(deviceId);
    if (device == null) return;
    final view = _view(device);
    final on = view.stateOf<OnOffState>(capabilityId)?.on ?? false;
    await device.pressLocal({capabilityId: CapabilityPatch.onOff(on: !on)});
  }

  Device _view(VirtualDevice device) =>
      Device.fromDescriptor(
        device.spec.descriptor,
        homeId: device.homeId,
      ).copyWith(
        state: device.state,
        availability: device.online
            ? DeviceAvailability.online
            : DeviceAvailability.offline,
      );

  void _refresh() {
    if (isClosed) return;
    final entries = _traffic.entries;
    emit(
      state.copyWith(
        devices: [for (final device in _home.devices.values) _view(device)],
        publishes: Map.unmodifiable(_published),
        traffic: [
          for (
            var i = entries.length - 1;
            i >= 0 && entries.length - i <= trafficShown;
            i--
          )
            entries[i],
        ],
      ),
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await super.close();
  }
}

/// Whether the devices panel is open next to the app.
class DemoPanelCubit extends Cubit<bool> {
  new({bool open = false}) : super(open);

  void toggle() => emit(!state);

  void show() => emit(true);

  void hide() => emit(false);
}
