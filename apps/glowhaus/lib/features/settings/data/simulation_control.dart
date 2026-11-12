import 'package:glowhaus_transport/glowhaus_transport.dart';

/// Lets settings tune the simulated network without knowing the transport.
abstract interface class SimulationControl {
  /// False when the app talks to real devices; the settings section hides.
  bool get available;

  void apply({required Duration latency, required double failureRate});
}

class TransportSimulationControl implements SimulationControl {
  new(this._transport);

  final SimulatedTransport _transport;

  @override
  bool get available => true;

  /// Half of the unlucky commands are rejected, half are never answered, so
  /// both the failure and the timeout path show up.
  @override
  void apply({required Duration latency, required double failureRate}) {
    _transport.config = _transport.config.copyWith(
      latency: latency,
      failureRate: failureRate / 2,
      timeoutRate: failureRate / 2,
    );
  }
}
