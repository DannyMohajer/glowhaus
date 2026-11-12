import 'dart:async';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

/// A transport the test drives by hand: it decides when and how each command
/// is answered and which events arrive.
class FakeTransport implements Transport {
  final _events = StreamController<DeviceEvent>.broadcast(sync: true);
  final _status = StreamController<TransportStatus>.broadcast(sync: true);

  /// Commands in the order they were sent.
  final sent = <DeviceCommand>[];
  final _answers = <String, Completer<CommandResult>>{};

  @override
  TransportStatus currentStatus = TransportStatus.disconnected;

  @override
  Stream<DeviceEvent> get events => _events.stream;

  @override
  Stream<TransportStatus> get status => _status.stream;

  void setStatus(TransportStatus status) {
    currentStatus = status;
    _status.add(status);
  }

  @override
  Future<void> connect() async => setStatus(TransportStatus.connected);

  @override
  Future<void> disconnect() async => setStatus(TransportStatus.disconnected);

  @override
  Future<void> dispose() async {
    await _events.close();
    await _status.close();
  }

  @override
  Future<CommandResult> send(
    DeviceCommand command, {
    Duration timeout = Protocol.commandTimeout,
  }) {
    sent.add(command);
    return (_answers[command.id] = Completer<CommandResult>()).future;
  }

  DeviceCommand get lastCommand => sent.last;

  void ack([DeviceCommand? command]) {
    final c = command ?? lastCommand;
    _answers[c.id]!.complete(CommandResult.acked(commandId: c.id));
  }

  void reject(ProtocolErrorCode code, [DeviceCommand? command]) {
    final c = command ?? lastCommand;
    _answers[c.id]!.complete(CommandResult.failed(commandId: c.id, code: code));
  }

  void unreachable([DeviceCommand? command]) {
    final c = command ?? lastCommand;
    _answers[c.id]!.complete(CommandResult.unreachable(commandId: c.id));
  }

  void timeOut([DeviceCommand? command]) {
    final c = command ?? lastCommand;
    _answers[c.id]!.complete(CommandResult.timedOut(commandId: c.id));
  }

  /// Announces every device of [devices] with availability and state, as a
  /// transport does after connecting.
  void seed(
    Iterable<SimulatedDevice> devices, {
    String homeId = DemoHome.homeId,
  }) {
    for (final device in devices) {
      final id = device.descriptor.id;
      _events
        ..add(DeviceAnnounced(homeId: homeId, descriptor: device.descriptor))
        ..add(
          DeviceAvailabilityChanged(
            homeId: homeId,
            deviceId: id,
            availability: device.online
                ? DeviceAvailability.online
                : DeviceAvailability.offline,
          ),
        );
      if (device.online) reportState(id, device.initialState);
    }
  }

  void reportState(
    String deviceId,
    Map<String, CapabilityState> state, {
    String homeId = DemoHome.homeId,
  }) => _events.add(
    DeviceStateChanged(
      homeId: homeId,
      deviceId: deviceId,
      state: state,
      at: DateTime.utc(2026, 11, 12),
    ),
  );

  void emit(DeviceEvent event) => _events.add(event);

  /// The device does what [command] asked: its state now includes the patches.
  void applyAndReport(
    Map<String, CapabilityState> before, [
    DeviceCommand? command,
  ]) {
    final c = command ?? lastCommand;
    final next = Map<String, CapabilityState>.of(before);
    for (final MapEntry(:key, :value) in c.patches.entries) {
      final patched = value.applyTo(next[key]);
      if (patched != null) next[key] = patched;
    }
    reportState(c.deviceId, next);
  }
}
