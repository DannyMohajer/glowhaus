import 'package:flutter/material.dart';
import 'package:glowhaus/app/router/routes.dart';
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
      _PlaceholderPane(title: l10n.roomsTitle),
      if (roomId != null)
        _PlaceholderPane(
          title: roomId,
          // The rooms list is not visible on phones, so offer a way back.
          backTo: size == GlowWindowSize.compact ? Routes.rooms : null,
        )
      else if (size != GlowWindowSize.compact)
        _HintPane(icon: GlowIcons.layoutGrid, message: l10n.selectRoom),
      if (roomId != null && deviceId != null)
        _PlaceholderPane(
          title: deviceId,
          backTo: size == GlowWindowSize.expanded ? null : Routes.room(roomId),
        )
      else if (roomId != null && size == GlowWindowSize.expanded)
        _HintPane(icon: GlowIcons.lightbulb, message: l10n.selectDevice),
    ];
    return SafeArea(child: AdaptivePanes(panes: panes));
  }
}

/// Placeholder until rooms and devices are built on the repositories.
class _PlaceholderPane extends StatelessWidget {
  const new({required this.title, this.backTo});

  final String title;
  final String? backTo;

  @override
  Widget build(BuildContext context) {
    final back = backTo;
    return Padding(
      padding: const EdgeInsets.all(GlowSpace.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (back != null) ...[
            IconButtonRound(
              icon: Directionality.of(context) == TextDirection.rtl
                  ? GlowIcons.arrowRight
                  : GlowIcons.arrowLeft,
              semanticLabel: AppLocalizations.of(context).back,
              onTap: () => context.go(back),
            ),
            const SizedBox(height: GlowSpace.x4),
          ],
          Text(title, style: context.type.title),
        ],
      ),
    );
  }
}

class _HintPane extends StatelessWidget {
  const new({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colors.textFaint),
          const SizedBox(height: GlowSpace.x3),
          Text(
            message,
            style: context.type.body.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
