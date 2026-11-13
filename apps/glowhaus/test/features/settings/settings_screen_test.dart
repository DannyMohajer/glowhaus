import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/view/settings_screen.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../../helpers/fakes.dart';

void main() {
  BuildContext contextOf(WidgetTester tester) =>
      tester.element(find.byType(SettingsScreen));

  testWidgets('theme: switching to dark changes the app theme', (tester) async {
    final settings = buildSettings();
    await tester.pumpApp(location: Routes.settings, settings: settings);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(settings.state.themeMode, ThemeMode.dark);
    expect(contextOf(tester).colors.isDark, isTrue);
    expect(
      Theme.of(contextOf(tester)).scaffoldBackgroundColor,
      const Color(0xFF111111),
    );
  });

  testWidgets('accent: picking blue recolours the theme', (tester) async {
    final settings = buildSettings();
    await tester.pumpApp(location: Routes.settings, settings: settings);
    await tester.tap(find.bySemanticsLabel('Blue'));
    await tester.pumpAndSettle();
    expect(settings.state.accent, AccentChoice.blue);
    expect(contextOf(tester).colors.accent, const Color(0xFF2F6BFF));
  });

  testWidgets('language: Persian switches text and direction live', (
    tester,
  ) async {
    final languages = FakeLanguagePreparer();
    final settings = buildSettings(languages: languages);
    await tester.pumpApp(location: Routes.settings, settings: settings);
    expect(find.text('Settings'), findsWidgets);

    await tester.ensureVisible(find.text('فارسی'));
    await tester.tap(find.text('فارسی'));
    await tester.pumpAndSettle();
    expect(languages.prepared, [AppLanguage.fa]);
    expect(find.text('تنظیمات'), findsWidgets);
    expect(Directionality.of(contextOf(tester)), TextDirection.rtl);
    expect(
      contextOf(tester).type.body.fontFamily,
      'packages/glowhaus_ui/Vazirmatn',
    );

    await tester.ensureVisible(find.text('Türkçe'));
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();
    expect(find.text('Ayarlar'), findsWidgets);
    expect(Directionality.of(contextOf(tester)), TextDirection.ltr);
  });

  testWidgets('reduce motion turns the motion tokens off', (tester) async {
    final settings = buildSettings();
    await tester.pumpApp(location: Routes.settings, settings: settings);
    await tester.tap(find.bySemanticsLabel('Reduce motion'));
    await tester.pumpAndSettle();
    expect(settings.state.reduceMotion, isTrue);
    expect(contextOf(tester).motion.reduced, isTrue);
  });

  testWidgets('simulation: sliders drive latency and failure rate', (
    tester,
  ) async {
    final simulation = FakeSimulationControl();
    final settings = buildSettings(simulation: simulation);
    await tester.pumpApp(
      size: const Size(390, 1400),
      location: Routes.settings,
      settings: settings,
    );
    expect(find.text('250 ms'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    final sliders = find.byType(Slider);
    await tester.tapAt(tester.getCenter(sliders.at(0)));
    await tester.pumpAndSettle();
    expect(settings.state.latencyMs, 1000);
    expect(find.text('1,000 ms'), findsOneWidget);

    await tester.tapAt(tester.getCenter(sliders.at(1)));
    await tester.pumpAndSettle();
    expect(settings.state.failureRate, 0.25);
    expect(find.text('25%'), findsOneWidget);
    expect(simulation.applied.last, (
      latency: const Duration(seconds: 1),
      failureRate: 0.25,
    ));
  });

  testWidgets('simulation section hides when there is no simulation', (
    tester,
  ) async {
    await tester.pumpApp(
      location: Routes.settings,
      settings: buildSettings(
        simulation: FakeSimulationControl(available: false),
      ),
    );
    expect(find.text('Simulation'), findsNothing);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('Persian uses Persian digits for numbers', (tester) async {
    await tester.pumpApp(
      size: const Size(390, 1400),
      location: Routes.settings,
      settings: buildSettings(
        saved: const SettingsState(language: AppLanguage.fa, failureRate: 0.3),
      ),
    );
    expect(find.text('۳۰٪'), findsOneWidget);
    expect(find.text('۲۵۰ میلی‌ثانیه'), findsOneWidget);
  });

  testWidgets('fits a small phone at 2x text in every language', (
    tester,
  ) async {
    for (final language in AppLanguage.values) {
      await tester.pumpApp(
        size: const Size(320, 640),
        location: Routes.settings,
        settings: buildSettings(saved: SettingsState(language: language)),
      );
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: language.name);
    }
  });
}
