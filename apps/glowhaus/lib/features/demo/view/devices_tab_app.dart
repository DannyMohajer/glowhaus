import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/l10n/framework_localizations.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// The demo's second tab: only the devices, running here and talking MQTT
/// over a BroadcastChannel to the broker in the tab that runs the app.
///
/// It has no repository, no router and no app state: it is the other end
/// of the protocol, nothing more. Theme and language follow the saved
/// settings of the app tab.
class DevicesTabApp extends StatelessWidget {
  const new({
    required this.browser,
    required this.channelName,
    this.settings = const SettingsState(),
    super.key,
  });

  final DemoBrowser browser;
  final String channelName;
  final SettingsState settings;

  Route<void> _route(RouteSettings? _) => MaterialPageRoute<void>(
    settings: const RouteSettings(name: DemoSetup.devicesRoute),
    builder: (_) => _DevicesTab(browser: browser, channelName: channelName),
  );

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => GlowhausTheme.build(
      brightness: brightness,
      accent: settings.accent.color,
      persian: settings.language == AppLanguage.fa,
      reduceMotion: settings.reduceMotion,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).panelTitle,
      locale: settings.language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...FrameworkLocalizations.delegates,
      ],
      themeMode: settings.themeMode,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      // Exactly one route, named so `#/devices` is what Flutter reports.
      // `onGenerateRoute` is what makes MaterialApp build a Navigator at
      // all; `onGenerateInitialRoutes` keeps it to this one route (plain
      // `initialRoute` would also build a `/` route underneath, and with it
      // a second devices tab).
      onGenerateRoute: _route,
      onGenerateInitialRoutes: (_) => [_route(null)],
    );
  }
}

class _DevicesTab extends StatefulWidget {
  const new({required this.browser, required this.channelName});

  final DemoBrowser browser;
  final String channelName;

  @override
  State<_DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<_DevicesTab> {
  final String _guestId =
      'devices-${Random().nextInt(1 << 32).toRadixString(36)}';
  RemoteDemoHome? _remote;
  DevicesPanelCubit? _panel;
  BridgePort? _port;
  bool _failed = false;
  Timer? _restoreRoute;

  @override
  void initState() {
    super.initState();
    widget.browser.onPageHide(() => unawaited(_remote?.leave()));
    // Flutter's history for a single-route app rewrites the address to `/`
    // at start; put `#/devices` back so a reload returns to this tab.
    // A timer as well as the first frame: a tab opened in the background
    // may not draw a frame for a while.
    void restore() => widget.browser.showRoute(DemoSetup.devicesRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) => restore());
    _restoreRoute = Timer(const Duration(seconds: 1), restore);
    unawaited(_join());
  }

  Future<void> _join() async {
    setState(() => _failed = false);
    _port?.close();
    final port = _port = widget.browser.channel(widget.channelName);
    if (port == null) {
      setState(() => _failed = true);
      return;
    }
    try {
      final remote = await RemoteDemoHome.join(port, guestId: _guestId);
      if (!mounted) {
        await remote.leave();
        return;
      }
      setState(() {
        _remote = remote;
        _panel = DevicesPanelCubit(home: remote.home, traffic: remote.traffic);
      });
    } on TimeoutException {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _restoreRoute?.cancel();
    unawaited(_panel?.close());
    unawaited(_remote?.leave());
    _port?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final panel = _panel;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: panel != null
                ? BlocProvider<DevicesPanelCubit>.value(
                    value: panel,
                    child: DevicesPanel(footer: l10n.devicesTabHint),
                  )
                : Padding(
                    padding: const EdgeInsets.all(GlowSpace.x6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.panelTitle, style: context.type.display),
                        const SizedBox(height: GlowSpace.x4),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _failed
                                ? l10n.devicesTabNoHost
                                : l10n.devicesTabJoining,
                            style: context.type.body,
                          ),
                        ),
                        if (_failed) ...[
                          const SizedBox(height: GlowSpace.x5),
                          GlowButton(
                            label: l10n.devicesTabRetry,
                            onTap: () => unawaited(_join()),
                          ),
                        ] else ...[
                          const SizedBox(height: GlowSpace.x5),
                          const Center(child: GlowSpinner(size: 24)),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
