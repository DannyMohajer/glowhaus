import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glowhaus_ui/src/tokens/colors.dart';
import 'package:glowhaus_ui/src/tokens/motion.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

/// Builds [ThemeData] carrying the Glowhaus tokens as theme extensions.
abstract final class GlowhausTheme {
  /// [accent] null means the default orange for that brightness.
  static ThemeData build({
    required Brightness brightness,
    Color? accent,
    bool persian = false,
    bool reduceMotion = false,
  }) {
    final colors = brightness == Brightness.dark
        ? (accent == null
              ? GlowhausColors.dark()
              : GlowhausColors.dark(accent: accent))
        : (accent == null
              ? GlowhausColors.light()
              : GlowhausColors.light(accent: accent));
    final type = GlowhausTypography.build(color: colors.text, persian: persian);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bg,
      canvasColor: colors.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        secondary: colors.inverse,
        onSecondary: colors.onInverse,
        error: colors.error,
        onError: colors.onAccent,
        surface: colors.surface,
        onSurface: colors.text,
        outline: colors.border,
      ),
      textTheme: TextTheme(
        displaySmall: type.display,
        headlineSmall: type.title,
        titleMedium: type.heading,
        bodyLarge: type.body,
        bodyMedium: type.body,
        labelLarge: type.body,
        bodySmall: type.caption,
        labelSmall: type.caption,
      ),
      pageTransitionsTheme: reduceMotion
          ? PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: const _NoTransitionsBuilder(),
              },
            )
          : null,
      extensions: [
        colors,
        type,
        GlowhausMotion(reduced: reduceMotion),
      ],
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const new();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

/// Loads fonts that are not needed at startup.
abstract final class GlowFontLoader {
  static Future<void>? _persian;

  /// Loads Vazirmatn once. Safe to call repeatedly.
  static Future<void> ensurePersian({AssetBundle? bundle}) =>
      _persian ??= (FontLoader(
        'packages/${GlowFonts.package}/${GlowFonts.vazirmatn}',
      )..addFont((bundle ?? rootBundle).load(GlowFonts.vazirmatnAsset))).load();
}

/// Token access: `context.colors`, `context.type`, `context.motion`.
extension GlowhausContext on BuildContext {
  GlowhausColors get colors => Theme.of(this).extension<GlowhausColors>()!;

  GlowhausTypography get type =>
      Theme.of(this).extension<GlowhausTypography>()!;

  /// Motion tokens, also honouring the platform's reduce-motion setting.
  GlowhausMotion get motion {
    final motion =
        Theme.of(this).extension<GlowhausMotion>() ?? const GlowhausMotion();
    return MediaQuery.disableAnimationsOf(this) && !motion.reduced
        ? const GlowhausMotion(reduced: true)
        : motion;
  }
}
