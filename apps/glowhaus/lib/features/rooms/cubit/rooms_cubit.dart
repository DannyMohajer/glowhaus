import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/features/shared/room_overview.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';

part 'rooms_cubit.freezed.dart';

/// The rooms list (master pane).
class RoomsCubit extends Cubit<List<RoomOverview>> {
  new(HomeRepository homes, DeviceRepository devices)
    : super(overviewRooms(homes.currentHome, devices.current)) {
    _subscription = devices.watchAll().listen(
      (views) => emit(overviewRooms(homes.currentHome, views)),
    );
  }

  late final StreamSubscription<List<DeviceView>> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

@freezed
abstract class RoomState with _$RoomState {
  const factory({
    /// Null if the room does not exist.
    Room? room,
    @Default(<DeviceView>[]) List<DeviceView> devices,

    /// Null shows every type.
    DeviceType? filter,
  }) = _RoomState;

  const new _();

  /// The device types present in this room, in a stable order.
  List<DeviceType> get types => [
    for (final type in DeviceType.values)
      if (devices.any((view) => view.device.type == type)) type,
  ];

  List<DeviceView> get visibleDevices => filter == null
      ? devices
      : devices.where((view) => view.device.type == filter).toList();
}

/// One room and its devices.
class RoomCubit extends Cubit<RoomState> {
  new(HomeRepository homes, this._devices, String roomId)
    : super(RoomState(room: homes.currentHome.room(roomId))) {
    _subscription = _devices.watchAll().listen((views) {
      final inRoom = [
        for (final view in views)
          if (view.device.roomId == roomId) view,
      ];
      final filter = state.filter;
      emit(
        state.copyWith(
          devices: inRoom,
          // Drop a filter whose last device has gone.
          filter: inRoom.any((view) => view.device.type == filter)
              ? filter
              : null,
        ),
      );
    });
  }

  final DeviceRepository _devices;
  late final StreamSubscription<List<DeviceView>> _subscription;

  void setFilter(DeviceType? type) => emit(state.copyWith(filter: type));

  void toggle(Device device, {required bool on}) {
    final toggle = primaryToggle(device);
    if (toggle == null) return;
    unawaited(_devices.send(device.id, toggle.patchesFor(on: on)));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
