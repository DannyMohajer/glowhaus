import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// The demo's device side: every virtual device with its own hardware
/// (button, keypad, door, motion) and its power plug, and the MQTT messages
/// they send and receive.
class DevicesPanel extends StatelessWidget {
  const new({this.onClose, this.onOpenTab, this.footer, super.key});

  /// Shows a close button when set.
  final VoidCallback? onClose;

  /// Shows "Open in a new tab" when set.
  final VoidCallback? onOpenTab;

  /// Shown under the header, e.g. what the devices tab is.
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    return BlocBuilder<DevicesPanelCubit, DevicesPanelState>(
      builder: (context, state) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              GlowSpace.x5,
              GlowSpace.x5,
              GlowSpace.x5,
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
                          child: Text(l10n.panelTitle, style: type.heading),
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
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: GlowSpace.x3),
              sliver: SliverList.list(
                children: [
                  for (final device in state.devices)
                    _DeviceRow(device: device),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                GlowSpace.x5,
                GlowSpace.x5,
                GlowSpace.x5,
                GlowSpace.x2,
              ),
              sliver: SliverToBoxAdapter(
                child: Semantics(
                  header: true,
                  child: Text(l10n.panelTraffic, style: type.body.weight(700)),
                ),
              ),
            ),
            if (state.traffic.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: GlowSpace.x5),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.panelTrafficEmpty,
                    style: type.caption.copyWith(color: colors.textMuted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  GlowSpace.x5,
                  0,
                  GlowSpace.x5,
                  GlowSpace.x8,
                ),
                sliver: SliverList.builder(
                  itemCount: state.traffic.length,
                  itemBuilder: (context, i) =>
                      _TrafficRow(entry: state.traffic[i]),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

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

/// One device: what it is and shows, then its two kinds of control, kept
/// apart and labelled so neither is mistaken for the other:
///
/// - its own hardware ([HandAction]: a button, a keypad, a door, someone
///   walking past), which changes what the device does;
/// - its power plug, which takes it off the network (it says goodbye on its
///   availability topic) and back.
class _DeviceRow extends StatelessWidget {
  const new({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final name = device.displayName(l10n);
    final online = !device.isOffline;
    final action = handAction(device);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GlowSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What the device is, not a control.
          ExcludeSemantics(
            child: _DeviceDisc(
              icon: deviceIcon(device),
              lit: online && device.isOn,
            ),
          ),
          const SizedBox(width: GlowSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.body.weight(600),
                          ),
                          Text(
                            deviceStatus(Readings(l10n), device),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.caption.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: GlowSpace.x2),
                    _PowerSwitch(device: device, name: name),
                  ],
                ),
                if (action != null) ...[
                  const SizedBox(height: GlowSpace.x2),
                  _HandButton(device: device, name: name, action: action),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceDisc extends StatelessWidget {
  const new({required this.icon, required this.lit});

  final IconData icon;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: context.motion.toggle,
      width: GlowSize.touch,
      height: GlowSize.touch,
      decoration: BoxDecoration(
        color: lit ? colors.accent : colors.surfaceAlt,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: GlowSize.icon,
        color: lit ? colors.onAccent : colors.textMuted,
      ),
    );
  }
}

/// The device's own hardware, with what it does written on it. A device
/// without power ignores it, so it is dimmed while unplugged.
class _HandButton extends StatelessWidget {
  const new({required this.device, required this.name, required this.action});

  final Device device;
  final String name;
  final HandAction action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final online = !device.isOffline;
    final (icon, label) = switch (action) {
      HandAction.button => (GlowIcons.power, l10n.panelHandButton),
      HandAction.lock => (GlowIcons.lock, l10n.panelHandLock),
      HandAction.unlock => (GlowIcons.lockOpen, l10n.panelHandUnlock),
      HandAction.openDoor => (GlowIcons.doorOpen, l10n.panelHandOpenDoor),
      HandAction.closeDoor => (GlowIcons.doorClosed, l10n.panelHandCloseDoor),
      HandAction.motion => (GlowIcons.activity, l10n.panelHandMotion),
    };
    final onTap = online
        ? () => context.read<DevicesPanelCubit>().press(device.id)
        : null;
    return Semantics(
      container: true,
      button: true,
      enabled: online,
      label: l10n.panelHandOn(name, label),
      onTap: onTap,
      excludeSemantics: true,
      child: Opacity(
        opacity: online ? 1 : 0.45,
        child: GlowChip(icon: icon, label: label, onTap: onTap),
      ),
    );
  }
}

/// The power plug: a plug icon, the word for it, and a switch. Off takes
/// the device off the network; on brings it back.
class _PowerSwitch extends StatelessWidget {
  const new({required this.device, required this.name});

  final Device device;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final online = !device.isOffline;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: GlowSpace.x3,
        end: GlowSpace.x1,
      ),
      decoration: BoxDecoration(
        borderRadius: GlowRadius.pillAll,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  GlowIcons.plug,
                  size: 18,
                  color: online ? colors.text : colors.textMuted,
                ),
                const SizedBox(width: GlowSpace.x1),
                Text(l10n.panelPower, style: context.type.caption.weight(600)),
              ],
            ),
          ),
          const SizedBox(width: GlowSpace.x2),
          ToggleSwitch(
            value: online,
            // Not the accent: plugged in is "connected", not "on".
            activeColor: colors.success,
            semanticLabel: l10n.panelPowerDevice(name),
            onChanged: (plugged) => context
                .read<DevicesPanelCubit>()
                .setPlugged(device.id, plugged: plugged),
          ),
        ],
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  const new({required this.entry});

  final MqttTraffic entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final sent = entry.direction == TrafficDirection.sent;
    // Topic and payload are protocol text: left to right in every locale.
    final topic = entry.topic.split('/').skip(2).join('/');
    return Semantics(
      container: true,
      label: sent
          ? l10n.panelTrafficSent(entry.who)
          : l10n.panelTrafficReceived(entry.who),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GlowSpace.x1),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                sent ? GlowIcons.arrowRight : GlowIcons.arrowLeft,
                size: 14,
                color: sent ? colors.accent : colors.textMuted,
              ),
              const SizedBox(width: GlowSpace.x2),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: topic,
                        style: context.type.caption.weight(600),
                      ),
                      if (entry.retained)
                        TextSpan(
                          text: '  retained',
                          style: context.type.caption.copyWith(
                            color: colors.textFaint,
                          ),
                        ),
                      TextSpan(
                        text: '\n${entry.text.isEmpty ? '∅' : entry.text}',
                        style: context.type.caption.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
