import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/shared/random_tag.dart';
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

  /// The Web Lock that decides which tab runs the devices.
  static const String lockName = 'glowhaus-devices';

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

enum _Phase { joining, noHost, elsewhere, running }

class _DevicesTabState extends State<_DevicesTab> {
  final String _guestId = 'devices-${randomTag()}';
  late final TabLock? _lock = widget.browser.lock(DevicesTabApp.lockName);
  StreamSubscription<void>? _lockLost;
  RemoteDemoHome? _remote;
  DevicesPanelCubit? _panel;
  BridgePort? _port;
  _Phase _phase = _Phase.joining;
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
    // Another tab took over: stop here, and say goodbye so the app tab
    // knows at once.
    _lockLost = _lock?.lost.listen((_) => unawaited(_stop(sayGoodbye: true)));
    unawaited(_start());
  }

  /// Runs the devices here if no other tab does, or, with [takeOver], in
  /// place of the tab that does.
  Future<void> _start({bool takeOver = false}) async {
    setState(() => _phase = _Phase.joining);
    final lock = _lock;
    if (lock != null && !await lock.acquire(steal: takeOver)) {
      if (mounted) setState(() => _phase = _Phase.elsewhere);
      return;
    }
    if (!mounted) return;
    _port?.close();
    final port = _port = widget.browser.channel(widget.channelName);
    if (port == null) {
      _lock?.release();
      setState(() => _phase = _Phase.noHost);
      return;
    }
    try {
      final remote = await RemoteDemoHome.join(port, guestId: _guestId);
      if (!mounted) {
        await remote.leave();
        return;
      }
      // The app tab handed the devices to a newer devices tab.
      unawaited(remote.evicted.then((_) => _stop(sayGoodbye: false)));
      setState(() {
        _remote = remote;
        _panel = DevicesPanelCubit(home: remote.home, traffic: remote.traffic);
        _phase = _Phase.running;
      });
    } on TimeoutException {
      _lock?.release();
      if (mounted) setState(() => _phase = _Phase.noHost);
    }
  }

  Future<void> _stop({required bool sayGoodbye}) async {
    final remote = _remote;
    final panel = _panel;
    _remote = null;
    _panel = null;
    _lock?.release();
    if (mounted) setState(() => _phase = _Phase.elsewhere);
    if (sayGoodbye) await remote?.leave();
    await panel?.close();
  }

  @override
  void dispose() {
    _restoreRoute?.cancel();
    unawaited(_lockLost?.cancel());
    unawaited(_panel?.close());
    unawaited(_remote?.leave());
    _lock?.release();
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
                          child: Text(switch (_phase) {
                            _Phase.noHost => l10n.devicesTabNoHost,
                            _Phase.elsewhere => l10n.devicesTabElsewhere,
                            _ => l10n.devicesTabJoining,
                          }, style: context.type.body),
                        ),
                        const SizedBox(height: GlowSpace.x5),
                        switch (_phase) {
                          _Phase.noHost => GlowButton(
                            label: l10n.devicesTabRetry,
                            onTap: () => unawaited(_start()),
                          ),
                          _Phase.elsewhere => GlowButton(
                            label: l10n.devicesTabTakeOver,
                            onTap: () => unawaited(_start(takeOver: true)),
                          ),
                          _ => const Center(child: GlowSpinner(size: 24)),
                        },
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
