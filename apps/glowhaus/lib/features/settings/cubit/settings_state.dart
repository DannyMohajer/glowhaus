import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

enum AccentChoice {
  orange(null),
  blue(Color(0xFF2F6BFF)),
  green(Color(0xFF1F9D6B)),
  violet(Color(0xFF7A4DFF)),
  rose(Color(0xFFE5387B));

  new(this.color);

  /// Null means the design system's default orange for the brightness.
  final Color? color;
}

enum AppLanguage {
  en,
  fa,
  tr;

  Locale get locale => Locale(name);

  /// The supported language closest to [locale], English otherwise.
  static AppLanguage fromLocale(Locale locale) => values.firstWhere(
    (language) => language.name == locale.languageCode,
    orElse: () => en,
  );
}

@freezed
abstract class SettingsState with _$SettingsState {
  const factory({
    @Default(AppLanguage.en) AppLanguage language,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(AccentChoice.orange) AccentChoice accent,
    @Default(false) bool reduceMotion,
    @Default(SettingsState.defaultLatencyMs) int latencyMs,
    @Default(0) double failureRate,

    /// Native only: show the welcome screen at the next launch.
    @Default(true) bool showWelcome,
  }) = _SettingsState;

  factory fromJson(Map<String, dynamic> json) => _$SettingsStateFromJson(json);

  static const int defaultLatencyMs = 250;
  static const int maxLatencyMs = 2000;
  static const double maxFailureRate = 0.5;
}
