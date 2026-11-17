import 'package:flutter/material.dart' hide LockState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/demo/cubit/device_activity.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// The demo's device side: every virtual device as a card with its own face
/// — the drawing of the hardware, pressed the way a person at home would —
/// its plug, and the MQTT messages the devices send.
class DevicesPanel extends StatelessWidget {
  const new({
    this.onClose,
    this.onOpenTab,
    this.footer,
    this.compact = false,
    this.scrollController,
    this.dragController,
    this.snapSizes = const [],
    super.key,
  });

  /// Shows a close button when set.
  final VoidCallback? onClose;

  /// Shows "Open in a new tab" when set.
  final VoidCallback? onOpenTab;

  /// Shown under the header, e.g. what the devices tab is.
  final String? footer;

  /// The phone sheet: a one-row sticky header with the description behind
  /// an info button, three columns of small cards, and the last message in
  /// plain words at the bottom.
  final bool compact;

  /// The sheet's scroll controller, so dragging the devices drags the
  /// sheet. Only used while [compact].
  final ScrollController? scrollController;

  /// The sheet itself, so its header can be dragged as well as its
  /// content, and let go at the nearest of [snapSizes].
  final DraggableScrollableController? dragController;

  /// Where the sheet rests, smallest first.
  final List<double> snapSizes;

  /// How many messages the log at the bottom keeps.
  static const int logLength = 4;

  @override
  Widget build(BuildContext context) {
    if (compact) return _sheet(context);
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    return BlocBuilder<DevicesPanelCubit, DevicesPanelState>(
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    GlowSpace.x4,
                    GlowSpace.x5,
                    GlowSpace.x4,
                    GlowSpace.x3,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  l10n.panelTitle,
                                  style: type.heading,
                                ),
                              ),
                            ),
                            if (onOpenTab != null && !state.away)
                              IconButtonRound(
                                icon: GlowIcons.arrowRight,
                                semanticLabel: l10n.panelOpenTab,
                                onTap: onOpenTab,
                                size: 40,
                              ),
                            if (onClose != null) ...[
                              const SizedBox(width: GlowSpace.x2),
                              IconButtonRound(
                                icon: GlowIcons.x,
                                semanticLabel: l10n.panelClose,
                                onTap: onClose,
                                size: 40,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: GlowSpace.x1),
                        Text(
                          footer ?? l10n.panelSubtitle,
                          style: type.caption.copyWith(color: colors.textMuted),
                        ),
                        if (!state.away) ...[
                          const SizedBox(height: GlowSpace.x3),
                          const _Hint(),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.away)
                  SliverPadding(
                    padding: const EdgeInsets.all(GlowSpace.x5),
                    sliver: SliverToBoxAdapter(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(l10n.panelAway, style: type.body),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      GlowSpace.x4,
                      0,
                      GlowSpace.x4,
                      GlowSpace.x5,
                    ),
                    sliver: SliverToBoxAdapter(child: _Rooms(state: state)),
                  ),
              ],
            ),
          ),
          if (!state.away) _TrafficLog(entries: state.traffic),
        ],
      ),
    );
  }

  /// The phone sheet. The header stays put and the devices scroll under it;
  /// the bottom line says what a device just did, and opens the MQTT log.
  Widget _sheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    return BlocBuilder<DevicesPanelCubit, DevicesPanelState>(
      builder: (context, state) => Column(
        children: [
          _SheetHeader(
            onClose: onClose,
            dragController: dragController,
            snapSizes: snapSizes,
          ),
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                if (state.away)
                  SliverPadding(
                    padding: const EdgeInsets.all(GlowSpace.x5),
                    sliver: SliverToBoxAdapter(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(l10n.panelAway, style: type.body),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      GlowSpace.x3,
                      GlowSpace.x2,
                      GlowSpace.x3,
                      GlowSpace.x4,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _Rooms(state: state, compact: true),
                    ),
                  ),
              ],
            ),
          ),
          if (!state.away)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: SafeArea(top: false, child: _ActivityLine(state: state)),
            ),
        ],
      ),
    );
  }
}

/// The sheet's one header row: the grab handle, the title, what the panel
/// is behind an info button, and close.
class _SheetHeader extends StatelessWidget {
  const new({this.onClose, this.dragController, this.snapSizes = const []});

