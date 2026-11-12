import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:glowhaus/features/feedback/app_cubits.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/features/shared/pane.dart';
import 'package:glowhaus/features/shared/room_overview.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        context.read<HomeRepository>(),
        context.read<DeviceRepository>(),
      ),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DashboardCubit>();

    return SafeArea(
      bottom: false,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                GlowSpace.x5,
                GlowSpace.x5,
                GlowSpace.x5,
                scrollBottomPadding(context),
              ),
              children: [
                GreetingHeader(
                  line1: l10n.greetingHi(state.userName),
                  line2: l10n.greetingWelcomeHome,
                ),
                const SizedBox(height: GlowSpace.x4),
                Wrap(
                  spacing: GlowSpace.x2,
                  runSpacing: GlowSpace.x2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ActivePill(count: state.activeCount),
                    const _ConnectionStatus(),
                  ],
                ),
                const SizedBox(height: GlowSpace.x5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      GlowChip(
                        label: l10n.filterAll,
                        selected: state.selectedRoomId == null,
                        onTap: () => cubit.selectRoom(null),
                      ),
                      for (final overview in state.rooms) ...[
                        const SizedBox(width: GlowSpace.x2),
                        GlowChip(
                          label: localizedName(l10n, overview.room.name),
                          selected: state.selectedRoomId == overview.room.id,
                          onTap: () => cubit.selectRoom(overview.room.id),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: GlowSpace.x4),
                if (!state.loaded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: GlowSpace.x10,
                    ),
                    child: Column(
                      children: [
                        const GlowSpinner(size: 28, strokeWidth: 3),
                        const SizedBox(height: GlowSpace.x3),
                        Text(
                          l10n.loading,
                          style: context.type.body.copyWith(
                            color: context.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) => EqualColumns(
                      columns: constraints.maxWidth >= 900
                          ? 3
                          : constraints.maxWidth >= 560
                          ? 2
                          : 1,
                      children: [
                        for (final overview in state.visibleRooms)
                          _RoomOverviewCard(overview: overview),
                      ],
                    ),
                  ),
                const SizedBox(height: GlowSpace.x4),
                _ScenesTeaser(
                  names: [
                    for (final scene in state.scenes)
                      localizedName(l10n, scene.name),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const new({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: GlowSpace.x3,
        vertical: GlowSpace.x1,
      ),
      decoration: BoxDecoration(
        color: colors.inverse,
        borderRadius: GlowRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(GlowIcons.zap, size: 14, color: colors.accent),
          const SizedBox(width: GlowSpace.x2),
          Flexible(
            child: Text(
              AppLocalizations.of(context).activeDevices(count),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.caption.numeric
                  .weight(700)
                  .copyWith(color: colors.onInverse),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ConnectionCubit, TransportStatus>(
      builder: (context, status) => switch (status) {
        TransportStatus.connected => ConnectionBadge(
          state: ConnectionBadgeState.online,
          label: l10n.connectionOnline,
        ),
        TransportStatus.connecting ||
        TransportStatus.reconnecting => ConnectionBadge(
          state: ConnectionBadgeState.connecting,
          label: l10n.connectionConnecting,
        ),
        TransportStatus.disconnected => ConnectionBadge(
          state: ConnectionBadgeState.offline,
          label: l10n.connectionOffline,
        ),
      },
    );
  }
}

class _RoomOverviewCard extends StatelessWidget {
  const new({required this.overview});

  final RoomOverview overview;

  /// How many quick controls a room card shows.
  static const int _maxControls = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    final cubit = context.read<DashboardCubit>();
    final celsius = overview.celsius;
    final controllable = overview.devices
        .where((view) => primaryToggle(view.device) != null)
        .take(_maxControls);

    return RoomCard(
      title: localizedName(l10n, overview.room.name),
      subtitle:
          '${l10n.roomDeviceCount(overview.devices.length)} · '
          '${l10n.roomOnCount(overview.activeCount)}',
      icon: roomIcon(overview.room.kind),
      meta: celsius == null ? null : readings.temperature(celsius),
      onTap: () => context.go(Routes.room(overview.room.id)),
      controls: [
        for (final view in controllable)
          RoomQuickControl(
            icon: deviceIcon(view.device),
            label: localizedName(l10n, view.device.name),
            on: primaryToggle(view.device)!.on,
            pending: view.pending,
            onTap: view.device.isOffline
                ? null
                : () => cubit.toggle(view.device),
          ),
      ],
    );
  }
}

/// Static for now: scenes become interactive in a later milestone.
class _ScenesTeaser extends StatelessWidget {
  const new({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    return GlowCard(
      color: colors.inverse,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                GlowIcons.sparkles,
                size: GlowSize.icon,
                color: colors.accent,
              ),
              const SizedBox(width: GlowSpace.x2),
              Text(
                l10n.scenesTitle,
                style: type.heading.copyWith(color: colors.onInverse),
              ),
            ],
          ),
          const SizedBox(height: GlowSpace.x1),
          Text(
            l10n.scenesSoon,
            style: type.caption.copyWith(
              color: colors.onInverse.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: GlowSpace.x4),
          Wrap(
            spacing: GlowSpace.x2,
            runSpacing: GlowSpace.x2,
            children: [
              for (final name in names)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GlowSpace.x3,
                    vertical: GlowSpace.x2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: GlowRadius.pillAll,
                    border: Border.all(
                      color: colors.onInverse.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    name,
                    style: type.caption
                        .weight(600)
                        .copyWith(color: colors.onInverse),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
