import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeSettingsStore store;
  late FakeSimulationControl simulation;
  late FakeLanguagePreparer languages;

  SettingsCubit build() =>
      buildSettings(store: store, simulation: simulation, languages: languages);

  setUp(() {
    store = FakeSettingsStore();
    simulation = FakeSimulationControl();
    languages = FakeLanguagePreparer();
  });

  group('initial state', () {
    test('defaults, with the device language when it is supported', () {
      languages = FakeLanguagePreparer(systemLanguage: AppLanguage.tr);
      final cubit = build();
      expect(cubit.state, const SettingsState(language: AppLanguage.tr));
      expect(cubit.state.themeMode, ThemeMode.system);
      expect(cubit.state.accent, AccentChoice.orange);
      expect(cubit.state.latencyMs, 250);
      expect(cubit.state.failureRate, 0);
    });

    test('saved settings win over the device language', () {
      languages = FakeLanguagePreparer(systemLanguage: AppLanguage.tr);
      store.saved = const SettingsState(
        language: AppLanguage.fa,
        themeMode: ThemeMode.dark,
      );
      expect(build().state, store.saved);
    });

    test('applies the simulation settings right away', () {
      store.saved = const SettingsState(latencyMs: 800, failureRate: 0.2);
      build();
      expect(simulation.applied, [
        (latency: const Duration(milliseconds: 800), failureRate: 0.2),
      ]);
    });

    test('init prepares the initial language', () async {
      store.saved = const SettingsState(language: AppLanguage.fa);
      await build().init();
      expect(languages.prepared, [AppLanguage.fa]);
    });
  });

  blocTest<SettingsCubit, SettingsState>(
    'theme, accent and motion emit and persist',
    build: build,
    act: (cubit) => cubit
      ..setThemeMode(ThemeMode.dark)
      ..setAccent(AccentChoice.blue)
      ..setReduceMotion(enabled: true),
    expect: () => const [
      SettingsState(themeMode: ThemeMode.dark),
      SettingsState(themeMode: ThemeMode.dark, accent: AccentChoice.blue),
      SettingsState(
        themeMode: ThemeMode.dark,
        accent: AccentChoice.blue,
        reduceMotion: true,
      ),
    ],
    verify: (cubit) {
      expect(store.saved, cubit.state);
      expect(store.saves, 3);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'setting the same value again does nothing',
    build: build,
    act: (cubit) => cubit
      ..setThemeMode(ThemeMode.system)
      ..setAccent(AccentChoice.orange),
    expect: () => const <SettingsState>[],
    verify: (_) => expect(store.saves, 0),
  );

  blocTest<SettingsCubit, SettingsState>(
    'language is prepared before the UI switches to it',
    build: build,
    act: (cubit) async {
      final switching = cubit.setLanguage(AppLanguage.fa);
      expect(cubit.state.language, AppLanguage.en, reason: 'not yet');
      await switching;
    },
    expect: () => const [SettingsState(language: AppLanguage.fa)],
    verify: (_) => expect(languages.prepared, [AppLanguage.fa]),
  );

  blocTest<SettingsCubit, SettingsState>(
    'simulation knobs are clamped and pushed to the simulation',
    build: build,
    act: (cubit) => cubit
      ..setLatency(1200)
      ..setLatency(99999)
      ..setFailureRate(0.3)
      ..setFailureRate(5),
    expect: () => const [
      SettingsState(latencyMs: 1200),
      SettingsState(latencyMs: 2000),
      SettingsState(latencyMs: 2000, failureRate: 0.3),
      SettingsState(latencyMs: 2000, failureRate: 0.5),
    ],
    verify: (_) => expect(simulation.applied.last, (
      latency: const Duration(seconds: 2),
      failureRate: 0.5,
    )),
  );

  test('reports whether a simulation exists', () {
    expect(build().simulationAvailable, isTrue);
    simulation = FakeSimulationControl(available: false);
    expect(build().simulationAvailable, isFalse);
  });
}
