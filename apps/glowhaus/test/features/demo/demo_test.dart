import 'dart:async';

import 'package:flutter/material.dart' hide LockState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/demo/cubit/devices_panel_cubit.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus/l10n/framework_localizations.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

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

  @override
  TabLock? lock(String name) => null;
}

String _path(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

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

    Device of(String id) => panel.state.devices.firstWhere((d) => d.id == id);

    test('each device offers the hand action its hardware has', () {
      expect(handAction(of('lr-ceiling')), HandAction.button);
      expect(handAction(of('kt-switch')), HandAction.button);
      expect(handAction(of('kt-outlet')), HandAction.button);
      expect(handAction(of('lr-thermostat')), HandAction.button);
      expect(handAction(of('en-lock')), HandAction.unlock);
      expect(handAction(of('en-door')), HandAction.openDoor);
      expect(handAction(of('kt-motion')), HandAction.motion);
      expect(handAction(of('lr-curtain')), isNull);
      expect(handAction(of('br-climate')), isNull);
      expect(handAction(of('en-camera')), isNull);
    });

    test('the keypad unlocks and locks; no command, only state', () async {
      await panel.press('en-lock');
      await pumpEventQueue();
      expect(of('en-lock').firstState<LockState>()!.locked, isFalse);
      expect(handAction(of('en-lock')), HandAction.lock);
      expect(
        panel.state.traffic.map((t) => t.topic),
        isNot(contains('glowhaus/demo-home/en-lock/ack')),
      );
      await panel.press('en-lock');
      await pumpEventQueue();
      expect(of('en-lock').firstState<LockState>()!.locked, isTrue);
    });

    test('the door opens and closes, and the app hears it', () async {
      await panel.press('en-door');
      await pumpEventQueue();
      expect(of('en-door').firstState<ContactSensorState>()!.open, isTrue);
      final reported = events
          .whereType<DeviceStateChanged>()
          .where((e) => e.deviceId == 'en-door')
          .last;
      expect(
        reported.state.values.whereType<ContactSensorState>().single.open,
        isTrue,
      );
      await panel.press('en-door');
      await pumpEventQueue();
      expect(of('en-door').firstState<ContactSensorState>()!.open, isFalse);
    });

    test('motion needs power: unplugged it sees nothing, plugged in it '
        'reports the time', () async {
      final at = DateTime.utc(2026, 11, 14, 9);
      final timed = DevicesPanelCubit(
        home: demo.home,
        traffic: demo.traffic,
        clock: () => at,
      );
      addTearDown(timed.close);
      await timed.press('kt-motion');
      await pumpEventQueue();
      expect(of('kt-motion').firstState<MotionSensorState>()!.motion, isFalse);

      await timed.setPlugged('kt-motion', plugged: true);
      await pumpEventQueue();
      await timed.press('kt-motion');
      await pumpEventQueue();
      expect(
        of('kt-motion').firstState<MotionSensorState>(),
        MotionSensorState(
          motion: true,
          lastMotionAt: at.millisecondsSinceEpoch,
        ),
      );
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

  group('the panel', () {
    Future<DevicesPanelCubit> pumpPanel(
      WidgetTester tester,
      SimulatedTransport demo,
    ) async {
      // Phone width, tall enough that every device row is built.
      tester.view
        ..physicalSize = Size(phone.width, 2400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(demo.connect);
      final cubit = DevicesPanelCubit(home: demo.home, traffic: demo.traffic);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...FrameworkLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: GlowhausTheme.build(brightness: Brightness.light),
          home: Scaffold(
            body: BlocProvider.value(value: cubit, child: const DevicesPanel()),
          ),
        ),
      );
      await tester.pump();
      return cubit;
    }

    testWidgets("says what it is for, and keeps a device's own button "
        'apart from its power plug', (tester) async {
      final demo = SimulatedTransport(
        homeId: DemoHome.homeId,
        devices: DemoHome.devices(),
        connectDelay: Duration.zero,
        ambientInterval: null,
      );
      final cubit = await pumpPanel(tester, demo);

      expect(
        find.text(
          "This is the device side: press a device's own buttons, or "
          'unplug it to see the app react.',
        ),
        findsOneWidget,
      );
      expect(find.text('Press its button'), findsWidgets);
      expect(find.text('Power'), findsWidgets);
      expect(find.text('Trigger motion'), findsOneWidget);
      expect(find.text('Keypad: unlock'), findsOneWidget);
      expect(find.text('Open the door'), findsOneWidget);
      expect(find.text('Power'), findsNWidgets(12));

      // The button changes what the device does; it stays online.
      final wasOn = demo.home.device('lr-ceiling')!.state['onOff']!;
      await tester.runAsync(() async {
        await tester.tap(
          find.bySemanticsLabel('Ceiling light: Press its button'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      expect(demo.home.device('lr-ceiling')!.state['onOff'], isNot(wasOn));
      expect(demo.home.device('lr-ceiling')!.online, isTrue);

      // The plug takes it off the network; its button is then dimmed and
      // does nothing.
      await tester.runAsync(() async {
        await tester.tap(find.bySemanticsLabel('Power plug of Ceiling light'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      expect(demo.home.device('lr-ceiling')!.online, isFalse);
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Ceiling light: Press its button'),
        ),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );

      await tester.runAsync(() async {
        await cubit.close();
        await demo.dispose();
      });
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

    testWidgets('desktop: /demo opens with the panel showing and keeps its '
        'address; the address follows the panel', (tester) async {
      final router = await tester.pumpApp(
        size: desktop,
        location: Routes.demo,
        demo: DemoSetup(demo: _idleDemo(), browser: _Browser()),
        panelOpen: true,
      );
      await tester.pumpAndSettle();
      expect(find.byType(DevicesPanel), findsOneWidget);
      expect(_path(router), Routes.demo);

      await tester.tap(find.bySemanticsLabel('Close the devices panel'));
      await tester.pumpAndSettle();
      expect(_path(router), Routes.home);

      await tester.tap(find.bySemanticsLabel('Devices'));
      await tester.pumpAndSettle();
      expect(_path(router), Routes.demo, reason: 'a link to share');

      // Other pages keep their own address; the panel stays beside them.
      router.go(Routes.settings);
      await tester.pumpAndSettle();
      expect(_path(router), Routes.settings);
      expect(find.byType(DevicesPanel), findsOneWidget);
    });

    testWidgets('phone: /demo opens the sheet and keeps its address until '
        'the sheet closes', (tester) async {
      final router = await tester.pumpApp(
        location: Routes.demo,
        demo: DemoSetup(demo: _idleDemo(), browser: _Browser()),
        panelOpen: true,
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(_path(router), Routes.demo);

      await tester.tap(find.bySemanticsLabel('Close the devices panel'));
      await tester.pumpAndSettle();
      expect(find.byType(DevicesPanel), findsNothing);
      expect(_path(router), Routes.home);
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
