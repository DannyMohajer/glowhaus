import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/device/view/device_pane.dart';
import 'package:glowhaus/features/rooms/cubit/rooms_cubit.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/features/shared/pane.dart';
import 'package:glowhaus/features/shared/room_overview.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// Master-detail for rooms: rooms list, room, device.
///
/// Which panes exist follows the route; how many are visible follows the
/// window width. Wide windows show a hint pane where nothing is selected yet.
class RoomsPanes extends StatelessWidget {
  const new({this.roomId, this.deviceId, super.key});

  final String? roomId;
  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = GlowWindowSize.of(context);
    final roomId = this.roomId;
    final deviceId = this.deviceId;

    final panes = <Widget>[
      RoomsListPane(selectedRoomId: roomId),
      if (roomId != null)
        RoomPane(
          key: ValueKey('room-$roomId'),
          roomId: roomId,
          selectedDeviceId: deviceId,
          // The rooms list is not visible on phones, so offer a way back.
          backTo: size == GlowWindowSize.compact ? Routes.rooms : null,
        )
      else if (size != GlowWindowSize.compact)
        PaneMessage(icon: GlowIcons.layoutGrid, message: l10n.selectRoom),
      if (roomId != null && deviceId != null)
        DevicePane(
          key: ValueKey('device-$deviceId'),
          deviceId: deviceId,
          backTo: size == GlowWindowSize.expanded ? null : Routes.room(roomId),
        )
      else if (roomId != null && size == GlowWindowSize.expanded)
        PaneMessage(icon: GlowIcons.lightbulb, message: l10n.selectDevice),
    ];
    return SafeArea(bottom: false, child: AdaptivePanes(panes: panes));
  }
}

class RoomsListPane extends StatelessWidget {
  const new({this.selectedRoomId, super.key});

  final String? selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    return BlocProvider(
      create: (context) => RoomsCubit(
        context.read<HomeRepository>(),
        context.read<DeviceRepository>(),
      ),
      child: BlocBuilder<RoomsCubit, List<RoomOverview>>(
        builder: (context, rooms) => ListView(
          padding: EdgeInsets.fromLTRB(
            GlowSpace.x5,
            GlowSpace.x5,
            GlowSpace.x5,
            scrollBottomPadding(context),
          ),
          children: [
            PaneHeader(title: l10n.roomsTitle),
            const SizedBox(height: GlowSpace.x4),
            for (final overview in rooms)
              Padding(
                padding: const EdgeInsets.only(bottom: GlowSpace.x3),
                child: RoomCard(
                  title: overview.room.displayName(l10n),
                  subtitle: joinParts(l10n, [
                    l10n.roomDeviceCount(overview.devices.length),
                    l10n.roomOnCount(overview.activeCount),
                  ]),
                  icon: roomIcon(overview.room.kind),
                  meta: switch (overview.celsius) {
                    final celsius? => readings.temperature(celsius),
                    null => null,
                  },
                  selected: overview.room.id == selectedRoomId,
                  onTap: () => context.go(Routes.room(overview.room.id)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RoomPane extends StatelessWidget {
  const new({
    required this.roomId,
    this.selectedDeviceId,
    this.backTo,
    super.key,
  });

  final String roomId;
  final String? selectedDeviceId;
  final String? backTo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomCubit(
        context.read<HomeRepository>(),
        context.read<DeviceRepository>(),
        roomId,
      ),
      child: _RoomView(backTo: backTo, selectedDeviceId: selectedDeviceId),
    );
  }
}

class _RoomView extends StatelessWidget {
  const new({this.backTo, this.selectedDeviceId});

  final String? backTo;
  final String? selectedDeviceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    final colors = context.colors;
    final cubit = context.read<RoomCubit>();

    return BlocBuilder<RoomCubit, RoomState>(
      builder: (context, state) {
        final room = state.room;
        if (room == null) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(GlowSpace.x5),
                child: PaneHeader(title: '', backTo: backTo ?? Routes.rooms),
              ),
              Expanded(
                child: PaneMessage(
                  icon: GlowIcons.circleHelp,
                  message: l10n.roomNotFound,
                ),
              ),
            ],
          );
        }
        final types = state.types;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            GlowSpace.x5,
            GlowSpace.x5,
            GlowSpace.x5,
            scrollBottomPadding(context),
          ),
          children: [
            PaneHeader(
              title: room.displayName(l10n),
              subtitle: l10n.roomDeviceCount(state.devices.length),
              backTo: backTo,
            ),
            const SizedBox(height: GlowSpace.x4),
            if (types.length > 1) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    GlowChip(
                      label: l10n.filterAll,
                      selected: state.filter == null,
                      onTap: () => cubit.setFilter(null),
                    ),
                    for (final type in types) ...[
                      const SizedBox(width: GlowSpace.x2),
                      GlowChip(
                        label: deviceTypeLabel(l10n, type),
                        selected: state.filter == type,
                        onTap: () => cubit.setFilter(type),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: GlowSpace.x4),
            ],
            if (state.devices.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: GlowSpace.x10),
                child: PaneMessage(
                  icon: GlowIcons.plug,
                  message: l10n.emptyRoom,
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) => EqualColumns(
                  columns: constraints.maxWidth >= 520 ? 3 : 2,
                  children: [
                    for (final view in state.visibleDevices)
                      Builder(
                        builder: (context) {
                          final device = view.device;
                          final toggle = primaryToggle(device);
                          final name = device.displayName(l10n);
                          return DecoratedBox(
                            // Marks the open device in master-detail.
                            position: DecorationPosition.foreground,
                            decoration: BoxDecoration(
                              borderRadius: GlowRadius.tileAll,
                              border: Border.all(
                                color: device.id == selectedDeviceId
                                    ? colors.text
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: DeviceTile(
                              key: ValueKey('tile-${device.id}'),
                              title: name,
                              subtitle: view.pending
                                  ? l10n.pendingLabel
                                  : deviceStatus(readings, device),
                              icon: deviceIcon(device),
                              on: toggle?.on ?? false,
                              tone: deviceTone(device),
                              offline: device.isOffline,
                              pending: view.pending,
                              activeColor: deviceActiveColor(colors, device),
                              toggleSemanticLabel: name,
                              onTap: () =>
                                  context.go(Routes.device(room.id, device.id)),
                              onToggle: toggle == null
                                  ? null
                                  : (on) => cubit.toggle(device, on: on),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