  final VoidCallback? onClose;
  final DraggableScrollableController? dragController;
  final List<double> snapSizes;

  /// A flick, rather than a slow drag, in fractions of the window a second.
  static const double _flick = 0.6;

  void _drag(BuildContext context, DragUpdateDetails details) {
    final controller = dragController;
    if (controller == null || !controller.isAttached) return;
    final height = MediaQuery.sizeOf(context).height;
    if (height == 0) return;
    controller.jumpTo(
      (controller.size - details.primaryDelta! / height).clamp(
        snapSizes.first,
        snapSizes.last,
      ),
    );
  }

  void _settle(BuildContext context, DragEndDetails details) {
    final controller = dragController;
    if (controller == null || !controller.isAttached) return;
    final height = MediaQuery.sizeOf(context).height;
    final speed = height == 0
        ? 0.0
        : -details.velocity.pixelsPerSecond.dy / height;
    final size = controller.size;
    final target = speed.abs() > _flick
        ? snapSizes.firstWhere(
            (snap) => speed > 0 ? snap > size + 0.01 : snap < size - 0.01,
            orElse: () => speed > 0 ? snapSizes.last : snapSizes.first,
          )
        : snapSizes.reduce(
            (a, b) => (a - size).abs() <= (b - size).abs() ? a : b,
          );
    controller.animateTo(
      target,
      duration: context.motion.toggle,
      curve: context.motion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final header = Container(
      padding: const EdgeInsets.fromLTRB(
        GlowSpace.x3,
        GlowSpace.x2,
        GlowSpace.x3,
        GlowSpace.x2,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          const GlowDragHandle(),
          const SizedBox(width: GlowSpace.x3),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(l10n.panelTitle, style: context.type.title),
            ),
          ),
          const _InfoButton(),
          if (onClose != null) ...[
            const SizedBox(width: GlowSpace.x1),
            IconButtonRound(
              icon: GlowIcons.x,
              semanticLabel: l10n.panelClose,
              onTap: onClose,
              size: 36,
            ),
          ],
        ],
      ),
    );
    if (dragController == null || snapSizes.length < 2) return header;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => _drag(context, details),
      onVerticalDragEnd: (details) => _settle(context, details),
      child: header,
    );
  }
}

/// What the panel is and how to use it, in a popover: the two lines the
/// side panel has room to show all the time.
class _InfoButton extends StatefulWidget {
  const new();

  @override
  State<_InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<_InfoButton> {
  final _tooltip = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Tooltip(
      key: _tooltip,
      message: '${l10n.panelSubtitle}\n\n${l10n.panelHint}',
      triggerMode: TooltipTriggerMode.manual,
      preferBelow: true,
      showDuration: const Duration(seconds: 12),
      margin: const EdgeInsets.symmetric(horizontal: GlowSpace.x4),
      padding: const EdgeInsets.all(GlowSpace.x3),
      textStyle: context.type.caption.copyWith(color: colors.text),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: GlowRadius.tileAll,
        border: Border.all(color: colors.border),
      ),
      child: IconButtonRound(
        icon: GlowIcons.info,
        semanticLabel: l10n.panelInfo,
        size: 36,
        onTap: () => _tooltip.currentState?.ensureTooltipVisible(),
      ),
    );
  }
}

/// The bottom line of the sheet: the last thing a device did, in words
/// ("Reading light · turned on · now"). Tapping it opens the MQTT log the
/// line is a reading of.
class _ActivityLine extends StatefulWidget {
  const new({required this.state});

  final DevicesPanelState state;

  @override
  State<_ActivityLine> createState() => _ActivityLineState();
}

