import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:glowhaus_mqtt/src/connection.dart';
import 'package:meta/meta.dart';

/// Which way a message went, seen from the tapped connection.
enum TrafficDirection { sent, received }

/// One message on a tapped connection.
@immutable
class MqttTraffic {
  const new({
    required this.who,
    required this.direction,
    required this.topic,
    required this.text,
    required this.qos,
    required this.retained,
    required this.at,
  });

  /// The label the connection was tapped with, e.g. a device id.
  final String who;
  final TrafficDirection direction;
  final String topic;

  /// The payload as text; empty for a cleared retained message.
  final String text;
  final MqttQos qos;
  final bool retained;
  final DateTime at;
}

/// The last [capacity] messages on the connections it [tap]s: what the demo's
/// device panel shows as live protocol traffic.
class MqttTrafficLog {
  new({this.capacity = 200, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final int capacity;
  final DateTime Function() _clock;
  final _entries = ListQueue<MqttTraffic>();
  final _stream = StreamController<MqttTraffic>.broadcast(sync: true);

  /// Oldest first.
  List<MqttTraffic> get entries => List.unmodifiable(_entries);

  Stream<MqttTraffic> get stream => _stream.stream;

  /// [inner], with every message it sends or receives recorded as [who].
  MqttConnection tap(MqttConnection inner, {required String who}) =>
      _TappedConnection(inner, who, this);

  void clear() => _entries.clear();

  Future<void> close() => _stream.close();

  void _record(
    String who,
    TrafficDirection direction,
    String topic,
    Uint8List payload,
    MqttQos qos, {
    required bool retained,
  }) {
    final entry = MqttTraffic(
      who: who,
      direction: direction,
      topic: topic,
      text: String.fromCharCodes(payload),
      qos: qos,
      retained: retained,
      at: _clock(),
    );
    _entries.addLast(entry);
    while (_entries.length > capacity) {
      _entries.removeFirst();
    }
    if (!_stream.isClosed) _stream.add(entry);
  }
}

class _TappedConnection implements MqttConnection {
  new(this._inner, this._who, this._log) {
    // One subscription, so a message is recorded once however many listen.
    _forward = _inner.messages.listen((message) {
      _log._record(
        _who,
        TrafficDirection.received,
        message.topic,
        message.payload,
        message.qos,
        retained: message.retained,
      );
      _messages.add(message);
    });
  }

  final MqttConnection _inner;
  final String _who;
  final MqttTrafficLog _log;
  final _messages = StreamController<MqttMessage>.broadcast(sync: true);
  late final StreamSubscription<MqttMessage> _forward;

  @override
  MqttConnectionState get currentState => _inner.currentState;

  @override
  Stream<MqttConnectionState> get state => _inner.state;

  @override
  Stream<MqttMessage> get messages => _messages.stream;

  @override
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  }) => _inner.connect(
    clientId: clientId,
    will: will,
    login: login,
    keepAlive: keepAlive,
  );

  @override
  Future<void> subscribe(String filter, {MqttQos qos = MqttQos.atLeastOnce}) =>
      _inner.subscribe(filter, qos: qos);

  @override
  Future<void> unsubscribe(String filter) => _inner.unsubscribe(filter);

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    await _inner.publish(topic, payload, qos: qos, retain: retain);
    _log._record(
      _who,
      TrafficDirection.sent,
      topic,
      payload,
      qos,
      retained: retain,
    );
  }

  @override
  Future<void> disconnect() => _inner.disconnect();

  @override
  Future<void> dispose() async {
    // Not awaited, as in VirtualDevice.dispose.
    unawaited(_forward.cancel());
    unawaited(_messages.close());
    await _inner.dispose();
  }
}
