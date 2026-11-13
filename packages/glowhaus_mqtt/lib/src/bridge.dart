import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:glowhaus_mqtt/src/connection.dart';
import 'package:glowhaus_mqtt/src/in_memory_broker.dart';

/// A message pipe shared by several parties, such as a browser
/// `BroadcastChannel`: everything posted reaches every other party, in the
/// order its sender posted it. Messages are JSON-compatible maps.
abstract interface class BridgePort {
  Stream<Map<String, Object?>> get messages;

  void post(Map<String, Object?> message);

  void close();
}

/// Lets clients elsewhere (another browser tab) use an [InMemoryBroker] as
/// if they were here, over a [BridgePort].
///
/// A guest says `hello`, the host answers `welcome` with whatever
/// [onJoin] returns, and from then on relays MQTT for the guest's
/// connections: connect with a will, subscribe, publish, messages, and
/// disconnect. A guest that stops sending (its tab closed or crashed) is
/// gone after [timeout]; its connections are dropped as a broker drops a
/// dead TCP link, so their last wills are published.
class BridgeHost {
  new({
    required this.broker,
    required this.port,
    required this.hostId,
    required this.onJoin,
    required this.onLeave,
    this.timeout = const Duration(seconds: 4),
  }) {
    _subscription = port.messages.listen(_onMessage);
    _sweeper = Timer.periodic(timeout ~/ _sweepsPerTimeout, (_) => _sweep());
  }

  /// Silence is counted in sweeps, not wall-clock time, so a host tab that
  /// was asleep in the background does not drop everyone when it wakes.
  static const int _sweepsPerTimeout = 4;

  final InMemoryBroker broker;
  final BridgePort port;
  final String hostId;

  /// Called when a guest joins; what it returns is sent in the `welcome`.
  final FutureOr<Map<String, Object?>> Function(String guestId) onJoin;

  /// Called after a guest left (said bye or went silent) and its
  /// connections were closed.
  final FutureOr<void> Function(String guestId) onLeave;
  final Duration timeout;

  late final StreamSubscription<Map<String, Object?>> _subscription;
  late final Timer _sweeper;
  final Map<String, _Guest> _guests = {};

  /// Guests connected right now.
  Iterable<String> get guests => _guests.keys;

  Future<void> close() async {
    _sweeper.cancel();
    await _subscription.cancel();
    for (final id in _guests.keys.toList()) {
      await _leave(id, graceful: false);
    }
  }

  Future<void> _onMessage(Map<String, Object?> message) async {
    final from = message['from'];
    if (from is! String) return;
    final type = message['t'];
    if (type == 'hello') {
      if (_guests.containsKey(from)) return;
      _guests[from] = _Guest();
      final welcome = await onJoin(from);
      _post(from, {'t': 'welcome', ...welcome});
      return;
    }
    if (message['to'] != hostId) return;
    final guest = _guests[from];
    if (guest == null) return;
    guest.silentSweeps = 0;
    final c = message['c'];
    switch (type) {
      case 'bye':
        await _leave(from, graceful: true);
      case 'connect' when c is String:
        await _connect(from, guest, c, message);
      case 'sub' when c is String:
        final connection = guest.connections[c];
        final filter = message['filter']! as String;
        try {
          await connection?.subscribe(
            filter,
            qos: MqttQos.fromLevel(message['qos']! as int),
          );
          _post(from, {'t': 'suback', 'c': c, 'filter': filter, 'ok': true});
        } on MqttConnectionException {
          _post(from, {'t': 'suback', 'c': c, 'filter': filter, 'ok': false});
        }
      case 'unsub' when c is String:
        await guest.connections[c]?.unsubscribe(message['filter']! as String);
      case 'pub' when c is String:
        try {
          await guest.connections[c]?.publish(
            message['topic']! as String,
            _bytes(message['payload']),
            qos: MqttQos.fromLevel(message['qos']! as int),
            retain: message['retain'] == true,
          );
        } on MqttConnectionException {
          // The guest learns of a dead connection from the `drop` below.
        }
      case 'disc' when c is String:
        final connection = guest.connections.remove(c);
        guest.clientIds.remove(c);
        await connection?.disconnect();
        await connection?.dispose();
      default:
    }
  }

