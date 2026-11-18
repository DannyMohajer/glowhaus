import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../../helpers/fakes.dart';

/// The phones the sheet is built for.
const _phones = <String, Size>{
  'iPhone SE': Size(375, 667),
  'iPhone 15': Size(393, 852),
  'iPhone 15 Plus': Size(430, 932),
};

class _Browser implements DemoBrowser {
  @override
  String? get initialRoute => null;

  @override
  bool get supportsTabs => true;

  @override
  BridgePort? channel(String name) => null;

  @override
  void openTab(String route) {}

  @override
  void showRoute(String route) {}

  @override
  void onPageHide(void Function() callback) {}

  @override
  TabLock? lock(String name) => null;
}

/// A demo whose devices are on the broker, so pressing one publishes.
///
/// [ambient] gives the devices their own rhythm — power and temperature
/// readings, as the real demo has every two seconds; it starts paused, so
/// a test turns it on when it wants it.
SimulatedTransport _demo({Duration? ambient}) => SimulatedTransport(
  homeId: DemoHome.homeId,
  devices: DemoHome.devices(),
  connectDelay: Duration.zero,
  ambientInterval: ambient,
)..home.ambientPaused = true;

/// Only what is inside the sheet: the app behind it names its devices too.
Finder inSheet(Finder finder) =>
    find.descendant(of: find.byType(DevicesPanel), matching: finder);

extension on WidgetTester {
  /// Opens the app on a phone with the demo, and the sheet over it.
  Future<SimulatedTransport> openSheet({
    Size size = const Size(393, 852),
    AppLanguage language = AppLanguage.en,
    ThemeMode themeMode = ThemeMode.light,
    bool connected = true,
    Duration? ambient,
  }) async {
    final demo = _demo(ambient: ambient);
    if (connected) await runAsync(demo.connect);
    await pumpApp(
      size: size,
      location: Routes.home,
      settings: buildSettings(
        saved: SettingsState(
          reduceMotion: true,
          language: language,
          themeMode: themeMode,
        ),
      ),
      demo: DemoSetup(demo: demo, browser: _Browser()),
    );
    await tap(find.byType(DemoPanelChip));
    await pumpAndSettle();
    return demo;
  }

