import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/app.dart';
import 'package:glowhaus/app/router/app_router.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus/features/settings/data/language_preparer.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:go_router/go_router.dart';

import 'fake_transport.dart';

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
  bool isWeb = true,
}) => SettingsCubit(
  store ?? FakeSettingsStore(saved),
  simulation ?? FakeSimulationControl(),
  languages ?? FakeLanguagePreparer(),
  AppPlatform(isWeb: isWeb),
);

/// Phone, small tablet and desktop sized windows.
const Size phone = Size(390, 844);
const Size tablet = Size(820, 1100);
const Size desktop = Size(1280, 900);

/// The app's data layer on a hand-driven transport, seeded with the demo
/// home.
class TestHome {
  new() {
    devices = DeviceRepository(transport);
  }

  final transport = FakeTransport();
  late final DeviceRepository devices;
  final homes = const HomeRepository(DemoHome.home);

  Future<void> start() async {
    await devices.start();
    transport.seed(DemoHome.devices());
  }

  Device device(String id) => devices.device(id)!.device;
}

extension AppTester on WidgetTester {
  /// Lets stream events travel from the transport through the repository
  /// and cubits into widgets. Unlike `pumpAndSettle` this also works while a
  /// pending spinner is animating.
  Future<void> pumpEvents([int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await pump(const Duration(milliseconds: 16));
    }
  }

  /// Pumps the whole app at [location] in a window of [size].
  Future<GoRouter> pumpApp({
    Size size = phone,
    String location = Routes.welcome,
    SettingsCubit? settings,
    TestHome? home,
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);

    final data = home ?? TestHome();
    if (home == null) await data.start();
    final router = createRouter(initialLocation: location);
    addTearDown(router.dispose);
    await pumpWidget(
      GlowhausApp(
        settings: settings ?? buildSettings(),
        homes: data.homes,
        devices: data.devices,
        router: router,
      ),
    );
    await pumpAndSettle();
    return router;
  }
}
