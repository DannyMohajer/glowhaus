import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:glowhaus_transport/src/mqtt/reconnect_policy.dart';
import 'package:glowhaus_transport/src/transport.dart';

/// A [Transport] that speaks the Glowhaus protocol over an [MqttConnection]:
/// a real broker through the `mqtt_client` adapter, or an [InMemoryBroker].
///
/// What it does with the connection:
///
/// - subscribes to the home's `state`, `ack` and `availability` at QoS 1 and
///   `discovery` at QoS 0, then sends a discovery query;
/// - publishes commands as non-retained QoS 1 `set` messages and answers
///   [send] from the matching ack, or `timedOut` when none arrives;
/// - reconnects with [ReconnectPolicy] backoff when the link drops,
///   re-subscribes and re-queries. While the link is down every pending
///   command fails as `unreachable` and so does any new [send]. Nothing is
///   said about the devices: a device is offline only when its own
///   availability topic (its last will) says so; losing the broker means
///   the app shows what it last knew.
///
/// State and availability that arrive before the device's announce (retained
/// messages are delivered as soon as the app subscribes, the announce only
/// after the query) are held until the announce, then emitted in order.
class MqttTransport implements Transport {
  new({
    required this.homeId,
    required this._connection,
    required this.clientId,
    this.login,
    this.reconnectPolicy = const ReconnectPolicy(),
    DateTime Function()? clock,
    Random? random,
    this._topics = const TopicCodec(),
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random() {
    _connectionState = _connection.state.listen(_onConnectionState);
    _messages = _connection.messages.listen(_onMessage);
  }

  final String homeId;
  final String clientId;
  final MqttLogin? login;
  final ReconnectPolicy reconnectPolicy;

  final MqttConnection _connection;
  final DateTime Function() _clock;
  final Random _random;
  final TopicCodec _topics;

  late final StreamSubscription<MqttConnectionState> _connectionState;
  late final StreamSubscription<MqttMessage> _messages;
  final _statusController = StreamController<TransportStatus>.broadcast();
  final _eventController = StreamController<DeviceEvent>.broadcast();
  final Map<String, _Pending> _pending = {};
  final Map<String, DeviceDescriptor> _descriptors = {};
  final Map<String, StatePayload> _stateBeforeAnnounce = {};
  final Map<String, AvailabilityPayload> _availabilityBeforeAnnounce = {};

  TransportStatus _status = TransportStatus.disconnected;
  bool _wanted = false;
  bool _disposed = false;
  int _attempt = 0;
  Timer? _retry;

  /// Reconnect attempts since the last successful connection.
  int get reconnectAttempts => _attempt;

  @override
  TransportStatus get currentStatus => _status;

  @override
  Stream<TransportStatus> get status => _statusController.stream;

  @override
  Stream<DeviceEvent> get events => _eventController.stream;

  @override
  Future<void> connect() async {
    if (_disposed) throw StateError('MqttTransport is disposed');
    if (_wanted) return;
    _wanted = true;
    _attempt = 0;
    _setStatus(TransportStatus.connecting);
    await _attemptConnect();
  }

  @override
  Future<void> disconnect() async {
    if (!_wanted) return;
    _wanted = false;
    _retry?.cancel();
    _retry = null;
    _failPending();
    await _connection.disconnect();
    _setStatus(TransportStatus.disconnected);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await disconnect();
    _disposed = true;
    await _connectionState.cancel();
    await _messages.cancel();
    await _statusController.close();
    await _eventController.close();
    await _connection.dispose();
  }

  @override
  Future<CommandResult> send(
    DeviceCommand command, {
    Duration timeout = Protocol.commandTimeout,
  }) async {
    if (_status != TransportStatus.connected || command.homeId != homeId) {
      return CommandResult.unreachable(commandId: command.id);
    }
    final completer = Completer<CommandResult>();
    final pending = _Pending(
      command.id,
      completer,
      Timer(timeout, () {
        _pending.remove(command.id);
        if (!completer.isCompleted) {
          completer.complete(CommandResult.timedOut(commandId: command.id));
        }
      }),
    );
    _pending[command.id] = pending;
    try {
      await _connection.publishText(
        _topics.device(homeId, command.deviceId, DeviceChannel.set),
        jsonEncode(command.toPayload().toJson()),
      );
    } on MqttConnectionException {
      _pending.remove(command.id)?.timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(CommandResult.unreachable(commandId: command.id));
      }
    }
    return await completer.future;
  }

  Future<void> _attemptConnect() async {
    if (!_wanted) return;
    try {
      await _connection.connect(clientId: clientId, login: login);
      await _subscribeAll();
      await _query();
    } on MqttConnectionException {
      _scheduleRetry();
      return;
    }
    if (!_wanted) return;
    _attempt = 0;
    _setStatus(TransportStatus.connected);
  }

  Future<void> _subscribeAll() async {
    for (final channel in [
      DeviceChannel.state,
      DeviceChannel.ack,
      DeviceChannel.availability,
    ]) {
      await _connection.subscribe(_topics.allDevicesFilter(homeId, channel));
    }
    await _connection.subscribe(
      _topics.discovery(homeId),
      qos: MqttQos.atMostOnce,
    );
  }

  Future<void> _query() => _connection.publishText(
    _topics.discovery(homeId),
    jsonEncode(
      DiscoveryMessage.query(ts: _clock().millisecondsSinceEpoch).toJson(),
    ),
    qos: MqttQos.atMostOnce,
  );

  void _onConnectionState(MqttConnectionState state) {
    if (state != MqttConnectionState.disconnected || !_wanted) return;
    // The link dropped under us. Devices keep their last known state and
    // availability; only the commands in flight are lost.
    _failPending();
    _setStatus(
      _status == TransportStatus.connected
          ? TransportStatus.reconnecting
          : _status,
    );
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_wanted || _retry != null) return;
    final delay = reconnectPolicy.delay(_attempt, _random);
    _attempt++;
    _retry = Timer(delay, () {
      _retry = null;
      unawaited(_attemptConnect());
    });
  }

