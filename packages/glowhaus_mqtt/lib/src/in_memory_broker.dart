import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:glowhaus_mqtt/src/connection.dart';
import 'package:glowhaus_mqtt/src/topic_filter.dart';
import 'package:meta/meta.dart';

/// A broker in a Dart object, behaving like a real MQTT 3.1.1 broker in
/// every way the Glowhaus protocol relies on:
///
/// - retained messages are kept per topic and delivered to new matching
///   subscriptions with `retained: true`; an empty retained payload clears
///   one; live forwards always carry `retained: false`;
/// - `+` and `#` wildcards, with the `$` rule;
/// - the will is published when a client is [drop]ped, never on a clean
///   [MqttConnection.disconnect];
/// - a second connection with the same client id takes over: the first one
///   is dropped (and its will published);
/// - delivered QoS is the lower of the publish QoS and the subscription's
///   QoS (the highest of several matching subscriptions);
/// - only QoS 0 deliveries can be lost ([qos0LossRate]); QoS 1 and 2 always
///   arrive. There is no redelivery, so a client never sees duplicates.
///
/// Sessions are always clean: nothing is stored for a disconnected client.
/// Everything is in process; the same object can serve the app and a device
/// engine in one isolate (the offline demo) or in tests.
class InMemoryBroker {
  new({this.qos0LossRate = 0, this.latency = Duration.zero, Random? random})
    : assert(qos0LossRate >= 0 && qos0LossRate <= 1, 'a probability'),
      _random = random ?? Random();

  /// Probability that one QoS 0 delivery is dropped. Lets tests and the
  /// demo show that QoS 0 discovery messages are best effort.
  final double qos0LossRate;

  /// Delay between a publish and its deliveries.
  final Duration latency;

  final Random _random;
  final Map<String, _Session> _sessions = {};
  final Map<String, MqttMessage> _retained = {};
  var _closed = false;

  /// A new, not yet connected client of this broker.
  MqttConnection client() {
    _checkOpen();
    return _InMemoryConnection(this);
  }

  /// Client ids currently connected.
  Iterable<String> get connectedClientIds => _sessions.keys;

  /// The retained message on [topic], if any.
  MqttMessage? retained(String topic) => _retained[topic];

  /// Every retained message, by topic.
  Map<String, MqttMessage> get retainedMessages => Map.unmodifiable(_retained);

  /// Cuts [clientId] off as if its network had gone: its will is published
  /// and it sees [MqttConnectionState.disconnected].
  void drop(String clientId) {
    final session = _sessions[clientId];
    if (session == null) return;
    _removeSession(session, publishWill: true);
  }

  /// Drops every client and refuses new ones.
  Future<void> close() async {
    _closed = true;
    for (final session in _sessions.values.toList()) {
      _removeSession(session, publishWill: false);
    }
  }

  void _checkOpen() {
    if (_closed) throw const MqttConnectionException('broker is closed');
  }

  void _connect(_Session session) {
    _checkOpen();
    final existing = _sessions[session.clientId];
    if (existing != null) {
      // MQTT 3.1.1 section 3.1.4: the existing client is disconnected.
      _removeSession(existing, publishWill: true);
    }
    _sessions[session.clientId] = session;
  }

  void _removeSession(_Session session, {required bool publishWill}) {
    if (_sessions[session.clientId] != session) return;
    _sessions.remove(session.clientId);
    final will = session.will;
    if (publishWill && will != null) {
      _publish(will.topic, will.payload, qos: will.qos, retain: will.retain);
    }
    session.connection._onDropped();
  }

  void _publish(
    String topic,
    Uint8List payload, {
    required MqttQos qos,
    required bool retain,
  }) {
    if (retain) {
      if (payload.isEmpty) {
        _retained.remove(topic);
      } else {
        _retained[topic] = MqttMessage(
          topic: topic,
          payload: payload,
          qos: qos,
          retained: true,
        );
      }
    }
    for (final session in _sessions.values.toList()) {
      final granted = session.grantedQos(topic);
      if (granted == null) continue;
      _deliver(
        session,
        MqttMessage(topic: topic, payload: payload, qos: qos.min(granted)),
      );
    }
  }

