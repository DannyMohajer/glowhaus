import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/connection/data/connection_store.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart'
    show InMemoryBroker, MqttConnectionText;
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_transport.dart';
import '../../helpers/fakes.dart';

const _topics = TopicCodec();

/// What a 1.1 device leaves on the broker: its retained info and state.
Future<void> _retainLamp(InMemoryBroker broker, {bool on = true}) async {
  final lamp = DemoHome.devices().firstWhere(
    (d) => d.descriptor.id == 'lr-lamp',
  );
  final device = broker.client();
  await device.connect(clientId: 'device-lr-lamp');
  await device.publishText(
    _topics.device(DemoHome.homeId, 'lr-lamp', DeviceChannel.info),
    jsonEncode(InfoPayload(ts: 1, device: lamp.descriptor).toJson()),
    retain: true,
  );
  await device.publishText(
    _topics.device(DemoHome.homeId, 'lr-lamp', DeviceChannel.state),
    jsonEncode(
      StatePayload.encode({
        'onOff': CapabilityState.onOff(on: on),
      }, ts: 1).toJson(),
    ),
    retain: true,
  );
  await device.disconnect();
}

void main() {
  group('BrokerSettings', () {
    test('a browser always uses secure WebSocket on 8884', () {
      const settings = BrokerSettings(tls: false);
      final endpoint = settings.endpoint(web: true);
      expect(endpoint.webSocket, isTrue);
      expect(endpoint.tls, isTrue);
      expect(endpoint.port, 8884);
      expect('$endpoint', 'wss://localhost:8884/mqtt');
    });

    test('native defaults follow TLS and WebSocket', () {
      expect(const BrokerSettings().endpoint(web: false).port, 8883);
      expect(const BrokerSettings(tls: false).endpoint(web: false).port, 1883);
      expect(
        const BrokerSettings(webSocket: true).endpoint(web: false).port,
        8884,
      );
      expect(const BrokerSettings(port: 9000).endpoint(web: false).port, 9000);
    });

    test('the extra CA reaches native endpoints only', () {
      const settings = BrokerSettings(trustedCertificatePem: 'PEM');
      expect(settings.endpoint(web: false).trustedCertificatePem, 'PEM');
      expect(settings.endpoint(web: true).trustedCertificatePem, isNull);
    });

    test('problems name every wrong field', () {
      const bad = BrokerSettings(
        host: 'mqtts://x:1',
        port: 70000,
        webSocket: true,
        path: 'mqtt',
        homeId: 'My Home',
        username: ' ',
      );
      expect(bad.problems(web: false), BrokerField.values.toSet());
      expect(const BrokerSettings().problems(web: false), isEmpty);
      expect(
        const BrokerSettings(host: '192.168.1.20').problems(web: true),
        isEmpty,
      );
    });
  });

  group('PrefsConnectionStore', () {
    late PrefsConnectionStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = PrefsConnectionStore(await SharedPreferences.getInstance());
    });

    test('round trips the settings and never holds a password', () async {
      const settings = ConnectionSettings(
        mode: ConnectionMode.broker,
        broker: BrokerSettings(host: 'broker.local', port: 8883),
      );
      await store.save(settings);
      expect(store.load(), settings);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(PrefsConnectionStore.settingsKey),
        isNot(contains('password')),
      );
    });

    test('last-known devices round trip, per broker', () async {
      final lamp = Device.fromDescriptor(
        DemoHome.devices().first.descriptor,
        homeId: DemoHome.homeId,
      ).copyWith(state: {'onOff': const CapabilityState.onOff(on: true)});
      await store.saveLastKnown('a:8883/demo-home', [lamp]);

      final back = store.lastKnown('a:8883/demo-home').single;
      expect(back.id, lamp.id);
      expect(back.capabilities, lamp.capabilities);
      expect(back.state, lamp.state);
      expect(back.availability, DeviceAvailability.unknown);
      expect(store.lastKnown('b:8883/demo-home'), isEmpty);
    });
  });

  group('DeviceRepository.use', () {
    test('forgets the old devices, shows the last-known ones, follows the '
        'new status', () async {
      final first = FakeTransport();
      final repository = DeviceRepository(first);
      await repository.start();
      first.seed(DemoHome.devices());
      expect(repository.current, hasLength(13));

      final statuses = <TransportStatus>[];
      repository.status.listen(statuses.add);
      final lamp = Device.fromDescriptor(
        DemoHome.devices().first.descriptor,
        homeId: DemoHome.homeId,
      ).copyWith(availability: DeviceAvailability.online);
      final second = FakeTransport();
      await repository.use(second, lastKnown: [lamp]);
      await pumpEventQueue();

      expect(first.currentStatus, TransportStatus.disconnected);
      expect(repository.current.single.device.id, lamp.id);
      expect(
        repository.current.single.device.availability,
        DeviceAvailability.unknown,
      );
      expect(statuses.last, TransportStatus.connected);
      expect(repository.transport, same(second));

      // Events from the old transport no longer count.
      first.seed(DemoHome.devices());
      expect(repository.current, hasLength(1));
      await repository.dispose();
    });
  });

  group('ConnectionSettingsCubit', () {
    late FakeTransport demo;
    late DeviceRepository devices;
    late FakeConnectionStore store;
    late FakeBrokerTransports brokers;

    ConnectionSettingsCubit cubit({bool isWeb = false, String? ca}) =>
        buildConnection(
          devices: devices,
          demo: demo,
          store: store,
          brokers: brokers,
          isWeb: isWeb,
          developmentCa: ca,
        );

    setUp(() async {
      demo = FakeTransport();
      devices = DeviceRepository(demo);
      store = FakeConnectionStore();
      brokers = FakeBrokerTransports();
      await devices.start();
      demo.seed(DemoHome.devices());
    });

    test('starts on the demo; init leaves it alone', () async {
      final c = cubit();
      await c.init();
      expect(c.state.active, ConnectionMode.demo);
      expect(devices.current, hasLength(13));
      await c.close();
    });

    test('connects to the broker and learns its devices from info', () async {
      await _retainLamp(brokers.broker);
      final c = cubit();
      await c.connect(
        const BrokerSettings(host: 'broker.local'),
        password: 'secret',
      );
      await pumpEventQueue();

      expect(c.state.active, ConnectionMode.broker);
      expect(c.state.status, TransportStatus.connected);
      expect(brokers.made.single.password, 'secret');
      expect(brokers.made.single.settings.username, 'demo-home.app');
      expect(devices.current.single.device.id, 'lr-lamp');
      expect(devices.current.single.device.isOn, isTrue);
      expect(demo.currentStatus, TransportStatus.disconnected);
      expect(store.saved.mode, ConnectionMode.broker);
      expect(jsonEncode(store.saved.toJson()), isNot(contains('secret')));
      await c.close();
    });

    test('invalid fields stop the connect and are named', () async {
      final c = cubit();
      await c.connect(
        const BrokerSettings(host: '', homeId: 'Bad Home'),
        password: 'x',
      );
      expect(c.state.invalid, {BrokerField.host, BrokerField.homeId});
      expect(c.state.active, ConnectionMode.demo);
      expect(brokers.made, isEmpty);
      await c.close();
    });

    test('a refused login is reported while it retries', () async {
      brokers.refuse = MqttConnectFailure.unauthorized;
      final c = cubit();
      await c.connect(const BrokerSettings(), password: 'wrong');
      await pumpEventQueue();
      expect(c.state.problem, MqttConnectFailure.unauthorized);
      expect(c.state.status, TransportStatus.connecting);
      await c.close();
    });

    test('back to the demo disposes the broker transport', () async {
      final c = cubit();
      await c.connect(const BrokerSettings(), password: 'p');
      await pumpEventQueue();
      final broker = brokers.made.single.transport;

      await c.select(ConnectionMode.demo);
      await pumpEventQueue();
      expect(c.state.active, ConnectionMode.demo);
      expect(devices.transport, same(demo));
      expect(devices.current, isEmpty, reason: 'until the demo re-announces');
      expect(broker.currentStatus, TransportStatus.disconnected);
      expect(store.saved.mode, ConnectionMode.demo);
      await c.close();
    });

    test('broker mode at launch shows the last-known devices and asks for '
        'the password', () async {
      final lamp = Device.fromDescriptor(
        DemoHome.devices().first.descriptor,
        homeId: DemoHome.homeId,
      );
      store
        ..saved = const ConnectionSettings(mode: ConnectionMode.broker)
        ..devices['localhost:8883/demo-home'] = [lamp];
      final c = cubit();
      await c.init();

      expect(c.state.active, ConnectionMode.broker);
      expect(c.state.needsPassword, isTrue);
      expect(c.state.status, TransportStatus.disconnected);
      expect(devices.current.single.device.id, lamp.id);
      expect(brokers.made, isEmpty);
      await c.close();
    });

    test('what the broker reports is saved for the next launch', () async {
      await _retainLamp(brokers.broker);
      final c = buildConnection(
        devices: devices,
        demo: demo,
        store: store,
        brokers: brokers,
        isWeb: false,
        saveDelay: const Duration(milliseconds: 20),
      );
      await c.connect(const BrokerSettings(), password: 'p');
      await pumpEventQueue();
      expect(store.deviceSaves, 0, reason: 'not before things settle');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(store.devices['localhost:8883/demo-home']!.single.id, 'lr-lamp');
      await c.close();
    });

    test('a debug build pre-fills the development CA', () async {
      expect(cubit(ca: 'PEM').brokerDraft.trustedCertificatePem, 'PEM');
      expect(
        cubit(ca: 'PEM', isWeb: true).brokerDraft.trustedCertificatePem,
        isNull,
      );
    });
  });

  group('settings screen', () {
    testWidgets('broker form: errors, connect, and the simulation knobs '
        'disappear', (tester) async {
      final home = TestHome();
      await home.start();
      final brokers = FakeBrokerTransports();
      final connection = buildConnection(
        devices: home.devices,
        demo: home.transport,
        brokers: brokers,
      );
      // Tall enough that the lazy list builds every section.
      await tester.pumpApp(
        size: const Size(1280, 3200),
        location: Routes.settings,
        home: home,
        connection: connection,
      );
      expect(find.text('Simulation'), findsOneWidget);
      expect(find.text('Host'), findsNothing);

      await tester.tap(find.text('My broker'));
      await tester.pumpAndSettle();
      expect(find.text('Host'), findsOneWidget);
      expect(
        find.textContaining('secure WebSocket'),
        findsOneWidget,
        reason: 'the web build says how it connects',
      );

      final host = find.descendant(
        of: find.widgetWithText(GlowTextField, 'Host'),
        matching: find.byType(TextField),
      );
      await tester.enterText(host, '');
      await tester.ensureVisible(find.text('Connect'));
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enter a host name'), findsOneWidget);
      expect(brokers.made, isEmpty);

      await tester.enterText(host, 'broker.local');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Connect'));
      await tester.pumpEvents();
      expect(brokers.made.single.settings.host, 'broker.local');
      expect(find.text('Simulation'), findsNothing);
      expect(
        find.textContaining('wss://broker.local:8884/mqtt'),
        findsOneWidget,
      );
      // The app's provider closes the cubit with the tree. Let the save
      // timer run out first so no timer is left pending.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
