import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// Space kept free at the bottom of scrolling content so nothing ends up
/// behind the floating navigation bar on phones.
///
/// On phones: the bar's height plus the system inset (gesture bar, home
/// indicator), plus a gap. The Scaffold also reports the bar's measured
/// height as bottom padding; the larger of the two wins, so a bar that grows
/// (large text) is still cleared. On wider layouts: the inset plus the gap.
double scrollBottomPadding(BuildContext context) {
  final inset = MediaQuery.viewPaddingOf(context).bottom;
  final reported = MediaQuery.paddingOf(context).bottom;
  final navigation = GlowWindowSize.of(context) == GlowWindowSize.compact
      ? inset + GlowBottomNav.height
      : inset;
  return math.max(navigation, reported) + GlowSpace.x6;
}

/// Title row of a pane, with a back button when the pane has no master pane
/// next to it.
class PaneHeader extends StatelessWidget {
  const new({
    required this.title,
    this.subtitle,
    this.backTo,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Route to go back to; null hides the button.
  final String? backTo;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final back = backTo;
    return Row(
      children: [
        if (back != null) ...[
          IconButtonRound(
            icon: Directionality.of(context) == TextDirection.rtl
                ? GlowIcons.arrowRight
                : GlowIcons.arrowLeft,
            semanticLabel: AppLocalizations.of(context).back,
            onTap: () => context.go(back),
          ),
          const SizedBox(width: GlowSpace.x3),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.title,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.caption.numeric.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
            ],
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

/// Centered icon and message for empty and not-found panes.
class PaneMessage extends StatelessWidget {
  const new({required this.icon, required this.message, super.key});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GlowSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colors.textFaint),
            const SizedBox(height: GlowSpace.x3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.type.body.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lays children out in equal-width columns, rows as tall as their tallest
/// child. Unlike a grid, row height follows the content, so large text
/// never overflows a tile.
class EqualColumns extends StatelessWidget {
  const new({
    required this.columns,
    required this.children,
    this.gap = GlowSpace.x3,
    super.key,
  });

  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: start == 0 ? 0 : gap),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = start; i < start + columns; i++) ...[
                  if (i > start) SizedBox(width: gap),
                  Expanded(
                    child: i < children.length
                        ? children[i]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