  void _deliver(_Session session, MqttMessage message) {
    if (message.qos == MqttQos.atMostOnce &&
        qos0LossRate > 0 &&
        _random.nextDouble() < qos0LossRate) {
      return;
    }
    if (latency == Duration.zero) {
      session.connection._onMessage(message);
    } else {
      Timer(latency, () {
        if (_sessions[session.clientId] == session) {
          session.connection._onMessage(message);
        }
      });
    }
  }

  void _subscribe(_Session session, String filter, MqttQos qos) {
    session.subscriptions[filter] = qos;
    for (final stored in _retained.values.toList()) {
      if (!MqttTopics.matches(filter, stored.topic)) continue;
      _deliver(
        session,
        MqttMessage(
          topic: stored.topic,
          payload: stored.payload,
          qos: stored.qos.min(qos),
          retained: true,
        ),
      );
    }
  }
}

class _Session {
  new({required this.clientId, required this.will, required this.connection});

  final String clientId;
  final MqttWill? will;
  final _InMemoryConnection connection;
  final Map<String, MqttQos> subscriptions = {};

  /// The highest QoS among subscriptions matching [topic], or null if none.
  MqttQos? grantedQos(String topic) {
    MqttQos? granted;
    for (final MapEntry(key: filter, value: qos) in subscriptions.entries) {
      if (!MqttTopics.matches(filter, topic)) continue;
      granted = granted == null ? qos : granted.max(qos);
    }
    return granted;
  }
}

class _InMemoryConnection implements MqttConnection {
  new(this._broker);

  final InMemoryBroker _broker;
  final _state = StreamController<MqttConnectionState>.broadcast();
  final _messages = StreamController<MqttMessage>.broadcast();
  _Session? _session;
  MqttConnectionState _current = MqttConnectionState.disconnected;
  var _disposed = false;

  @override
  MqttConnectionState get currentState => _current;

  @override
  Stream<MqttConnectionState> get state => _state.stream;

  @override
  Stream<MqttMessage> get messages => _messages.stream;

  void _setState(MqttConnectionState next) {
    if (_current == next) return;
    _current = next;
    if (!_state.isClosed) _state.add(next);
  }

  @override
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  }) async {
    _checkNotDisposed();
    if (_session != null) return;
    if (clientId.isEmpty) {
      throw const MqttConnectionException('client id must not be empty');
    }
    if (will != null && !MqttTopics.isValidName(will.topic)) {
      throw MqttConnectionException('invalid will topic: ${will.topic}');
    }
    _setState(MqttConnectionState.connecting);
    final session = _Session(clientId: clientId, will: will, connection: this);
    try {
      _broker._connect(session);
    } on MqttConnectionException {
      _setState(MqttConnectionState.disconnected);
      rethrow;
    }
    _session = session;
    _setState(MqttConnectionState.connected);
  }

  @override
  Future<void> subscribe(
    String filter, {
    MqttQos qos = MqttQos.atLeastOnce,
  }) async {
    final session = _connected();
    if (!MqttTopics.isValidFilter(filter)) {
      throw MqttConnectionException('invalid topic filter: $filter');
    }
    _broker._subscribe(session, filter, qos);
  }

  @override
  Future<void> unsubscribe(String filter) async {
    _connected().subscriptions.remove(filter);
  }

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    _connected();
    if (!MqttTopics.isValidName(topic)) {
      throw MqttConnectionException('invalid topic name: $topic');
    }
    _broker._publish(topic, payload, qos: qos, retain: retain);
  }

  @override
  Future<void> disconnect() async {
    final session = _session;
    if (session == null) return;
    _session = null;
    _broker._removeSession(session, publishWill: false);
    _setState(MqttConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    _disposed = true;
    await _state.close();
    await _messages.close();
  }

  _Session _connected() {
    _checkNotDisposed();
    final session = _session;
    if (session == null) {
      throw const MqttConnectionException('not connected');
    }
    return session;
  }

  void _checkNotDisposed() {
    if (_disposed) throw const MqttConnectionException('disposed');
  }

  /// Called by the broker when it removes the session for any reason.
  void _onDropped() {
    _session = null;
    _setState(MqttConnectionState.disconnected);
  }

  void _onMessage(MqttMessage message) {
    if (!_messages.isClosed && _session != null) _messages.add(message);
  }
}

/// Test seam: lets a test observe deliveries without a real subscription.
@visibleForTesting
extension InMemoryBrokerTesting on InMemoryBroker {
  int get retainedCount => _retained.length;
}
