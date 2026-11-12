import 'package:flutter/material.dart';

/// Font families bundled with the design system.
abstract final class GlowFonts {
  static const String package = 'glowhaus_ui';

  /// Latin and Turkish.
  static const String manrope = 'Manrope';

  /// Persian. Loaded on demand, see `GlowFontLoader`.
  static const String vazirmatn = 'Vazirmatn';

  static const String vazirmatnAsset =
      'packages/$package/assets/fonts/Vazirmatn-Variable.ttf';
}

/// The type scale: display 36, title 24, heading 18, body 15, caption 12.
@immutable
class GlowhausTypography extends ThemeExtension<GlowhausTypography> {
  const new({
    required this.display,
    required this.title,
    required this.heading,
    required this.body,
    required this.caption,
  });

  /// Builds the scale in [color]. Persian uses Vazirmatn first.
  factory build({required Color color, bool persian = false}) {
    TextStyle style(double size, int weight, double height, double spacing) =>
        TextStyle(
          package: GlowFonts.package,
          fontFamily: persian ? GlowFonts.vazirmatn : GlowFonts.manrope,
          fontFamilyFallback: [
            if (persian) GlowFonts.manrope else GlowFonts.vazirmatn,
          ],
          fontSize: size,
          height: persian ? height + 0.15 : height,
          letterSpacing: persian ? 0 : spacing,
          fontWeight: FontWeight.values[weight ~/ 100 - 1],
          fontVariations: [FontVariation.weight(weight.toDouble())],
          color: color,
          leadingDistribution: TextLeadingDistribution.even,
        );
    return GlowhausTypography(
      display: style(36, 700, 1.12, -1),
      title: style(24, 700, 1.2, -0.5),
      heading: style(18, 600, 1.3, -0.2),
      body: style(15, 500, 1.4, 0),
      caption: style(12, 500, 1.35, 0.1),
    );
  }

  final TextStyle display;
  final TextStyle title;
  final TextStyle heading;
  final TextStyle body;
  final TextStyle caption;

  @override
  GlowhausTypography copyWith({
    TextStyle? display,
    TextStyle? title,
    TextStyle? heading,
    TextStyle? body,
    TextStyle? caption,
  }) => GlowhausTypography(
    display: display ?? this.display,
    title: title ?? this.title,
    heading: heading ?? this.heading,
    body: body ?? this.body,
    caption: caption ?? this.caption,
  );

  @override
  GlowhausTypography lerp(GlowhausTypography? other, double t) {
    if (other == null) return this;
    return GlowhausTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      heading: TextStyle.lerp(heading, other.heading, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

extension GlowTextStyle on TextStyle {
  /// Tabular figures, for temperatures, watts and anything that ticks.
  TextStyle get numeric =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  TextStyle weight(int weight) => copyWith(
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    fontVariations: [FontVariation.weight(weight.toDouble())],
  );
}
