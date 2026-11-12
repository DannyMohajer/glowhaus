import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/feedback/app_cubits.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

class GlowhausApp extends StatelessWidget {
  const new({
    required this.settings,
    required this.homes,
    required this.devices,
    required this.router,
    super.key,
  });

  /// Already initialised; the app takes ownership and closes it.
  final SettingsCubit settings;
  final HomeRepository homes;
  final DeviceRepository devices;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>.value(value: homes),
        RepositoryProvider<DeviceRepository>.value(value: devices),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(create: (_) => settings),
          BlocProvider<ConnectionCubit>(
            create: (_) => ConnectionCubit(devices),
          ),
          BlocProvider<FeedbackCubit>(create: (_) => FeedbackCubit(devices)),
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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
