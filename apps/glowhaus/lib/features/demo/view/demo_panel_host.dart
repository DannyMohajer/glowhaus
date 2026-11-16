import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// The demo's device side, when this app runs the demo home: its devices,
/// the browser (for the second tab), and whether they are away in it.
@immutable
class DemoSetup {
  const new({required this.demo, required this.browser, this.away});

  final SimulatedTransport demo;
  final DemoBrowser browser;

  /// True while another tab runs the devices.
  final Stream<bool>? away;

  /// The route of the devices-only tab.
  static const String devicesRoute = '/devices';

  /// The route that opens the app with the devices panel showing.
  static const String demoRoute = '/demo';
}

/// Whether the devices panel can be offered right now: there is a demo and
/// the app is on it, not on a real broker.
bool demoPanelAvailable(BuildContext context) =>
    context.read<DemoSetup?>() != null &&
    context.select<ConnectionSettingsCubit, bool>(
      (c) => c.state.active == ConnectionMode.demo,
    );

/// The panel with its buttons wired: close, and open in a new tab.
class DemoDevicesPanel extends StatelessWidget {
  const new({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final browser = context.read<DemoSetup>().browser;
    return DevicesPanel(
      onClose: onClose,
      onOpenTab: browser.supportsTabs
          ? () => browser.openTab(DemoSetup.devicesRoute)
          : null,
    );
  }
}

/// Opens the devices panel: next to the app on expanded windows, as a sheet
/// on smaller ones.
void openDevicesPanel(BuildContext context) {
  if (GlowWindowSize.of(context) == GlowWindowSize.expanded) {
    context.read<DemoPanelCubit>().toggle();
    return;
  }
  final panel = context.read<DevicesPanelCubit>();
  final setup = context.read<DemoSetup>();
  final colors = context.colors;
  final height = MediaQuery.sizeOf(context).height;
  final router = GoRouter.maybeOf(context);
  // The address says what is showing, so it can be shared: `#/demo` while
  // the sheet is open over the dashboard.
  if (router != null && _path(router) == Routes.home) router.go(Routes.demo);
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      // Above the shell, so the address change underneath leaves it alone.
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GlowRadius.card),
        ),
      ),
      builder: (sheet) => RepositoryProvider<DemoSetup>.value(
        value: setup,
        child: BlocProvider<DevicesPanelCubit>.value(
          value: panel,
          child: SizedBox(
            // Half the window: the app stays visible above the sheet.
            height: height * 0.5,
            child: DemoDevicesPanel(onClose: () => Navigator.of(sheet).pop()),
          ),
        ),
      ),
    ).whenComplete(() {
      if (router != null && _path(router) == Routes.demo) {
        router.go(Routes.home);
      }
    }),
  );
}

String _path(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

/// Keeps the address in step with the side panel on wide windows: `#/demo`
/// while the dashboard shows with the panel open, `#/home` without it. Other
/// pages keep their own address; the panel stays open beside them.
class DemoPanelAddress extends StatefulWidget {
  const new({required this.panelOpen, required this.child, super.key});

  final bool panelOpen;
  final Widget child;

  @override
  State<DemoPanelAddress> createState() => _DemoPanelAddressState();
}

class _DemoPanelAddressState extends State<DemoPanelAddress> {
  @override
  Widget build(BuildContext context) {
    if (GlowWindowSize.of(context) == GlowWindowSize.expanded &&
        demoPanelAvailable(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
    return widget.child;
  }

  void _sync() {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final path = _path(router);
    if (path != Routes.home && path != Routes.demo) return;
    final wanted = widget.panelOpen ? Routes.demo : Routes.home;
    if (path != wanted) router.go(wanted);
  }
}

/// The round "Devices" button for the side rail.
class DemoPanelRailButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final open = context.watch<DemoPanelCubit>().state;
    final expanded = GlowWindowSize.of(context) == GlowWindowSize.expanded;
    return IconButtonRound(
      icon: GlowIcons.radar,
      semanticLabel: AppLocalizations.of(context).panelOpen,
      tone: open && expanded ? GlowTone.inverse : GlowTone.surface,
      onTap: () => openDevicesPanel(context),
    );
  }
}

/// The "Devices" chip for the phone dashboard, where there is no rail.
class DemoPanelChip extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    if (GlowWindowSize.of(context) != GlowWindowSize.compact ||
        !demoPanelAvailable(context)) {
      return const SizedBox.shrink();
    }
    return GlowChip(
      label: AppLocalizations.of(context).panelOpen,
      icon: GlowIcons.radar,
      onTap: () => openDevicesPanel(context),
    );
  }
}

/// Opens the panel once at start when the app was opened at the demo
/// route on a window too small for the side column.
class DemoPanelLauncher extends StatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  State<DemoPanelLauncher> createState() => _DemoPanelLauncherState();
}

class _DemoPanelLauncherState extends State<DemoPanelLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final panel = context.read<DemoPanelCubit>();
      if (!panel.state ||
          context.read<DemoSetup?>() == null ||
          GlowWindowSize.of(context) == GlowWindowSize.expanded) {
        return;
      }
      panel.hide();
      openDevicesPanel(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
