import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// MQTT quality of service. The Glowhaus protocol uses 0 and 1 only;
/// 2 is accepted and treated as 1 by the in-memory broker.
enum MqttQos {
  atMostOnce(0),
  atLeastOnce(1),
  exactlyOnce(2);

  new(this.level);

  final int level;

  static MqttQos fromLevel(int level) =>
      values.firstWhere((qos) => qos.level == level);

  /// The lower of two levels, as a broker applies when it forwards a
  /// message to a subscription.
  MqttQos min(MqttQos other) => level <= other.level ? this : other;

  MqttQos max(MqttQos other) => level >= other.level ? this : other;
}

/// A message as published or as delivered.
///
/// [retained] is true only on a message delivered because of a new
/// subscription (the broker's stored copy). A message forwarded live to an
/// existing subscription always has it false, whatever the publisher set.
///
/// [duplicate] is the DUP flag: a QoS 1 redelivery. The first delivery may
/// already have arrived, so receivers must not act on it twice.
@immutable
class MqttMessage {
  const new({
    required this.topic,
    required this.payload,
    this.qos = MqttQos.atLeastOnce,
    this.retained = false,
    this.duplicate = false,
  });

  /// Convenience for UTF-8 text payloads (all Glowhaus payloads are).
  factory text(
    String topic,
    String text, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retained = false,
  }) => MqttMessage(
    topic: topic,
    payload: Uint8List.fromList(utf8.encode(text)),
    qos: qos,
    retained: retained,
  );

  final String topic;
  final Uint8List payload;
  final MqttQos qos;
  final bool retained;
  final bool duplicate;

  /// The payload decoded as UTF-8. Throws on invalid bytes.
  String get text => utf8.decode(payload);

  MqttMessage asDuplicate() => MqttMessage(
    topic: topic,
    payload: payload,
    qos: qos,
    retained: retained,
    duplicate: true,
  );

  @override
  String toString() =>
      'MqttMessage($topic, ${payload.length} bytes, qos ${qos.level}'
      '${retained ? ', retained' : ''}${duplicate ? ', dup' : ''})';
}

/// The message a broker publishes on a client's behalf when that client
/// disappears without a clean disconnect.
@immutable
class MqttWill {
  const new({
    required this.topic,
    required this.payload,
    this.qos = MqttQos.atLeastOnce,
    this.retain = false,
  });

  factory text(
    String topic,
    String text, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) => MqttWill(
    topic: topic,
    payload: Uint8List.fromList(utf8.encode(text)),
    qos: qos,
    retain: retain,
  );

  final String topic;
  final Uint8List payload;
  final MqttQos qos;
  final bool retain;
}

/// Username and password sent in CONNECT.
@immutable
class MqttLogin {
  const new({required this.username, this.password});

  final String username;
  final String? password;
}

enum MqttConnectionState { disconnected, connecting, connected }

/// Thrown by [MqttConnection.publish], [MqttConnection.subscribe] and
/// [MqttConnection.unsubscribe] while the connection is not connected, and
/// by a [MqttConnection.connect] that the broker refused.
class MqttConnectionException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'MqttConnectionException: $message';
}

/// One MQTT 3.1.1 client session, as much of it as Glowhaus needs.
///
/// Where the connection goes (host, port, TLS, WebSocket) is fixed when the
/// object is created; [connect] carries only session parameters. A
/// connection can be reconnected after it drops by calling [connect] again;
/// subscriptions are not restored (sessions are always clean), the caller
/// re-subscribes.
///
/// [messages] and [state] are broadcast streams: listen before you
/// [subscribe], events that nobody listens to are lost.
abstract interface class MqttConnection {
  MqttConnectionState get currentState;

  /// Connection state changes, including an unexpected drop to
  /// [MqttConnectionState.disconnected].
  Stream<MqttConnectionState> get state;

  /// Messages delivered to this connection's subscriptions.
  Stream<MqttMessage> get messages;

  /// Opens the session. Only clean sessions are supported: the protocol
  /// forbids queued commands reaching a device late (see docs/protocol.md,
  /// section 3), so there is nothing to resume.
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  });

  /// Subscribes to a topic filter (`+` and `#` allowed). Retained messages
  /// that match arrive on [messages] with `retained: true`.
  Future<void> subscribe(String filter, {MqttQos qos = MqttQos.atLeastOnce});

  Future<void> unsubscribe(String filter);

  /// Publishes to a concrete topic (no wildcards). An empty [payload] with
  /// [retain] clears the retained message on that topic.
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  });

  /// Closes the session cleanly: the will is discarded, not published.
  Future<void> disconnect();

  /// Releases resources; the object cannot be reused.
  Future<void> dispose();
}

/// Text helpers shared by every implementation.
extension MqttConnectionText on MqttConnection {
  Future<void> publishText(
    String topic,
    String text, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) => publish(
    topic,
    Uint8List.fromList(utf8.encode(text)),
    qos: qos,
    retain: retain,
  );
}
