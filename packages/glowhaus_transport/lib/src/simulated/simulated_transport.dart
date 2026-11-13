import 'dart:async';
import 'dart:math';

import 'package:glowhaus_device/glowhaus_device.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:glowhaus_transport/src/mqtt/mqtt_transport.dart';
import 'package:glowhaus_transport/src/mqtt/reconnect_policy.dart';
import 'package:glowhaus_transport/src/transport.dart';

/// The offline demo: an [InMemoryBroker], a [VirtualHome] of devices on it,
/// and an [MqttTransport] for the app, all in one isolate.
///
/// Nothing is simulated about the protocol: every command is a real `set`
/// message that a real device engine answers with a real ack and a retained
/// state. Only the network is imitated ([config]: latency, rejections, lost
/// commands) and the devices are virtual.
class SimulatedTransport implements Transport {
  new({
    required this.homeId,
    required Iterable<DeviceSpec> devices,
    SimulationConfig config = const SimulationConfig(),
    Random? random,
    DateTime Function()? clock,
    this.connectDelay = const Duration(milliseconds: 300),
    Duration stateDelay = const Duration(milliseconds: 60),
    Duration positionInterval = const Duration(milliseconds: 400),
    Duration? ambientInterval = const Duration(seconds: 2),
    InMemoryBroker? broker,
  }) : broker = broker ?? InMemoryBroker() {
    final seed = random ?? Random();
    home = VirtualHome(
      homeId: homeId,
      specs: devices,
      connectionFactory: this.broker.client,
      config: config,
      stateDelay: stateDelay,
      positionInterval: positionInterval,
      ambientInterval: ambientInterval,
      random: seed,
      clock: clock,
    );
    _app = MqttTransport(
      homeId: homeId,
      connection: this.broker.client(),
      clientId: appClientId,
      clock: clock,
      random: seed,
      reconnectPolicy: const ReconnectPolicy(
        initial: Duration(milliseconds: 500),
        maximum: Duration(seconds: 5),
      ),
    );
    _appStatus = _app.status.listen(_onAppStatus);
  }

  /// Client id of the app's connection; `broker.drop(appClientId)` cuts it.
  static const String appClientId = 'app';

  final String homeId;

  /// How long [connect] takes before the broker "answers".
  final Duration connectDelay;

  /// The broker, shared with anything else that wants to join the demo
  /// (the in-browser device panel, a second app instance).
  final InMemoryBroker broker;

  /// The devices.
  late final VirtualHome home;

  late final MqttTransport _app;
  late final StreamSubscription<TransportStatus> _appStatus;
  final _statusController = StreamController<TransportStatus>.broadcast();
  TransportStatus _status = TransportStatus.disconnected;
  bool _disposed = false;

  /// Link knobs. May be replaced at any time; applies to new commands.
  SimulationConfig get config => home.config;

  set config(SimulationConfig value) => home.config = value;

  @override
  TransportStatus get currentStatus => _status;

  @override
  Stream<TransportStatus> get status => _statusController.stream;

  @override
  Stream<DeviceEvent> get events => _app.events;

  /// Current state of a virtual device, for inspection.
  Map<String, CapabilityState>? deviceState(String deviceId) =>
      home.stateOf(deviceId);

  @override
  Future<void> connect() async {
    if (_disposed) throw StateError('SimulatedTransport is disposed');
    if (_status != TransportStatus.disconnected) return;
    _setStatus(TransportStatus.connecting);
    await Future<void>.delayed(connectDelay);
    if (_status != TransportStatus.connecting) return;
    // The app first, so it sees the devices' announces as they come up.
    await _app.connect();
    await home.start();
    _setStatus(_app.currentStatus);
  }

  @override
  Future<void> disconnect() async {
    if (_status == TransportStatus.disconnected) return;
    await _app.disconnect();
    _setStatus(TransportStatus.disconnected);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await disconnect();
    _disposed = true;
    await _appStatus.cancel();
    await _app.dispose();
    await home.dispose();
    await broker.close();
    await _statusController.close();
  }

  @override
  Future<CommandResult> send(
    DeviceCommand command, {
    Duration timeout = Protocol.commandTimeout,
  }) => _app.send(command, timeout: timeout);

  /// Takes a device off the network or brings it back, as a power cut would.
  Future<void> setDeviceOnline(String deviceId, {required bool online}) =>
      home.setOnline(deviceId, online: online);

  /// Cuts the app's link to the broker; it reconnects by itself.
  void dropLink() => broker.drop(appClientId);

  void _onAppStatus(TransportStatus status) {
    // Our own connecting phase is longer than the app's; after that the
    // app's status is the truth.
    if (_status == TransportStatus.connecting &&
        status != TransportStatus.connected) {
      return;
    }
    _setStatus(status);
  }

  void _setStatus(TransportStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }
}
