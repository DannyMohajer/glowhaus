import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart' hide LockState;
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../helpers/fakes.dart';

const _lampState = <String, CapabilityState>{
  'onOff': CapabilityState.onOff(on: true),
  'brightness': CapabilityState.brightness(level: 55),
  'color': CapabilityState.color(hue: 28, saturation: 85),
  'colorTemperature': CapabilityState.colorTemperature(kelvin: 2700),
};

void main() {
  late TestHome home;

  // Created inside each test body: streams set up in `setUp` live outside
  // the widget test's fake-async zone and would not deliver during pumps.
  Future<void> startHome() async {
    home = TestHome();
    await home.start();
  }

  DeviceTile tile(WidgetTester tester, String id) =>
      tester.widget<DeviceTile>(find.byKey(ValueKey('tile-$id')));

  group('dashboard', () {
    testWidgets('greeting, active count, connection, rooms and scenes', (
      tester,
    ) async {
      await startHome();
      await tester.pumpApp(location: Routes.home, home: home);
      expect(find.textContaining('Hi Daniel,'), findsOneWidget);
      expect(find.text('5 devices active'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.byType(RoomCard), findsNWidgets(4));
      expect(find.text('4 devices · 3 on'), findsOneWidget);
      expect(find.text('20.8°'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Scenes'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Movie night'), findsOneWidget);
    });

    for (final (screen, location) in [
      ('dashboard', Routes.home),
      ('room', Routes.room('living-room')),
      ('thermostat', Routes.device('living-room', 'lr-thermostat')),
      ('settings', Routes.settings),
    ]) {
      testWidgets('$screen: scrolled to the end, nothing is behind the nav', (
        tester,
      ) async {
        // A phone with a system gesture bar / button bar below the app.
        tester.view.padding = const FakeViewPadding(bottom: 48);
        tester.view.viewPadding = const FakeViewPadding(bottom: 48);
        await startHome();
        await tester.pumpApp(location: location, home: home);

        // Content scrolls behind the floating bar, so the list's bottom
        // padding must cover the bar plus the system inset, plus a gap.
        final nav = find.byType(GlowBottomNav);
        final list = tester.widget<ListView>(find.byType(ListView).last);
        final padding = list.padding!.resolve(TextDirection.ltr);
        final covered = phone.height - tester.getRect(nav).top;
        expect(covered, greaterThanOrEqualTo(GlowBottomNav.height));
        expect(padding.bottom, greaterThanOrEqualTo(covered + GlowSpace.x4));

        // And the last item really ends above the bar.
        final scrollable = find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first;
        final position = tester.state<ScrollableState>(scrollable).position;
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
        final lastItem = find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(RepaintBoundary),
            )
            .last;
        expect(
          tester.getRect(lastItem).bottom,
          lessThanOrEqualTo(tester.getRect(nav).top),
        );
      });
    }

    testWidgets('the bottom navigation is compact', (tester) async {
      await startHome();
      await tester.pumpApp(location: Routes.home, home: home);
      // The pill is as wide as its items, not the whole screen.
      final pill = find
          .descendant(
            of: find.byType(GlowBottomNav),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(pill).width, lessThan(phone.width * 0.75));
    });

    testWidgets('dark theme: the scenes card uses the normal surface', (
      tester,
    ) async {
      await startHome();
      await tester.pumpApp(
        location: Routes.home,
        home: home,
        settings: buildSettings(
          saved: const SettingsState(themeMode: ThemeMode.dark),
        ),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('scenes-card')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final colors = GlowhausColors.dark();
      final card = tester.widget<GlowCard>(
        find.byKey(const ValueKey('scenes-card')),
      );
      expect(card.color, colors.surface);
      final sparkles = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey('scenes-card')),
          matching: find.byIcon(GlowIcons.sparkles),
        ),
      );
      expect(sparkles.color, colors.accent);
    });

    testWidgets('the front door lock is calm while locked', (tester) async {
      await startHome();
      await tester.pumpApp(location: Routes.home, home: home);
      final control = tester.widget<RoomQuickControl>(
        find.widgetWithText(RoomQuickControl, 'Front door lock'),
      );
      expect(control.on, isTrue, reason: 'locked');
      expect(control.tone, DeviceTone.neutral);
      expect(find.text('3 devices · 0 on'), findsOneWidget, reason: 'entrance');
    });

    testWidgets('room chips filter the cards', (tester) async {
      await startHome();
      await tester.pumpApp(location: Routes.home, home: home);
      await tester.ensureVisible(find.widgetWithText(GlowChip, 'Kitchen'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GlowChip, 'Kitchen'));
      await tester.pumpAndSettle();
      expect(find.byType(RoomCard), findsOneWidget);
      await tester.ensureVisible(find.widgetWithText(GlowChip, 'All'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GlowChip, 'All'));
      await tester.pumpAndSettle();
      expect(find.byType(RoomCard), findsNWidgets(4));
    });

    testWidgets('a room card opens its room', (tester) async {
      await startHome();
      final router = await tester.pumpApp(location: Routes.home, home: home);
      await tester.tap(find.text('4 devices · 3 on'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, Routes.room('living-room'));
    });

    testWidgets('quick control: instant change, pending, then confirmed', (
      tester,
    ) async {
      await startHome();
      await tester.pumpApp(location: Routes.home, home: home);
      RoomQuickControl lamp() => tester.widget<RoomQuickControl>(
        find.widgetWithText(RoomQuickControl, 'Floor lamp'),
      );
      expect(lamp().on, isTrue);

      await tester.tap(find.widgetWithText(RoomQuickControl, 'Floor lamp'));
      await tester.pumpEvents();
      expect(lamp().on, isFalse, reason: 'optimistic');
      expect(lamp().pending, isTrue);
      expect(find.text('4 devices active'), findsOneWidget);

      home.transport.ack();
      await tester.pumpEvents();
      expect(lamp().pending, isTrue, reason: 'acked, state not reported yet');

      home.transport.applyAndReport(_lampState);
      await tester.pumpEvents();
      expect(lamp().pending, isFalse);
      expect(lamp().on, isFalse);
    });

    testWidgets('an offline device cannot be toggled', (tester) async {
      await startHome();
      home.transport.emit(
        const DeviceAvailabilityChanged(
          homeId: DemoHome.homeId,
          deviceId: 'lr-lamp',
          availability: DeviceAvailability.offline,
        ),
      );
      await tester.pumpApp(location: Routes.home, home: home);
      await tester.tap(
        find.widgetWithText(RoomQuickControl, 'Floor lamp'),
        warnIfMissed: false,
      );
      expect(home.transport.sent, isEmpty);
    });

    testWidgets('Persian: right to left, translated names, Persian digits', (
      tester,
    ) async {
      await startHome();
      await tester.pumpApp(
        location: Routes.home,
        home: home,
        settings: buildSettings(
          saved: const SettingsState(language: AppLanguage.fa),
        ),
      );
      expect(
        Directionality.of(tester.element(find.byType(GreetingHeader))),
        TextDirection.rtl,
      );
      expect(find.textContaining('سلام Daniel،'), findsOneWidget);
      expect(find.text('۵ دستگاه فعال'), findsOneWidget);
      expect(find.text('اتاق نشیمن'), findsWidgets);
      expect(find.text('۴ دستگاه، ۳ روشن'), findsOneWidget);
      expect(find.text('\u200E۲۰٫۸°\u200E'), findsOneWidget);
      expect(find.text('Living Room'), findsNothing);

      // Mirrored: the room icon sits to the right of the room title.
      final card = find.byType(RoomCard).first;
      final title = find.descendant(
        of: card,
        matching: find.text('اتاق نشیمن'),
      );
      final icon = find.descendant(
        of: card,
        matching: find.byIcon(GlowIcons.sofa),
      );
      expect(
        tester.getCenter(icon).dx,
        greaterThan(tester.getCenter(title).dx),
      );
      // Chips start from the right edge.
      expect(
        tester.getCenter(find.widgetWithText(GlowChip, 'همه')).dx,
        greaterThan(
          tester.getCenter(find.widgetWithText(GlowChip, 'ورودی')).dx,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone at 2x text in every language', (
      tester,
    ) async {
      await startHome();
      for (final language in AppLanguage.values) {
        final data = TestHome();
        await data.start();
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpApp(
          size: const Size(320, 640),
          location: Routes.home,
          home: data,
          settings: buildSettings(saved: SettingsState(language: language)),
        );
        expect(tester.takeException(), isNull, reason: language.name);
      }
    });
  });

  group('room', () {
    testWidgets('tiles show status; type chips filter them', (tester) async {
      await startHome();
      await tester.pumpApp(location: Routes.room('living-room'), home: home);
      expect(find.byType(DeviceTile), findsNWidgets(4));
      expect(find.text('On · 70%'), findsOneWidget);
      expect(find.text('60% open'), findsOneWidget);
      expect(tile(tester, 'lr-curtain').onToggle, isNull);

      await tester.tap(find.widgetWithText(GlowChip, 'Lights'));
      await tester.pumpAndSettle();
      expect(find.byType(DeviceTile), findsNWidgets(2));
    });

    testWidgets('offline device is shown as offline', (tester) async {
      await startHome();
      await tester.pumpApp(location: Routes.room('kitchen'), home: home);
      expect(tile(tester, 'kt-motion').offline, isTrue);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('toggle: optimistic, then rolled back with a message when '
        'the device does not answer', (tester) async {
      await startHome();
      await tester.pumpApp(location: Routes.room('living-room'), home: home);
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('tile-lr-lamp')),
          matching: find.byType(ToggleSwitch),
        ),
      );
      await tester.pumpEvents();
      expect(tile(tester, 'lr-lamp').on, isFalse);
      expect(tile(tester, 'lr-lamp').pending, isTrue);
      expect(find.text('Sending…'), findsOneWidget);

      home.transport.timeOut();
      await tester.pumpEvents(40);
      expect(tile(tester, 'lr-lamp').on, isTrue, reason: 'rolled back');
      expect(tile(tester, 'lr-lamp').pending, isFalse);
      expect(
        find.text("Floor lamp didn't respond. Your change was undone."),
        findsOneWidget,
      );
    });

    testWidgets('a rejected command explains that the device was busy', (
      tester,
    ) async {
      await startHome();
      await tester.pumpApp(location: Routes.room('entrance'), home: home);
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('tile-en-lock')),
          matching: find.byType(ToggleSwitch),
        ),
      );
      await tester.pumpEvents();
      home.transport.reject(ProtocolErrorCode.busy);
      await tester.pumpEvents(40);
      expect(
        find.text(
          'Front door lock is busy and rejected the change. It was undone.',
        ),
        findsOneWidget,
      );
      expect(tile(tester, 'en-lock').on, isTrue);
    });
  });

  group('device detail', () {
    Future<void> open(WidgetTester tester, String room, String device) =>
        tester.pumpApp(
          size: const Size(390, 1600),
          location: Routes.device(room, device),
          home: home,
        );

    testWidgets('RGB light: power, brightness, colour and white tone', (
      tester,
    ) async {
      await startHome();
      await open(tester, 'living-room', 'lr-lamp');
      expect(find.text('Power'), findsOneWidget);
      expect(find.text('Brightness'), findsOneWidget);
      expect(find.text('55%'), findsOneWidget);
      expect(find.text('Colour'), findsOneWidget);
      expect(find.text('White tone'), findsOneWidget);
      expect(find.text('GL-RGB-1 · firmware 1.0.0'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Colour 6'));
      await tester.pumpEvents();
      expect(home.transport.lastCommand.patches, {
        'color': const CapabilityPatch.color(hue: 210, saturation: 85),
      });
    });

    testWidgets('brightness: dragging sends once, on release', (tester) async {
      await startHome();
      await open(tester, 'living-room', 'lr-lamp');
      final slider = find.byType(PositionSlider);
      final rect = tester.getRect(slider);
      final gesture = await tester.startGesture(
        rect.centerLeft + const Offset(40, -10),
      );
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(60, 0));
      await tester.pumpEvents();
      expect(home.transport.sent, isEmpty, reason: 'still dragging');
      expect(find.text('55%'), findsNothing, reason: 'follows the finger');

      await gesture.up();
      await tester.pumpEvents();
      expect(home.transport.sent, hasLength(1));
      expect(home.transport.lastCommand.patches.keys, {'brightness'});
    });

    testWidgets('multi-channel switch: one row per channel', (tester) async {
      await startHome();
      await open(tester, 'kitchen', 'kt-switch');
      for (final label in ['Ceiling', 'Counter', 'Hood']) {
        expect(find.widgetWithText(ModeRow, label), findsOneWidget);
      }
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('switch-ch2')),
          matching: find.byType(ToggleSwitch),
        ),
      );
      await tester.pumpEvents();
      expect(home.transport.lastCommand.patches, {
        'ch2': const CapabilityPatch.onOff(on: true),
      });
    });

    testWidgets('thermostat: dial, room temperature and mode control', (
      tester,
    ) async {
      await startHome();
      await open(tester, 'living-room', 'lr-thermostat');
      expect(find.byType(TickDial), findsOneWidget);
      expect(find.text('22.5°'), findsOneWidget);
      expect(find.text('Heating to'), findsOneWidget);
      expect(find.text('Now 20.8°'), findsOneWidget);
      expect(
        find.text('Temperature'),
        findsNothing,
        reason: 'no separate tile',
      );

      final modes = tester.widget<GlowSegmented<ThermostatMode>>(
        find.byKey(const ValueKey('thermostat-mode')),
      );
      expect(modes.segments.map((s) => s.label), [
        'Off',
        'Heat',
        'Cool',
        'Auto',
      ]);
      expect(modes.selected, ThermostatMode.heat);
      expect(find.byType(ModeRow), findsNothing, reason: 'no mode switches');
      expect(find.text('Fan'), findsOneWidget, reason: 'fan stays separate');

      Future<void> pick(String label) async {
        await tester.tap(
          find.descendant(
            of: find.byKey(const ValueKey('thermostat-mode')),
            matching: find.text(label),
          ),
        );
        await tester.pumpEvents();
      }

      await pick('Cool');
      expect(home.transport.lastCommand.patches, {
        'thermostat': const CapabilityPatch.thermostat(
          mode: ThermostatMode.cool,
        ),
      });
      expect(find.text('Cooling to'), findsOneWidget, reason: 'optimistic');
      expect(
        tester.widget<TickDial>(find.byType(TickDial)).tone,
        TickDialTone.cool,
      );

      // Dial: tap at the top is the middle of 16..30.
      final dial = tester.getRect(find.byType(TickDial));
      await tester.tapAt(dial.topCenter + const Offset(0, 12));
      await tester.pumpEvents();
      expect(home.transport.lastCommand.patches, {
        'thermostat': const CapabilityPatch.thermostat(setpoint: 23),
      });
    });

    testWidgets('curtain: buttons and travel', (tester) async {
      await startHome();
      await open(tester, 'living-room', 'lr-curtain');
      await tester.tap(find.widgetWithText(GlowChip, 'Open'));
      await tester.pumpEvents();
      expect(home.transport.lastCommand.patches, {
        'position': const CapabilityPatch.position(target: 100),
      });
      home.transport.ack();
      home.transport.reportState('lr-curtain', const {
        'position': CapabilityState.position(
          position: 75,
          target: 100,
          moving: true,
        ),
      });
      await tester.pumpEvents();
      expect(find.text('75%'), findsOneWidget, reason: 'reported progress');
      expect(
        tester
            .widget<PositionSlider>(find.byType(PositionSlider))
            .reportedValue,
        75,
      );

      await tester.tap(find.widgetWithText(GlowChip, 'Stop'));
      await tester.pumpEvents();
      expect(home.transport.lastCommand.patches, {
        'position': const CapabilityPatch.position(stop: true),
      });
    });

    testWidgets('outlet: live power readings update', (tester) async {
      await startHome();
      await open(tester, 'kitchen', 'kt-outlet');
      expect(find.text('1,180 W'), findsOneWidget);
      expect(find.text('42.7 kWh'), findsOneWidget);
      home.transport.reportState('kt-outlet', const {
        'onOff': CapabilityState.onOff(on: true),
        'powerMeter': CapabilityState.powerMeter(
          watts: 1203.4,
          energyKwh: 42.8,
        ),
      });
      await tester.pumpEvents();
      expect(find.text('1,203 W'), findsOneWidget);
    });

    testWidgets('lock, sensors and camera', (tester) async {
      await startHome();
      await open(tester, 'entrance', 'en-lock');
      expect(find.text('Door lock'), findsOneWidget);
      await tester.tap(find.byType(ToggleSwitch));
      await tester.pumpEvents();
      expect(home.transport.lastCommand.patches, {
        'lock': const CapabilityPatch.lock(locked: false),
      });

      await open(tester, 'bedroom', 'br-climate');
      expect(find.text('21.4°'), findsOneWidget);
      expect(find.text('46%'), findsOneWidget);
      expect(find.byType(ToggleSwitch), findsNothing);

      await open(tester, 'entrance', 'en-camera');
      expect(find.text('Live view arrives in a later release'), findsOneWidget);
    });

    testWidgets('offline device: banner, controls disabled', (tester) async {
      await startHome();
      home.transport.emit(
        const DeviceAvailabilityChanged(
          homeId: DemoHome.homeId,
          deviceId: 'lr-lamp',
          availability: DeviceAvailability.offline,
        ),
      );
      await open(tester, 'living-room', 'lr-lamp');
      expect(
        find.text('Offline. Showing the last known state.'),
        findsOneWidget,
      );
      await tester.tap(find.byType(ToggleSwitch).first, warnIfMissed: false);
      await tester.tap(find.bySemanticsLabel('Colour 6'), warnIfMissed: false);
      expect(home.transport.sent, isEmpty);
    });

    testWidgets('pending badge shows while a command is in flight', (
      tester,
    ) async {
      await startHome();
      await open(tester, 'living-room', 'lr-ceiling');
      expect(find.text('Sending…'), findsNothing);
      await tester.tap(find.byType(ToggleSwitch));
      await tester.pumpEvents();
      expect(find.text('Sending…'), findsOneWidget);
      expect(
        tester
            .widget<ModeRow>(find.byKey(const ValueKey('switch-onOff')))
            .pending,
        isTrue,
      );
    });

    testWidgets('every demo device opens in every language without errors', (
      tester,
    ) async {
      await startHome();
      for (final language in AppLanguage.values) {
        for (final seed in DemoHome.devices()) {
          final data = TestHome();
          await data.start();
          await tester.pumpApp(
            size: const Size(360, 700),
            location: Routes.device(
              seed.descriptor.roomHint!,
              seed.descriptor.id,
            ),
            home: data,
            settings: buildSettings(saved: SettingsState(language: language)),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${seed.descriptor.id} in ${language.name}',
          );
        }
      }
    });
  });
}
