import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/feedback/app_cubits.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/l10n/framework_localizations.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

class GlowhausApp extends StatelessWidget {
  const new({
    required this.settings,
    required this.connection,
    required this.homes,
    required this.devices,
    required this.router,
    this.demo,
    this.panelOpen = false,
    super.key,
  });

  /// Already initialised; the app takes ownership and closes it.
  final SettingsCubit settings;

  /// Already initialised; the app takes ownership and closes it.
  final ConnectionSettingsCubit connection;
  final HomeRepository homes;
  final DeviceRepository devices;
  final GoRouter router;

  /// The demo's device side, when the app runs the demo home.
  final DemoSetup? demo;

  /// Start with the devices panel open (the app was opened at `/demo`).
  final bool panelOpen;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>.value(value: homes),
        RepositoryProvider<DeviceRepository>.value(value: devices),
        RepositoryProvider<DemoSetup?>.value(value: demo),
        if (demo case final demo?)
          RepositoryProvider<DemoSetup>.value(value: demo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(create: (_) => settings),
          BlocProvider<ConnectionSettingsCubit>(create: (_) => connection),
          BlocProvider<ConnectionCubit>(
            create: (_) => ConnectionCubit(devices),
          ),
          BlocProvider<FeedbackCubit>(create: (_) => FeedbackCubit(devices)),
          BlocProvider<DemoPanelCubit>(
            create: (_) => DemoPanelCubit(open: panelOpen && demo != null),
          ),
          BlocProvider<DemoSheetCubit>(create: (_) => DemoSheetCubit()),
          if (demo case final demo?)
            BlocProvider<DevicesPanelCubit>(
              create: (_) => DevicesPanelCubit(
                home: demo.demo.home,
                traffic: demo.demo.traffic,
                away: demo.away,
                initiallyAway: demo.demo.devicesAway,
              ),
            ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            ThemeData theme(Brightness brightness) => GlowhausTheme.build(
              brightness: brightness,
              accent: state.accent.color,
              persian: state.language == AppLanguage.fa,
              reduceMotion: state.reduceMotion,
            );
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              locale: state.language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...FrameworkLocalizations.delegates,
              ],
              themeMode: state.themeMode,
              theme: theme(Brightness.light),
              darkTheme: theme(Brightness.dark),
              themeAnimationDuration: state.reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
            );
          },
        ),
      ),
    );
  }
}
