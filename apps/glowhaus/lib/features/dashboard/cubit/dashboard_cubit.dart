import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/features/shared/room_overview.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';

part 'dashboard_cubit.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory({
    required String userName,

    /// The home's own name, shown when the greeting makes room for the
    /// devices sheet.
    required String homeName,
    @Default(<RoomOverview>[]) List<RoomOverview> rooms,
    @Default(<Scene>[]) List<Scene> scenes,

    /// Null shows every room.
    String? selectedRoomId,

    /// False until the first devices have arrived.
    @Default(false) bool loaded,
  }) = _DashboardState;

  const new _();

  int get activeCount =>
      rooms.fold(0, (total, room) => total + room.activeCount);

  List<RoomOverview> get visibleRooms => selectedRoomId == null
      ? rooms
      : rooms.where((r) => r.room.id == selectedRoomId).toList();
}

class DashboardCubit extends Cubit<DashboardState> {
  new(HomeRepository homes, this._devices)
    : _home = homes.currentHome,
      super(
        DashboardState(
          homeName: homes.currentHome.name,
          userName:
              homes.currentHome.members
                  .where((m) => m.role == Role.owner)
                  .firstOrNull
                  ?.user
                  .name ??
              '',
          scenes: homes.currentHome.scenes,
        ),
      ) {
    _subscription = _devices.watchAll().listen(
      (views) => emit(
        state.copyWith(
          rooms: overviewRooms(_home, views),
          loaded: state.loaded || views.isNotEmpty,
        ),
      ),
    );
  }

  final Home _home;
  final DeviceRepository _devices;
  late final StreamSubscription<List<DeviceView>> _subscription;

  /// Filters the room cards; null shows all rooms.
  void selectRoom(String? roomId) =>
      emit(state.copyWith(selectedRoomId: roomId));

  /// Flips a device's main switch from its quick control.
  void toggle(Device device) {
    final toggle = primaryToggle(device);
    if (toggle == null) return;
    unawaited(_devices.send(device.id, toggle.patchesFor(on: !toggle.on)));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
