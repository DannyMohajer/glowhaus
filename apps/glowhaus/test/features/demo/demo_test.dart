import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../../helpers/fakes.dart';

class _Browser implements DemoBrowser {
  final opened = <String>[];

  @override
  String? get initialRoute => null;

  @override
  bool get supportsTabs => true;

  @override
  BridgePort? channel(String name) => null;

  @override
  void openTab(String route) => opened.add(route);

  @override
  void showRoute(String route) {}

  @override
  void onPageHide(void Function() callback) {}
}

/// A demo that is never connected: the panel only needs its devices.
SimulatedTransport _idleDemo() => SimulatedTransport(
  homeId: DemoHome.homeId,
  devices: DemoHome.devices(),
  ambientInterval: null,
);

void main() {
  group('DevicesPanelCubit on a running demo', () {
    late SimulatedTransport demo;
    late DevicesPanelCubit panel;
    final events = <DeviceEvent>[];

    setUp(() async {
      demo = SimulatedTransport(
        homeId: DemoHome.homeId,
        devices: DemoHome.devices(),
        connectDelay: Duration.zero,
        ambientInterval: null,
        config: const SimulationConfig(latency: Duration(milliseconds: 5)),
      );
      events.clear();
      demo.events.listen(events.add);
      await demo.connect();
      panel = DevicesPanelCubit(home: demo.home, traffic: demo.traffic);
    });

    tearDown(() async {
      await panel.close();
      await demo.dispose();
    });

    test('lists every device as the device knows itself', () {
      expect(panel.state.devices, hasLength(12));
      final motion = panel.state.devices.firstWhere((d) => d.id == 'kt-motion');
      expect(motion.isOffline, isTrue);
    });

    test('a press flips the main switch; the device reports it and the '
        'app hears it', () async {
      final before = panel.state.devices
          .firstWhere((d) => d.id == 'lr-ceiling')
          .isOn;
      await panel.press('lr-ceiling');
      await pumpEventQueue();

      final after = panel.state.devices.firstWhere((d) => d.id == 'lr-ceiling');
      expect(after.isOn, !before);
      expect(
        panel.state.traffic.first.topic,
        'glowhaus/demo-home/lr-ceiling/state',
      );
      expect(panel.state.traffic.first.direction, TrafficDirection.sent);
      final reported = events
          .whereType<DeviceStateChanged>()
          .where((e) => e.deviceId == 'lr-ceiling')
          .last;
      expect(reported.state.values.whereType<OnOffState>().single.on, !before);
    });

    test('pulling the plug takes the device off the network', () async {
      await panel.setPlugged('lr-lamp', plugged: false);
      await pumpEventQueue();
      expect(
        panel.state.devices.firstWhere((d) => d.id == 'lr-lamp').isOffline,
        isTrue,
      );
      final availability = events
          .whereType<DeviceAvailabilityChanged>()
          .where((e) => e.deviceId == 'lr-lamp')
          .last;
      expect(availability.availability, DeviceAvailability.offline);
    });

    test('follows the devices into another tab and back', () async {
      final away = StreamController<bool>();
      final followed = DevicesPanelCubit(
        home: demo.home,
        traffic: demo.traffic,
        away: away.stream,
      );
      away.add(true);
      await pumpEventQueue();
      expect(followed.state.away, isTrue);
      away.add(false);
      await pumpEventQueue();
      expect(followed.state.away, isFalse);
      await followed.close();
      await away.close();
    });
  });

  group('in the app', () {
    testWidgets('desktop: the rail button opens the panel beside the app', (
      tester,
    ) async {
      final demo = _idleDemo();
      final browser = _Browser();
      await tester.pumpApp(
        size: desktop,
        location: Routes.home,
        demo: DemoSetup(demo: demo, browser: browser),
      );
      expect(find.byType(DevicesPanel), findsNothing);

      await tester.tap(find.bySemanticsLabel('Devices'));
      await tester.pumpAndSettle();
      expect(find.byType(DevicesPanel), findsOneWidget);
      expect(find.text('Coffee machine'), findsWidgets);

      await tester.tap(find.bySemanticsLabel('Open in a new tab'));
      expect(browser.opened, ['/devices']);

      await tester.tap(find.bySemanticsLabel('Close the devices panel'));
      await tester.pumpAndSettle();
      expect(find.byType(DevicesPanel), findsNothing);
    });

    testWidgets('/demo opens with the panel showing', (tester) async {
      await tester.pumpApp(
        size: desktop,
        location: Routes.home,
        demo: DemoSetup(demo: _idleDemo(), browser: _Browser()),
        panelOpen: true,
      );
      expect(find.byType(DevicesPanel), findsOneWidget);
    });

    testWidgets('phone: the dashboard chip opens the panel as a sheet', (
      tester,
    ) async {
      await tester.pumpApp(
        location: Routes.home,
        demo: DemoSetup(demo: _idleDemo(), browser: _Browser()),
      );
      await tester.tap(find.widgetWithText(GlowChip, 'Devices'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(DevicesPanel), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Close the devices panel'));
      await tester.pumpAndSettle();
      expect(find.byType(DevicesPanel), findsNothing);
    });

    testWidgets('on a real broker there is no devices panel to offer', (
      tester,
    ) async {
      final home = TestHome();
      await home.start();
      final connection = buildConnection(
        devices: home.devices,
        demo: home.transport,
        store:
            FakeConnectionStore(
                const ConnectionSettings(mode: ConnectionMode.broker),
              )
              ..devices['localhost:8884/demo-home'] = [
                for (final spec in DemoHome.devices())
                  Device.fromDescriptor(
                    spec.descriptor,
                    homeId: DemoHome.homeId,
                  ),
              ],
      );
      await tester.runAsync(connection.init);
      await tester.pumpApp(
        size: desktop,
        location: Routes.home,
        home: home,
        connection: connection,
        demo: DemoSetup(demo: _idleDemo(), browser: _Browser()),
        panelOpen: true,
      );
      expect(find.byType(DevicesPanel), findsNothing);
      expect(find.bySemanticsLabel('Devices'), findsNothing);
    });
  });
}
