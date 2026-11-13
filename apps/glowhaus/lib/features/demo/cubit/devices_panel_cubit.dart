import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:meta/meta.dart';

/// What the devices panel shows.
@immutable
class DevicesPanelState {
  const new({
    this.devices = const [],
    this.traffic = const [],
    this.away = false,
  });

  /// Every virtual device as the app would show it, with its availability
  /// as the device itself knows it.
  final List<Device> devices;

  /// Newest first.
  final List<MqttTraffic> traffic;

  /// The devices run in another tab; this one has nothing to show.
  final bool away;

  DevicesPanelState copyWith({
    List<Device>? devices,
    List<MqttTraffic>? traffic,
    bool? away,
  }) => DevicesPanelState(
    devices: devices ?? this.devices,
    traffic: traffic ?? this.traffic,
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
  }) : _home = home,
       _traffic = traffic,
       super(DevicesPanelState(away: initiallyAway)) {
    _refresh();
    _subscriptions = [
      home.changes.listen((_) => _refresh()),
      traffic.stream.listen((_) => _refresh()),
      if (away != null)
        away.listen((value) => emit(state.copyWith(away: value))),
    ];
  }

  final VirtualHome _home;
  final MqttTrafficLog _traffic;

  /// How many of the latest messages the panel lists.
  final int trafficShown;
  late final List<StreamSubscription<Object?>> _subscriptions;

  /// Plugs a device in or pulls the plug, as a power cut would.
  Future<void> setPlugged(String deviceId, {required bool plugged}) =>
      _home.setOnline(deviceId, online: plugged);

  /// Presses the device's own button: its main switch flips, the device
  /// reports the new state, and the app follows.
  Future<void> press(String deviceId) async {
    final device = _home.device(deviceId);
    if (device == null) return;
    final toggle = primaryToggle(_view(device));
    if (toggle == null) return;
    await device.pressLocal(toggle.patchesFor(on: !toggle.on));
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
