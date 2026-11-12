import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:meta/meta.dart';

/// A room with the devices currently in it.
@immutable
class RoomOverview {
  const new({required this.room, required this.devices});

  final Room room;
  final List<DeviceView> devices;

  /// Devices that are reachable and doing something.
  int get activeCount => devices.where((view) => view.device.isActive).length;

  /// The room temperature, if any device measures it.
  double? get celsius {
    for (final view in devices) {
      if (view.device.isOffline) continue;
      final reading = view.device.firstState<TemperatureSensorState>();
      if (reading != null) return reading.celsius;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is RoomOverview &&
      other.room == room &&
      _sameViews(other.devices, devices);

  @override
  int get hashCode => Object.hash(room, Object.hashAll(devices));

  static bool _sameViews(List<DeviceView> a, List<DeviceView> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Groups [views] by the rooms of [home], in room order.
List<RoomOverview> overviewRooms(Home home, List<DeviceView> views) => [
  for (final room in home.rooms)
    RoomOverview(
      room: room,
      devices: [
        for (final view in views)
          if (view.device.roomId == room.id) view,
      ],
    ),
];
