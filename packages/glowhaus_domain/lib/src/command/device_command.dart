import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability_patch.dart';
import 'package:glowhaus_domain/src/protocol/payloads.dart';
import 'package:glowhaus_domain/src/protocol/protocol_error.dart';

part 'device_command.freezed.dart';

/// A request to change one or more capabilities of one device. Atomic.
@freezed
abstract class DeviceCommand with _$DeviceCommand {
  const factory({
    required String id,
    required String homeId,
    required String deviceId,
    required DateTime issuedAt,
    required Map<String, CapabilityPatch> patches,
  }) = _DeviceCommand;

  const new _();

  /// The `set` payload for this command.
  SetPayload toPayload() => SetPayload(
    commandId: id,
    ts: issuedAt.millisecondsSinceEpoch,
    set: <String, Map<String, dynamic>>{
      for (final MapEntry(:key, :value) in patches.entries) key: value.toWire(),
    },
  );
}

/// Where a command is in its lifecycle. `pending` is the only non-final one.
enum CommandStatus { pending, acked, failed, timedOut, unreachable }

/// The final outcome of a command.
@freezed
sealed class CommandResult with _$CommandResult {
  /// The device accepted the command. Its state will follow.
  const factory acked({required String commandId}) = CommandAcked;

  /// The device rejected the command.
  const factory failed({
    required String commandId,
    required ProtocolErrorCode code,
    String? message,
  }) = CommandFailed;

  /// No ack arrived in time.
  const factory timedOut({required String commandId}) = CommandTimedOut;

  /// The app had no connection to the broker, so the command was never
  /// sent (or the connection dropped while it was pending). Only the app
  /// side produces this; a device never sees such a command.
  const factory unreachable({required String commandId}) = CommandUnreachable;

  const new _();

  CommandStatus get status => switch (this) {
    CommandAcked() => CommandStatus.acked,
    CommandFailed() => CommandStatus.failed,
    CommandTimedOut() => CommandStatus.timedOut,
    CommandUnreachable() => CommandStatus.unreachable,
  };

  bool get isSuccess => this is CommandAcked;
}
