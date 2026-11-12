import 'package:flutter/widgets.dart';
import 'package:glowhaus/app/app.dart';
import 'package:glowhaus/app/di/injection.dart';
import 'package:glowhaus/app/router/app_router.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final settings = getIt<SettingsCubit>();
  await settings.init();

  runApp(GlowhausApp(settings: settings, router: createRouter()));
}
