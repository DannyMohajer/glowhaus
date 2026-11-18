import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/dashboard/view/dashboard_screen.dart';
import 'package:glowhaus/features/device/view/device_pane.dart';
import 'package:glowhaus/features/intro/view/intro_screen.dart';
import 'package:glowhaus/features/rooms/view/rooms_panes.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/view/settings_screen.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('starts on the intro; the button opens the home', (tester) async {
    await tester.pumpApp();
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.byType(GlowBottomNav), findsNothing);

    await tester.tap(find.text("Let's start"));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(GlowBottomNav), findsOneWidget);
  });

  testWidgets('the root path is the home, and a first visit sees the intro '
      'on the way there', (tester) async {
    await tester.pumpApp(location: '/');
    expect(find.byType(DashboardScreen), findsOneWidget);

    final router = await tester.pumpApp(location: '/', firstVisit: () => true);
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(router.state.uri.path, Routes.intro);
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
    expect(find.byType(DevicePane), findsOneWidget);
    expect(find.byType(RoomPane), findsNothing);
    expect(find.byType(RoomsListPane), findsNothing);
    expect(find.text('Floor lamp'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.room('living-room'));
    expect(find.byType(RoomPane), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.rooms);
    expect(find.byType(RoomsListPane), findsOneWidget);
  });

  testWidgets('phone: rooms list, room, device by tapping through', (
    tester,
  ) async {
    final router = await tester.pumpApp(location: Routes.rooms);
    await tester.tap(find.text('Kitchen'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.room('kitchen'));

    await tester.tap(find.text('Coffee machine'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.device('kitchen', 'kt-outlet'));
    expect(find.byType(DevicePane), findsOneWidget);
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
    expect(find.byType(RoomsListPane), findsNothing);
    expect(
      tester.getCenter(find.byType(RoomPane)).dx,
      lessThan(tester.getCenter(find.byType(DevicePane)).dx),
    );
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
  });

  testWidgets('tablet: the rooms route shows the list and a hint', (
    tester,
  ) async {
    await tester.pumpApp(size: tablet, location: Routes.rooms);
    expect(find.byType(RoomsListPane), findsOneWidget);
    expect(find.text('Select a room'), findsOneWidget);
  });

  testWidgets('desktop: rooms, room and device are all visible', (
    tester,
  ) async {
    final router = await tester.pumpApp(
      size: desktop,
      location: Routes.device('kitchen', 'kt-outlet'),
    );
    final xs = [
      tester.getCenter(find.byType(RoomsListPane)).dx,
      tester.getCenter(find.byType(RoomPane)).dx,
      tester.getCenter(find.byType(DevicePane)).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    expect(find.bySemanticsLabel('Back'), findsNothing);

    // Picking another room swaps the middle pane and clears the device.
    await tester.tap(find.text('Entrance'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.room('entrance'));
    expect(find.text('Select a device'), findsOneWidget);

    await tester.tap(find.text('Front door lock'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.device('entrance', 'en-lock'));
    expect(find.byType(RoomsListPane), findsOneWidget);
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
    expect(find.byType(DevicePane), findsOneWidget);
    expect(find.byType(RoomPane), findsNothing);
  });

  testWidgets('unknown room or device shows a message, not a crash', (
    tester,
  ) async {
    await tester.pumpApp(location: Routes.room('attic'));
    expect(find.text('This room no longer exists'), findsOneWidget);
    await tester.pumpApp(location: Routes.device('kitchen', 'ghost'));
    expect(find.text('This device is no longer available'), findsOneWidget);
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
