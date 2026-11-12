import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/features/settings/data/settings_store.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PrefsSettingsStore', () {
    Future<PrefsSettingsStore> store([
      Map<String, Object> values = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(values);
      return PrefsSettingsStore(await SharedPreferences.getInstance());
    }

    test('nothing saved yet', () async {
      expect((await store()).load(), isNull);
    });

    test('round trips every field', () async {
      const settings = SettingsState(
        language: AppLanguage.fa,
        themeMode: ThemeMode.dark,
        accent: AccentChoice.violet,
        reduceMotion: true,
        latencyMs: 900,
        failureRate: 0.25,
      );
      final s = await store();
      await s.save(settings);
      expect(s.load(), settings);
    });

    test('corrupt data falls back to defaults', () async {
      expect(
        (await store({PrefsSettingsStore.key: '{not json'})).load(),
        isNull,
      );
      expect(
        (await store({PrefsSettingsStore.key: '{"language":"klingon"}'}))
            .load(),
        isNull,
      );
    });

    test('fields added later default sensibly', () async {
      final s = await store({PrefsSettingsStore.key: '{"language":"tr"}'});
      expect(s.load(), const SettingsState(language: AppLanguage.tr));
    });
  });

  test('AppLanguage.fromLocale picks the closest supported language', () {
    expect(AppLanguage.fromLocale(const Locale('fa', 'IR')), AppLanguage.fa);
    expect(AppLanguage.fromLocale(const Locale('tr')), AppLanguage.tr);
    expect(AppLanguage.fromLocale(const Locale('de')), AppLanguage.en);
  });

  test('simulation control splits failures into rejects and timeouts', () {
    final transport = SimulatedTransport(
      homeId: DemoHome.homeId,
      devices: DemoHome.devices(),
    );
    TransportSimulationControl(transport)
        .apply(latency: const Duration(milliseconds: 700), failureRate: 0.4);
    expect(transport.config.latency, const Duration(milliseconds: 700));
    expect(transport.config.failureRate, 0.2);
    expect(transport.config.timeoutRate, 0.2);
  });
}
