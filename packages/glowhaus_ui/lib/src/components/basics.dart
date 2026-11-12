import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/components/pressable.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

/// Colour roles shared by buttons.
enum GlowTone { surface, inverse, accent, ghost }

({Color background, Color foreground}) _toneColors(
  BuildContext context,
  GlowTone tone,
) {
  final colors = context.colors;
  return switch (tone) {
    GlowTone.surface => (background: colors.surface, foreground: colors.text),
    GlowTone.inverse => (
      background: colors.inverse,
      foreground: colors.onInverse,
    ),
    GlowTone.accent => (background: colors.accent, foreground: colors.onAccent),
    GlowTone.ghost => (background: Colors.transparent, foreground: colors.text),
  };
}

/// The big two-line greeting: first line in text colour, second line faint.
class GreetingHeader extends StatelessWidget {
  const new({
    required this.line1,
    required this.line2,
    this.trailing,
    super.key,
  });

  final String line1;
  final String line2;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = context.type.display;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$line1\n'),
                  TextSpan(
                    text: line2,
                    style: TextStyle(color: context.colors.textFaint),
                  ),
                ],
              ),
              style: style,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: GlowSpace.x3),
          trailing!,
        ],
      ],
    );
  }
}

/// A pill chip. Selected chips are inverse (black in light, white in dark).
class GlowChip extends StatelessWidget {
  const new({
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.onInverse : colors.text;
    return GlowPressable(
      onTap: onTap,
      selected: selected,
      child: AnimatedContainer(
        duration: context.motion.toggle,
        curve: context.motion.curve,
        constraints: const BoxConstraints(minHeight: GlowSize.touch),
        padding: const EdgeInsets.symmetric(
          horizontal: GlowSpace.x4,
          vertical: GlowSpace.x2,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.inverse : colors.surface,
          borderRadius: GlowRadius.pillAll,
          border: Border.all(color: selected ? colors.inverse : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: GlowSpace.x2),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.body
                    .weight(600)
                    .copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A circular 44 px icon button.
class IconButtonRound extends StatelessWidget {
  const new({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.tone = GlowTone.surface,
    this.size = GlowSize.touch,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final GlowTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (:background, :foreground) = _toneColors(context, tone);
    return Tooltip(
      message: semanticLabel,
      excludeFromSemantics: true,
      child: GlowPressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: tone == GlowTone.surface
                ? Border.all(color: context.colors.border)
                : null,
          ),
          child: Icon(icon, size: GlowSize.icon, color: foreground),
        ),
      ),
    );
  }
}

/// A pill button with a label.
class GlowButton extends StatelessWidget {
  const new({
    required this.label,
    this.onTap,
    this.icon,
    this.tone = GlowTone.accent,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final GlowTone tone;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (:background, :foreground) = _toneColors(context, tone);
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GlowPressable(
        onTap: onTap,
        child: Container(
          width: expand ? double.infinity : null,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: GlowSpace.x6,
            vertical: GlowSpace.x3,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: GlowRadius.pillAll,
            border: tone == GlowTone.surface
                ? Border.all(color: context.colors.border)
                : null,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.heading
                      .weight(700)
                      .copyWith(color: foreground),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: GlowSpace.x2),
                Icon(icon, size: GlowSize.icon, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The floating action button: accent, round, or a pill when it has a label.
class GlowFab extends StatelessWidget {
  const new({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.label,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowPressable(
      onTap: onTap,
      semanticLabel: label == null ? semanticLabel : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
        padding: EdgeInsets.symmetric(
          horizontal: label == null ? 0 : GlowSpace.x5,
        ),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: GlowRadius.pillAll,
          boxShadow: glowFloatingShadow(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: GlowSize.iconLarge, color: colors.onAccent),
            if (label != null) ...[
              const SizedBox(width: GlowSpace.x2),
              Text(
                label!,
                style: context.type.heading
                    .weight(700)
                    .copyWith(color: colors.onAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The base surface: radius 28, no shadow.
class GlowCard extends StatelessWidget {
  const new({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(GlowSpace.x5),
    this.color,
    this.radius = GlowRadius.card,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final card = AnimatedContainer(
      duration: context.motion.toggle,
      curve: context.motion.curve,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.colors.surface,
        borderRadius: borderRadius,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GlowPressable(
      onTap: onTap,
      borderRadius: borderRadius,
      semanticLabel: semanticLabel,
      child: card,
    );
  }
}

/// An animated on/off switch. Mirrors in RTL.
class ToggleSwitch extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    this.pending = false,
    this.activeColor,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Shows a spinner in the thumb while a command is in flight.
  final bool pending;
  final Color? activeColor;
  final String? semanticLabel;

  static const double _width = 52;
  static const double _height = 32;
  static const double _thumb = 26;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final active = activeColor ?? colors.accent;
    final track = value
        ? active
        : Color.lerp(
            colors.border,
            colors.textFaint,
            colors.isDark ? 0.6 : 0.5,
          )!;
    return Opacity(
      opacity: onChanged == null ? 0.5 : 1,
      child: GlowPressable(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        toggled: value,
        semanticLabel: semanticLabel,
        child: SizedBox(
          width: _width,
          height: GlowSize.touch,
          child: Center(
            child: AnimatedContainer(
              duration: motion.toggle,
              curve: motion.curve,
              width: _width,
              height: _height,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: track,
                borderRadius: GlowRadius.pillAll,
              ),
              child: AnimatedAlign(
                duration: motion.toggle,
                curve: motion.curve,
                alignment: value
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  width: _thumb,
                  height: _thumb,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: pending
                      ? GlowSpinner(
                          size: 14,
                          color: value ? active : const Color(0xFF7A7A7A),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum StatusTone { success, warning, error, offline, accent }

/// A small coloured dot.
class StatusDot extends StatelessWidget {
  const new({required this.tone, this.size = 8, super.key});

  final StatusTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (tone) {
          StatusTone.success => colors.success,
          StatusTone.warning => colors.warning,
          StatusTone.error => colors.error,
          StatusTone.offline => colors.offline,
          StatusTone.accent => colors.accent,
        },
      ),
    );
  }
}

enum ConnectionBadgeState { online, connecting, offline }

/// Shows the state of the connection to the home.
class ConnectionBadge extends StatelessWidget {
  const new({required this.state, required this.label, super.key});

  final ConnectionBadgeState state;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(
          horizontal: GlowSpace.x3,
          vertical: GlowSpace.x1,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: GlowRadius.pillAll,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (state) {
              ConnectionBadgeState.online => const StatusDot(
                tone: StatusTone.success,
              ),
              ConnectionBadgeState.connecting => GlowSpinner(
                size: 10,
                strokeWidth: 1.5,
                color: colors.warning,
              ),
              ConnectionBadgeState.offline => const StatusDot(
                tone: StatusTone.offline,
              ),
            },
            const SizedBox(width: GlowSpace.x2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.caption.weight(600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
