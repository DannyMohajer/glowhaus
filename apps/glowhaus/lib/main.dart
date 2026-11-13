import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:glowhaus/app/app.dart';
import 'package:glowhaus/app/di/injection.dart';
import 'package:glowhaus/app/router/app_router.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_tab_app.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/language_preparer.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/shared/random_tag.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

/// The BroadcastChannel the app tab and the devices tab share.
const String _demoChannel = 'glowhaus-demo';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final browser = createDemoBrowser();
  final route = browser.initialRoute;

  if (route == DemoSetup.devicesRoute) {
    // The demo's second tab: the devices only, nothing of the app.
    final saved = getIt<SettingsStore>().load();
    if (saved != null) await getIt<LanguagePreparer>().prepare(saved.language);
    runApp(
      DevicesTabApp(
        browser: browser,
        channelName: _demoChannel,
        settings: saved ?? const SettingsState(),
      ),
    );
    return;
  }

  final settings = getIt<SettingsCubit>();
  await settings.init();

  final devices = getIt<DeviceRepository>();
  // In broker mode this shows the broker's last-known devices until the
  // password is entered again; otherwise the demo home starts.
  final connection = getIt<ConnectionSettingsCubit>();
  await connection.init();
  if (connection.state.active == ConnectionMode.demo) {
    unawaited(devices.start());
  }

  // Lets a devices tab take the demo's devices (see DemoBridgeHost).
  final simulated = getIt<SimulatedTransport>();
  final port = browser.channel(_demoChannel);
  final bridge = port == null
      ? null
      : DemoBridgeHost(simulated, port, hostId: 'app-${randomTag()}');

  final atDemo = route == DemoSetup.demoRoute;
  runApp(
    GlowhausApp(
      settings: settings,
      connection: connection,
      homes: getIt<HomeRepository>(),
      devices: devices,
      demo: DemoSetup(
        demo: simulated,
        browser: browser,
        away: bridge?.devicesAway,
      ),
      panelOpen: atDemo,
      router: createRouter(
        initialLocation: atDemo
            ? Routes.demo
            : settings.shouldShowWelcome
            ? Routes.welcome
            : Routes.home,
      ),
    ),
  );
}
