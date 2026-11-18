import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

void main() {
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
