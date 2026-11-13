import 'dart:async';
import 'dart:math';

import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/connection/data/mqtt_adapter.dart'
    deferred as adapter;
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:injectable/injectable.dart';

/// Makes the transport for a broker. An interface so tests need no network.
abstract interface class BrokerTransports {
  /// Async because the real MQTT adapter is a deferred library: it is
  /// downloaded the first time someone connects to a broker.
  Future<MqttTransport> create(
    BrokerSettings settings, {
    required String password,
  });
}

@LazySingleton(as: BrokerTransports)
class DeferredBrokerTransports implements BrokerTransports {
  new(this._platform);

  final AppPlatform _platform;
  final Random _random = Random();

  @override
  Future<MqttTransport> create(
    BrokerSettings settings, {
    required String password,
  }) async {
    await adapter.loadLibrary();
    return adapter.createBrokerTransport(
      settings,
      password: password,
      web: _platform.isWeb,
      random: _random,
    );
  }
}

/// The transport while the app has no connection to make: broker mode after
/// a launch, before the password has been entered again. It knows no devices
/// and reaches none.
class IdleTransport implements Transport {
  final _status = StreamController<TransportStatus>.broadcast();
  final _events = StreamController<DeviceEvent>.broadcast();

  @override
  TransportStatus get currentStatus => TransportStatus.disconnected;

  @override
  Stream<TransportStatus> get status => _status.stream;

  @override
  Stream<DeviceEvent> get events => _events.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<CommandResult> send(
    DeviceCommand command, {
    Duration timeout = Protocol.commandTimeout,
  }) async => CommandResult.unreachable(commandId: command.id);

  @override
  Future<void> dispose() async {
    await _status.close();
    await _events.close();
  }
}
