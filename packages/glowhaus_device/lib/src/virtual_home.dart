import 'dart:async';
import 'dart:math';

import 'package:glowhaus_device/src/device_model.dart';
import 'package:glowhaus_device/src/link_config.dart';
import 'package:glowhaus_device/src/virtual_device.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';

/// A set of `VirtualDevice`s on one broker, started and tuned together.
///
/// `connectionFactory` gives each device its own connection, by device id: a
/// broker's `client()` for the in-memory case, or a new `MqttClientConnection`
/// carrying that device's own login for a real broker.
class VirtualHome {
  new({
    required this.homeId,
    required Iterable<DeviceSpec> specs,
    required MqttConnection Function(String deviceId) connectionFactory,
    SimulationConfig config = const SimulationConfig(),
    Duration stateDelay = const Duration(milliseconds: 60),
    Duration positionInterval = const Duration(milliseconds: 400),
    Duration? ambientInterval = const Duration(seconds: 2),
    Random? random,
    DateTime Function()? clock,
  }) : _config = config,
       devices = {
         for (final spec in specs)
           spec.descriptor.id: VirtualDevice(
             homeId: homeId,
             spec: spec,
             connection: connectionFactory(spec.descriptor.id),
             config: config,
             stateDelay: stateDelay,
             positionInterval: positionInterval,
             ambientInterval: ambientInterval,
             random: random,
             clock: clock,
           ),
       };

  final String homeId;
  final Map<String, VirtualDevice> devices;
  SimulationConfig _config;
  bool _started = false;

  /// Link knobs shared by every device.
  SimulationConfig get config => _config;

  set config(SimulationConfig value) {
    _config = value;
    for (final device in devices.values) {
      device.config = value;
    }
  }

  bool get started => _started;

  VirtualDevice? device(String id) => devices[id];

  Map<String, CapabilityState>? stateOf(String id) => devices[id]?.state;

  /// Starts every device in spec order. Safe to call more than once.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    for (final device in devices.values) {
      await device.start();
    }
  }

  /// Ids of devices whose state or online status just changed.
  Stream<String> get changes => Stream<String>.multi((controller) {
    final subscriptions = [
      for (final device in devices.values)
        device.changes.listen((_) => controller.add(device.id)),
    ];
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  }, isBroadcast: true);

  /// What every device is right now, to carry over to another runtime.
  Map<String, DeviceSnapshot> snapshot() => {
    for (final device in devices.values)
      device.id: DeviceSnapshot(state: device.state, online: device.online),
  };

  /// Starts again after [stop], each device carrying on from [from] where
  /// it has an entry: its state, and online or not.
  Future<void> resume(Map<String, DeviceSnapshot> from) async {
    _started = true;
    for (final device in devices.values) {
      final snapshot = from[device.id];
      if (snapshot != null) device.restore(snapshot.state);
      if (snapshot?.online ?? device.spec.online) await device.goOnline();
    }
  }

  /// Takes a device off the network or brings it back, as a power cut would.
  Future<void> setOnline(String id, {required bool online}) async {
    final device = devices[id];
    if (device == null) return;
    await (online ? device.goOnline() : device.goOffline());
  }

  /// Every device says goodbye and disconnects.
  Future<void> stop() async {
    for (final device in devices.values) {
      await device.goOffline();
    }
    _started = false;
  }

  Future<void> dispose() async {
    for (final device in devices.values) {
      await device.dispose();
    }
    _started = false;
  }
}
