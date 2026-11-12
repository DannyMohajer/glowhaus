import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';

part 'device_cubit.freezed.dart';

@freezed
abstract class DeviceState with _$DeviceState {
  const factory({
    /// Null while the device is unknown (still loading, or removed).
    DeviceView? view,
    Room? room,

    /// True once the repository has answered, so "unknown" means "gone".
    @Default(false) bool resolved,
  }) = _DeviceState;
}

/// One device in detail.
class DeviceCubit extends Cubit<DeviceState> {
  new(HomeRepository homes, this._devices, this.deviceId)
    : super(const DeviceState()) {
    _subscription = _devices.watch(deviceId).listen((view) {
      final roomId = view?.device.roomId;
      emit(
        DeviceState(
          view: view,
          room: roomId == null ? null : homes.currentHome.room(roomId),
          resolved: view != null || _devices.current.isNotEmpty,
        ),
      );
    });
  }

  final DeviceRepository _devices;
  final String deviceId;
  late final StreamSubscription<DeviceView?> _subscription;

  /// Changes one capability. The new value shows immediately.
  void set(String capabilityId, CapabilityPatch patch) =>
      setAll({capabilityId: patch});

  /// Changes several capabilities in one atomic command.
  void setAll(Map<String, CapabilityPatch> patches) =>
      unawaited(_devices.send(deviceId, patches));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
