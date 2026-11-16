import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/dashboard/view/dashboard_screen.dart';
import 'package:glowhaus/features/intro/view/intro_screen.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../../helpers/fakes.dart';

void main() {
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
