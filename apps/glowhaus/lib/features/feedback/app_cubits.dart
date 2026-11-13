import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:meta/meta.dart';

/// The state of the connection to the home, for the connection badge.
class ConnectionCubit extends Cubit<TransportStatus> {
  new(DeviceRepository devices) : super(TransportStatus.disconnected) {
    _subscription = devices.status.listen(emit);
  }

  late final StreamSubscription<TransportStatus> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

@immutable
class FeedbackState {
  const new({this.failure, this.lateApply, this.sequence = 0});

  /// The most recent command that was rolled back, unless [lateApply] is
  /// the more recent event.
  final CommandFailure? failure;

  /// The most recent timed-out command that turned out to be applied.
  final LateApply? lateApply;

  /// Increases with every failure, so two identical failures in a row are
  /// still two events.
  final int sequence;
}

/// Surfaces rolled-back commands, and the rare command that was applied
/// after its timeout, so the app can explain what happened no matter which
/// screen sent the command.
class FeedbackCubit extends Cubit<FeedbackState> {
  new(DeviceRepository devices) : super(const FeedbackState()) {
    _failures = devices.failures.listen(
      (failure) =>
          emit(FeedbackState(failure: failure, sequence: state.sequence + 1)),
    );
    _lateApplies = devices.lateApplies.listen(
      (late) =>
          emit(FeedbackState(lateApply: late, sequence: state.sequence + 1)),
    );
  }

  late final StreamSubscription<CommandFailure> _failures;
  late final StreamSubscription<LateApply> _lateApplies;

  @override
  Future<void> close() async {
    await _failures.cancel();
    await _lateApplies.cancel();
    await super.close();
  }
}
