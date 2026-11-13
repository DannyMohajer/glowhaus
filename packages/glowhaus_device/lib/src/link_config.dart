import 'package:meta/meta.dart';

/// Knobs of the simulation, adjustable while it runs.
@immutable
class SimulationConfig {
  const new({
    this.latency = const Duration(milliseconds: 250),
    this.latencyJitter = 0.4,
    this.failureRate = 0,
    this.timeoutRate = 0,
  }) : assert(latencyJitter >= 0 && latencyJitter <= 1, 'jitter is 0..1'),
       assert(failureRate >= 0 && failureRate <= 1, 'failureRate is 0..1'),
       assert(timeoutRate >= 0 && timeoutRate <= 1, 'timeoutRate is 0..1');

  /// Mean time between sending a command and its ack.
  final Duration latency;

  /// Random spread of [latency], as a fraction of it (0.4 = plus/minus 40%).
  final double latencyJitter;

  /// Probability that a device rejects a valid command.
  final double failureRate;

  /// Probability that a command is lost and never acked.
  final double timeoutRate;

  SimulationConfig copyWith({
    Duration? latency,
    double? latencyJitter,
    double? failureRate,
    double? timeoutRate,
  }) => SimulationConfig(
    latency: latency ?? this.latency,
    latencyJitter: latencyJitter ?? this.latencyJitter,
    failureRate: failureRate ?? this.failureRate,
    timeoutRate: timeoutRate ?? this.timeoutRate,
  );

  @override
  bool operator ==(Object other) =>
      other is SimulationConfig &&
      other.latency == latency &&
      other.latencyJitter == latencyJitter &&
      other.failureRate == failureRate &&
      other.timeoutRate == timeoutRate;

  @override
  int get hashCode =>
      Object.hash(latency, latencyJitter, failureRate, timeoutRate);
}
