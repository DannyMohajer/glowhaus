import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:glowhaus/app/di/injection.config.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/broker_transports.dart';
import 'package:glowhaus/features/connection/data/connection_store.dart';
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// The composition root. Only `main`, the router and tests touch this;
/// everything else receives its dependencies through constructors.
final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get preferences async {
    try {
      return await SharedPreferences.getInstance();
    } on Object {
      // A browser that blocks site data (a private window, "block all
      // cookies") throws when the store is read. The app runs all the
      // same; what it saves then lasts for this visit only, which also
      // means every such visit is a first visit and sees the intro.
      SharedPreferencesStorePlatform.instance =
          InMemorySharedPreferencesStore.empty();
      return await SharedPreferences.getInstance();
    }
  }

  /// The demo home. The repository starts on it; the connection settings
  /// can switch the repository to a real broker and back.
  @lazySingleton
  SimulatedTransport get simulatedTransport =>
      SimulatedTransport(homeId: DemoHome.homeId, devices: DemoHome.devices());

  @lazySingleton
  Transport transport(SimulatedTransport simulated) => simulated;

  @lazySingleton
  HomeRepository get homeRepository => const HomeRepository(DemoHome.home);

  @lazySingleton
  DeviceRepository deviceRepository(Transport transport) =>
      DeviceRepository(transport);

  @lazySingleton
  ConnectionSettingsCubit connectionSettings(
    DeviceRepository devices,
    SimulatedTransport simulated,
    BrokerTransports brokers,
    ConnectionStore store,
    AppPlatform platform,
  ) => ConnectionSettingsCubit(
    devices: devices,
    demo: simulated,
    brokers: brokers,
    store: store,
    platform: platform,
    developmentCa: developmentCa(),
  );

  @lazySingleton
  SimulationControl simulationControl(SimulatedTransport simulated) =>
      TransportSimulationControl(simulated);
}

/// The mkcert CA handed to a debug build, so a phone can trust a broker on
/// the Mac without installing anything (Dart on Android ignores user CAs):
///
///     flutter run --dart-define=GLOWHAUS_DEV_CA="$(base64 -i infra/certs/ca.crt)"
///
/// Release builds never read it.
String? developmentCa() {
  const encoded = String.fromEnvironment('GLOWHAUS_DEV_CA');
  if (!kDebugMode || encoded.isEmpty) return null;
  try {
    return utf8.decode(base64.decode(encoded));
  } on FormatException {
    return null;
  }
}
