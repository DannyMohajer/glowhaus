import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/dashboard/view/dashboard_screen.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/view/settings_screen.dart';
import 'package:glowhaus/features/welcome/view/welcome_screen.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('starts on welcome; the button opens the home', (tester) async {
    await tester.pumpApp();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(GlowBottomNav), findsNothing);

    await tester.tap(find.text("Let's start"));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(GlowBottomNav), findsOneWidget);
  });

  testWidgets('the root path redirects to welcome', (tester) async {
    await tester.pumpApp(location: '/');
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('phone: bottom navigation switches destinations', (tester) async {
    final router = await tester.pumpApp(location: Routes.home);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(router.state.uri.path, Routes.settings);

    await tester.tap(find.bySemanticsLabel('Rooms'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.rooms);
  });

  testWidgets('phone: a device link shows only the device, with a way back', (
    tester,
  ) async {
    final router = await tester.pumpApp(
      location: Routes.device('living-room', 'lr-lamp'),
    );
    expect(find.text('lr-lamp'), findsOneWidget);
    expect(find.text('living-room'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.room('living-room'));
    expect(find.text('living-room'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.rooms);
  });

  testWidgets('tablet: side rail; room and device side by side', (
    tester,
  ) async {
    await tester.pumpApp(
      size: tablet,
      location: Routes.device('living-room', 'lr-lamp'),
    );
    expect(find.byType(GlowNavRail), findsOneWidget);
    expect(find.byType(GlowBottomNav), findsNothing);
    expect(find.text('living-room'), findsOneWidget);
    expect(find.text('lr-lamp'), findsOneWidget);
    expect(
      tester.getCenter(find.text('living-room')).dx,
      lessThan(tester.getCenter(find.text('lr-lamp')).dx),
    );
  });

  testWidgets('tablet: the rooms route shows the list and a hint', (
    tester,
  ) async {
    await tester.pumpApp(size: tablet, location: Routes.rooms);
    expect(find.text('Select a room'), findsOneWidget);
  });

  testWidgets('desktop: rooms, room and device are all visible', (
    tester,
  ) async {
    await tester.pumpApp(
      size: desktop,
      location: Routes.device('kitchen', 'kt-outlet'),
    );
    final xs = [
      tester.getCenter(find.text('Rooms').last).dx,
      tester.getCenter(find.text('kitchen')).dx,
      tester.getCenter(find.text('kt-outlet')).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    expect(find.bySemanticsLabel('Back'), findsNothing);
  });

  testWidgets('desktop: a room without a device shows a device hint', (
    tester,
  ) async {
    await tester.pumpApp(size: desktop, location: Routes.room('kitchen'));
    expect(find.text('Select a device'), findsOneWidget);
  });

  testWidgets('resizing keeps the route and changes the layout', (
    tester,
  ) async {
    final router = await tester.pumpApp(
      size: desktop,
      location: Routes.device('kitchen', 'kt-outlet'),
    );
    tester.view.physicalSize = phone;
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.device('kitchen', 'kt-outlet'));
    expect(find.byType(GlowBottomNav), findsOneWidget);
    expect(find.text('kt-outlet'), findsOneWidget);
    expect(find.text('kitchen'), findsNothing);
  });

  testWidgets('tapping the current destination returns to its first page', (
    tester,
  ) async {
    final router = await tester.pumpApp(
      size: tablet,
      location: Routes.device('kitchen', 'kt-outlet'),
    );
    await tester.tap(find.bySemanticsLabel('Rooms').first);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.rooms);
  });

  testWidgets('Persian: the whole app is right to left', (tester) async {
    await tester.pumpApp(
      size: tablet,
      location: Routes.rooms,
      settings: buildSettings(
        saved: const SettingsState(language: AppLanguage.fa),
      ),
    );
    expect(
      Directionality.of(tester.element(find.byType(GlowNavRail))),
      TextDirection.rtl,
    );
    expect(find.text('اتاق‌ها'), findsWidgets);
    expect(
      tester.getCenter(find.byType(GlowNavRail)).dx,
      greaterThan(tablet.width / 2),
    );
  });
}
