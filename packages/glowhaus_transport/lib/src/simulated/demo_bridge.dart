import 'dart:async';

import 'package:glowhaus_device/glowhaus_device.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:glowhaus_transport/src/simulated/simulated_transport.dart';

/// The app side of the demo's two-tab mode: lets the devices of a
/// [SimulatedTransport] move to another browser tab and come back.
///
/// When a [RemoteDemoHome] joins over the port, the devices here say
/// goodbye and their state travels with the welcome; the other tab runs
/// them from then on, as real MQTT clients of this tab's broker. When that
/// tab leaves, or goes silent, the devices come back here from what the
/// broker last retained.
class DemoBridgeHost {
  new(this.demo, BridgePort port, {required String hostId}) {
    _host = BridgeHost(
      broker: demo.broker,
      port: port,
      hostId: hostId,
      onJoin: _onJoin,
      onLeave: _onLeave,
    );
  }

  final SimulatedTransport demo;
  late final BridgeHost _host;
  final _away = StreamController<bool>.broadcast();

  /// True while another tab runs the devices.
  Stream<bool> get devicesAway => _away.stream;

  Future<Map<String, Object?>> _onJoin(String guestId) async {
    final snapshot = demo.devicesAway
        // A second devices tab: hand over what the broker knows.
        ? const <String, DeviceSnapshot>{}
        : await demo.releaseDevices();
    if (!_away.isClosed) _away.add(true);
    return {
      'homeId': demo.homeId,
      'devices': {
        for (final MapEntry(:key, :value) in snapshot.entries)
          key: value.toJson(),
      },
    };
  }

  Future<void> _onLeave(String guestId) async {
    if (_host.guests.isNotEmpty) return;
    await demo.reclaimDevices();
    if (!_away.isClosed) _away.add(false);
  }

  Future<void> close() async {
    await _host.close();
    await _away.close();
  }
}

/// The devices tab of the demo: the twelve virtual devices, connected over a
/// [BridgePort] to the broker in the app's tab.
class RemoteDemoHome {
  new _(this._guest, this.home, this.traffic);

  /// Joins a [DemoBridgeHost] and starts the devices where the app's tab
  /// left them. Throws a [TimeoutException] when no app tab answers.
  static Future<RemoteDemoHome> join(
    BridgePort port, {
    required String guestId,
    Duration? ambientInterval = const Duration(seconds: 2),
  }) async {
    final guest = BridgeGuest(port: port, guestId: guestId);
    final welcome = await guest.join();
    final traffic = MqttTrafficLog();
    final specs = DemoHome.devices().toList();
    final home = VirtualHome(
      homeId: welcome['homeId'] as String? ?? DemoHome.homeId,
      specs: specs,
      connectionFactory: (id) => traffic.tap(guest.connection(), who: id),
      ambientInterval: ambientInterval,
    );
    final devices = welcome['devices'];
    final from = <String, DeviceSnapshot>{
      if (devices is Map<String, Object?>)
        for (final spec in specs)
          if (devices[spec.descriptor.id] case final Map<String, Object?> json)
            spec.descriptor.id: DeviceSnapshot.fromJson(
              json,
              spec.descriptor.capabilities,
            ),
    };
    await home.resume(from);
    return RemoteDemoHome._(guest, home, traffic);
  }

  final BridgeGuest _guest;
  final VirtualHome home;
  final MqttTrafficLog traffic;

  /// Leaves cleanly, so the app's tab takes the devices back at once.
  Future<void> leave() async {
    await _guest.leave();
    await traffic.close();
  }
}