  void _failPending() {
    final pending = _pending.values.toList();
    _pending.clear();
    for (final p in pending) {
      p.timer.cancel();
    }
    for (final p in pending) {
      if (!p.completer.isCompleted) {
        p.completer.complete(CommandResult.unreachable(commandId: p.commandId));
      }
    }
  }

  void _onMessage(MqttMessage message) {
    final topic = _topics.parse(message.topic);
    if (topic == null || topic.homeId != homeId) return;
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(message.text);
      if (decoded is! Map<String, dynamic>) return;
      json = decoded;
    } on FormatException {
      return;
    }
    // Section 4: never act on a payload from a newer protocol version.
    if (json['v'] is int && (json['v'] as int) > Protocol.version) return;

    try {
      switch (topic) {
        case DiscoveryTopic():
          _onDiscovery(DiscoveryMessage.fromJson(json));
        case DeviceTopic(:final deviceId, :final channel):
          switch (channel) {
            case DeviceChannel.ack:
              _onAck(AckPayload.fromJson(json));
            case DeviceChannel.state:
              _onState(deviceId, StatePayload.fromJson(json));
            case DeviceChannel.availability:
              _onAvailability(deviceId, AvailabilityPayload.fromJson(json));
            case DeviceChannel.set:
              // Apps do not subscribe to set; ignore if a broker echoes one.
              break;
          }
      }
    } on Object {
      // A malformed payload from one device must not take the app down.
      return;
    }
  }

  void _onDiscovery(DiscoveryMessage message) {
    switch (message) {
      case DiscoveryAnnounce(:final device):
        _descriptors[device.id] = device;
        _emit(DeviceAnnounced(homeId: homeId, descriptor: device));
        final availability = _availabilityBeforeAnnounce.remove(device.id);
        if (availability != null) _onAvailability(device.id, availability);
        final state = _stateBeforeAnnounce.remove(device.id);
        if (state != null) _onState(device.id, state);
      case DiscoveryBye(:final deviceId):
        _descriptors.remove(deviceId);
        _stateBeforeAnnounce.remove(deviceId);
        _availabilityBeforeAnnounce.remove(deviceId);
        _emit(DeviceRemoved(homeId: homeId, deviceId: deviceId));
      case DiscoveryQuery():
        break;
    }
  }

  void _onAck(AckPayload ack) {
    // Unknown ids: another app's command, or a QoS 1 redelivery of an ack
    // already handled. Both are ignored.
    final pending = _pending.remove(ack.commandId);
    if (pending == null) return;
    pending.timer.cancel();
    if (!pending.completer.isCompleted) {
      pending.completer.complete(ack.toResult());
    }
  }

  void _onState(String deviceId, StatePayload payload) {
    final descriptor = _descriptors[deviceId];
    if (descriptor == null) {
      _stateBeforeAnnounce[deviceId] = payload;
      return;
    }
    _emit(
      DeviceStateChanged(
        homeId: homeId,
        deviceId: deviceId,
        state: payload.decode(descriptor.capabilities),
        at: DateTime.fromMillisecondsSinceEpoch(payload.ts, isUtc: true),
      ),
    );
  }

  void _onAvailability(String deviceId, AvailabilityPayload payload) {
    if (!_descriptors.containsKey(deviceId)) {
      _availabilityBeforeAnnounce[deviceId] = payload;
      return;
    }
    _emit(
      DeviceAvailabilityChanged(
        homeId: homeId,
        deviceId: deviceId,
        availability: payload.availability,
      ),
    );
  }

  void _setStatus(TransportStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  void _emit(DeviceEvent event) {
    if (!_eventController.isClosed) _eventController.add(event);
  }
}

class _Pending {
  new(this.commandId, this.completer, this.timer);

  final String commandId;
  final Completer<CommandResult> completer;
  final Timer timer;
}