class _ActivityLineState extends State<_ActivityLine> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final activity = widget.state.activity;
    final entries = widget.state.traffic.take(DevicesPanel.logLength).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GlowSpace.x4,
        GlowSpace.x2,
        GlowSpace.x4,
        GlowSpace.x2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowPressable(
            onTap: () => setState(() => _expanded = !_expanded),
            semanticLabel: _expanded
                ? l10n.panelTrafficHide
                : l10n.panelTrafficShow,
            borderRadius: GlowRadius.tileAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: GlowSpace.x2),
              child: Row(
                children: [
                  const StatusDot(tone: StatusTone.success),
                  const SizedBox(width: GlowSpace.x2),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        activity == null
                            ? l10n.panelTrafficEmpty
                            : _words(l10n, activity),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.caption.copyWith(
                          color: colors.text,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? GlowIcons.chevronDown : GlowIcons.chevronUp,
                    size: 16,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: GlowSpace.x1),
            if (entries.isEmpty)
              Text(
                l10n.panelTrafficEmpty,
                style: context.type.caption.copyWith(color: colors.textMuted),
              )
            else
              for (final entry in entries) _TrafficRow(entry: entry),
            const SizedBox(height: GlowSpace.x2),
          ],
        ],
      ),
    );
  }

  /// "Reading light · turned on · now".
  String _words(AppLocalizations l10n, DeviceActivity activity) {
    final device = widget.state.devices
        .where((device) => device.id == activity.deviceId)
        .firstOrNull;
    final minutes = DateTime.now().difference(activity.at).inMinutes;
    final when = minutes < 1
        ? l10n.activityNow
        : l10n.activityMinutesAgo(minutes);
    return joinParts(l10n, [
      device?.displayName(l10n) ?? activity.deviceId,
      activityWords(l10n, activity.kind),
      when,
    ]);
  }
}

/// What a device did, in this language.
String activityWords(AppLocalizations l10n, DeviceActivityKind kind) =>
    switch (kind) {
      DeviceActivityKind.turnedOn => l10n.activityTurnedOn,
      DeviceActivityKind.turnedOff => l10n.activityTurnedOff,
      DeviceActivityKind.locked => l10n.activityLocked,
      DeviceActivityKind.unlocked => l10n.activityUnlocked,
      DeviceActivityKind.jammed => l10n.activityJammed,
      DeviceActivityKind.opened => l10n.activityOpened,
      DeviceActivityKind.closed => l10n.activityClosed,
      DeviceActivityKind.opening => l10n.activityOpening,
      DeviceActivityKind.closing => l10n.activityClosing,
      DeviceActivityKind.leakFound => l10n.activityLeak,
      DeviceActivityKind.driedUp => l10n.activityDry,
      DeviceActivityKind.sawMotion => l10n.activityMotion,
      DeviceActivityKind.motionStopped => l10n.activityMotionStopped,
      DeviceActivityKind.streaming => l10n.activityStreaming,
      DeviceActivityKind.stoppedStreaming => l10n.activityStoppedStreaming,
      DeviceActivityKind.heating => l10n.activityHeating,
      DeviceActivityKind.cooling => l10n.activityCooling,
      DeviceActivityKind.idle => l10n.activityIdle,
      DeviceActivityKind.reading => l10n.activityReading,
      DeviceActivityKind.wentOffline => l10n.activityOffline,
      DeviceActivityKind.cameBack => l10n.activityOnline,
      DeviceActivityKind.reported => l10n.activityReported,
    };

