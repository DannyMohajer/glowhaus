import 'dart:convert';

import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where settings survive between launches.
abstract interface class SettingsStore {
  /// The saved settings, or null if there are none or they are unreadable.
  SettingsState? load();

  Future<void> save(SettingsState settings);
}

@LazySingleton(as: SettingsStore)
class PrefsSettingsStore implements SettingsStore {
  new(this._prefs);

  static const String key = 'settings.v1';

  final SharedPreferences _prefs;

  @override
  SettingsState? load() {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return SettingsState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Corrupt or from an incompatible version: fall back to defaults.
      return null;
    }
  }

  @override
  Future<void> save(SettingsState settings) async {
    try {
      await _prefs.setString(key, jsonEncode(settings.toJson()));
    } on Object {
      // Storage can be unavailable (private mode, embedded frames). Settings
      // then simply last for the session.
    }
  }
}
