import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

const _nav = [
  GlowNavItem(icon: GlowIcons.house, label: 'Home'),
  GlowNavItem(icon: GlowIcons.layoutGrid, label: 'Rooms'),
  GlowNavItem(icon: GlowIcons.settings, label: 'Settings'),
];

void main() {
  group('ToggleSwitch', () {
    double thumbX(WidgetTester tester) => tester
        .getCenter(
          find.descendant(
            of: find.byType(AnimatedAlign),
            matching: find.byType(Container),
          ),
        )
        .dx;

    testWidgets('thumb sits at the end when on, mirrored in RTL', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(ToggleSwitch(value: true, onChanged: (_) {})),
      );
      final centre = tester.getCenter(find.byType(ToggleSwitch)).dx;
      expect(thumbX(tester), greaterThan(centre));

      await tester.pumpWidget(
        host(
          ToggleSwitch(value: true, onChanged: (_) {}),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(thumbX(tester), lessThan(centre));
    });

    testWidgets('reduced motion: changes without animating', (tester) async {
      Widget build({required bool value}) => host(
        ToggleSwitch(value: value, onChanged: (_) {}),
        reduceMotion: true,
      );
      await tester.pumpWidget(build(value: false));
      final off = thumbX(tester);
      await tester.pumpWidget(build(value: true));
      await tester.pump();
      final afterOneFrame = thumbX(tester);
      expect(afterOneFrame, greaterThan(off));
      await tester.pumpAndSettle();
      expect(thumbX(tester), afterOneFrame, reason: 'already at rest');
    });
  });

  group('GlowSegmented', () {
    Widget segmented({
      required int selected,
      ValueChanged<int>? onChanged,
      TextDirection direction = TextDirection.ltr,
    }) => host(
      SizedBox(
        width: 340,
        child: GlowSegmented<int>(
          selected: selected,
          onChanged: onChanged,
          semanticLabel: 'Mode',
          segments: const [
            GlowSegment(value: 0, label: 'Off', icon: GlowIcons.power),
            GlowSegment(value: 1, label: 'Heat', icon: GlowIcons.flame),
            GlowSegment(value: 2, label: 'Cool', icon: GlowIcons.snowflake),
            GlowSegment(value: 3, label: 'Auto', icon: GlowIcons.sunMoon),
          ],
        ),
      ),
      direction: direction,
    );

    testWidgets('tapping another segment reports it; the selected one '
        'does nothing', (tester) async {
      final picked = <int>[];
      await tester.pumpWidget(segmented(selected: 1, onChanged: picked.add));
      await tester.tap(find.text('Cool'));
      await tester.tap(find.text('Heat'));
      expect(picked, [2]);
    });

    testWidgets('equal widths, touch-sized, mirrored in RTL', (tester) async {
      await tester.pumpWidget(segmented(selected: 0, onChanged: (_) {}));
      final widths = [
        for (final label in ['Off', 'Heat', 'Cool', 'Auto'])
          tester
              .getSize(
                find.ancestor(
                  of: find.text(label),
                  matching: find.byType(GlowPressable),
                ),
              )
              .width,
      ];
      expect(widths.toSet(), hasLength(1));
      final off = find.ancestor(
        of: find.text('Off'),
        matching: find.byType(GlowPressable),
      );
      expect(tester.getSize(off).height, greaterThanOrEqualTo(48));
      final ltrOff = tester.getCenter(find.text('Off')).dx;

      await tester.pumpWidget(
        segmented(selected: 0, onChanged: (_) {}, direction: TextDirection.rtl),
      );
      expect(tester.getCenter(find.text('Off')).dx, greaterThan(ltrOff));
    });

    testWidgets('announces each option as a selected or unselected button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(segmented(selected: 2, onChanged: (_) {}));
      expect(
        tester.getSemantics(find.text('Cool')),
        matchesSemantics(
          label: 'Cool',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasSelectedState: true,
          isSelected: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Heat')),
        matchesSemantics(
          label: 'Heat',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasSelectedState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('disabled without onChanged', (tester) async {
      await tester.pumpWidget(segmented(selected: 0));
      await tester.tap(find.text('Heat'));
      expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0.5);
    });
  });

  group('DeviceTone', () {
    testWidgets('a tile switch can be on while the tile stays calm', (
      tester,
    ) async {
      final colors = GlowhausColors.light();
      Future<Color?> disc(DeviceTone? tone, {required bool on}) async {
        await tester.pumpWidget(
          host(
            SizedBox(
              width: 200,
              child: DeviceTile(
                title: 'Front door',
                subtitle: 'Locked',
                icon: GlowIcons.lock,
                on: on,
                tone: tone,
                onToggle: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final container = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byIcon(GlowIcons.lock),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        return (container.decoration! as BoxDecoration).color;
      }

      expect(await disc(null, on: true), colors.accent);
      expect(await disc(DeviceTone.neutral, on: true), colors.surfaceAlt);
      expect(await disc(DeviceTone.attention, on: false), colors.warning);
      expect(
        tester.widget<ToggleSwitch>(find.byType(ToggleSwitch)).value,
        isFalse,
      );
    });
  });

  group('touch targets and semantics', () {
    testWidgets('chip, icon button and quick control are at least 44 px', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowChip(label: 'All', onTap: () {}),
              IconButtonRound(
                icon: GlowIcons.bell,
                semanticLabel: 'Notifications',
                onTap: () {},
              ),
              RoomQuickControl(
                icon: GlowIcons.lamp,
                label: 'Lamp',
                on: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      for (final type in [GlowChip, IconButtonRound, RoomQuickControl]) {
        expect(
          tester.getSize(find.byType(type)).height,
          greaterThanOrEqualTo(44),
          reason: '$type',
        );
      }
    });

    testWidgets('chip reports selection; icon button has a label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowChip(label: 'Lights', selected: true, onTap: () {}),
              IconButtonRound(
                icon: GlowIcons.bell,
                semanticLabel: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(GlowChip)),
        isSemantics(label: 'Lights', isSelected: true, isButton: true),
      );
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keyboard: enter activates the focused control', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(GlowButton(label: "Let's start", onTap: () => taps++)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('PositionSlider', () {
    Widget slider(List<int> changes, List<int> ends, {TextDirection? dir}) =>
        host(
          direction: dir ?? TextDirection.ltr,
          SizedBox(
            width: 300,
            child: PositionSlider(
              value: 40,
              reportedValue: 20,
              startLabel: 'Closed',
              endLabel: 'Open',
              semanticLabel: 'Curtain',
              onChanged: changes.add,
              onChangeEnd: ends.add,
            ),
          ),
        );

    testWidgets('tap sets a snapped value', (tester) async {
      final changes = <int>[];
      final ends = <int>[];
      await tester.pumpWidget(slider(changes, ends));
      final rect = tester.getRect(find.byType(GestureDetector).first);
      await tester.tapAt(rect.centerLeft + const Offset(226, 0));
      expect(changes, [75]);
      expect(ends, [75]);
    });

    testWidgets('mirrors in RTL', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(slider(changes, [], dir: TextDirection.rtl));
      final rect = tester.getRect(find.byType(GestureDetector).first);
      await tester.tapAt(rect.centerLeft + const Offset(226, 0));
      expect(changes, [25]);
      expect(
        tester.getCenter(find.text('Closed')).dx,
        greaterThan(tester.getCenter(find.text('Open')).dx),
      );
    });

    testWidgets('drag reports continuously', (tester) async {
      final changes = <int>[];
      final ends = <int>[];
      await tester.pumpWidget(slider(changes, ends));
      final rect = tester.getRect(find.byType(GestureDetector).first);
      await tester.dragFrom(
        rect.centerLeft + const Offset(30, 0),
        const Offset(200, 0),
      );
      expect(changes.length, greaterThan(1));
      expect(changes.last, greaterThan(changes.first));
      expect(ends, hasLength(1));
    });
  });

  group('adaptive layout', () {
    Widget scaffold() => host(
      center: false,
      AdaptiveScaffold(
        destinations: _nav,
        currentIndex: 0,
        onDestinationSelected: (_) {},
        body: const AdaptivePanes(
          panes: [
            Center(child: Text('rooms')),
            Center(child: Text('room')),
            Center(child: Text('device')),
          ],
        ),
      ),
    );

    testWidgets('phone: bottom navigation, only the last pane', (tester) async {
      tester.useSurface(const Size(390, 800));
      await tester.pumpWidget(scaffold());
      expect(find.byType(GlowBottomNav), findsOneWidget);
      expect(find.byType(GlowNavRail), findsNothing);
      expect(find.text('device'), findsOneWidget);
      expect(find.text('room'), findsNothing);
    });

    testWidgets('medium: side rail, two panes', (tester) async {
      tester.useSurface(const Size(800, 900));
      await tester.pumpWidget(scaffold());
      expect(find.byType(GlowNavRail), findsOneWidget);
      expect(find.byType(GlowBottomNav), findsNothing);
      expect(find.text('rooms'), findsNothing);
      expect(find.text('room'), findsOneWidget);
      expect(find.text('device'), findsOneWidget);
    });

    testWidgets('expanded: side rail, three panes in reading order', (
      tester,
    ) async {
      tester.useSurface(const Size(1280, 900));
      await tester.pumpWidget(scaffold());
      final xs = [
        for (final label in ['rooms', 'room', 'device'])
          tester.getCenter(find.text(label)).dx,
      ];
      expect(xs, orderedEquals([...xs]..sort()));
      expect(tester.getCenter(find.byType(GlowNavRail)).dx, lessThan(xs.first));
    });

    testWidgets('RTL: rail and panes flip', (tester) async {
      tester.useSurface(const Size(1280, 900));
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.rtl, child: scaffold()),
      );
      await tester.pumpWidget(
        host(
          center: false,
          direction: TextDirection.rtl,
          AdaptiveScaffold(
            destinations: _nav,
            currentIndex: 0,
            onDestinationSelected: (_) {},
            body: const AdaptivePanes(
              panes: [
                Center(child: Text('rooms')),
                Center(child: Text('room')),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getCenter(find.text('rooms')).dx,
        greaterThan(tester.getCenter(find.text('room')).dx),
      );
      expect(
        tester.getCenter(find.byType(GlowNavRail)).dx,
        greaterThan(tester.getCenter(find.text('rooms')).dx),
      );
    });

    testWidgets('bottom nav: tapping reports the index; fits at 2x text', (
      tester,
    ) async {
      tester.useSurface(const Size(360, 700));
      final taps = <int>[];
      await tester.pumpWidget(
        host(
          center: false,
          textScale: 2,
          Align(
            alignment: Alignment.bottomCenter,
            child: GlowBottomNav(items: _nav, currentIndex: 1, onTap: taps.add),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.bySemanticsLabel('Settings'));
      expect(taps, [2]);
      expect(find.text('Rooms'), findsOneWidget, reason: 'selected label');
      expect(find.text('Home'), findsNothing);
    });
  });

  testWidgets('room card: opens on tap, controls work on their own', (
    tester,
  ) async {
    tester.useSurface(const Size(390, 800));
    var opened = 0;
    var toggled = 0;
    await tester.pumpWidget(
      host(
        textScale: 1.5,
        RoomCard(
          title: 'Living Room',
          subtitle: '4 devices · 2 on',
          icon: GlowIcons.sofa,
          meta: '20.8°',
          onTap: () => opened++,
          controls: [
            RoomQuickControl(
              icon: GlowIcons.lamp,
              label: 'Floor lamp',
              on: true,
              onTap: () => toggled++,
            ),
            const RoomQuickControl(
              icon: GlowIcons.lightbulb,
              label: 'Ceiling',
              on: false,
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Living Room'));
    await tester.tap(find.text('Floor lamp'));
    await tester.tap(find.text('Ceiling'), warnIfMissed: false);
    expect((opened, toggled), (1, 1));
  });
}
