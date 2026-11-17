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
SimulatedTransport _demo() => SimulatedTransport(
  homeId: DemoHome.homeId,
  devices: DemoHome.devices(),
  connectDelay: Duration.zero,
  ambientInterval: null,
);

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
  }) async {
    final demo = _demo();
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

  testWidgets('three columns of compact cards, under their room names', (
    tester,
  ) async {
    final demo = await tester.openSheet();
    addTearDown(() => tester.runAsync(demo.dispose));

    expect(find.byType(GlowDeviceCard), findsWidgets);
    final card = tester.widget<GlowDeviceCard>(
      find.byType(GlowDeviceCard).first,
    );
    expect(card.compact, isTrue);
    // The faces are the same drawings, at the compact height.
    expect(
      tester.getSize(inSheet(find.byType(GlowFaceFrame)).first).height,
      glowFaceHeightCompact,
    );
    // The living room's four devices: three in a row, the fourth below.
    final living = ['Ceiling light', 'Floor lamp', 'Curtain'];
    final row = [
      for (final name in living) tester.getCenter(inSheet(find.text(name))).dy,
    ];
    expect(row.toSet(), hasLength(1), reason: 'one row of three');
    expect(inSheet(find.text('Living Room')), findsOneWidget);
    // The plug is a button in the corner, not a bar with a label.
    expect(find.text('Plugged in'), findsNothing);
    expect(inSheet(find.byType(GlowFaceFrame)), findsNWidgets(13));
    expect(find.bySemanticsLabel('Unplug Ceiling light'), findsOneWidget);
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
    final half = top();

    // Down to the peek: the header and the line at the bottom.
    await tester.drag(find.byType(GlowDragHandle), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(top(), greaterThan(half));
    final peek = top();
    expect(find.text('Devices'), findsOneWidget);

    // Up to full.
    await tester.drag(find.byType(GlowDragHandle), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(top(), lessThan(half));
    expect(top(), lessThan(peek));
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
        // The sheet leaves the app above it something to show.
        expect(
          tester.getTopLeft(find.byType(DevicesPanel)).dy,
          greaterThan(size.height * 0.4),
        );
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
