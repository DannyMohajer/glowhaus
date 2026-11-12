import 'package:flutter/material.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// Frame around the three top-level destinations.
class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
      destinations: [
        GlowNavItem(icon: GlowIcons.house, label: l10n.navHome),
        GlowNavItem(icon: GlowIcons.layoutGrid, label: l10n.navRooms),
        GlowNavItem(icon: GlowIcons.settings, label: l10n.navSettings),
      ],
      currentIndex: navigationShell.currentIndex,
      // Tapping the current destination returns to its first page.
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      railHeader: const GlowLogoMark(),
      body: navigationShell,
    );
  }
}

/// The Glowhaus mark: a house on the accent colour.
class GlowLogoMark extends StatelessWidget {
  const new({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        child: Icon(GlowIcons.house, size: size * 0.5, color: colors.onAccent),
      ),
    );
  }
}
