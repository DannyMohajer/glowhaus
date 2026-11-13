import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

part 'connection_settings.freezed.dart';
part 'connection_settings.g.dart';

/// Where the app's devices come from.
enum ConnectionMode {
  /// The demo home, simulated in this app over an in-memory broker.
  demo,

  /// A real MQTT broker, such as the one in `infra/`.
  broker,
}

/// A field of [BrokerSettings] that can be wrong.
enum BrokerField { host, port, path, homeId, username }

/// How to reach a broker. Everything here is saved on the device except the
/// password, which the app keeps in memory only.
@freezed
abstract class BrokerSettings with _$BrokerSettings {
  const factory({
    @Default('localhost') String host,

    /// Null means the default for the transport: 8884 for WSS, 8883 for
    /// TLS, 1883 for plain MQTT.
    int? port,
    @Default(true) bool tls,

    /// MQTT over WebSocket. Always on in a browser, which can only open
    /// WebSockets.
    @Default(false) bool webSocket,
    @Default('/mqtt') String path,
    @Default(DemoHome.homeId) String homeId,
    @Default('${DemoHome.homeId}.app') String username,

    /// An extra CA to trust, in PEM, for a development broker whose CA the
    /// platform does not know (Android ignores user-installed CAs). Native
    /// only.
    String? trustedCertificatePem,
  }) = _BrokerSettings;

  factory fromJson(Map<String, dynamic> json) => _$BrokerSettingsFromJson(json);

  const new _();

  /// What the connection actually uses on this platform: a browser always
  /// speaks secure WebSocket.
  MqttEndpoint endpoint({required bool web}) {
    final ws = web || webSocket;
    final secure = web || tls;
    final pem = web ? null : trustedCertificatePem;
    return MqttEndpoint(
      host: host.trim(),
      port: port ?? defaultPort(web: web),
      tls: secure,
      webSocket: ws,
      path: path,
      trustedCertificatePem: pem == null || pem.trim().isEmpty ? null : pem,
    );
  }

  int defaultPort({required bool web}) {
    if (web || webSocket) return 8884;
    return tls ? 8883 : 1883;
  }

  /// Which fields stop a connect, empty when none.
  Set<BrokerField> problems({required bool web}) => {
    if (!_hostPattern.hasMatch(host.trim())) BrokerField.host,
    if (port case final p? when p < 1 || p > 65535) BrokerField.port,
    if ((web || webSocket) && !path.startsWith('/')) BrokerField.path,
    if (!Ids.isValidHomeId(homeId)) BrokerField.homeId,
    if (username.trim().isEmpty) BrokerField.username,
  };

  /// A host name, an IPv4 address or a bracket-less IPv6 address; no scheme,
  /// no port, no path.
  static final RegExp _hostPattern = RegExp(r'^[A-Za-z0-9.\-:]+$');
}

@freezed
abstract class ConnectionSettings with _$ConnectionSettings {
  const factory({
    @Default(ConnectionMode.demo) ConnectionMode mode,
    @Default(BrokerSettings()) BrokerSettings broker,
  }) = _ConnectionSettings;

  factory fromJson(Map<String, dynamic> json) =>
      _$ConnectionSettingsFromJson(json);
}