  /// Presses a device's own button in the sheet and lets it publish.
  Future<void> pressFace(String label) async {
    await runAsync(() async {
      await tap(find.bySemanticsLabel(label));
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await pumpAndSettle();
  }
}

void main() {
  testWidgets('opened at /demo, the sheet comes up high', (tester) async {
    final demo = _demo();
    await tester.runAsync(demo.connect);
    addTearDown(() => tester.runAsync(demo.dispose));
    await tester.pumpApp(
      size: const Size(393, 852),
      location: Routes.demo,
      settings: buildSettings(saved: const SettingsState(reduceMotion: true)),
      demo: DemoSetup(demo: demo, browser: _Browser()),
      panelOpen: true,
    );
    await tester.pumpAndSettle();

    expect(find.byType(DevicesPanel), findsOneWidget);
    final top = tester.getTopLeft(find.byType(DevicesPanel)).dy;
    // A little over half the window, so a room card fits above it.
    expect(top, closeTo(852 * 0.45, 2));
    expect(
      tester.getSize(find.byType(DevicesPanel)).height,
      greaterThan(852 * 0.5),
    );
  });

  testWidgets('the header is one row: handle, title, info and close', (
    tester,
  ) async {
    final demo = await tester.openSheet(connected: false);
    addTearDown(() => tester.runAsync(demo.dispose));

    expect(find.byType(GlowDragHandle), findsOneWidget);
    expect(inSheet(find.text('Devices')), findsOneWidget);
    expect(find.bySemanticsLabel('Close the devices panel'), findsOneWidget);
    // The description and the hint are not in the way; they are one tap
    // away, in a popover.
    expect(find.textContaining('thirteen virtual devices'), findsNothing);
    expect(find.textContaining('Press a device like someone'), findsNothing);

    await tester.tap(find.bySemanticsLabel('What this panel is'));
    await tester.pumpAndSettle();
    expect(find.textContaining('thirteen virtual devices'), findsOneWidget);
    expect(find.textContaining('Press a device like someone'), findsOneWidget);
  });

  testWidgets('two columns of cards, under their room names', (tester) async {
    final demo = await tester.openSheet();
    addTearDown(() => tester.runAsync(demo.dispose));

    expect(inSheet(find.byType(GlowDeviceCard)), findsWidgets);
    expect(inSheet(find.byType(GlowFaceFrame)), findsNWidgets(13));
    // The cards are the ones the side panel has: a full-size face and the
    // plug as a bar along the bottom.
    expect(
      tester.getSize(inSheet(find.byType(GlowFaceFrame)).first).height,
      96,
    );
    expect(find.text('Plugged in'), findsWidgets);
    expect(find.bySemanticsLabel('Unplug Ceiling light'), findsOneWidget);

    // The living room's four devices: two to a row.
    final living = ['Ceiling light', 'Floor lamp', 'Curtain', 'Thermostat'];
    final rows = [
      for (final name in living) tester.getCenter(inSheet(find.text(name))).dy,
    ];
    expect(rows[0], rows[1], reason: 'first row');
    expect(rows[2], rows[3], reason: 'second row');
    expect(rows[2], greaterThan(rows[0]));
    expect(inSheet(find.text('Living Room')), findsOneWidget);
  });

  testWidgets('the bottom line says what happened, and opens the log', (
    tester,
  ) async {
    final demo = await tester.openSheet();
    addTearDown(() => tester.runAsync(demo.dispose));

    expect(find.text('Nothing yet. Tap something in the app.'), findsWidgets);

    // The ceiling light starts on, so the first press turns it off.
    await tester.pressFace('Ceiling light: Press its button');
    expect(find.text('Ceiling light · turned off · now'), findsOneWidget);
    // The protocol is behind it, not in front of it.
    expect(find.textContaining('glowhaus/demo-home/'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Show the MQTT traffic'));
    await tester.pumpAndSettle();
    expect(find.textContaining('glowhaus/demo-home/'), findsWidgets);
    expect(find.text('Ceiling light · turned off · now'), findsOneWidget);

    await tester.pressFace('Ceiling light: Press its button');
    expect(find.text('Ceiling light · turned on · now'), findsOneWidget);
  });

  testWidgets('the sheet is dragged by its header between its rests', (
    tester,
  ) async {
    final demo = await tester.openSheet();
    addTearDown(() => tester.runAsync(demo.dispose));

    double top() => tester.getTopLeft(find.byType(DevicesPanel)).dy;
    final open = top();

    // Down to the peek: the header and the line at the bottom are left.
    await tester.drag(find.byType(GlowDragHandle), const Offset(0, 400));
    await tester.pumpAndSettle();
    final peek = top();
    expect(peek, greaterThan(open));
    expect(find.text('Devices'), findsWidgets);

    // Back up: a flick takes it to the next rest, where it opened.
    await tester.drag(find.byType(GlowDragHandle), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(top(), closeTo(open, 1));

    // And once more, to full.
    await tester.drag(find.byType(GlowDragHandle), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(top(), lessThan(open));
  });

  testWidgets('the app above makes room and follows what the devices do', (
    tester,
  ) async {
    final demo = await tester.openSheet();
    addTearDown(() => tester.runAsync(demo.dispose));

    // One line instead of the two-line greeting.
    expect(find.byType(GreetingHeader), findsNothing);
    expect(find.text('Glowhaus Demo'), findsOneWidget);
    expect(find.textContaining('devices active'), findsOneWidget);

    // Every quick control in the app can ring when its device publishes.
    expect(find.byType(GlowPulseRing), findsWidgets);
    final before = tester
        .widgetList<GlowPulseRing>(find.byType(GlowPulseRing))
        .map((ring) => ring.tick)
        .toList();
    expect(before.every((tick) => tick == 0), isTrue);

    await tester.pressFace('Ceiling light: Press its button');
    final after = tester
        .widgetList<GlowPulseRing>(find.byType(GlowPulseRing))
        .map((ring) => ring.tick)
        .toList();
    expect(after.any((tick) => tick > 0), isTrue);

    // Closing it brings the greeting back.
    await tester.tap(find.bySemanticsLabel('Close the devices panel'));
    await tester.pumpAndSettle();
    expect(find.byType(GreetingHeader), findsOneWidget);
  });

  testWidgets('the devices reporting by themselves never move the app; a '
      'press moves it once', (tester) async {
    // Ten seconds with the devices talking the whole time: the demo's own
    // rhythm, twenty times over, so a hundred rounds of readings go by.
    final demo = await tester.openSheet(
      ambient: const Duration(milliseconds: 100),
    );
    addTearDown(() => tester.runAsync(demo.dispose));
    final panel = demo.traffic;

    double appOffset() => tester
        .state<ScrollableState>(
          find
              .ancestor(
                of: find.byType(RoomCard).first,
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position
        .pixels;

    Future<void> tick([int rounds = 20]) async {
      for (var i = 0; i < rounds; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    expect(appOffset(), 0);
    final before = panel.entries.length;
    demo.home.ambientPaused = false;
    await tick(100);

    // The devices really did talk for those ten seconds: the climate
    // sensor, the coffee machine and the rest, over and over.
    final said = panel.entries.skip(before).toList();
    expect(
      said.length,
      greaterThan(20),
      reason: 'the periodic publishers were running',
    );
    expect(
      said.map((entry) => entry.who).toSet(),
      containsAll(<String>['br-climate', 'kt-outlet']),
    );
    expect(
      appOffset(),
      0,
      reason: 'nobody touched anything; the app stays where it was',
    );
    // Nor does any chip ring for a reading that arrived by itself.
    expect(
      tester
          .widgetList<GlowPulseRing>(find.byType(GlowPulseRing))
          .every((ring) => ring.tick == 0),
      isTrue,
    );

    // A press, on a device in a room below the fold: the app follows, once.
    final list = find
        .descendant(
          of: find.byType(DevicesPanel),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.dragUntilVisible(
      find.bySemanticsLabel('Coffee machine: Press its button'),
      list,
      const Offset(0, -120),
    );
    await tick(3);
    await tester.runAsync(() async {
      await tester.tap(
        find.bySemanticsLabel('Coffee machine: Press its button'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tick(6);
    final followed = appOffset();
    expect(followed, greaterThan(0), reason: 'the kitchen came into sight');

    // And it stays there while the devices keep reporting.
    await tick();
    expect(appOffset(), followed);
  });

  testWidgets('the app scrolls to the room of the device that was pressed', (
    tester,
  ) async {
    final demo = await tester.openSheet();
    addTearDown(() => tester.runAsync(demo.dispose));

    double sheetTop() => tester.getTopLeft(find.byType(DevicesPanel)).dy;
    Finder kitchen() => find.ancestor(
      of: find.text('Kitchen'),
      matching: find.byType(RoomCard),
    );
    // The kitchen card starts below the sheet: out of sight.
    expect(tester.getTopLeft(kitchen()).dy, greaterThan(sheetTop()));

    // Press the coffee machine, which is in it.
    final list = find
        .descendant(
          of: find.byType(DevicesPanel),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.dragUntilVisible(
      find.bySemanticsLabel('Coffee machine: Press its button'),
      list,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.pressFace('Coffee machine: Press its button');

    // The app above has brought the kitchen into the strip it still shows.
    final top = tester.getTopLeft(kitchen()).dy;
    expect(top, greaterThanOrEqualTo(0));
    expect(top, lessThan(sheetTop()));
  });

  for (final MapEntry(key: name, value: size) in _phones.entries) {
    for (final (theme, mode) in [
      ('light', ThemeMode.light),
      ('dark', ThemeMode.dark),
    ]) {
      testWidgets('$name, $theme: the sheet and the app above it fit', (
        tester,
      ) async {
        final demo = await tester.openSheet(size: size, themeMode: mode);
        addTearDown(() => tester.runAsync(demo.dispose));

        expect(tester.takeException(), isNull);
        expect(find.byType(DevicesPanel), findsOneWidget);
        expect(find.byType(GlowDeviceCard), findsWidgets);
        // The sheet leaves the app above it a room card's worth of room.
        final top = tester.getTopLeft(find.byType(DevicesPanel)).dy;
        expect(top, closeTo(size.height * 0.45, 2));
        expect(find.byType(RoomCard), findsWidgets);
        expect(find.text('Glowhaus Demo'), findsOneWidget);
      });
    }
  }

  testWidgets('Persian: the sheet reads right to left', (tester) async {
    final demo = await tester.openSheet(
      size: const Size(375, 667),
      language: AppLanguage.fa,
    );
    addTearDown(() => tester.runAsync(demo.dispose));

    expect(tester.takeException(), isNull);
    expect(find.text('دستگاه‌ها'), findsWidgets);
    expect(
      Directionality.of(tester.element(find.byType(DevicesPanel))),
      TextDirection.rtl,
    );
    // The close button is at the start of the row in reading order, which
    // in Persian is the left.
    final close = tester.getCenter(find.bySemanticsLabel('بستن پنل دستگاه‌ها'));
    final handle = tester.getCenter(find.byType(GlowDragHandle));
    expect(close.dx, lessThan(handle.dx));
  });
}
