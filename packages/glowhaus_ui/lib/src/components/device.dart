import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/components/basics.dart';
import 'package:glowhaus_ui/src/components/pressable.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _IconDisc extends StatelessWidget {
  const new({
    required this.icon,
    required this.active,
    this.activeColor,
    this.size = GlowSize.touch,
  });

  final IconData icon;
  final bool active;
  final Color? activeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = active
        ? activeColor ?? colors.accent
        : colors.surfaceAlt;
    return AnimatedContainer(
      duration: context.motion.toggle,
      curve: context.motion.curve,
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: GlowSize.icon,
        color: active ? glowOn(background) : colors.text,
      ),
    );
  }
}

/// A device in a grid: icon, name, status line and an optional switch.
///
/// States: [on] / off, [offline] (dimmed) and [pending] (command in flight).
/// In the dark theme a device that is on gets a soft accent glow.
class DeviceTile extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.on,
    this.offline = false,
    this.pending = false,
    this.onTap,
    this.onToggle,
    this.activeColor,
    this.toggleSemanticLabel,
    super.key,
  });

  final String title;

  /// Status text, e.g. "On · 70%" or "Offline".
  final String subtitle;
  final IconData icon;
  final bool on;
  final bool offline;
  final bool pending;
  final VoidCallback? onTap;

  /// Shows a switch when set. Disabled while [offline].
  final ValueChanged<bool>? onToggle;

  /// Colour of the icon disc while on. Defaults to the accent.
  final Color? activeColor;
  final String? toggleSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final lit = on && !offline;
    final glow = lit && colors.isDark;

    return GlowPressable(
      onTap: onTap,
      borderRadius: GlowRadius.tileAll,
      child: AnimatedContainer(
        duration: context.motion.toggle,
        curve: context.motion.curve,
        padding: const EdgeInsets.all(GlowSpace.x4),
        decoration: BoxDecoration(
          color: glow ? colors.accentSoft : colors.surface,
          borderRadius: GlowRadius.tileAll,
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.28),
                    blurRadius: 28,
                    spreadRadius: -6,
                  ),
                ]
              : const [],
        ),
        child: Opacity(
          opacity: offline ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _IconDisc(icon: icon, active: lit, activeColor: activeColor),
                  const Spacer(),
                  if (onToggle != null)
                    ToggleSwitch(
                      value: on,
                      pending: pending,
                      onChanged: offline ? null : onToggle,
                      semanticLabel: toggleSemanticLabel ?? title,
                    )
                  else if (pending)
                    const Padding(
                      padding: EdgeInsets.all(GlowSpace.x3),
                      child: GlowSpinner(),
                    ),
                ],
              ),
              const SizedBox(height: GlowSpace.x5),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: type.body.weight(700),
              ),
              const SizedBox(height: GlowSpace.x1),
              Row(
                children: [
                  if (offline) ...[
                    const StatusDot(tone: StatusTone.offline),
                    const SizedBox(width: GlowSpace.x2),
                  ],
                  Flexible(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.caption.numeric.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact pill that toggles one device from a [RoomCard].
class RoomQuickControl extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.on,
    this.pending = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool on;
  final bool pending;

  /// Null renders the control as unavailable (device offline).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = on ? colors.onAccent : colors.text;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GlowPressable(
        onTap: onTap,
        toggled: on,
        child: AnimatedContainer(
          duration: context.motion.toggle,
          curve: context.motion.curve,
          constraints: const BoxConstraints(minHeight: GlowSize.touch),
          padding: const EdgeInsetsDirectional.only(
            start: GlowSpace.x3,
            end: GlowSpace.x4,
            top: GlowSpace.x2,
            bottom: GlowSpace.x2,
          ),
          decoration: BoxDecoration(
            color: on ? colors.accent : colors.surfaceAlt,
            borderRadius: GlowRadius.pillAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pending)
                GlowSpinner(size: 18, color: foreground)
              else
                Icon(icon, size: 18, color: foreground),
              const SizedBox(width: GlowSpace.x2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.caption
                      .weight(700)
                      .copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A room on the dashboard: name, summary and its key device controls.
class RoomCard extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.meta,
    this.controls = const [],
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String title;

  /// e.g. "4 devices · 2 on".
  final String subtitle;
  final IconData icon;

  /// A short reading shown at the end, e.g. "21.4°".
  final String? meta;

  /// Usually [RoomQuickControl]s.
  final List<Widget> controls;

  /// Highlights the card when it is the open room in a master-detail layout.
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return GlowCard(
      color: selected ? colors.accentSoft : null,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowPressable(
            onTap: onTap,
            selected: selected,
            borderRadius: GlowRadius.cardAll,
            child: Padding(
              padding: const EdgeInsets.all(GlowSpace.x5),
              child: Row(
                children: [
                  _IconDisc(icon: icon, active: false, size: 48),
                  const SizedBox(width: GlowSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.heading,
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.caption.numeric.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (meta != null) ...[
                    const SizedBox(width: GlowSpace.x2),
                    Text(meta!, style: type.heading.numeric),
                  ],
                  const SizedBox(width: GlowSpace.x1),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? LucideIcons.chevronLeft
                        : LucideIcons.chevronRight,
                    size: GlowSize.icon,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (controls.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: GlowSpace.x5,
                end: GlowSpace.x5,
                bottom: GlowSpace.x5,
              ),
              child: Wrap(
                spacing: GlowSpace.x2,
                runSpacing: GlowSpace.x2,
                children: controls,
              ),
            ),
        ],
      ),
    );
  }
}

/// A labelled row with a switch, e.g. "Heating" / "Cooling".
class ModeRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.color,
    this.pending = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Colour of the icon and switch while on, e.g. heat or cool.
  final Color? color;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final active = color ?? colors.accent;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: GlowSpace.x3,
        end: GlowSpace.x3,
        top: GlowSpace.x2,
        bottom: GlowSpace.x2,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: GlowRadius.tileAll,
      ),
      child: MergeSemantics(
        child: Row(
          children: [
            _IconDisc(icon: icon, active: value, activeColor: active),
            const SizedBox(width: GlowSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: type.body.weight(700),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.caption.copyWith(color: colors.textMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(width: GlowSpace.x2),
            ToggleSwitch(
              value: value,
              onChanged: onChanged,
              pending: pending,
              activeColor: active,
            ),
          ],
        ),
      ),
    );
  }
}
