import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus/features/settings/data/language_preparer.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:injectable/injectable.dart';

/// App-wide preferences: language, theme, accent, motion, simulation knobs.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  new(this._store, this._simulation, this._languages, this._platform)
    : super(
        _store.load() ?? SettingsState(language: _languages.systemLanguage),
      ) {
    _applySimulation(state);
  }

  final SettingsStore _store;
  final SimulationControl _simulation;
  final LanguagePreparer _languages;
  final AppPlatform _platform;

  bool get simulationAvailable => _simulation.available;

  /// The web demo always opens with the welcome screen. Native apps show it
  /// on first launch only, unless it is switched back on in settings.
  bool get shouldShowWelcome => _platform.isWeb || state.showWelcome;

  /// Whether "show welcome screen" is a meaningful setting here.
  bool get welcomeToggleAvailable => !_platform.isWeb;

  /// Called when the user leaves the welcome screen.
  void welcomeSeen() => setShowWelcome(enabled: false);

  void setShowWelcome({required bool enabled}) =>
      _update(state.copyWith(showWelcome: enabled));

  /// Call once before the first frame so the initial language can render.
  Future<void> init() => _languages.prepare(state.language);

  Future<void> setLanguage(AppLanguage language) async {
    if (language == state.language) return;
    await _languages.prepare(language);
    if (isClosed) return;
    _update(state.copyWith(language: language));
  }

  void setThemeMode(ThemeMode mode) => _update(state.copyWith(themeMode: mode));

  void setAccent(AccentChoice accent) =>
      _update(state.copyWith(accent: accent));

  void setReduceMotion({required bool enabled}) =>
      _update(state.copyWith(reduceMotion: enabled));

  void setLatency(int milliseconds) => _update(
    state.copyWith(
      latencyMs: milliseconds.clamp(0, SettingsState.maxLatencyMs),
    ),
  );

  void setFailureRate(double rate) => _update(
    state.copyWith(
      failureRate: rate.clamp(0, SettingsState.maxFailureRate).toDouble(),
    ),
  );

  void _update(SettingsState next) {
    if (next == state) return;
    emit(next);
    _applySimulation(next);
    unawaited(_store.save(next));
  }

  void _applySimulation(SettingsState settings) => _simulation.apply(
    latency: Duration(milliseconds: settings.latencyMs),
    failureRate: settings.failureRate,
  );
}
