import 'dart:async';
import 'dart:typed_data';

import 'package:glowhaus_mqtt/src/client_factory_stub.dart'
    if (dart.library.io) 'package:glowhaus_mqtt/src/client_factory_io.dart'
    if (dart.library.js_interop) 'package:glowhaus_mqtt/src/client_factory_web.dart'
    as clients;
import 'package:glowhaus_mqtt/src/connection.dart';
import 'package:glowhaus_mqtt/src/mqtt_endpoint.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:typed_data/typed_data.dart' as typed;

/// [MqttConnection] over a real broker, using the `mqtt_client` package:
/// TCP (with TLS) on native platforms, WebSocket in the browser.
///
/// Reconnecting is the caller's job ([connect] again after a drop), as the
/// interface promises; the client's own auto-reconnect is off so that the
/// transport sees every drop and can fail its pending commands.
class MqttClientConnection implements MqttConnection {
  new(this.endpoint, {this.connectTimeout = const Duration(seconds: 10)});

  final MqttEndpoint endpoint;
  final Duration connectTimeout;

  final _state = StreamController<MqttConnectionState>.broadcast();
  final _messages = StreamController<MqttMessage>.broadcast();
  mqtt.MqttClient? _client;
  StreamSubscription<List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>>>?
  _updates;
  MqttConnectionState _current = MqttConnectionState.disconnected;
  bool _disposed = false;

  /// Subscribes waiting for the broker's SUBACK, by filter.
  final _subscribing = <String, Completer<void>>{};

  @override
  MqttConnectionState get currentState => _current;

  @override
  Stream<MqttConnectionState> get state => _state.stream;

  @override
  Stream<MqttMessage> get messages => _messages.stream;

  @override
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  }) async {
    if (_disposed) throw const MqttConnectionException('disposed');
    if (_client != null) return;
    _setState(MqttConnectionState.connecting);

    final client = clients.createClient(endpoint, clientId)
      ..keepAlivePeriod = keepAlive.inSeconds
      ..connectTimeoutPeriod = connectTimeout.inMilliseconds
      ..autoReconnect = false
      ..setProtocolV311();
    var message = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    if (will != null) {
      message = message
          .withWillTopic(will.topic)
          .withWillMessage(String.fromCharCodes(will.payload))
          .withWillQos(_toClientQos(will.qos));
      if (will.retain) message = message.withWillRetain();
    }
    client
      ..connectionMessage = message
      ..onDisconnected = (() => _onDisconnected(client))
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail;
    _client = client;

    mqtt.MqttClientConnectionStatus? status;
    try {
      status = await client.connect(login?.username, login?.password);
    } on Object catch (error) {
      _client = null;
      _setState(MqttConnectionState.disconnected);
      throw MqttConnectionException('connect failed: $error');
    }
    if (status?.state != mqtt.MqttConnectionState.connected) {
      _client = null;
      _setState(MqttConnectionState.disconnected);
      throw MqttConnectionException(
        'broker refused the connection: ${status?.returnCode}',
      );
    }
    _updates = client.updates?.listen(_onUpdates);
    _setState(MqttConnectionState.connected);
  }

  @override
  /// Completes once the broker has acknowledged the subscription, so that
  /// anything published after it returns is delivered. Returning on send
  /// instead loses messages that race the SUBSCRIBE, which over TLS or a
  /// slow link is easy to hit.
  Future<void> subscribe(
    String filter, {
    MqttQos qos = MqttQos.atLeastOnce,
  }) async {
    final client = _connected();
    if (client.getSubscriptionsStatus(filter) ==
        mqtt.MqttSubscriptionStatus.active) {
      return;
    }
    final acked = _subscribing.putIfAbsent(filter, Completer<void>.new);
    final subscription = client.subscribe(filter, _toClientQos(qos));
    if (subscription == null) {
      _subscribing.remove(filter);
      throw MqttConnectionException('subscribe refused: $filter');
    }
    try {
      await acked.future.timeout(connectTimeout);
    } on TimeoutException {
      _subscribing.remove(filter);
      throw MqttConnectionException('no SUBACK for $filter');
    }
  }

  @override
  Future<void> unsubscribe(String filter) async {
    _connected().unsubscribe(filter);
  }

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    final client = _connected();
    final buffer = typed.Uint8Buffer()..addAll(payload);
    try {
      client.publishMessage(topic, _toClientQos(qos), buffer, retain: retain);
    } on Object catch (error) {
      throw MqttConnectionException('publish failed: $error');
    }
  }

  @override
  Future<void> disconnect() async {
    final client = _client;
    if (client == null) return;
    _client = null;
    _failPendingSubscribes();
    await _updates?.cancel();
    _updates = null;
    client
      ..onDisconnected = null
      ..disconnect();
    _setState(MqttConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    _disposed = true;
    await _state.close();
    await _messages.close();
  }

  mqtt.MqttClient _connected() {
    if (_disposed) throw const MqttConnectionException('disposed');
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != mqtt.MqttConnectionState.connected) {
      throw const MqttConnectionException('not connected');
    }
    return client;
  }

  void _onSubscribed(String filter) => _subscribing.remove(filter)?.complete();

  void _onSubscribeFail(String filter) => _subscribing
      .remove(filter)
      ?.completeError(MqttConnectionException('subscribe refused: $filter'));

  void _failPendingSubscribes() {
    final pending = _subscribing.values.toList();
    _subscribing.clear();
    for (final completer in pending) {
      completer.completeError(
        const MqttConnectionException('disconnected before SUBACK'),
      );
    }
  }

  void _onDisconnected(mqtt.MqttClient client) {
    if (_client != client) return;
    _client = null;
    _failPendingSubscribes();
    unawaited(_updates?.cancel());
    _updates = null;
    _setState(MqttConnectionState.disconnected);
  }

  void _onUpdates(List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> updates) {
    for (final update in updates) {
      final payload = update.payload;
      if (payload is! mqtt.MqttPublishMessage) continue;
      final header = payload.header;
      if (_messages.isClosed) return;
      _messages.add(
        MqttMessage(
          topic: update.topic,
          payload: Uint8List.fromList(payload.payload.message),
          qos: MqttQos.fromLevel(header?.qos.index ?? 0),
          retained: header?.retain ?? false,
          duplicate: header?.duplicate ?? false,
        ),
      );
    }
  }

  void _setState(MqttConnectionState next) {
    if (_current == next) return;
    _current = next;
    if (!_state.isClosed) _state.add(next);
  }

  static mqtt.MqttQos _toClientQos(MqttQos qos) => switch (qos) {
    MqttQos.atMostOnce => mqtt.MqttQos.atMostOnce,
    MqttQos.atLeastOnce => mqtt.MqttQos.atLeastOnce,
    MqttQos.exactlyOnce => mqtt.MqttQos.exactlyOnce,
  };
}
