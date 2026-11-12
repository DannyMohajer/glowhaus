import 'dart:math';

import 'package:meta/meta.dart';

/// Exponential backoff with jitter for reconnecting to a broker.
///
/// Attempt 0 waits [initial], each next attempt doubles (by [multiplier])
/// up to [maximum]; every wait is spread by plus or minus [jitter] so a
/// fleet of clients does not hammer a broker in lockstep after an outage.
@immutable
class ReconnectPolicy {
  const new({
    this.initial = const Duration(seconds: 1),
    this.maximum = const Duration(seconds: 30),
    this.multiplier = 2,
    this.jitter = 0.5,
  }) : assert(multiplier >= 1, 'backoff never shrinks'),
       assert(jitter >= 0 && jitter <= 1, 'jitter is a fraction');

  final Duration initial;
  final Duration maximum;
  final double multiplier;
  final double jitter;

  /// How long to wait before reconnect attempt number [attempt] (0-based).
  Duration delay(int attempt, Random random) {
    var base = initial.inMicroseconds * pow(multiplier, attempt);
    base = min(base, maximum.inMicroseconds.toDouble());
    final spread = 1 + jitter * (random.nextDouble() * 2 - 1);
    return Duration(microseconds: (base * spread).round());
  }
}
