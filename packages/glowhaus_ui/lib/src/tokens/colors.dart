import 'package:flutter/material.dart';

/// Glowhaus colour tokens. One instance per brightness; the accent is a
/// parameter so it can be swapped at runtime.
@immutable
class GlowhausColors extends ThemeExtension<GlowhausColors> {
  const new({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.inverse,
    required this.onInverse,
    required this.heat,
    required this.cool,
    required this.lamp,
    required this.power,
    required this.success,
    required this.warning,
    required this.error,
    required this.offline,
  });

  factory light({Color accent = defaultAccentLight}) => GlowhausColors(
    brightness: Brightness.light,
    bg: const Color(0xFFF1F1EF),
    surface: const Color(0xFFFFFFFF),
    surfaceAlt: const Color(0xFFF7F7F5),
    border: const Color(0xFFE6E6E3),
    text: const Color(0xFF111111),
    textMuted: const Color(0xFF7A7A7A),
    textFaint: const Color(0xFFB5B5B2),
    accent: accent,
    onAccent: const Color(0xFFFFFFFF),
    accentSoft: accent == defaultAccentLight
        ? const Color(0xFFFFE6DC)
        : Color.alphaBlend(
            accent.withValues(alpha: 0.14),
            const Color(0xFFFFFFFF),
          ),
    inverse: const Color(0xFF111111),
    onInverse: const Color(0xFFFFFFFF),
    heat: const Color(0xFFFF5A1F),
    cool: const Color(0xFF7FB6D5),
    lamp: const Color(0xFFFFC24A),
    power: const Color(0xFF4CAF7A),
    success: const Color(0xFF2E9E5B),
    warning: const Color(0xFFE3A008),
    error: const Color(0xFFE5484D),
    offline: const Color(0xFFA0A0A0),
  );

  factory dark({Color accent = defaultAccentDark}) => GlowhausColors(
    brightness: Brightness.dark,
    bg: const Color(0xFF111111),
    surface: const Color(0xFF1C1C1C),
    surfaceAlt: const Color(0xFF252525),
    border: const Color(0xFF2E2E2E),
    text: const Color(0xFFF2F2F0),
    textMuted: const Color(0xFF9A9A98),
    textFaint: const Color(0xFF5E5E5C),
    accent: accent,
    onAccent: const Color(0xFFFFFFFF),
    accentSoft: accent == defaultAccentDark
        ? const Color(0xFF3A2016)
        : Color.alphaBlend(
            accent.withValues(alpha: 0.20),
            const Color(0xFF1C1C1C),
          ),
    inverse: const Color(0xFFF2F2F0),
    onInverse: const Color(0xFF111111),
    heat: const Color(0xFFFF6A2E),
    cool: const Color(0xFF6FA8C8),
    lamp: const Color(0xFFFFC85C),
    power: const Color(0xFF5CC28A),
    success: const Color(0xFF4CC27A),
    warning: const Color(0xFFF2B83A),
    error: const Color(0xFFF2555A),
    offline: const Color(0xFF5E5E5C),
  );

  static const Color defaultAccentLight = Color(0xFFFF5A1F);
  static const Color defaultAccentDark = Color(0xFFFF6A2E);

  final Brightness brightness;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color text;
  final Color textMuted;

  /// Second line of the two-tone greeting, disabled content.
  final Color textFaint;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;

  /// Black pills in light, near-white pills in dark.
  final Color inverse;
  final Color onInverse;
  final Color heat;
  final Color cool;
  final Color lamp;
  final Color power;
  final Color success;
  final Color warning;
  final Color error;
  final Color offline;

  bool get isDark => brightness == Brightness.dark;

  @override
  GlowhausColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
  }) => GlowhausColors(
    brightness: brightness,
    bg: bg,
    surface: surface,
    surfaceAlt: surfaceAlt,
    border: border,
    text: text,
    textMuted: textMuted,
    textFaint: textFaint,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentSoft: accentSoft ?? this.accentSoft,
    inverse: inverse,
    onInverse: onInverse,
    heat: heat,
    cool: cool,
    lamp: lamp,
    power: power,
    success: success,
    warning: warning,
    error: error,
    offline: offline,
  );

  @override
  GlowhausColors lerp(GlowhausColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return GlowhausColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      border: mix(border, other.border),
      text: mix(text, other.text),
      textMuted: mix(textMuted, other.textMuted),
      textFaint: mix(textFaint, other.textFaint),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentSoft: mix(accentSoft, other.accentSoft),
      inverse: mix(inverse, other.inverse),
      onInverse: mix(onInverse, other.onInverse),
      heat: mix(heat, other.heat),
      cool: mix(cool, other.cool),
      lamp: mix(lamp, other.lamp),
      power: mix(power, other.power),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      error: mix(error, other.error),
      offline: mix(offline, other.offline),
    );
  }
}
