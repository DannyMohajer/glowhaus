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
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

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

  runApp(
    GlowhausApp(
      settings: settings,
      connection: connection,
      homes: getIt<HomeRepository>(),
      devices: devices,
      router: createRouter(
        initialLocation: settings.shouldShowWelcome
            ? Routes.welcome
            : Routes.home,
      ),
    ),
  );
}
