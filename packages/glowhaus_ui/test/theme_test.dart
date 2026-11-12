import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  final light = GlowhausColors.light();
  final dark = GlowhausColors.dark();

  test('tokens match the design spec', () {
    expect(light.bg, const Color(0xFFF1F1EF));
    expect(light.surface, const Color(0xFFFFFFFF));
    expect(light.accent, const Color(0xFFFF5A1F));
    expect(light.accentSoft, const Color(0xFFFFE6DC));
    expect(light.inverse, const Color(0xFF111111));
    expect(dark.bg, const Color(0xFF111111));
    expect(dark.surface, const Color(0xFF1C1C1C));
    expect(dark.accent, const Color(0xFFFF6A2E));
    expect(dark.accentSoft, const Color(0xFF3A2016));
    expect(dark.cool, const Color(0xFF6FA8C8));
  });

  test('accent is swappable and derives its soft variant', () {
    const blue = Color(0xFF2F6BFF);
    for (final colors in [
      GlowhausColors.light(accent: blue),
      GlowhausColors.dark(accent: blue),
    ]) {
      expect(colors.accent, blue);
      expect(colors.accentSoft, isNot(blue));
      expect(colors.accentSoft.a, 1);
      expect(colors.heat, isNot(blue), reason: 'state colours stay fixed');
    }
    expect(light.copyWith(accent: blue).accent, blue);
  });

  test('primary text meets 4.5:1 on every surface, both themes', () {
    for (final colors in [light, dark]) {
      for (final surface in [colors.bg, colors.surface, colors.surfaceAlt]) {
        expect(_contrast(colors.text, surface), greaterThanOrEqualTo(4.5));
      }
      expect(
        _contrast(colors.onInverse, colors.inverse),
        greaterThanOrEqualTo(4.5),
      );
    }
    // Dark theme secondary text also passes.
    expect(_contrast(dark.textMuted, dark.surface), greaterThanOrEqualTo(4.5));
  });

  test('lerp reaches both ends', () {
    expect(light.lerp(dark, 0).bg, light.bg);
    expect(light.lerp(dark, 1).bg, dark.bg);
    expect(light.lerp(dark, 1).brightness, Brightness.dark);
  });

  test('type scale: 36 / 24 / 18 / 15 / 12 with the right family', () {
    final latin = GlowhausTypography.build(color: light.text);
    expect(
      [
        latin.display,
        latin.title,
        latin.heading,
        latin.body,
        latin.caption,
      ].map((s) => s.fontSize),
      [36, 24, 18, 15, 12],
    );
    expect(latin.body.fontFamily, 'packages/glowhaus_ui/Manrope');
    expect(latin.body.fontFamilyFallback, ['packages/glowhaus_ui/Vazirmatn']);

    final persian = GlowhausTypography.build(color: light.text, persian: true);
    expect(persian.body.fontFamily, 'packages/glowhaus_ui/Vazirmatn');
    expect(persian.body.letterSpacing, 0);
    expect(latin.body.numeric.fontFeatures, const [
      FontFeature.tabularFigures(),
    ]);
  });

  test('motion tokens collapse when reduced', () {
    const normal = GlowhausMotion();
    expect(
      [normal.tap, normal.toggle, normal.page].map((d) => d.inMilliseconds),
      [150, 250, 400],
    );
    const reduced = GlowhausMotion(reduced: true);
    expect([
      reduced.tap,
      reduced.toggle,
      reduced.page,
    ], everyElement(Duration.zero));
  });

  test('window size classes', () {
    expect(GlowWindowSize.fromWidth(390), GlowWindowSize.compact);
    expect(GlowWindowSize.fromWidth(600), GlowWindowSize.medium);
    expect(GlowWindowSize.fromWidth(1000), GlowWindowSize.expanded);
    expect(GlowWindowSize.values.map((s) => s.maxPanes), [1, 2, 3]);
  });

  testWidgets('theme exposes tokens through context', (tester) async {
    late GlowhausColors colors;
    late GlowhausMotion motion;
    await tester.pumpWidget(
      host(
        brightness: Brightness.dark,
        Builder(
          builder: (context) {
            colors = context.colors;
            motion = context.motion;
            return Text('x', style: context.type.body);
          },
        ),
      ),
    );
    expect(colors.isDark, isTrue);
    expect(motion.reduced, isFalse);
    expect(
      Theme.of(tester.element(find.text('x'))).scaffoldBackgroundColor,
      colors.bg,
    );
  });

  testWidgets('platform reduce-motion setting is honoured', (tester) async {
    late GlowhausMotion motion;
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              motion = context.motion;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(motion.reduced, isTrue);
  });
}
