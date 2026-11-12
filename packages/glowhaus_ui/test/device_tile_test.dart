import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

void main() {
  Widget tile({
    bool on = true,
    bool offline = false,
    bool pending = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onToggle,
    Brightness brightness = Brightness.light,
  }) => host(
    brightness: brightness,
    SizedBox(
      width: 180,
      child: DeviceTile(
        title: 'Floor lamp',
        subtitle: on ? 'On · 55%' : 'Off',
        icon: GlowIcons.lamp,
        on: on,
        offline: offline,
        pending: pending,
        onTap: onTap,
        onToggle: onToggle,
      ),
    ),
  );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester
              .widget<AnimatedContainer>(
                find
                    .descendant(
                      of: find.byType(DeviceTile),
                      matching: find.byType(AnimatedContainer),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;

  testWidgets('on: shows name, status and a switch that is on', (tester) async {
    await tester.pumpWidget(tile(onToggle: (_) {}));
    expect(find.text('Floor lamp'), findsOneWidget);
    expect(find.text('On · 55%'), findsOneWidget);
    expect(
      tester.widget<ToggleSwitch>(find.byType(ToggleSwitch)).value,
      isTrue,
    );
    expect(find.byType(GlowSpinner), findsNothing);
    expect(find.byType(StatusDot), findsNothing);
  });

  testWidgets('off: switch is off; toggling asks for on', (tester) async {
    final toggles = <bool>[];
    await tester.pumpWidget(tile(on: false, onToggle: toggles.add));
    expect(
      tester.widget<ToggleSwitch>(find.byType(ToggleSwitch)).value,
      isFalse,
    );
    await tester.tap(find.byType(ToggleSwitch));
    expect(toggles, [true]);
  });

  testWidgets('tapping the tile opens it without toggling', (tester) async {
    var taps = 0;
    final toggles = <bool>[];
    await tester.pumpWidget(tile(onTap: () => taps++, onToggle: toggles.add));
    await tester.tap(find.text('Floor lamp'));
    expect(taps, 1);
    expect(toggles, isEmpty);

    await tester.tap(find.byType(ToggleSwitch));
    expect(taps, 1, reason: 'the switch does not open the tile');
    expect(toggles, [false]);
  });

  testWidgets('pending: spinner in the switch, still shows the new value', (
    tester,
  ) async {
    await tester.pumpWidget(tile(pending: true, onToggle: (_) {}));
    expect(find.byType(GlowSpinner), findsOneWidget);
    expect(
      tester.widget<ToggleSwitch>(find.byType(ToggleSwitch)).value,
      isTrue,
    );
  });

  testWidgets('pending without a switch shows a spinner in its place', (
    tester,
  ) async {
    await tester.pumpWidget(tile(pending: true));
    expect(find.byType(ToggleSwitch), findsNothing);
    expect(find.byType(GlowSpinner), findsOneWidget);
  });

  testWidgets('offline: dimmed, marked, switch disabled, still opens', (
    tester,
  ) async {
    var taps = 0;
    final toggles = <bool>[];
    await tester.pumpWidget(
      tile(offline: true, onTap: () => taps++, onToggle: toggles.add),
    );
    expect(find.byType(StatusDot), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find
                .descendant(
                  of: find.byType(DeviceTile),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
      0.5,
    );
    // The disabled switch does nothing itself; the whole tile is one target.
    await tester.tap(find.byType(ToggleSwitch), warnIfMissed: false);
    expect(toggles, isEmpty);
    await tester.tap(find.text('Floor lamp'));
    expect(taps, 2);
  });

  testWidgets('dark theme: glows only while on and reachable', (tester) async {
    await tester.pumpWidget(tile(brightness: Brightness.dark));
    expect(decorationOf(tester).boxShadow, isNotEmpty);
    expect(decorationOf(tester).color, GlowhausColors.dark().accentSoft);

    await tester.pumpWidget(tile(on: false, brightness: Brightness.dark));
    await tester.pumpAndSettle();
    expect(decorationOf(tester).boxShadow, isEmpty);

    await tester.pumpWidget(tile(offline: true, brightness: Brightness.dark));
    await tester.pumpAndSettle();
    expect(decorationOf(tester).boxShadow, isEmpty);
  });

  testWidgets('light theme never glows', (tester) async {
    await tester.pumpWidget(tile());
    expect(decorationOf(tester).boxShadow, isEmpty);
    expect(decorationOf(tester).color, GlowhausColors.light().surface);
  });

  testWidgets('switch is a 44 px target and exposes toggled semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(tile(onToggle: (_) {}));
    expect(
      tester.getSize(find.byType(ToggleSwitch)).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSemantics(
        find
            .descendant(
              of: find.byType(ToggleSwitch),
              matching: find.byType(Semantics),
            )
            .first,
      ),
      matchesSemantics(
        label: 'Floor lamp',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('survives 2x text scale in a narrow tile', (tester) async {
    await tester.pumpWidget(
      host(
        textScale: 2,
        SizedBox(
          width: 150,
          child: DeviceTile(
            title: 'Front door lock with a long name',
            subtitle: 'Locked · a long status line',
            icon: GlowIcons.lock,
            on: true,
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
