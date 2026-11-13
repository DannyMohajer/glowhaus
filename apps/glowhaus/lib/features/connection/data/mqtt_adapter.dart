import 'dart:math';

import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

// Loaded on demand (see DeferredBrokerTransports): the only app library that
// reaches the mqtt_client adapter, so demo-mode visitors never download it.

/// A transport to the broker in [settings], over a real MQTT client.
MqttTransport createBrokerTransport(
  BrokerSettings settings, {
  required String password,
  required bool web,
  required Random random,
}) => MqttTransport(
  homeId: settings.homeId,
  connection: MqttClientConnection(settings.endpoint(web: web)),
  // Unique per app session: two sessions with one id would keep taking the
  // connection from each other.
  clientId: 'app-${random.nextInt(1 << 32).toRadixString(36)}',
  login: MqttLogin(username: settings.username.trim(), password: password),
);
