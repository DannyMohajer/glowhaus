// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) =>
    _SettingsState(
      language:
          $enumDecodeNullable(_$AppLanguageEnumMap, json['language']) ??
          AppLanguage.en,
      themeMode:
          $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      accent:
          $enumDecodeNullable(_$AccentChoiceEnumMap, json['accent']) ??
          AccentChoice.orange,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      latencyMs:
          (json['latencyMs'] as num?)?.toInt() ??
          SettingsState.defaultLatencyMs,
      failureRate: (json['failureRate'] as num?)?.toDouble() ?? 0,
      showWelcome: json['showWelcome'] as bool? ?? true,
    );

Map<String, dynamic> _$SettingsStateToJson(_SettingsState instance) =>
    <String, dynamic>{
      'language': _$AppLanguageEnumMap[instance.language]!,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'accent': _$AccentChoiceEnumMap[instance.accent]!,
      'reduceMotion': instance.reduceMotion,
      'latencyMs': instance.latencyMs,
      'failureRate': instance.failureRate,
      'showWelcome': instance.showWelcome,
    };

const _$AppLanguageEnumMap = {
  AppLanguage.en: 'en',
  AppLanguage.fa: 'fa',
  AppLanguage.tr: 'tr',
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$AccentChoiceEnumMap = {
  AccentChoice.orange: 'orange',
  AccentChoice.blue: 'blue',
  AccentChoice.green: 'green',
  AccentChoice.violet: 'violet',
  AccentChoice.rose: 'rose',
};
