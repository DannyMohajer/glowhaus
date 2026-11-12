import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/language_preparer.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:injectable/injectable.dart';

/// App-wide preferences: language, theme, accent, motion, simulation knobs.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  new(this._store, this._simulation, this._languages)
    : super(
        _store.load() ?? SettingsState(language: _languages.systemLanguage),
      ) {
    _applySimulation(state);
  }

  final SettingsStore _store;
  final SimulationControl _simulation;
  final LanguagePreparer _languages;

  bool get simulationAvailable => _simulation.available;

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
