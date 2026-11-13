import 'dart:convert';
import 'dart:io';

import 'package:glowhaus_mqtt/src/mqtt_endpoint.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// TCP, TLS or WebSocket client for the Dart VM and native Flutter apps.
MqttClient createClient(MqttEndpoint endpoint, String clientId) {
  if (endpoint.webSocket) {
    return MqttServerClient.withPort(
        endpoint.webSocketUrl,
        clientId,
        endpoint.port,
      )
      ..useWebSocket = true
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  }
  final client = MqttServerClient.withPort(
    endpoint.host,
    clientId,
    endpoint.port,
  )..secure = endpoint.tls;
  final pem = endpoint.trustedCertificatePem;
  if (endpoint.tls && pem != null) {
    client.securityContext = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(utf8.encode(pem));
  }
  return client;
}