  Future<void> _connect(
    String from,
    _Guest guest,
    String c,
    Map<String, Object?> message,
  ) async {
    final connection = broker.client();
    final clientId = message['clientId']! as String;
    final will = message['will'];
    connection.messages.listen(
      (m) => _post(from, {
        't': 'msg',
        'c': c,
        'topic': m.topic,
        'payload': base64Encode(m.payload),
        'qos': m.qos.level,
        'retained': m.retained,
        'dup': m.duplicate,
      }),
    );
    connection.state.listen((state) {
      // Taken over or dropped by the broker, not by the guest.
      if (state == MqttConnectionState.disconnected &&
          guest.connections[c] == connection) {
        guest.connections.remove(c);
        guest.clientIds.remove(c);
        _post(from, {'t': 'drop', 'c': c});
      }
    });
    try {
      await connection.connect(
        clientId: clientId,
        will: will is Map<String, Object?>
            ? MqttWill(
                topic: will['topic']! as String,
                payload: _bytes(will['payload']),
                qos: MqttQos.fromLevel(will['qos']! as int),
                retain: will['retain'] == true,
              )
            : null,
      );
      guest.connections[c] = connection;
      guest.clientIds[c] = clientId;
      _post(from, {'t': 'connack', 'c': c, 'ok': true});
    } on MqttConnectionException catch (e) {
      await connection.dispose();
      _post(from, {'t': 'connack', 'c': c, 'ok': false, 'error': e.message});
    }
  }

  void _sweep() {
    for (final MapEntry(key: id, value: guest) in _guests.entries.toList()) {
      if (++guest.silentSweeps > _sweepsPerTimeout) {
        unawaited(_leave(id, graceful: false));
      }
    }
  }

  Future<void> _leave(String guestId, {required bool graceful}) async {
    final guest = _guests.remove(guestId);
    if (guest == null) return;
    for (final MapEntry(key: c, value: connection)
        in guest.connections.entries.toList()) {
      guest.connections.remove(c);
      final clientId = guest.clientIds.remove(c);
      if (graceful) {
        await connection.disconnect();
      } else if (clientId != null) {
        // A tab that vanished is a dead link: the broker publishes wills.
        broker.drop(clientId);
      }
      await connection.dispose();
    }
    await onLeave(guestId);
  }

  void _post(String to, Map<String, Object?> message) =>
      port.post({...message, 'from': hostId, 'to': to});
}

class _Guest {
  int silentSweeps = 0;
  final Map<String, MqttConnection> connections = {};
  final Map<String, String> clientIds = {};
}

/// The other end of a [BridgeHost]: joins it and hands out
/// [MqttConnection]s that reach its broker.
class BridgeGuest {
  new({
    required this.port,
    required this.guestId,
    this.heartbeat = const Duration(seconds: 1),
  }) {
    _subscription = port.messages.listen(_onMessage);
  }

  final BridgePort port;
  final String guestId;
  final Duration heartbeat;

  late final StreamSubscription<Map<String, Object?>> _subscription;
  final _welcome = Completer<Map<String, Object?>>();
  final Map<String, _BridgeConnection> _connections = {};
  Timer? _beat;
  String? _hostId;
  var _next = 0;

  /// The host that answered, once [join] completed.
  String? get hostId => _hostId;

  /// Says hello and waits for a host's welcome (its [BridgeHost.onJoin]
  /// payload). Throws a [TimeoutException] if no host answers.
  Future<Map<String, Object?>> join({
    Duration wait = const Duration(seconds: 3),
  }) async {
    port.post({'t': 'hello', 'from': guestId});
    final welcome = await _welcome.future.timeout(wait);
    _beat = Timer.periodic(heartbeat, (_) => _send({'t': 'ping'}));
    return welcome;
  }

  /// A connection to the host's broker. Usable after [join].
  MqttConnection connection() {
    final c = '${_next++}';
    return _connections[c] = _BridgeConnection(this, c);
  }

  /// Leaves cleanly: the host disconnects every connection without wills.
  Future<void> leave() async {
    _beat?.cancel();
    if (_hostId != null) _send({'t': 'bye'});
    for (final connection in _connections.values.toList()) {
      connection._dropped();
    }
    await _subscription.cancel();
  }

