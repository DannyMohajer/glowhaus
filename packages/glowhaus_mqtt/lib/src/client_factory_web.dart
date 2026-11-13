import 'package:glowhaus_mqtt/src/mqtt_endpoint.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

/// Browsers can only open WebSockets, so the endpoint must be one.
MqttClient createClient(MqttEndpoint endpoint, String clientId) {
  if (!endpoint.webSocket) {
    throw ArgumentError.value(
      endpoint,
      'endpoint',
      'A browser can only reach a broker over WebSocket',
    );
  }
  return MqttBrowserClient.withPort(
    endpoint.webSocketUrl,
    clientId,
    endpoint.port,
  )..websocketProtocols = MqttClientConstants.protocolsSingleDefault;
}
