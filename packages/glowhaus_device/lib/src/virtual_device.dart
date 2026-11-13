import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:glowhaus_device/src/device_model.dart';
import 'package:glowhaus_device/src/link_config.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';

/// One device on the wire: a [DeviceModel] behind an [MqttConnection],
/// doing what `docs/protocol.md` asks of a device.
///
/// - connects with a clean session and a retained last will
///   (`availability: offline`), then publishes its retained `info`
///   (revision 1.1), `online`, its state and an announce;
/// - answers every discovery query with an announce after a short random
///   delay (section 5.2);
/// - ignores retained `set` messages, rejects expired ones, acks every
///   command exactly once (a QoS 1 redelivery gets the same ack again) and
///   publishes the new state after a successful one;
/// - publishes while covers move and while readings drift;
/// - publishes `offline` and disconnects cleanly when told to go offline;
/// - when the broker goes away, keeps trying to come back (1 s, doubling
///   to 30 s, with jitter), as any device on a shelf would.
///
/// [config] adds the imperfections of a real link: latency with jitter, the
/// odd `busy` rejection and the odd command that never arrives.
class VirtualDevice {
  new({
    required this.homeId,
    required this.spec,
    required this._connection,
    this.config = const SimulationConfig(),
    this.stateDelay = const Duration(milliseconds: 60),
    this.positionInterval = const Duration(milliseconds: 400),
    this.ambientInterval = const Duration(seconds: 2),
    this.reconnectInitial = const Duration(seconds: 1),
    this.reconnectMax = const Duration(seconds: 30),
    Random? random,
    DateTime Function()? clock,
    this._topics = const TopicCodec(),
  }) : model = DeviceModel(spec),
       _random = random ?? Random(),
       _clock = clock ?? DateTime.now {
    _messages = _connection.messages.listen(_onMessage);
    _link = _connection.state.listen(_onLink);
  }

  final String homeId;
  final DeviceSpec spec;
  final DeviceModel model;

  /// Link knobs. May be replaced at any time; applies to the next command.
  SimulationConfig config;

  /// Gap between an ack and the state message that follows it.
  final Duration stateDelay;

  /// How often a moving cover reports progress.
  final Duration positionInterval;

  /// How often sensors and meters change by themselves. Null disables it.
  final Duration? ambientInterval;

  /// First wait after the broker went away; doubles up to [reconnectMax].
  final Duration reconnectInitial;
  final Duration reconnectMax;

  final MqttConnection _connection;
  final Random _random;
  final DateTime Function() _clock;
  final TopicCodec _topics;
  late final StreamSubscription<MqttMessage> _messages;
  late final StreamSubscription<MqttConnectionState> _link;
  final Set<Timer> _timers = {};
  Timer? _positionTimer;
  Timer? _ambientTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _online = false;
  bool _disposed = false;
  final _changes = StreamController<void>.broadcast(sync: true);

  /// Fires whenever [state] or [online] changes, for a panel that shows the
  /// device. Not part of the protocol.
  Stream<void> get changes => _changes.stream;

  String get id => spec.descriptor.id;

  /// Unique per home and device; a second instance would take this one's
  /// place on the broker.
  String get clientId => 'device-$homeId-$id';

  /// Whether the device is on the network right now.
  bool get online => _online;

  /// Reconnects tried since the device last lost its broker.
  int get reconnectAttempts => _reconnectAttempts;

  Map<String, CapabilityState> get state => model.snapshot();

  int get _ts => _clock().millisecondsSinceEpoch;

  String _topic(DeviceChannel channel) => _topics.device(homeId, id, channel);

  /// Brings the device up, or, for a spec that starts offline, announces it
  /// once and leaves it offline (as a device that was known, then unplugged).
  ///
  /// A broker that is not there yet is not an error: like a real device after
  /// a power cut, it keeps trying with the same backoff as after a drop.
  Future<void> start() async {
    try {
      await _boot();
    } on MqttConnectionException {
      _scheduleRetry(_boot);
    }
  }

