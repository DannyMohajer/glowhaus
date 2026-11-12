import 'package:meta/meta.dart';

/// Where a broker is and how to reach it.
///
/// Native apps and the device simulator use plain MQTT over TCP, with TLS on
/// the standard port 8883. The web app can only use WebSockets, so it talks
/// MQTT over WSS. Both are the same protocol; only the framing differs.
@immutable
class MqttEndpoint {
  const new({
    required this.host,
    required this.port,
    this.tls = true,
    this.webSocket = false,
    this.path = '/mqtt',
  });

  /// MQTT over TLS on 8883, the native default.
  const new tcp(String host, {int port = 8883, bool tls = true})
    : this(host: host, port: port, tls: tls);

  /// MQTT over secure WebSocket, what a browser needs.
  const new webSocketSecure(
    String host, {
    int port = 8884,
    String path = '/mqtt',
  }) : this(host: host, port: port, webSocket: true, path: path);

  final String host;
  final int port;
  final bool tls;
  final bool webSocket;

  /// WebSocket path on the broker; ignored for TCP.
  final String path;

  /// The URL form `mqtt_client` wants for WebSocket connections.
  String get webSocketUrl => '${tls ? 'wss' : 'ws'}://$host$path';

  @override
  String toString() => webSocket
      ? '$webSocketUrl:$port'
      : '${tls ? 'mqtts' : 'mqtt'}://$host:$port';

  @override
  bool operator ==(Object other) =>
      other is MqttEndpoint &&
      other.host == host &&
      other.port == port &&
      other.tls == tls &&
      other.webSocket == webSocket &&
      other.path == path;

  @override
  int get hashCode => Object.hash(host, port, tls, webSocket, path);
}
