import 'dart:async';
import 'dart:math';

import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/settings/data/app_platform.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:injectable/injectable.dart';

/// Makes the transport for a broker. An interface so tests need no network.
abstract interface class BrokerTransports {
  MqttTransport create(BrokerSettings settings, {required String password});
}

@LazySingleton(as: BrokerTransports)
class MqttBrokerTransports implements BrokerTransports {
  new(this._platform);

  final AppPlatform _platform;
  final Random _random = Random();

  @override
  MqttTransport create(
    BrokerSettings settings, {
    required String password,
  }) => MqttTransport(
    homeId: settings.homeId,
    connection: MqttClientConnection(settings.endpoint(web: _platform.isWeb)),
    // Unique per app session: two sessions with one id would keep
    // taking the connection from each other.
    clientId: 'app-${_random.nextInt(1 << 32).toRadixString(36)}',
    login: MqttLogin(username: settings.username.trim(), password: password),
  );
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
