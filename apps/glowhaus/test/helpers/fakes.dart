import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/app.dart';
import 'package:glowhaus/app/router/app_router.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/language_preparer.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:go_router/go_router.dart';

class FakeSettingsStore implements SettingsStore {
  new([this.saved]);

  SettingsState? saved;
  int saves = 0;

  @override
  SettingsState? load() => saved;

  @override
  Future<void> save(SettingsState settings) async {
    saved = settings;
    saves++;
  }
}

class FakeSimulationControl implements SimulationControl {
  new({this.available = true});

  @override
  final bool available;

  final applied = <({Duration latency, double failureRate})>[];

  @override
  void apply({required Duration latency, required double failureRate}) =>
      applied.add((latency: latency, failureRate: failureRate));
}

class FakeLanguagePreparer implements LanguagePreparer {
  new({this.systemLanguage = AppLanguage.en});

  @override
  final AppLanguage systemLanguage;

  final prepared = <AppLanguage>[];

  @override
  Future<void> prepare(AppLanguage language) async => prepared.add(language);
}

SettingsCubit buildSettings({
  SettingsState? saved,
  FakeSettingsStore? store,
  FakeSimulationControl? simulation,
  FakeLanguagePreparer? languages,
}) => SettingsCubit(
  store ?? FakeSettingsStore(saved),
  simulation ?? FakeSimulationControl(),
  languages ?? FakeLanguagePreparer(),
);

/// Phone, small tablet and desktop sized windows.
const Size phone = Size(390, 844);
const Size tablet = Size(820, 1100);
const Size desktop = Size(1280, 900);

extension AppTester on WidgetTester {
  /// Pumps the whole app at [location] in a window of [size].
  Future<GoRouter> pumpApp({
    Size size = phone,
    String location = Routes.welcome,
    SettingsCubit? settings,
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);

    final router = createRouter(initialLocation: location);
    addTearDown(router.dispose);
    await pumpWidget(
      GlowhausApp(settings: settings ?? buildSettings(), router: router),
    );
    await pumpAndSettle();
    return router;
  }

  String get location =>
      GoRouter.of(element(find.byType(Navigator).last)).state.uri.toString();
}