  void _onMessage(Map<String, Object?> message) {
    if (message['to'] != guestId) return;
    final from = message['from'];
    if (message['t'] == 'welcome' && !_welcome.isCompleted && from is String) {
      _hostId = from;
      _welcome.complete(message);
      return;
    }
    if (from != _hostId) return;
    final connection = _connections[message['c']];
    if (connection == null) return;
    switch (message['t']) {
      case 'connack':
        connection._connack(
          ok: message['ok'] == true,
          error: message['error'] as String?,
        );
      case 'suback':
        connection._suback(
          message['filter']! as String,
          ok: message['ok'] == true,
        );
      case 'msg':
        connection._deliver(
          MqttMessage(
            topic: message['topic']! as String,
            payload: _bytes(message['payload']),
            qos: MqttQos.fromLevel(message['qos']! as int),
            retained: message['retained'] == true,
            duplicate: message['dup'] == true,
          ),
        );
      case 'drop':
        connection._dropped();
      default:
    }
  }

  void _send(Map<String, Object?> message) =>
      port.post({...message, 'from': guestId, 'to': _hostId});
}

class _BridgeConnection implements MqttConnection {
  new(this._guest, this._c);

  final BridgeGuest _guest;
  final String _c;
  final _state = StreamController<MqttConnectionState>.broadcast();
  final _messages = StreamController<MqttMessage>.broadcast();
  final Map<String, Completer<void>> _subscribing = {};
  Completer<void>? _connecting;
  MqttConnectionState _current = MqttConnectionState.disconnected;

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
    if (_guest._hostId == null) {
      throw const MqttConnectionException('bridge not joined');
    }
    if (_current == MqttConnectionState.connected) return;
    _set(MqttConnectionState.connecting);
    final connecting = _connecting = Completer<void>();
    _guest._send({
      't': 'connect',
      'c': _c,
      'clientId': clientId,
      if (will != null)
        'will': {
          'topic': will.topic,
          'payload': base64Encode(will.payload),
          'qos': will.qos.level,
          'retain': will.retain,
        },
    });
    try {
      await connecting.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      _set(MqttConnectionState.disconnected);
      throw const MqttConnectionException('bridge host did not answer');
    }
  }

  @override
  Future<void> subscribe(
    String filter, {
    MqttQos qos = MqttQos.atLeastOnce,
  }) async {
    _checkConnected();
    final acked = _subscribing.putIfAbsent(filter, Completer<void>.new);
    _guest._send({'t': 'sub', 'c': _c, 'filter': filter, 'qos': qos.level});
    await acked.future;
  }

  @override
  Future<void> unsubscribe(String filter) async {
    _checkConnected();
    _guest._send({'t': 'unsub', 'c': _c, 'filter': filter});
  }

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    _checkConnected();
    _guest._send({
      't': 'pub',
      'c': _c,
      'topic': topic,
      'payload': base64Encode(payload),
      'qos': qos.level,
      'retain': retain,
    });
  }

  @override
  Future<void> disconnect() async {
    if (_current == MqttConnectionState.disconnected) return;
    _guest._send({'t': 'disc', 'c': _c});
    _set(MqttConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    _guest._connections.remove(_c);
    await _state.close();
    await _messages.close();
  }

  void _checkConnected() {
    if (_current != MqttConnectionState.connected) {
      throw const MqttConnectionException('not connected');
    }
  }

  void _connack({required bool ok, String? error}) {
    final connecting = _connecting;
    _connecting = null;
    if (connecting == null || connecting.isCompleted) return;
    if (ok) {
      _set(MqttConnectionState.connected);
      connecting.complete();
    } else {
      _set(MqttConnectionState.disconnected);
      connecting.completeError(
        MqttConnectionException(
          error ?? 'refused',
          reason: MqttConnectFailure.refused,
        ),
      );
    }
  }

  void _suback(String filter, {required bool ok}) {
    final completer = _subscribing.remove(filter);
    if (completer == null) return;
    ok
        ? completer.complete()
        : completer.completeError(
            MqttConnectionException('subscribe refused: $filter'),
          );
  }

  void _deliver(MqttMessage message) {
    if (!_messages.isClosed) _messages.add(message);
  }

  void _dropped() {
    for (final completer in _subscribing.values) {
      completer.completeError(const MqttConnectionException('dropped'));
    }
    _subscribing.clear();
    _set(MqttConnectionState.disconnected);
  }

  void _set(MqttConnectionState next) {
    if (_current == next) return;
    _current = next;
    if (!_state.isClosed) _state.add(next);
  }
}

Uint8List _bytes(Object? base64) =>
    base64 is String ? base64Decode(base64) : Uint8List(0);
