import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

Widget _card({bool compact = false, bool online = true, int tick = 0}) =>
    GlowDeviceCard(
      name: 'Ceiling light',
      status: 'On · 70%',
      face: GlowLightFace(on: true, onTap: () {}, semanticLabel: 'press it'),
      online: online,
      active: true,
      compact: compact,
      publishTick: tick,
      plugLabel: online ? 'Plugged in' : 'Unplugged',
      plugSemanticLabel: online ? 'Unplug Ceiling light' : 'Plug it back in',
      onPlug: () {},
    );

void main() {
  group('GlowDeviceCard', () {
    testWidgets('full: the face is 96 px and the plug is a labelled bar', (
      tester,
    ) async {
      await tester.pumpWidget(host(SizedBox(width: 200, child: _card())));
      expect(tester.getSize(find.byType(GlowFaceFrame)).height, 96);
      expect(find.text('Plugged in'), findsOneWidget);
    });

    testWidgets('compact: the same face scaled to 56 px, no plug bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SizedBox(width: 120, child: _card(compact: true))),
      );
      // The drawing itself is unchanged; only the box it is drawn in is.
      expect(find.byType(GlowLightFace), findsOneWidget);
      expect(tester.getSize(find.byType(GlowFaceFrame)).height, 56);
      expect(find.text('Plugged in'), findsNothing);
      expect(find.text('Ceiling light'), findsOneWidget);
      expect(find.text('On · 70%'), findsOneWidget);
    });

    testWidgets('compact: the plug is a 44 px button that says what it does', (
      tester,
    ) async {
      var plugged = true;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 120,
            child: GlowDeviceCard(
              name: 'Ceiling light',
              status: 'On',
              face: const GlowFaceFrame(child: SizedBox.shrink()),
              compact: true,
              plugLabel: 'Plugged in',
              plugSemanticLabel: 'Unplug Ceiling light',
              onPlug: () => plugged = false,
            ),
          ),
        ),
      );
      final plug = find.bySemanticsLabel('Unplug Ceiling light');
      expect(plug, findsOneWidget);
      expect(tester.getSize(plug).height, greaterThanOrEqualTo(44));
      await tester.tap(plug);
      expect(plugged, isFalse);
    });

    testWidgets('compact: an unplugged card dims and greys its face', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SizedBox(width: 120, child: _card(compact: true, online: false))),
      );
      await tester.pumpAndSettle();
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(opacity.opacity, lessThan(1));
      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });

  group('GlowPulseRing', () {
    testWidgets('a new tick draws a ring that fades within 600 ms', (
      tester,
    ) async {
      Widget pulsing(int tick) => host(
        GlowPulseRing(tick: tick, child: const SizedBox.square(dimension: 40)),
      );

      await tester.pumpWidget(pulsing(0));
      expect(find.byType(DecoratedBox), findsNothing);

      await tester.pumpWidget(pulsing(1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DecoratedBox), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(DecoratedBox), findsNothing);
    });

    testWidgets('reduced motion: no ring at all', (tester) async {
      Widget pulsing(int tick) => host(
        GlowPulseRing(tick: tick, child: const SizedBox.square(dimension: 40)),
        reduceMotion: true,
      );
      await tester.pumpWidget(pulsing(0));
      await tester.pumpWidget(pulsing(1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DecoratedBox), findsNothing);
    });
  });
}
