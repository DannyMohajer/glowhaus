import 'dart:async';
import 'dart:math';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/src/simulated/simulated_device.dart';
import 'package:glowhaus_transport/src/simulated/simulation_config.dart';
import 'package:glowhaus_transport/src/transport.dart';

/// An in-memory [Transport]: devices that react to commands after a small
/// delay, sometimes fail or stay silent, and keep reporting state.
class SimulatedTransport implements Transport {
  new({
    required this.homeId,
    required Iterable<SimulatedDevice> devices,
    this.config = const SimulationConfig(),
    Random? random,
    DateTime Function()? clock,
    this.connectDelay = const Duration(milliseconds: 300),
    this.stateDelay = const Duration(milliseconds: 60),
    this.positionInterval = const Duration(milliseconds: 400),
    this.ambientInterval = const Duration(seconds: 2),
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now,
       _devices = {
         for (final device in devices)
           device.descriptor.id: DeviceRuntime(device),
       };

  final String homeId;

  /// Simulation knobs. May be replaced at any time; applies to new commands.
  SimulationConfig config;

  /// How long [connect] takes.
  final Duration connectDelay;

  /// Gap between an ack and the state message that follows it.
  final Duration stateDelay;

  /// How often a moving curtain reports progress.
  final Duration positionInterval;

  /// How often sensors and meters change by themselves. Null disables it.
  final Duration? ambientInterval;

  final Random _random;
  final DateTime Function() _clock;
  final Map<String, DeviceRuntime> _devices;
  final _statusController = StreamController<TransportStatus>.broadcast();
  final _eventController = StreamController<DeviceEvent>.broadcast();
  final Set<Timer> _timers = {};

  TransportStatus _status = TransportStatus.disconnected;
  Timer? _positionTimer;
  Timer? _ambientTimer;

  @override
  TransportStatus get currentStatus => _status;

  @override
  Stream<TransportStatus> get status => _statusController.stream;

  @override
  Stream<DeviceEvent> get events => _eventController.stream;

  /// Current state of a simulated device, for inspection.
  Map<String, CapabilityState>? deviceState(String deviceId) =>
      _devices[deviceId]?.snapshot();

  @override
  Future<void> connect() async {
    if (_status != TransportStatus.disconnected) return;
    _setStatus(TransportStatus.connecting);
    await Future<void>.delayed(connectDelay);
    if (_status != TransportStatus.connecting) return;
    _setStatus(TransportStatus.connected);

    for (final device in _devices.values) {
      _emit(
        DeviceAnnounced(homeId: homeId, descriptor: device.spec.descriptor),
      );
      _emitAvailability(device);
      _emitState(device);
    }
    final interval = ambientInterval;
    if (interval != null) {
      _ambientTimer = Timer.periodic(interval, (_) => _ambientTick(interval));
    }
    _ensurePositionTimer();
  }

  @override
  Future<void> disconnect() async {
    if (_status == TransportStatus.disconnected) return;
    _cancelTimers();
    _setStatus(TransportStatus.disconnected);
  }

  @override
  Future<void> dispose() async {
    _cancelTimers();
    _status = TransportStatus.disconnected;
    await _statusController.close();
    await _eventController.close();
  }

  @override
  Future<CommandResult> send(
    DeviceCommand command, {
    Duration timeout = Protocol.commandTimeout,
  }) {
    final completer = Completer<CommandResult>();
    final timeoutTimer = _timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(CommandResult.timedOut(commandId: command.id));
      }
    });

    final device = command.homeId == homeId ? _devices[command.deviceId] : null;
    final delivered =
        _status == TransportStatus.connected &&
        device != null &&
        device.online &&
        !_roll(config.timeoutRate);
    if (!delivered) return completer.future;

    _timer(_latency(), () {
      // Too late, or the link or the device went away in the meantime.
      if (completer.isCompleted ||
          _status != TransportStatus.connected ||
          !device.online) {
        return;
      }
      final result = device.handle(
        command,
        now: _clock(),
        shouldFail: () => _roll(config.failureRate),
      );
      timeoutTimer.cancel();
      _timers.remove(timeoutTimer);
      completer.complete(result);
      if (result.isSuccess) {
        _timer(stateDelay, () {
          _emitState(device);
          _ensurePositionTimer();
        });
      }
    });
    return completer.future;
  }

  /// Takes a device off the network or brings it back, as a power cut would.
  void setDeviceOnline(String deviceId, {required bool online}) {
    final device = _devices[deviceId];
    if (device == null || device.online == online) return;
    device.online = online;
    if (_status != TransportStatus.connected) return;
    _emitAvailability(device);
    if (online) _emitState(device);
  }

  void _ambientTick(Duration elapsed) {
    for (final device in _devices.values) {
      if (!device.online) continue;
      if (device.ambientTick(_random, elapsed: elapsed, now: _clock())) {
        _emitState(device);
      }
    }
  }

  void _ensurePositionTimer() {
    if (_positionTimer != null ||
        _status != TransportStatus.connected ||
        !_devices.values.any((device) => device.isMoving)) {
      return;
    }
    _positionTimer = Timer.periodic(positionInterval, (timer) {
      var anyMoving = false;
      for (final device in _devices.values) {
        if (!device.online) continue;
        if (device.stepPositions()) _emitState(device);
        anyMoving = anyMoving || device.isMoving;
      }
      if (!anyMoving) {
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

  Timer _timer(Duration duration, void Function() callback) {
    late final Timer timer;
    timer = Timer(duration, () {
      _timers.remove(timer);
      callback();
    });
    _timers.add(timer);
    return timer;
  }

  /// Cancels device-side timers. Command timeouts keep running so callers of
  /// [send] always get an answer.
  void _cancelTimers() {
    _positionTimer?.cancel();
    _positionTimer = null;
    _ambientTimer?.cancel();
    _ambientTimer = null;
  }

  void _setStatus(TransportStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  void _emit(DeviceEvent event) {
    if (!_eventController.isClosed) _eventController.add(event);
  }

  void _emitAvailability(DeviceRuntime device) => _emit(
    DeviceAvailabilityChanged(
      homeId: homeId,
      deviceId: device.id,
      availability: device.online
          ? DeviceAvailability.online
          : DeviceAvailability.offline,
    ),
  );

  void _emitState(DeviceRuntime device) {
    if (_status != TransportStatus.connected || !device.online) return;
    _emit(
      DeviceStateChanged(
        homeId: homeId,
        deviceId: device.id,
        state: device.snapshot(),
        at: _clock(),
      ),
    );
  }
}
