import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// The demo's device side: every virtual device with its plug and its own
/// button, and the MQTT messages they send and receive.
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

class _DeviceRow extends StatelessWidget {
  const new({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final cubit = context.read<DevicesPanelCubit>();
    final name = device.displayName(l10n);
    final pressable = primaryToggle(device) != null;
    final online = !device.isOffline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GlowSpace.x1),
      child: Row(
        children: [
          // The device's own button. A device without power ignores it.
          IconButtonRound(
            icon: deviceIcon(device),
            semanticLabel: l10n.panelPress(name),
            tone: pressable && online && device.isOn
                ? GlowTone.accent
                : GlowTone.surface,
            onTap: pressable && online ? () => cubit.press(device.id) : null,
          ),
          const SizedBox(width: GlowSpace.x3),
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
                  style: context.type.caption.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: GlowSpace.x2),
          ToggleSwitch(
            value: online,
            semanticLabel: l10n.panelPlugDevice(name),
            onChanged: (plugged) =>
                cubit.setPlugged(device.id, plugged: plugged),
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
