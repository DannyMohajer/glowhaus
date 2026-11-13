import 'dart:convert';

import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the connection choice and the last-known devices of a broker
/// survive between launches. Never the password.
abstract interface class ConnectionStore {
  ConnectionSettings load();

  Future<void> save(ConnectionSettings settings);

  /// The devices last seen on the broker identified by [key], so the app has
  /// something to show before it is connected. Empty when there are none.
  List<Device> lastKnown(String key);

  Future<void> saveLastKnown(String key, Iterable<Device> devices);
}

@LazySingleton(as: ConnectionStore)
class PrefsConnectionStore implements ConnectionStore {
  new(this._prefs);

  static const String settingsKey = 'connection.v1';
  static const String devicesKey = 'connection.lastKnown.v1';

  final SharedPreferences _prefs;

  @override
  ConnectionSettings load() {
    final raw = _prefs.getString(settingsKey);
    if (raw == null) return const ConnectionSettings();
    try {
      return ConnectionSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return const ConnectionSettings();
    }
  }

  @override
  Future<void> save(ConnectionSettings settings) =>
      _write(settingsKey, jsonEncode(settings.toJson()));

  @override
  List<Device> lastKnown(String key) {
    final raw = _prefs.getString(devicesKey);
    if (raw == null) return const [];
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['key'] != key) return const [];
      return [
        for (final entry in json['devices'] as List<dynamic>)
          LastKnownDevice.decode(entry as Map<String, dynamic>),
      ];
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> saveLastKnown(String key, Iterable<Device> devices) => _write(
    devicesKey,
    jsonEncode({
      'key': key,
      'devices': [for (final device in devices) LastKnownDevice.encode(device)],
    }),
  );

  Future<void> _write(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } on Object {
      // Storage can be unavailable (private mode, embedded frames).
    }
  }
}

/// A device as the protocol describes it: its descriptor plus its state in
/// wire form, so the cache needs no format of its own.
abstract final class LastKnownDevice {
  static Map<String, dynamic> encode(Device device) => {
    'homeId': device.homeId,
    'descriptor': DeviceDescriptor(
      id: device.id,
      type: device.type,
      name: device.name,
      capabilities: device.capabilities,
      manufacturer: device.manufacturer,
      model: device.model,
      firmware: device.firmware,
      roomHint: device.roomId,
      nameKey: device.nameKey,
    ).toJson(),
    'state': StatePayload.encode(device.state, ts: 0).toJson()['state'],
  };

  /// Availability is not cached: until the broker says otherwise, a device
  /// last seen some time ago is `unknown`.
  static Device decode(Map<String, dynamic> json) {
    final descriptor = DeviceDescriptor.fromJson(
      json['descriptor'] as Map<String, dynamic>,
    );
    final state = StatePayload.fromJson({'ts': 0, 'state': json['state']})
        .decode(descriptor.capabilities);
    return Device.fromDescriptor(
      descriptor,
      homeId: json['homeId'] as String,
    ).copyWith(state: state);
  }
}
