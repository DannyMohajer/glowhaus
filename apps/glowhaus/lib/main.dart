import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:glowhaus/app/app.dart';
import 'package:glowhaus/app/di/injection.dart';
import 'package:glowhaus/app/router/app_router.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final settings = getIt<SettingsCubit>();
  await settings.init();

  final devices = getIt<DeviceRepository>();
  unawaited(devices.start());

  runApp(
    GlowhausApp(
      settings: settings,
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