  Future<void> _boot() async {
    if (spec.online) {
      await goOnline();
      return;
    }
    await _connect();
    _reconnectAttempts = 0;
    await _publishInfo();
    await _announce();
    await _publishAvailability(AvailabilityStatus.offline);
    await _connection.disconnect();
  }

  /// Plugs the device in: connect, announce, go online, report state.
  Future<void> goOnline() async {
    if (_online) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _connect();
    _reconnectAttempts = 0;
    _online = true;
    _changed();
    await _publishInfo();
    await _publishAvailability(AvailabilityStatus.online);
    await _publishState();
    await _announce();
    _startAmbient();
    _ensurePositionTimer();
  }

  /// Unplugs the device cleanly: it says goodbye on its availability topic
  /// itself (section 6), so the will is not needed.
  Future<void> goOffline() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (!_online) return;
    _online = false;
    _changed();
    _cancelTimers();
    try {
      await _publishAvailability(AvailabilityStatus.offline);
      await _connection.disconnect();
    } on MqttConnectionException {
      // The link is already gone; there is nobody left to say goodbye to.
    }
  }

  /// Someone used the device itself (its button, a wall switch). An
  /// unplugged device has no power, so nothing happens then.
  Future<void> pressLocal(Map<String, CapabilityPatch> patches) async {
    if (!_online || !model.applyLocal(patches)) return;
    await _publishState();
    _ensurePositionTimer();
  }

  /// Carries on from [snapshot] (see [DeviceModel.restore]). Call while the
  /// device is offline, before [goOnline].
  void restore(Map<String, CapabilityState> snapshot) {
    model.restore(snapshot);
    _changed();
  }

  /// [goOffline] plus releasing the connection. The device cannot be reused.
  Future<void> dispose() async {
    if (_disposed) return;
    await goOffline();
    _disposed = true;
    // None of these is awaited: nothing here depends on them finishing,
    // and a cancel can hand back a future of another zone, which keeps a
    // test's fake clock from seeing the rest of the shutdown.
    unawaited(_messages.cancel());
    unawaited(_changes.close());
    unawaited(_link.cancel());
    await _connection.dispose();
  }

  Future<void> _connect() => _connection
      .connect(
        clientId: clientId,
        will: MqttWill.text(
          _topic(DeviceChannel.availability),
          jsonEncode(
            const AvailabilityPayload(status: AvailabilityStatus.offline)
                .toJson(),
          ),
          retain: true,
        ),
      )
      .then((_) async {
        await _connection.subscribe(_topic(DeviceChannel.set));
        await _connection.subscribe(
          _topics.discovery(homeId),
          qos: MqttQos.atMostOnce,
        );
      });

  Future<void> _announce() => _connection.publishText(
    _topics.discovery(homeId),
    jsonEncode(
      DiscoveryMessage.announce(ts: _ts, device: spec.descriptor).toJson(),
    ),
    qos: MqttQos.atMostOnce,
  );

  /// Revision 1.1: the descriptor, retained, so an app that connects later
  /// knows this device even while it is offline.
  Future<void> _publishInfo() => _connection.publishText(
    _topic(DeviceChannel.info),
    jsonEncode(InfoPayload(ts: _ts, device: spec.descriptor).toJson()),
    retain: true,
  );

  Future<void> _publishAvailability(AvailabilityStatus status) =>
      _connection.publishText(
        _topic(DeviceChannel.availability),
        jsonEncode(AvailabilityPayload(status: status, ts: _ts).toJson()),
        retain: true,
      );

  void _changed() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> _publishState() async {
    if (!_online) return;
    _changed();
    await _connection.publishText(
      _topic(DeviceChannel.state),
      jsonEncode(StatePayload.encode(model.snapshot(), ts: _ts).toJson()),
      retain: true,
    );
  }

  /// The network went away (the broker published the will): the device is
  /// off the air, and tries to come back with growing pauses.
  void _onLink(MqttConnectionState state) {
    if (state == MqttConnectionState.disconnected && _online) {
      _online = false;
      _changed();
      _cancelTimers();
      _scheduleRetry(goOnline);
    }
  }

  void _scheduleRetry(Future<void> Function() attempt) {
    if (_disposed || _reconnectTimer != null) return;
    final exponent = min(_reconnectAttempts, 10);
    final base = min(
      reconnectInitial.inMilliseconds * (1 << exponent),
      reconnectMax.inMilliseconds,
    );
    final jitter = (base * 0.5 * _random.nextDouble()).round();
    _reconnectTimer = Timer(Duration(milliseconds: base + jitter), () async {
      _reconnectTimer = null;
      _reconnectAttempts++;
      try {
        await attempt();
      } on MqttConnectionException {
        _scheduleRetry(attempt);
      }
    });
  }

  Future<void> _onMessage(MqttMessage message) async {
    final topic = _topics.parse(message.topic);
    if (topic == null || topic.homeId != homeId) return;
    switch (topic) {
      case DiscoveryTopic():
        _onDiscovery(message);
      case DeviceTopic(:final deviceId, :final channel):
        if (deviceId == id && channel == DeviceChannel.set) {
          _onSet(message);
        }
    }
  }

  void _onDiscovery(MqttMessage message) {
    if (!_online) return;
    final Object? json;
    try {
      json = jsonDecode(message.text);
    } on FormatException {
      return;
    }
    if (json is! Map<String, dynamic> || json['type'] != 'query') return;
    // Section 5.2: answer after a random delay so a home full of devices
    // does not answer in one burst.
    _timer(
      Duration(
        milliseconds: _random.nextInt(Protocol.announceJitter.inMilliseconds),
      ),
      () => unawaited(_announce()),
    );
  }

  void _onSet(MqttMessage message) {
    // Section 3: a retained set is stale by definition.
    if (message.retained || !_online) return;
    final SetPayload payload;
    try {
      final json = jsonDecode(message.text);
      if (json is! Map<String, dynamic>) return;
      payload = SetPayload.fromJson(json);
    } on Object {
      // Without a commandId there is nothing to ack.
      return;
    }
    // A lost command: it never reached the device.
    if (_roll(config.timeoutRate)) return;

    _timer(_latency(), () {
      if (!_online) return;
      final (:ack, :applied) = model.handle(
        payload,
        now: _clock(),
        shouldFail: () => _roll(config.failureRate),
      );
      unawaited(
        _connection.publishText(
          _topic(DeviceChannel.ack),
          jsonEncode(ack.toJson()),
        ),
      );
      if (applied) {
        _timer(stateDelay, () {
          unawaited(_publishState());
          _ensurePositionTimer();
        });
      }
    });
  }

  void _startAmbient() {
    final interval = ambientInterval;
    if (interval == null || _ambientTimer != null) return;
    _ambientTimer = Timer.periodic(interval, (_) {
      if (model.ambientTick(_random, elapsed: interval, now: _clock())) {
        unawaited(_publishState());
      }
    });
  }

  void _ensurePositionTimer() {
    if (_positionTimer != null || !_online || !model.isMoving) return;
    _positionTimer = Timer.periodic(positionInterval, (timer) {
      if (model.stepPositions()) unawaited(_publishState());
      if (!model.isMoving) {
        timer.cancel();
        _positionTimer = null;
      }
    });
  }

  Duration _latency() {
    final spread = config.latencyJitter * (_random.nextDouble() * 2 - 1);
    return config.latency * (1 + spread);
  }

  bool _roll(double probability) =>
      probability > 0 && _random.nextDouble() < probability;

  void _timer(Duration duration, void Function() callback) {
    late final Timer timer;
    timer = Timer(duration, () {
      _timers.remove(timer);
      callback();
    });
    _timers.add(timer);
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _positionTimer?.cancel();
    _positionTimer = null;
    _ambientTimer?.cancel();
    _ambientTimer = null;
  }
}
