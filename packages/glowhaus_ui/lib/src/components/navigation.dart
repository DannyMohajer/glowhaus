import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/components/pressable.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

@immutable
class GlowNavItem {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Floating pill navigation for phones. The selected item shows its label.
///
/// The pill is as wide as its items and centred; it only reaches the screen
/// edges when a long label needs the room (and then ellipsizes).
class GlowBottomNav extends StatelessWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<GlowNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _pillHeight = 48;
  static const double _gutter = GlowSpace.x2;
  static const double _bottomMargin = GlowSpace.x3;

  /// Height the bar takes above the system inset (gesture bar, home
  /// indicator). Scrolling content under it reserves at least this much.
  static const double height = _pillHeight + 2 * _gutter + _bottomMargin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GlowSpace.x4,
        0,
        GlowSpace.x4,
        _bottomMargin,
      ),
      child: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(_gutter),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: GlowRadius.pillAll,
            border: colors.isDark ? Border.all(color: colors.border) : null,
            boxShadow: glowFloatingShadow(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, item) in items.indexed) ...[
                if (index > 0) const SizedBox(width: GlowSpace.x2),
                Flexible(
                  child: _NavPill(
                    item: item,
                    selected: index == currentIndex,
                    showLabel: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const new({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final GlowNavItem item;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.onInverse : colors.textMuted;
    return GlowPressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: item.label,
      child: AnimatedContainer(
        duration: context.motion.toggle,
        curve: context.motion.curve,
        constraints: const BoxConstraints(
          minHeight: GlowBottomNav._pillHeight,
          minWidth: GlowSize.touch,
        ),
        padding: const EdgeInsets.symmetric(horizontal: GlowSpace.x3),
        decoration: BoxDecoration(
          color: selected ? colors.inverse : Colors.transparent,
          borderRadius: GlowRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: GlowSize.icon, color: foreground),
            if (showLabel) ...[
              const SizedBox(width: GlowSpace.x2),
              Flexible(
                child: ExcludeSemantics(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.caption
                        .weight(700)
                        .copyWith(color: foreground),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vertical navigation for tablets and desktops.
class GlowNavRail extends StatelessWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.header,
    this.footer,
    super.key,
  });

  final List<GlowNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? header;

  /// Pinned to the bottom of the rail, e.g. a secondary action.
  final Widget? footer;

  static const double width = 88;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: width,
      margin: const EdgeInsetsDirectional.only(
        start: GlowSpace.x4,
        top: GlowSpace.x4,
        bottom: GlowSpace.x4,
      ),
      padding: const EdgeInsets.symmetric(vertical: GlowSpace.x4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: GlowRadius.cardAll,
      ),
      child: Column(
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: GlowSpace.x6),
          ],
          for (final (index, item) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: GlowSpace.x3),
              child: GlowPressable(
                onTap: () => onTap(index),
                selected: index == currentIndex,
                semanticLabel: item.label,
                borderRadius: GlowRadius.tileAll,
                child: SizedBox(
                  width: width - GlowSpace.x4,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: context.motion.toggle,
                        curve: context.motion.curve,
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? colors.inverse
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: GlowSize.icon,
                          color: index == currentIndex
                              ? colors.onInverse
                              : colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: GlowSpace.x1),
                      ExcludeSemantics(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.caption
                              .weight(600)
                              .copyWith(
                                color: index == currentIndex
                                    ? colors.text
                                    : colors.textMuted,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (footer != null) ...[const Spacer(), footer!],
        ],
      ),
    );
  }
}

/// App frame: bottom navigation on phones, a side rail on wider windows.
class AdaptiveScaffold extends StatelessWidget {
  const new({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.railHeader,
    this.railFooter,
    this.sidePanel,
    super.key,
  });

  final List<GlowNavItem> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? railHeader;

  /// At the bottom of the side rail; not shown on phones.
  final Widget? railFooter;

  /// A column next to the body on expanded windows only, such as a tool
  /// panel. Smaller windows show it some other way, or not at all.
  final Widget? sidePanel;

  /// Width of [sidePanel].
  static const double sidePanelWidth = 380;

  @override
  Widget build(BuildContext context) {
    if (GlowWindowSize.of(context) == GlowWindowSize.compact) {
      return Scaffold(
        extendBody: true,
        body: body,
        bottomNavigationBar: SafeArea(
          child: GlowBottomNav(
            items: destinations,
            currentIndex: currentIndex,
            onTap: onDestinationSelected,
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            GlowNavRail(
              items: destinations,
              currentIndex: currentIndex,
              onTap: onDestinationSelected,
              header: railHeader,
              footer: railFooter,
            ),
            Expanded(child: body),
            if (sidePanel != null &&
                GlowWindowSize.of(context) == GlowWindowSize.expanded)
              Container(
                width: sidePanelWidth,
                margin: const EdgeInsetsDirectional.only(
                  end: GlowSpace.x4,
                  top: GlowSpace.x4,
                  bottom: GlowSpace.x4,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: GlowRadius.cardAll,
                ),
                child: sidePanel,
              ),
          ],
        ),
      ),
    );
  }
}

/// Master-detail: shows as many of the trailing [panes] as the window fits
/// (one on phones, two on medium, three on expanded windows).
///
/// Pass panes from most general to most specific, e.g. rooms, room, device.
class AdaptivePanes extends StatelessWidget {
  const new({required this.panes, super.key});

  final List<Widget> panes;

  static const List<int> _flex = [5, 6, 6];

  @override
  Widget build(BuildContext context) {
    if (panes.isEmpty) return const SizedBox.shrink();
    final max = GlowWindowSize.of(context).maxPanes;
    final first = panes.length > max ? panes.length - max : 0;
    if (panes.length - first == 1) {
      return KeyedSubtree(key: ValueKey(first), child: panes[first]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = first; i < panes.length; i++)
          Expanded(
            flex: _flex[i.clamp(0, _flex.length - 1)],
            child: KeyedSubtree(key: ValueKey(i), child: panes[i]),
          ),
      ],
    );
  }
}
