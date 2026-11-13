import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/app.dart';
import 'package:glowhaus/app/router/app_router.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/broker_transports.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/connection/data/connection_store.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus/features/settings/data/language_preparer.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart'
    show
        InMemoryBroker,
        MqttConnection,
        MqttConnectionState,
        MqttMessage,
        MqttQos,
        MqttWill;
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

class FakeConnectionStore implements ConnectionStore {
  new([this.saved = const ConnectionSettings()]);

  ConnectionSettings saved;
  final devices = <String, List<Device>>{};
  int deviceSaves = 0;

  @override
  ConnectionSettings load() => saved;

  @override
  Future<void> save(ConnectionSettings settings) async => saved = settings;

  @override
  List<Device> lastKnown(String key) => devices[key] ?? const [];

  @override
  Future<void> saveLastKnown(String key, Iterable<Device> devices) async {
    this.devices[key] = devices.toList();
    deviceSaves++;
  }
}

/// Hands out MqttTransports over one in-memory broker, so a test can play
/// the broker and its devices.
class FakeBrokerTransports implements BrokerTransports {
  new({InMemoryBroker? broker}) : broker = broker ?? InMemoryBroker();

  final InMemoryBroker broker;

  /// Every transport made, with what it was made from.
  final made =
      <({BrokerSettings settings, String password, MqttTransport transport})>[];

  /// When set, every connect fails with this reason.
  MqttConnectFailure? refuse;

  @override
  Future<MqttTransport> create(
    BrokerSettings settings, {
    required String password,
  }) async {
    final connection = broker.client();
    final transport = MqttTransport(
      homeId: settings.homeId,
      connection: refuse == null
          ? connection
          : RefusingConnection(connection, refuse!),
      clientId: 'app-${made.length}',
      login: MqttLogin(username: settings.username, password: password),
      reconnectPolicy: const ReconnectPolicy(jitter: 0),
    );
    made.add((settings: settings, password: password, transport: transport));
    return transport;
  }
}

/// Fails every connect with [reason]; the rest is the real connection.
class RefusingConnection implements MqttConnection {
  new(this._inner, this.reason);

  final MqttConnection _inner;
  final MqttConnectFailure reason;

  @override
  MqttConnectionState get currentState => _inner.currentState;

  @override
  Stream<MqttConnectionState> get state => _inner.state;

  @override
  Stream<MqttMessage> get messages => _inner.messages;

  @override
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  }) async => throw MqttConnectionException('refused', reason: reason);

  @override
  Future<void> subscribe(String filter, {MqttQos qos = MqttQos.atLeastOnce}) =>
      _inner.subscribe(filter, qos: qos);

  @override
  Future<void> unsubscribe(String filter) => _inner.unsubscribe(filter);

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) => _inner.publish(topic, payload, qos: qos, retain: retain);

  @override
  Future<void> disconnect() => _inner.disconnect();

  @override
  Future<void> dispose() => _inner.dispose();
}

ConnectionSettingsCubit buildConnection({
  required DeviceRepository devices,
  required Transport demo,
  FakeConnectionStore? store,
  FakeBrokerTransports? brokers,
  bool isWeb = true,
  String? developmentCa,
  Duration saveDelay = const Duration(seconds: 2),
}) => ConnectionSettingsCubit(
  devices: devices,
  demo: demo,
  brokers: brokers ?? FakeBrokerTransports(),
  store: store ?? FakeConnectionStore(),
  platform: AppPlatform(isWeb: isWeb),
  developmentCa: developmentCa,
  saveDelay: saveDelay,
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
    ConnectionSettingsCubit? connection,
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
        connection:
            connection ??
            buildConnection(devices: data.devices, demo: data.transport),
        homes: data.homes,
        devices: data.devices,
        router: router,
      ),
    );
    await pumpAndSettle();
    return router;
  }
}