/// What the panel is for, in one line, above the devices.
class _Hint extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GlowSpace.x3,
        vertical: GlowSpace.x2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: GlowRadius.tileAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(GlowIcons.info, size: 16, color: colors.textMuted),
          ),
          const SizedBox(width: GlowSpace.x2),
          Expanded(
            child: Text(
              AppLocalizations.of(context).panelHint,
              style: context.type.caption.copyWith(color: colors.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// The devices, grouped by the room they are in: two columns in the side
/// panel and on phones, three or four on a wide page.
class _Rooms extends StatelessWidget {
  const new({required this.state, this.compact = false});

  final DevicesPanelState state;

  /// The phone sheet: three columns of small cards whatever the width.
  final bool compact;

  /// The demo's rooms, in the order the home lists them; devices with an
  /// unknown room come last, under no heading.
  List<(Room?, List<Device>)> _groups() {
    final byRoom = <String?, List<Device>>{};
    for (final device in state.devices) {
      byRoom.putIfAbsent(device.roomId, () => []).add(device);
    }
    return [
      for (final room in DemoHome.home.rooms)
        if (byRoom.remove(room.id) case final devices?) (room, devices),
      for (final devices in byRoom.values) (null, devices),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = compact
            ? 3
            : width >= 1000
            ? 4
            : width >= 720
            ? 3
            : 2;
        final gap = compact ? GlowSpace.x2 : GlowSpace.x3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (room, devices) in _groups()) ...[
              if (room != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    GlowSpace.x1,
                    compact ? GlowSpace.x2 : GlowSpace.x3,
                    GlowSpace.x1,
                    GlowSpace.x2,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      room.displayName(l10n),
                      style: context.type.caption.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              for (var start = 0; start < devices.length; start += columns)
                Padding(
                  padding: EdgeInsets.only(bottom: gap),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var column = 0; column < columns; column++) ...[
                          if (column > 0) SizedBox(width: gap),
                          Expanded(
                            child: start + column < devices.length
                                ? _DeviceCard(
                                    device: devices[start + column],
                                    compact: compact,
                                    publishes:
                                        state.publishes[devices[start + column]
                                            .id] ??
                                        0,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

/// One device: its face, which presses the device's own hardware, and its
/// plug, which takes it off the network and back.
class _DeviceCard extends StatelessWidget {
  const new({
    required this.device,
    required this.publishes,
    this.compact = false,
  });

  final Device device;
  final int publishes;

  /// The small card of the phone sheet.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DevicesPanelCubit>();
    final name = device.displayName(l10n);
    final online = !device.isOffline;
    return GlowDeviceCard(
      name: name,
      status: deviceStatus(Readings(l10n), device),
      face: _face(context, device: device, name: name, online: online),
      online: online,
      active: device.isActive,
      compact: compact,
      publishTick: publishes,
      plugLabel: online ? l10n.panelPlugged : l10n.panelUnplugged,
      plugSemanticLabel: online
          ? l10n.panelPlugOut(name)
          : l10n.panelPlugIn(name),
      onPlug: () => cubit.setPlugged(device.id, plugged: !online),
    );
  }
}

/// The drawing for [device]: which one comes from its capabilities, what it
/// does when pressed from its hand action. A device without power ignores
/// every press, so its face is not a button while it is unplugged.
Widget _face(
  BuildContext context, {
  required Device device,
  required String name,
  required bool online,
}) {
  final l10n = AppLocalizations.of(context);
  final cubit = context.read<DevicesPanelCubit>();
  final action = handAction(device);
  final label = switch (action) {
    null => null,
    HandAction.button => l10n.panelHandButton,
    HandAction.lock => l10n.panelHandLock,
    HandAction.unlock => l10n.panelHandUnlock,
    HandAction.openCurtain => l10n.panelHandOpenCurtain,
    HandAction.closeCurtain => l10n.panelHandCloseCurtain,
    HandAction.doorbell => l10n.panelHandDoorbell,
    HandAction.openDoor => l10n.panelHandOpenDoor,
    HandAction.closeDoor => l10n.panelHandCloseDoor,
    HandAction.leak =>
      (device.firstState<LeakSensorState>()?.wet ?? false)
          ? l10n.panelHandDry
          : l10n.panelHandLeak,
    HandAction.motion => l10n.panelHandMotion,
  };
  final semanticLabel = label == null ? null : l10n.panelHandOn(name, label);
  final press = online && action != null ? () => cubit.press(device.id) : null;
  final readings = Readings(l10n);

  switch (faceKind(device)) {
    case DeviceFaceKind.light:
      return GlowLightFace(
        on: device.isOn,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.curtain:
      return GlowCurtainFace(
        openPercent: device.firstState<PositionState>()?.position ?? 0,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.thermostat:
      final thermostat = device.firstState<ThermostatState>();
      return GlowThermostatFace(
        reading: readings.temperature(thermostat?.setpoint ?? 0),
        running:
            thermostat != null && thermostat.action != ThermostatAction.idle,
        cooling: thermostat?.action == ThermostatAction.cooling,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.wallSwitch:
      final channels = device.capabilitiesOf(CapabilityKind.onOff).toList();
      return GlowSwitchFace(
        gangs: [
          for (final channel in channels)
            device.stateOf<OnOffState>(channel.id)?.on ?? false,
        ],
        labelOf: (index) => l10n.panelHandOn(
          name,
          channels[index].displayLabel(l10n) ?? l10n.panelHandButton,
        ),
        onPress: online
            ? (index) => cubit.pressChannel(device.id, channels[index].id)
            : null,
      );
    case DeviceFaceKind.lock:
      return GlowLockFace(
        locked: device.firstState<LockState>()?.locked ?? false,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.camera:
      return GlowCameraFace(
        ringTick: (device.firstState<CameraState>()?.streaming ?? false)
            ? 1
            : 0,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.plug:
      return GlowPlugFace(
        on: device.isOn,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.door:
      return GlowDoorFace(
        open: device.firstState<ContactSensorState>()?.open ?? false,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.climate:
      final temperature = device.firstState<TemperatureSensorState>();
      final humidity = device.firstState<HumiditySensorState>();
      return GlowClimateFace(
        temperature: readings.temperature(temperature?.celsius ?? 0),
        humidity: readings.percent(humidity?.percent ?? 0),
      );
    case DeviceFaceKind.leak:
      return GlowLeakFace(
        wet: device.firstState<LeakSensorState>()?.wet ?? false,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.motion:
      return GlowMotionFace(
        motion: device.firstState<MotionSensorState>()?.motion ?? false,
        onTap: press,
        semanticLabel: semanticLabel,
      );
    case DeviceFaceKind.unknown:
      return const GlowFaceFrame(child: SizedBox.shrink());
  }
}

/// The protocol, as it happens: the last few messages, newest first. On a
/// phone only the newest line shows until it is tapped.
class _TrafficLog extends StatefulWidget {
  const new({required this.entries});

  final List<MqttTraffic> entries;

  @override
  State<_TrafficLog> createState() => _TrafficLogState();
}

class _TrafficLogState extends State<_TrafficLog> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final compact = GlowWindowSize.of(context) == GlowWindowSize.compact;
    final entries = widget.entries.take(DevicesPanel.logLength).toList();
    final shown = compact && !_expanded ? entries.take(1).toList() : entries;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        GlowSpace.x4,
        GlowSpace.x3,
        GlowSpace.x4,
        GlowSpace.x4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowPressable(
            onTap: compact
                ? () => setState(() => _expanded = !_expanded)
                : null,
            semanticLabel: compact
                ? (_expanded ? l10n.panelTrafficHide : l10n.panelTrafficShow)
                : null,
            borderRadius: GlowRadius.tileAll,
            child: Row(
              children: [
                const StatusDot(tone: StatusTone.success),
                const SizedBox(width: GlowSpace.x2),
                Expanded(
                  child: Semantics(
                    header: !compact,
                    child: Text(
                      l10n.panelTraffic,
                      style: context.type.caption.weight(700),
                    ),
                  ),
                ),
                if (compact)
                  Icon(
                    _expanded ? GlowIcons.chevronDown : GlowIcons.chevronUp,
                    size: 16,
                    color: colors.textMuted,
                  ),
              ],
            ),
          ),
          const SizedBox(height: GlowSpace.x2),
          if (entries.isEmpty)
            Text(
              l10n.panelTrafficEmpty,
              style: context.type.caption.copyWith(color: colors.textMuted),
            )
          else
            for (final entry in shown) _TrafficRow(entry: entry),
        ],
      ),
    );
  }
}

/// One message: when it was sent, its topic with the last part in the
/// accent, and its payload.
class _TrafficRow extends StatelessWidget {
  const new({required this.entry});

  final MqttTraffic entry;

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final sent = entry.direction == TrafficDirection.sent;
    final at = entry.at;
    final time = '${_two(at.hour)}:${_two(at.minute)}:${_two(at.second)}';
    // Topic and payload are protocol text: left to right in every locale.
    final topic = entry.topic.split('/');
    final suffix = topic.last;
    final prefix = topic.take(topic.length - 1).join('/');
    return Semantics(
      container: true,
      label: sent
          ? l10n.panelTrafficSent(entry.who)
          : l10n.panelTrafficReceived(entry.who),
      child: Padding(
        padding: const EdgeInsets.only(top: GlowSpace.x1),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$time  ',
                  style: TextStyle(color: colors.textFaint),
                ),
                TextSpan(text: '$prefix/'),
                TextSpan(
                  text: suffix,
                  style: TextStyle(color: colors.accentStrong),
                ),
                TextSpan(
                  text: '  ${entry.text.isEmpty ? '∅' : entry.text}',
                  style: TextStyle(color: colors.textMuted),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.caption.numeric.copyWith(color: colors.text),
          ),
        ),
      ),
    );
  }
}
