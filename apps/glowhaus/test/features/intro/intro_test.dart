import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/app/start_location.dart';
import 'package:glowhaus/features/dashboard/view/dashboard_screen.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/demo_panel_host.dart';
import 'package:glowhaus/features/demo/view/devices_panel.dart';
import 'package:glowhaus/features/intro/view/intro_screen.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../../helpers/fakes.dart';

/// A browser with no tabs of its own; the demo only needs its devices here.
class _Browser implements DemoBrowser {
  new(this.initialRoute);

  @override
  final String? initialRoute;

  @override
  bool get supportsTabs => false;

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

DemoSetup _demo() => DemoSetup(
  demo: SimulatedTransport(
    homeId: DemoHome.homeId,
    devices: DemoHome.devices(),
    ambientInterval: null,
  ),
  browser: _Browser(null),
);

void main() {
  group('where the app opens', () {
    test('it is the address the page was opened at, or the home', () {
      expect(startLocation('/demo?quiet'), '/demo?quiet');
      expect(startLocation(Routes.demo), Routes.demo);
      expect(startLocation(null), Routes.home);
    });

    test('`quiet` is read from the fragment as well as the query', () {
      expect(quietDemo(Uri.parse('https://x.dev/#/demo?quiet')), isTrue);
      expect(quietDemo(Uri.parse('https://x.dev/?quiet#/demo')), isTrue);
      expect(quietDemo(Uri.parse('https://x.dev/#/demo')), isFalse);
    });

    test('what the intro goes on to is a route of this app, or home', () {
      expect(
        Routes.nextAfterIntro(Uri.parse(Routes.introTo('/demo?quiet'))),
        '/demo?quiet',
      );
      expect(Routes.nextAfterIntro(Uri.parse(Routes.intro)), Routes.home);
      expect(
        Routes.nextAfterIntro(Uri.parse('/intro?next=https://elsewhere.test')),
        Routes.home,
      );
    });
  });

  testWidgets('the intro is shown once: starting remembers it', (tester) async {
    final store = FakeSettingsStore(const SettingsState());
    final settings = buildSettings(store: store);
    final router = await tester.pumpApp(settings: settings);

    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.text('Welcome to Glowhaus'), findsOneWidget);
    expect(find.text('Curious how it works?'), findsOneWidget);

    await tester.tap(find.text("Let's start"));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(settings.state.showIntro, isFalse);
    expect(store.saved?.showIntro, isFalse, reason: 'survives a reload');
  });

  testWidgets('a first visit to #/demo sees the intro, then lands on the '
      'devices', (tester) async {
    // Reduced motion, or the device faces never stop breathing.
    final store = FakeSettingsStore(const SettingsState(reduceMotion: true));
    final demo = _demo();
    addTearDown(() => tester.runAsync(demo.demo.dispose));
    final settings = buildSettings(store: store);
    final router = await tester.pumpApp(
      // As the web does it: the address wins, and the intro is a redirect.
      location: startLocation(Routes.demo),
      settings: settings,
      firstVisit: () => settings.shouldShowIntro,
      demo: demo,
      panelOpen: true,
    );
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(router.state.uri.path, Routes.intro);

    await tester.tap(find.text("Let's start"));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.demo);
    expect(find.byType(DevicesPanel), findsOneWidget, reason: 'the sheet');
    expect(store.saved?.showIntro, isFalse);
  });

  testWidgets('a second visit to #/demo goes straight in', (tester) async {
    final demo = _demo();
    addTearDown(() => tester.runAsync(demo.demo.dispose));
    final settings = buildSettings(
      saved: const SettingsState(showIntro: false, reduceMotion: true),
    );
    final router = await tester.pumpApp(
      location: startLocation(Routes.demo),
      settings: settings,
      firstVisit: () => settings.shouldShowIntro,
      demo: demo,
      panelOpen: true,
    );
    expect(find.byType(IntroScreen), findsNothing);
    expect(router.state.uri.path, Routes.demo);
    expect(find.byType(DevicesPanel), findsOneWidget);
  });

  testWidgets('#/demo?quiet skips the intro on a first visit too', (
    tester,
  ) async {
    final demo = _demo();
    addTearDown(() => tester.runAsync(demo.demo.dispose));
    final settings = buildSettings(
      saved: const SettingsState(reduceMotion: true),
    );
    final router = await tester.pumpApp(
      location: startLocation('/demo?quiet'),
      settings: settings,
      // What `main` passes for a recording: a first visit all the same.
      firstVisit: () => false,
      demo: demo,
      panelOpen: true,
    );
    expect(settings.shouldShowIntro, isTrue, reason: 'still a first visit');
    expect(find.byType(IntroScreen), findsNothing);
    expect(router.state.uri.path, Routes.demo);
    expect(router.state.uri.queryParameters, containsPair('quiet', ''));
  });

  testWidgets('a window that cannot save settings still starts and shows '
      'the intro', (tester) async {
    final store = FailingSettingsStore();
    final settings = buildSettings(store: store);
    final router = await tester.pumpApp(
      location: startLocation(null),
      settings: settings,
      firstVisit: () => settings.shouldShowIntro,
    );
    expect(find.byType(IntroScreen), findsOneWidget);

    await tester.tap(find.text("Let's start"));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.state.uri.path, Routes.home);
    // It is forgotten, so the next visit is a first visit again.
    expect(settings.state.showIntro, isFalse);
    expect(store.saved, isNull);
  });

  testWidgets('settings can ask for the intro again', (tester) async {
    final settings = buildSettings(
      saved: const SettingsState(showIntro: false),
    );
    await tester.pumpApp(location: Routes.settings, settings: settings);
    expect(settings.shouldShowIntro, isFalse);

    final row = find.bySemanticsLabel('Show intro again');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(settings.state.showIntro, isTrue);
    expect(settings.shouldShowIntro, isTrue);
  });

  testWidgets('Persian: the headline is mirrored to the right', (tester) async {
    await tester.pumpApp(
      settings: buildSettings(
        saved: const SettingsState(language: AppLanguage.fa),
      ),
    );
    final headline = find.text('به گلوهاوس خوش آمدی');
    expect(headline, findsOneWidget);
    expect(
      Directionality.of(tester.element(headline)),
      TextDirection.rtl,
      reason: 'the shape and its headline flip with the language',
    );
    final screen = tester.getRect(find.byType(GlowIntroPanel));
    expect(
      tester.getRect(headline).right,
      closeTo(screen.right - 28, 1),
      reason: 'top right in Persian, with the same 28 px padding',
    );
  });
}
